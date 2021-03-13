[#ftl]
[@b.head/]
[@b.grid items=availableTimes var="availableTime"]
  [@b.gridbar]
    bar.addItem("${b.text("action.new")}",action.add());
    bar.addItem("${b.text("action.modify")}",action.edit());
    bar.addItem("${b.text("action.delete")}",action.remove("确认删除?"));
  [/@]
  [@b.row]
    [@b.boxcol /]
    [@b.col width="10%" property="room.code" title="代码"/]
    [@b.col width="10%" property="room.name" title="名称"/]
    [@b.col width="10%" property="room.roomType.name" title="教室类型"/]
    [@b.col width="10%" property="room.building.name" title="教学楼"/]
    [@b.col width="10%" property="room.campus.name" title="校区"]
      ${(availableTime.room.campus.shortName)!((availableTime.room.campus.name)!'--')}
    [/@]
    [@b.col width="10%" property="room.capacity" title="容量"/]
    [@b.col width="10%" property="room.courseCapacity" title="上课容量"/]
    [@b.col width="10%" property="room.examCapacity" title="考试容量"/]
    [@b.col width="15%" title="可用时间"]${availableTime.time.startOn}(${availableTime.time.beginAt}-${availableTime.time.endAt})[/@]
  [/@]
  [/@]
[@b.foot/]
