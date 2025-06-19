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

package org.openurp.edu.room.service

import org.beangle.commons.cdi.BindModule
import org.beangle.commons.codec.digest.Digests
import org.beangle.commons.io.{Dirs, IOs}
import org.beangle.ems.app.EmsApp
import org.openurp.edu.room.service.impl.{EcuplSmsServiceImpl, RoomApplyServiceImpl}

import java.io.{File, FileInputStream}

object DefaultModule extends BindModule {

  protected override def binding(): Unit = {
    bind(classOf[RoomApplyServiceImpl])

    EmsApp.getAppFile foreach { file =>
      val is = new FileInputStream(file)
      val app = scala.xml.XML.load(is)
      var base: String = null
      var appId: String = null
      var appPassword: String = null
      (app \\ "sms") foreach { e =>
        base = (e \ "@base").text.trim
        appId = (e \ "@appId").text.trim
        appPassword = (e \ "@appPassword").text.trim
      }
      is.close()
      if (base != null && null != appId && null != appPassword)
        bind(classOf[EcuplSmsServiceImpl]).constructor(base, appId, appPassword)
    }
  }
}
