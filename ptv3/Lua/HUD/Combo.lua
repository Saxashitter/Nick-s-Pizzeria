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

return function(v,p,c)
	if not PTV3:isPTV3() then return end
	if not p.ptv3 then return end
	
	local MAX_COMBO_TIME = 10*FU
	
	if p.ptv3.combo_rank
	and leveltime-p.ptv3.combo_rank.time < 5*TICRATE then
		local x = 230*FU
		local y = 30*FU
		local scale = FU/3

		v.drawScaled(x, y, scale, v.cachePatch('CRSTART'), V_SNAPTOTOP|V_SNAPTORIGHT)
		v.drawScaled(x-(12*scale), y+(18*scale), scale, v.cachePatch('CR'..p.ptv3.combo_rank.rankn..'_'..leveltime % 2), V_SNAPTOTOP|V_SNAPTORIGHT)
		--if p.ptv3.combo_rank.very then
			v.drawScaled(x-(40*scale), y+(23*scale), scale, v.cachePatch('CRVERY'), V_SNAPTOTOP|V_SNAPTORIGHT)
		--end
	end
	
	if not (p.ptv3.combo or p.ptv3.combo_offtime) then return end
	
	local x = 230*FU
	local scale = FU/3
	scale = $+($/8)
	x = $ + FixedMul(8*scale, cos(((leveltime*2) % 360) * ANG1))
	local targety = 0
	if p.pvars and p.pvars.tv then
		targety = 40*FU
	end
	local bar = v.cachePatch('COMBOBAR')
	local time = min(((leveltime - p.ptv3.combo_start_time)*(FU*2))/35, FU+1)
	local y = ease.linear(time, -bar.height*scale, targety)
	if p.ptv3.combo_offtime then
		time = min(((leveltime - p.ptv3.combo_offtime)*(FU*2))/35, FU+1)
		y = ease.linear(time, targety, -bar.height*scale)
	else
		if p.ptv3.combo_pos <= MAX_COMBO_TIME/2 then
			local time = (leveltime-p.ptv3.combo_start_time)*25
			y = $ - abs(FixedMul(6*scale, sin(time*ANG1)))
		end
	end

	local start_point = 40*scale
	local end_point = (bar.width*scale) - 30*scale
	
	local combopos = FixedDiv(p.ptv3.combo_display, MAX_COMBO_TIME)
	
	local pos = start_point + FixedMul(end_point-start_point, combopos)
	
	local pointer = v.cachePatch('COMBOGUY'..(leveltime % 8))
	local center = pointer.width*(scale/2)
	v.drawScaled(x + pos - center,
		y+(40*scale),
		scale,
		pointer,
		V_SNAPTOTOP|V_SNAPTORIGHT
	)

	v.drawScaled(x, y, scale, bar, V_SNAPTORIGHT|V_SNAPTOTOP)
	
	local patches = getPatchesFromNum(v,"PTCMB",p.ptv3.combo)

	for _,i in ipairs(patches) do
		local add = (26*scale) * (#patches - _)
		local add2 = (-4*scale) * (#patches - _)
		v.drawScaled(x+(18*scale)-add, y+(85*scale)+add2, scale, i, V_SNAPTOTOP|V_SNAPTORIGHT)
	end
end