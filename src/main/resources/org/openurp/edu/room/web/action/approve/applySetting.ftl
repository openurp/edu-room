[#ftl]
[@b.head/]
[#import "../cycleType.ftl" as RoomApply/]
[#--[#include "/template/macros.ftl"/]--]
[#assign barTitle][#if roomApply.rooms?exists && (roomApply.rooms)?size == 0]批准申请,分配教室[#else]${b.text('action.edit')}教室分配[/#if][/#assign]
[@b.messages slash="3"/]
[@b.toolbar title=barTitle]
    [#if roomApply.rooms?exists && (roomApply.rooms)?size == 0]
      bar.addItem("批准审核通过", "approve()");
    [#else]
      bar.addItem("保存修改", "approve()", "save.png");
    [/#if]
  bar.addItem("审核不通过", "cancelApply()", "edit-delete.png");
  bar.addBack();
[/@]
[@b.form action="!approve" name="actionForm"]
  <input type="hidden" name="roomApply.id" value="${roomApply.id}"/>
  <table class="formTable" align="center" width="100%">
    <tr>
      <td class="title" align="right" width="15%"><font color="red">*</font>&nbsp;借用人：</td>
      <td width="35%">${(roomApply.borrower.applicant)!}</td>
      <td class="title" align="right" width="15%"><font color="red">*</font>&nbsp;经办人姓名：</td>
      <td width="35%">${roomApply.applyBy.name} 填表申请时间：${roomApply.applyAt?string('yyyy-MM-dd HH:mm:ss')}</td>
    </tr>
    <tr>
      <td class="title"><font color="red">*</font>&nbsp;归口部门：</td>
      <td>${roomApply.borrower.department.name}</td>
      <td class="title" align="right">&nbsp;联系方式：</td>
      <td>${(roomApply.borrower.mobile)!}</td>
    </tr>
    <tr>
      <td class="title">借用用途：</td>
      <td>${roomApply.activity.activityType.name}</td>
      <td class="title" align="right"><font color="red">*</font>&nbsp;说明：</td>
      <td colspan="3">${roomApply.activity.name!}</td>
    </tr>
    <tr>
      <td class="title"><font color="red">*</font>&nbsp;借用校区：</td>
      <td>${(roomApply.space.campus.name)!}</td>
      <td class="title" align="right"><font color="red">*</font>&nbsp;出席总人数：</td>
      <td>${roomApply.activity.attendanceNum}(每个教室${roomApply.space.unitAttendance})</td>
    </tr>
    <tr>
      <td class="title" align="right"><font color="red">*</font>&nbsp;是否使用多媒体设备：</td>
      <td>${roomApply.space.requireMultimedia?string('是','否')}</td>
      <td class="title">其它要求：</td>
      <td>${(roomApply.space.roomComment)!}</td>
    </tr>
      [#assign dateBegin=(roomApply.time.beginOn)! /]
      [#assign dateEnd=(roomApply.time.endOn)! /]
    <tr>
      <td class="title" align="right">&nbsp;使用日期：</td>
      <td colspan="3"><span
                title="[#if dateBegin=dateEnd]${dateEnd}[#else]${dateBegin}~${dateEnd}[/#if]">${(roomApply.time)!}</span>
      </td>
    </tr>
    <tr>
      <td class="title" align="right">&nbsp;分配教室：</td>
      <td colspan="3">
          [#assign totalCapacity=0/]
          [#if roomApply.rooms?exists && roomApply.rooms?size > 0]
            <span id="allocatedRooms">
              [#list roomApply.rooms as room]
                <font name="roomInfo">
                [#assign usageCapacity=0]
                  ${(room.name)!} ${(room.campus.name?js_string)!("未设定")}  ${(room.roomType.name?js_string)!("未设定")} ${room.capacity}人<br>
                [#assign totalCapacity=totalCapacity+room.capacity/]
              </font>
              [/#list]
              总计容量${totalCapacity}人
              [#if totalCapacity<roomApply.activity.attendanceNum]<span style="color:red">尚未满足要求容量${roomApply.activity.attendanceNum}</span>
              [#else]<span style="color:green">[#if roomApply.activity.attendanceNum>0]超出要求${((totalCapacity-roomApply.activity.attendanceNum)/roomApply.activity.attendanceNum)?string.percent}[/#if]</span>
              [/#if]
              <br>
            </span>
            <input type="button" name="clearButton" value="清除" onclick="clearRoom();"/>
          [/#if]
        <input type="hidden" name="roomIds" value="[#if roomApply.rooms?exists][#list  roomApply.rooms as r]${r.id},[/#list][/#if]"/>
        <input type="button" value="查找教室" onclick="freeRooms()"/>
      </td>
    </tr>
  </table>
    [@b.div id='resultDiv' /]
[/@]

<script language="JavaScript">
  function approve() {
    var ids = document.actionForm['roomIds'].value;
    [#if totalCapacity>0 && totalCapacity<roomApply.activity.attendanceNum]
    if (!confirm("分配容量不够,是否确定保存?")) return;
    [/#if]
    if ("" != ids) {
      bg.form.submit(document.actionForm);
    } else {
      alert("请添加教室");
    }
  }

  function clearRoom() {
    $('#allocatedRooms').text("");
    $("input[name='clearButton']").hide();
    document.actionForm['roomIds'].value = "";
  }

  function freeRooms() {
    bg.form.submit(document.actionForm, "${b.url('!freeRooms?roomApplyId=${roomApply.id}')}", "resultDiv");
  }

  function cancelApply() {
    var form = document.actionForm;
    var flag = promptReason(form);
    if (!flag) {
      return;
    }
    bg.form.submit(form, "${b.url("!cancel")}");
  }

  function promptReason(form) {
    var reason = prompt("请填写审核不通过的理由");
    if (reason == null) {
      return false;
    }
    reason = $.trim(reason);
    if (reason == "") {
      alert("请填写审核不通过理由");
      return promptReason(form);
    } else if (reason.length > 200) {
      alert("请不要超过200个字");
      return promptReason(form);
    }
    bg.form.addInput(form, "roomApply.approvedRemark", reason);
    return true;
  }
</script>
[@b.foot/]
