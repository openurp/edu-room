[#ftl]
[@b.head/]
[@b.toolbar title="教室借用信息"]
	bar.addClose();
	bar.addPrint();
[/@]
[#list applies as roomApply]
    <table class="infoTable" align="center" width="100%">
        <tr>
        	<td class="title" align="right" width="15%" ><font color="red">*</font>&nbsp;借用人：</td>
            <td width="35%">${roomApply.borrower.applicant!}</td>
        	<td class="title" align="right" width="15%"><font color="red">*</font>&nbsp;经办人姓名：</td>
        	<td width="35%">${roomApply.user.fullname} 填表申请时间：${roomApply.updatedAt?string('yyyy-MM-dd HH:mm:ss')}</td>
        </tr>
        <tr>
        	<td class="title"><font color="red">*</font>&nbsp;归口部门：</td>
        	<td>${roomApply.auditDepart.name}</td>
        	<td class="title" align="right" >&nbsp;联系方式：</td>
			<td>${roomApply.borrower.mobile!}</td>
        </tr>
		<tr>
        	<td class="title"  >${b.text('roomApply.usage.name')}：</td>
        	<td>${roomApply.usage.name}</td>
        	<td class="title" align="right" ><font color="red">*</font>&nbsp;${b.text('roomApply.activity.name')}：</td>
        	<td colspan	="3">${roomApply.activity.name!}</td>
        </tr>
        <tr>
        	<td class="title"><font color="red">*</font>&nbsp;借用校区：</td>
        	<td>${(roomApply.campus.name)!}</td>
        	<td class="title" align="right" ><font color="red">*</font>&nbsp;出席总人数：</td>
        	<td>${roomApply.activity.attendance}</td>
        </tr>
        <tr>
        	<td class="title" align="right" ><font color="red">*</font>&nbsp;是否使用多媒体设备：</td>
        	<td>${roomApply.isMultimedia?string('是','否')}</td>
        	<td class="title">其它要求：</td>
        	<td>${roomApply.roomRequest!}</td>
        </tr>
        <tr>
            <td class="title"  align="right"><font color="red">*</font>&nbsp;使用日期：</td>
            <td colspan="3" >${roomApply.applyTime}  约${roomApply.hours}小时</td>
        </tr>
        <tr>
        	<td class="title" align="right" ><font color="red">*</font>&nbsp;归口审核：</td>
        	<td>${((roomApply.isDepartApproved)?string('通过','不通过'))!}</td>
        	<td class="title">分配审核：</td>
        	<td>${((roomApply.isApproved)?string('通过','不通过'))!}</td>
        </tr>
        <tr>
            <td class="title"  align="right">&nbsp;分配教室：</td>
            <td colspan="3" >[#list roomApply.rooms?if_exists as room]${(room.name)!}[#if room_has_next]&nbsp;[/#if][/#list]</td>
        </tr>
    </table>
    [#if roomApply_has_next]<div style="PAGE-BREAK-AFTER: always"></div>[/#if]
[/#list]
[@b.foot/]
