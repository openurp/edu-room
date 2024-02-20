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
import org.beangle.data.dao.OqlBuilder
import org.beangle.data.transfer.exporter.ExportContext
import org.beangle.security.Securities
import org.beangle.template.freemarker.ProfileTemplateLoader
import org.beangle.web.action.annotation.{mapping, param}
import org.beangle.web.action.view.View
import org.beangle.webmvc.support.action.ExportSupport
import org.openurp.base.resource.model.Classroom
import org.openurp.base.model.{Project, User}
import org.openurp.code.edu.model.ClassroomType
import org.openurp.edu.room.log.RoomApplyAuditLog
import org.openurp.edu.room.model.RoomApply
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
    ProfileTemplateLoader.setProfile(apply.school.id)
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
  def applySetting(): View = {
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
          return redirect("applySetting", "roomApply.id=" + roomApply.id, "该教室已被占用,请重新查找空闲教室")
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

  protected override def configExport(context: ExportContext): Unit = {
    super.configExport(context)
    context.extractor = new RoomApplyPropertyExtractor()
  }
}
