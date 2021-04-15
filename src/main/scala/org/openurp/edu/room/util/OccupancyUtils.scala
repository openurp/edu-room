package org.openurp.edu.room.util

import org.beangle.commons.lang.time.WeekTime
import org.beangle.data.dao.OqlBuilder
import org.openurp.base.edu.model.Classroom

import java.time.LocalDate
import scala.collection.mutable

class OccupancyUtils {

	def buildFreeroomQuery(units: mutable.Buffer[WeekTime]): OqlBuilder[Classroom] = {
		val hql = new StringBuilder(" from org.openurp.edu.room.model.Occupancy occupancy where occupancy.room = room ")
		units.indices.foreach(i => {
			val ocuupy = "(bitand(occupancy.time.weekstate," + units(i).weekstate.value + ")>0 " + " and to_char(occupancy.time.startOn,'yyyy-MM-dd') = '" + units(i).startOn + "' and occupancy.time.beginAt < " + units(i).endAt.value + " and occupancy.time.endAt > " + units(i).beginAt.value + ")"
			if (i > 0) hql.append(" or ")
			else if (i == 0) hql.append(" and (")
			hql.append(ocuupy)
		})
		hql.append(")")
		val query = OqlBuilder.from(classOf[Classroom], "room")
		query.where("room.beginOn <= :now and (room.endOn is null or room.endOn >= :now)", LocalDate.now())
		query.where("not exists (" + hql.toString + ")")
		query
	}

}
