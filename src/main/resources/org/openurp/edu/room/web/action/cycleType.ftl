[#ftl]
[#macro cycleTypeSelect name cycleType  extra...]
    <select name="${name}"[#if (extra?size!=0)][#list extra?keys as attr] ${attr}="${(extra[attr]?html)!}"[/#list][/#if]>
        <option value="1" [#if cycleType == 1]selected[/#if]>天</option>
        <option value="2" [#if cycleType == 2]selected[/#if]>周</option>
    </select>
[/#macro]

[#assign cycleNames={'1':'天','2':'周'}/]
[#macro cycleValue count type]
每[#if count!=1]${count}[/#if]${cycleNames[(type?string)?default('1')]}
[/#macro]
