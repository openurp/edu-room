[#ftl]
[@b.head/]
${b.script("my97","WdatePicker.js")}
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
	           	<font color="red">*</font><select id="roomApplyTimeType" name="roomApplyTimeType"><option value="1" selected>教室使用时间：</option><option value="0">教室使用小节：</option></select>
	           </td>
            	<td id="roomApplyTimeTypeTd"><input type="text" title="起始时间" name="timeBegin" style='width:50px' value="00:00" format="Time"  maxlength="5"/> - <input type="text" title="结束时间" name="timeEnd" value="00:00" style='width:50px' maxlength="5"/> (时:分)&nbsp;&nbsp&nbsp;&nbsp&nbsp;&nbsp&nbsp;&nbsp</td>
	        </tr>
	        <tr class="thead">
	            <td colspan="4" align="center">
		            <input type="button" onClick="searchFreeApply()" value="查询"/>&nbsp;&nbsp;
		            <input type="button" onClick="resetForm()" value="重置"/>
	            </td>
	        </tr>
    	</table>
    [/@]
    [@b.div id="freeRoomList" style="width:95%;margin:0 auto;"/]
    <script language="JavaScript">
      beangle.load(["jquery-validity"]);

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

    		jQuery("#roomApplyTimeType").change(function(){
	    		if(jQuery(this).val()=="1"){
	    			jQuery("#roomApplyTimeTypeTd").html("<input type='text' title='起始时间' name='timeBegin' style='width:40px' value='00:00' format='Time'  maxlength='5'/> - <input type='text' title='结束时间' name='timeEnd' value='00:00' maxlength='5' style='width:40px'/> (时:分)&nbsp;&nbsp&nbsp;&nbsp&nbsp;&nbsp&nbsp;&nbsp");
	    		}else{
	    			jQuery("#roomApplyTimeTypeTd").html("<input type='text' title='起始小节' name='timeBegin' style='width:25px' value='1' maxlength='5'/> - <input type='text' name='timeEnd' title='结束小节' value='1' style='width:25px' maxlength='5'/> [#if maxUnitSize??](最大小节数为${maxUnitSize})[/#if]");
	    		}
	    	})
    	})

    	function searchFreeApply(){
			jQuery.validity.start();
    		var form = document.actionForm;
    		var beginOn = form["cycleTime.beginOn"].value;
        	var endOn = form["cycleTime.endOn"].value;
        	var cycleCount = parseInt(form["cycleTime.cycleCount"].value,10);
        	var beginYear = parseInt(beginOn.substr(0, 4),10);
        	var beginMonth = parseInt(beginOn.substr(5, 2),10);
        	var beginDate = parseInt(beginOn.substr(8, 2),10);
        	var date1 = new Date(beginYear, beginMonth - 1, beginDate);
        	var endYear = parseInt(endOn.substr(0, 4),10);
        	var endMonth = parseInt(endOn.substr(5, 2),10);
        	var endDate = parseInt(endOn.substr(8, 2),10);
        	var date2 = new Date(endYear, endMonth - 1, endDate);
        	var tmp;
		 	if (form["cycleTime.cycleType"].value == "2") {
    			tmp = new Date(date1.getFullYear(), date1.getMonth(), date1.getDate() + (7 * cycleCount));
    		} else if (form["cycleTime.cycleType"].value == "1") {
    			tmp = new Date(date1.getFullYear(), date1.getMonth() , date1.getDate() + cycleCount - 1);
    		}
    		jQuery("input[name='cycleTime.beginOn']").require().match('notBlank').match(/^\d{1,4}[\/-]((0?\d)|(1[012]))[\/-]([012]?\d|30|31)$/);
    		jQuery("input[name='cycleTime.endOn']").require().match('notBlank').match(/^\d{1,4}[\/-]((0?\d)|(1[012]))[\/-]([012]?\d|30|31)$/).assert(function(){
	    			return tmp <= date2;
	    		},"借用日期与时间周期不匹配。");
    		jQuery("input[name='seats']").match('integer');
    		jQuery("input[name='cycleTime.cycleCount']").require().match('notBlank').match('integer').greaterThan(0);
        	if(jQuery("#roomApplyTimeType").val()=="1"){
        		jQuery("input[name='timeBegin']").require().match('notBlank').match('time24');
        		jQuery("input[name='timeEnd']").require().match('notBlank').match('time24').assert(function(){
		 			if(null == jQuery("input[name='timeEnd']").val() || null == jQuery("input[name='timeBegin']")){
		 				return true;
		 			}
		 			return parseInt(jQuery("input[name='timeBegin']").val(),10) < parseInt(jQuery("input[name='timeEnd']").val(),10);
		 		},"开始时间需小于结束时间");
        	} else{
        		jQuery("input[name='timeBegin']").require().match('notBlank').match('integer').greaterThan(0);
        		jQuery("input[name='timeEnd']").require().match('notBlank').match('integer').range(1,${maxUnitSize!(12)}).assert(function(){
		 			if(null == jQuery("input[name='timeEnd']").val() || null == jQuery("input[name='timeBegin']")){
		 				return true;
		 			}
		 			return parseInt(jQuery("input[name='timeBegin']").val(),10) <= parseInt(jQuery("input[name='timeEnd']").val(),10);
		 		},"开始小节需不大于结束小节");
	        }
     		if(jQuery.validity.end().valid) {
		   	bg.form.submit(form);
			}
    	}
    	
    	function resetForm(){
    		var form = document.actionForm;
    		jQuery("#building").empty().append("<option value=''>...</option>");
			jQuery("#roomApplyTimeTypeTd").html("<input type='text' name='timeBegin' style='width:40px' value='00:00' format='Time'  maxlength='5'/> - <input type='text' name='timeEnd' value='00:00' maxlength='5' style='width:40px'/> (时:分)&nbsp;&nbsp&nbsp;&nbsp&nbsp;&nbsp&nbsp;&nbsp;");
    		form.reset();
    	}
    </script>
[@b.foot/]