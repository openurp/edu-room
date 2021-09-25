[#ftl]
  <div class="card card-info card-primary card-outline">
    <div class="card-header">
      <h3 class="card-title">
        [#if building??]${building.name} 教室信息[#else]无教学楼 教室信息[/#if]
        <span class="badge badge-primary">${classrooms?size}</span>
      </h3>
    </div>
    [#assign typeCount={} /]
    [#assign typeCapacity={} /]
    [#assign typeCourseCapacity={} /]
    [#assign typeExamCapacity={} /]
    [#list classrooms as r]
      [#assign typeCount=typeCount+{r.roomType.name:1+typeCount[r.roomType.name]!0} /]
      [#assign typeCapacity=typeCapacity+{r.roomType.name:r.capacity+typeCapacity[r.roomType.name]!0} /]
      [#assign typeCourseCapacity=typeCourseCapacity+{r.roomType.name:r.courseCapacity+typeCourseCapacity[r.roomType.name]!0} /]
      [#assign typeExamCapacity=typeExamCapacity+{r.roomType.name:r.examCapacity+typeExamCapacity[r.roomType.name]!0} /]
    [/#list]
    <div class="card-body">
        <table class="table table-hover table-sm">
          <thead>
             <th>教室类型</th>
             <th>教室数</th>
             <th>容量</th>
             <th>上课容量</th>
             <th>考试容量</th>
          </thead>
          <tbody>
          [#list typeCapacity?keys as k]
           <tr>
            <td>${k}</td>
            <td>${typeCount[k]}</td>
            <td>${typeCapacity[k]}</td>
            <td>${typeCourseCapacity[k]}</td>
            <td>${typeExamCapacity[k]}</td>
           </tr>
           [/#list]
          </tbody>
         </table>
    </div>
    <div class="card-body">
        <table class="table table-hover table-sm">
          <thead>
             <th>代码</th>
             <th>名称</th>
             <th>教室类型</th>
             <th>容量</th>
             <th>上课容量</th>
             <th>考试容量</th>
          </thead>
          <tbody>
          [#list classrooms as classroom]
           <tr>
            <td>${classroom.code}</td>
            <td>[@b.a href="!calendar?id="+classroom.id]${classroom.name} [#if !classroom.roomNo??]<sup>虚拟</sup>[/#if][/@]</td>
            <td>${classroom.roomType.name}</td>
            <td>${classroom.capacity}</td>
            <td>${classroom.courseCapacity}</td>
            <td>${classroom.examCapacity}</td>
           </tr>
           [/#list]
          </tbody>
         </table>
    </div>
  </div>
