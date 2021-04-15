[#ftl]
[@b.head/]
<script language="JavaScript" type="text/JavaScript" src="${base}/static/scripts/itemSelect.js"></script>
[@b.toolbar title="代理申请"/]
<table class="indexpanel">
	<tr>
		<td class="index_view">
			<form id="roomApplyIndexForm" name="roomApplyIndexForm" action="" method="post" target="contentDiv">
				<table class="search-widget" id="viewTables" width="95%">
					<tr><td><img src="${b.static_url('bui','icons/16x16/actions/info.png')}" alt="info" class="toolbar-icon"/><em>教室申请菜单</em></td></tr>
					<tr><td style="font-size:0px"><img src="${b.static_url('bui','icons/16x16/actions/keyline.png')}" height="2" width="100%" alt="keyline"/></td></tr>
			       	<tr>
			         	<td id="infoTd" class="toolbar-item" width="95%" onclick="info(this,'${b.url("!search")}')">
			         	&nbsp;&nbsp;<image src="${b.static_url('bui','icons/16x16/actions/list.png')}" align="bottom"/>已申请
			         	</td>
			       	</tr>
			       	<tr>
			         	<td id="infoTd" name="applyTd" class="toolbar-item" width="95%" onclick="info(this,'${b.url("!editNew")}')">
			         	&nbsp;&nbsp;<image src="${b.static_url('bui','icons/16x16/actions/list.png')}"/>教室申请
			       	</td>
			       	</tr>
[#--			       	[@ems.guard res="/room/apply/free"]--]
[#--			       	<tr>--]
[#--			         	<td id="infoTd" class="toolbar-item" width="95%" onclick="info(this,'${b.url("free")}')" >--]
[#--			         	&nbsp;&nbsp;<image src="${b.static_url('bui','icons/16x16/actions/list.png')}"/>查看空闲教室--]
[#--			         	</td>--]
[#--			       	</tr>--]
[#--			       	[/@]--]
				</table>
			</form>
	   	</td>
		<td class="index_content">
			[@b.div id="contentDiv" href="!search" /]
		</td>
	</tr>
</table>
<script language="JavaScript">
	function info(td,action){
		var viewTables = document.getElementById("viewTables");
		clearSelected(viewTables,td);
		setSelectedRow(viewTables,td);
 		bg.form.submit("roomApplyIndexForm",action);
	}
	jQuery(function(){
		jQuery("#roomApplyIndexForm #infoTd:first").css("fontStyle","italic").css("color","blue").css("backgroundColor","#e9f2f8");
		jQuery("#roomApplyIndexForm #infoTd").hover(
			function(){
				jQuery(this).toggleClass("toolbar-item-transfer");
			}
		);
	});
</script>
[@b.foot/]
