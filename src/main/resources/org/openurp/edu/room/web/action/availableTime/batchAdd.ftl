[#ftl]
[@b.head/]
${b.script("my97","WdatePicker.js")}
[@b.toolbar title="设置可用时间"]bar.addBack();[/@]
[@b.tabs]
[#--[@b.form action=b.rest.save(availableTime) theme="list" onsubmit="validTime"]--]
    [@b.form action="!batchSave" theme="list" onsubmit="validTime"]
			<table class="formTable" align="center" width="100%">
				<tr>
					<td class="title" align="right" width="15%"><font color="red">*</font>教室代码：</td>
					<td width="35%">
              <input name="availableTime.room" type="text" style="width:400px" title="教室代码"/>(多个教室代码使用,隔开)
					</td>
					<td class="title" id="f_cycleCount" align="right" width="15%"><font color="red">*</font>时间周期：</td>
					<td width="35%">每&nbsp;<input type="text" title="时间周期" name="cycleTime.cycleCount" style="width:20px" value="1"
														maxlength="2"/>
						<select name="cycleTime.cycleType" items={} label="">
							<option value="1">天</option>
							<option value="2">周</option>
						</select>
					</td>
				</tr>
				<tr>
					<td class="title" id="f_begin_end" align="right"><font color="red">*</font>教室使用日期：</td>
					<td>
						<input type="text" title="起始日期" readOnly="readOnly" id="beginOn" name="cycleTime.beginOn" class="Wdate"
									 onFocus="WdatePicker({dateFmt:'yyyy-MM-dd',maxDate:'#F{$dp.$D(\'endOn\')}'})" maxlength="10"
									 style="width:100px"/>
						- <input type="text" title="结束日期" readOnly="readOnly" id="endOn" name="cycleTime.endOn" class="Wdate"
										 onFocus="WdatePicker({dateFmt:'yyyy-MM-dd',minDate:'#F{$dp.$D(\'beginOn\')}'})" maxlength="10"
										 style="width:100px"/>
						(年月日)
					</td>
					<td class="title" id="f_beginTime_endTime" align="right"><font color="red">*</font>教室使用时间：</td>
					<td><input type="text" title="起始时间" id="beginAt" name="beginAt" style='width:50px' value="00:00" format="Time"
										 maxlength="5"/> - <input type="text" title="结束时间" name="endAt" id="endAt" value="00:00"
																							style='width:50px' maxlength="5"/> (时:分)&nbsp;&nbsp&nbsp;&nbsp&nbsp;&nbsp&nbsp;&nbsp
					</td>
				</tr>
			</table>
        [@b.formfoot]
            [@b.reset/]&nbsp;&nbsp;[@b.submit value="action.submit" /]
        [/@]
    [/@]
[/@]
<script>

	function validTime(form) {
		var beginOn = form["cycleTime.beginOn"].value;
		var endOn = form["cycleTime.endOn"].value;
		var cycleCount = parseInt(form["cycleTime.cycleCount"].value, 10);
		var beginYear = parseInt(beginOn.substr(0, 4), 10);
		var beginMonth = parseInt(beginOn.substr(5, 2), 10);
		var beginDate = parseInt(beginOn.substr(8, 2), 10);
		var date1 = new Date(beginYear, beginMonth - 1, beginDate);
		var endYear = parseInt(endOn.substr(0, 4), 10);
		var endMonth = parseInt(endOn.substr(5, 2), 10);
		var endDate = parseInt(endOn.substr(8, 2), 10);
		var date2 = new Date(endYear, endMonth - 1, endDate);
		var tmp;
		jQuery("input[name='availableTime.room']").require().match('notBlank')
		if (form["cycleTime.cycleType"].value == "2") {
			tmp = new Date(date1.getFullYear(), date1.getMonth(), date1.getDate() + (7 * cycleCount));
		} else if (form["cycleTime.cycleType"].value == "1") {
			tmp = new Date(date1.getFullYear(), date1.getMonth(), date1.getDate() + cycleCount - 1);
		}
		jQuery("#beginOn").require().match('notBlank').match(/^\d{1,4}[\/-]((0?\d)|(1[012]))[\/-]([012]?\d|30|31)$/);
		jQuery("#endOn").require().match('notBlank').match(/^\d{1,4}[\/-]((0?\d)|(1[012]))[\/-]([012]?\d|30|31)$/).assert(function () {
			return tmp <= date2;
		}, "可用日期与时间周期不匹配。");
		if (tmp > date2) {
			return false
		}
		jQuery("#cycleCount").require().match('notBlank').match('integer').greaterThan(0);
		jQuery("input[name='beginAt']").require().match('notBlank').match('time24');
		jQuery("input[name='endAt']").require().match('notBlank').match('time24').assert(function () {
			if (null == jQuery("input[name='endAt']").val() || null == jQuery("input[name='beginAt']")) {
				return true;
			}
			return parseInt(jQuery("input[name='beginAt']").val(), 10) < parseInt(jQuery("input[name='endAt']").val(), 10);
		}, "开始时间需小于结束时间");
		if (parseInt(jQuery("input[name='beginAt']").val(), 10) >= parseInt(jQuery("input[name='endAt']").val(), 10)) {
			return false
		}
		return true;
	}

</script>
[@b.foot/]
