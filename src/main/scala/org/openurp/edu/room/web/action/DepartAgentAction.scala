package org.openurp.edu.room.web.action

import org.beangle.web.action.view.View
import org.openurp.base.model.Project
import org.openurp.starter.web.support.ProjectSupport

import java.time.Instant

class DepartAgentAction extends AgentAction, ProjectSupport {

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
}
