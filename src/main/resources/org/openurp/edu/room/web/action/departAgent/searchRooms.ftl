[#ftl]
[@b.head/]
  [@b.toolbar title="查看空闲教室"/]
  [@b.form name="roomSearchForm" action="!freeRooms" theme="list" target="freeRoomList"]
    [@b.radios name="applyCount" items={'1':'单次借用','2':'多次借用'} label="借用次数" value="1" onclick="showApplyRange(this);"/]
    [@b.field label="借用日期" required="true"]
        <input type="text" title="起始日期" readOnly="readOnly" id="beginOn" name="time.beginOn" class="Wdate"
           onFocus="WdatePicker({dateFmt:'yyyy-MM-dd',minDate:'${beginOn?string('yyyy-MM-dd')}'})" maxlength="10" style="width:120px" placeholder="YYYY-MM-DD"/>
        <div id="dateRangeZone" style="display:none"> ~
        <input type="text" title="结束日期" readOnly="readOnly" id="endOn" name="time.endOn" class="Wdate"
                   onFocus="WdatePicker({dateFmt:'yyyy-MM-dd',minDate:'#F{$dp.$D(\'beginOn\')}'})" maxlength="10" style="width:120px" placeholder="YYYY-MM-DD"/>
        <input name="time.cycle" value="1" type="radio" checked="checked"  id="cycle1"><label for="cycle1" style="font-weight:normal;">每天</label>
        <input name="time.cycle" value="7" type="radio" id="cycle7"><label for="cycle7" style="font-weight:normal;">每周</label>
        <input name="time.cycle" value="14" type="radio" id="cycle14"><label for="cycle14" style="font-weight:normal;">每两周</label>
        </div>
    [/@]
    [@b.field label="借用时间" required="true"]
      [#if timeSettings?size >0][#assign timeSetting= timeSettings?first][/#if]
      [#if timeSetting??]
      <input name="timeSettingStyle" value="0" type="radio" checked="checked" onclick="selectTimeStyle(this)" id="style0">
      <label for="style0" style="font-weight:normal;">自定义</label>
      <input name="timeSettingStyle" value="1" type="radio" onclick="selectTimeStyle(this)" id="style1">
      <label for="style1" style="font-weight:normal;">按节次</label>
      [/#if]
      <div id="timeRangeZone" style="display:inline">
      <input type="text" title="起始时间" name="time.beginAt" id="beginAt" style='width:70px' value="" class="Wdate"
             onFocus="WdatePicker({dateFmt:'HH:mm',maxDate:'#F{$dp.$D(\'endAt\')}'})"  placeholder="HH:mm"/>
         - <input type="text" title="结束时间" name="time.endAt"  id="endAt" value="" style='width:70px' class="Wdate"
          onFocus="WdatePicker({dateFmt:'HH:mm',minDate:'#F{$dp.$D(\'beginAt\')}'})" maxlength="5" placeholder="HH:mm"/>
      </div>
    [/@]

    [#if timeSetting??]
    [@b.field label="可选节次" style="display:none"]
      <div id="unitRangeZone" style="display:inline">
        <div class="btn-group btn-group-toggle" data-toggle="buttons" style="height: 1.5625rem;font-size:0.8125rem !important;">
            [#assign dayPartId=0/]
            [#list timeSetting.units as u]
            <label style="font-weight:normal;padding:0px 1px 0px 1px;[#if u.part.id!=dayPartId][#assign dayPartId=u.part.id/]margin-left:5px[/#if]"
                   class="btn btn-outline-secondary btn-sm" title="${u.beginAt}~${u.endAt}">
            <input type="checkbox" name="unit" id="unit_${u.id}" value="${u.indexno}" onclick="toggleUnit(this)">${u.name}
            </label>
            [/#list]
        </div>
      </div>
    [/@]
    [/#if]

    [@b.select name="room.roomType.id" items=roomTypes label="教室类型" comment="以下条件，无要求可忽略"/]
    [@b.select name="room.building.id" items=buildings label="教学楼"/]
    [@b.textfield name="room.name" label="教室名称"/]
    [@b.number name="room.capacity" label="教室容量(≥)"/]
    [@b.field label="拟借教室"]
      <span id="classroomIdspan">查询后选择</span>
    [/@]
    [@b.formfoot]
      <button class="btn btn-outline-primary btn-sm" onclick="if(validateTime(this.form)){bg.form.submit('roomSearchForm');}return false;">查询空闲教室</button>
      [@b.submit value="填写申请" id="applySubmitBtn" action="!applyForm" onsubmit="cleanFormTarget()" style="display:none"/]
    [/@]
  [/@]
  <script>
  beangle.load(["my97"]);
  var selectRooms = new Map();
  function collectRooms(){
    var template='<input name="classroomIds" value="{ids}" type="hidden">{names} &nbsp;共计{cnt}座位'
    var cnt=0;
    var ids=',';
    var names='&nbsp';
    selectRooms.forEach(function(room){
       ids += (room.id+",");
       names += (room.name+"&nbsp;");
       cnt+=room.capacity;
    });
    template=template.replace("{ids}",ids);
    template=template.replace("{names}",names);
    template=template.replace("{cnt}",cnt);
    document.getElementById('classroomIdspan').innerHTML=template;
    if(cnt>0){
      jQuery('#applySubmitBtn').show();
    }else{
      jQuery('#applySubmitBtn').hide();
    }
  }
  function cleanFormTarget(){
    document.roomSearchForm.target="";
    return true;
  }
  function showApplyRange(ele){
    var hidden = jQuery(ele).val()=='1';
    if(hidden) jQuery("#dateRangeZone").hide();
    else {
      jQuery('#dateRangeZone').css("display","inline");
    }
  }
  function validateTime(form){
    var dateRow = jQuery(form['time.beginOn']).parent();
    var timeRow = jQuery(form['time.beginAt']).parent();
    if(!form['time.beginOn'].value){
      return addError(dateRow,'请填写起始日期');
    }else{
      if(document.roomSearchForm['applyCount'].value=='2'){
         if(!form['time.endOn'].value){
           return addError(dateRow,'请填写结束日期');
         }else{
            if(form['time.endOn'].value < form['time.beginOn'].value){
              return addError(dateRow,'结束日期应晚于开始日期');
            }
         }
      }
    }

    dateRow.find("label.error").remove();
    if(!form['time.beginAt'].value){
      return addError(timeRow,'请填写起始时间');
    }
    timeRow.find("label.error").remove();
    if(!form['time.endAt'].value){
      return addError(timeRow,'请填写结束时间');
    }
    timeRow.find("label.error").remove();
    return true;
  }
  function addError(row,msg){
    row.find("label.error").remove();
    row.append('<label class="error">'+msg+'</label>');
    return false;
  }

  [#if timeSetting??]
  function selectTimeStyle(ele){
    if(ele.value=='0'){
      jQuery("#unitRangeZone").parent().hide()
      jQuery("[name='time\.beginAt']").attr("readonly",false)
      jQuery("[name='time\.endAt']").attr("readonly",false)
    }else{
      jQuery("[name='time\.beginAt']").attr("readonly",true)
      jQuery("[name='time\.endAt']").attr("readonly",true)
      jQuery("#unitRangeZone").parent().show()
    }
  }

  var units=[[#list timeSetting.units as u]{'id':'${u.id}','beginAt':'${u.beginAt}','endAt':'${u.endAt}','indexno':${u.indexno}}[#sep],[/#list]];
  var bIdx=null;
  var eIdx=null;
  function toggleUnit(elem){
    var cur = parseInt(elem.value);
    if(jQuery(elem).prop("checked")){
      if(!bIdx && !eIdx){
        bIdx = cur;
        eIdx = cur;
      }else{
        if(cur < bIdx){
          toggleUnitRange(cur,bIdx-1,true);
          bIdx = cur;
        }else if(cur>eIdx){
          toggleUnitRange(eIdx+1,cur,true);
          eIdx = cur;
        }
      }
    }else{
      if(cur == bIdx){
        if(bIdx == eIdx){
          bIdx=null;eIdx=null;
        }else{
          toggleUnitRange(bIdx,eIdx-1,false);
          bIdx=eIdx;
        }
      }else if(cur>bIdx && cur<eIdx){
        if(cur-bIdx >= eIdx-cur){
          toggleUnitRange(cur+1,eIdx,false);
          eIdx=cur-1;
        }else{
          toggleUnitRange(bIdx,cur-1,false);
          bIdx=cur+1;
        }
      }else if(cur==eIdx){
        if(bIdx == eIdx){
          bIdx=null;eIdx=null;
        }else{
          toggleUnitRange(bIdx+1,eIdx,false);
          eIdx=bIdx;
        }
      }
    }
    fillTime(bIdx,eIdx);
  }

  function fillTime(bIdx,eIdx){
    if(bIdx){
      for(i =0;i<units.length;i++){
        if(bIdx == units[i].indexno){
          jQuery("[name='time\.beginAt']").val(units[i].beginAt);
        }
        if(eIdx == units[i].indexno){
          jQuery("[name='time\.endAt']").val(units[i].endAt);
        }
      }
    }else{
      jQuery("[name='time\.beginAt']").val("");
      jQuery("[name='time\.endAt']").val("");
    }
  }
  function toggleUnitRange(begin,end,active){
    if(begin>end) return;
    for(i =0;i<units.length;i++){
      if(begin <= units[i].indexno  && units[i].indexno<= end){
        var selector='#unit_'+units[i].id;
        if(active){
          if(!jQuery(selector).prop("checked")){
            jQuery(selector).prop("checked",true);
            jQuery(selector).parent().addClass("active")
          }
        }else{
          if(jQuery(selector).prop("checked")){
            jQuery(selector).prop("checked",false);
            jQuery(selector).parent().removeClass("active")
          }
        }
      }
    }
  }
  [/#if]
  </script>
    [#if alert??]<font color="red">请至少提前两天申请教室!</font>[/#if]
  [@b.div id="freeRoomList"/]

[@b.foot/]
