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
import org.beangle.commons.lang.time.{HourMinute, WeekDay, WeekTime}
import org.beangle.commons.lang.{Enums, Strings}
import org.beangle.data.dao.OqlBuilder
import org.beangle.web.action.annotation.mapping
import org.beangle.web.action.context.ActionContext
import org.beangle.web.action.view.View
import org.openurp.base.edu.model.{Classroom, CourseUnit, TimeSetting}
import org.openurp.base.model.*
import org.openurp.code.edu.model.{ActivityType, ClassroomType}
import org.openurp.edu.clazz.service.CourseTableStyle
import org.openurp.edu.room.model.*
import org.openurp.edu.room.model.CycleTime.CycleTimeType
import org.openurp.edu.room.service.RoomApplyService
import org.openurp.edu.room.util.OccupancyUtils

import java.time.temporal.ChronoUnit
import java.time.{Instant, LocalDate, ZoneId}
import scala.collection.immutable.TreeMap
import scala.collection.mutable
import scala.sys.error

/** 代理借用
 */
class AgentAction extends StaffApplyAction {

  override def searchRooms(): View = {
    val q = OqlBuilder.from(classOf[Building], "b")
    q.where("b.endOn is null")
    put("buildings", entityDao.search(q))
    put("roomTypes", codeService.get(classOf[ClassroomType]))
    put("beginOn", LocalDate.now())

    val ts = OqlBuilder.from(classOf[TimeSetting], "ts")
    ts.where("ts.endOn is null")
    put("timeSettings", entityDao.search(ts))
    forward()
  }

  override def applyForm(): View = {
    val time = getApplyTime()
    put("time", time)
    val activityTypes = codeService.get(classOf[ActivityType]).sortBy(_.id)
    val activityType = activityTypes.head
    put("activityTypes", TreeMap.from(activityTypes.map(x => (x.id, x.name))))
    put("activityType", activityType)
    val rooms = entityDao.find(classOf[Classroom], getLongIds("classroom"))
    put("classrooms", rooms)
    put("user", this.getUser)
    put("hasSmsSupport", smsService.nonEmpty)
    forward()
  }

  override def saveApply(): View = {
    val time = getApplyTime()
    val apply = this.populate(classOf[RoomApply], "apply")

    if (null == apply.time) apply.time = new TimeRequest()
    apply.time.times.addAll(time.toWeektimes())
    apply.time.beginOn = time.beginOn
    apply.time.endOn = time.endOn

    val applicant = entityDao.get(classOf[User], getLongId("applicant"))
    val applier = getUser
    apply.applicant.auditDepart = applier.department
    apply.applicant.user = applicant
    apply.departApproved = Some(true)

    val activity = apply.activity

    val rooms = entityDao.find(classOf[Classroom], getLongIds("classroom"))
    apply.space.campus = rooms.head.campus
    roomApplyService.submit(apply, applier)
    roomApplyService.approve(apply, applier, rooms)
    businessLogger.info(s"代理借用了教室(${apply.activity.name})", apply.id, ActionContext.current.params)
    redirect("search", "借用提交完成")
  }

  @mapping(method = "delete")
  override def remove(): View = {
    val query = OqlBuilder.from(classOf[RoomApply], "apply")
    query.where("apply.applyBy=:me", getUser)
    query.where("apply.id in(:applyIds)", getLongIds("roomApply"))
    val applies = entityDao.search(query)
    applies foreach { apply =>
      roomApplyService.remove(apply)
      businessLogger.info(s"删除教室借用申请(${apply.activity.name})", apply.id, ActionContext.current.params)
    }
    redirect("search", s"成功删除${applies.size}个教室申请")
  }

