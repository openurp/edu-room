[#ftl]
[@b.head/]
[@b.grid items=scopes var="scope"]
  [@b.gridbar]
    bar.addItem("${b.text('action.new')}", action.add());
    bar.addItem("${b.text('action.edit')}", action.edit());
    bar.addItem("${b.text('action.delete')}", action.remove());
  [/@]
  [@b.row]
    [@b.boxcol/]
    [@b.col property="depart.name" width="12%" title="院系"/]
    [@b.col property="beginAt" title="开始时间" width="12%"]${scope.beginAt?string('yy-MM-dd HH:mm')}[/@]
    [@b.col property="endAt" title="结束时间" width="12%"]${scope.endAt?string('yy-MM-dd HH:mm')}[/@]
    [@b.col title="使用教室" ]
        [#list scope.rooms?sort_by("code") as room]${(room.name)!}[#if room_has_next]&nbsp;[/#if][/#list]
    [/@]
  [/@]
[/@]
[@b.foot/]
