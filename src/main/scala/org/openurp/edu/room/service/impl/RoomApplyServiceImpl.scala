package org.openurp.edu.room.service.impl

import org.beangle.data.dao.Query.Lang.OQL
import org.beangle.data.dao.{EntityDao, OqlBuilder}
import org.openurp.base.edu.model.Classroom
import org.openurp.base.model.User
import org.openurp.edu.room.model.{Occupancy, RoomApply, RoomApplyAuditLog, RoomOccupyApp}
import org.openurp.edu.room.service.RoomApplyService

import java.time.Instant
import scala.collection.mutable

class RoomApplyServiceImpl extends RoomApplyService {

  var entityDao: EntityDao = _

  private def getOccupancies(roomApply: RoomApply): Seq[Occupancy] = {
    if (roomApply.rooms.nonEmpty) {
      val query = OqlBuilder.from(classOf[Occupancy], "occ")
      query.where("occ.room in(:rooms)", roomApply, roomApply.rooms)
      query.where("occ.activity.id=:activityId", roomApply.id)
      query.where("occ.app.id=:appId", RoomOccupyApp.RoomAppId)
      entityDao.search(query)
    } else {
      List.empty
    }
  }

  /** 批准教室申请(允许批量分配教室)
   */
  override def approve(roomApply: RoomApply, approveBy: User, rooms: Seq[Classroom]): Boolean = {
    entityDao.remove(getOccupancies(roomApply))
    roomApply.rooms.clear()
    roomApply.approved = Option(rooms.nonEmpty)
    roomApply.approvedAt = Some(Instant.now)

    val log = new RoomApplyAuditLog
    log.apply = roomApply
    log.approved = true
    log.auditAt = Instant.now
    log.auditBy = approveBy.code + " " + approveBy.name

    val occupancies = new mutable.ArrayBuffer[Occupancy]
    roomApply.time.times.foreach(time => {
      rooms.foreach(room => {
        val occupancy = new Occupancy
        occupancy.room = room
        occupancy.time = time
        occupancy.activityType = roomApply.activity.activityType
        occupancy.comments = roomApply.activity.name
        occupancy.app = new RoomOccupyApp(RoomOccupyApp.RoomAppId)
        occupancy.activityId = roomApply.id
        occupancy.updatedAt = Instant.now()
        occupancies.addOne(occupancy)
      })
    })
    roomApply.rooms.addAll(rooms)
    try {
      entityDao.saveOrUpdate(roomApply, log)
      entityDao.saveOrUpdate(occupancies)
    } catch {
      case e: Exception => return false
    }
    true
  }
}
