[#ftl]
[@b.head/]
[@b.toolbar title="教室借用查询"/]
<div class="search-container">
    <div class="search-panel">
      [@b.form action="!search" theme="search" title="查询条件" name="searchRoomApplyApproveForm" target="contentDiv"]
        [@b.textfield label="活动名称" maxlength="20" name="roomApply.activity.name"/]
        [@b.select label="活动/用途" items=activityTypes name="roomApply.activity.activityType.id" empty="..."/]
        [@b.textfield label="借用人" maxlength="20" name="roomApply.applicant.user.name" placeholder="姓名"/]
        [@b.select label="多媒体" items={"1":"使用","0":"不使用"} empty="..." name="roomApply.space.requireMultimedia"/]
        [@b.date label="借用日期"  name="occupyOn" format="yyyy-MM-dd"/]
        [@b.select label="校区" items=campuses empty="..." name="roomApply.space.campus.id"/]
        [@b.textfield label="教学楼" name="room.building.name"/]
        [@b.select label="教室类别" items=roomTypes empty="..." name="room.roomType.id" class="formHidden"/]
        [@b.textfield label="教室名称" name="room.name"/]
        <input type="hidden" name="orderBy" value="roomApply.applyAt desc"/>
      [/@]
    </div>
    <div class="search-list">
      [@b.div id="contentDiv" href="!search?orderBy=roomApply.applyAt desc" /]
  </div>
</div>
[@b.foot/]
