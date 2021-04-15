package org.openurp.edu.room.web.action

import org.beangle.commons.collection.Collections
import org.beangle.commons.lang.Strings
import org.beangle.commons.lang.time.WeekDay.WeekDay
import org.beangle.commons.lang.time.{WeekDay, WeekTime, WeekTimes}
import org.beangle.data.dao.OqlBuilder
import org.beangle.security.Securities
import org.beangle.webmvc.api.view.View
import org.beangle.webmvc.entity.action.RestfulAction
import org.openurp.base.edu.model.{CourseUnit, Semester, TimeSetting}
import org.openurp.base.model.{Campus, User}
import org.openurp.boot.edu.helper.ProjectSupport
import org.openurp.code.edu.model.ActivityType
import org.openurp.edu.clazz.service.CourseTableStyle
import org.openurp.edu.room.model.{ApplyDepartCheck, RoomApply, TimeRequest, WeekTimeBuilder}

import java.time.temporal.ChronoUnit
import java.time.{Instant, LocalDate, ZoneId}
import scala.collection.mutable


class RoomApplyAction extends RestfulAction[RoomApply] with ProjectSupport {

	override def indexSetting(): Unit = {
		put("campuses", findInSchool(classOf[Campus]))
		put("activityTypes", getCodes(classOf[ActivityType]))
		super.indexSetting()
	}

	override def editSetting(roomApply: RoomApply): Unit = {
		put("departments", getDeparts)
		put("campuses", findInSchool(classOf[Campus]))
		put("activityTypes", getCodes(classOf[ActivityType]))
		put("timeSettings", getTimeSettings)
		put("currentSemester", getCurrentSemester)
		roomApply.applyBy = getUser

		// 每个学期能够选择的教学周集合
		val semesterWeeks = Collections.newMap[Semester, mutable.Set[Int]]
		// 每个学期缺省的最大教学周
		val defaultMaxWeeks = Collections.newMap[Semester, Int]

		val applyAt = if (roomApply.applyAt == null) Instant.now else roomApply.applyAt
		val applyOn = LocalDate.ofInstant(applyAt, ZoneId.systemDefault())
		val semesters = getSemesters(applyOn)
		semesters.foreach(s => {
			val weekList = buildWeekList(s, null)
			if (applyOn.isBefore(s.endOn) && applyOn.isAfter(s.beginOn)) {
				val length = s.beginOn.until(applyOn, ChronoUnit.DAYS)
				val startWeek = Math.ceil(length / 7.0).toInt + 1
				val starts = Collections.newSet[Int]
				for (i <- 1 until startWeek) {
					starts.add(i)
				}
				weekList.--=(starts)
			}
			semesterWeeks.put(s, weekList)
			defaultMaxWeeks.put(s, getWeeks(s))
		})
		put("tableStyle", CourseTableStyle.WEEK_TABLE)
		put("CourseTableStyle", CourseTableStyle)
		put("weekList", WeekDay.values)
		put("semesterWeeks", semesterWeeks)
		put("defaultMaxWeeks", defaultMaxWeeks)
		super.editSetting(roomApply)
	}

	def getUser: User = {
		val users = entityDao.findBy(classOf[User], "code", List(Securities.user))
		if (users.isEmpty) {
			null
		} else {
			users.head
		}
	}

	def getTimeSettings: Seq[TimeSetting] = {
		val settingQuery = OqlBuilder.from(classOf[TimeSetting], "ts").where("ts.project=:project", getProject)
		entityDao.search(settingQuery)
	}

	def getWeeks(semester: Semester): Int = {
		val length = semester.beginOn.until(semester.endOn, ChronoUnit.DAYS)
		Math.ceil(length / 7.0).toInt
	}

	def buildWeekList(semester: Semester, next: Semester): mutable.Set[Int] = {
		val maxWeek = if (null != next) {
			val length = semester.beginOn.until(next.beginOn, ChronoUnit.DAYS)
			Math.ceil(length / 7.0).toInt
		} else {
			getWeeks(semester)
		}
		val weekList = Collections.newSet[Int]
		for (i <- 1 to maxWeek) {
			weekList.add(i)
		}
		weekList
	}

