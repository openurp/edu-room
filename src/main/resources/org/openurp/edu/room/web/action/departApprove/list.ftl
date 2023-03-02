[#ftl]
[@b.head/]
<script language="JavaScript" type="text/JavaScript" src="${b.base}/static/scripts/roomApply.js"></script>
[#assign cycleName={'1':'天','2':'周','4':'月'}/]
[@b.grid items=roomApplies var="roomApply"]
  [@b.gridbar]
    bar.addItem("${b.text('action.info')}", action.info());
    bar.addItem("审核通过", action.multi("departApprove"));
    bar.addItem("审核不通过",  action.multi("departCancel"));
    bar.addItem("${b.text("action.export")}","exportDatas()");

    function exportDatas() {
      var roomApplyIds = bg.input.getCheckBoxValues("roomApply.id");
      var form = action.getForm();
      if (roomApplyIds) {
        bg.form.addInput(form,"roomApplyIds",roomApplyIds);
      }else{
        if(!confirm("是否导出查询条件内的所有数据?")) return;
          if(""!=action.page.paramstr){
                bg.form.addHiddens(form,action.page.paramstr);
                bg.form.addParamsInput(form,action.page.paramstr);
              }
        bg.form.addInput(form,"roomApplyIds","");
      }
      bg.form.addInput(form, "keys", "activity.name,usage.name,activity.speaker,activity.attendee,activity.attendance,campus.name,roomRequest,borrower.applicant,updatedAt,applyTime,auditDepart.name,isDepartApproved,departApproveBy.fullname,departApproveAt,isApproved,approveBy.fullname,approveAt,hours,isMultimedia,roomInfo");
      bg.form.addInput(form, "titles", "活动名称,活动类型,主讲人及内容,出席对象,出席总人数,借用校区,其他要求,借用人,提交申请时间,申请占用时间,借用部门,归口审核,归口审核人,归口审核时间,物管审核,物管审核人,物管审核时间,时间(小时数),是否使用多媒体设备,批准教室信息");
      bg.form.addInput(form, "fileName", "教室借用信息");
      bg.form.submit(form,"${b.url('!export')}","_self");
    }
  [/@]
  [@b.row]
    [@b.boxcol width="5%"/]
    [@b.col property="activity.name" title="活动名称"  width="12%"]
      [#if roomApply.isApproved!false]
      [@b.a href="!preview?roomApplyIds=${roomApply.id}" target="_blank"]${(roomApply.activity.name?html)!}[/@]
      [#else]
      [@b.a href="!info?id=${roomApply.id}"]${(roomApply.activity.name?html)!}[/@]
      [/#if]
    [/@]
    [@b.col property="activity.activityType.name" title="活动类型"  width="8%" sortable="false"/]
    [@b.col title="借用时间" width="25%"]${roomApply.time!}[/@]
      [@b.col title="使用教室" width="20%"]
        [#list roomApply.rooms?if_exists as room]${(room.name)!}[#if room_has_next]&nbsp;[/#if][/#list]
      [/@]
    [@b.col property="borrower.applicant" sortable="false" title="借用人"  width="10%"/]
    [@b.col property="updatedAt" title="申请时间"  width="10%"]${(roomApply.applyAt?string("yy-MM-dd HH:mm"))?default("")}[/@]
    [@b.col property="isDepartApproved" title="状态"  width="10%"]
      ${(roomApply.isDepartApproved?string("审核通过","审核不通过"))?default("待审核")}<input type="hidden" id="${"depart"+roomApply.id}" value="${(roomApply.isDepartApproved?string("审核通过","审核不通过"))?default("待审核")}"/>
    [/@]
  [/@]
[/@]
<script>
   function promptReason(form){
     var reason = prompt("请填写审核不通过的理由");
        if(reason == null){
          return false;
        }
        reason = $.trim(reason);
        if(reason == ""){
          alert("请填写审核不通过理由");
          return promptReason(form);
        }else if (reason.length > 200){
          alert("请不要超过200个字");
          return promptReason(form);
        }
        bg.form.addInput(form,"roomApply.departApprovedRemark",reason);
        return true;
   }

   function editApply() {
     var form = document.searchRoomApplyApproveForm;
     var id = bg.input.getCheckBoxValues("roomApply.id");
     if (id == null || id == "" || id.indexOf(",")>-1) {
       alert("请只选择一条操作!");
       return;
     }
        if (confirm(autoLineFeed("在修改页面保存所修改的内容后，将取消原来的审核结果（即，审核不通过），要进入修改吗？"))) {
          bg.form.addInput(form,"roomApplyId",id);
          [#--bg.form.submit(form,"${b.url('!editApply')}");--]
        }
   }
</script>
[@b.foot/]
