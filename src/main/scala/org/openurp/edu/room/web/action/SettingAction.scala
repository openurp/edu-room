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

import org.beangle.security.Securities
import org.beangle.webmvc.view.View
import org.beangle.webmvc.support.action.RestfulAction
import org.openurp.base.model.{Campus, User}
import org.openurp.edu.room.config.{RoomApplyReservedTime, RoomApplySetting}
import org.openurp.edu.room.service.RoomApplyService

class SettingAction extends RestfulAction[RoomApplySetting] {
  var roomApplyService: RoomApplyService = _

  override def indexSetting(): Unit = {
    val applicant = getUser
    put("reservedTimes", roomApplyService.getReservedTimes(applicant.school))
    put("setting", entityDao.getAll(classOf[RoomApplySetting]).headOption.getOrElse(new RoomApplySetting))
  }

  override def search(): View = {
    val applicant = getUser
    put("reservedTimes", roomApplyService.getReservedTimes(applicant.school))
    put("setting", entityDao.getAll(classOf[RoomApplySetting]).headOption)
    forward("index")
  }

  protected override def editSetting(entity: RoomApplySetting): Unit = {
    val applicant = getUser
    put("campuses", entityDao.getAll(classOf[Campus]))
    put("reservedTimes", roomApplyService.getReservedTimes(applicant.school))
  }

  override def saveAndRedirect(entity: RoomApplySetting): View = {
    entity.school = getUser.school
    val campuses = entityDao.getAll(classOf[Campus])
    (1 to 3) foreach { i =>
      val beginOn = getDate(s"rt${i}.beginOn")
      val endOn = getDate(s"rt${i}.endOn")
      val rtId = getLong(s"rt${i}.id")
      if (beginOn.nonEmpty && endOn.nonEmpty) {
        val rt = getLong(s"rt${i}") match
          case None => new RoomApplyReservedTime
          case Some(i) => entityDao.get(classOf[RoomApplyReservedTime], i)
        rt.school = entity.school
        rt.campus = campuses.head
        rt.beginOn = beginOn.get
        rt.endOn = endOn.get
        entityDao.saveOrUpdate(rt)
      } else {
        val rtId = getLong(s"rt${i}.id")
        if (rtId.nonEmpty) {
          entityDao.remove(entityDao.get(classOf[RoomApplyReservedTime], rtId.get))
        }
      }
    }
    super.saveAndRedirect(entity)
  }

  override def info(id: String): View = {
    val applicant = getUser
    put("reservedTimes", roomApplyService.getReservedTimes(applicant.school))
    super.info(id)
  }

  def getUser: User = {
    entityDao.findBy(classOf[User], "code", List(Securities.user)).headOption.orNull
  }

}
