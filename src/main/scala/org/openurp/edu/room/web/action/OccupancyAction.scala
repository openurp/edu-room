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

import org.beangle.commons.collection.Collections
import org.beangle.data.dao.{Condition, OqlBuilder}
import org.beangle.webmvc.api.action.ActionSupport
import org.beangle.webmvc.api.annotation.mapping
import org.beangle.webmvc.api.view.View
import org.beangle.webmvc.entity.action.EntityAction
import org.openurp.base.edu.model.Classroom
import org.openurp.base.model.Building
import org.openurp.code.edu.model.ActivityType
import org.openurp.edu.room.model.{Occupancy, WeekTimeBuilder}
import org.openurp.starter.edu.helper.ProjectSupport

import java.time.LocalDate

class OccupancyAction extends ActionSupport with EntityAction[Classroom] with ProjectSupport {

  def index(): View = {
    val project = getProject
    val builder = OqlBuilder.from(classOf[Classroom].getName, "c")
    builder.where("c.school=:school", project.school)
    builder.groupBy("c.campus.code,c.campus.name,c.building.id,c.building.code,c.building.name")
    builder.select("c.campus.name,c.building.id,c.building.name,count(*)")
    builder.where("c.endOn is null or c.endOn>:now", LocalDate.now)
    builder.orderBy("c.campus.code,c.building.code")
    val buildings = entityDao.search(builder)
    put("buildings", buildings)
    forward()
  }

  @mapping("{id}")
  def building(id: String): View = {
    val builder = OqlBuilder.from(classOf[Classroom], "c")
    val buildingId = id.toInt
    if (buildingId > 0) {
      put("building", entityDao.get(classOf[Building], buildingId))
      builder.where("c.building.id=:building_id", buildingId)
    } else {
      builder.where("c.building is null")
    }
    val project = getProject
    builder.where("c.school=:school", project.school)
    builder.where(":project in elements(c.projects)", project)
    builder.orderBy("c.code")
    builder.where("c.endOn is null or c.endOn>:now", LocalDate.now)
    put("classrooms", entityDao.search(builder))
    forward()
  }

  def calendar(): View = {
    put("activityTypes", getCodes(classOf[ActivityType]))
    put("room", entityDao.get(classOf[Classroom], longId("classroom")))
    forward()
  }

  def stat(): View = {
    val startOn = getDate("beginOn").head
    val endOn = getDate("endOn").head
    val query = OqlBuilder.from(classOf[Occupancy], "occupancy")
    getLong("roomId").foreach(roomId => {
      query.where("occupancy.room.id = :roomId", roomId)
    })
    val times = WeekTimeBuilder.build(startOn, endOn)
    if (times.size > 0) {
      val sb = Collections.newBuffer[String]
      val params = Collections.newBuffer[Any]
      times.indices.foreach(i => {
        sb += "(occupancy.time.startOn = :startOn" + i + " and bitand(occupancy.time.weekstate,:weekstate" + i + ")>0)"
        params += times(i).startOn
        params += times(i).weekstate.value
      })
      val con = new Condition(sb.mkString(" or "))
      con.params(params)
      query.where(con)
    }
    val occupancies = entityDao.search(query)
    put("occupancies", occupancies)
    forward()
  }

}
