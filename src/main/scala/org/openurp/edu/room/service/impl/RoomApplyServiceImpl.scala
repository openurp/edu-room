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
import org.openurp.base.edu.model.Classroom
import org.openurp.base.model.{Department, School, User}
import org.openurp.edu.room.config.{RoomApplyDepartScope, RoomApplySetting}
import org.openurp.edu.room.log.RoomApplyAuditLog
import org.openurp.edu.room.model.{Occupancy, RoomApply, RoomOccupyApp}
import org.openurp.edu.room.service.RoomApplyService

import java.time.Instant
import scala.collection.mutable

class RoomApplyServiceImpl extends RoomApplyService {

  var entityDao: EntityDao = _

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
    entityDao.saveOrUpdate(apply)
  }

  def reject(roomApply: RoomApply, approveBy: User, reason: String): Unit = {
    val log = new RoomApplyAuditLog
    log.roomApply = roomApply
    log.approved = false
    log.auditAt = Instant.now
    log.opinions = Some(reason)
    log.auditBy = approveBy.code + " " + approveBy.name

    roomApply.approved = Some(false)
    roomApply.rooms.clear()
    entityDao.saveOrUpdate(log, roomApply)
  }

  private def getOccupancies(roomApply: RoomApply): Seq[Occupancy] = {
    if (roomApply.rooms.nonEmpty) {
      val query = OqlBuilder.from(classOf[Occupancy], "occ")
      query.where("occ.room in(:rooms)", roomApply.rooms)
      query.where("occ.activityId=:activityId", roomApply.id)
      query.where("occ.app.id=:appId", RoomOccupyApp.RoomAppId)
      entityDao.search(query)
    } else {
      List.empty
    }
  }

  /** 批准教室申请(允许批量分配教室)
   */
  override def approve(roomApply: RoomApply, approveBy: User, rooms: Seq[Classroom]): Boolean = {
    entityDao.remove(getOccupancies(roomApply))
    roomApply.rooms.clear()
    roomApply.approved = Option(rooms.nonEmpty)
    roomApply.approvedAt = Some(Instant.now)

    val log = new RoomApplyAuditLog
    log.roomApply = roomApply
    log.approved = true
    log.auditAt = Instant.now
    log.auditBy = approveBy.code + " " + approveBy.name

    val occupancies = new mutable.ArrayBuffer[Occupancy]
    roomApply.time.times.foreach(time => {
      rooms.foreach(room => {
        val occupancy = new Occupancy
        occupancy.room = room
        occupancy.time = time
        occupancy.activityType = roomApply.activity.activityType
        occupancy.comments = roomApply.activity.name
        occupancy.app = new RoomOccupyApp(RoomOccupyApp.RoomAppId)
        occupancy.activityId = roomApply.id
        occupancy.updatedAt = Instant.now()
        occupancies.addOne(occupancy)
      })
    })
    roomApply.rooms.addAll(rooms)
    try {
      entityDao.saveOrUpdate(roomApply, log)
      entityDao.saveOrUpdate(occupancies)
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
}
