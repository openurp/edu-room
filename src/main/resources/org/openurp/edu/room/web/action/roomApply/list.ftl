[#ftl]
[@b.head/]
[@b.grid items=roomApplies var="roomApply"]
	[@b.gridbar]
[#--		bar.addItem("教室申请",action.add());--]
		bar.addItem("${b.text('action.edit')}",action.edit());
		bar.addItem("${b.text('action.delete')}",action.remove());
	[/@]
	[@b.row]
		[@b.boxcol width="5%"/]
		[@b.col property="activity.name" title="活动名称" width="18%"]
			[@b.a href="!info?id=${roomApply.id}"]${(roomApply.activity.name)?default("")}[/@]
		[/@]
		[@b.col property="activity.activityType.name" title="活动类型" width="7%"/]
		[#if roomApply??]
		[#assign dateBegin=(roomApply.time.beginOn)! /]
		[#assign dateEnd=(roomApply.time.endOn)! /]
		[/#if]
		[@b.col title="借用时间" width="20%"]<span title="[#if dateBegin=dateEnd]${dateEnd}[#else]${dateBegin}~${dateEnd}[/#if]">${(roomApply.time)!}</span>[/@]
		[@b.col title="使用教室" width="20%"]
			[#if roomApply.rooms?? && roomApply.rooms?size>0]
			[#list roomApply.rooms?if_exists as room]${(room.name)!}[#if room_has_next]&nbsp;[/#if][/#list]
			[#else]
			<font color="red">
			[#if roomApply.isApproved??]${roomApply.isApproved?string('审核通过','审核不通过')}
			[#else]待审核[/#if]
			</font>
			[/#if]
		[/@]
		[@b.col property="space.campus.name" title="校区" width="5%"/]
		[@b.col property="borrower.applicant" title="借用人" width="10%"/]
		[@b.col property="activity.attendanceNum" title="人数" width="5%"/]
		[@b.col property="applyAt" title="申请时间" width="10%"]${(roomApply.applyAt?string("yyyy-MM-dd HH:mm"))?default("")}[/@]
	[/@]
 [/@]