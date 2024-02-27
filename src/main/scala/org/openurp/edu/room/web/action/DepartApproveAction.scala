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
import org.beangle.commons.lang.time.WeekTime
import org.beangle.data.dao.{Condition, Conditions, OqlBuilder}
import org.beangle.ems.app.web.WebBusinessLogger
import org.beangle.web.action.annotation.{mapping, param}
import org.beangle.web.action.context.ActionContext
import org.beangle.web.action.view.View
import org.beangle.webmvc.support.action.RestfulAction
import org.beangle.webmvc.support.helper.QueryHelper
import org.openurp.base.edu.model.Holiday
import org.openurp.base.model.{Campus, Project}
import org.openurp.base.resource.model.Classroom
import org.openurp.code.edu.model.{ActivityType, ClassroomType}
import org.openurp.edu.room.model.{Occupancy, RoomApply}
import org.openurp.starter.web.support.ProjectSupport

import java.time.{Instant, LocalDate}
import scala.collection.immutable.TreeMap

class DepartApproveAction extends RestfulAction[RoomApply] with ProjectSupport {
  var businessLogger: WebBusinessLogger = _

  override def indexSetting(): Unit = {
    given project: Project = getProject

    put("campuses", findInSchool(classOf[Campus]))
    put("activityTypes", getCodes(classOf[ActivityType]))
    put("roomTypes", getCodes(classOf[ClassroomType]))
    put("project", project)
    put("semester", getSemester)
    super.indexSetting()
  }

  override def getQueryBuilder: OqlBuilder[RoomApply] = {
    val builder = OqlBuilder.from(classOf[RoomApply], "roomApply")
    populateConditions(builder)
    builder.where("roomApply.school = :school", getProject.school)
    val roomConditions = QueryHelper.extractConditions(classOf[Classroom], "room", null)
    if (roomConditions.nonEmpty) {
      val params = roomConditions.flatten(_.params)
      val con = new Condition(s"exists(from roomApply.rooms as room where ${Conditions.toQueryString(roomConditions)})").params(params)
      builder.where(con)
    }
    getDate("occupyOn") foreach { occupyOn =>
      val wt = WeekTime.of(occupyOn)
      builder.where("exists(from roomApply.time.times t where t.startOn=:starton and bitand(t.weekstate,:weekstate)>0)",
        wt.startOn, wt.weekstate)
    }
    get("lookContent").foreach {
      case "1" =>
        builder.where("roomApply.departApproved = true")
        builder.where("roomApply.approved is null")
      case "2" =>
        builder.where("roomApply.departApproved = true")
        builder.where("roomApply.approved = true")
      case "3" =>
        builder.where("roomApply.departApproved = true")
        builder.where("roomApply.approved = false")
      case "" =>
    }
    get("approved").foreach {
      case "null" =>
        builder.where("roomApply.approved is null")
      case "0" =>
        builder.where("roomApply.approved = false")
      case "1" =>
        builder.where("roomApply.approved = true")
      case "" =>
    }
    get(Order.OrderStr) foreach { orderClause =>
      builder.orderBy(orderClause)
    }
    builder.tailOrder("roomApply.id")
    builder.limit(getPageLimit)
  }

  def preview(): View = {
    put(simpleEntityName, entityDao.get(classOf[RoomApply], getLongId("roomApply")))
    forward()
  }

  /** 根据节假日调整占用情况
   *
   * @return
   */
  def switching(): View = {
    val query = OqlBuilder.from(classOf[Holiday], "d")
    query.where("d.startOn >= :today", LocalDate.now)
    query.where("d.switchTo is not null")
    val holidays = entityDao.search(query)
    holidays foreach { holiday =>
      val wt1 = WeekTime.of(holiday.startOn)
      val wt2 = WeekTime.of(holiday.switchTo.get)

      val q = OqlBuilder.from(classOf[Occupancy], "occ")
      q.where("occ.time.startOn=:startOn", wt1.startOn)
      q.where("bitand(occ.time.weekstate,:weekstate)>0", wt1.weekstate)
      val occupancies = entityDao.search(q)
      occupancies foreach { occ =>
        val nq = OqlBuilder.from(classOf[Occupancy], "occ")
        nq.where("occ.time.startOn=:startOn", wt2.startOn)
        nq.where("occ.time.weekstate=:weekstate", wt2.weekstate)
        nq.where("occ.activityId=:activityId", occ.activityId)
        nq.where("occ.app=:app", occ.app)
        val exists = entityDao.search(nq)
        var newOcc: Occupancy = null
        if (exists.isEmpty) {
          newOcc = new Occupancy
          newOcc.activityId = occ.activityId
          newOcc.activityType = occ.activityType
          newOcc.app = occ.app
          newOcc.room = occ.room
          newOcc.comments = "【调课】" + occ.comments
          newOcc.time.beginAt = occ.time.beginAt
          newOcc.time.endAt = occ.time.endAt
          newOcc.time.startOn = wt2.startOn
          newOcc.time.weekstate = wt2.weekstate
          newOcc.updatedAt = Instant.now
        }
        occ.time.weekstate = occ.time.weekstate ^ wt1.weekstate
        if (newOcc == null) entityDao.saveOrUpdate(occ)
        else entityDao.saveOrUpdate(occ, newOcc)
      }
    }
    redirect("search", "调整完成")
  }

  @mapping(value = "{id}/edit")
  def edit(@param("id") id: Long): View = {
    val apply = entityDao.get(classOf[RoomApply], id)
    put("apply", apply)
    put("time", apply.time.toApplyTime())
    val activityTypes = codeService.get(classOf[ActivityType]).sortBy(_.id)
    put("activityTypes", TreeMap.from(activityTypes.map(x => (x.id, x.name))))
    forward("updateForm")
  }

  def updateApply(): View = {
    val apply = entityDao.get(classOf[RoomApply], getLongId("apply"))
    apply.activity.activityType = entityDao.get(classOf[ActivityType], getIntId("apply.activity.activityType"))
    apply.activity.speaker = get("apply.activity.speaker", "--")
    apply.activity.name = get("apply.activity.name", "--")
    get("apply.applicant.mobile") foreach { mobile => apply.applicant.mobile = mobile }
    entityDao.saveOrUpdate(apply)
    businessLogger.info(s"调整了教室借用内容", apply.id, ActionContext.current.params)
    redirect("search", "更新成功")
  }
}
