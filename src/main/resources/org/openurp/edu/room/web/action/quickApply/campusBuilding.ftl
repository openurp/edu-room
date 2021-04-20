[#ftl]
[#list datas as data]
	<option value="${data.id}">${(data.name)!}</option>
[/#list]