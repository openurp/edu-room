[@b.head/]
<style>
@page {
  size: A3 landscape;
}
.text-ellipsis2{
  overflow: hidden;
  display: -webkit-box;
  -webkit-box-orient: vertical;
  -webkit-line-clamp: 2;
  white-space: pre-wrap;
}
</style>
  [@b.toolbar title="教学活动教室占用汇总表"/]
  [#assign weekdayNames=["0","星期一","星期二","星期三","星期四","星期五","星期六","星期日"] /]
  [#assign total = weekdays?size * units?size /]
  [#assign unitWidth=80/]
  [#assign lastDayPartId=0/]
  [#assign seperatorIndexes=[]/]
  [#list units as u]
    [#if lastDayPartId=0]
      [#assign lastDayPartId = u.part.id/]
    [#else]
      [#if u.part.id != lastDayPartId]
        [#assign lastDayPartId = u.part.id/]
        [#assign seperatorIndexes = seperatorIndexes+[u.indexno-1]/]
      [/#if]
    [/#if]
  [/#list]
  <div style="width:${110 + total * unitWidth}px;margin:0px 10px 0px 10px">
    <div style="text-align:center">
      <h5>${project.school.name} ${semester.schoolYear}${("（" + semester.name + "）学期")?replace("学期）学期", "小学期")}教室占用情况一览表<h5>
    </div>
   <p style="margin: 0px;">占用内容说明：开头的1-16表示第1到16周，后面表示占用内容</p>
    <table class="grid-table" id="occupyTable" style="text-align:center;width:${110 + total * unitWidth}px;border: 0.5px solid #006CB2;table-layout:fixed;work-break;break:all;text-align:center;font-size:8.5pt;font-family:宋体">
        <colgroup>
          <col width="30px">
          <col width="80px">
          <col span="${total}" width="${unitWidth}px"/>
        </colgroup>
        <thead class="grid-head">
          <tr>
            <td width="30px" rowspan="2">序号</td>
            <td width="80px" rowspan="2">教室</td>
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
            <td width="30px">${room_index + 1}</td>
            <td width="80px">[@b.a href="occupancy!classroom?id="+room.id target="_blank"]${room.name}(${room.courseCapacity})[/@]</td>
            [#list weekdays as weekday]
              [#list units as unit]
              [#assign slotWeeks=(slotMap[room.id + "_" + weekday.id +"_"+ unit.indexno].weeks)!''  /]
              <td id="${room.id+"_"+weekday.id +"_"+ unit.indexno}">[#t/]
               <div class="text-ellipsis2" title="${slotWeeks} ${(slotMap[room.id + "_" + weekday.id +"_"+ unit.indexno].comments)?if_exists}">${slotWeeks} ${(slotMap[room.id + "_" + weekday.id +"_"+ unit.indexno].comments)?if_exists}</div>[#t/]
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

    var seperatorIndexes=[[#list seperatorIndexes as i]${i}[#sep],[/#list]]
    function mergeCol(tableId, rowStart, colStart) {
      var rows = document.getElementById(tableId).rows;
      for (var i = rowStart; i < rows.length; i++) {
        for (var j = colStart + 1; j < rows[i].cells.length;) {
          var tdIds = rows[i].cells[j].id.split("_");
          if (rows[i].cells[j - 1].innerHTML == rows[i].cells[j].innerHTML && "" != rows[i].cells[j - 1].innerHTML && "" != rows[i].cells[j].innerHTML) {
            rows[i].removeChild(rows[i].cells[j]);
            rows[i].cells[j - 1].colSpan++;
          } else {
            j++;
          }
          if (seperatorIndexes.includes(parseInt(tdIds[2]))) {
            rows[i].cells[j - 1].style.borderRightColor = "red";
          }
        }
      }
    }
    setTimeout("mergeTable()", 1);
    </script>
  </div>
[@b.foot/]
