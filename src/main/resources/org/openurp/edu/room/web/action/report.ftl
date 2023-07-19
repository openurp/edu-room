[@b.head/]
    <table id="myBar" width="100%"></table>
    [#assign isStd = roomApply.applicant.user.category.name?contains('学生')/]
    <table style="font-size:14px;border-bottom:black 1px dotted" width="600px" align="center">
      <tr>
        <td>
          <table style="font-size:14px;line-height:0.75cm" width="100%">
            <tr>
                <th style="text-align:center;font-size:20px;height:70px;vertical-align:middle">教室借用凭证（存根）</th>
            </tr>
            <tr>
              [#assign tdStyle="border-bottom:black 1px solid;padding: 0px 0px 2px 0px"/]
              [#assign applicantDepartment = (roomApply.applicant.user.department)?if_exists/]
              <td style="text-align:justify;text-justify:inter-ideograph;text-indent:28px;font-family:宋体,MiscFixed">
                兹有<span style="${tdStyle}">${applicantDepartment.name}${roomApply.applicant.user.name}</span>
                ${isStd?string("同学", "老师")}(<span style="${tdStyle}">${isStd?string("学号", "工号")}&nbsp;${roomApply.applicant.user.code}</span>)，Tel<span>&nbsp;${roomApply.applicant.mobile}&nbsp;，
                因<span style="${tdStyle}">&nbsp;${roomApply.activity.name}&nbsp;</span>之需，
                于<span style="${tdStyle}">&nbsp;${roomApply.time}</span>
                借用<span style="${tdStyle}">&nbsp;[#list (roomApply.rooms?sort_by("name"))?if_exists as r]${r.name}[#sep]、[/#list]&nbsp;</span>。
              </td>
            </tr>
            <tr>
              <td style="text-align:justify;text-justify:inter-ideograph;text-indent:28px;font-family:宋体,MiscFixed">
               [#if roomApply.space.requireMultimedia]（要）使用教学设备（电脑，投影仪，扩音设备）[#else]（不）使用教学设备[/#if]
              </td>
            </tr>
          </table>
          <table width="150px" align="right" style="font-size:14px;text-align:center;font-family:宋体,MiscFixed">
            <tr>
              <td height="50px" valign="bottom">盖章：<span style="color:white">(各具体学院)</span></td>
            </tr>
            <tr>
              <td height="50px" valign="top">${.now?string("yyyy-MM-dd")}</td>
            </tr>
          </table>
        </td>
      </tr>
    </table>
    <table style="font-size:14px" width="600px" align="center">
      <tr>
        <td>
          <table style="font-size:14px;line-height:0.75cm" width="100%">
            <tr>
              <th style="text-align:center;font-size:20px;height:70px;vertical-align:middle">教室借用凭证（存根）</th>
            </tr>
            <tr>
              <td style="text-align:justify;text-justify:inter-ideograph;text-indent:28px;font-family:宋体,MiscFixed">
                兹有<span style="${tdStyle}">${applicantDepartment.name}${roomApply.applicant.user.name}</span>
                ${isStd?string("同学", "老师")}(<span style="${tdStyle}">${isStd?string("学号", "工号")}&nbsp;${roomApply.applicant.user.code}</span>)
                ，Tel<span>&nbsp;${roomApply.applicant.mobile}&nbsp;，
                因<span style="${tdStyle}">&nbsp;${roomApply.activity.name}&nbsp;</span>之需，
                于<span style="${tdStyle}">&nbsp;${roomApply.time}</span>
                借用<span style="${tdStyle}">&nbsp;[#list roomApply.rooms?sort_by("name") as r]${r.name}[#sep]、[/#list]&nbsp;</span>。
             </td>
            </tr>
            <tr>
              <td style="text-align:justify;text-justify:inter-ideograph;text-indent:28px;font-family:宋体,MiscFixed">
              [#if roomApply.space.requireMultimedia]（要）使用教学设备（电脑，投影仪，扩音设备）[#else]（不）使用教学设备[/#if]
              </td>
            </tr>
            <tr>
              <td style="text-align:justify;text-justify:inter-ideograph;text-indent:28px;font-family:宋体,MiscFixed">请管理人员届时开放教室，并于教室使用完毕后予以检查。</td>
            </tr>
          </table>
          <table width="150px" align="right" style="font-size:14px;text-align:center;font-family:宋体,MiscFixed">
            <tr>
              <td height="50px" valign="bottom"></td>
            </tr>
            <tr>
              <td height="20px" valign="top" style="text-align:left">签发人：</td>
            </tr>
            <tr>
              <td height="50px" valign="top">${.now?string("yyyy-MM-dd")}</td>
            </tr>
          </table>
        </td>
      </tr>
    </table>
    <table style="font-size:14px;border:black 1px solid;text-align:justify;text-justify:inter-ideograph;text-indent:28px;font-family:宋体,MiscFixed;line-height:0.75cm" width="600px" align="center">
      <tr>
        <td>以下部分由物业管理人员填写</td>
      </tr>
      <tr>
        <td>教室借用情况（用“√”表示）</td>
      </tr>
      <tr>
        <td>卫生状况：好<span style="${tdStyle};width:70px"></span>中<span style="${tdStyle};width:70px"></span>差<span style="${tdStyle};width:70px"></span></td>
      </tr>
      <tr>
        <td>课桌复位：已复位<span style="${tdStyle};width:70px"></span>未复位<span style="${tdStyle};width:70px"></span></td>
      </tr>
      <tr>
        <td>教学设备归还：电脑<span style="${tdStyle};width:70px"></span>投影仪<span style="${tdStyle};width:70px"></span>扩音设备<span style="${tdStyle};width:70px"></span></td>
      </tr>
      <tr>
        <td height="30px"></td>
      </tr>
      <tr>
        <td style="text-indent:${14*20}px">物业保安签名：</td>
      </tr>
      <tr>
        <td style="text-indent:${14*25}px">
          <span style="width:30px;display: inline-block;"></span>年
          <span style="width:30px;display: inline-block;"></span>月
          <span style="width:30px;display: inline-block;"></span>日</td>
      </tr>
    </table>
    <table style="font-size:14px;font-family:宋体,MiscFixed;line-height:0.75cm" width="600px" align="center">
      <tr>
        <td height="80px">注：本回执由教学值班室汇总后交教务处存档</td>
      </tr>
    </table>
    <script type="text/javascript">
        var bar =new ToolBar("myBar","教室借用凭证",null,true,true);
        bar.addPrint("<@msg.message key="action.print"/>");
    </script>
[@b.foot/]
