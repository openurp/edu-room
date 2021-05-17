[#ftl]
[@b.head]
  <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=0">
  [#include "occupancy_m_css.ftl"/]
[/@]
  [#assign roomTitleHTML]<span style="color: blue">${room.name}</span>[/#assign]
  <div style="display: inline-block; margin-top: 20px; overflow-y: auto">
    <div id="occupancy"></div>
  </div>
  <div id="detail"></div>
  <script>
    var roomName="${room.name?js_string}"
    $(function() {
      $(document).ready(function() {
        document.title = roomName + "房间占用情况查看";

        var colorMap = {};
        [#list activityTypes as activityType]
        colorMap["${activityType.id}"] =  "${colors[activityType_index + 1]!colors[0]}";
        [/#list]

        var now = "${now?string("yyyy-MM-dd")}";
        var nowValue = ${now?string("yyyyMMdd")};

        var eventMap = {};
        bg.load(["fullcalendar","fullcalendar-locale"],function(){
          var occupancyEl = document.getElementById('occupancy');
          "headerToolbar": {
            "left": "prev,next today",
            "center": "title",
            "right": ""
          },
          "locale": "zh-cn",
          "initialDate": now,
          "height": (screen.availHeight - 100) * 0.7,
          "navLinks": false,
          "eventLimitText": function() {
            return "更多";
          },
          "displayEventTime": false,
          "editable": false,
          "events": function(range, process, timezone, callback) {
            $.ajax({
              "type": "POST",
              "url": "${b.url("!stat_m")}",
              "async": false,
              "dataType": "text",
              "data": {
                "roomId": "${room.id}",
                  "beginOn": formatDate(range.start),
                  "endOn": formatDate(range.end)
              },
              "success": function(data) {
                process(eval("(" + data + ")"));
              }
            });
          },
          "dayRender": function(date, cell) {
            $(".fc-today").css("background-color", "MistyRose");
            $(".fc-today").css("border-color", "rgb(221, 221, 221)");
            eventMap[date.format("YYYY-MM-DD")] = [];
          },
          "eventRender": function(event, element, view) {
            element.addClass("event-" + colorMap[event.activityType.id]);
            eventMap[event.start.format("YYYY-MM-DD")].push(event);
            eventMap[event.start.format("YYYY-MM-DD")].sort(function(a, b) {
              return a.start - b.start;
            });
          },
          "eventAfterAllRender": function(view) {
            if ($(".fc-select-day").size()) {
              loadDay($.fullCalendar.moment($(".fc-select-day").parent().attr("data-date")));
            }
          },
          "dayClick": function(date, jsEvent, view) {
            $(".fc-select-day").removeClass("fc-select-day");
            $("td[data-date='" + date.format("YYYY-MM-DD") + "']").children().first().addClass("fc-select-day");

            loadDay(date);
          },
          "eventClick": function(event, jsEvent, view) {
            $(".fc-select-day").removeClass("fc-select-day");
            $("td[data-date='" + event.start.format("YYYY-MM-DD") + "']").children().first().addClass("fc-select-day");
            $(this).addClass("fc-select-day");

            loadDay(event.start, true);
          }
        });

        function loadDay(date, isPosition) {
          var dateValue = date.format("YYYY-MM-DD");
          var timeValue = date.format("HH:mm");

          var events = eventMap[dateValue] || [];

          $("#detail").empty();
          var headObj = $("<div>");
          headObj.addClass("detail-root");
          $("#detail").append(headObj);

          var headContentObj = $("<span>");
          headContentObj.addClass("detail-root-content");
          if (nowValue == date.format("YYYYMMDD")) {
            headContentObj.addClass("detail-root-content-today");
          }
          headContentObj.html(date.locale("zh-cn").format("YYYY年M月D日 dddd"));
          headObj.append(headContentObj);

          var occupancyListObj = $("<div>");
          occupancyListObj.addClass("detail-body");
          $("#detail").append(occupancyListObj);
          var positionItemObj = null;
          for (var i = 0; i < events.length; i++) {
            var occupancyObj = $("<div>");
            occupancyObj.addClass("occupancy");

            var titleObj = $("<div>");
            titleObj.addClass("title");
            titleObj.css("background-color", colorMap[events[i].activityType.id]);
            occupancyObj.append(titleObj);

            var titleValueObj = $("<span>");
            titleValueObj.addClass("title-value");
            titleValueObj.text(events[i].activityType.name);
            titleObj.append(titleValueObj);

            var timeObj = $("<span>");
            timeObj.addClass("time");
            timeObj.addClass("event-" + colorMap[events[i].activityType.id] + "-deep");
            timeObj.text(events[i].start.format("HH:mm") + " - " + events[i].end.format("HH:mm"));
            titleObj.append(timeObj);

            var contentObj = $("<div>");
            contentObj.addClass("content");
            contentObj.addClass("event-" + colorMap[events[i].activityType.id] + "-trans");
            occupancyObj.append(contentObj);

            var msgObj1 = $("<div>");
            msgObj1.addClass("msg");
            msgObj1.text(events[i].content);
            contentObj.append(msgObj1);

            if (events[i].weeks > 1) {
              var msgObj2 = $("<div>");
              msgObj2.addClass("msg");
              msgObj2.text(events[i].dateSpan);
              contentObj.append(msgObj2);
            }

            occupancyListObj.append(occupancyObj);
            if ((isPosition || false) && timeValue == events[i].start.format("HH:mm")) {
              positionItemObj = occupancyObj;
            }
          }

          console.log(positionItemObj);
          if (null != positionItemObj) {
            console.log(occupancyListObj[0].scrollTop);
            console.log(positionItemObj[0].offsetTop);
            console.log(occupancyListObj.position().top);
            occupancyListObj[0].scrollTop = positionItemObj[0].offsetTop - occupancyListObj.position().top - 10;
          }
         });
        });
      });
    });
  </script>
[@b.foot/]
