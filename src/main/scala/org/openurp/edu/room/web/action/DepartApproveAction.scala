package org.openurp.edu.room.web.action

import org.beangle.commons.collection.Order
import org.beangle.commons.lang.Strings
import org.beangle.data.dao.OqlBuilder
import org.beangle.webmvc.entity.action.RestfulAction
import org.openurp.base.edu.model.Classroom
import org.openurp.base.model.Campus
import org.openurp.boot.edu.helper.ProjectSupport
import org.openurp.code.edu.model.{ActivityType, ClassroomType}
import org.openurp.edu.room.model.RoomApply

import java.util
import java.util.List

class DepartApproveAction extends RestfulAction[RoomApply] with ProjectSupport {

	override def indexSetting(): Unit = {
		put("campuses", findInSchool(classOf[Campus]))
		put("activityTypes", getCodes(classOf[ActivityType]))
		put("roomTypes", getCodes(classOf[ClassroomType]))
		super.indexSetting()
	}

	override def getQueryBuilder: OqlBuilder[RoomApply] = {
		val builder = OqlBuilder.from(classOf[RoomApply], "roomApply")
		populateConditions(builder)
		builder.where("roomApply.school = :school", getProject.school)
		val room = populateEntity(classOf[Classroom], "room")
		if (Strings.isNotEmpty(room.name) && null != room.roomType) {
			builder.where("exists(from roomApply.rooms m where room.name like :roomName and room.roomType =:roomType)", "%" + room.name + "%", room.roomType)
		}
		else if (Strings.isNotEmpty(room.name)) {
			builder.where("exists(from roomApply.rooms room where room.name like :roomName)", "%" + room.name + "%")
		}
		else if (null != room.roomType) {
			builder.where("exists(from roomApply.rooms room where room.roomType =:roomType)", room.roomType)
		}
		get("lookContent").foreach(lookContent => lookContent match {
			case "1" => {
				builder.where("roomApply.departCheck.approved = true")
				builder.where("roomApply.approved is null")
			}
			case "2" => {
				builder.where("roomApply.departCheck.approved = true")
				builder.where("roomApply.approved = true")
			}
			case "3" => {
				builder.where("roomApply.departCheck.approved = true")
				builder.where("roomApply.approved = false")
			}
			case "" =>
		})
		get(Order.OrderStr) foreach { orderClause =>
			builder.orderBy(orderClause)
		}
		builder.tailOrder("roomApply.id")
		builder.limit(getPageLimit)
	}

}
