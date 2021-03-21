[#ftl]
[@b.head]
  <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=0">
  <link href="${base}/static/js/fullcalendar_old/fullcalendar.css" rel="stylesheet" />
  <link href="${base}/static/js/fullcalendar_old/fullcalendar.print.css" rel="stylesheet" media="print" />
  <script src="${base}/static/js/fullcalendar_old/lib/moment.min.js"></script>
  <script src="${base}/static/js/fullcalendar_old/fullcalendar.js"></script>
  <script src="${base}/static/js/fullcalendar_old/locale-all.js"></script>
  [#include "occupancy_m_css.ftl"/]
[/@]
  [#assign roomTitleHTML]<span style="color: blue">${room.name}</span>[/#assign]
  <div style="display: inline-block; margin-top: 20px; overflow-y: auto">
    <div id="occupancy"></div>
  </div>
  <div id="detail"></div>
  <script>
    $(function() {
      $(document).ready(function() {
        document.title = "${room.name?js_string + "房间占用情况查看"}";
        
        var colorMap = {};
        [#list activityTypes as activityType]
        colorMap["${activityType.id}"] =  "${colors[activityType_index + 1]!colors[0]}";
        [/#list]
        
        var now = "${now?string("yyyy-MM-dd")}";
        var nowValue = ${now?string("yyyyMMdd")};
        
        var eventMap = {};
        
        $("#occupancy").fullCalendar({
          "header": {
            "left": "prev,next today",
            "center": "title",
            "right": ""
          },
          "locale": "zh-cn",
          "titleFormat": "YYYY年M月",
          "defaultDate": now,
          "height": (screen.availHeight - 100) * 0.7,
          "navLinks": false,
          "eventLimit": true,
          "views": {
            "month": {
              "eventLimit": 4
            }
          },
          "eventLimitText": function() {
            return "更多";
          },
          "displayEventTime": false,
          //"displayEventEnd": true,
          "timeFormat": "HH:mm",
          "editable": false,
          "events": function(start, end, timezone, callback) {
            $.ajax({
              "type": "POST",
              "url": "${b.url("!stat_m")}",
              "async": false,
              "dataType": "text",
              "data": {
                "roomId": "${room.id}",
                "startAt": start.format("YYYY-MM-DD HH:mm:ss"),
                "endAt": end.format("YYYY-MM-DD HH:mm:ss")
              },
              "success": function(data) {
                callback(eval("(" + data + ")"));
              }
            });
          },
          "viewRender": function(view, element) {
            console.log(element.parent().prev());
            var titleObj = element.parent().prev().find(".fc-center").children().first();
            titleObj.parent().html("<h3>" + view.title + "${roomTitleHTML?js_string}房间占用情况</h3>");
            element.parent().prev().first().before(element.parent().prev().find(".fc-center"));
            
            $(".fc-select-day").removeClass("fc-select-day");
            if (nowValue >= parseInt(view.intervalStart.format("YYYYMMDD")) && nowValue <= parseInt(view.intervalEnd.format("YYYYMMDD"))) {
              element.find("td[data-date='" + now + "']").children().first().addClass("fc-select-day");
            } else {
              element.find("td[data-date='" + view.intervalStart.format("YYYY-MM") + "-01']").children().first().addClass("fc-select-day");
            }
            
            $("#detail").css("height", screen.availHeight - $("#occupancy")[0].offsetHeight - 60);
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
            //console.log($(".fc-select-day").size());
            if ($(".fc-select-day").size()) {
              //console.log($(".fc-select-day").parent().attr("data-date"));
              loadDay($.fullCalendar.moment($(".fc-select-day").parent().attr("data-date")));
            }
          },
          [#-- 
          "eventMouseover": function(event, jsEvent, view) {
            $(this).css("cursor", "pointer");
            $(this).css("border-color", "red");
            var contentDivObj = $(".content");
            if (0 == contentDivObj.size()) {
              var contentWidth = 200;
              contentDivObj = $("<div>");
              contentDivObj.addClass("content");
              contentDivObj.addClass("tooltip");
              contentDivObj.css("width", contentWidth + "px");
              contentDivObj.css("position", "absolute");
              contentDivObj.css("z-index", "999");
              
              var contentObj1 = $("<div>");
              contentObj1.html(event.activityType.name + " " + event.start.format("M月D日 HH:mm") + "-" + event.end.format("HH:mm"));
              contentObj1.css("padding", "5px");
              contentObj1.css("background-color", colorMap[event.activityType.id]);
              contentObj1.css("border-color", "grey");
              contentObj1.css("border-width", "1px");
              contentObj1.css("border-bottom-width", "0px");
              contentObj1.css("border-style", "solid");
              contentDivObj.append(contentObj1);
              
              var contentObj3 = $("<div>");
              contentObj3.html(event.title);
              contentObj3.css("padding", "5px");
              contentObj3.css("color", "black");
              contentObj3.css("background-color", "white");
              contentObj3.css("border-color", "grey");
              contentObj3.css("border-width", "1px");
              if (event.weeks > 1) {
                contentObj3.css("border-bottom-width", "0px");
              }
              contentObj3.css("border-style", "solid");
              contentDivObj.append(contentObj3);
              
              if (event.weeks > 1) {
                var contentObj4 = $("<div>");
                contentObj4.html(event.dateSpan);
                contentObj4.css("padding", "5px");
                contentObj4.css("color", "black");
                contentObj4.css("background-color", "#FFFF99");
                contentObj4.css("border-color", "grey");
                contentObj4.css("border-width", "1px");
                contentObj4.css("border-style", "solid");
                contentDivObj.append(contentObj4);
              }
              
              var arrowObj1 = $("<div>");
              arrowObj1.css("display", "block");
              arrowObj1.css("padding", "0px");
              arrowObj1.css("margin", "0px");
              arrowObj1.css("width", "0px");
              arrowObj1.css("height", "0px");
              arrowObj1.css("position", "absolute");
              arrowObj1.css("border-left", "5px solid transparent");
              arrowObj1.css("border-right", "5px solid transparent");
              arrowObj1.css("border-top", "10px solid grey");
              arrowObj1.css("left", (contentWidth / 2 - 5) + "px");
              arrowObj1.css("z-index", "1");
              contentDivObj.append(arrowObj1);
              var arrowObj2 = $("<div>");
              arrowObj2.css("display", "block");
              arrowObj2.css("padding", "0px");
              arrowObj2.css("margin", "0px");
              arrowObj2.css("width", "0px");
              arrowObj2.css("height", "0px");
              arrowObj2.css("position", "absolute");
              arrowObj2.css("border-left", "5px solid transparent");
              arrowObj2.css("border-right", "5px solid transparent");
              arrowObj2.css("border-top", "10px solid " + (event.weeks > 1 ? "#FFFF99" : "white"));
              arrowObj2.css("left", (contentWidth / 2 - 5) + "px");
              arrowObj2.css("z-index", "2");
              contentDivObj.append(arrowObj2);
              $("#occupancy").parent().append(contentDivObj);
              contentDivObj.css("top", $(this).offset().top - contentDivObj[0].offsetHeight - 10);
              contentDivObj.css("left", $(this).offset().left);
              arrowObj2.css("top", arrowObj2.position().top - 2);
            }
          },
          "eventMouseout": function(event, jsEvent, view) {
            $(".content").remove();
            $(this).css("border-color", colorMap[event.activityType.id]);
          }
           --]
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
          console.log(timeValue);
            [#-- 
          var events = $("#occupancy").fullCalendar("clientEvents", function(event) {
            $("#occupancy1")[0].innerHTML = "1";
            for (var m in event) {
              $("#detail")[0].innerHTML += m + " = " + event[m] + "<br><br>";
            }
            var eventStart = event.start.format('YYYY-MM-DD');
            var eventEnd = event.end ? event.end.format('YYYY-MM-DD') : null;
            return dateValue >= eventStart && (dateValue <= eventEnd || null == eventEnd);
          });
         --]
         
          var events = eventMap[dateValue] || [];
          //console.log(events);
          
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
        }
      });
    });
  </script>
[@b.foot/]