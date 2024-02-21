[@b.head/]
[#include "reportMacros.ftl"/]
  [@b.toolbar title="教学活动教室占用汇总表"/]
  [#assign weekdayNames=["0","星期一","星期二","星期三","星期四","星期五","星期六","星期日"] /]
  [#assign total = units?size /]
  [#assign unitWidth=80/]
  <div class="container-fluid">
    <div style="text-align:center">
      <h5>${project.school.name} ${semester.schoolYear}${("（" + semester.name + "）学期")?replace("学期）学期", "小学期")}教室占用情况一览表<h5>
    </div>
   <p style="margin: 0px;">占用内容说明：开头的1-16表示第1到16周，后面表示占用内容</p>
    <table class="grid-table" id="occupyTable" style="text-align:center;border: 0.5px solid #006CB2;table-layout:fixed;work-break;break:all;text-align:center;font-size:8.5pt;font-family:宋体">
        <colgroup>
          <col width="30px">
          <col width="30px">
          <col width="100px">
          <col span="${total}" width="${unitWidth}px"/>
        </colgroup>
        <thead class="grid-head">
          <tr>
            <td>周几</td>
            <td>序号</td>
            <td>教室(上课容量)</td>
            [#list units as unit]
            <td [#if seperatorIndexes?seq_contains(unit.indexno)]style="border-right-color: red;"[/#if]>${unit.name}</td>
            [/#list]
          </tr>
        </thead>
        [#list weekdays as weekday]
          [#list classrooms as room]
          <tr>
              [#if room_index ==0]<td rowspan="${classrooms?size}" style="background-color: var(--gridbar-bg-color);">${weekdayNames[weekday.id]}</td>[/#if]
              <td>${room_index + 1}</td>
              <td>[@b.a href="occupancy!classroom?id="+room.id target="_blank"]${room.name}(${room.courseCapacity})[/@]</td>
              [#list units as unit]
              [#assign slotWeeks=(slotMap[room.id + "_" + weekday.id +"_"+ unit.indexno].weeks)!''  /]
              <td id="${room.id+"_"+weekday.id +"_"+ unit.indexno}">[#t/]
               <div class="text-ellipsis2" title="${slotWeeks} ${(slotMap[room.id + "_" + weekday.id +"_"+ unit.indexno].comments)?if_exists}">${slotWeeks} ${(slotMap[room.id + "_" + weekday.id +"_"+ unit.indexno].comments)?if_exists}</div>[#t/]
              </td>[#t/]
              [/#list]
          </tr>
          [/#list]
        [/#list]
    </table>

    <script>
    function mergeTable(){
      mergeCol('occupyTable', 1, 0);
    }
    setTimeout("mergeTable()", 1);
    </script>
  </div>
[@b.foot/]
