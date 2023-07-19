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

import org.beangle.commons.collection.Order
import org.beangle.commons.lang.time.HourMinute
import org.beangle.commons.lang.{Enums, Strings}
import org.beangle.data.dao.OqlBuilder
import org.beangle.web.action.view.View
import org.openurp.base.edu.model.Classroom
import org.openurp.base.model.{Building, Campus, Project, User}
import org.openurp.code.edu.model.{ActivityType, ClassroomType}
import org.openurp.edu.room.model.*
import org.openurp.edu.room.model.CycleTime.CycleTimeType
import org.openurp.edu.room.service.RoomApplyService
import org.openurp.edu.room.util.OccupancyUtils

import java.time.{Instant, LocalDate}
import scala.collection.immutable.TreeMap
import scala.sys.error

/** 代理借用
 */
class AgentAction extends ApplyAction {

  var roomApplyService: RoomApplyService = _

  override def applyForm(): View = {
    val time = getApplyTime()
    put("time", time)
    val activityTypes = codeService.get(classOf[ActivityType]).sortBy(_.id)
    val activityType = activityTypes.head
    put("activityTypes", TreeMap.from(activityTypes.map(x => (x.id, x.name))))
    put("activityType", activityType)
    val rooms = entityDao.find(classOf[Classroom], getLongIds("classroom"))
    put("classrooms", rooms)
    put("user", this.getUser)
    forward()
  }

  override def saveApply(): View = {
    val time = getApplyTime()
    val apply = this.populate(classOf[RoomApply], "apply")

    if (null == apply.time) apply.time = new TimeRequest()
    apply.time.times.addAll(time.toWeektimes())
    apply.time.beginOn = time.beginOn
    apply.time.endOn = time.endOn

    val applicant = entityDao.get(classOf[User], getLongId("applicant"))
    val applier = getUser
    apply.applicant.auditDepart = applier.department
    apply.applicant.user = applicant
    apply.departApproved = Some(true)

    val activity = apply.activity
    activity.speaker = "--"
    activity.attendance = "--"

    val rooms = entityDao.find(classOf[Classroom], getLongIds("classroom"))
    apply.space.campus = rooms.head.campus
    apply.school = applier.school
    apply.applyBy = applier
    apply.applyAt = Instant.now
    entityDao.saveOrUpdate(apply)
    roomApplyService.approve(apply, applier, rooms)
    redirect("search", "借用提交完成")
  }

  def indexSetting(): Unit = {
    given project: Project = getProject

    put("campuses", findInSchool(classOf[Campus]))
    put("activityTypes", getCodes(classOf[ActivityType]))
    put("roomTypes", getCodes(classOf[ClassroomType]))
    put("buildings", findInSchool(classOf[Building]))
    if (getTimeSettings.nonEmpty) {
      put("maxUnitSize", getTimeSettings.head.units.size)
    }
    get("alert").foreach(alert => {
      put("alert", alert)
    })
  }

  def search2(): View = {
    val times = getCycleTime().convert().toBuffer
    if (null == times || times.length == 0) error("借用时间错误!")
    val builder = OccupancyUtils.buildFreeroomQuery(times).limit(getPageLimit)
    get(Order.OrderStr) match {
      case Some(orderClause) => builder.orderBy(orderClause)
      case None => builder.orderBy("room.name,room.capacity")
    }
    populateConditions(builder)
    getInt("seats").foreach(capacity => {
      builder.where("room.capacity >= :capacity", capacity)
    })
    put("rooms", entityDao.search(builder))
    forward()
  }

  def getCycleTime(): CycleTime = {
    val cycleDate = new CycleTime
    getInt("cycleTime.cycleCount").foreach(cycleCount => {
      cycleDate.cycleCount = cycleCount
    })
    getInt("cycleTime.cycleType").foreach(cycleType => {
      cycleDate.cycleType = Enums.of(classOf[CycleTimeType], cycleType).get
    })
    getDate("cycleTime.beginOn").foreach(dateBegin => {
      cycleDate.beginOn = dateBegin
    })
    getDate("cycleTime.endOn").foreach(dateEnd => {
      cycleDate.endOn = dateEnd
    })
    val roomApplyTimeType = getBoolean("roomApplyTimeType", true)
    if (roomApplyTimeType) {
      get("timeBegin").foreach(beginAtContent => {
        cycleDate.beginAt = HourMinute.apply(beginAtContent)
      })
      get("timeEnd").foreach(endAtContent => {
        cycleDate.endAt = HourMinute.apply(endAtContent)
      })
    } else {
      val timeSetting = if (getTimeSettings.nonEmpty) getTimeSettings.head else null
      if (null == timeSetting) error("没有相应时间设置")
      getInt("timeBegin").foreach(beginAtUnit => {
        cycleDate.beginAt = timeSetting.units(beginAtUnit).beginAt
      })
      getInt("timeEnd").foreach(endAtUnit => {
        cycleDate.endAt = timeSetting.units(endAtUnit).endAt
      })
    }
    cycleDate
  }

