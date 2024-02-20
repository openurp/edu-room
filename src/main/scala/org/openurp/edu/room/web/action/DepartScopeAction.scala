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
import org.beangle.web.action.view.View
import org.beangle.webmvc.support.action.RestfulAction
import org.openurp.base.resource.model.Classroom
import org.openurp.edu.room.config.RoomApplyDepartScope
import org.openurp.starter.web.support.ProjectSupport

/** 院系代理借用设置
 */
class DepartScopeAction extends RestfulAction[RoomApplyDepartScope], ProjectSupport {

  override def editSetting(scope: RoomApplyDepartScope): Unit = {
    val project = getProject
    val q = OqlBuilder.from(classOf[Classroom], "r")
    q.where("r.roomNo is not null")
    q.where("r.school=:school", project.school)
    val available = entityDao.search(q).toBuffer
    available --= scope.rooms
    put("classrooms", available)

    put("departments", project.departments)
    super.editSetting(scope)
  }

  override protected def simpleEntityName: String = "scope"

  override protected def saveAndRedirect(scope: RoomApplyDepartScope): View = {
    val roomIds = getAll("roomId2nd", classOf[Long])
    val newRooms = entityDao.find(classOf[Classroom], roomIds)
    val removed = scope.rooms filter { x => !newRooms.contains(x) }
    scope.rooms.subtractAll(removed)
    newRooms foreach { l =>
      if (!scope.rooms.contains(l)) scope.rooms += l
    }
    super.saveAndRedirect(scope)
  }
}
