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
