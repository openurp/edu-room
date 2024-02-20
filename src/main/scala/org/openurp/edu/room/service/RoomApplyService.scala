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

import org.openurp.base.resource.model.Classroom
import org.openurp.base.model.{Department, School, User}
import org.openurp.edu.room.config.{RoomApplyDepartScope, RoomApplyReservedTime, RoomApplySetting}
import org.openurp.edu.room.model.RoomApply

trait RoomApplyService {
  def submit(roomApply: RoomApply, applyBy: User): Unit

  def reject(roomApply: RoomApply, approveBy: User, reason: String): Unit

  def approve(roomApply: RoomApply, approveBy: User, rooms: Seq[Classroom]): Boolean

  def remove(roomApply: RoomApply): Unit

  def getSetting(school: School): Option[RoomApplySetting]

  def getScopes(departs: Iterable[Department]): Seq[RoomApplyDepartScope]

  def getReservedTimes(school: School): Seq[RoomApplyReservedTime]
}
