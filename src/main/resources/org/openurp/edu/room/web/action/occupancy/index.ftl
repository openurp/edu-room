[@b.head/]

[#include "info_macros.ftl"/]
[@info_header title="占用情况"/]

<div class="container-fluid">
<div class="row">
  <div class="col-3">
    <div class="card card-info card-primary card-outline">
      <div class="card-header">
        教学楼列表
      </div>
      <div class="card-body" style="padding-top: 0px;">
         <table class="table table-hover table-sm">
          <tbody>
        [#assign displayCampuses=[]/]
        [#list buildings as building]
          <tr><td>
          [@b.a href="!building?id="+building[1] target="classroom_info"]
             ${building[2]}
             [#if !displayCampuses?seq_contains(building[0])]
             [#assign displayCampuses=displayCampuses+[building[0]]/] <span style="font-size:0.8rem;color: #999;">${building[0]}</span>[/#if]
          [/@]
           </td>
          <td>${building[3]}</td>
         </tr>
        [/#list]
           <tr><td>[@b.a href="!building?id=0" target="classroom_info"]未写明具体教学楼[/@]</td><td></td></tr>
          </tbody>
        </table>
      </div>

    </div>
  </div>
  [#if buildings?size>0]
  [@b.div href="!building?id="+buildings?first[1] class="col-9" id="classroom_info"/]
  [#else]
  [@b.div href="!building?id=0" class="col-9" id="classroom_info"/]
  [/#if]
[@b.foot/]
