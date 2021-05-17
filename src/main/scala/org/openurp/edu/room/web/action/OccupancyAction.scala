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
import org.beangle.webmvc.api.view.View
import org.beangle.webmvc.entity.action.RestfulAction
import org.openurp.base.edu.model.Classroom
import org.openurp.code.edu.model.ActivityType
import org.openurp.edu.room.model.{Occupancy, WeekTimeBuilder}
import org.openurp.starter.edu.helper.ProjectSupport

import java.time.LocalDate

class OccupancyAction extends RestfulAction[Classroom] with ProjectSupport {

  def calendar(): View = {
    put("now",LocalDate.of(2020,5,10))
    put("activityTypes", getCodes(classOf[ActivityType]))
    put("room", entityDao.get(classOf[Classroom], longId("classroom")))
    forward()
  }

  def calendar_m(): View = {
    put("now", LocalDate.now())
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
    val occupancies= entityDao.search(query)
    put("occupancies", occupancies)
    forward()
  }

  def stat_m: View = {
    stat()
  }
}
