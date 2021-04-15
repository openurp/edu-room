package org.openurp.edu.room.service

import org.beangle.commons.collection.Collections
import org.beangle.commons.lang.Strings
import org.beangle.webmvc.entity.action.RestfulAction
import org.openurp.base.edu.model.Classroom
import org.openurp.base.model.User
import org.openurp.boot.edu.helper.ProjectSupport
import org.openurp.edu.room.model.{ApplyFinalCheck, Occupancy, RoomApply, RoomOccupyApp}
import org.openurp.edu.room.util.OccupancyUtils

import java.time.Instant
import scala.collection.mutable

class RoomApplyService extends RestfulAction[RoomApply] with ProjectSupport {

	var occupancyUtils: OccupancyUtils = _

	/**
	 * 批准教室申请(允许批量分配教室)
	 *
	 */
	def approve(roomApply: RoomApply, approveBy: User, rooms: Seq[Classroom]): Boolean = {
		val exitOccupancies = entityDao.findBy(classOf[Occupancy], "room", rooms)
		entityDao.remove(exitOccupancies)
		roomApply.rooms.clear()

		roomApply.approved = Option(!rooms.isEmpty)
		val finalCheck = roomApply.finalCheck match {
			case Some(value) => value
			case None => new ApplyFinalCheck
		}
		finalCheck.apply = roomApply
		finalCheck.approved = true
		finalCheck.checkedAt = Instant.now()
		finalCheck.checkedBy = approveBy
		saveOrUpdate(finalCheck)
		roomApply.finalCheck = Option(finalCheck)
		// 教研活动
		val units = roomApply.time.times
		val freerooms = entityDao.search(occupancyUtils.buildFreeroomQuery(units))
		val newRooms = Collections.newSet[Classroom]
		units.indices.foreach(i => {
			rooms.foreach(room => {
				if (freerooms.contains(room)) {
					val occupancy = new Occupancy
					newRooms.add(room)
					occupancy.room = room
					occupancy.time = units(i)
					occupancy.activityType = roomApply.activity.activityType
					// 流水号 活动 部门 人 人数
					occupancy.comments = roomApply.id + " " + roomApply.activity.name + " " +
						(roomApply.borrower.department.shortName match {
							case Some(value) => value
							case None => roomApply.borrower.department.name
						}) +
						" " + roomApply.borrower.applicant + " " + roomApply.activity.attendanceNum + "人"
					occupancy.app = entityDao.get(classOf[RoomOccupyApp], 3.toLong)
					occupancy.activityId = roomApply.id
					occupancy.updatedAt = Instant.now()
					saveOrUpdate(occupancy)
				}
				else false
			})
		})
		roomApply.rooms.addAll(rooms)
		try entityDao.saveOrUpdate(roomApply)
		catch {
			case e: Exception =>
				return false
		}
		true
	}
}
