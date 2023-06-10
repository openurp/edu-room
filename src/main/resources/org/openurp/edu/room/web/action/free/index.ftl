[@b.head/]
<div class="container-fluid text-sm">
[@b.toolbar title="空闲教室查询"/]
[#assign unitTitles={}/]
[#list units as u]
[#assign unitTitles=unitTitles+{'${u.id}':'${u.name}(${u.beginAt}~${u.endAt})'}/]
[/#list]
[@b.form name="freeRoomSetting" action="!freeRooms" target="freeRoomsList"]
  [@b.date name="date" value=today label="日期" required="true"/]
  [@b.select label="小节" name="unitId" items=unitTitles value=unit.id?string required="true"/]
  [@b.textfield label="教室名称" name="room.name"/]
  [@b.submit value="查询"/]
[/@]

[@b.div id="freeRoomsList" href="!freeRooms?date=${today?string('yyyy-MM-dd')}&beginAt=${unit.beginAt}&endAt=${unit.endAt}"/]
</div>
[@b.foot/]
