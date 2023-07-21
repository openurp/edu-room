[#ftl]
[@b.head/]
[@b.toolbar title="教室借用设置"]
  bar.addItem("修改","editSetting()");
  function editSetting(){
    bg.form.submit(document.settingEditForm);
  }
[/@]
<table class="infoTable" id="setting_info">
  <tr>
    <td class="title" width="20%">是否开放申请</td>
    <td class="content">${setting.opened?string('开放','关闭')}</td>
    <td class="title" width="20%">申请人应提前多少天提出申请</td>
    <td class="content">${setting.daysBeforeApply}天</td>
  </tr>
  <tr>
    <td class="title">每日可申请的时段</td>
    <td class="content" colspan="3">${setting.beginAt}~${setting.endAt}</td>
  </tr>
  <tr>
    <td class="title">申请须知</td>
    <td class="content" colspan="3">
      ${setting.notice!}
    </td>
  </tr>
</table>

[#if setting.id??]
  [@b.form name="settingEditForm" action="!edit?id="+setting.id/]
[#else]
  [@b.form name="settingEditForm" action="!editNew"/]
[/#if]
[@b.foot/]
