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

package org.openurp.edu.room.util

import org.beangle.commons.lang.time.WeekTime
import org.beangle.data.dao.{Condition, OqlBuilder}
import org.openurp.base.edu.model.Classroom
import org.openurp.edu.room.model.Occupancy

import java.time.LocalDate
import scala.collection.mutable

object OccupancyUtils {

  def buildFreeroomQuery(units: collection.Seq[WeekTime]): OqlBuilder[Classroom] = {
    val hql = new StringBuilder(s" from ${classOf[Occupancy].getName} o where o.room = room and (")
    val params = new mutable.ArrayBuffer[Any]
    units.indices.foreach(i => {
      val ocuupy = s"bitand(o.time.weekstate,:weekstate${i})>0 " +
        s" and o.time.startOn = :startOn${i}" +
        s" and o.time.beginAt < :endAt${i}" +
        s" and o.time.endAt > :beginAt${i}"
      params.addOne(units(i).weekstate)
      params.addOne(units(i).startOn)
      params.addOne(units(i).endAt)
      params.addOne(units(i).beginAt)

      if (i > 0) hql.append(" or ")
      hql.append(ocuupy)
    })
    hql.append(")")
    val query = OqlBuilder.from(classOf[Classroom], "room")
    query.where("room.beginOn <= :now and (room.endOn is null or room.endOn >= :now)", LocalDate.now(), LocalDate.now())
    query.where(new Condition("not exists (" + hql.toString + ")", params.toSeq: _*))
    query
  }

}
