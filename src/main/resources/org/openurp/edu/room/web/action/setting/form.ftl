[#ftl]
[@b.head/]
[@b.toolbar title="教室借用设置"]bar.addBack();[/@]
  [@b.form action=b.rest.save(roomApplySetting) theme="list"]
    [@b.radios name="roomApplySetting.opened" label="是否开放" value=roomApplySetting.opened required="true" items={'1':'开放','0':'关闭'}/]
    [@b.textfield check="match('number')" name="roomApplySetting.daysBeforeApply" label="提前天数" value=roomApplySetting.daysBeforeApply! required="true" comment="天"/]
    [@b.startend name="roomApplySetting.beginAt,roomApplySetting.endAt" label="每日借用时段" start=roomApplySetting.beginAt end=roomApplySetting.endAt required="true" format="HH:mm"/]
    [#list 1..3 as i]
      [#assign name]rt${i}.beginOn,rt${i}.endOn[/#assign]
      [#if reservedTimes[i-1]??]
        [#assign rt= reservedTimes[i-1]/]
        [@b.startend name=name start=rt.beginOn end=rt.endOn label="第${i}个保留时段"/]
      [#else]
        [@b.startend name=name label="第${i}个保留时段"/]
      [/#if]
    [/#list]
    [@b.editor rows="8" cols="50" name="roomApplySetting.notice" value=roomApplySetting.notice! label="借用须知" /]
    [@b.formfoot]
      [#list reservedTimes as rt]
        <input name="rt${rt_index+1}.id" type="hidden" value="${rt.id}"/>
      [/#list]
      [@b.reset/]&nbsp;&nbsp;[@b.submit value="action.submit"/]
    [/@]
  [/@]
[@b.foot/]
