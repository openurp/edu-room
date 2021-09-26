[#ftl]
[@b.head/]
[#include "info_macros.ftl"/]
[#if building??]
  [@info_header title=building.name+"占用情况"/]
[#else]
  [@info_header title="其他教室占用情况"/]
[/#if]

  [#assign typeCount={} /]
  [#assign typeCapacity={} /]
  [#assign typeCourseCapacity={} /]
  [#assign typeExamCapacity={} /]
  [#assign typeClassrooms={} /]

  [#list classrooms as r]
    [#assign typeCount=typeCount+{r.roomType.name:1+typeCount[r.roomType.name]!0} /]
    [#assign typeCapacity=typeCapacity+{r.roomType.name:r.capacity+typeCapacity[r.roomType.name]!0} /]
    [#assign typeCourseCapacity=typeCourseCapacity+{r.roomType.name:r.courseCapacity+typeCourseCapacity[r.roomType.name]!0} /]
    [#assign typeExamCapacity=typeExamCapacity+{r.roomType.name:r.examCapacity+typeExamCapacity[r.roomType.name]!0} /]
    [#assign typeClassrooms = typeClassrooms + {r.roomType.name:([r] + typeClassrooms[r.roomType.name]![])} /]
  [/#list]

<div class="container-fluid">
  <div class="row">
    <div class="card card-info card-primary card-outline col-3">
      <div class="card-header">
        ${(building.name)!}教室列表  [@b.a href="!index" style="float:right"]其他教学楼[/@]
      </div>
      <div class="card-body" style="padding-top: 0px;">
         <table class="table table-sm">
          <tbody>
        [#list typeClassrooms as type,rooms]
          <tr><td> ${type} <span class="badge badge-primary">${typeCount[type]}间</span>
             <span class="badge badge-primary">上课${typeCourseCapacity[type]}座</span>
             <span class="badge badge-primary">考试${typeExamCapacity[type]}座</span>
           </td></tr>

          <tr><td>
          <nav class="nav">
          [#list rooms?sort_by("name") as room]
          [@b.a href="!classroom?id="+room.id target="calendar_info"]
             ${room.name}&nbsp;
          [/@]
          [/#list]
          </nav>
           </td>
         </tr>

        [/#list]
          </tbody>
        </table>
      </div>
    </div>
    [@b.div href="!classroom?id="+roomId class="ajax_container col-9" id="calendar_info"/]
  </div>
</div>
[@b.foot/]
