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
package org.openurp.edu.room.model

import java.time.LocalDate
import org.beangle.commons.collection.Collections
import org.beangle.commons.lang.time.WeekDay.WeekDay
import org.beangle.commons.lang.time.{HourMinute, WeekDay, WeekState, WeekTime}
import org.openurp.base.edu.model.Semester

import java.time.temporal.ChronoUnit

object WeekTimeBuilder {
	/**
	 * 构造某个日期（beginAt, endAt必须是同一天，只是时间不同）的WeekTime
	 *
	 * @param beginAt
	 * @param endAt
	 * @return
	 */
	def of(startOn: LocalDate, beginAt: HourMinute, endAt: HourMinute): WeekTime = {
		val time = WeekTime.of(startOn)
		time.beginAt = beginAt
		time.endAt = endAt
		time
	}

	def build(beginOn: LocalDate, endOn: LocalDate): Seq[WeekTime] = {
		val timeMap = Collections.newMap[LocalDate, WeekTime]
		var newBeginOn = beginOn
		while (!newBeginOn.isAfter(endOn)) {
			val t = WeekTime.of(beginOn)
			val existed = timeMap.get(t.startOn)
			timeMap.get(t.startOn) match {
				case Some(existed) => existed.weekstate = existed.weekstate | t.weekstate
				case None => timeMap.put(t.startOn, t)
			}
			newBeginOn = newBeginOn.plusYears(1)
		}
		val times = timeMap.values.toSeq.sortBy(x => x.startOn)
		times
	}

	def on(semester: Semester): WeekTimeBuilder = {
		new WeekTimeBuilder(semester.beginOn, semester.calendar.firstWeekday)
	}


}

class WeekTimeBuilder {
	private var startOn: LocalDate = _

	private var firstWeekEndOn: LocalDate = _


	def this(startOn: LocalDate, firstDay: WeekDay) {
		this()
		this.startOn = startOn
		var endOn = startOn
		val preDayId = firstDay.id - 1
		val weekendDay = if (preDayId <= 0) WeekDay.Sun else WeekDay.apply(preDayId)
		while (endOn.getDayOfWeek.getValue != weekendDay.id) {
			endOn = endOn.plusDays(1)
		}
		this.firstWeekEndOn = endOn
	}

	def build(weekday: WeekDay, weeks: Seq[Int]): List[WeekTime] = {
		val times = Collections.newMap[Integer, WeekTime]
		var startDate = startOn
		while (startDate.getDayOfWeek.getValue != weekday.id) {
			startDate = startDate.plusDays(1)
		}
		var minWeek = 1
		if (startDate.isAfter(firstWeekEndOn)) {
			minWeek = 2
		}
		weeks.foreach(week => {
			if (week >= minWeek) {
				val oneday = startDate.plusWeeks(week - 1)
				val year = oneday.getYear
				val yearStartOn = WeekTime.getStartOn(year, weekday)
				if (times.get(year).isEmpty) {
					val weektime = new WeekTime
					times.put(year, weektime)
					weektime.startOn = yearStartOn
					weektime.weekstate = new WeekState(0)
				}
				val newWeektime = times.get(year).get
				newWeektime.weekstate = new WeekState(newWeektime.weekstate.value | WeekState.of(ChronoUnit.WEEKS.between(yearStartOn, oneday).toInt + 1).value)
			}
		})
		times.values.toList
	}



		//	/**
		//	 * 这个方法都是在ftl里使用的
		//	 *
		//	 * @param state
		//	 * @return
		//	 */
		//	def digestWeekTime(time: WeekTime, semester: Semester): String = {
		//		if (null == time) {
		//			return ""
		//		}
		//		val beginOn: LocalDate = semester.getBeginOn.toLocalDate
		//		val firstWeekday: Int = beginOn.getDayOfWeek.getValue
		//		var timeBeginOn: LocalDate = time.getStartOn.toLocalDate
		//		while ( {
		//			timeBeginOn.getDayOfWeek.getValue != firstWeekday
		//		}) {
		//			timeBeginOn = timeBeginOn.plusDays(-(1))
		//		}
		//		val weeksDistance: Int = Weeks.between(beginOn, timeBeginOn)
		//		var weekstate: Long = time.getWeekstate.getValue
		//		if (weeksDistance < 0) {
		//			weekstate >>= (0 - weeksDistance)
		//		}
		//		else {
		//			weekstate <<= weeksDistance
		//		}
		//		val weekIndecies: Array[Integer] = new WeekState(weekstate).getWeekList.toArray(new Array[Integer](0))
		//		val digest: String = NumberRangeDigestor.digest(weekIndecies, null)
		//		return digest.replace("[", "").replace("]", "").replace("number.range.odd", "单").replace("number.range.even", "双")
		//	}
		//

