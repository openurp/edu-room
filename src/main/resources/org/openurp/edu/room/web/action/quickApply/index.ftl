[#ftl]
[@b.head/]
[@b.toolbar title="查看空闲教室"/]
    [#if alert??]<font color="red">请至少提前两天申请教室!</font>[/#if]
    [@b.form action="!search" name="actionForm" target="freeRoomList"]
      <table class="formTable" align="center" width="95%">
          <tr class="thead" align="center">
            <td colspan="4"><B>空闲教室查询</B></td>
          </tr>
          <tr>
              <td class="title">教室类型名称：</td>
              <td>
                [@b.select style="width:130px" label="" items=roomTypes name="room.roomType.id" empty="..."/]
              </td>
           <td class="title">校区：</td>
           <td>
             [@b.select style="width:130px" id="campus" label="" items=campuses name="room.campus.id" empty="..."/]
               </td>
        </tr>
        <tr>
            <td  class="title">教学楼：</td>
            <td >
              [@b.select style="width:130px" label="" items={} id="building" name="room.building.id" empty="..."/]
           </td>
              <td class="title" id="f_seats">教室容量(≥)：</td>
              <td><input name="seats" title="教室容量" maxlength="8" style="width:100px"/></td>
        </tr>
        <tr>
              <td class="title">教室名称：</td>
              <td><input name="room.name" maxlength="10" style="width:100px"/></td>
              <td class="title" id="f_cycleCount" align="right"><font color="red">*</font>时间周期：</td>
              <td>每&nbsp;<input type="text" title="时间周期" name="cycleTime.cycleCount" style="width:20px" value="1" maxlength="2"/>
                  [@b.select items={"1":"天","2":"周"} name="cycleTime.cycleType" value="1" label="" /]
              </td>
          </tr>
          <tr>
              <td class="title" id="f_begin_end" align="right"><font color="red">*</font>教室使用日期：</td>
              <td>
              <input type="text" title="起始日期" readOnly="readOnly" id="beginOn" name="cycleTime.beginOn" class="Wdate" onFocus="WdatePicker({dateFmt:'yyyy-MM-dd',maxDate:'#F{$dp.$D(\'endOn\')}'})" maxlength="10" style="width:120px"/>
              - <input type="text" title="结束日期" readOnly="readOnly" id="endOn" name="cycleTime.endOn" class="Wdate" onFocus="WdatePicker({dateFmt:'yyyy-MM-dd',minDate:'#F{$dp.$D(\'beginOn\')}'})" maxlength="10" style="width:120px"/>
              (年月日)
              </td>
             <td class="title" id="f_beginTime_endTime" align="right">
               <font color="red">*</font>教室使用时间</select>
             </td>
              <td id="roomApplyTimeTypeTd">
                 <input type="text" title="起始时间" name="timeBegin" id="timeBegin" style='width:70px' value="" class="Wdate" onFocus="WdatePicker({dateFmt:'HH:mm',maxDate:'#F{$dp.$D(\'timeEnd\')}'})" format="Time"  maxlength="5"/>
                 - <input type="text" title="结束时间" name="timeEnd"  id="timeEnd" value="" style='width:70px' class="Wdate" onFocus="WdatePicker({dateFmt:'HH:mm',minDate:'#F{$dp.$D(\'timeBegin\')}'})" maxlength="5"/> (时:分)
              </td>
          </tr>
          <tr class="thead">
              <td colspan="4" align="center">
                <input type="button" onClick="searchFreeApply()" value="查询"/>&nbsp;&nbsp;
                <input type="button" onClick="resetForm()" value="重置"/>
              </td>
          </tr>
      </table>
    [/@]
    [@b.div id="freeRoomList" style="width:95%;margin:0 auto;border:0.5px solid #006CB2"/]
    <script language="JavaScript">
      beangle.load(["my97","jquery-validity"]);

      jQuery(document).ready(function(){
        jQuery("#campus").change(function(){
          var res = jQuery.post("${b.url('!campusBuilding')}",{campusId:jQuery(this).val()},function(){
          if(res.status==200){
            if(res.responseText!=""){
              jQuery("#building").empty().append("<option value=''>...</option>").append(res.responseText);
              var a = jQuery("#building");
            }
          }
        },"text");
        })
      })

      function searchFreeApply(){
        jQuery.validity.start();
        var form = document.actionForm;
        jQuery("input[name='seats']").match('integer');
        jQuery("input[name='cycleTime.beginOn']").require().match('notBlank').match(/^\d{1,4}[\/-]((0?\d)|(1[012]))[\/-]([012]?\d|30|31)$/);
        jQuery("input[name='cycleTime.endOn']").require().match('notBlank').match(/^\d{1,4}[\/-]((0?\d)|(1[012]))[\/-]([012]?\d|30|31)$/);
        jQuery("input[name='timeBegin']").require();
        jQuery("input[name='timeEnd']").require();
        jQuery("input[name='cycleTime.cycleCount']").require().match('notBlank').match('integer').greaterThan(0);
        if(jQuery.validity.end().valid) {
         bg.form.submit(form);
        }
      }

      function resetForm(){
        var form = document.actionForm;
        jQuery("#building").empty().append("<option value=''>...</option>");
        form.reset();
      }
    </script>
[@b.foot/]
