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
import org.beangle.data.dao.OqlBuilder
import org.beangle.doc.transfer.exporter.ExportContext
import org.beangle.security.Securities
import org.beangle.template.api.DynaProfile
import org.beangle.template.freemarker.ProfileTemplateLoader
import org.beangle.webmvc.annotation.{mapping, param}
import org.beangle.webmvc.context.ActionContext
import org.beangle.webmvc.support.action.ExportSupport
import org.beangle.webmvc.view.View
import org.openurp.base.model.{Project, User}
import org.openurp.base.resource.model.Classroom
import org.openurp.code.asset.model.ClassroomType
import org.openurp.code.edu.model.ActivityType
import org.openurp.edu.room.log.RoomApplyAuditLog
import org.openurp.edu.room.model.{ApplyTime, RoomApply}
import org.openurp.edu.room.service.RoomApplyService
import org.openurp.edu.room.util.OccupancyUtils
import org.openurp.edu.room.web.helper.RoomApplyPropertyExtractor

import scala.sys.error

class ApproveAction extends DepartApproveAction, ExportSupport[RoomApply] {

  var roomApplyService: RoomApplyService = _

  def report(): View = {
    val id = getLongId("roomApply")
    val apply = entityDao.get(classOf[RoomApply], id)
    put("roomApply", apply)
    DynaProfile.set(apply.school.id)
    forward("../report")
  }

  override def search(): View = {
    val builder = getQueryBuilder
    //builder.where("roomApply.departApproved = true")
    put("roomApplies", entityDao.search(builder))
    forward()
  }

  @mapping(value = "{id}")
  override def info(@param("id") id: String): View = {
    val apply = entityDao.get(classOf[RoomApply], id.toLong)
    put("roomApply", apply)
    put("roomApplyLogs", entityDao.findBy(classOf[RoomApplyAuditLog], "roomApply", apply))
    forward()
  }

  /**
   * 给申请分配教室
   */
  def auditForm(): View = {
    given project: Project = getProject

    val id = getLongId("roomApply")
    if (0 == id) error("error.parameters.needed")
    val apply = entityDao.get(classOf[RoomApply], id)
    put("roomTypes", getCodes(classOf[ClassroomType]))

    get("roomIds") match
      case Some(roomIdStr) =>
        if (roomIdStr.nonEmpty) {
          val roomIds = Strings.splitToLong(roomIdStr)
          if (null != roomIds && roomIds.nonEmpty) {
            val rooms = entityDao.find(classOf[Classroom], roomIds)
            apply.rooms ++= rooms
          }
        }
      case None =>
        apply.space.roomComment foreach { roomComment =>
          Strings.split(roomComment) foreach { rc =>
            val query = OccupancyUtils.buildFreeroomQuery(apply.time.times)
            query.where("room.campus=:campus", apply.space.campus)
            query.where("room.name=:name", rc)
            apply.rooms ++= entityDao.search(query)
          }
        }
    put("roomApply", apply)
    forward()
  }

  /**
   * 审批教室借用
   */
  def approve(): View = {
    val roomApply = populateEntity(classOf[RoomApply], "roomApply")
    get("roomIds") match {
      case Some(roomIdStr) =>
        val roomIds = Strings.splitToLong(roomIdStr)
        val times = roomApply.time.times
        val builder = OccupancyUtils.buildFreeroomQuery(times)
        builder.where("room.id in (:roomIds)", roomIds)
        val classrooms = entityDao.search(builder)
        if (classrooms.size != roomIds.length) {
          return redirect("auditForm", "roomApply.id=" + roomApply.id, "该教室已被占用,请重新查找空闲教室")
        }
        val rooms = entityDao.find(classOf[Classroom], roomIds)
        if (roomApplyService.approve(roomApply, getUser, rooms)) redirect("search", "info.action.success")
        else redirect("search", "info.action.failure")
      case None =>
        roomApply.rooms.clear()
        roomApply.approved = null
        entityDao.saveOrUpdate(roomApply)
        redirect("search", "info.action.success")
    }
  }

