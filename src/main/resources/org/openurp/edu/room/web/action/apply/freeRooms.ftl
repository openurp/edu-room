[#ftl]
[@b.grid items=classrooms var="room"]
  [@b.row]
    [@b.col title="序号" width="5%"]${room_index+1}[/@]
    [@b.col title="名称" width="30%" property="name"]
       [@b.a target="_blank" href="occupancy!building?id="+((room.building.id)!0) +"&classroomId="+room.id + "&beginOn="+Parameters['time.beginOn']]
          ${room.name} [#if !room.roomNo??]<sup>虚拟</sup>[/#if]
       [/@]
       &nbsp;
      <a href="javascript:void(0)" onclick="toggleRoom(this,'${room.id}','${room.name}',${room.courseCapacity});return false;" class="btn btn-sm btn-outline-primary pt-0 pb-0">选择</a>
    [/@]
    [@b.col title="校区" width="15%" property="campus.name"/]
    [@b.col title="教学楼" width="20%" property="building.name"/]
    [@b.col title="教室类型" width="20%" property="roomType.name"/]
    [@b.col title="容量" width="10%" property="courseCapacity"/]
  [/@]
[/@]
  <script>
  function toggleRoom(ele,id,name,capacity){
    if(selectRooms.has(id)){
       selectRooms.delete(id);
       ele.innerHTML="选择";
       jQuery(ele).addClass('btn-outline-primary').removeClass('btn-outline-danger');
    }else{
       selectRooms.set(id,{'id':id,'name':name,'capacity':capacity});
       ele.innerHTML="删除";
       jQuery(ele).addClass('btn-outline-danger').removeClass('btn-outline-primary');
    }
    collectRooms();
  }
  </script>