  //---------------------------old code
  def getCycleTime(): CycleTime = {
    val cycleDate = new CycleTime
    getInt("cycleTime.cycleCount").foreach(cycleCount => {
      cycleDate.cycleCount = cycleCount
    })
    getInt("cycleTime.cycleType").foreach(cycleType => {
      cycleDate.cycleType = Enums.of(classOf[CycleTimeType], cycleType).get
    })
    getDate("cycleTime.beginOn").foreach(dateBegin => {
      cycleDate.beginOn = dateBegin
    })
    getDate("cycleTime.endOn").foreach(dateEnd => {
      cycleDate.endOn = dateEnd
    })
    val roomApplyTimeType = getBoolean("roomApplyTimeType", true)
    if (roomApplyTimeType) {
      get("timeBegin").foreach(beginAtContent => {
        cycleDate.beginAt = HourMinute.apply(beginAtContent)
      })
      get("timeEnd").foreach(endAtContent => {
        cycleDate.endAt = HourMinute.apply(endAtContent)
      })
    } else {
      val timeSetting = if (getTimeSettings.nonEmpty) getTimeSettings.head else null
      if (null == timeSetting) error("没有相应时间设置")
      getInt("timeBegin").foreach(beginAtUnit => {
        cycleDate.beginAt = timeSetting.units(beginAtUnit).beginAt
      })
      getInt("timeEnd").foreach(endAtUnit => {
        cycleDate.endAt = timeSetting.units(endAtUnit).endAt
      })
    }
    cycleDate
  }

  def quickApplySetting(): View = {
    given project: Project = getProject

    getInt("cycleTime.cycleCount").foreach(cycleCount => {
      put("cycleCount", cycleCount)
    })
    get("cycleTime.cycleType").foreach(cycleType => {
      put("cycleType", cycleType)
    })
    getDate("cycleTime.beginOn").foreach(beginOn => {
      put("beginOn", beginOn)
    })
    getDate("cycleTime.endOn").foreach(endOn => {
      put("endOn", endOn)
    })
    val roomApplyTimeType = getBoolean("roomApplyTimeType", true)
    if (roomApplyTimeType) {
      get("timeBegin").foreach(timeBegin => {
        put("timeBegin", timeBegin)
      })
      get("timeEnd").foreach(timeEnd => {
        put("timeEnd", timeEnd)
      })
    } else {
      val timeSetting = if (getTimeSettings.nonEmpty) getTimeSettings.head else null
      if (null == timeSetting) error("没有相应时间设置")
      getInt("timeBegin").foreach(beginAtUnit => {
        put("timeBegin", timeSetting.units(beginAtUnit).beginAt)
      })
      getInt("timeEnd").foreach(endAtUnit => {
        put("timeEnd", timeSetting.units(endAtUnit).endAt)
      })
    }
    put("activityTypes", getCodes(classOf[ActivityType]))
    put("departments", getDeparts)
    get("roomIds").foreach(roomIdStr => {
      val roomIds = Strings.splitToLong(roomIdStr)
      val rooms = entityDao.find(classOf[Classroom], roomIds)
      put("roomIds", roomIds)
      put("rooms", rooms)
      var maxCapacity = 0
      rooms.foreach(room => {
        maxCapacity += room.capacity
      })
      put("maxCapacity", maxCapacity)
    })
    forward()
  }

  def submitApply(): View = {
    val roomApply = buildApply()
    val days = roomApply.time.beginOn.toEpochDay - LocalDate.now.toEpochDay
    if (days < 2) {
      redirect("index", "&alert=1", null)
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
        //        val finalCheck = roomApply.finalCheck match {
        //          case Some(value) => value
        //          case None => new RoomApplyFinalCheck
        //        }
        //        finalCheck.roomApply = roomApply
        //        finalCheck.approved = true
        //        finalCheck.checkedAt = Instant.now()
        //        finalCheck.checkedBy = getUser
        //        saveOrUpdate(finalCheck)
        //        roomApply.finalCheck = Option(finalCheck)
        roomApply.approved = Option(true)
        saveOrUpdate(roomApply)
        redirect("info", "&id=" + roomApply.id, null)
      }
      catch {
        case e: Exception =>
          logger.info("saveAndForwad failure", e)
          redirect("index", "info.save.failure")
      }
    }
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

}
