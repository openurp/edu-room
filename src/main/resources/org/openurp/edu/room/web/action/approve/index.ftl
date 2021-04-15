[#ftl]
[@b.head/]
[@b.toolbar title="物管审核"]
  bar.addItem("代理借用","delegateApply()");
  function delegateApply(){
  bg.form.submit(document.searchRoomApplyApproveForm,'${b.url("room-apply")}',"_blank");
  }
[/@]
<div class="search-container">
    <div class="search-panel">
      [@b.form action="!search" theme="search" title="查询条件" name="searchRoomApplyApproveForm" target="contentDiv"]
        [@b.textfield label="活动名称" maxlength="20" name="roomApply.activity.name"/]
        [@b.textfield label="借用人" maxlength="20" name="roomApply.borrower.applicant"/]
        [@b.textfield label="经办人" maxlength="20" name="roomApply.applyBy.name"/]
        [@b.select label="校区" items=campuses empty="..." name="roomApply.space.campus.id"/]
        [@b.select label="活动/用途" items=activityTypes name="roomApply.activity.activityType.id" empty="..."/]
        [@b.select label="多媒体" items={"1":"使用","0":"不使用"} empty="..." name="roomApply.space.requireMultimedia"/]
        [@b.datepicker label="起始" readOnly="readOnly" id="dateBegin1" name="roomApply.time.beginOn" format="yyyy-MM-dd" maxDate="#F{$dp.$D(\\'dateEnd1\\')}" style="width:61%"/]
        [@b.datepicker label="截止" readOnly="readOnly" id="dateEnd1" name="roomApply.time.endOn" format="yyyy-MM-dd" minDate="#F{$dp.$D(\\'dateBegin1\\')}" style="width:61%"/]
        [@b.select label="教室类别" items=roomTypes empty="..." name="room.roomType.id" class="formHidden"/]
        [@b.textfield label="教室名称" name="room.name" class="formHidden"/]
        [#assign lookContents={'1':'待审核','2':'审核通过','3':'审核不通过'}]
        [@b.select label="状态" items=lookContents empty="..." name="lookContent" value="" empty="..."/]
        <input type="hidden" name="orderBy" value="roomApply.applyAt desc"/>
      [/@]
    </div>
    <div class="search-list">
      [@b.div id="contentDiv" href="!search?orderBy=roomApply.applyAt desc" /]
  </div>
</div>
[@b.foot/]
