[#ftl]
[@b.head/]
<style>
.limit_line {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
</style>
[@b.grid items=roomApplies var="roomApply"]
  [@b.gridbar]
    bar.addItem("${b.text('action.info')}", action.info());
    bar.addItem("${b.text('action.edit')}",action.edit());
    bar.addItem("审核分配", action.single('applySetting'), "update.png");
    bar.addItem("${b.text('action.delete')}", action.remove());
    bar.addItem("${b.text("action.export")}",action.exportData("activity.name:活动名称,activity.activityType.name:活动类型,"+
                "time:申请占用时间,rooms:借用教室,space.campus.name:借用校区,activity.attendanceNum:出席总人数,"+
                "space.requireMultimedia:是否使用多媒体设备,space.roomComment:教室要求,applicant.user.name:借用人,applicant.mobile:联系手机,"+
                "applyAt:提交申请时间,approvedAt:审核时间,applyBy.name:借用人",
    null,'fileName=教室借用信息'));
  [/@]
  [@b.row]
    [@b.boxcol/]
    [@b.col property="activity.name" title="活动名称"]
      [#if roomApply.approved!false]
      [@b.a href="!report?id=${roomApply.id}" title="流水${roomApply.id}" target="_blank"]${(roomApply.activity.name?html)!}[/@]
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
    [@b.col title="使用教室" width="18%"]
      [#if roomApply.rooms?size>0]
        [#list roomApply.rooms?if_exists as room]${(room.name)!}[#if room_has_next]&nbsp;[/#if][/#list]
      [#elseif roomApply.space.roomComment??]
        <span style="font-style: italic;">拟借:${roomApply.space.roomComment!}</span>
      [/#if]
    [/@]
    [@b.col property="applicant.user.department.name" title="借用人部门"  width="7%"]
      <div title="${roomApply.applicant.user.department.name}" class="limit_line">${(roomApply.applicant.user.department.shortName)!roomApply.applicant.user.department.name}</div>
    [/@]
    [@b.col property="applicant.user" sortable="false" title="经办(借用人)"  width="8%"]
      [#if ((roomApply.applyBy.name)!'')==((roomApply.applicant.user.name)!'')]${roomApply.applyBy.name}
      [#else]${(roomApply.applyBy.name)!}(${(roomApply.applicant.user.name)!})[/#if]
    [/@]
    [@b.col property="activity.speaker" title="主讲人" width="7%"/]
    [@b.col property="applyAt" title="日期"  width="6%"]${(roomApply.applyAt?string("yy-MM-dd"))?default("")}[/@]
    [@b.col property="approved" title="审核状态"  width="6%"]
      ${(roomApply.approved?string("通过","<font color='red'>不通过</font>"))?default("<font color='red'>待审</font>")}
    [/@]
  [/@]
[/@]
[@b.foot/]
