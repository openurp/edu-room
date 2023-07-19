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
import org.openurp.edu.room.model.{Occupancy, RoomApply, RoomOccupyApp}
import org.openurp.edu.room.util.OccupancyUtils

import java.time.Instant
import scala.collection.mutable

trait RoomApplyService {
  def approve(roomApply: RoomApply, approveBy: User, rooms: Seq[Classroom]): Boolean
}
