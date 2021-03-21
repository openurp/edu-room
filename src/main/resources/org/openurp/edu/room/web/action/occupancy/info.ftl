[#ftl]
[@b.head/]
  [#assign roomTitleHTML]<span style="color: blue">${room.name}</span>[/#assign]
[#--  <link href='${base}/static/js/fullcalendar/fullcalendar.css' rel='stylesheet' />--]
[#--  <link href='${base}/static/js/fullcalendar/fullcalendar.print.css' rel='stylesheet' media='print' />--]
[#--  <script src='${base}/static/js/fullcalendar/lib/moment.min.js'></script>--]
[#--  <script src='${base}/static/js/fullcalendar/fullcalendar.js'></script>--]
[#--  <script src='${base}/static/js/fullcalendar/locale-all.js'></script>--]
  <link href='${base}/static/js/fullcalendar/main.css' rel='stylesheet' />
  <script src='${base}/static/js/fullcalendar/main.js'></script>
  <script src='${base}/static/js/fullcalendar/locales-all.js'></script>
[#--  ${b.script("fullcalendar","main.min.js")}--]
[#--  ${b.script("fullcalendar","main.min.css")}--]
[#--  ${b.script("fullcalendar","locales-all.min.js")}--]
  [#assign colors = [ "black", "rgb(148, 174, 243)", "pink", "PaleGreen", "Orchid", "Cyan", "Orange", "NavajoWhite", "DarkKhaki" , "Purple", "Lime", "Yellow" ]/]
  <table align="right" style="font-size: 15px" cellpadding="0" cellspacing="0">
    <tr>
    [#list activityTypes as activityType]
      <td style="display:inline-block;background-color: ${(colors[activityType_index + 1])!colors[0]};width: 18px"><br></td>
      <td[#if activityType_has_next] style="padding-right: 10px"[/#if]>${activityType.name}</td>
    [/#list]
    </tr>
  </table>
  <style>
    .fc-title {
      white-space: pre-wrap;
    }
    .fc-content {
      color: black;
    }
    
    body {
      margin-left: 10px;
      margin-right: 10px;
    }
  </style>
  <div style="display: inline-block; margin-top: 20px; overflow-y: auto">
    <div id="occupancy"></div>
  </div>
  <script>
    $(function() {
      $(document).ready(function() {
        document.title = "${room.name?js_string + "房间占用情况查看"}";
        
        var colorMap = {};
        [#list activityTypes as activityType]
        colorMap["${activityType.id}"] =  "${colors[activityType_index + 1]!colors[0]}";
        [/#list]
        
        function pageResize() {
          $("#occupancy").parent().css("height", $(window).height() - $("table")[0].offsetHeight - $("#occupancy")[0].offsetTop - 50);
        }
        
        pageResize();
        
        $("#occupancy"). FullCalendar({
          "header": {
            "left": "prev,next today",
            "center": "title",
            "right": "month,basicWeek,basicDay"
          },
          "locale": "zh-cn",
          "titleFormat": "YYYY年M月",
          "defaultDate": "${now?string("yyyy-MM-dd")}",
          "navLinks": true,
          "eventLimit": true,
          "views": {
            "month": {
              "eventLimit": 4
            }
          },
          "editable": false,
          "handleWindowResize": true,
          "events": function(start, end, timezone, callback) {
            $.ajax({
              "type": "POST",
              "url": "${b.url("!stat")}",
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
          "timeFormat": "HH:mm",
          //"displayEventEnd": true,
          "viewRender": function(view, element) {
          [#-- 
            $("#occupancy1")[0].innerHTML = "";
            for (var m in view) {
              $("#occupancy1")[0].innerHTML += m + " = " + view[m] + "<br><br>";
            }
            return;
           --]
           element.parent().prev().find(".fc-center").children().first()[0].innerHTML += "${roomTitleHTML?js_string}房间占用情况";
          },
          "eventRender": function(event, element, view) {
            //$("#occupancy1")[0].innerHTML += event.title + ", " + event.activityType.id + ", " + element[0].tagName + "<br>";
            element.css("background-color", colorMap[event.activityType.id]);
            element.css("border-color", colorMap[event.activityType.id]);
          },
          "eventMouseover": function(event, jsEvent, view) {
            [#-- 下面是tooltip --]
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
          },
          "windowResize": function(view) {
            pageResize();
          }
        });
      });
    });
  </script>
  <div id="occupancy1" style="margin-top: 50px"></div>
[@b.foot/]