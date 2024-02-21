  [#assign lastDayPartId=0/]
  [#assign seperatorIndexes=[]/]
  [#list units as u]
    [#if lastDayPartId=0]
      [#assign lastDayPartId = u.part.id/]
    [#else]
      [#if u.part.id != lastDayPartId]
        [#assign lastDayPartId = u.part.id/]
        [#assign seperatorIndexes = seperatorIndexes+[u.indexno-1]/]
      [/#if]
    [/#if]
  [/#list]
<style>
.text-ellipsis2{
  overflow: hidden;
  display: -webkit-box;
  -webkit-box-orient: vertical;
  -webkit-line-clamp: 2;
  white-space: pre-wrap;
}
</style>
<script>
  var seperatorIndexes=[[#list seperatorIndexes as i]${i}[#sep],[/#list]]
  function mergeCol(tableId, rowStart, colStart) {
    var rows = document.getElementById(tableId).rows;
    for (var i = rowStart; i < rows.length; i++) {
      for (var j = colStart + 1; j < rows[i].cells.length;) {
        var tdIds = rows[i].cells[j].id.split("_");
        if (rows[i].cells[j - 1].innerHTML == rows[i].cells[j].innerHTML && "" != rows[i].cells[j - 1].innerHTML && "" != rows[i].cells[j].innerHTML) {
          rows[i].removeChild(rows[i].cells[j]);
          rows[i].cells[j - 1].colSpan++;
          if (seperatorIndexes.includes(parseInt(tdIds[2]))) {
            rows[i].cells[j - 1].style.borderRightColor = "red";
          }else{
            rows[i].cells[j - 1].style.borderRightColor = "";
          }
        } else {
          if (seperatorIndexes.includes(parseInt(tdIds[2]))) {
            rows[i].cells[j].style.borderRightColor = "red";
          }else{
            rows[i].cells[j].style.borderRightColor = "";
          }
          j++;
        }
      }
    }
  }
</script>
