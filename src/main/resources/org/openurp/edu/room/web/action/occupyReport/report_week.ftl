[@b.head/]
<style>
@page {
  size: A3 landscape;
}
</style>
[#include "reportMacros.ftl"/]
  [@b.toolbar title="教学活动教室占用汇总表"/]
  [#assign weekdayNames=["0","星期一","星期二","星期三","星期四","星期五","星期六","星期日"] /]
  [#assign total = weekdays?size * units?size /]
  [#assign unitWidth=20/]
  <div class="container-fluid">
    <div style="text-align:center">
      <h5>${project.school.name} ${semester.schoolYear}${("（" + semester.name + "）学期")?replace("学期）学期", "小学期")}教室占用情况一览表<h5>
    </div>
    <table class="grid-table" id="occupyTable" style="text-align:center;border: 0.5px solid #006CB2;table-layout:fixed;work-break;break:all;text-align:center;font-size:8.5pt;font-family:宋体">
      <colgroup>
        <col width="30px">
        <col width="100px">
        <col span="${total}" width="${unitWidth}px"/>
      </colgroup>
      <thead class="grid-head">
        <tr>
          <td rowspan="2">序号</td>
          <td rowspan="2">教室(上课容量)</td>
          [#list weekdays as weekday]
          <td colspan="${units?size}">${weekdayNames[weekday.id]}</td>
          [/#list]
        </tr>
        <tr>
          [#list weekdays as weekday]
            [#list units as unit]
            <td [#if seperatorIndexes?seq_contains(unit.indexno)]style="border-right-color: red;"[/#if]>${unit.indexno}</td>
            [/#list]
          [/#list]
        </tr>
      </thead>
      [#list classrooms as room]
      <tr>
          <td>${room_index + 1}</td>
          <td>[@b.a href="occupancy!classroom?id="+room.id target="_blank"]${room.name}(${room.courseCapacity})[/@]</td>
          [#list weekdays as weekday]
            [#list units as unit]
            [#assign slotWeeks=(slotMap[room.id + "_" + weekday.id +"_"+ unit.indexno].weeks)!''  /]
            <td id="${room.id+"_"+weekday.id +"_"+ unit.indexno}" title="${slotWeeks} ${(slotMap[room.id + "_" + weekday.id +"_"+ unit.indexno].comments)?if_exists}">[#t/]
            ${slotWeeks}[#t/]
            </td>[#t/]
            [/#list]
          [/#list]
      </tr>
      [/#list]
    </table>
    <script>
    function mergeTable(){
      mergeCol('occupyTable', 2, 0);
    }
    setTimeout("mergeTable()", 1);
    </script>
  </div>
[@b.foot/]
