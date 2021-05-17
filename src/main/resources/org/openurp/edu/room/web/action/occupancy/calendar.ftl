[#ftl]
[@b.head/]
  [#assign colors = [ "black", "rgb(148, 174, 243)", "pink", "PaleGreen", "Orchid", "Cyan", "Orange", "NavajoWhite", "DarkKhaki" , "Purple", "Lime", "Yellow" ]/]
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
    .event-tip {
      position:absolute;
      z-index:999;
    }
    .event-tip-category{
       padding:5px;
       border-color:grey;
       border-width:1px;
       border-bottom-width:0px;
       border-style:solid;
    }
    .event-tip-title{
       padding:5px;
       color:black;
       background-color:white;
       border-color:grey;
       border-width:1px;
       border-style:solid;
    }
    .event-tip-remark{
       padding:5px;
       color:black;
       background-color:#FFFF99;
       border-color:grey;
       border-width:1px;
       border-style:solid;
    }
    .event-tip-arrow{
       padding:0px;
       margin:0px;
       width:0px;
       height:0px;
       position:absolute;
       display:block;
       border-left:5px solid transparent;
       border-right:5px solid transparent;
    }
  </style>
  <div class="container">
  <div class="row" >
    <div class="col-10"><strong>${room.name} 房间占用情况</strong></div>
    <div class="col-2" style="font-size: 15px;text-align: right;">
      [#list activityTypes as activityType]
        <span style="display:inline-block;background-color: ${(colors[activityType_index + 1])!colors[0]};width: 18px">&nbsp;</span>
        <span[#if activityType_has_next] style="padding-right: 10px"[/#if]>${activityType.name}</span>
      [/#list]
      </div>
  </div>
  <div style="margin-top: 20px;">
    <div id="occupancy"></div>
  </div>
</div>
  <script>
    var roomName="${room.name?js_string}"
    $(function() {
      $(document).ready(function() {
        document.title = roomName + "房间占用情况查看";

        var colorMap = {};
        [#list activityTypes as activityType]
        colorMap["${activityType.id}"] =  "${colors[activityType_index + 1]!colors[0]}";
        [/#list]

        function pageResize() {
          $("#occupancy").parent().css("height", $(window).height() - $("#occupancy")[0].offsetTop - 50);
        }

        pageResize();
        bg.load(["fullcalendar","fullcalendar-locale"],function(){
          var occupancyEl = document.getElementById('occupancy');
          var calendar = new FullCalendar.Calendar(occupancyEl, {
            "headerToolbar": {
              "left": "prev,next today",
              "center": "title",
              "right": "dayGridMonth,timeGridWeek,listWeek"
            },
            "locale": "zh-cn",
            "initialDate": "${now?string("yyyy-MM-dd")}",
            "navLinks": true,
            "editable": false,
            "handleWindowResize": true,
            "events": function(range, process, timezone, callback) {
              $.ajax({
                "type": "POST",
                "url": "${b.url("!stat")}",
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
            "eventDidMount": function(arg) {
               jQuery(arg.el).css("background-color", colorMap[arg.event.extendedProps.activityType.id]);
               jQuery(arg.el).css("border-color", colorMap[arg.event.extendedProps.activityType.id]);
            },
            "eventMouseEnter": function(arg) {
              var event = arg.event;
              var el=arg.el;
              [#-- 下面是tooltip --]
              $(el).css("cursor", "pointer");
              $(el).css("border-color", "red");
              var contentDivObj = $(".content");
              if (0 == contentDivObj.length) {
                var contentWidth = 200;
                contentDivObj = $("<div>");
                contentDivObj.addClass("event-tip");
                contentDivObj.css("width", contentWidth + "px");

                var contentObj1 = $("<div>");
                contentObj1.html(event.extendedProps.activityType.name + " " + formatRange(event.start,event.end));
                contentObj1.css("background-color", colorMap[event.extendedProps.activityType.id]);
                contentObj1.addClass("event-tip-category");

                contentDivObj.append(contentObj1);

                var contentObj3 = $("<div>");
                contentObj3.html(event.title);
                contentObj3.addClass("event-tip-title");
                if (event.extendedProps.weeks > 1) {
                  contentObj3.css("border-bottom-width", "0px");
                }
                contentDivObj.append(contentObj3);

                if (event.extendedProps.weeks > 1) {
                  var contentObj4 = $("<div>");
                  contentObj4.html(event.extendedProps.dateSpan);
                  contentObj4.addClass("event-tip-remark");
                  contentDivObj.append(contentObj4);
                }

                var arrowObj1 = $("<div>");
                arrowObj1.addClass("event-tip-arrow");
                arrowObj1.css("border-top", "10px solid grey");
                arrowObj1.css("left", (contentWidth / 2 - 5) + "px");
                arrowObj1.css("z-index", "1");
                contentDivObj.append(arrowObj1);
                var arrowObj2 = $("<div>");
                arrowObj2.addClass("event-tip-arrow");
                arrowObj2.css("border-top", "10px solid " + (event.extendedProps.weeks > 1 ? "#FFFF99" : "white"));
                arrowObj2.css("left", (contentWidth / 2 - 5) + "px");
                arrowObj2.css("z-index", "2");
                contentDivObj.append(arrowObj2);
                $("#occupancy").parent().append(contentDivObj);
                contentDivObj.css("top", $(el).offset().top - contentDivObj[0].offsetHeight - 10);
                contentDivObj.css("left", $(el).offset().left);
                arrowObj2.css("top", arrowObj2.position().top - 2);
              }
            },
            "eventMouseLeave": function(arg) {
              $(".event-tip").remove();
              $(arg.el).css("border-color", colorMap[arg.event.extendedProps.activityType.id]);
            },
            "windowResize": function(view) {
              pageResize();
            }
          });
          calendar.render();
          //var title=jQuery("#occupancy > .fc-header-toolbar .fc-toolbar-title").text();
        });//load fullcalendar
      });
    });

    function formatDate(d){
      var str= d.toISOString()
      return str.substring(0,str.indexOf("T"));
    }
    function formatRange(start,end){
      var startValue =  leftPad2((start.getMonth()+1)) +"-" + leftPad2(start.getDate())+" "+leftPad2(start.getHours())+":"+leftPad2(start.getMinutes());
      var endValue = leftPad2(end.getHours())+":"+leftPad2(end.getMinutes());
      return startValue +"~" + endValue;
    }
    function leftPad2(num){
       var s= ""+num;
       if(s.length<2){
          return "0"+s;
       }else{
          return s;
       }
    }
  </script>
[@b.foot/]
