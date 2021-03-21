[#ftl]
[[#list occupancies as occupancy]
  [#list occupancy.time.dates as date]
  {
    "title": "${occupancy.comments?replace("\n", "")?js_string}",
    "start": "${date?string("yyyy-MM-dd")}T${occupancy.time.beginAt}",
    "end": "${date?string("yyyy-MM-dd")}T${occupancy.time.endAt}",
    "activityType": {
      "id": "${occupancy.activityType.id}",
      "name": "${occupancy.activityType.name}"
    },
    "dateSpan": "重复${occupancy.time.weekstate.weeks}次 ${occupancy.time.firstDay?string('yyyy-MM-dd')}~${occupancy.time.lastDay?string('MM-dd')}",
    "weeks": ${occupancy.time.weekstate.weeks}
  }[#if date_has_next || occupancy_has_next],[/#if]
  [/#list]
[/#list]]