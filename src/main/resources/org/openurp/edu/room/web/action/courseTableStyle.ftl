[#ftl]
<style>
.courseUnit{cursor:pointer;}
</style>
[#assign weekMap={'Mon':'星期一','Tue':'星期二','Wed':'星期三','Thu':'星期四','Fri':'星期五','Sat':'星期六','Sun':'星期日'}]
[#macro initCourseTable(tableStyle,unitList,weekList)]
	[#if tableStyle==CourseTableStyle.WEEK_TABLE]
		<table width="100%" id="manualArrangeCourseTable" align="center" class="gridtable"  style="text-align:center">
			<thead>
			<tr>
		    	<th style="background-color:#DEEDF7;" height="10px" width="150px">节次/周几</td>
		    	[#list weekList as week]
		    	<script>weekArray[${week.id-1}]='${weekMap[week]}';</script>
		    	<th style="background-color:#DEEDF7;[#if weekMap[week]=='星期六' || weekMap[week]=='星期日'][#if !showWeekend!(true)]display:none[/#if][/#if]" [#if weekMap[week]=='星期六' || weekMap[week]=='星期日']class="weekend"[/#if]>
		        	<font size="2px">${weekMap[week]}</font>
				</th>
		    	[/#list]
			</tr>
			</thead>
			[#list unitList?sort_by("indexno") as unit]
			<tr>
				<script>unitArray[${unit_index}]='${unit.name}';</script>
			    <td style="background-color:${unit.part.color}">
		    		<font size="2px"> ${unit.name}
		    		${unit.beginAt}~${unit.endAt}</font>
				</td>
		  	    [#list weekList as week]
	   			<td id="TD${unit_index+(week.id-1)*unitList?size}" style="[#if week.id==6 || week.id==7][#if !showWeekend!(true)]display:none[/#if][/#if]" class="courseUnit infoTitle [#if weekMap[week]=='星期六' || weekMap[week]=='星期日']weekend[/#if]" onclick="toggleUnit(this);" title="${weekMap[week]} 第${unit_index+1}节"></td>
				[/#list]
			</tr>
		    [/#list]
		</table> 
	[#else]
	  	<table width="100%" align="center" class="gridtable" id="manualArrangeCourseTable" style="text-align:center">
	  		<thead>
	  		<tr height="10px">
	  			<th style="background-color: #DEEDF7;"></th>
	  			[#list unitList?sort_by("indexno") as unit]
				<th style="background-color:${unit.color}">
        			<font size="1px">${unit.beginAt}-${unit.endAt}</font>
				</th>
				[/#list]
	  		</tr>
	    	<tr>
	        	<th style="background-color: #DEEDF7;"></th>
	     		[#list unitList?sort_by("indexno") as unit]
	     		<script>unitArray[${unit_index}]=' ${unit.name}';</script>
				<th style="background-color: #DEEDF7;">
	             ${unit.name}
				</th>
				[/#list]
	    	</tr>
	    	</thead>
			[#assign units = unitList?size]
			<tbody>
				[#list weekList as week]
				<script>weekArray[${week.id-1}]='${weekMap[week]}';</script>
				<tr>
				    <td style="background-color: #DEEDF7;">${weekMap[week]}</td>
			  	    [#list 1..unitList?size as unit]
			   		<td id="TD${(week.id-1)*unitList?size+unit_index}" style="curson:point;" onclick="toggleUnit(this);" class="courseUnit"></td>
					[/#list]
				</tr>
			    [/#list]
		    </tbody>
		</table>
	[/#if]
[/#macro]
<script>
	var maxunits=${unitList?size};
	function selectUnit(weekday,fromunit,endunit){
		for(var i=fromunit;i<=endunit;i++){
			var indexno=(weekday-1)*maxunits+i-1;
			var td=document.getElementById( "TD"+ indexno);
			td.style.backgroundColor="yellow"
		}
	}
	function toggleUnit(td){
        if(td.style.backgroundColor=="yellow"){
			td.style.backgroundColor="white";
		} else {
			td.style.backgroundColor="yellow"
		}
    }
</script>