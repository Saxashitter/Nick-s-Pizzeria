return function(v)
	if not PTV3.pizzatime then return end
	if PTV3.hud_pt < 0 then return end
	local time = PTV3.HUD_returnTime(PTV3.hud_pt, 3*FU)
	
	local patch = (leveltime % 4) / 2 and v.cachePatch('PITIM1') or v.cachePatch('PITIM2')
	local scale = FU/3
	local x = (160*FU) - ((patch.width/2)*scale)
	local y = ease.linear(time, (v.height()/v.dupx())*FU, -(patch.height*scale))

	v.drawScaled(x,y,scale,patch,V_SNAPTOTOP)
end