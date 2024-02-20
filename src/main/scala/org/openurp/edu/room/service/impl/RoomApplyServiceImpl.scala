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

package org.openurp.edu.room.service.impl

import org.beangle.data.dao.Query.Lang.OQL
import org.beangle.data.dao.{EntityDao, OqlBuilder}
import org.beangle.ems.app.Ems
import org.beangle.ems.app.web.WebBusinessLogger
import org.openurp.base.resource.model.Classroom
import org.openurp.base.model.{Department, School, User}
import org.openurp.base.service.UserCategories
import org.openurp.edu.room.config.{RoomApplyDepartScope, RoomApplyReservedTime, RoomApplySetting}
import org.openurp.edu.room.log.RoomApplyAuditLog
import org.openurp.edu.room.model.{Occupancy, RoomApply, RoomOccupyApp}
import org.openurp.edu.room.service.{RoomApplyService, SmsService}

import java.time.Instant
import scala.collection.mutable

class RoomApplyServiceImpl extends RoomApplyService {

  var entityDao: EntityDao = _

  var smsService: Option[SmsService] = None

  def getSetting(school: School): Option[RoomApplySetting] = {
    val query = OqlBuilder.from(classOf[RoomApplySetting], "setting")
    if (null != school) query.where("setting.school=:school", school)
    query.cacheable()
    entityDao.search(query).headOption
  }

  def submit(apply: RoomApply, applyBy: User): Unit = {
    apply.school = applyBy.school
    apply.applyBy = applyBy
    apply.applyAt = Instant.now
    apply.departApproved = None
    apply.approved = None
    entityDao.saveOrUpdate(apply)
  }

  def reject(apply: RoomApply, approveBy: User, reason: String): Unit = {
    val log = new RoomApplyAuditLog
    log.roomApply = apply
    log.approved = false
    log.auditAt = Instant.now
    log.opinions = Some(reason)
    log.auditBy = approveBy.code + " " + approveBy.name

    apply.approved = Some(false)
    apply.approvedAt = None
    entityDao.remove(getOccupancies(apply))
    apply.rooms.clear()
    entityDao.saveOrUpdate(log, apply)
    smsService foreach { sms =>
      val applicant = apply.applicant.user
      val roomNames = apply.rooms.map(_.name).mkString(",")
      val suffix = if (applicant.category.id == UserCategories.Student) "同学" else "老师"
      val template = s"${applicant.name}${suffix}您好，你的教室申请(${apply.activity.name})已被撤销。原因：${reason}"
      sms.send(template, apply.applicant.mobile -> applicant.name)
    }
  }

  private def getOccupancies(roomApply: RoomApply): Seq[Occupancy] = {
    val query = OqlBuilder.from(classOf[Occupancy], "occ")
    query.where("occ.activityId=:activityId", roomApply.id)
    query.where("occ.app.id=:appId", RoomOccupyApp.RoomAppId)
    entityDao.search(query)
  }

  /** 批准教室申请(允许批量分配教室)
   */
  override def approve(apply: RoomApply, approveBy: User, rooms: Seq[Classroom]): Boolean = {
    entityDao.remove(getOccupancies(apply))
    apply.rooms.clear()
    apply.approved = Option(rooms.nonEmpty)
    apply.approvedAt = Some(Instant.now)

    val log = new RoomApplyAuditLog
    log.roomApply = apply
    log.approved = true
    log.auditAt = Instant.now
    log.auditBy = approveBy.code + " " + approveBy.name

    val occupancies = new mutable.ArrayBuffer[Occupancy]
    apply.time.times.foreach(time => {
      rooms.foreach(room => {
        val occupancy = new Occupancy
        occupancy.room = room
        occupancy.time = time
        occupancy.activityType = apply.activity.activityType
        occupancy.comments = apply.activity.name
        occupancy.app = new RoomOccupyApp(RoomOccupyApp.RoomAppId)
        occupancy.activityId = apply.id
        occupancy.updatedAt = Instant.now()
        occupancies.addOne(occupancy)
      })
    })
    apply.rooms.addAll(rooms)
    try {
      entityDao.saveOrUpdate(apply, log)
      entityDao.saveOrUpdate(occupancies)
      smsService foreach { sms =>
        val applicant = apply.applicant.user
        val roomNames = apply.rooms.map(_.name).mkString(",")
        val suffix = if (applicant.category.id == UserCategories.Student) "同学" else "老师"
        val template = s"${applicant.name}${suffix}您好，你的教室申请(${apply.activity.name})已经审批通过。借用时间为${apply.time},教室为${roomNames}。教室凭证查看：${Ems.base}/edu/room/apply-info/${apply.id}"
        sms.send(template, apply.applicant.mobile -> applicant.name)
      }
    } catch {
      case e: Exception => return false
    }
    true
  }

  override def remove(roomApply: RoomApply): Unit = {
    entityDao.remove(getOccupancies(roomApply))
    entityDao.remove(entityDao.findBy(classOf[RoomApplyAuditLog], "roomApply", roomApply))
    entityDao.remove(roomApply)
  }

  override def getScopes(departs: Iterable[Department]): Seq[RoomApplyDepartScope] = {
    if departs.isEmpty then List.empty
    else
      val query = OqlBuilder.from(classOf[RoomApplyDepartScope], "s")
      query.where("s.depart in(:departs)", departs)
      entityDao.search(query)
  }


  override def getReservedTimes(school: School): Seq[RoomApplyReservedTime] = {
    val query = OqlBuilder.from(classOf[RoomApplyReservedTime], "s")
    query.where("s.school = :school", school)
    entityDao.search(query)
  }

}
