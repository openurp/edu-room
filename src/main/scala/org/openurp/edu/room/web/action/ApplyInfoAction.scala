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

import org.beangle.commons.lang.Numbers
import org.beangle.data.dao.Query.Lang.OQL
import org.beangle.data.dao.{EntityDao, OqlBuilder}
import org.beangle.template.api.DynaProfile
import org.beangle.template.freemarker.ProfileTemplateLoader
import org.beangle.webmvc.annotation.{mapping, param}
import org.beangle.webmvc.support.ActionSupport
import org.beangle.webmvc.view.{Status, View}
import org.openurp.edu.room.model.RoomApply

/** 展示教室申请的凭证页面，公开的。
 */
class ApplyInfoAction extends ActionSupport {
  var entityDao: EntityDao = _

  @mapping("{id}")
  def index(@param("id") id: String): View = {
    if (Numbers.isDigits(id)) {
      val query = OqlBuilder.from(classOf[RoomApply], "r")
      query.where("r.id=:id", id.toLong)
      entityDao.search(query).headOption match
        case Some(apply) =>
          if (apply.rooms.nonEmpty) {
            put("roomApply", apply)
            DynaProfile.set(apply.school.id)
            forward("../report")
          } else {
            Status.NotFound
          }
        case None => Status.NotFound
    } else {
      Status.NotFound
    }
  }
}
