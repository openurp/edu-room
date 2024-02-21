[@b.head/]
  [@b.toolbar title="修改教室借用申请"/]
  [@b.form name="roomSearchForm" action="!updateApply" theme="list"]
[#assign applyCycle=time.cycle/]
    [#assign applyCount=(time.applyCount>1)?string("2","1")/]
    [@b.radios name="applyCount" items={'1':'单次借用','2':'多次借用'} label="借用次数" value="1" onclick="showApplyRange(this);" value=applyCount/]
    [@b.field label="借用日期" required="true"]
      <input type="text" title="起始日期" readOnly="readOnly" id="beginOn" name="time.beginOn" class="Wdate" [#if time.beginOn??]value="${time.beginOn}"[/#if]
           onFocus="WdatePicker({dateFmt:'yyyy-MM-dd'})" maxlength="10" style="width:120px" placeholder="YYYY-MM-DD"/>
      <div id="dateRangeZone" [#if applyCount=="1"]style="display:none"[#else]style="display:inline"[/#if]> ~
        <input type="text" title="结束日期" readOnly="readOnly" id="endOn" name="time.endOn" class="Wdate" [#if time.endOn??]value="${time.endOn}"[/#if]
                   onFocus="WdatePicker({dateFmt:'yyyy-MM-dd',minDate:'#F{$dp.$D(\'beginOn\')}'})" maxlength="10" style="width:120px" placeholder="YYYY-MM-DD"/>
        <input name="time.cycle" value="1" type="radio" [#if applyCycle=1]checked="checked"[/#if] id="cycle1"><label for="cycle1" style="font-weight:normal;">每天</label>
        <input name="time.cycle" value="7" type="radio" [#if applyCycle=7]checked="checked"[/#if] id="cycle7"><label for="cycle7" style="font-weight:normal;">每周</label>
        <input name="time.cycle" value="14" type="radio"[#if applyCycle=14]checked="checked"[/#if] id="cycle14"><label for="cycle14" style="font-weight:normal;">每两周</label>
      </div>
    [/@]
    [@b.field label="借用时间" required="true"]
      <div id="timeRangeZone" style="display:inline">
        <input type="text" title="起始时间" name="time.beginAt" id="beginAt" style='width:70px' class="Wdate" value="${time.beginAt}"
             onFocus="WdatePicker({dateFmt:'HH:mm',maxDate:'#F{$dp.$D(\'endAt\')}'})" placeholder="HH:mm"/>
      - <input type="text" title="结束时间" name="time.endAt"  id="endAt" style='width:70px' class="Wdate" value="${time.endAt}"
          onFocus="WdatePicker({dateFmt:'HH:mm',minDate:'#F{$dp.$D(\'beginAt\')}'})" maxlength="5" placeholder="HH:mm"/>
      </div>
    [/@]
    [#if apply.approved][@b.field label="注意事项"]<div style="color:red">如果修改时间，提交后，系统会引导至审核分配界面。</div>[/@][/#if]
    [@b.field label="拟借教室"][#list apply.rooms as r]${r.name}[#sep],[/#list]&nbsp;[/@]
    [@b.radios name="apply.activity.activityType.id" items=activityTypes label="活动类型" value=apply.activity.activityType.id/]
    [@b.textfield name="apply.activity.name" label="活动名称" value=(apply.activity.name)! required="true" style="width:300px"/]
    [@b.textfield name="apply.activity.speaker" label="主讲人" required="true" value=(apply.activity.speaker)! comment="上课可填任课教师"/]
    [@b.cellphone name="apply.applicant.mobile" required="true" label="联系手机" value=(apply.applicant.mobile)! /]
    [@b.formfoot]
      <input name="apply.id" value="${apply.id}" type="hidden"/>
      [@b.submit value="提交"/]
    [/@]
  [/@]
  <script>
  function showApplyRange(ele){
    var hidden = jQuery(ele).val()=='1';
    if(hidden) jQuery("#dateRangeZone").hide();
    else {
      jQuery('#dateRangeZone').css("display","inline");
    }
  }
  </script>
[@b.foot/]
