[#ftl]
[@b.head/]
[@b.toolbar title="教室占用情况"/]
<div class="search-container">
  <div class="search-panel">
    [@b.form name="occupancySearchForm" action="!search" target="classroomlist" title="ui.searchForm" theme="search"]
      [@b.textfields names="classroom.code;教室代码"/]
      [@b.textfields names="classroom.name;教室名称"/]
      <input type="hidden" name="orderBy" value="classroom.code"/>
    [/@]
  </div>
  <div class="search-list">[@b.div id="classroomlist" href="!search?orderBy=classroom.code"/]
  </div>
</div>
[@b.foot/]
