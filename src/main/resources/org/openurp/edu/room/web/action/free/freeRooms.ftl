[#ftl]
  <table class="table table-hover table-sm table-striped table-bordered">
    <thead>
       <th>序号</th>
       <th>名称</th>
       <th>教室类型</th>
       <th>教学楼</th>
       <th>容量</th>
    </thead>
    <tbody>
    [#list classrooms as classroom]
     <tr>
      <td>${classroom_index+1}</td>
      <td>${classroom.name} [#if !classroom.roomNo??]<sup>虚拟</sup>[/#if]</td>
      <td>${classroom.roomType.name}</td>
      <td>${(classroom.building.name)!}</td>
      <td>${classroom.courseCapacity}</td>
     </tr>
     [/#list]
    </tbody>
   </table>
