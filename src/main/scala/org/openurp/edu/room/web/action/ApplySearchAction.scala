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

import org.beangle.commons.lang.time.WeekTime
import org.beangle.data.dao.{Condition, Conditions, EntityDao, OqlBuilder}
import org.beangle.data.transfer.exporter.ExportContext
import org.beangle.template.freemarker.ProfileTemplateLoader
import org.beangle.web.action.annotation.param
import org.beangle.web.action.support.ActionSupport
import org.beangle.web.action.view.View
import org.beangle.webmvc.support.action.{EntityAction, ExportSupport}
import org.beangle.webmvc.support.helper.QueryHelper
import org.openurp.base.model.Campus
import org.openurp.base.resource.model.Classroom
import org.openurp.code.edu.model.{ActivityType, ClassroomType}
import org.openurp.code.service.CodeService
import org.openurp.edu.room.model.RoomApply
import org.openurp.edu.room.web.helper.RoomApplyPropertyExtractor

/** 借用查询
 */
class ApplySearchAction extends ActionSupport, EntityAction[RoomApply], ExportSupport[RoomApply] {

  var entityDao: EntityDao = _
  var codeService: CodeService = _

  def index(): View = {
    put("campuses", entityDao.getAll(classOf[Campus]))
    put("activityTypes", codeService.get(classOf[ActivityType]))
    put("roomTypes", codeService.get(classOf[ClassroomType]))
    forward()
  }

  def report(@param("id") id: String): View = {
    val apply = entityDao.get(classOf[RoomApply], id.toLong)
    put("roomApply", apply)
    ProfileTemplateLoader.setProfile(apply.school.id)
    forward("../report")
  }

  def search(): View = {
    put("roomApplies", entityDao.search(getQueryBuilder))
    forward()
  }

  override def getQueryBuilder: OqlBuilder[RoomApply] = {
    val query = super.getQueryBuilder
    query.where("roomApply.approved=true")
    val roomConditions = QueryHelper.extractConditions(classOf[Classroom], "room", null)
    if (roomConditions.nonEmpty) {
      val params = roomConditions.flatten(_.params)
      val con = new Condition(s"exists(from roomApply.rooms as room where ${Conditions.toQueryString(roomConditions)})").params(params)
      query.where(con)
    }
    getDate("occupyOn") foreach { occupyOn =>
      val wt = WeekTime.of(occupyOn)
      query.where("exists(from roomApply.time.times t where t.startOn=:starton and bitand(t.weekstate,:weekstate)>0)",
        wt.startOn, wt.weekstate)
    }
    query
  }

  protected override def configExport(context: ExportContext): Unit = {
    super.configExport(context)
    context.extractor = new RoomApplyPropertyExtractor()
  }
}
