package org.openurp.edu.clazz.service

object CourseTableStyle extends Enumeration {

	/**
	 * x-星期，y-小节
	 */

	val WEEK_TABLE = new Style("WEEK_TABLE")

	/**
	 * x-小节，y-星期
	 */
	val UNIT_COLUMN = new Style("UNIT_COLUMN")

	/**
	 * 逐次安排的列表
	 */
	val LIST = new Style("LIST")

	val STYLE_KEY = "schedule.courseTable.style"

	class Style(name: String) extends super.Val(name)
}