		//
		//	def buildOnOldWeekStr(weekday: WeekDay, weekstr: String): List[WeekTime] = {
		//		val weekList: List[Integer] = new ArrayList[Integer]
		//		for (i <- 0 until weekstr.length) {
		//			if (weekstr.charAt(i) == '1') {
		//				weekList.add(i)
		//			}
		//		}
		//		val weeks: Array[Int] = new Array[Int](weekList.size)
		//		for (i <- 0 until weekList.size) {
		//			weeks(i) = weekList.get(i)
		//		}
		//		return build(weekday, weeks)
		//	}
		//
		//	def needNormalize(wt: WeekTime): Boolean = {
		//		val startYear: Int = wt.getStartYear
		//		val lastDay: Date = wt.getLastDay
		//		return startYear != lastDay.getYear + 1900
		//	}
		//
		//	def normalize(wt: WeekTime): WeekTime = {
		//		val startYear: Int = wt.getStartYear
		//		var lastDay: Date = wt.getLastDay
		//		var nextWt: WeekTime = null
		//		while ( {
		//			startYear != lastDay.getYear + 1900
		//		}) {
		//			if (null == nextWt) {
		//				nextWt = new WeekTime
		//				nextWt.setBeginAt(wt.getBeginAt)
		//				nextWt.setEndAt(wt.getEndAt)
		//				nextWt.setStartOn(java.sql.Date.valueOf(WeekTime.getStartOn(lastDay.getYear + 1900, wt.getWeekday)))
		//				nextWt.setWeekstate(WeekState.Zero)
		//			}
		//			wt.dropDay(lastDay)
		//			nextWt.addDay(lastDay)
		//			lastDay = wt.getLastDay
		//		}
		//		return nextWt
		//	}
		//
		//	def getOffset(semester: Semester, weekday: WeekDay): Int = {
		//		var startOn: LocalDate = semester.getBeginOn.toLocalDate
		//		while ( {
		//			startOn.getDayOfWeek.getValue != weekday.getId
		//		}) {
		//			startOn = startOn.plusDays(1)
		//		}
		//		val yearStartOn: LocalDate = WeekTime.getStartOn(startOn.getYear, weekday)
		//		return Weeks.between(yearStartOn, startOn)
		//	}
		//
		//	def getReverseOffset(semester: Semester, weekday: WeekDay): Int = {
		//		var startOn: LocalDate = semester.getBeginOn.toLocalDate
		//		while ( {
		//			startOn.getDayOfWeek.getValue != weekday.getId
		//		}) {
		//			startOn = startOn.plusDays(1)
		//		}
		//		val yearStartOn: LocalDate = WeekTime.getStartOn(startOn.getYear + 1, weekday)
		//		return Math.abs(Weeks.between(yearStartOn, startOn))
		//	}
		//
		//	def build(weekday: WeekDay, weeks: Collection[Integer]): List[WeekTime] = {
		//		val weekIndices: Array[Int] = new Array[Int](weeks.size)
		//		var i: Int = 0
		//		import scala.collection.JavaConversions._
		//		for (w <- weeks) {
		//			weekIndices(i) = w
		//			i += 1
		//		}
		//		return build(weekday, weekIndices)
		//	}
		//

		//
		//	def getYearStartOns(semester: Semester, weekday: WeekDay): List[Date] = {
		//		val year: Int = semester.getStartYear
		//		val dates: List[Date] = CollectUtils.newArrayList
		//		dates.add(java.sql.Date.valueOf(WeekTime.getStartOn(year, weekday)))
		//		dates.add(java.sql.Date.valueOf(WeekTime.getStartOn(year, weekday)))
		//		return dates
		//	}
		//
		//	def getStartOn(semester: Semester, weekday: WeekDay): Date = {
		//		var ld: LocalDate = semester.getBeginOn.toLocalDate
		//		while ( {
		//			ld.getDayOfWeek.getValue != weekday.getId
		//		}) {
		//			ld = ld.plusDays(1)
		//		}
		//		return java.sql.Date.valueOf(ld)
		//	}
		//
		//	def of(startWeek: Int, endWeek: Int, pattern: NumberSequence.Pattern): WeekTime = {
		//		val range: Array[Int] = NumberSequence.build(startWeek, endWeek, pattern)
		//		val courseTime: WeekTime = new WeekTime
		//		courseTime.setWeekstate(WeekState.of(range))
		//		return courseTime
		//	}


		//	def getDateRange(semester: Semester, weekIndex: Int): Pair[Date, Date] = {
		//		val beginOn: Date = WeekTimeBuilder.on(semester).build(semester.getCalendar.getFirstWeekday, Array[Int](weekIndex)).get(0).getFirstDay
		//		var ld: LocalDate = beginOn.toLocalDate
		//		ld = ld.plusDays(6)
		//		return Pair.of(beginOn, java.sql.Date.valueOf(ld))
		//	}
		//
		//	def getDate(semester: Semester, teachWeek: Int, weekday: WeekDay): Date = {
		//		return WeekTimeBuilder.on(semester).build(weekday, Array[Int](teachWeek)).get(0).getFirstDay
		//	}
		//
		//	def weekIndexOf(semester: Semester, oneday: Date): Int = {
		//		val beginOn: LocalDate = semester.getBeginOn.toLocalDate
		//		val firstWeekday: Int = beginOn.getDayOfWeek.getValue
		//		var timeBeginOn: LocalDate = oneday.toLocalDate
		//		while ( {
		//			timeBeginOn.getDayOfWeek.getValue != firstWeekday
		//		}) {
		//			timeBeginOn = timeBeginOn.plusDays(-(1))
		//		}
		//		return Weeks.between(beginOn, timeBeginOn)
		//	}
		//
		//	def getStartYear(semester: Semester): Int = {
		//		if (null != semester.getBeginOn) {
		//			val gc: GregorianCalendar = new GregorianCalendar
		//			gc.setTime(semester.getBeginOn)
		//			return gc.get(Calendar.YEAR)
		//		}
		//		return 0
		//	}
		//
		//	def getWeekDays(semester: Semester): Array[WeekDay] = {
		//		val isSundayFirst: Boolean = semester.getCalendar.getFirstWeekday == WeekDay.Sun
		//		return WeekDay.getWeekdayArray(isSundayFirst)
		//	}

}
