[#ftl]
[@b.head/]
[@b.toolbar title="归口审核"]
	bar.addItem("代理借用","delegateApply()");
	function delegateApply(){
		bg.form.submit(document.searchRoomApplyApproveForm,'${b.url("delegate")}',"_blank");
	}
[/@]
<table class="indexpanel">
  <tr>
	<td class="index_view">
		[@b.form action="!search" theme="search" title="查询条件" name="searchRoomApplyApproveForm" target="contentDiv"]
			<tr>
				<td class="search-item">
				[@eams.semesterCalendar theme="xml" id="f_semester" label="学年学期" name="roomApply.semester.id" items=semesters value=semester /]
				</td>
			</tr>
			[@b.select items=usages label="roomApply.usage.name" name="roomApply.usage.id" empty="..."/]
			[@b.select label="校区" items=campuses empty="..." name="roomApply.campus.id"/]
			[@b.select label="多媒体" items={"1":"使用","0","不使用"} empty="..." name="roomApply.isMultimedia" class="formHidden"/]	
			[@b.textfield label="借用人" maxlength="20" name="roomApply.borrower.applicant"/]
			[@b.datepicker label="起始" readOnly="readOnly" id="dateBegin1" name="applyTime.dateBegin" format="yyyy-MM-dd" maxDate="#F{$dp.$D(\\'dateEnd1\\')}" style="width:61%"/]
			[@b.datepicker label="截止" readOnly="readOnly" id="dateEnd1" name="applyTime.dateEnd" format="yyyy-MM-dd" minDate="#F{$dp.$D(\\'dateBegin1\\')}" style="width:61%"/]
		[/@]
	</td>
	<td class="index_content">
		[@b.div id="contentDiv" href="!search?roomApply.semester.id=${semester.id}" /]
	</td>
  </tr>
</table>
[@b.foot/]