  def getUser: User = {
    val builder = OqlBuilder.from(classOf[User], "user")
    builder.where("user.code=:code", Securities.user)
    entityDao.search(builder).headOption.orNull
  }

  def freeRooms(): View = {
    val roomApplyId = getLongId("roomApply")
    if (0 == roomApplyId) error("error.parameters.needed")
    val apply = entityDao.get(classOf[RoomApply], roomApplyId)
    val query = OccupancyUtils.buildFreeroomQuery(apply.time.times)
    query.where("room.campus=:campus", apply.space.campus)
    populateConditions(query, "room.capacity")
    getInt("room.capacity") match {
      case Some(capacity) => query.where("room.capacity>=:capacity", capacity)
      case None => query.where("room.capacity>=:capacity", apply.space.unitAttendance)
    }
    get(Order.OrderStr) match {
      case Some(orderClause) => if (orderClause.startsWith("room.")) query.orderBy(orderClause)
      case None => query.orderBy("room.name,room.capacity")
    }
    query.limit(getPageLimit)
    put("rooms", entityDao.search(query))
    put("roomApply", apply)
    forward()
  }

  /**
   * 取消已批准的教室
   */
  def cancel(): View = {
    val roomApplies = entityDao.find(classOf[RoomApply], getLongIds("roomApply"))
    if (roomApplies.isEmpty) error("error.parameters.needed")
    roomApplies.foreach { roomApply =>
      roomApplyService.reject(roomApply, getUser, get("approvedOpinions", "--"))
    }
    redirect("search", "info.action.success")
  }

  protected override def removeAndRedirect(applies: Seq[RoomApply]): View = {
    val removed = applies.filter(a => a.rooms.isEmpty)
    if (removed.nonEmpty) {
      removed foreach { r => roomApplyService.remove(r) }
    }
    if removed.size < applies.size then
      redirect("search", s"成功删除${removed.size}个申请(已经审批的，需要取消审批后才能删除)")
    else
      redirect("search", "info.remove.success")
  }

  override def updateApply(): View = {
    val apply = entityDao.get(classOf[RoomApply], getLongId("apply"))

    apply.activity.activityType = entityDao.get(classOf[ActivityType], getIntId("apply.activity.activityType"))
    apply.activity.speaker = get("apply.activity.speaker", "--")
    apply.activity.name = get("apply.activity.name", "--")
    get("apply.applicant.mobile") foreach { mobile => apply.applicant.mobile = mobile }
    entityDao.saveOrUpdate(apply)

    val approveBy = getUser
    val time = new ApplyTime()
    time.beginOn = getDate("time.beginOn").get
    getDate("time.endOn") foreach { d => time.endOn = d }
    time.beginAt = HourMinute(get("time.beginAt", "00:00"))
    time.endAt = HourMinute(get("time.endAt", "00:00"))
    time.cycle = getInt("time.cycle", 1)
    time.build()

    val exist = apply.time.toApplyTime()
    if (exist.beginOn != time.beginOn || exist.endOn != time.endOn || exist.beginAt != time.beginAt || exist.endAt != time.endAt || exist.cycle != time.cycle) {
      apply.time.times.clear()
      apply.time.times.addAll(time.toWeektimes())
      apply.time.beginOn = time.beginOn
      apply.time.endOn = time.endOn
      entityDao.saveOrUpdate(apply)
      businessLogger.info(s"调整了教室借用内容", apply.id, ActionContext.current.params)
      if (apply.approved.getOrElse(false)) { //如果已经成功的申请，需要重新分配教室
        roomApplyService.reject(apply, approveBy, "调整时间")
        redirect("auditForm", "&roomApply.id=" + apply.id, "修改成功，请重新分配教室")
      } else {
        redirect("search", "更新成功")
      }
    } else {
      businessLogger.info(s"调整了教室借用内容", apply.id, ActionContext.current.params)
      redirect("search", "更新成功")
    }
  }

  protected override def configExport(context: ExportContext): Unit = {
    super.configExport(context)
    context.extractor = new RoomApplyPropertyExtractor()
  }
}
