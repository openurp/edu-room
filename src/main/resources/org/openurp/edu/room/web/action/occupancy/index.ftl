[#ftl]
[@b.head/]
[@b.toolbar title="教室占用情况"/]
<div class="search-container">
  <div class="search-panel">
    [@b.form name="occupancySearchForm" action="!search" target="occupancylist" title="ui.searchForm" theme="search"]
      [@b.textfields names="occupancy.room.code;教室代码"/]
      [@b.textfields names="occupancy.room.name;教室名称"/]
      <input type="hidden" name="orderBy" value="occupancy.room.code"/>
    [/@]
  </div>
  <div class="search-list">[@b.div id="occupancylist" href="!search?orderBy=occupancy.room.code"/]
  </div>
</div>
[@b.foot/]