	def getSemesters(localDate: LocalDate): Seq[Semester] = {
		val builder = OqlBuilder.from(classOf[Semester], "semester")
		builder.where("semester.calendar.school=:school", getProject.school)
		builder.where("semester.endOn >=:now", localDate)
		builder.orderBy("semester.code desc")
		entityDao.search(builder)
	}

	def buildApply(): RoomApply = {
		val roomApply = populateEntity(classOf[RoomApply], "roomApply")
		val semester = entityDao.get(classOf[Semester], intId("semester"))
		val timeSetting = getTimeSettings.head
		get("weekState").foreach(weekState => {
			get("classUnit").foreach(classUnit => {
				val timeRequest = buildApplyTimeByWeekState(timeSetting, semester, weekState, classUnit)
				roomApply.time = timeRequest
			})
		})

		if (0 >= roomApply.space.unitAttendance) roomApply.space.unitAttendance = roomApply.activity.attendanceNum
		roomApply.time.calcMinutes()
		roomApply.applyAt = Instant.now()
		roomApply.applyBy = getUser
		roomApply.school = getUser.school
		roomApply.activity.attendance = "--"
		roomApply.activity.speaker = "--"
		roomApply
	}

	def buildApplyTimeByWeekState(timeSetting: TimeSetting, semester: Semester, state: String, courseUnitString: String): TimeRequest = {
		val weeks = Strings.splitToInt(state)
		val maxUnitSize = timeSetting.units.size
		val units = Strings.splitToInt(courseUnitString)
		val builder = WeekTimeBuilder.on(semester)
		var alltimes = Collections.newBuffer[WeekTime]
		val unitMap = entityDao.findBy(classOf[CourseUnit], "setting", List(timeSetting)).map(e => (e.indexno, e)).toMap

		units.indices.foreach(i => {
			val weekId = units(i) / maxUnitSize + 1
			val unitIndex = units(i) % maxUnitSize + 1
			val times = builder.build(WeekDay.apply(weekId).asInstanceOf[WeekDay], weeks)
			unitMap.get(unitIndex).foreach(unit => {
				times.foreach(time => {
					time.beginAt = unit.beginAt
					time.endAt = unit.endAt
				})
			})
			alltimes.addAll(times)
		})
		alltimes = WeekTimes.mergeTimes(alltimes)
		var beginOn: LocalDate = null
		var endOn: LocalDate = null
		alltimes.foreach(timeUnit => {
			if (null == beginOn || timeUnit.firstDay.isBefore(beginOn)) beginOn = timeUnit.firstDay
			if (null == endOn || timeUnit.lastDay.isAfter(endOn)) endOn = timeUnit.lastDay
		})
		val timeRequest = new TimeRequest
		timeRequest.times = alltimes
		timeRequest.beginOn = beginOn
		timeRequest.endOn = endOn
		timeRequest.timeComment = get("timeComment")
		timeRequest
	}


	def apply: View = {
		val roomApply = buildApply()
		if (roomApply.time.beginOn != null) {
			val now = LocalDate.now
			val applyOn = roomApply.time.beginOn
			val days = applyOn.toEpochDay - now.toEpochDay
			if (days < 2) {
				return redirect("search", "请至少提前两天申请教室!")
			}
		}
		val departCheck = roomApply.departCheck match {
			case Some(value) => value
			case None => new ApplyDepartCheck
		}
		departCheck.apply = roomApply
		departCheck.approved = true
		departCheck.checkedAt = Instant.now()
		departCheck.checkedBy = getUser
		saveOrUpdate(departCheck)
		roomApply.departCheck = Option(departCheck)
		try saveOrUpdate(roomApply)
		catch {
			case e: Exception =>
				logger.info("saveAndForwad failure", e)
				return redirect("search", "info.save.failure")
		}
		redirect("search", "info.save.success")
	}

}
