<script>
  function validateMobile(elem){
    return /^1(3[0-9]|4[01456879]|5[0-3,5-9]|6[2567]|7[0-8]|8[0-9]|9[0-3,5-9])\d{8}$/.test(jQuery(elem).val())
  }
</script>
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
    [@b.radios name="apply.space.requireMultimedia" items={'1':'需要使用','0':'不需要'} label="多媒体设备" value="1"/]
    [@b.radios name="apply.activity.activityType.id" items=activityTypes label="活动类型" value=activityType.id/]
    [@b.textfield name="apply.activity.name" label="活动名称" required="true"/]
    [@b.textfield name="apply.activity.attendanceNum" label="出席人数" required="true" comment="容量${capacity}"/]
    [@b.textfield name="apply.applicant.mobile" label="联系手机" required="true" check="assert(validateMobile, '请填写正确的手机号码')"/]
    [@b.formfoot]
      [@b.submit value="提交"/]
    [/@]
  [/@]
