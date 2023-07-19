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
import org.beangle.commons.lang.time.HourMinute
import org.beangle.data.dao.{EntityDao, OqlBuilder}
import org.beangle.security.Securities
import org.beangle.web.action.support.ActionSupport
import org.beangle.web.action.view.View
import org.beangle.webmvc.support.action.EntityAction
import org.openurp.base.edu.model.{Classroom, CourseUnit, TimeSetting}
import org.openurp.base.model.Building
import org.openurp.edu.room.model.{RoomApply, WeekTimeBuilder}
import org.openurp.edu.room.util.OccupancyUtils

import java.time.{LocalDate, LocalTime}
import scala.sys.error

class FreeAction extends ActionSupport, EntityAction[Classroom] {

  var entityDao: EntityDao = _

  def index(): View = {
    put("today", LocalDate.now)

    val now = HourMinute.of(LocalTime.now)
    val query = OqlBuilder.from(classOf[TimeSetting], "ts")
    query.where("ts.endOn is null")
    val setting = entityDao.search(query).head
    val units = setting.units.sortBy(_.beginAt)
    units.find(_.beginAt > now) match
      case None => put("unit", setting.units.head)
      case Some(u) => put("unit", u)
    put("units", units)
    put("buildings", entityDao.getAll(classOf[Building]))
    forward()
  }

  def freeRooms(): View = {
    val date = getDate("date")
    var beginAt: HourMinute = null
    var endAt: HourMinute = null
    getInt("unitId") match
      case None =>
        beginAt = HourMinute(get("beginAt").get)
        endAt = HourMinute(get("endAt").get)
      case Some(uId) =>
        val u = entityDao.get(classOf[CourseUnit], uId)
        beginAt = u.beginAt
        endAt = u.endAt

    val weektime = WeekTimeBuilder.build(date.get, date.get, 1).head
    weektime.beginAt = beginAt
    weektime.endAt = endAt
    val query = OccupancyUtils.buildFreeroomQuery(List(weektime))
    query.where("room.roomNo is not null")
    populateConditions(query, "room.capacity")
    getInt("room.capacity") foreach { capacity =>
      query.where("room.capacity>=:capacity", capacity)
    }
    get(Order.OrderStr) match {
      case Some(orderClause) => query.orderBy(orderClause)
      case None => query.orderBy("room.name,room.capacity")
    }
    put("logined",Securities.session.nonEmpty)
    put("classrooms", entityDao.search(query))
    forward()
  }

}
