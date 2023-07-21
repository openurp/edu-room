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
import org.beangle.commons.lang.time.WeekTime
import org.beangle.data.dao.{Conditions, OqlBuilder}
import org.beangle.web.action.annotation.{mapping, param}
import org.beangle.web.action.view.View
import org.beangle.webmvc.support.action.RestfulAction
import org.beangle.webmvc.support.helper.QueryHelper
import org.openurp.base.edu.model.Classroom
import org.openurp.base.model.{Campus, Project}
import org.openurp.code.edu.model.{ActivityType, ClassroomType}
import org.openurp.edu.room.model.RoomApply
import org.openurp.starter.web.support.ProjectSupport

class DepartApproveAction extends RestfulAction[RoomApply] with ProjectSupport {

  override def indexSetting(): Unit = {
    given project: Project = getProject

    put("campuses", findInSchool(classOf[Campus]))
    put("activityTypes", getCodes(classOf[ActivityType]))
    put("roomTypes", getCodes(classOf[ClassroomType]))
    put("project", project)
    put("semester", getSemester)
    super.indexSetting()
  }

  override def getQueryBuilder: OqlBuilder[RoomApply] = {
    val builder = OqlBuilder.from(classOf[RoomApply], "roomApply")
    populateConditions(builder)
    builder.where("roomApply.school = :school", getProject.school)
    val roomConditions = QueryHelper.extractConditions(classOf[Classroom], "room", null)
    if (roomConditions.nonEmpty) {
      builder.where(s"exists(from roomApply.rooms as room where ${Conditions.toQueryString(roomConditions)})", roomConditions.flatMap(_.params))
    }
    getDate("occupyOn") foreach { occupyOn =>
      val wt = WeekTime.of(occupyOn)
      builder.where("exists(from roomApply.time.times t where t.startOn=:starton and bitand(t.weekstate,:weekstate)>0)",
        wt.startOn, wt.weekstate)
    }
    get("lookContent").foreach {
      case "1" =>
        builder.where("roomApply.departApproved = true")
        builder.where("roomApply.approved is null")
      case "2" =>
        builder.where("roomApply.departApproved = true")
        builder.where("roomApply.approved = true")
      case "3" =>
        builder.where("roomApply.departApproved = true")
        builder.where("roomApply.approved = false")
      case "" =>
    }
    get("approved").foreach {
      case "null" =>
        builder.where("roomApply.approved is null")
      case "0" =>
        builder.where("roomApply.approved = false")
      case "1" =>
        builder.where("roomApply.approved = true")
      case "" =>
    }
    get(Order.OrderStr) foreach { orderClause =>
      builder.orderBy(orderClause)
    }
    builder.tailOrder("roomApply.id")
    builder.limit(getPageLimit)
  }

  def preview(): View = {
    put(simpleEntityName, entityDao.get(classOf[RoomApply], getLongId("roomApply")))
    forward()
  }
}
