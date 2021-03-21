[#ftl]
[@b.grid items=occupancies var="occupancy"]
  [@b.gridbar]
    bar.addItem("查看", function() {
      var form = document.roomListForm;
      var occupancyIds = bg.input.getCheckBoxValues("occupancy.id");
      if(occupancyIds == null || occupancyIds == "" || occupancyIds.indexOf(",")>-1){
        alert("请选择一条要查看的房间");
        return;
      }
      var url = "${b.url("!info?id=aaa")}";
      var newUrl = url.replace("aaa",occupancyIds);
      bg.form.submit(form, newUrl, "_blank");
    });
    
    bar.addItem("查看（简版）", function() {
      var form = document.roomListForm;
      var occupancyIds = bg.input.getCheckBoxValues("occupancy.id");
      if(occupancyIds == null || occupancyIds == "" || occupancyIds.indexOf(",")>-1) {
        alert("请选择一条要查看的房间");
        return;
      }
      var url = "${b.url("!info_m?id=aaa")}";
      var newUrl = url.replace("aaa",occupancyIds);
      bg.form.submit(form, newUrl, "_blank");
    });
  [/@]
  [@b.row]
    [@b.boxcol/]
    [@b.col width="15%" property="room.code" title="代码"/]
    [@b.col width="15%" property="room.name" title="名称"/]
    [@b.col width="15%" property="room.campus.name" title="校区"]
      ${(occupancy.room.campus.shortName)!((occupancy.room.campus.name)!'--')}
    [/@]
    [@b.col width="15%" property="room.building.name" title="教学楼"/]
    [@b.col width="12%" property="room.capacity" title="容量"/]
    [@b.col width="12%" property="room.courseCapacity" title="上课容量"/]
    [@b.col width="12%" property="room.examCapacity" title="考试容量"/]
  [/@]
[/@]
[@b.form name="roomListForm" action="" target="_blank"]
  <input type="hidden" name="roomId" value=""/>
[/@]
