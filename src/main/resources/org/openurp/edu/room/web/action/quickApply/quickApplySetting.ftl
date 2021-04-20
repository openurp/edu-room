[#ftl]
[@b.head/]
${b.script("my97","WdatePicker.js")}
[#import "../cycleType.ftl" as RoomApply/]
[@b.form action="!apply" method="post" name="roomApplyForm"]
    <table class="formTable" align="center" width="95%">
        <input type="hidden" name="roomIds" value="[#if roomIds?exists][#list  roomIds as id]${id},[/#list][/#if]"/>
        <tr class="thead" align="center">
            <td colspan="5"><B>[#list rooms as room]${room.name}[#if room_has_next],[/#if][/#list]教室借用填写表</B></td>
        </tr>
        <tr>
            <td class="title" align="center" rowspan="2" style="text-align:center">借用人</td>
            <td class="title" align="right" width="15%" id="f_username"><font color="red">*</font>&nbsp;姓名：</td>
            <td width="25%"><input type="text" title="借用人" name="roomApply.borrower.applicant" maxlength="20" value="${(roomApply.borrower.applicant)!}" /></td>
            </td>
            <td class="title" align="right" id="f_mobile" width="15%" ><font color="red">*</font>&nbsp;手机：</td>
            <td width="25%"><input type="text" title="手机" name="roomApply.borrower.mobile" size="15" maxlength="20"/></td>
        </tr>
        <tr>
            <td class="title" align="right" ><font color="red">*</font>&nbsp;归口部门：</td>
            <td colspan="3">[@b.select title="归口部门" empty="..." items=departments?sort_by("name") name="roomApply.borrower.department.id" value=(roomApply.borrower.department)! label="" required="true"/]</td>
        </tr>
        <tr>
            <td class="title" align="center" rowspan="2" style="text-align:center">借用用途、性质</td>
            <td class="title" align="right" id="f_activityName"><font color="red">*</font>&nbsp;活动名称：</td>
            <td><input type="text" title="活动名称" name="roomApply.activity.name" size="40" maxlength="50"/></td>
            <td class="title" align="right" id="f_attendance"><font color="red">*</font>&nbsp;出席总人数：</td>
            <td><input type="text" name="roomApply.activity.attendanceNum" title="出席总人数" maxlength="5" value="${maxCapacity!}" style="width:50px"/>(教室总容量${maxCapacity!})
            </td>
        </tr>
        <tr>
            <td class="title" align="right" id="f_activityType"><font color="red">*</font>&nbsp;活动类型：</td>
            <td colspan="3">
                [#if activityTypes?size > 0]
                    [#list activityTypes as activityType]
                        <input type="radio" id="activityType${activityType.id}" name="roomApply.activity.activityType.id" [#if ((roomApply.activity.activityType.id)?? && roomApply.activity.activityType.id==activityType.id) || (!(roomApply.activity.activityType.id)?? && activityType_index==0)]checked[/#if] value="${activityType.id}"/><label for="activityType${activityType.id}">${(activityType.name?html)!}</label>&nbsp;&nbsp;
                    [/#list]
                [#else]
                    您没有活动类型数据,请先在基础代码中维护活动类型数据!
                [/#if]
            </td>
        </tr>
        	<input type="hidden" name="cycleTime.cycleCount" value="${cycleCount!}"/>
        	<input type="hidden" name="cycleTime.cycleType" value="${cycleType!}"/>
        	<input type="hidden" name="cycleTime.beginOn" value="${beginOn!}"/>
        	<input type="hidden" name="cycleTime.endOn" value="${endOn!}"/>
        	<input type="hidden" name="timeBegin" value="${timeBegin!}"/>
        	<input type="hidden" name="timeEnd" value="${timeEnd!}"/>
        <tr >
            <td class="title" align="center" rowspan="3" style="text-align:center">借用时间要求</td>
            <td class="title" id="f_cycleCount" align="right">时间周期：</td>
            <td colspan="3">
                [#assign typeMap={'1':'天','2':'周'}]
                每&nbsp;${cycleCount!}&nbsp;${typeMap[cycleType]!}
            </td>
        </tr>
        <tr>
            <td class="title" id="f_begin_end" align="right">&nbsp;教室使用日期：</td>
            <td colspan="3">${beginOn!}~${endOn!}
            </td>
        </tr>
        <tr>
            <td class="title" id="f_beginTime_endTime" align="right">&nbsp;教室使用时间：</td>
            <td colspan="3">${timeBegin!}-${timeEnd!}
						</td>
        </tr>
        <tr class="thead">
            <td colspan="5" align="center">
                <input type="button" onClick="apply()" value="申请"/>&nbsp;&nbsp;
                <input type="button" onClick="this.form.reset()" value="重置"/>
            </td>
        </tr>
    </table>
[/@]
<script>
    beangle.load(["jquery-validity"]);
    function apply() {
        jQuery.validity.start();
        var form = document.roomApplyForm;
        jQuery("input[name='roomApply.borrower.applicant']").require().match('notBlank');
        jQuery("input[name='roomApply.borrower.mobile']").require().match('notBlank');
        jQuery("input[name='roomApply.activity.name']").require().match('notBlank');
        jQuery("select[name='roomApply.borrower.department.id']").require();
        jQuery("input[name='roomApply.activity.attendanceNum']").require().match('notBlank').match('integer').range(0,${maxCapacity!(0)});
        if(jQuery.validity.end().valid) {
            bg.form.submit(form);
        }
    }

</script>
[@b.foot/]
