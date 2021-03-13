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
package org.beangle.commons.lang.time



object WeekTimes {
	/**
	 * 判断两个时间是否可以合并<br>
	 * 判断标准为 （weekState、weekday相等） 且 （上课节次相连 或 上课节次相交）
	 * 或者节次相等则可以合并周次
	 *
	 * @param other
	 * @return
	 */
	def canMergerWith(me: WeekTime, other: WeekTime): Boolean = {
		if (me.startOn.equals(other.startOn)) {
			if (me.weekstate.equals(other.weekstate)) {
				if (me.beginAt.interval(other.endAt) < 20 || (other.beginAt.interval(me.endAt) < 20)) {
					true
				} else {
					(me.beginAt.value <= other.endAt.value) && (other.beginAt.value <= me.endAt.value)
				}
			} else {
				me.beginAt.equals(other.beginAt) && me.endAt.equals(other.endAt)
			}
		} else {
			false
		}
	}

	/** 77777
	 * 将两上课时间进行合并，前提是这两上课时间可以合并
	 *
	 * @see #canMergerWith(WeekTime)
	 * @param other
	 */
	def mergeWith(me: WeekTime, other: WeekTime): Unit = {
		if (me.weekstate.equals(other.weekstate)) {
			if (other.beginAt.value < me.beginAt.value) {
				me.beginAt = other.beginAt
			}

			if (other.endAt.value > me.endAt.value) {
				me.endAt = other.endAt
			}
		} else {
			me.weekstate = new WeekState(me.weekstate.value | other.weekstate.value)
		}
	}

	//
	//	/**
	//	 * 合并相邻或者重叠的时间段<br>
	//	 * 前提条件是待合并的
	//	 *
	//	 * @param tobeMerged
	//	 * @return
	//	 */
	//	def mergeTimes(tobeMerged: util.List[WeekTime]): util.List[WeekTime] = {
	//		if (tobeMerged.isEmpty) return tobeMerged
	//		Collections.sort(tobeMerged)
	//		val mergedTimeUnits = CollectUtils.newArrayList
	//		val activityIter = tobeMerged.iterator
	//		var toMerged = activityIter.next.asInstanceOf[WeekTime]
	//		mergedTimeUnits.add(toMerged)
	//		while ( {
	//			activityIter.hasNext
	//		}) {
	//			val unit = activityIter.next.asInstanceOf[WeekTime]
	//			if (canMergerWith(toMerged, unit)) mergeWith(toMerged, unit)
	//			else {
	//				toMerged = unit
	//				mergedTimeUnits.add(toMerged)
	//			}
	//		}
	//		mergedTimeUnits
	//	}
}
