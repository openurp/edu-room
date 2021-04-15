[#ftl]
[@b.head/]
[#--[#include "/template/print.ftl" /]--]
[@b.toolbar title="教室借用凭条"]
	bar.addPrint();
	bar.addBackOrClose();
[/@]
<style>
	.tableStyle { font-size:15px; border-collapse:collapse; width:100% }
	.tableStyle td { border: solid #000 1px; height:30px}
	.tableStyle .title { border: solid #000 1px; }
</style>
[#list applies as roomApply]
<h2 align="center"><B>${project.school.name}教室借用凭条</B></h2>
<table class="tableStyle">
    <tr>
    	<td class="title" width="12%" >借用人</td>
        <td width="20%">${roomApply.borrower.applicant!}</td>
        <td class="title" width="13%">借用单位</td>
		<td width="21%">${roomApply.borrower.department.name}</td>
    	<td class="title" width="13%">联系方式</td>
		<td width="21%">${(roomApply.borrower.mobile)!}</td>
	</tr>
	<tr>
    	<td class="title">教学楼</td>
    	[#assign buildings =[]]
    	[#list roomApply.rooms as room]
    	[#if room.building?? && !buildings?seq_contains(room.building)][#assign buildings=buildings+[room.building]][/#if]
    	[/#list]
    	<td>[#list buildings as building]${(building.name)!}[#if building_has_next]&nbsp;[/#if][/#list]</td>
    	<td class="title" >借用教室</td>
    	<td colspan="3">[#list roomApply.rooms?if_exists as room]${(room.name)!}[#if room_has_next][/#if][/#list]</td>
    </tr>
    	<td class="title" >活动类型</td>
    	<td>${roomApply.activity.activityType.name}</td>
    	<td class="title" >活动名称</td>
    	<td>${roomApply.activity.name}</td>
    	<td class="title">活动时间</td>
    	<td>
				[#assign dateBegin=(roomApply.time.beginOn)! /]
				[#assign dateEnd=(roomApply.time.endOn)! /]
				<span title="[#if dateBegin=dateEnd]${dateEnd}[#else]${dateBegin}~${dateEnd}[/#if]">${(roomApply.time)!}</span>
    	</td>
    </tr>
    <tr>
    	<td class="title">审核员</td>
    	<td colspan="2">${roomApply.finalCheck.checkedBy.name!}</td>
    	<td class="title" >审核日期</td>
    	<td colspan="2">${(roomApply.finalCheck.checkedAt?string('yyyy-MM-dd'))!}</td>
    </tr>
    <tr>
    	<td align="center" colspan="6">物业反映情况</td>
    </tr>
    <tr>
        <td>活动<br/>是否属实</td><td> 是/否</td>
        <td>课桌椅<br/>是否复位</td><td> 是/否</td>
        <td>多媒体设备<br/>是否正常</td><td> 是/否</td>
    </tr>
    <tr>
    	<td >其他情况</td>
    	<td colspan="5"></td>
    </tr>
</table>

<table style="font-size:15px; border-collapse:collapse; width:100% ">
	<tr>
    	<td colspan="6">&nbsp;</td>
    </tr>
    <tr>
    	<td width="12%" ></td>
    	<td width="20%" ></td>
    	<td width="13%" ></td>
    	<td width="41%" colspan="2" align="center">${project.school.name} &nbsp;教务处</td>
    	<td width="13%" ></td>
    </tr>
    <tr>
    	<td ></td>
    	<td ></td>
    	<td ></td>
    	<td colspan="2" align="center">${b.now?string('yyyy-MM-dd')}</td>
    	<td ></td>
    </tr>
</table>

<br/><br/><br/>
[/#list]
[@b.foot/]
