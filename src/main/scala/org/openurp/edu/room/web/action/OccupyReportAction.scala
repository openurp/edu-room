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

package org.openurp.edu.room.web.action

import org.beangle.commons.bean.orderings.PropertyOrdering
import org.beangle.commons.collection.Collections
import org.beangle.commons.lang.time.WeekDay
import org.beangle.data.dao.{Condition, OqlBuilder}
import org.beangle.webmvc.support.action.RestfulAction
import org.beangle.webmvc.support.helper.QueryHelper
import org.beangle.webmvc.view.View
import org.openurp.base.edu.model.TimeSetting
import org.openurp.base.model.{Campus, Project, Semester}
import org.openurp.base.resource.model.{Building, Classroom}
import org.openurp.code.asset.model.ClassroomType
import org.openurp.edu.clazz.domain.WeekTimeBuilder
import org.openurp.edu.room.model.Occupancy
import org.openurp.edu.room.util.OccupySlot
import org.openurp.starter.web.support.ProjectSupport

/** 占用报告
 */
class OccupyReportAction extends RestfulAction[Classroom], ProjectSupport {

  override def index(): View = {
    given project: Project = getProject

    put("semester", getSemester)
    put("project", project)
    put("roomTypes", getCodes(classOf[ClassroomType]))
    put("campuses", findInSchool(classOf[Campus]))
    put("buildings", findInSchool(classOf[Building]))
    forward()
  }

  override def getQueryBuilder: OqlBuilder[Classroom] = {
    val builder = super.getQueryBuilder
    builder.where("classroom.school=:school", getProject.school)
    QueryHelper.addActive(builder, Some(true))
    getBoolean("virtual") foreach { virtual =>
      builder.where(if (virtual) "classroom.roomNo is null" else "classroom.roomNo is not null")
    }
    builder
  }

  def stat(): View = {
    val classroomIds = getLongIds("classroom")

    val semester = entityDao.get(classOf[Semester], getIntId("semester"))
    val weekTimes = WeekTimeBuilder.build(semester.beginOn, semester.endOn, 1)

    val query = OqlBuilder.from(classOf[Occupancy], "occ")
    populateConditions(query)
    query.where("occ.room.id in (:roomIds)", classroomIds)
    if (weekTimes.nonEmpty) {
      val sb = Collections.newBuffer[String]
      val params = Collections.newBuffer[Any]
      weekTimes.indices.foreach(i => {
        sb += "(occ.time.startOn = :startOn" + i + " and bitand(occ.time.weekstate,:weekstate" + i + ")>0)"
        params += weekTimes(i).startOn
        params += weekTimes(i).weekstate
      })
      val con = new Condition(sb.mkString(" or "))
      con.params(params)
      query.where(con)
    }
    val occupancies = entityDao.search(query)
    val tquery = OqlBuilder.from(classOf[TimeSetting], "t")
    tquery.where("t.endOn is null")
    val timeSetting = entityDao.search(tquery).head

    val slotMap = Collections.newMap[String, OccupySlot]
    val rooms = Collections.newSet[Classroom]
    val it = occupancies.iterator
    val weekdaySet = Collections.newSet[WeekDay]
    while (it.hasNext) {
      val occ = it.next
      weekdaySet.add(occ.time.weekday)
      val unitPair = timeSetting.getUnitSpan(occ.time.beginAt, occ.time.endAt)
      for (i <- unitPair._1 to unitPair._2) {
        val key = occ.room.id.toString + "_" + occ.time.weekday.id.toString + "_" + i.toString
        val slot = slotMap.getOrElseUpdate(key, new OccupySlot(occ.time.weekday, semester))
        slot.add(occ)
        rooms.add(occ.room)
      }
    }
    put("slotMap", slotMap)
    import org.beangle.commons.lang.time.WeekDay.*
    val weekdayList = List(Mon, Tue, Wed, Thu, Fri, Sat, Sun).toBuffer
    if (!weekdaySet.contains(Sat)) weekdayList.subtractOne(Sat)
    if (!weekdaySet.contains(Sun)) weekdayList.subtractOne(Sun)

    put("weekdays", weekdayList)
    put("units", timeSetting.units)

    val classrooms = rooms.toBuffer.sorted(PropertyOrdering.by("name"))
    put("classrooms", classrooms)
    put("semester", semester)
    put("project", getProject)
    forward("report_" + get("report", "week"))
  }
}
