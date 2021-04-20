[#ftl]
[@b.head/]
[@b.toolbar title="教室借用信息"]
[/@]
    <table class="infoTable" align="center" width="100%">
			<tr>
				<td class="title" align="right" width="15%" >&nbsp;借用人：</td>
				<td width="35%">${roomApply.borrower.applicant!}</td>
				<td class="title" align="right" width="15%">&nbsp;经办人姓名：</td>
				<td width="35%">${roomApply.applyBy.name} 填表申请时间：${roomApply.applyAt?string('yyyy-MM-dd HH:mm:ss')}</td>
			</tr>
			<tr>
				<td class="title">&nbsp;归口部门：</td>
				<td>${roomApply.borrower.department.name}</td>
				<td class="title" align="right" >&nbsp;联系方式：</td>
				<td>${roomApply.borrower.mobile!}</td>
			</tr>
			<tr>
				<td class="title">活动类型：</td>
				<td>${roomApply.activity.activityType.name}</td>
				<td class="title" align="right" >&nbsp; 活动名称：</td>
				<td colspan	="3">${roomApply.activity.name!}</td>
			</tr>
			<tr>
				<td class="title">&nbsp;借用校区：</td>
				<td>${(roomApply.space.campus.name)!}</td>
				<td class="title" align="right" >&nbsp;出席总人数：</td>
				<td>${roomApply.activity.attendanceNum}</td>
			</tr>
			<tr>
				<td class="title" align="right" >&nbsp;是否使用多媒体设备：</td>
				<td>${roomApply.space.requireMultimedia?string('是','否')}</td>
				<td class="title">其它要求：</td>
				<td>${(roomApply.space.roomComment)!}</td>
			</tr>
        [#assign dateBegin=(roomApply.time.beginOn)! /]
        [#assign dateEnd=(roomApply.time.endOn)! /]
			<tr>
				<td class="title"  align="right">&nbsp;使用日期：</td>
				<td colspan="3" ><span title="[#if dateBegin=dateEnd]${dateEnd}[#else]${dateBegin}~${dateEnd}[/#if]">${(roomApply.time)!}</span></td>
			</tr>
			<tr>
				<td class="title" align="right" >&nbsp;归口审核：</td>
				<td>${((roomApply.departCheck.approved)?string('通过','不通过'))!} [#if roomApply.departCheck?? && roomApply.departCheck.opinions??]<font color='red'>${(roomApply.departCheck.opinions)!}</font>[/#if]</td>
				<td class="title">分配审核：</td>
				<td>${((roomApply.finalCheck.approved)?string('通过','不通过'))!} [#if roomApply.finalCheck?? && roomApply.finalCheck.opinions??]<font color='red'>${(roomApply.finalCheck.opinions)!}</font>[/#if]</td>
			</tr>
    </table>

[#if roomApply.rooms?size>0]
<div align="center"><B>分配教室列表</B></div>
<table class="gridtable">
	<thead>
		<tr class="gridhead">
			<td width="10%">序号</td>
			<td width="25%">教室</td>
			<td width="25%">教学楼</td>
			<td width="25%">教室类型</td>
			<td width="15%">容量</td>
		</tr>
	</thead>
	<tbody align="center">
		[#list roomApply.rooms?sort_by("name") as room]
		<tr>
			<td>${room_index+1}</td>
			<td>${(room.name)!}</td>
			<td>${(room.building.name)!}</td>
			<td>${(room.roomType.name)!}</td>
			<td>${room.capacity}</td>
		</tr>
		[/#list]	
	</tbody>
</table>
[/#if]
[@b.foot/]
