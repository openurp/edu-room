[#ftl]
[@b.head/]
[@b.toolbar title="归口审核"]
  bar.addItem("代理借用","delegateApply()");
  function delegateApply(){
    alert("正在施工..");
    [#--bg.form.submit(document.searchRoomApplyApproveForm,'${b.url("delegate")}',"_blank");--]
  }
[/@]
<div class="search-container">
    <div class="search-panel">
    [@b.form action="!search" theme="search" title="查询条件" name="searchRoomApplyApproveForm" target="contentDiv"]
      [@urp_base.semester id="f_semester" label="学年学期" name="roomApply.semester.id" value=semester/]
      [@b.textfield label="借用人" maxlength="20" name="roomApply.applicant.user"/]
      [@b.select label="校区" items=campuses empty="..." name="roomApply.campus.id"/]
      [@b.select label="活动/用途" items=activityTypes name="roomApply.activity.activityType.id" empty="..."/]
      [@b.select label="多媒体" items={"1":"使用","0","不使用"} empty="..." name="roomApply.isMultimedia" class="formHidden"/]
      [@b.datepicker label="起始" readOnly="readOnly" id="dateBegin1" name="applyTime.dateBegin" format="yyyy-MM-dd" maxDate="#F{$dp.$D(\\'dateEnd1\\')}" style="width:61%"/]
      [@b.datepicker label="截止" readOnly="readOnly" id="dateEnd1" name="applyTime.dateEnd" format="yyyy-MM-dd" minDate="#F{$dp.$D(\\'dateBegin1\\')}" style="width:61%"/]
    [/@]
    </div>
    <div class="search-list">
     [@b.div id="contentDiv" href="!search?roomApply.semester.id="+semester.id /]
  </div>
</div>
[@b.foot/]
