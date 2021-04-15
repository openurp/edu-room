[#ftl]
[@b.head/]
[#--[#include "/template/macros.ftl"/]--]
<script language="JavaScript" type="text/JavaScript" src="${base}/static/scripts/StringUtils.js"></script>
<script language="JavaScript" type="text/JavaScript">
 	var unitArray = new Array();
	var weekArray = new Array();
</script>
[@b.form action="!apply" name="roomApplyForm" target="contentDiv"]
	<input type="hidden" name="roomApply.id" value="${(roomApply.id)!}"/>
    <table class="formTable" align="center" width="100%">
        <input name="roomIds" type="hidden" value=""/>
        <input name="classUnit" id="classUnit" type="hidden" value=""/>
        <input name="weekState" id="weekState" type="hidden" value=""/>
        <tr class="thead" align="center">
            <td colspan="4"><B>教室借用代理申请表</B></td>
        </tr>
        <tr>
        	<td class="title" align="right" width="15%" id="f_applicant"><font color="red">*</font>&nbsp;借用人：</td>
            <td width="35%"><input type="text" title="借用人" name="roomApply.borrower.applicant" maxlength="20" value="${(roomApply.borrower.applicant)!}" /></td>
        	<td class="title" align="right" width="15%"><font color="red">*</font>&nbsp;经办人姓名：</td>
        	<td width="35%"><input type="hidden" name="roomApply.applyBy.id" value="${(roomApply.applyBy.id)!}"/>${(roomApply.applyBy.name?html)!} 填表申请时间：${b.now?string('MM-dd HH:mm')}</td>
        </tr>
        <tr>
        	<td class="title"><font color="red">*</font>&nbsp;归口部门：</td>
        	<td>[@b.select empty="..." items=departments?sort_by("name") name="roomApply.borrower.department.id" value=(roomApply.borrower.department)! label=""/]</td>
        	<td class="title" align="right" id="f_mobile"><font color="red">*</font>&nbsp;联系方式：</td>
			<td><input type="text" name="roomApply.borrower.mobile" size="15" maxlength="20" value="${(roomApply.borrower.mobile)!}"/></td>
        </tr>
        <tr>
        	<td class="title" id="f_activityType" >借用用途：</td>
        	<td>
    		[#list activityTypes as activityType]
				<input type="radio" id="activityType${activityType.id}" name="roomApply.activity.activityType.id" [#if ((roomApply.activity.activityType.id)?? && roomApply.activity.activityType.id==activityType.id) || (!(roomApply.activity.activityType.id)?? && activityType_index==0)]checked[/#if] value="${activityType.id}"/><label for="activityType${activityType.id}">${(activityType.name?html)!}</label>&nbsp;&nbsp;
			[/#list]
        	</td>
        	<td class="title" align="right" id="f_name"><font color="red">*</font>&nbsp;说明：</td>
        	<td colspan	="3"><input type="text" title="说明" name="roomApply.activity.name" maxlength="50" value="${(roomApply.activity.name)!}"/></td>
        </tr>
        <tr>
        	<td class="title" id="f_campus"><font color="red">*</font>&nbsp;借用校区：</td>
        	<td>
        		[#if campuses?size>1]
        		[@b.select items=campuses name="roomApply.space.campus.id" style="width:200px" empty="..." value=(roomApply.space.campus)! label=""/]
        		[#else]
        		[@b.select items=campuses name="roomApply.space.campus.id" style="width:200px" value=(roomApply.space.campus)! label=""/]
        		[/#if]
        	</td>
        	<td class="title" align="right" id="f_attendance"><font color="red">*</font>&nbsp;出席总人数：</td>
        	<td><input type="text" name="roomApply.activity.attendanceNum" title="出席总人数" maxlength="5" value="${(roomApply.activity.attendanceNum)!}" style="width:50px"/>
        		每个教室人数:<input type="text" name="roomApply.space.unitAttendance" maxlength="5" value="${(roomApply.space.unitAttendance)!}" style="width:50px"/>
        	</td>
        </tr>
        <tr>
        	<td class="title" align="right" id="f_isMultimedia"><font color="red">*</font>&nbsp;是否使用多媒体设备：</td>
        	<td>
        		<input type="radio" id="isMultimedia1" name="roomApply.space.requireMultimedia" value="1" [#if ((roomApply.space.requireMultimedia)!true)]checked[/#if]/><label for="isMultimedia1">&nbsp;使用&nbsp;</label>
        		<input type="radio" id="isMultimedia2" name="roomApply.space.requireMultimedia" value="0" [#if !((roomApply.space.requireMultimedia)!true)]checked[/#if]/><label for="isMultimedia2">&nbsp;不使用</label>
        	</td>
        	<td class="title">其它要求：</td>
        	<td><input name="roomApply.space.roomComment"   maxlength="50" value="${(roomApply.space.roomComment)!}"/></td>
        </tr>

  		<tr>
			<td class="title" align="right" id="f_weekState"><font color="red">*</font>&nbsp;教学周：</td>
			<td colspan="3">
				<select style="width:170px" id="semesterSelect" name="semester.id" >
					[#list semesterWeeks?keys?sort_by("code")?reverse as s]
						<option value="${s.id}" [#if currentSemester==s]selected[/#if]>${s.schoolYear}学年${s.name}学期</option>
					[/#list]
				</select>
				<input type="text" id="beginWeek" name="beginWeek" value="1" style="width:50px"/>~<input type="text" id="endWeek" name="endWeek" value="" style="width:50px"/>
				<select id="cycle" style="width:50px">
					<option value="">...</option>
					<option value="0">连续周</option>
					<option value="1">单周</option>
					<option value="2">双周</option>
				</select>
				<input type="button" title="小节" id="selectReverse" value="反选" style="width:50px"/>
				<input type="hidden" id="h_unit"/>
				<br/>
				<div id="weekZone"></div>
				<input type="hidden" id="h_week"/>
			</td>
        <tr>
            [#assign timeSetting = timeSettings?first/]
        <tr>
            <td class="title" align="right" id="f_weekState"><font color="red">*</font>&nbsp;节次：</td>
	        <td colspan="3">
			  	[#assign unitList=timeSetting.units/]
			  	[#include "../courseTableStyle.ftl"/]
				[@initCourseTable tableStyle,unitList,weekList/]
	        </td>
        </tr>
        <tr class="thead">
            <td colspan="5" align="center">
	        [#if !(roomApply.isApproved!false)]
            <input type="button" [#if activityTypes?size==0 || departments?size==0]disabled="true"[/#if] onClick="apply()" value="申请"/>&nbsp;&nbsp;<input type="button" onClick="this.form.reset()" value="重填"/>
					[#else]申请已经批准，无法修改。
            [/#if]
            </td>
        </tr>
    </table>
[/@]
[#macro drawWeek weeks]
	[#list weeks as week][#t]
		<input id="weekId${week}" name="weekIdState" class="weekCheck ui-helper-hidden-accessible" type="checkbox" value="${week}">[#t]
		<label id="weekLabel${week}" name="weekState" style="cursor:pointer;background:white;color:black" class="ui-widget ui-state-default" role="button" onclick="toggleMe(this)" >[#t]
			<span style="padding:2px 4px 2px 4px">${week}</span>[#t]
		</label>[#t]
	[/#list]
[/#macro]
<script language="JavaScript">
  beangle.load(["jquery-validity"]);
	var unitsPerDay=${(unitList?size)?default(0)};
    var unitsPerWeek=${(unitList?size*weekList?size)?default(0)};
	var weekLists={};
	[#list semesterWeeks?keys as s]
	weekLists['s${s.id}']='[@drawWeek semesterWeeks.get(s)/]'
	[/#list]
	var defaultMaxWeeks={};
	[#list defaultMaxWeeks?keys as s]
	defaultMaxWeeks['s${s.id}']=${defaultMaxWeeks.get(s)}
	[/#list]
	var defaultMinWeeks={};
	[#list semesterWeeks?keys as s]
	defaultMinWeeks['s${s.id}']=${semesterWeeks.get(s)?first}
	[/#list]

	jQuery("#weekZone").html(weekLists['s${currentSemester.id}']);
	jQuery("#beginWeek").val(defaultMinWeeks['s${currentSemester.id}']);
	jQuery("#endWeek").val(defaultMaxWeeks['s${currentSemester.id}']);

    function apply() {
		jQuery.validity.start();
 		var form = document.roomApplyForm;
 		var strUnit = "";
 		var strWeek = "";
    	for(var i = 0; i< unitsPerWeek - 1; i ++) {
    		if(document.getElementById("TD"+i).style.backgroundColor=='yellow'){
    			strUnit += i +",";
    		}
    	}
        jQuery(".weekCheck").each(function(i){
   			if(jQuery(this).prop("checked")){
   				strWeek += jQuery(this).val() + ",";
   			}
   		});
   	jQuery("#h_unit").assert(function(){
   		return strUnit != "";
   		},"没有选择小节");
   	jQuery("#h_week").assert(function(){
   		return strWeek != "";
   		},"没有选择教学周");
   	jQuery("input[name='roomApply.borrower.applicant']").require().match('notBlank');
			jQuery("input[name='roomApply.borrower.mobile']").require().match('notBlank');
   	jQuery("select[name='roomApply.campus.id']").require();
   	jQuery("select[name='roomApply.auditDepart.id']").require();
   	// jQuery("input[name='roomApply.activity.name']").require().match('notBlank');
   	jQuery("input[name='roomApply.activity.attendance']").require().match('notBlank').match('integer');
		if(jQuery.validity.end().valid) {
			$("#weekState").val(strWeek);
		 	$("#classUnit").val(strUnit);
	   	bg.form.submit(form);
		}
    }

	function toggleMe(lbe){
		var me =jQuery(lbe)
		if(me.hasClass('ui-state-active')){
        	me.removeClass("ui-state-active").addClass("ui-state-default").css("background","white").prev().prop("checked",false);
        }else{
			me.removeClass("ui-state-default").addClass("ui-state-active").css("background","yellow").prev().prop("checked",true);
		}
	}

	function toggle(obj){
		jQuery(obj).prop("checked",true).next("label").removeClass("ui-state-default").addClass("ui-state-active").css("background","yellow");
	}
	function clearToggle(obj){
		jQuery(obj).prop("checked",false).next("label").removeClass("ui-state-active").addClass("ui-state-default").css("background","white").css("color","blank");
	}

	jQuery("#cycle").change(function(){
		var beginWeek=parseInt($('#beginWeek').val());
		var endWeek=parseInt($('#endWeek').val());
		if(beginWeek>endWeek || beginWeek<0) {alert("周区间错误!");return;}
		switch(parseInt(jQuery(this).val())){
	   		case 0:
	   			jQuery(".weekCheck").each(function(index,e){
	   				w=e.value;
	   				if(w<=endWeek && w >=beginWeek) toggle(this)
	   				else clearToggle(this)
	   			})
	     		break;
		   	case 1://单周
		   		jQuery(".weekCheck").each(function(index,e){
		   			w=e.value;
		   			if(w%2==1 && (w<=endWeek && w>=beginWeek))toggle(this)
		   			else clearToggle(this)
		   		})
				break;
		   	case 2://双周
		   		jQuery(".weekCheck").each(function(index,e){
		   			w=e.value;
		   			if(w%2==0 && (w<=endWeek && w>=beginWeek)) toggle(this)
		   			else clearToggle(this)
		   		})
		   }
	});
	jQuery("#semesterSelect").change(function(){
		var semesterId='s'+jQuery(this).val();
		jQuery("#weekZone").html(weekLists[semesterId]);
		var beginWeek=parseInt($('#beginWeek').val());
		if(beginWeek<defaultMinWeeks[semesterId]){
			beginWeek=defaultMinWeeks[semesterId];
			jQuery("#beginWeek").val(defaultMinWeeks[semesterId]);
		}
		var endWeek=parseInt($('#endWeek').val());
		if(endWeek>defaultMaxWeeks[semesterId])	{
			endWeek=defaultMaxWeeks[semesterId];
			jQuery("#endWeek").val(defaultMaxWeeks[semesterId]);
		}
		if(beginWeek>endWeek)jQuery("#beginWeek").val(endWeek);
		jQuery("#cycle").change();
	});

	jQuery("#selectReverse").click(function(){
		var beginWeek=parseInt($('#beginWeek').val());
		var endWeek=parseInt($('#endWeek').val());
		if(beginWeek>endWeek || beginWeek<0) {alert("周区间错误!");return;}
		jQuery(".weekCheck").each(function(index,e){
			i=e.value;
			if(i<=endWeek && i >=beginWeek){
				if(jQuery(this).prop("checked")) clearToggle(this)
				else toggle(this)
			}else{
				clearToggle(this)
			}
   		})
	});
	[#if roomApply.applyTime??]
	[#list roomApply.applyTime.weeks as w]
	toggleMe(document.getElementById('weekLabel${w}'));
	[/#list]

	[#list roomApply.applyTime.units as u]
	selectUnit(${u.timeUnit.weekday},${u.startUnit},${u.endUnit});
	[/#list]
	[/#if]

	$(function(){
		jQuery("select[name='roomApply.campus.id']").attr("title","借用校区");
		jQuery("select[name='roomApply.auditDepart.id']").attr("title","归口部门");
	})
</script>
[@b.foot/]