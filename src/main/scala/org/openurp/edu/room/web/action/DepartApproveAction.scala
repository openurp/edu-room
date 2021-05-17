/*
 * OpenURP, Agile University Resource Planning Solution.
 *
 * Copyright © 2014, The OpenURP Software.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful.
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package org.openurp.edu.room.web.action

import org.beangle.commons.collection.Order
import org.beangle.commons.lang.Strings
import org.beangle.data.dao.OqlBuilder
import org.beangle.webmvc.api.annotation.{mapping, param}
import org.beangle.webmvc.api.view.View
import org.beangle.webmvc.entity.action.RestfulAction
import org.openurp.base.edu.model.Classroom
import org.openurp.base.model.Campus
import org.openurp.code.edu.model.{ActivityType, ClassroomType}
import org.openurp.edu.room.model.RoomApply
import org.openurp.starter.edu.helper.ProjectSupport

class DepartApproveAction extends RestfulAction[RoomApply] with ProjectSupport {

  override def indexSetting(): Unit = {
    put("campuses", findInSchool(classOf[Campus]))
    put("activityTypes", getCodes(classOf[ActivityType]))
    put("roomTypes", getCodes(classOf[ClassroomType]))
    put("project",getProject)
    put("semester",getCurrentSemester)
    super.indexSetting()
  }

  override def getQueryBuilder: OqlBuilder[RoomApply] = {
    val builder = OqlBuilder.from(classOf[RoomApply], "roomApply")
    populateConditions(builder)
    builder.where("roomApply.school = :school", getProject.school)
    val room = populateEntity(classOf[Classroom], "room")
    if (Strings.isNotEmpty(room.name) && null != room.roomType) {
      builder.where("exists(from roomApply.rooms m where room.name like :roomName and room.roomType =:roomType)", "%" + room.name + "%", room.roomType)
    }
    else if (Strings.isNotEmpty(room.name)) {
      builder.where("exists(from roomApply.rooms room where room.name like :roomName)", "%" + room.name + "%")
    }
    else if (null != room.roomType) {
      builder.where("exists(from roomApply.rooms room where room.roomType =:roomType)", room.roomType)
    }
    get("lookContent").foreach(lookContent => lookContent match {
      case "1" => {
        builder.where("roomApply.departCheck.approved = true")
        builder.where("roomApply.approved is null")
      }
      case "2" => {
        builder.where("roomApply.departCheck.approved = true")
        builder.where("roomApply.approved = true")
      }
      case "3" => {
        builder.where("roomApply.departCheck.approved = true")
        builder.where("roomApply.approved = false")
      }
      case "" =>
    })
    get(Order.OrderStr) foreach { orderClause =>
      builder.orderBy(orderClause)
    }
    builder.tailOrder("roomApply.id")
    builder.limit(getPageLimit)
  }

  def preview(): View = {
    put(simpleEntityName, entityDao.get(classOf[RoomApply],longId("roomApply")))
    forward()
  }
}
