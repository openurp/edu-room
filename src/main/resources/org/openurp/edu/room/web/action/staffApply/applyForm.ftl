[@b.head/]
  [@b.toolbar title="教室借用申请"/]
  [#assign capacity = 0/]
  [#list classrooms as r]
    [#assign capacity = r.courseCapacity + capacity /]
  [/#list]
  [@b.form name="roomSearchForm" action="!saveApply" theme="list"]
    [@b.field label="借用时间" required="true"]
      ${time}
      <input name="time.beginOn" type="hidden" value="${time.beginOn?string('yyyy-MM-dd')}"/>
      <input name="time.endOn" type="hidden" value="${time.endOn?string('yyyy-MM-dd')}"/>
      <input name="time.beginAt" type="hidden" value="${time.beginAt}"/>
      <input name="time.endAt" type="hidden" value="${time.endAt}"/>
      <input name="time.cycle" type="hidden" value="${time.cycle}"/>
    [/@]
    [@b.field label="拟借教室" required="true"]
      <input name="classroomIds" value="[#list classrooms as r]${r.id}[#sep],[/#list]" type="hidden">
      <input name="apply.space.roomComment" value="[#list classrooms as r]${r.name}[#sep],[/#list]" type="hidden">
      [#list classrooms?sort_by('name') as r]${r.name}[#sep],[/#list]
    [/@]
    [@b.field label="借用人" required="true"]
      ${applicant.code} ${applicant.name} ${applicant.department.name}
    [/@]
    [#assign requireMultimedia=((apply.space.requireMultimedia)!true)?string("1","0")/]
    [@b.radios name="apply.space.requireMultimedia" items={'1':'需要使用','0':'不需要'} label="多媒体设备" value=requireMultimedia/]
    [@b.radios name="apply.activity.activityType.id" items=activityTypes label="活动类型" value=activityType.id/]
    [@b.textfield name="apply.activity.name" label="活动名称" required="true" value=(apply.activity.name)!/]
    [@b.textfield name="apply.activity.speaker" label="主讲人" required="true" value=speaker comment="上课可填任课教师" style="width:300px"/]
    [@b.textfield name="apply.activity.attendanceNum" label="出席人数" value=(apply.activity.attendanceNum)! required="true" comment="容量${capacity}"/]
    [@b.textfield name="apply.space.unitAttendance" value=unitAttendance label="最小教室容量" required="true" comment="0表示不要求"/]
    [@b.cellphone name="apply.applicant.mobile" required="true" label="联系手机" value=applicant.mobile!]
      <br><input type='checkbox' name='saveMobile' id='saveMobile' ><label style='font-weight: normal;' for='saveMobile'>保存为常用号码</label>
      [#if hasSmsSupport](申请通过后，该号码收到审批提醒，查看凭证)[/#if]
    [/@]
    [@b.formfoot]
      [#if apply??]
        <input type="hidden" name="apply.id" value="${apply.id}"/>
      [/#if]
      [@b.submit value="提交"/]
    [/@]
  [/@]
[@b.foot/]
