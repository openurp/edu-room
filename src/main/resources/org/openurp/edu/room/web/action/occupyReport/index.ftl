[#ftl]
[@b.head/]
[@b.toolbar title="教室占用汇总"/]
<div class="search-container">
    <div class="search-panel">
    [@b.form name="classroomSearchForm" action="!search" target="classroomlist" title="ui.searchForm" theme="search"]
      [@base.semester name="semester.id" value=semester label="学年学期"/]
      [@b.textfields names="classroom.code;代码,classroom.name;名称"/]
      [@b.select style="width:100px" name="classroom.building.id" label="教学楼" items=buildings option="id,name" empty="..." /]
      [@b.select style="width:100px" name="classroom.roomType.id" label="教室类型" items=roomTypes option="id,name" empty="..." /]
      [@b.select style="width:100px" name="classroom.campus.id" label="校区" items=campuses option="id,name" empty="..." /]
      <input type="hidden" name="orderBy" value="classroom.code"/>
    [/@]
    </div>
    <div class="search-list">[@b.div id="classroomlist" href="!search?orderBy=classroom.code&semester.id="+semester.id/]
  </div>
</div>
[@b.foot/]
