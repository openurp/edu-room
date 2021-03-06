package org.openurp.edu.room.web.action

import org.beangle.commons.collection.Order
import org.beangle.commons.lang.Strings
import org.beangle.data.dao.OqlBuilder
import org.beangle.security.Securities
import org.beangle.webmvc.api.view.View
import org.openurp.base.edu.model.Classroom
import org.openurp.base.model.User
import org.openurp.code.edu.model.ClassroomType
import org.openurp.edu.room.model.{ApplyDepartCheck, ApplyFinalCheck, RoomApply}
import org.openurp.edu.room.service.RoomApplyService
import org.openurp.edu.room.util.OccupancyUtils

import java.time.Instant
import scala.sys.error


class ApproveAction extends DepartApproveAction {

	var occupancyUtils: OccupancyUtils = _
	var roomApplyService: RoomApplyService = _

	def report: View = {
		val ids = longIds("roomApply")
		val applies = entityDao.find(classOf[RoomApply], ids).filter(e => (e.approved != null && e.approved.get))
		put("applies", applies)
		put("project", getProject)
		forward()
	}

	override def search(): View = {
		val builder = getQueryBuilder
		if (Strings.isEmpty(get("lookContent").orNull)) builder.where("roomApply.departCheck.approved = true")
		put("roomApplies", entityDao.search(builder))
		forward()
	}

	/**
	 * 给申请分配教室
	 */
	def applySetting: View = {
		val id = longId("roomApply")
		if (null == id) error("error.parameters.needed")
		val roomApply = entityDao.get(classOf[RoomApply], id)
		put("roomTypes", getCodes(classOf[ClassroomType]))
		get("roomIds").foreach(roomIdStr => {
			if (roomIdStr.length > 0) {
				val roomIds = Strings.splitToLong(roomIdStr)
				if (null != roomIds && roomIds.length > 0) {
					val rooms = entityDao.find(classOf[Classroom], roomIds)
					roomApply.rooms.++=(rooms)
				}
			}
		})
		put("roomApply", roomApply)
		forward()
	}

	/**
	 * 审批教室借用
	 */
	def approve: View = {
		val roomApply = populateEntity(classOf[RoomApply], "roomApply")
		get("roomIds") match {
			case Some(roomIdStr) => {
				val roomIds = Strings.splitToLong(roomIdStr)
				val times = roomApply.time.times
				val builder = occupancyUtils.buildFreeroomQuery(times)
				builder.where("room.id in (:roomIds)", roomIds)
				val classrooms = entityDao.search(builder)
				if (classrooms.size != roomIds.length) {
					return redirect("applySetting", "roomApply.id=" + roomApply.id, "该教室已被占用,请重新查找空闲教室")
				}
				val rooms = entityDao.find(classOf[Classroom], roomIds)
				if (roomApplyService.approve(roomApply, getUser, rooms)) redirect("search", "info.action.success")
				else redirect("search", "info.action.failure")
			}
			case None => {
				roomApply.rooms.clear()
				roomApply.approved = null
				entityDao.saveOrUpdate(roomApply)
				redirect("search", "info.action.success")
			}
		}
	}

	def getUser: User = {
		val builder = OqlBuilder.from(classOf[User], "user")
		builder.where("user.code=:code", Securities.user)
		val users = entityDao.search(builder)
		if (users.isEmpty) {
			null
		} else {
			users.head
		}
	}

	def freeRooms: View = {
		val roomApplyId = longId("roomApply")
		if (null == roomApplyId) error("error.parameters.needed")
		val apply = entityDao.get(classOf[RoomApply], roomApplyId)
		val query = occupancyUtils.buildFreeroomQuery(apply.time.times)
		if (null != apply.space.campus) query.where("room.campus=:campus", apply.space.campus)
		populateConditions(query, "room.capacity")
		getInt("room.capacity") match {
			case Some(capacity) => query.where("room.capacity>=:capacity", capacity)
			case None => query.where("room.capacity>=:capacity", apply.space.unitAttendance)
		}
		get(Order.OrderStr) match {
			case Some(orderClause) => query.orderBy(orderClause)
			case None => query.orderBy("room.name,room.capacity")
		}
		query.limit(getPageLimit)
		put("rooms", entityDao.search(query))
		put("roomApply", apply)
		forward()
	}

	/**
	 * 取消已批准的教室
	 */
	def cancel: View = {
		val roomApplies = entityDao.find(classOf[RoomApply], longIds("roomApply"))
		if (roomApplies.isEmpty) error("error.parameters.needed")
		roomApplies.foreach(roomApply => {
			roomApply.rooms.clear()
			saveOrUpdate(roomApply)
			val finalCheck = roomApply.finalCheck match {
				case Some(value) => value
				case None => new ApplyFinalCheck
			}
			finalCheck.apply = roomApply
			finalCheck.approved = false
			finalCheck.checkedAt = Instant.now()
			finalCheck.checkedBy = getUser
			finalCheck.opinions = get("roomApply.approvedRemark")
			saveOrUpdate(finalCheck)
			roomApply.finalCheck = Option(finalCheck)
			roomApply.approved = Option(false)
		})
		try entityDao.saveOrUpdate(roomApplies)
		catch {
			case e: Exception =>
				return redirect("search", "info.action.failure")
		}
		redirect("search", "info.action.success")
	}

}
