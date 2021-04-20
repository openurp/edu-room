package org.openurp.edu.room.web.action

import org.beangle.commons.collection.Order
import org.beangle.commons.lang.Strings
import org.beangle.commons.lang.time.HourMinute
import org.beangle.data.dao.OqlBuilder
import org.beangle.webmvc.api.view.View
import org.openurp.base.edu.model.Classroom
import org.openurp.base.model.{Building, Campus}
import org.openurp.code.edu.model.{ActivityType, ClassroomType}
import org.openurp.edu.room.model.{ApplyDepartCheck, ApplyFinalCheck, CycleDate, RoomApply, SpaceRequest, TimeRequest}
import org.openurp.edu.room.util.OccupancyUtils

import java.time.{Instant, LocalDate}
import scala.sys.error

class QuickApplyAction extends RoomApplyAction {

	var occupancyUtils: OccupancyUtils = _

	override def indexSetting(): Unit = {
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
		super.indexSetting()
	}

	def campusBuilding(): View = {
		val builder = OqlBuilder.from(classOf[Building], "building")
		getInt("campusId").foreach(campusId => {
			builder.where("building.campus.id = :campusId", campusId)
		})
		builder.where("building.beginOn <= :now and (building.endOn is null or building.endOn >= :now)", LocalDate.now()).orderBy("building.name")
		put("datas", entityDao.search(builder))
		forward()
	}

	override def search(): View = {
		val times = getCycleDate().convert.toBuffer
		if (null == times || times.length == 0) error("借用时间错误!")
		val builder = occupancyUtils.buildFreeroomQuery(times).limit(getPageLimit)
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

	def getCycleDate(): CycleDate = {
		val cycleDate = new CycleDate
		getInt("cycleTime.cycleCount").foreach(cycleCount => {
			cycleDate.cycleCount = cycleCount
		})
		getInt("cycleTime.cycleType").foreach(cycleType => {
			cycleDate.cycleType = cycleType
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
		val times = getCycleDate().convert.toBuffer
		val timeRequest = new TimeRequest
		timeRequest.times = times
		getDate("cycleTime.beginOn").foreach(beginOn => {
			timeRequest.beginOn = beginOn
		})
		getDate("cycleTime.endOn").foreach(endOn => {
			timeRequest.endOn = endOn
		})
		roomApply.time = timeRequest
		roomApply.time.calcMinutes()
		roomApply.applyAt = Instant.now()
		roomApply.applyBy = getUser
		roomApply.school = getUser.school
		roomApply.activity.attendance = "--"
		roomApply.activity.speaker = "--"
		roomApply
	}

	override def apply(): View = {
		val roomApply = buildApply()
		val days = roomApply.time.beginOn.toEpochDay - LocalDate.now.toEpochDay
		if (days < 2) {
			redirect("index", "&alert=1", null)
		} else {
			try {
				saveOrUpdate(roomApply)
				val departCheck = roomApply.departCheck match {
					case Some(value) => value
					case None => new ApplyDepartCheck
				}
				departCheck.apply = roomApply
				departCheck.approved = true
				departCheck.checkedAt = Instant.now()
				departCheck.checkedBy = getUser
				saveOrUpdate(departCheck)
				roomApply.departCheck = Option(departCheck)
				val finalCheck = roomApply.finalCheck match {
					case Some(value) => value
					case None => new ApplyFinalCheck
				}
				finalCheck.apply = roomApply
				finalCheck.approved = true
				finalCheck.checkedAt = Instant.now()
				finalCheck.checkedBy = getUser
				saveOrUpdate(finalCheck)
				roomApply.finalCheck = Option(finalCheck)
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
