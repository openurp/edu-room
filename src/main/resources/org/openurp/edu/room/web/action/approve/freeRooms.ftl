[#ftl]
[@b.head/]

[@b.form name="roomSearchForm" action="!freeRooms"]
	<input type="hidden" name="roomApply.id" value = "${roomApply.id}"/>
	[@b.grid items=rooms var="room" filterable="true"]
		[@b.gridbar]
			bar.addItem("添加教室", "addRoom()");
		[/@]
		[@b.row]
			[@b.boxcol width="5%" property="id" boxname="room.id"/]
			[@b.col title="名称" property="name" width="25%" /]
			[@b.col title="教学楼" property="building.name" width="25%" /]
			[@b.col title="校区" property="campus.name" width="15%"/]
			[@b.col title="类型" property="roomType.name" width="20%" /]
			[@b.col title="容量" property="capacity" width="10%" /]
		[/@]
	[/@]
[/@]

<script>
	function addRoom() {
		var roomIds = bg.input.getCheckBoxValues("room.id");
		if (roomIds == "") { alert("请选择教室进行操作!"); return; } 
		var form = document.actionForm;
		form["roomIds"].value=form["roomIds"].value +","+ roomIds;
		bg.form.submit(form, "${b.url('!applySetting')}");
	}
</script>	