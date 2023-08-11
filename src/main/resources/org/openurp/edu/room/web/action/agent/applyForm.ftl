[@b.head/]
<script>
  function validateMobile(elem){
    return /^1(3[0-9]|4[01456879]|5[0-3,5-9]|6[2567]|7[0-8]|8[0-9]|9[0-3,5-9])\d{8}$/.test(jQuery(elem).val())
  }
  function checkMobile(elem){
    var row = jQuery(elem).parent();
    if(elem.value){
      if(!validateMobile(elem)){
        raiseValidateError(row,"请正确填写手机号");
      }else{
        row.find("label.error").remove();
      }
    }else{
      raiseValidateError(row,"请填写手机号");
    }
  }
  function raiseValidateError(row,msg){
    row.find("label.error").remove();
    row.append('<label class="error">'+msg+'</label>');
    return false;
  }
</script>
  [@b.toolbar title="教室代理借用"/]
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
    [@b.field label="经办人" required="true"]
      ${user.code} ${user.name} ${user.department.name}
    [/@]
    [@base.user name="applicant.id" required="true" label="借用人" params="&isStd=0" style="width:300px;" empty="..." comment="输入工号或姓名模糊查询"/]
    [@b.radios name="apply.space.requireMultimedia" items={'1':'需要使用','0':'不需要'} label="多媒体设备" value="1"/]
    [@b.radios name="apply.activity.activityType.id" items=activityTypes label="活动类型" value=activityType.id/]
    [@b.textfield name="apply.activity.name" label="活动名称" required="true"/]
    [@b.textfield name="apply.activity.speaker" label="主讲人" required="true" value="" comment="上课可填任课教师"/]
    [@b.textfield name="apply.activity.attendanceNum" label="出席人数" required="true" comment="容量${capacity}"/]
    [#if hasSmsSupport]
    [@b.cellphone name="apply.applicant.mobile" label="联系手机" required="true" comment="提交后发送提醒消息"/]
    [#else]
    [@b.cellphone name="apply.applicant.mobile" label="联系手机" required="true"/]
    [/#if]
    [@b.formfoot]
      [@b.submit value="提交"/]
    [/@]
  [/@]
