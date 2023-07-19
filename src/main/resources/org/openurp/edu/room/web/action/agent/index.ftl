[#ftl]
[@b.head/]
<script language="JavaScript" type="text/JavaScript" src="${b.base}/static/scripts/itemSelect.js"></script>
<style>
  .item-select{
    float: left;
    padding: 3px;
    cursor: pointer;
    width:100%;
  }
  .item-select-active{
    background-color: #e9f2f8;
  }
</style>
[@b.toolbar title="教室代理借用"/]
<table class="indexpanel">
  <tr>
    <td class="index_view">
      <form id="roomApplyIndexForm" name="roomApplyIndexForm" action="" method="post" target="contentDiv">
        <table id="viewTables" style="width: 100%;display: table;">
          <tr><td><img src="${b.static_url('bui','icons/16x16/actions/info.png')}" alt="info" class="toolbar-icon"/><em>教室申请菜单</em></td></tr>
          <tr><td style="font-size:0px"><img src="${b.static_url('bui','icons/16x16/actions/keyline.png')}" height="2" width="100%" alt="keyline"/></td></tr>
          <tr>
            <td class="item-select" onclick="info(this,'${b.url("!search")}')">&nbsp;&nbsp;<i class="fa-solid fa-list"></i>&nbsp;已借用</td>
          </tr>
          <tr>
            <td class="item-select" onclick="info(this,'${b.url("!searchRooms")}')">&nbsp;&nbsp;<i class="fa-solid fa-plus"></i>&nbsp;开始借用</td>
          </tr>
          <tr>
            <td class="item-select" onclick="info(this,'${b.url("free")}')">&nbsp;&nbsp;<i class="fa-solid fa-magnifying-glass"></i>&nbsp;空闲教室</td>
          </tr>
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
    jQuery("#roomApplyIndexForm .item-select:first").css("fontStyle","italic").css("color","blue").css("backgroundColor","#e9f2f8");
    jQuery("#roomApplyIndexForm .item-select").hover(
      function(){
        jQuery(this).toggleClass("item-select-active");
      }
    );
  });
</script>
[@b.foot/]
