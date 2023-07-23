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
import org.openurp.base.service.UserCategories
import org.openurp.code.edu.model.{ActivityType, ClassroomType}
import org.openurp.edu.clazz.service.CourseTableStyle
import org.openurp.edu.room.log.RoomApplyAuditLog
import org.openurp.edu.room.model.*
import org.openurp.edu.room.service.RoomApplyService
import org.openurp.edu.room.util.OccupancyUtils
import org.openurp.edu.room.web.helper.ApplyTime
import org.openurp.starter.web.support.ProjectSupport

import java.time.temporal.ChronoUnit
import java.time.{Instant, LocalDate, ZoneId}
import scala.collection.immutable.TreeMap
import scala.collection.mutable

/** 教职工申请借教室
 */
class StaffApplyAction extends ActionSupport, EntityAction[RoomApply], ProjectSupport {

  var entityDao: EntityDao = _

  var roomApplyService: RoomApplyService = _

  def index(): View = {
    put("setting", roomApplyService.getSetting(null))
    forward()
  }

  def searchRooms(): View = {
    val q = OqlBuilder.from(classOf[Building], "b")
    q.where("b.endOn is null")
    put("buildings", entityDao.search(q))

    put("roomTypes", codeService.get(classOf[ClassroomType]))
    val setting = roomApplyService.getSetting(null).get
    put("setting", setting)
    val applicant = getUser
    if (Set(UserCategories.Teacher, UserCategories.Student).contains(applicant.category.id)) {
      put("beginOn", LocalDate.now().plusDays(setting.daysBeforeApply))
    } else {
      put("beginOn", LocalDate.now())
    }

    val ts = OqlBuilder.from(classOf[TimeSetting], "ts")
    ts.where("ts.endOn is null")
    put("timeSettings", entityDao.search(ts))
    forward()
  }

  def applyForm(): View = {
    val time = getApplyTime()
    val applicant = getUser
    put("time", time)

    val activityTypes = codeService.get(classOf[ActivityType]).sortBy(_.id)
    val activityType = if (applicant.category.id == UserCategories.Teacher) {
      activityTypes.find(_.name.contains("课")).getOrElse(activityTypes.head)
    } else {
      activityTypes.head
    }
    put("unitAttendance", getInt("room.capacity", 0))
    put("activityTypes", TreeMap.from(activityTypes.map(x => (x.id, x.name))))
    put("activityType", activityType)
    val rooms = entityDao.find(classOf[Classroom], getLongIds("classroom"))
    put("classrooms", rooms)
    put("applicant", applicant)
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

    val rooms = entityDao.find(classOf[Classroom], getLongIds("classroom"))
    apply.space.roomComment = Some(rooms.map(_.name).mkString(","))
    apply.space.campus = rooms.head.campus
    roomApplyService.submit(apply, user)

    if (getBoolean("saveMobile", false)) {
      user.mobile = Some(apply.applicant.mobile)
      entityDao.saveOrUpdate(user)
    }
    redirect("search", "借用申请提交完成")
  }

  protected def buildFreeRoomQuery(): OqlBuilder[Classroom] = {
    val time = getApplyTime()
    val weektimes = time.toWeektimes()
    val query = OccupancyUtils.buildFreeroomQuery(weektimes)
    query.where("room.roomNo is not null") //虚拟教室不能借用
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
  }

  def freeRooms(): View = {
    val query = buildFreeRoomQuery()
    put("classrooms", entityDao.search(query))
    forward()
  }

  @mapping(value = "{id}")
  def info(@param("id") id: String): View = {
    val apply = entityDao.get(classOf[RoomApply], id.toLong)
    put("roomApply", apply)
    put("roomApplyLogs", entityDao.findBy(classOf[RoomApplyAuditLog], "roomApply", apply))
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
    if (!query.hasOrderBy) query.orderBy("roomApply.applyAt desc")
    query
  }

  @mapping(method = "delete")
  def remove(): View = {
    val query = OqlBuilder.from(classOf[RoomApply], "apply")
    query.where("apply.applyBy=:me", getUser)
    query.where("apply.id in(:applyIds)", getLongIds("roomApply"))
    val applies = entityDao.search(query)
    var removed = 0
    var reserved = 0
    applies foreach { apply =>
      if (apply.rooms.isEmpty) {
        roomApplyService.remove(apply)
        removed += 1
      } else {
        reserved += 1
      }
    }
    if (removed == 0) redirect("search", "不能删除已经审批的教室")
    else redirect("search", s"成功删除${removed}个教室申请")
  }

  def getUser: User = {
    entityDao.findBy(classOf[User], "code", List(Securities.user)).headOption.orNull
  }

  def setting(): View = {
    put("setting", roomApplyService.getSetting(null))
    forward()
  }
}
