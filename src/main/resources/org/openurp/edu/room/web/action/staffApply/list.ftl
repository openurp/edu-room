[#ftl]
[@b.head/]
[@b.form name="roomApplyListForm" action="!search"]
[@b.grid items=roomApplies var="roomApply" filterable="true"]
  [@b.gridbar]
    bar.addItem("${b.text('action.edit')}",action.edit());
    bar.addItem("${b.text('action.info')}",action.info());
    bar.addItem("${b.text('action.delete')}",action.remove());
  [/@]
  [@b.row]
    [@b.boxcol/]
    [@b.col property="activity.name" title="活动名称"]
      [#if roomApply.approved!false]
        [@b.a href="!report?id=${roomApply.id}" target="_blank"]${(roomApply.activity.name)?default("")}[/@]
      [#else]
        [@b.a href="!info?id=${roomApply.id}"]${(roomApply.activity.name)?default("")}[/@]
      [/#if]
    [/@]
    [@b.col property="activity.activityType.name" title="活动类型" width="7%"/]
    [#if roomApply??]
    [#assign dateBegin=(roomApply.time.beginOn)! /]
    [#assign dateEnd=(roomApply.time.endOn)! /]
    [/#if]
    [@b.col title="借用时间" width="23%"]<span title="[#if dateBegin=dateEnd]${dateEnd}[#else]${dateBegin}~${dateEnd}[/#if]">${(roomApply.time)!}</span>[/@]
    [@b.col title="使用教室" width="22%" property="roomName" sortable="false"]
      [#if roomApply.rooms?? && roomApply.rooms?size>0]
      [#list roomApply.rooms?if_exists as room]${(room.name)!}[#if room_has_next]&nbsp;[/#if][/#list]
      [@b.a href="!report?id=${roomApply.id}" target="_blank"]凭证&#8599;[/@]
      [#else]
      <font color="red">
      [#if roomApply.approved??]${roomApply.approved?string('审核通过','审核不通过')}
      [#else]待审核[/#if]
      </font>
      [/#if]
    [/@]
    [@b.col property="space.campus.name" title="校区" width="6%"/]
    [@b.col property="activity.speaker" title="主讲人" width="7%"/]
    [@b.col property="activity.attendanceNum" title="人数" width="5%"/]
    [@b.col property="applyAt" title="申请时间" width="5%" filterable="false"]${(roomApply.applyAt?string("MM-dd"))?default("")}[/@]
  [/@]
 [/@]

[/@]
