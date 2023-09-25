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

import org.beangle.commons.collection.Collections
import org.beangle.commons.lang.time.{WeekDay, WeekState, WeekTime}
import org.openurp.base.model.Semester
import org.openurp.edu.clazz.domain.WeekTimeBuilder
import org.openurp.edu.room.model.Occupancy

/**
 * 单个教室再某个时间槽的占用（周几，第几节）
 */
class OccupySlot(weekday: WeekDay, semester: Semester) {

  var weekstate: WeekState = WeekState.Zero
  var occupancies = Collections.newBuffer[Occupancy]

  def add(o: Occupancy): Unit = {
    weekstate |= o.time.weekstate
    occupancies.addOne(o)
  }

  def weeks: String = {
    val wt = new WeekTime
    wt.weekstate = weekstate
    wt.startOn = WeekTime.getStartOn(semester.beginOn.getYear, weekday)
    WeekTimeBuilder.digest(wt, semester)
  }

  def comments: String = {
    occupancies.map(_.comments).toSet.mkString(",")
  }

  def abbreviateComments(maxlength: Int): String = {
    val c = occupancies.map(_.comments).toSet.mkString(",")
    if c.length < maxlength then c else (c.substring(0, maxlength) + "...")
  }
}

