[@b.head/]

[#include "info_macros.ftl"/]
[@info_header title="占用情况"/]

<div class="container-fluid">
  <div class="row">
      <div class="card card-info card-primary card-outline col-3">
        <div class="card-header">
          教学楼列表
        </div>
        <div class="card-body" style="padding-top: 0px;">
           <table class="table table-hover table-sm">
            <tbody>
          [#assign displayCampuses=[]/]
          [#list buildings as building]
            <tr><td>
            [@b.a href="!index?buildingId="+building[1] ]
               ${building[2]}
               [#if !displayCampuses?seq_contains(building[0])]
               [#assign displayCampuses=displayCampuses+[building[0]]/] <span style="font-size:0.8rem;color: #999;">${building[0]}</span>[/#if]
            [/@]
             </td>
            <td>${building[3]}</td>
           </tr>
          [/#list]
             <tr><td>[@b.a href="!index?buildingId=0"]未写明具体教学楼[/@]</td><td></td></tr>
            </tbody>
          </table>
        </div>
      </div>
      <div id="classroom_info" class="col-9">
        [#include "classrooms.ftl"/]
      </div>
  </div>
</div>
[@b.foot/]
