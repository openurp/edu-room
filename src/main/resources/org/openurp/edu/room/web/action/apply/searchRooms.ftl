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
                   onFocus="WdatePicker({dateFmt:'yyyy-MM-dd'})" maxlength="10" style="width:120px" placeholder="YYYY-MM-DD"/>
        每
        <select name="time.cycle" style="width:50px">
          <option value="1">天</option>
          <option value="7">周</option>
        </select>
        </div>
    [/@]
    [@b.field label="借用时间" required="true"]
      <input type="text" title="起始时间" name="time.beginAt" id="beginAt" style='width:70px' value="" class="Wdate"
             onFocus="WdatePicker({dateFmt:'HH:mm',maxDate:'#F{$dp.$D(\'endAt\')}'})" format="Time"  maxlength="5" placeholder="HH:mm"/>
         - <input type="text" title="结束时间" name="time.endAt"  id="endAt" value="" style='width:70px' class="Wdate"
          onFocus="WdatePicker({dateFmt:'HH:mm',minDate:'#F{$dp.$D(\'beginAt\')}'})" maxlength="5" placeholder="HH:mm"/>
    [/@]
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
         }
      }
    }
    dateRow.find("label:last-child").remove();
    if(!form['time.beginAt'].value){
      return addError(timeRow,'请填写起始时间');
    }
    timeRow.find("label:last-child").remove();
    if(!form['time.endAt'].value){
      return addError(timeRow,'请填写结束时间');
    }
    timeRow.find("label:last-child").remove();
    return true;
  }
  function addError(row,msg){
    row.find("label:last-child").remove();
    row.append('<label class="error">'+msg+'</label>');
    return false;
  }
  </script>
    [#if alert??]<font color="red">请至少提前两天申请教室!</font>[/#if]
  [@b.div id="freeRoomList"/]

[@b.foot/]
