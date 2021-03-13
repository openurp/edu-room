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
import java.util.{Calendar, Date}

import org.beangle.commons.lang.time.{HourMinute, WeekTime}
import org.openurp.edu.room.util.TimeUnitBuilder

object CycleDate {
	/** 天 */
	val DAY = 1
	/** 周 */
	val WEEK = 2
	/** 月 */
	val MONTH = 4
}

class CycleDate extends Cloneable with Serializable {
	/** 开始日期 */
	var beginOn: LocalDate = _
	/** 结束日期 */
	var endOn: LocalDate = _
	/** 开始时间 */
	var beginAt: HourMinute = _
	/** 结束时间 */
	var endAt: HourMinute = _
	/** 单位 */
	var cycleType: Int = _
	/** 单位数量 */
	var cycleCount: Int = _


	def isOneDay: Boolean = {
		this.beginOn == this.endOn
	}

	def getCycleDays: Int = {
		cycleType match {
			case CycleDate.DAY => cycleCount
			case CycleDate.MONTH => cycleCount * 30
			case CycleDate.WEEK => cycleCount * 7
		}
		throw new RuntimeException("xxx")
	}

	def convert: Array[WeekTime] = {
		val builder = new TimeUnitBuilder(beginAt, endAt)
		builder.addRange(beginOn, endOn, cycleType, cycleCount)
		builder.build
	}

	//	override def toString: String = {
	//		if (_ == getBeginOn) {
	//			return ""
	//		}
	//		else {
	//			val msg: Array[String] = Array[String]("", "天", "周", "", "月")
	//			val sdf: SimpleDateFormat = new SimpleDateFormat("yyyy-MM-dd")
	//			val beginAtContent: String = if (_ == getBeginAt) {
	//				_
	//			}
	//			else {
	//				getBeginAt.toString
	//			}
	//			val endAtContent: String = if (_ == getEndAt) {
	//				_
	//			}
	//			else {
	//				getEndAt.toString
	//			}
	//			val beginDate: String = sdf.format(getBeginOn)
	//			val endDate: String = sdf.format(getEndOn)
	//			var dates: String = beginDate
	//			if (!(endDate == beginDate)) {
	//				if (endDate.substring(0, 5) == beginDate.substring(0, 5)) {
	//					dates += "~" + endDate.substring(5)
	//				}
	//				else {
	//					dates += "~" + endDate
	//				}
	//			}
	//			return dates + "(" + beginAtContent + "~" + endAtContent + ")" + "(每" + (if ((getCycleCount.intValue == 1)) {
	//				""
	//			}
	//			else {
	//				getCycleCount.toString
	//			}) + msg(getCycleType.intValue) + ")"
	//		}
	//	}
}