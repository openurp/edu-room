package org.openurp.edu.room.web.action

import java.time.LocalDate

import org.beangle.data.dao.OqlBuilder
import org.beangle.webmvc.api.view.View
import org.beangle.webmvc.entity.action.RestfulAction
import org.openurp.boot.edu.helper.ProjectSupport
import org.openurp.code.edu.model.ActivityType
import org.openurp.edu.room.model.{Occupancy, WeekTimeBuilder}

class OccupancyAction extends RestfulAction[Occupancy] with ProjectSupport {

	override def info(id: String): View = {
		put("now", LocalDate.now())
		put("activityTypes", getCodes(classOf[ActivityType]))
		put("room", entityDao.get(classOf[Occupancy], id.toLong).room)
		forward()
	}

	def info_m(): View = {
		get("id").foreach(id => {
			info(id)
		})
		forward()
	}

	def stat(): View = {
		val startOn = getDateTime("startAt").head.toLocalDate
		val endOn = getDateTime("endAt").head.toLocalDate
		val query = OqlBuilder.from(classOf[Occupancy], "occupancy")
		getLong("roomId").foreach(roomId => {
			query.where("occupancy.room.id = :roomId", roomId)
		})
		query.where("occupancy.time.startOn <= :endOn", endOn)
		val times = WeekTimeBuilder.build(startOn, endOn)
		if (times.size > 0) {
			times.indices.foreach(i => {
				query.where("or (occupancy.time.startOn = :startOn" + i + " and bitand(occupancy.time.weekstate,:weekstate" + i + ")>0)", times(i).startOn, times(i).weekstate)
			})
		}
		put("occupancies", entityDao.search(query))
		forward()
	}

	def stat_m: View = {
		stat()
	}
}
