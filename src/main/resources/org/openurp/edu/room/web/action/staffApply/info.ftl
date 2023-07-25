[#ftl]
[@b.head/]
[@b.toolbar title="教室申请信息"]
  bar.addBack();
  [#if ((roomApply.approved)!false)]bar.addItem("打印","bg.form.submit(document.actionForm)","print.png");[/#if]
[/@]
<table class="infoTable" align="center" width="100%">
  <tr>
    <td class="title"  width="15%" >&nbsp;借用人：</td>
        <td width="35%">${roomApply.applicant.user.code} ${roomApply.applicant.user.name} ${roomApply.applicant.user.department.name!}</td>
    <td class="title"  width="15%">&nbsp;经办人姓名：</td>
    <td width="35%">${roomApply.applyBy.name} 填表申请时间：${roomApply.applyAt?string('yyyy-MM-dd HH:mm:ss')}</td>
  </tr>
    <tr>
        <td class="title">&nbsp;审核部门：</td>
      <td>${roomApply.applicant.auditDepart.name}</td>
      <td class="title">&nbsp;联系方式：</td>
      <td>${roomApply.applicant.mobile!}</td>
    </tr>
    <tr>
      <td class="title">活动类型：</td>
      <td>${roomApply.activity.activityType.name}</td>
      <td class="title">&nbsp; 活动名称：</td>
      <td colspan  ="3">${roomApply.activity.name!}</td>
    </tr>
    <tr>
      <td class="title">&nbsp;主讲人：</td>
      <td>${(roomApply.activity.speaker)!}</td>
      <td class="title">&nbsp;出席对象：</td>
      <td>${roomApply.activity.attendance!}</td>
    </tr>
    <tr>
      <td class="title">&nbsp;借用校区：</td>
      <td>${(roomApply.space.campus.name)!}</td>
      <td class="title">&nbsp;出席总人数：</td>
      <td>${roomApply.activity.attendanceNum}</td>
    </tr>
    <tr>
      <td class="title">&nbsp;是否使用多媒体设备：</td>
      <td>${roomApply.space.requireMultimedia?string('是','否')}</td>
      <td class="title">其它要求：</td>
      <td>${(roomApply.space.roomComment)!}</td>
    </tr>
    [#assign dateBegin=(roomApply.time.beginOn)! /]
    [#assign dateEnd=(roomApply.time.endOn)! /]
      <tr>
        <td class="title">&nbsp;使用日期：</td>
        <td><span title="[#if dateBegin=dateEnd]${dateEnd}[#else]${dateBegin}~${dateEnd}[/#if]">${(roomApply.time)!}</span></td>
        <td class="title" >&nbsp;审核结果：</td>
        <td style="color:red">
          [#if roomApply.approved??]
            ${((roomApply.approved)?string('审核通过','审核不通过'))!}
          [#else]
            [#if roomApply.departApproved??]
              ${((roomApply.departApproved)?string('部门审核通过','部门审核不通过'))!}
            [#else]
              未审核
            [/#if]
          [/#if]
        </td>
      </tr>
    <tr>
      <td class="title">分配教室列表：</td>
      <td colspan="3">[#list roomApply.rooms?sort_by("name") as r]
       [@b.a target="_blank" href="occupancy!building?id="+((r.building.id)!0) +"&classroomId="+r.id + "&beginOn="+roomApply.time.beginOn]
          ${r.name}
       [/@]
      [#sep],[/#list]</td>
    </tr>
    [#if roomApplyLogs?size>0]
    <tr>
      <td class="title">审核日志：</td>
      <td colspan="3">
      [#list roomApplyLogs?sort_by("auditAt") as r]
          ${r.auditAt?string('yyyy-MM-dd HH:mm:ss')} ${r.opinions!'--'} ${r.approved?string("通过","不通过")}
      [#sep]<br>[/#list]
      </td>
    </tr>
    [/#if]
</table>
[@b.form name="actionForm" action="!report?id="+roomApply.id target="_blank"/]
[@b.foot/]
