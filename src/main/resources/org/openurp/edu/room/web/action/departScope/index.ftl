[#ftl]
[@b.head/]
[@b.toolbar title="院系教室代理借用范围"/]
<div class="search-container">
    <div class="search-panel">
      [@b.form action="!search" theme="search" title="查询条件" name="searchRoomApplyApproveForm" target="contentDiv"]
        [@b.textfield name="scope.depart.name" label="学院名称"/]
      [/@]
    </div>
    <div class="search-list">
      [@b.div id="contentDiv" href="!search" /]
  </div>
</div>
[@b.foot/]
