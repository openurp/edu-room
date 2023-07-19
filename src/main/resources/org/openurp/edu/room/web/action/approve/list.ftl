[#ftl]
[@b.head/]
[@b.grid items=roomApplies var="roomApply"]
  [@b.gridbar]
    bar.addItem("${b.text('action.info')}", action.info());
    bar.addItem("审核分配", action.single('applySetting'), "update.png");
    //bar.addItem("${b.text('action.edit')}",  action.single('editApply'));
    bar.addItem("${b.text('action.delete')}", action.remove());
    bar.addItem("${b.text("action.export")}",action.exportData("activity.name:活动名称,activity.activityType.name:活动类型,activity.speaker:主讲人及内容,activity.attendance:出席对象,activity.attendanceNum:出席总人数,space.campus.name:借用校区,space.roomComment:其他要求,applicant.user:借用人,applyAt:提交申请时间,time:申请占用时间,departCheck.approved:归口审核,departCheck.checkedBy.name:归口审核人,departCheck.checkedAt:归口审核时间,finalCheck.approved:物管审核,finalCheck.checkedBy.name:物管审核人,finalCheck.checkedAt:物管审核时间,space.requireMultimedia:是否使用多媒体设备",
    null,'fileName=教室借用信息'));
  [/@]
  [@b.row]
    [@b.boxcol width="5%"/]
    [@b.col property="activity.name" title="活动名称"]
      [#if roomApply.approved!false]
      [@b.a href="!report?roomApplyIds=${roomApply.id}" title="流水${roomApply.id}" target="_blank"]${(roomApply.activity.name?html)!}[/@]
      [#else]
      [@b.a href="!info?id=${roomApply.id}" title="流水${roomApply.id}"]${(roomApply.activity.name?html)!}[/@]
      [/#if]
    [/@]
    [@b.col property="activity.activityType.name" title="活动类型" width="5%" sortable="false"/]
    [#if roomApply??]
      [#assign dateBegin=(roomApply.time.beginOn)! /]
      [#assign dateEnd=(roomApply.time.endOn)! /]
    [/#if]
    [@b.col title="借用时间" width="19%"]<span title="[#if dateBegin=dateEnd]${dateEnd}[#else]${dateBegin}~${dateEnd}[/#if]">${(roomApply.time)!}</span>[/@]
    [@b.col title="使用教室" width="19%"]
      [#if roomApply.rooms?size>0]
        [#list roomApply.rooms?if_exists as room]${(room.name)!}[#if room_has_next]&nbsp;[/#if][/#list]
      [#elseif roomApply.space.roomComment??]
        <span style="font-style: italic;">拟借:${roomApply.space.roomComment!}</span>
      [/#if]
    [/@]
    [@b.col property="applicant.user" sortable="false" title="经办(借用人)"  width="12%"]
      [#if ((roomApply.applyBy.name)!'')==((roomApply.applicant.user.name)!'')]${roomApply.applyBy.name}
      [#else]${(roomApply.applyBy.name)!}(${(roomApply.applicant.user.name)!})[/#if]
    [/@]
    [@b.col property="applyAt" title="日期"  width="6%"]${(roomApply.applyAt?string("yy-MM-dd"))?default("")}[/@]
    [@b.col property="approved" title="状态"  width="7%"]
      ${(roomApply.approved?string("审核通过","<font color='red'>审核不通过</font>"))?default("<font color='red'>待审核</font>")}
    [/@]
  [/@]
[/@]
[@b.foot/]
