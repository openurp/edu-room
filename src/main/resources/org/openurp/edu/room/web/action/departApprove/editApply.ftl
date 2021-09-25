[#ftl]
[@b.head/]
[@b.toolbar title="教室借用"]
bar.addBack();
[/@]
[#import "../cycleType.ftl" as RoomApply/]
<script language="JavaScript" type="text/JavaScript" src="static/scripts/ValidatorsForClassroom.js"></script>
[@b.form action="!apply" name="roomApplyForm" target="contentDiv"]
    <table class="formTable" align="center" width="100%">
      <input name="roomApply.id" type="hidden" value="${roomApplyId!}"/>
        <tr class="thead" align="center">
            <td colspan="5"><B>教室借用填写表</B></td>
        </tr>
        <tr>
          <td class="title" style="text-align:center; width: 15%" rowspan="2">借用人</td>
          <td class="title" align="right" id="f_username" width="18%"><font color="red">*</font>&nbsp;姓名：</td>
          <td><input type="text" name="roomApply.borrower.applicant" value="${roomApply.borrower.applicant}"/></td>
          <td class="title" align="right" width="18%" id="f_addr"><font color="red">*</font>&nbsp;地址：</td>
          <td><input type="text" name="roomApply.borrower.addr" size="15" maxlength="200" value="${(roomApply.borrower.addr)?default("")}"/></td>
        </tr>
        <tr>
          <td class="title" align="right" id="f_mobile"><font color="red">*</font>&nbsp;手机：</td>
      <td><input type="text" name="roomApply.borrower.mobile" size="15" value="${(roomApply.borrower.mobile)?default("")}" maxlength="20"/></td>
      <td class="title" align="right" id="f_email"><font color="red">*</font>&nbsp;E-mail：</td>
      <td><input type="text" name="roomApply.borrower.email" value="${(roomApply.borrower.email)?default("")}" size="15" maxlength="50"/></td>
        </tr>
        <tr>
          <td class="title" style="text-align:center" rowspan="2">借用用途、性质</td>
          <td class="title" align="right" id="f_name"><font color="red">*</font>&nbsp;活动名称：</td>
          <td colspan  ="3"><input type="text" name="roomApply.activity.name" value="${(roomApply.activity.name)?default("")}" size="50" maxlength="50"/></td>
        </tr>
        <tr>
          <td class="title" align="right" id="f_activityType"><font color="red">*</font>&nbsp;活动类型：</td>
          <td colspan="4">
            [#if activityTypes?size > 0]
              [#list activityTypes as activityType]
            <input type="radio" id="activityType${activityType.id}" name="roomApply.usage.id" [#if 0 == activityType_index]checked[#elseif activityType.id == roomApply.usage.id]checked[/#if] value="${activityType.id}"/><label for="activityType${activityType.id}">${(usage.name?html)!}</label>&nbsp;&nbsp;
              [/#list]
            [#else]
              您没有活动类型数据,请先在基础代码中维护活动类型数据!
            [/#if]
          </td>
        </tr>
        <tr>
          <td class="title" style="text-align:center" rowspan="2">主讲人</td>
          <td id="f_speaker" style="border-right-width:0px"><font color="red">*</font>&nbsp;姓名及背景资料：</td>
            <td colspan="3" style="border-left-width:0px"></td>
        </tr>
        <tr>
          <td colspan="5"><textarea name="roomApply.activity.speaker" rows="3" cols="50">${(roomApply.activity.speaker)?default("")}</textarea></td>
        </tr>
        <tr>
          <td class="title" style="text-align:center" rowspan="2">出席者情况</td>
          <td class="title" align="right" id="f_attendee"><font color="red">*</font>&nbsp;出席对象：</td>
          <td colspan="3"><input type="text" name="roomApply.activity.attendee" size="50" value="${(roomApply.activity.attendee)?default("")}" maxlength="50"/></td>
        </tr>
        <tr>
          <td class="title" align="right" id="f_attendance"><font color="red">*</font>&nbsp;出席总人数：</td>
          <td colspan="3"><input type="text" name="roomApply.activity.attendance" value="${(roomApply.activity.attendance)?default('0')}" maxlength="5"/>&nbsp;人&nbsp;&nbsp;&nbsp;(填写数字)</td>
        </tr>
        <tr>
          <td class="title" style="text-align:center"id="f_roomRequest" rowspan="3">&nbsp;借用场所要求</td>
          <td class="title" align="right" id="f_isFree"><font color="red">*</font>&nbsp;是否使用多媒体设备：</td>
          <td colspan="3">
          <input type="radio" id="isMultimedia1" name="roomApply.isMultimedia" value="1" [#if (roomApply.isMultimedia)?exists == false || (roomApply.isMultimedia)?exists && roomApply.isMultimedia?string("true", "false") == "true"] checked[/#if]/><label for="isMultimedia1">&nbsp;使用&nbsp;</label>
            <input type="radio" id="isMultimedia2" name="roomApply.isMultimedia" value="0" [#if (roomApply.isMultimedia)?exists && roomApply.isMultimedia?string("true", "false") == "false"]checked[/#if]/><label for="isMultimedia2">&nbsp;不使用</label>
          </td>
        </tr>
        <tr>
          <td class="title"><font color="red">*</font>&nbsp;借用校区：</td>
          <td colspan="3">[@b.select items=campuss value=(roomApply.campus.id)!("") name="roomApply.campus.id" style="width:200px"/]</td>
        </tr>
        <tr>
          <td class="title">其它要求：</td>
          <td colspan="3"><textarea name="roomApply.roomRequest" rows="3" cols="35">${(roomApply.roomRequest)?default("")}</textarea>(最多250个字符)</td>
        </tr>
        <tr>
          <td class="title" style="text-align:center" rowspan="3">借用时间要求</td>
            <td class="title" id="f_begin_end" align="right"><font color="red">*</font>&nbsp;教室使用日期：</td>
            <td colspan="3">
            <input type="text" readOnly="readOnly" id="dateBegin" name="roomApply.applyTime.dateBegin" class="Wdate"  value="${(roomApply.applyTime.dateBegin?string('yyyy-MM-dd'))?default('')}" onFocus="WdatePicker({dateFmt:'yyyy-MM-dd',maxDate:'#F{$dp.$D(\'dateEnd\')}'})" />
            - <input type="text" readOnly="readOnly" id="dateEnd" name="roomApply.applyTime.dateEnd" class="Wdate" value="${(roomApply.applyTime.dateEnd?string('yyyy-MM-dd'))?default('')}" onFocus="WdatePicker({dateFmt:'yyyy-MM-dd',minDate:'#F{$dp.$D(\'dateBegin\')}'})" /> (年月日 格式2007-09-20)
        </tr>
        <tr>
            <td class="title" id="f_beginTime_endTime" align="right"><font color="red">*</font>&nbsp;<select id="roomApplyTimeType" name="roomApplyTimeType"><option value="1">教室使用时间：</option><option value="0">教室使用小节：</option></select></td>
            <td colspan="3" id="roomApplyTimeTypeTd"><input type="text" name="timeBegin" size="10" class="LabeledInput" value="00:00" format="Time"  maxlength="5"/> - <input type="text" name="timeEnd" value="00:00"  size="10" maxlength="5"/> (时分 格式如09:00 共五位)</td>
        </tr>
        <tr>
            <td class="title" id="f_cycleCount" align="right"><font color="red">*</font>&nbsp;时间周期：</td>
            <td colspan="3">每&nbsp;<input type="text" name="roomApply.applyTime.cycleCount" style="width:30px" maxlength="3" value="${(roomApply.applyTime.cycleCount)?default('0')}"/>
                [@RoomApply.cycleTypeSelect  name="roomApply.applyTime.cycleType" cycleType=(roomApply.applyTime.cycleType)?default(1)/]
            </td>
        </tr>
        <tr>
          <td class="title" style="text-align:center" rowspan="4">借用方承诺</td>
            <td colspan="4">(1)遵守学校教室场所使用管理要求，保持环境整洁，不吸烟、不乱抛口香糖等杂物。 </td>
        </tr>
        <tr><td colspan="4">(2)遵守学校治安管理规定，确保安全使用。若因借用人管理和使用不当造成安全事故，借用人自行承担责任。</td></tr>
        <tr><td colspan="4">(3)遵守学校财产物资规定，损坏设备设施按原值赔偿。</td></tr>
        <tr>
          <td class="title" style="text-align:center" rowspan="5">归口审核</td>
          <td colspan="4">1.各院系学术讲座、办班等院长或系主任负责审批；</td>
        </tr>
        <tr><td colspan="4">2.各院系学生活动由各院系总支副书记负责审批(学生社团活动除外)；</td></tr>
        <tr><td colspan="4">3.校团委、校学生会、社团联合会以及所有学生社团活动归口团委审批。</td></tr>
        <tr><td colspan="4">4.后勤管理处直接审批(适应于“就业指导中心”等特殊部门)。</td></tr>
        <tr>
          <td class="title"><font color="red">*</font>&nbsp;归口审核部门：</td>
          <td colspan="3">[@b.select items=departments?sort_by("name") name="roomApply.auditDepart.id" value=(roomApply.auditDepart.id)!("") /]</td>
        </tr>
        <tr class="thead">
            <td colspan="5" align="center"><input type="button" [#if activityTypes?size==0 || departments?size==0]disabled="true"[/#if] onClick="editApply()" value="申请"/>&nbsp;&nbsp;<input type="button" onClick="this.form.reset()" value="重填"/></td>
        </tr>
    </table>
[/@]
<script language="JavaScript">
    function editApply() {
     var form = document.roomApplyForm;
        var a_fields;
        if(jQuery("#roomApplyTimeType").val()=="1"){
          a_fields = {
            'roomApply.borrower.addr':{'l':'借用人地址', 'r':true, 't':'f_addr'},
            'roomApply.borrower.mobile':{'l':'借用人手机', 'r':true, 't':'f_mobile','f':'unsigned'},
            'roomApply.borrower.email':{'l':'借用人E-mail', 'r':true, 't':'f_email', 'f':'email'},
            'roomApply.activity.name':{'l':'活动名称', 'r':true, 't':'f_name'},
            'roomApply.usage.id':{'l':'活动类型','r':true, 't':'f_activityType'},
            'roomApply.isFree':{'l':'是否具有营利性', 'r':true, 't':'f_isFree'},
            'roomApply.activity.speaker':{'l':'姓名及资料背景', 'r':true, 't':'f_speaker','mx':200},
            'roomApply.activity.attendee':{'l':'出席对象', 'r':true, 't':'f_attendee'},
            'roomApply.activity.attendance':{'l':'出席总人数', 'r':true, 't':'f_attendance', 'f':'unsigned'},
              'roomApply.applyTime.dateBegin':{'l':'教室使用日期的“起始日期”', 'r':true, 't':'f_begin_end','f':'date'},
              'roomApply.applyTime.dateEnd':{'l':'教室使用日期的“结束日期”', 'r':true, 't':'f_begin_end','f':'date'},
              'timeBegin':{'l':'教室使用的“开始”时间点', 'r':true, 't':'f_beginTime_endTime','f':'shortTime'},
              'timeEnd':{'l':'教室使用的“结束”时间点', 'r':true, 't':'f_beginTime_endTime','f':'shortTime'},
              'roomApply.applyTime.cycleCount':{'l':'时间周期', 'r':true, 't':'f_cycleCount', 'f':'positiveInteger'},
              'roomApply.applicant':{'l':'申请人签名', 'r':true, 't':'f_applicant'}
          };
        }else{
          a_fields = {
            'roomApply.borrower.addr':{'l':'借用人地址', 'r':true, 't':'f_addr'},
            'roomApply.borrower.mobile':{'l':'借用人手机', 'r':true, 't':'f_mobile'},
            'roomApply.borrower.email':{'l':'借用人E-mail', 'r':true, 't':'f_email', 'f':'email'},
            'roomApply.activity.name':{'l':'活动名称', 'r':true, 't':'f_name'},
            'roomApply.usage.id':{'l':'活动类型','r':true, 't':'f_activityType'},
            'roomApply.isFree':{'l':'是否具有营利性', 'r':true, 't':'f_isFree'},
            'roomApply.activity.speaker':{'l':'姓名及资料背景', 'r':true, 't':'f_speaker','mx':200},
            'roomApply.activity.attendee':{'l':'出席对象', 'r':true, 't':'f_attendee'},
            'roomApply.activity.attendance':{'l':'出席总人数', 'r':true, 't':'f_attendance', 'f':'unsigned'},
              'roomApply.applyTime.dateBegin':{'l':'教室使用日期的“起始日期”', 'r':true, 't':'f_begin_end','f':'date'},
              'roomApply.applyTime.dateEnd':{'l':'教室使用日期的“结束日期”', 'r':true, 't':'f_begin_end','f':'date'},
              'timeBegin':{'l':'教室使用的“开始”小节', 'r':true, 't':'f_beginTime_endTime','f':'unsigned'},
              'timeEnd':{'l':'教室使用的“结束”小节', 'r':true, 't':'f_beginTime_endTime','f':'unsigned'},
              'roomApply.applyTime.cycleCount':{'l':'时间周期', 'r':true, 't':'f_cycleCount', 'f':'positiveInteger'},
              'roomApply.applicant':{'l':'申请人签名', 'r':true, 't':'f_applicant'}
          };
      }
       var v = new validator(form, a_fields, null);
        if (v.exec()) {
            if(form['roomApply.applyTime.dateBegin'].value>form['roomApply.applyTime.dateEnd'].value){
               alert("借用开始日期大于结束日期");return;
            }
            if(jQuery("#roomApplyTimeType").val()=="1" && form['timeBegin'].value > form['timeEnd'].value){
               alert("借用开始时间大于结束时间");return;
            }
            if(jQuery("#roomApplyTimeType").val()=="0" && (parseInt(form['timeBegin'].value) > parseInt(form['timeEnd'].value) || parseInt(form['timeBegin'].value) == 0 || parseInt(form['timeEnd'].value) == 0)){
               alert("借用开始小节大于结束小节");return;
            }
            [#if maxUnitSize??]
            if(jQuery("#roomApplyTimeType").val()=="0" && parseInt(form['timeEnd'].value)>${maxUnitSize}){
               alert("借用小节超过最大小节数");return;
            }
            [/#if]

            var dateBegin = form["roomApply.applyTime.dateBegin"].value;
            var dateEnd = form["roomApply.applyTime.dateEnd"].value;
            var cycleCount = form["roomApply.applyTime.cycleCount"].value;

            var beginYear = parseInt(dateBegin.substr(0, 4));
            var beginMonth = parseInt(dateBegin.substr(5, 2));
            var beginDate = parseInt(dateBegin.substr(8, 2));
            var date1 = new Date(beginYear, beginMonth - 1, beginDate);
            var endYear = parseInt(dateEnd.substr(0, 4));
            var endMonth = parseInt(dateEnd.substr(5, 2));
            var endDate = parseInt(dateEnd.substr(8, 2));
            var date2 = new Date(endYear, endMonth - 1, endDate);
            var roomRequest=form["roomApply.roomRequest"].value;

            if (form["roomApply.applyTime.cycleType"].value == "2") {
                var tmp = new Date(date1.getFullYear(), date1.getMonth(), date1.getDate() + (7 * cycleCount));
                if (tmp.getFullYear() > date2.getFullYear() || tmp.getMonth() > date2.getMonth() || tmp.getDate() > date2.getDate()) {
                    alert("借用日期与时间周期不匹配。");
                    return;
                }
            } else if (form["roomApply.applyTime.cycleType"].value == "4") {
                var tmp = new Date(date1.getFullYear(), date1.getMonth() + cycleCount, date1.getDate());
                if (tmp.getFullYear() > date2.getFullYear() || tmp.getMonth() > date2.getMonth() || tmp.getDate() > date2.getDate()) {
                    alert("借用日期与时间周期不匹配。");
                    return;
                }
            }

            if (roomRequest.length >250){
                alert("其他要求最多只能输入250个字符");
          return;
              }

            bg.form.submit(form);
        }
    }

        jQuery(document).ready(function(){
      jQuery("#roomApplyTimeType").change(function(){
        if(jQuery(this).val()=="1"){
          jQuery("#roomApplyTimeTypeTd").html("<input type='text' name='timeBegin' size='10' class='LabeledInput' value='00:00' format='Time'  maxlength='5'/> - <input type='text' name='timeEnd' value='00:00'  size='10' maxlength='5'/> (时分 格式如09:00 共五位)")
        }else{
          jQuery("#roomApplyTimeTypeTd").html("<input type='text' name='timeBegin' size='10' class='LabeledInput' value='1' maxlength='2'/> - <input type='text' name='timeEnd' value='1'  size='10' maxlength='2'/> (请填写小节数[#if maxUnitSize??],最大小节数为${maxUnitSize}[/#if])")
        }
      })
    })

</script>
[@b.foot/]
