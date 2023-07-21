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

package org.openurp.edu.room.web.helper

import org.beangle.commons.lang.time.{HourMinute, WeekTime}
import org.beangle.data.model.LongId
import org.openurp.edu.room.model.CycleTime.CycleTimeType
import org.openurp.edu.room.model.{CycleTime, CycleTimeDigest}

import java.time.LocalDate

class ApplyTime {
  var beginOn: LocalDate = _
  var endOn: LocalDate = _

  var beginAt: HourMinute = _
  var endAt: HourMinute = _
  var cycle: Int = 1

  def toWeektimes(): List[WeekTime] = {
    val builder = CycleTime.ToWeekTimeBuilder(beginAt, endAt)

    if (cycle == 1) {
      builder.addRange(beginOn, endOn, CycleTimeType.Day, 1)
    } else {
      builder.addRange(beginOn, endOn, CycleTimeType.Week, 1)
    }
    builder.build()
  }

  def build(): ApplyTime = {
    if (endOn == null) {
      endOn = beginOn
      cycle = 1
    }
    this
  }

  override def toString: String = {
    CycleTimeDigest.digest(toWeektimes(), "<br>")
  }
}