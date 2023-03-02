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

package org.openurp.edu.room.service

import org.beangle.commons.collection.Collections
import org.beangle.webmvc.support.action.RestfulAction
import org.openurp.base.edu.model.Classroom
import org.openurp.base.model.User
import org.openurp.edu.room.model.{RoomApplyFinalCheck, Occupancy, RoomApply, RoomOccupyApp}
import org.openurp.edu.room.util.OccupancyUtils

import java.time.Instant
import scala.collection.mutable

class RoomApplyService extends RestfulAction[RoomApply] {

  var occupancyUtils: OccupancyUtils = _

  /**
   * 批准教室申请(允许批量分配教室)
   *
   */
  def approve(roomApply: RoomApply, approveBy: User, rooms: Seq[Classroom]): Boolean = {
    val exitOccupancies = entityDao.findBy(classOf[Occupancy], "room", rooms)
    entityDao.remove(exitOccupancies)
    roomApply.rooms.clear()
    roomApply.approved = Option(!rooms.isEmpty)
    saveOrUpdate(roomApply)
    val finalCheck = roomApply.finalCheck match {
      case Some(value) => value
      case None => new RoomApplyFinalCheck
    }
    finalCheck.roomApply = roomApply
    finalCheck.approved = true
    finalCheck.checkedAt = Instant.now()
    finalCheck.checkedBy = approveBy
    saveOrUpdate(finalCheck)
    roomApply.finalCheck = Option(finalCheck)
    val units = roomApply.time.times
    val freerooms = entityDao.search(occupancyUtils.buildFreeroomQuery(units))
    val newRooms = Collections.newSet[Classroom]
    units.indices.foreach(i => {
      rooms.foreach(room => {
        if (freerooms.contains(room)) {
          val occupancy = new Occupancy
          newRooms.add(room)
          occupancy.room = room
          occupancy.time = units(i)
          occupancy.activityType = roomApply.activity.activityType
          // 流水号 活动 部门 人 人数
          occupancy.comments = roomApply.id + " " + roomApply.activity.name + " " +
            (roomApply.borrower.department.shortName match {
              case Some(value) => value
              case None => roomApply.borrower.department.name
            }) +
            " " + roomApply.borrower.applicant + " " + roomApply.activity.attendanceNum + "人"
          occupancy.app = entityDao.get(classOf[RoomOccupyApp], 3.toLong)
          occupancy.activityId = roomApply.id
          occupancy.updatedAt = Instant.now()
          saveOrUpdate(occupancy)
        }
        else false
      })
    })
    roomApply.rooms.addAll(rooms)
    try entityDao.saveOrUpdate(roomApply)
    catch {
      case e: Exception =>
        return false
    }
    true
  }
}
