[#ftl]
[@b.head/]
[@b.grid items=roomApplies var="roomApply"]
  [@b.gridbar]
    bar.addItem("${b.text("action.export")}",action.exportData("activity.name:活动名称,activity.activityType.name:活动类型,"+
                "time:申请占用时间,rooms:借用教室,space.campus.name:借用校区,activity.attendanceNum:出席总人数,"+
                "space.requireMultimedia:是否使用多媒体设备,applicant.user.name:借用人,applicant.mobile:联系手机,"+
                "applyAt:提交申请时间,approvedAt:审核时间",
    null,'fileName=教室借用信息'));
  [/@]
  [@b.row]
    [@b.boxcol/]
    [@b.col property="activity.name" title="活动名称"]
      [@b.a href="!report?id=${roomApply.id}" title="流水${roomApply.id}" target="_blank"]${(roomApply.activity.name?html)!}[/@]
    [/@]
    [@b.col property="activity.activityType.name" title="活动类型" width="5%" sortable="false"/]
    [@b.col title="借用时间" width="19%"]<span>${(roomApply.time)!}</span>[/@]
    [@b.col title="使用教室" width="18%"]
        [#list roomApply.rooms as room]${(room.name)!}[#if room_has_next]&nbsp;[/#if][/#list]
    [/@]
    [@b.col property="applicant.user.department.name" title="借用人部门"  width="10%"]
      <div title="${roomApply.applicant.user.department.name}" class="text-ellipsis">${(roomApply.applicant.user.department.shortName)!roomApply.applicant.user.department.name}</div>
    [/@]
    [@b.col property="applicant.user" sortable="false" title="经办(借用人)"  width="12%"]
      [#if ((roomApply.applyBy.name)!'')==((roomApply.applicant.user.name)!'')]${roomApply.applyBy.name}
      [#else]${(roomApply.applyBy.name)!}(${(roomApply.applicant.user.name)!})[/#if]
    [/@]
    [@b.col property="approved" title="多媒体设备"  width="7%"]
      ${roomApply.space.requireMultimedia?string("需要使用","不需要")}
    [/@]
    [@b.col property="applyAt" title="日期"  width="6%"]${(roomApply.applyAt?string("yy-MM-dd"))?default("")}[/@]
  [/@]
[/@]
[@b.foot/]
