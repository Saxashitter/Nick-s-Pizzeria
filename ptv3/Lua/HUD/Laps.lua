freeslot("sfx_lap2")
sfxinfo[sfx_lap2].caption = "Ding Ding Ding!"

local function customTween(t, times)
	local ot = t/(FU/#times)
	return ease.linear(t/#times, times[ot+1], times[min(ot+2, #times)])
end

local function getPatchesFromNum(v, font, num)
	local patches = {}
	local str = tostring(num)

	for i = 1,#str do
		local byte = str:sub(i):byte()
		local patch = v.cachePatch(string.format("%s%03d", font, byte))
		if not patch then continue end

		table.insert(patches, patch)
	end

	return patches
end

return function(v,p)
	if not PTV3.pizzatime then return end
	if not p.ptv3 then return end
	if p.ptv3.lap_time < 0 then return end
	local time = ((leveltime - p.ptv3.lap_time)*(FU))/35
	
	if time > FU*5 then return end
	
	local lapgraph = v.cachePatch('PTLAP')
	local patches = getPatchesFromNum(v, "PTLAP", p.ptv3.laps)

	local scale = FU/3
	local x = (160*FU)-((lapgraph.width*scale)/2)
	local y = ease.linear(time, -lapgraph.height*scale, 4*FU)
	if time > FU*4 then
		y = ease.linear(time-(FU*4), 4*FU, -lapgraph.height*scale)
	elseif time > FU then
		y = 4*FU
	end
	v.drawScaled(x,y,scale,lapgraph,V_SNAPTOTOP)
	local fx = 0
	for _,patch in ipairs(patches) do
		local x = x + (165*scale)
		local fy = (91-patch.height)*scale
		
		v.drawScaled(x+fx,y+fy,scale,patch,V_SNAPTOTOP)
		fx = $+FixedDiv(patch.width*scale, FU)
	end
end