  def quickApplySetting(): View = {
    given project: Project = getProject

    getInt("cycleTime.cycleCount").foreach(cycleCount => {
      put("cycleCount", cycleCount)
    })
    get("cycleTime.cycleType").foreach(cycleType => {
      put("cycleType", cycleType)
    })
    getDate("cycleTime.beginOn").foreach(beginOn => {
      put("beginOn", beginOn)
    })
    getDate("cycleTime.endOn").foreach(endOn => {
      put("endOn", endOn)
    })
    val roomApplyTimeType = getBoolean("roomApplyTimeType", true)
    if (roomApplyTimeType) {
      get("timeBegin").foreach(timeBegin => {
        put("timeBegin", timeBegin)
      })
      get("timeEnd").foreach(timeEnd => {
        put("timeEnd", timeEnd)
      })
    } else {
      val timeSetting = if (getTimeSettings.nonEmpty) getTimeSettings.head else null
      if (null == timeSetting) error("没有相应时间设置")
      getInt("timeBegin").foreach(beginAtUnit => {
        put("timeBegin", timeSetting.units(beginAtUnit).beginAt)
      })
      getInt("timeEnd").foreach(endAtUnit => {
        put("timeEnd", timeSetting.units(endAtUnit).endAt)
      })
    }
    put("activityTypes", getCodes(classOf[ActivityType]))
    put("departments", getDeparts)
    get("roomIds").foreach(roomIdStr => {
      val roomIds = Strings.splitToLong(roomIdStr)
      val rooms = entityDao.find(classOf[Classroom], roomIds)
      put("roomIds", roomIds)
      put("rooms", rooms)
      var maxCapacity = 0
      rooms.foreach(room => {
        maxCapacity += room.capacity
      })
      put("maxCapacity", maxCapacity)
    })
    forward()
  }

  override def buildApply(): RoomApply = {
    val roomApply = populateEntity(classOf[RoomApply], "roomApply")
    get("roomIds").foreach(roomIdStr => {
      if (roomIdStr.length > 0) {
        val roomIds = Strings.splitToLong(roomIdStr)
        if (null != roomIds && roomIds.length > 0) {
          val rooms = entityDao.find(classOf[Classroom], roomIds)
          roomApply.rooms.++=(rooms)
          val spaceRequest = new SpaceRequest
          spaceRequest.campus = rooms.head.campus
          roomApply.space = spaceRequest
        }
      }
    })
    val times = getCycleTime().convert().toBuffer
    val timeRequest = new TimeRequest
    timeRequest.times = times
    getDate("cycleTime.beginOn").foreach(beginOn => {
      timeRequest.beginOn = beginOn
    })
    getDate("cycleTime.endOn").foreach(endOn => {
      timeRequest.endOn = endOn
    })
    roomApply.time = timeRequest
    roomApply.applyAt = Instant.now()
    roomApply.applyBy = getUser
    roomApply.school = getUser.school
    roomApply.activity.attendance = "--"
    roomApply.activity.speaker = "--"
    roomApply
  }

  override def submitApply(): View = {
    val roomApply = buildApply()
    val days = roomApply.time.beginOn.toEpochDay - LocalDate.now.toEpochDay
    if (days < 2) {
      redirect("index", "&alert=1", null)
    } else {
      try {
        saveOrUpdate(roomApply)
        //        val departCheck = roomApply.departCheck match {
        //          case Some(value) => value
        //          case None => new RoomApplyDepartCheck
        //        }
        //        departCheck.roomApply = roomApply
        //        departCheck.approved = true
        //        departCheck.checkedAt = Instant.now()
        //        departCheck.checkedBy = getUser
        //        saveOrUpdate(departCheck)
        //        roomApply.departCheck = Option(departCheck)
        //        val finalCheck = roomApply.finalCheck match {
        //          case Some(value) => value
        //          case None => new RoomApplyFinalCheck
        //        }
        //        finalCheck.roomApply = roomApply
        //        finalCheck.approved = true
        //        finalCheck.checkedAt = Instant.now()
        //        finalCheck.checkedBy = getUser
        //        saveOrUpdate(finalCheck)
        //        roomApply.finalCheck = Option(finalCheck)
        roomApply.approved = Option(true)
        saveOrUpdate(roomApply)
        redirect("info", "&id=" + roomApply.id, null)
      }
      catch {
        case e: Exception =>
          logger.info("saveAndForwad failure", e)
          redirect("index", "info.save.failure")
      }
    }
  }
}
