[#ftl]
[@b.head/]
[@b.toolbar title="教室借用信息"/]
<div class="search-container">
	<div class="search-panel">
      [@b.form name="roomApplySearchForm" action="!search" target="roomApplylist" title="ui.searchForm" theme="search"]
[#--					[@b.textfield label="活动名称" maxlength="20" name="roomApply.activity.name"/]--]
[#--          [@b.textfield label="借用人" maxlength="20" name="roomApply.borrower.applicant"/]--]
          [@b.select label="校区" items=campuses empty="..." name="roomApply.space.campus.id"/]
          [@b.select label="活动类型" items=activityTypes name="roomApply.activity.activityType.id" empty="..."/]
          [@b.select label="多媒体" items={"1":"使用","0":"不使用"} empty="..." name="roomApply.space.requireMultimedia"/]
          [@b.datepicker label="起始" readOnly="readOnly" id="dateBegin1" name="roomApply.time.beginOn" format="yyyy-MM-dd" maxDate="#F{$dp.$D(\\'dateEnd1\\')}" style="width:61%"/]
          [@b.datepicker label="截止" readOnly="readOnly" id="dateEnd1" name="roomApply.time.endOn" format="yyyy-MM-dd" minDate="#F{$dp.$D(\\'dateBegin1\\')}" style="width:61%"/]
				<input type="hidden" name="orderBy" value="roomApply.applyAt"/>
      [/@]
	</div>
	<div class="search-list">[@b.div id="roomApplylist" href="!search?orderBy=roomApply.applyAt"/]
	</div>
</div>
[@b.foot/]
