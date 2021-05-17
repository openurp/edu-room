[#ftl]
[#assign colors     = [ "black",   "LightSteelBlue", "pink",          "PaleGreen",     "Orchid",        "Cyan",         "Orange",      "NavajoWhite",   "DarkKhaki",     "MediumOrchid", "Lime",      "Yellow" ]/]
[#assign colorTrans = [ "0, 0, 0", "176, 196, 222",  "255, 192, 203", "152, 251, 152", "218, 112, 214", "0, 255, 255",  "255, 165, 0", "255, 222, 173", "189, 183, 107", "186, 85, 211", "0, 255, 0", "255, 255, 0" ]/]
[#assign colorDeeps = [ "0, 0, 0", "32, 52, 222",   "255, 74, 108",   "52, 151, 52",   "216, 5, 216",   "0, 127, 127", "205, 155, 0", "255, 166, 49",  "186, 174, 63",  "169, 2, 209",  "0, 124, 0", "124, 124, 0" ]/]
<style>
  .fc-title {
    white-space: pre-wrap;
    text-align: center;
    width: 100%;
    display: inline-block;
  }
  .fc-content {
    color: black;
  }
  a.fc-more {
    text-align: right;
    display: inline-block;
    width: 80%;
    color: blue;
    font-size: 10pt;
  }
  [#list colors as color]
  .event-${color} {
    background-color: ${color};
    border-color: ${color};
  }

  .event-${color}-trans {
    background-color: rgba(${colorTrans[color_index]}, 0.5);
    border-color: rgba(${colorTrans[color_index]}, 0.5);
  }

  .event-${color}-deep {
    color: rgb(${colorDeeps[color_index]});
  }
  [/#list]

  body {
    margin-left: 10px;
    margin-right: 10px;
    overflow: hidden;
  }

  table.legend {
    font-size: 15px;
    table-layout: fixed;
    border-width: 3px;
    border-style: double;
    border-color: blue;
  }

  table.legend td {
    width: 10px;
    vertical-align: top;
  }

  #detail {
    background-color: WhiteSmoke;
    margin-top: 10px;
    padding: 10px;
    overflow-y: hidden;
  }

  #detail .detail-root {
    font-size: 12pt;
  }

  #detail .detail-root .detail-root-content {
    font-weight: bold;
  }

  #detail .detail-root .detail-root-content.detail-root-content-today {
    color: red;
  }

  #detail .detail-body {
    margin-top: 10px;
    height: 80%;
    overflow-y: auto;
  }

  #detail .detail-body .occupancy {
    margin-bottom: 10px;
  }

  #detail .detail-body .occupancy .title {
    font-weight: bold;
    height: 20px;
    padding-top: 5px;
  }

  #detail .detail-body .occupancy .title .title-value {
    padding-right: 5px;
    font-weight: bold;
  }

  #detail .detail-body .occupancy .title .time {
    font-weight: bold;
    background-color: white;
    padding-left: 2px;
    padding-right: 2px;
  }

  #detail .detail-body .occupancy .content {
    filter:alpha(opacity=80);
    -moz-opacity:0.8;
  }

  #detail .detail-body .occupancy .content .msg {
  }

  .fc-select-day {
    border-width: 1px;
    border-style: solid;
    border-color: red;
  }

  .fc-center {
    text-align: center;
  }
</style>
