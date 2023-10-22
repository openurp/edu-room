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

import org.beangle.commons.collection.Order
import org.beangle.commons.lang.Strings
import org.beangle.commons.lang.time.HourMinute
import org.beangle.data.dao.{EntityDao, OqlBuilder}
import org.beangle.ems.app.web.WebBusinessLogger
import org.beangle.security.Securities
import org.beangle.template.freemarker.ProfileTemplateLoader
import org.beangle.web.action.annotation.{mapping, param}
import org.beangle.web.action.context.ActionContext
import org.beangle.web.action.support.ActionSupport
import org.beangle.web.action.view.View
import org.beangle.webmvc.support.action.EntityAction
import org.beangle.webmvc.support.helper.QueryHelper
import org.openurp.base.edu.model.{Classroom, TimeSetting}
import org.openurp.base.model.*
import org.openurp.base.service.UserCategories
import org.openurp.code.edu.model.{ActivityType, ClassroomType}
import org.openurp.edu.room.log.RoomApplyAuditLog
import org.openurp.edu.room.model.*
import org.openurp.edu.room.service.{RoomApplyService, SmsService}
import org.openurp.edu.room.util.OccupancyUtils
import org.openurp.starter.web.support.ProjectSupport

import java.time.LocalDate
import scala.collection.immutable.TreeMap

/** 教职工申请借教室
 */
class StaffApplyAction extends ActionSupport, EntityAction[RoomApply], ProjectSupport {

  var entityDao: EntityDao = _

  var roomApplyService: RoomApplyService = _

  var businessLogger: WebBusinessLogger = _

  var smsService: Option[SmsService] = None

  def index(): View = {
    put("setting", roomApplyService.getSetting(null))
    forward()
  }

  /** 填写申请第一步，查询空闲教室
   *
   * @return
   */
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

    put("time", new ApplyTime)
    val ts = OqlBuilder.from(classOf[TimeSetting], "ts")
    ts.where("ts.endOn is null")
    put("timeSettings", entityDao.search(ts))
    forward()
  }

  /** 填写申请第二步，填写申请信息
   *
   * @return
   */
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
    put("speaker", applicant.name)
    getLong("apply.id") foreach { applyId =>
      val apply = entityDao.get(classOf[RoomApply], applyId)
      put("apply", apply)
      put("speaker", apply.activity.speaker)
      put("activityType", apply.activity.activityType)
    }
    put("hasSmsSupport", smsService.nonEmpty)
    forward()
  }

  /** 修改申请
   *
   * @param id
   * @return
   */
  @mapping(value = "{id}/edit")
  def edit(@param("id") id: Long): View = {
    val apply = entityDao.get(classOf[RoomApply], id)
    put("apply", apply)
    put("time", apply.time.toApplyTime())
    val activityTypes = codeService.get(classOf[ActivityType]).sortBy(_.id)
    put("activityTypes", TreeMap.from(activityTypes.map(x => (x.id, x.name))))
    if (apply.approved.getOrElse(false)) {
      forward("updateForm")
    } else {
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
      forward("searchRooms")
    }
  }

  /** 提交更改
   *
   * @return
   */
  def updateApply(): View = {
    val apply = entityDao.get(classOf[RoomApply], getLongId("apply"))
    apply.activity.activityType = entityDao.get(classOf[ActivityType], getIntId("apply.activity.activityType"))
    apply.activity.speaker = get("apply.activity.speaker", "--")
    apply.activity.name = get("apply.activity.name", "--")
    get("apply.applicant.mobile") foreach { mobile => apply.applicant.mobile = mobile }
    entityDao.saveOrUpdate(apply)
    redirect("search", "更新成功")
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

  /** 申请第三步，提交申请
   *
   * @return
   */
  def saveApply(): View = {
    val time = getApplyTime()
    val apply = populateEntity(classOf[RoomApply], "apply")

    if (null == apply.time) apply.time = new TimeRequest()
    apply.time.times.clear()
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
    businessLogger.info(s"提交教室借用申请(${apply.activity.name})", apply.id, ActionContext.current.params)
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
    query.where("room.roomNo is not null")
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
    val query = OqlBuilder.from(classOf[RoomApply], "roomApply")
    populateConditions(query, "roomApply.roomName")
    QueryHelper.sort(query)
    query.tailOrder("roomApply.id")
    query.limit(getPageLimit)

    query.where("roomApply.applyBy=:me", getUser)
    get("roomApply.roomName") foreach { n =>
      if (Strings.isNotBlank(n)) {
        query.where("exists(from roomApply.rooms r where r.name like :name)", s"%$n%")
      }
    }
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
        businessLogger.info(s"删除了教室借用申请(${apply.activity.name})", apply.id, ActionContext.current.params)
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
