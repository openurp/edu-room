/*
 * Copyright (C) 2014, The OpenURP Software.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

package org.openurp.edu.room.web.action

import org.beangle.commons.collection.{Collections, Order}
import org.beangle.commons.lang.Strings
import org.beangle.commons.lang.time.{HourMinute, WeekDay, WeekTime}
import org.beangle.data.dao.{EntityDao, OqlBuilder}
import org.beangle.security.Securities
import org.beangle.template.freemarker.ProfileTemplateLoader
import org.beangle.web.action.annotation.{mapping, param}
import org.beangle.web.action.support.ActionSupport
import org.beangle.web.action.view.View
import org.beangle.webmvc.support.action.{EntityAction, RestfulAction}
import org.openurp.base.edu.model.{Classroom, CourseUnit, TimeSetting}
import org.openurp.base.model.*
import org.openurp.code.edu.model.{ActivityType, ClassroomType}
import org.openurp.edu.clazz.service.CourseTableStyle
import org.openurp.edu.room.model.*
import org.openurp.edu.room.util.OccupancyUtils
import org.openurp.edu.room.web.helper.ApplyTime
import org.openurp.starter.web.support.ProjectSupport

import java.time.temporal.ChronoUnit
import java.time.{Instant, LocalDate, ZoneId}
import scala.collection.mutable

class ApplyAction extends ActionSupport, EntityAction[RoomApply], ProjectSupport {

  var entityDao: EntityDao = _

  def index(): View = {
    forward()
  }

  def searchRooms(): View = {
    val q = OqlBuilder.from(classOf[Building], "b")
    q.where("b.endOn is null")
    put("buildings", entityDao.search(q))
    put("roomTypes", codeService.get(classOf[ClassroomType]))
    forward()
  }

  def applyForm(): View = {
    val time = getApplyTime()
    put("time", time)
    put("activityTypes", codeService.get(classOf[ActivityType]).map(x => (x.id, x.name)).toMap)
    val rooms = entityDao.find(classOf[Classroom], getLongIds("classroom"))
    put("classrooms", rooms)
    put("applicant", this.getUser)
    forward()
  }

  protected def getApplyTime(): ApplyTime = {
    val time = new ApplyTime()
    time.beginOn = getDate("time.beginOn").get
    getDate("time.endOn") foreach { d => time.endOn = d }
    time.beginAt = HourMinute(get("time.beginAt", "00:00"))
    time.endAt = HourMinute(get("time.endAt", "00:00"))
    time.cycle = getInt("time.cycle", 1)
    time.build()
  }

  def saveApply(): View = {
    val time = getApplyTime()
    val apply = this.populate(classOf[RoomApply], "apply")

    if (null == apply.time) apply.time = new TimeRequest()
    apply.time.times.addAll(time.toWeektimes())
    apply.time.beginOn = time.beginOn
    apply.time.endOn = time.endOn

    val user = getUser
    apply.applicant.auditDepart = user.department
    apply.applicant.user = user

    val activity = apply.activity
    activity.speaker = "--"
    activity.attendance = "--"

    val rooms = entityDao.find(classOf[Classroom], getLongIds("classroom"))
    apply.space.roomComment = Some(rooms.map(_.name).mkString(","))
    apply.space.campus = rooms.head.campus
    apply.school = user.school
    apply.applyBy = user
    apply.applyAt = Instant.now
    entityDao.saveOrUpdate(apply)
    redirect("search", "借用申请提交完成")
  }

  def freeRooms(): View = {
    val time = getApplyTime()
    val weektimes = time.toWeektimes()
    val query = OccupancyUtils.buildFreeroomQuery(weektimes)
    query.where("room.roomNo is not null")
    populateConditions(query, "room.capacity")
    getInt("room.capacity") foreach { capacity =>
      query.where("room.courseCapacity>=:capacity", capacity)
    }
    get(Order.OrderStr) match {
      case Some(orderClause) => query.orderBy(orderClause)
      case None => query.orderBy("room.name,room.capacity")
    }
    query.where("room.roomNo is not null");
    query.limit(getPageLimit)
    put("classrooms", entityDao.search(query))
    forward()
  }

  @mapping(value = "{id}")
  def info(@param("id") id: String): View = {
    val entityType = entityDao.domain.getEntity(entityClass).get
    put(simpleEntityName, getModel[RoomApply](entityType, convertId(entityType, id)))
    forward()
  }

  def report(@param("id") id: String): View = {
    val apply = entityDao.get(classOf[RoomApply], id.toLong)
    put("roomApply", apply)
    ProfileTemplateLoader.setProfile(apply.school.id)
    forward("../report")
  }

  def search(): View = {
    put("roomApplies", entityDao.search(getQueryBuilder))
    forward()
  }

  override def getQueryBuilder: OqlBuilder[RoomApply] = {
    val query = super.getQueryBuilder
    query.where("roomApply.applyBy=:me", getUser)
    query
  }

  def edit(roomApply: RoomApply): Unit = {
    given project: Project = getProject

    put("departments", getDeparts)
    put("campuses", findInSchool(classOf[Campus]))
    put("activityTypes", getCodes(classOf[ActivityType]))
    put("timeSettings", getTimeSettings)
    put("currentSemester", getSemester)
    roomApply.applyBy = getUser

    // 每个学期能够选择的教学周集合
    val semesterWeeks = Collections.newMap[Semester, mutable.Set[Int]]
    // 每个学期缺省的最大教学周
    val defaultMaxWeeks = Collections.newMap[Semester, Int]

    val applyAt = if (roomApply.applyAt == null) Instant.now else roomApply.applyAt
    val applyOn = LocalDate.ofInstant(applyAt, ZoneId.systemDefault())
    val semesters = getSemesters(applyOn)
    semesters.foreach(s => {
      val weekList = buildWeekList(s, null)
      if (applyOn.isBefore(s.endOn) && applyOn.isAfter(s.beginOn)) {
        val length = s.beginOn.until(applyOn, ChronoUnit.DAYS)
        val startWeek = Math.ceil(length / 7.0).toInt + 1
        val starts = Collections.newSet[Int]
        for (i <- 1 until startWeek) {
          starts.add(i)
        }
        weekList.--=(starts)
      }
      semesterWeeks.put(s, weekList)
      defaultMaxWeeks.put(s, getWeeks(s))
    })
    put("tableStyle", CourseTableStyle.WEEK_TABLE)
    put("CourseTableStyle", CourseTableStyle)
    put("weekList", WeekDay.values)
    put("semesterWeeks", semesterWeeks)
    put("defaultMaxWeeks", defaultMaxWeeks)
  }

  def getUser: User = {
    val users = entityDao.findBy(classOf[User], "code", List(Securities.user))
    if (users.isEmpty) {
      null
    } else {
      users.head
    }
  }

  def getTimeSettings: Seq[TimeSetting] = {
    val settingQuery = OqlBuilder.from(classOf[TimeSetting], "ts").where("ts.project=:project", getProject)
    entityDao.search(settingQuery)
  }

  private def getWeeks(semester: Semester): Int = {
    val length = semester.beginOn.until(semester.endOn, ChronoUnit.DAYS)
    Math.ceil(length / 7.0).toInt
  }

  private def buildWeekList(semester: Semester, next: Semester): mutable.Set[Int] = {
    val maxWeek = if (null != next) {
      val length = semester.beginOn.until(next.beginOn, ChronoUnit.DAYS)
      Math.ceil(length / 7.0).toInt
    } else {
      getWeeks(semester)
    }
    val weekList = Collections.newSet[Int]
    for (i <- 1 to maxWeek) {
      weekList.add(i)
    }
    weekList
  }

  def getSemesters(localDate: LocalDate): Seq[Semester] = {
    val builder = OqlBuilder.from(classOf[Semester], "semester")
    builder.where("semester.calendar.school=:school", getProject.school)
    builder.where("semester.endOn >=:now", localDate)
    builder.orderBy("semester.code desc")
    entityDao.search(builder)
  }

  def buildApply(): RoomApply = {
    val roomApply = populateEntity(classOf[RoomApply], "roomApply")
    val semester = entityDao.get(classOf[Semester], getIntId("semester"))
    val timeSetting = getTimeSettings.head
    get("weekState").foreach(weekState => {
      get("classUnit").foreach(classUnit => {
        val timeRequest = buildApplyTimeByWeekState(timeSetting, semester, weekState, classUnit)
        roomApply.time = timeRequest
      })
    })

    if (0 >= roomApply.space.unitAttendance) roomApply.space.unitAttendance = roomApply.activity.attendanceNum
    roomApply.applyAt = Instant.now()
    roomApply.applyBy = getUser
    roomApply.school = getUser.school
    roomApply.activity.attendance = "--"
    roomApply.activity.speaker = "--"
    roomApply
  }

  def buildApplyTimeByWeekState(timeSetting: TimeSetting, semester: Semester, state: String, courseUnitString: String): TimeRequest = {
    val weeks = Strings.splitToInt(state)
    val maxUnitSize = timeSetting.units.size
    val units = Strings.splitToInt(courseUnitString)
    val builder = WeekTimeBuilder.on(semester)
    var alltimes = Collections.newBuffer[WeekTime]
    val unitMap = entityDao.findBy(classOf[CourseUnit], "setting", List(timeSetting)).map(e => (e.indexno, e)).toMap

    units.indices.foreach(i => {
      val weekId = units(i) / maxUnitSize + 1
      val unitIndex = units(i) % maxUnitSize + 1
      val times = builder.build(WeekDay.of(weekId), weeks)
      unitMap.get(unitIndex).foreach(unit => {
        times.foreach(time => {
          time.beginAt = unit.beginAt
          time.endAt = unit.endAt
        })
      })
      alltimes.addAll(times)
    })
    alltimes = WeekTimeBuilder.mergeTimes(alltimes, 15)
    var beginOn: LocalDate = null
    var endOn: LocalDate = null
    alltimes.foreach(timeUnit => {
      if (null == beginOn || timeUnit.firstDay.isBefore(beginOn)) beginOn = timeUnit.firstDay
      if (null == endOn || timeUnit.lastDay.isAfter(endOn)) endOn = timeUnit.lastDay
    })
    val timeRequest = new TimeRequest
    timeRequest.times = alltimes
    timeRequest.beginOn = beginOn
    timeRequest.endOn = endOn
    timeRequest.timeComment = get("timeComment")
    timeRequest
  }

  def submitApply(): View = {
    val roomApply = buildApply()
    val days = roomApply.time.beginOn.toEpochDay - LocalDate.now.toEpochDay
    if (days < 2) {
      redirect("search", "请至少提前两天申请教室!")
    } else {
      try {
        saveOrUpdate(roomApply)
        //        val departCheck = roomApply.departCheck match {
        //          case Some(value) => value
        //          case None => new RoomApplyDepartCheck
        //        }
        //        departCheck.roomApply = roomApply
        //        departCheck.approved = true
        //        departCheck.checkedAt = Instant.now()
        //        departCheck.checkedBy = getUser
        //        saveOrUpdate(departCheck)
        //        roomApply.departCheck = Option(departCheck)
        saveOrUpdate(roomApply)
        redirect("search", "info.save.success")
      }
      catch {
        case e: Exception =>
          logger.info("saveAndForwad failure", e)
          redirect("search", "info.save.failure")
      }
    }
  }

  //  @mapping(method = "delete")
  //  override def remove(): View = {
  //    val idclass = entityDao.domain.getEntity(entityName).get.id.clazz
  //    val entities: Seq[RoomApply] = getId(simpleEntityName, idclass) match {
  //      case Some(entityId) => List(getModel[RoomApply](entityName, entityId))
  //      case None => getModels[RoomApply](entityName, ids(simpleEntityName, idclass))
  //    }
  //    try {
  //      entities.foreach(entity => {
  //        entity.departCheck.foreach(departCheck => {
  //          remove(departCheck)
  //        })
  //        entity.finalCheck.foreach(finalCheck => {
  //          remove(finalCheck)
  //        })
  //      })
  //      removeAndRedirect(entities)
  //    } catch {
  //      case e: Exception =>
  //        logger.info("removeAndRedirect failure", e)
  //        redirect("search", "info.delete.failure")
  //    }
  //  }

}
