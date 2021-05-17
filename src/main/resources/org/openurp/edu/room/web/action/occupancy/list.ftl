[#ftl]
[@b.grid items=classrooms var="classroom"]
  [@b.gridbar]
    bar.addItem("查看", action.single("calendar",null,null,"_blank"));
    //bar.addItem("查看（简版）", action.single("calendar_m",null,null,"_blank"));
  [/@]
  [@b.row]
    [@b.boxcol/]
    [@b.col width="15%" property="code" title="代码"/]
    [@b.col width="15%" property="name" title="名称"/]
    [@b.col width="15%" property="campus.name" title="校区"]
      ${(classroom.campus.shortName)!((classroom.campus.name)!'--')}
    [/@]
    [@b.col width="15%" property="building.name" title="教学楼"/]
    [@b.col width="12%" property="capacity" title="容量"/]
    [@b.col width="12%" property="courseCapacity" title="上课容量"/]
    [@b.col width="12%" property="examCapacity" title="考试容量"/]
  [/@]
[/@]
