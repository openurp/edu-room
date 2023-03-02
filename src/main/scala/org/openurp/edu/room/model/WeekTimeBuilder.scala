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

package org.openurp.edu.room.model

import org.beangle.commons.collection.Collections
import org.beangle.commons.lang.time.WeekTime
import org.openurp.base.model.Semester

import java.time.LocalDate
import scala.collection.mutable

object WeekTimeBuilder {

  def build(beginOn: LocalDate, endOn: LocalDate): Seq[WeekTime] = {
    val timeMap = Collections.newMap[LocalDate, WeekTime]
    var newBeginOn = beginOn
    while (!newBeginOn.isAfter(endOn)) {
      val t = WeekTime.of(newBeginOn)
      timeMap.get(t.startOn) match {
        case Some(existed) => existed.weekstate = existed.weekstate | t.weekstate
        case None => timeMap.put(t.startOn, t)
      }
      newBeginOn = newBeginOn.plusDays(1)
    }
    val times = timeMap.values.toSeq.sortBy(x => x.startOn)
    times
  }

  def on(semester: Semester): WeekTime.Builder = {
    WeekTime.newBuilder(semester.beginOn, semester.calendar.firstWeekday)
  }

  /**
   * 合并相邻或者重叠的时间段<br>
   * 前提条件是待合并的
   *
   * @param tobeMerged
   * @return
   */
  def mergeTimes(tobeMerged: mutable.Buffer[WeekTime], minGap: Int): mutable.Buffer[WeekTime] = {
    if (tobeMerged.isEmpty) return tobeMerged
    val mergedTimeUnits = Collections.newBuffer[WeekTime]
    val activityIter = tobeMerged.iterator
    var toMerged = activityIter.next()
    mergedTimeUnits.+=(toMerged)
    while (activityIter.hasNext) {
      val unit = activityIter.next()
      if (toMerged.mergeable(unit, minGap)) toMerged.merge(unit, minGap)
      else {
        toMerged = unit
        mergedTimeUnits += toMerged
      }
    }
    mergedTimeUnits
  }
}
