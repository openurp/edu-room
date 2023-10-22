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

import org.beangle.data.dao.OqlBuilder
import org.beangle.web.action.annotation.mapping
import org.beangle.web.action.context.ActionContext
import org.beangle.web.action.view.View
import org.openurp.base.edu.model.Classroom
import org.openurp.base.model.*
import org.openurp.code.edu.model.ActivityType
import org.openurp.edu.room.model.*

import java.time.Instant
import scala.collection.immutable.TreeMap

/** 院系代理借用
 */
class DepartAgentAction extends StaffApplyAction {
  override def index(): View = {
    given project: Project = getProject

    val scopes = roomApplyService.getScopes(getDeparts)
    val opened = scopes.exists(_.within(Instant.now))
    put("opened", opened)
    forward()
  }

  override def freeRooms(): View = {
    given project: Project = getProject

    val query = buildFreeRoomQuery()
    val scopes = roomApplyService.getScopes(getDeparts)
    val opened = scopes.exists(_.within(Instant.now))
    if (opened) {
      query.where("room.id <0")
    } else {
      val rooms = scopes.flatMap(_.rooms)
      query.where("room in(:rooms)", rooms)
    }
    put("classrooms", entityDao.search(query))
    forward()
  }

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
    put("hasSmsSupport", smsService.nonEmpty)
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

    val rooms = entityDao.find(classOf[Classroom], getLongIds("classroom"))
    apply.space.campus = rooms.head.campus
    roomApplyService.submit(apply, applier)
    roomApplyService.approve(apply, applier, rooms)
    businessLogger.info(s"代理借用了教室(${apply.activity.name})", apply.id, ActionContext.current.params)
    redirect("search", "借用提交完成")
  }

  @mapping(method = "delete")
  override def remove(): View = {
    val query = OqlBuilder.from(classOf[RoomApply], "apply")
    query.where("apply.applyBy=:me", getUser)
    query.where("apply.id in(:applyIds)", getLongIds("roomApply"))
    val applies = entityDao.search(query)
    applies foreach { apply =>
      roomApplyService.remove(apply)
      businessLogger.info(s"删除教室借用申请(${apply.activity.name})", apply.id, ActionContext.current.params)
    }
    redirect("search", s"成功删除${applies.size}个教室申请")
  }

}
