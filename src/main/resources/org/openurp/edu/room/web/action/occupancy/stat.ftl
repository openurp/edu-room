[#ftl]
[[#list occupancies as occupancy]
  [#list occupancy.time.dates as date]
  {
    "title": "${occupancy.comments?replace("\n", "")?js_string}",
    "start": "${date?string("yyyy-MM-dd")}T${occupancy.time.beginAt}",
    "end": "${date?string("yyyy-MM-dd")}T${occupancy.time.endAt}",
    "extendedProps":{
       "activityType": {
          "id": "${occupancy.activityType.id}",
          "name": "${occupancy.activityType.name}"
       },
      "dateSpan": "${occupancy.time.firstDay?string('yyyy-MM-dd')}~${occupancy.time.lastDay?string('MM-dd')}(${occupancy.time.weekstate.weeks?size}次)",
      "weeks": ${occupancy.time.weekstate.size}
    }
  }[#if date_has_next || occupancy_has_next],[/#if]
  [/#list]
[/#list]]
