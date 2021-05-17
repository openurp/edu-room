[#ftl]
[@b.grid items=rooms var="room"]
  [@b.gridbar]
    bar.addItem("借用教室","quickApplySetting()");
    function quickApplySetting(){
      var roomIds = bg.input.getCheckBoxValues("room.id");
      if(roomIds == "" || roomIds == null){
        alert("请至少选择一条");
        return;
      }
      bg.form.addInput(document.actionForm,"roomIds",roomIds);
      bg.form.submit(document.actionForm,'${b.url("!quickApplySetting")}',"main");
    }
  [/@]
  [@b.row]
    [@b.boxcol width="5%"/]
    [@b.col property="name" title="名称" width="20%"/]
    [@b.col property="building.name" title="教学楼" width="25%"/]
    [@b.col property="campus.name" title="校区" width="15%"/]
    [@b.col property="roomType.name" title="类型" width="15%"/]
    [@b.col title="上课容量" property="courseCapacity" width="10%"/]
    [@b.col title="考试容量" property="examCapacity" width="10%"/]
  [/@]
[/@]
