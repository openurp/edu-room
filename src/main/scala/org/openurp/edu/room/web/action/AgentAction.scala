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

import org.beangle.data.dao.OqlBuilder
import org.beangle.webmvc.view.View
import org.openurp.base.edu.model.TimeSetting
import org.openurp.base.model.Project
import org.openurp.base.resource.model.Building
import org.openurp.code.asset.model.ClassroomType
import org.openurp.starter.web.support.ProjectSupport

import java.time.{Instant, LocalDate}

/** 主管部门代理借用
 */
class AgentAction extends DepartAgentAction, ProjectSupport {

  override def index(): View = {
    put("setting", roomApplyService.getSetting(null))
    forward()
  }

  override def searchRooms(): View = {
    val q = OqlBuilder.from(classOf[Building], "b")
    q.where("b.endOn is null")
    put("buildings", entityDao.search(q))
    put("roomTypes", codeService.get(classOf[ClassroomType]))
    put("beginOn", LocalDate.now())

    val ts = OqlBuilder.from(classOf[TimeSetting], "ts")
    ts.where("ts.endOn is null")
    put("timeSettings", entityDao.search(ts))
    forward()
  }

  override def freeRooms(): View = {
    val query = buildFreeRoomQuery()
    put("classrooms", entityDao.search(query))
    forward()
  }
}
