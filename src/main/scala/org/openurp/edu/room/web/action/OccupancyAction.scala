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

import org.beangle.commons.collection.Collections
import org.beangle.commons.lang.Numbers
import org.beangle.data.dao.{Condition, EntityDao, OqlBuilder}
import org.beangle.web.action.annotation.mapping
import org.beangle.web.action.support.ActionSupport
import org.beangle.web.action.view.{Status, View}
import org.beangle.webmvc.support.action.EntityAction
import org.openurp.base.edu.model.Classroom
import org.openurp.base.model.Building
import org.openurp.code.edu.model.ActivityType
import org.openurp.code.service.CodeService
import org.openurp.edu.clazz.domain.WeekTimeBuilder
import org.openurp.edu.room.model.Occupancy

import java.time.LocalDate

/** 浏览占用内容
 */
class OccupancyAction extends ActionSupport with EntityAction[Classroom] {

  var entityDao: EntityDao = _
  var codeService: CodeService = _

  def index(): View = {
    val builder = OqlBuilder.from[Array[Any]](classOf[Classroom].getName, "c")
    //    builder.where("c.school=:school", project.school)
    builder.groupBy("c.campus.code,c.campus.name,c.building.id,c.building.code,c.building.name")
    builder.select("c.campus.name,c.building.id,c.building.name,count(*)")
    builder.where("c.endOn is null or c.endOn>:now", LocalDate.now)
    builder.orderBy("c.campus.code,c.building.code")
    val buildings = entityDao.search(builder)
    val buildingId = getInt("buildingId") match {
      case Some(bid) => bid
      case None => if (buildings.isEmpty) 0 else buildings.head(1).asInstanceOf[Int]
    }
    put("classrooms", classrooms(buildingId))
    put("buildings", buildings)
    forward()
  }

  private def classrooms(buildingId: Int): Seq[Classroom] = {
    val builder = OqlBuilder.from(classOf[Classroom], "c")
    if (buildingId > 0) {
      put("building", entityDao.get(classOf[Building], buildingId))
      builder.where("c.building.id=:building_id", buildingId)
    } else {
      builder.where("c.building is null")
    }
    //    val project = getProject
    //    builder.where("c.school=:school", project.school)
    //    builder.where(":project in elements(c.projects)", project)
    builder.orderBy("c.code")
    builder.where("c.endOn is null or c.endOn>:now", LocalDate.now)
    entityDao.search(builder)
  }

  @mapping("building/{id}")
  def building(id: String): View = {
    if (!Numbers.isDigits(id)) return Status.NotFound
    val buildId = id.toInt
    if (buildId > 0) {
      put("building", entityDao.get(classOf[Building], buildId))
    }
    val rooms = classrooms(id.toInt)
    put("classrooms", rooms)
    val roomId = getInt("classroomId") match {
      case Some(roomId) => roomId
      case None => if (rooms.isEmpty) 0 else rooms.head.id
    }
    put("beginOn", getDate("beginOn").getOrElse(LocalDate.now))
    put("roomId", roomId)
    forward()
  }

  @mapping("classroom/{id}")
  def classroom(id: String): View = {
    if (!Numbers.isDigits(id)) return Status.NotFound

    put("activityTypes", codeService.get(classOf[ActivityType]))
    put("room", entityDao.get(classOf[Classroom], id.toLong))
    put("beginOn", getDate("beginOn").getOrElse(LocalDate.now))
    forward("calendar")
  }

  def stat(): View = {
    val startOn = getDate("beginOn").head
    val endOn = getDate("endOn").head
    val query = OqlBuilder.from(classOf[Occupancy], "occupancy")
    getLong("roomId").foreach(roomId => {
      query.where("occupancy.room.id = :roomId", roomId)
    })
    val times = WeekTimeBuilder.build(startOn, endOn, 1)
    if (times.nonEmpty) {
      val sb = Collections.newBuffer[String]
      val params = Collections.newBuffer[Any]
      times.indices.foreach(i => {
        sb += "(occupancy.time.startOn = :startOn" + i + " and bitand(occupancy.time.weekstate,:weekstate" + i + ")>0)"
        params += times(i).startOn
        params += times(i).weekstate
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
