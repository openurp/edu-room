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

package org.openurp.edu.room.service.impl

import org.beangle.commons.lang.{Charsets, Strings}
import org.beangle.commons.logging.Logging
import org.beangle.commons.net.http.{HttpMethods, HttpUtils}
import org.openurp.edu.room.service.SmsService

import java.io.OutputStreamWriter
import java.net.{URI, URLEncoder}
import java.nio.charset.Charset
import java.time.temporal.{ChronoUnit, TemporalUnit}
import java.time.{Duration, Instant}

class EcuplSmsServiceImpl(base: String, appId: String, appPassword: String) extends SmsService, Logging {

  var tokenInfo: (String, Instant) = _
  var tokenLiveTime = 600 //600s

  def fetchToken(): Option[String] = {
    val now = Instant.now
    if (null == tokenInfo || Math.abs(Duration.between(tokenInfo._2, now).get(ChronoUnit.SECONDS)) >= tokenLiveTime) {
      val tokenRes = HttpUtils.getText(s"${base}/msg/getThirdAPIToken?appId=${appId}&appPassword=${appPassword}")
      if (tokenRes.isOk && tokenRes.getText.contains("000000")) {
        val token = Strings.substringBetween(tokenRes.getText, "\"token\":\"", "\"")
        if (Strings.isNotEmpty(token)) {
          this.tokenInfo = (token, Instant.now)
          Some(token)
        } else None
      } else None
    } else {
      Some(tokenInfo._1)
    }
  }

  override def send(content: String, receivers: (String, String)*): Option[String] = {
    fetchToken() match
      case Some(token) =>
        val postUrl = s"${base}/message/sendMessageBySMSApi"
        val receiverContacts = receivers.map(x => s"{\"name\": \"${URLEncoder.encode(x._2, Charsets.UTF_8)}\",\"mobile\":\"${x._1}\"}").mkString(",")
        //FIXME Using HttpUtils.invoke
        val res = HttpUtils.getText(URI.create(postUrl).toURL, HttpMethods.POST, Charsets.UTF_8, Some({ conn =>
          conn.setDoOutput(true)
          conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded")
          val writer = new OutputStreamWriter(conn.getOutputStream)
          val formData = s"""token=${token}&msgContent=${URLEncoder.encode(content, Charsets.UTF_8)}&receivers=[${receiverContacts}]"""
          writer.write(formData)
          writer.close()
        }))
        if (res.isOk) {
          val restext = res.getText
          Some(Strings.substringBetween(restext, "\"msgId\":\"", "\""))
        } else {
          logger.error("sms error:" + res.getText + "(receivers:" + receivers.toString() + " msg:" + content + ")")
          None
        }
      case None =>
        logger.error("Cannot get invoke token")
        None
  }

}
