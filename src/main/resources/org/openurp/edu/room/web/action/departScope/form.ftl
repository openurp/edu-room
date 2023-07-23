[@b.head/]

[@b.form name="scopeForm" action=b.rest.save(scope) theme="list"]
  [@b.select name="scope.depart.id" items=departments value=scope.depart label="院系" required="true"/]
  [@b.startend name="scope.beginAt,scope.endAt" start=scope.beginAt! end=scope.endAt
               required="true" label="起始结束时间" format="datetime"/]
  [@b.select2 label="可借教室" name1st="roomId1st" name2nd="roomId2nd" style="height:100px;width:152px"
      items1st=classrooms items2nd=scope.rooms
      option="id,name"  required="true" style="width:height:300px;width:200px"/]
  [@b.formfoot]
    [@b.reset/]
    [@b.submit value="提交"/]
  [/@]
[/@]
