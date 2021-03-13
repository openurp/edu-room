[#ftl]
[@b.head/]
[@b.toolbar title="教室基本信息"/]
<div class="search-container">
    <div class="search-panel">
    [@b.form name="availableTimeSearchForm" action="!search" target="availableTimelist" title="ui.searchForm" theme="search"]
      [@b.textfields names="availableTime.room.code;代码"/]
      [@b.textfields names="availableTime.room.name;名称"/]
      [@b.select style="width:100px" name="availableTime.room.campus.id" label="校区" items=campuses option="id,name" empty="..." /]
      <input type="hidden" name="orderBy" value="availableTime.room.code"/>
    [/@]
    </div>
    <div class="search-list">[@b.div id="availableTimelist" href="!search?orderBy=availableTime.room.code"/]
  </div>
</div>
[@b.foot/]
