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

import org.beangle.web.action.view.View
import org.openurp.base.model.Project
import org.openurp.starter.web.support.ProjectSupport

import java.time.Instant

class DepartAgentAction extends AgentAction, ProjectSupport {

  override def index(): View = {
    given project: Project = getProject

    val scopes = roomApplyService.getScopes(getDeparts)
    val opened = scopes.exists(_.within(Instant.now))
    put("opened", opened)
    forward()
  }

  override def freeRooms(): View = {
    given project: Project = getProject

    val query = buildFreeRoomQuery()
    val scopes = roomApplyService.getScopes(getDeparts)
    val opened = scopes.exists(_.within(Instant.now))
    if (opened) {
      query.where("room.id <0")
    } else {
      val rooms = scopes.flatMap(_.rooms)
      query.where("room in(:rooms)", rooms)
    }
    put("classrooms", entityDao.search(query))
    forward()
  }
}
