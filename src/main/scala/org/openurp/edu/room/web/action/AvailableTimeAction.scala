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

import org.beangle.commons.lang.{Enums, Strings}
import org.beangle.commons.lang.time.{HourMinute, WeekTime}
import org.beangle.data.dao.OqlBuilder
import org.beangle.web.action.view.View
import org.beangle.webmvc.support.action.RestfulAction
import org.openurp.base.edu.model.Classroom
import org.openurp.base.model.{Campus, Project}
import org.openurp.edu.room.model.CycleTime.CycleTimeType
import org.openurp.edu.room.model.{CycleTime, RoomAvailableTime}
import org.openurp.starter.web.support.ProjectSupport

import java.time.Instant
import scala.collection.mutable

class AvailableTimeAction extends RestfulAction[RoomAvailableTime] with ProjectSupport {

  override def indexSetting(): Unit = {
    given project: Project = getProject
    put("campuses", findInSchool(classOf[Campus]))
    super.indexSetting()
  }

  override def editSetting(entity: RoomAvailableTime): Unit = {
    val builder = OqlBuilder.from(classOf[Classroom], "cr")
    builder.where("exists(from cr.projects as project where project=:project)", getProject)
    put("rooms", entityDao.search(builder))
    super.editSetting(entity)
  }

  def batchAdd(): View = {
    forward()
  }

  def saveTime(): View = {
    getLong("availableTime.id").foreach(availableTimeId => {
      val availableTimeNow = entityDao.get(classOf[RoomAvailableTime], availableTimeId)
      entityDao.remove(availableTimeNow)
    })
    val times = getTimes()
    val room = entityDao.findBy(classOf[Classroom], "code", get("availableTime.room")).head
    if (times.isEmpty) {
      redirect("search", "info.save.failure")
    } else {
      times.foreach(time => {
        val builder = OqlBuilder.from(classOf[RoomAvailableTime], "at")
        builder.where("at.room=:room", room)
        builder.where("at.time=:time", time)
        val availableTimes = entityDao.search(builder)
        val availableTime = if (availableTimes.isEmpty) new RoomAvailableTime else availableTimes.head
        availableTime.time = time
        availableTime.updatedAt = Instant.now()
        availableTime.room = room
        availableTime.project = getProject
        saveOrUpdate(availableTime)
      })
      redirect("search", "info.save.success")
    }
  }

  def batchSave(): View = {
    val times = getTimes()
    get("availableTime.room").orNull match {
      case null => redirect("search", "info.save.failure")
      case roomStr => {
        val newRoomStr = roomStr.replaceAll("\n", ",")
          .replaceAll("\r\n", ",")
          .replaceAll("\r", ",")
          .replaceAll("\t", ",")
          .replaceAll("，", ",")
          .replaceAll(" ", ",")
        val roomStrSeq = Strings.split(newRoomStr, ",")
        val rooms = entityDao.findBy(classOf[Classroom], "code", roomStrSeq)
        if (rooms.isEmpty) {
          redirect("search", "info.save.failure")
        } else {
          rooms.foreach(room => {
            times.foreach(time => {
              val availableTime = new RoomAvailableTime
              availableTime.time = time
              availableTime.updatedAt = Instant.now()
              availableTime.room = room
              availableTime.project = getProject
              saveOrUpdate(availableTime)
            })
          })
          redirect("search", "info.save.success")
        }
      }
    }
  }

  def getTimes(): List[WeekTime] = {
    val cycleDate = new CycleTime
    getInt("cycleTime.cycleCount").foreach(cycleCount => {
      cycleDate.cycleCount = cycleCount
    })
    getInt("cycleTime.cycleType").foreach(cycleType => {
      cycleDate.cycleType = Enums.of(classOf[CycleTimeType],cycleType).get
    })
    getDate("cycleTime.beginOn").foreach(dateBegin => {
      cycleDate.beginOn = dateBegin
    })
    getDate("cycleTime.endOn").foreach(dateEnd => {
      cycleDate.endOn = dateEnd
    })
    get("beginAt").foreach(beginAtContent => {
      cycleDate.beginAt = HourMinute.apply(beginAtContent)
    })
    get("endAt").foreach(endAtContent => {
      cycleDate.endAt = HourMinute.apply(endAtContent)
    })
    cycleDate.convert()
  }

  def roomAjax(): View = {
    val query = OqlBuilder.from(classOf[Classroom], "cr")
    query.orderBy("cr.code")
    query.where("exists(from cr.projects as project where project=:project)", getProject)
    populateConditions(query)
    get("term").foreach(codeOrName => {
      query.where("(cr.name like :name )", s"%$codeOrName%")
    })
    query.limit(getPageLimit)
    put("rooms", entityDao.search(query))
    forward("roomsJSON")
  }

  override protected def simpleEntityName: String = {
    "availableTime"
  }
}
