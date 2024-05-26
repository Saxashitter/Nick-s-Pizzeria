local function drawBarFill(v, x, y, patch, flags, scale, offset, length, color)
	local prog = -(offset*FU)

	while prog < length do
		if prog+(patch.width*FU) < length then
			if prog < 0 then
				v.drawCropped(
					x, y,
					scale, scale,
					patch,
					flags,
					color,
					-prog,
					0,
					(patch.width*FU)-prog,patch.height*FU
				)
			else
				v.drawScaled(x+FixedMul(prog, scale), y, scale, patch, flags, color)
			end
			prog = $+(patch.width*FU)
		else
			if prog > 0 then
				v.drawCropped(
					x+FixedMul(prog, scale), y,
					scale, scale,
					patch,
					flags,
					color,
					0, 0,
					length-prog,
					patch.height*FU
				)
			else
				v.drawCropped(
					x, y,
					scale, scale,
					patch,
					flags,
					color,
					-prog, 0,
					length,
					patch.height*FU
				)
			end
			prog = length
		end
	end
end

return function(v)
	if not PTV3.pizzatime then return end
	if PTV3.hud_pt < 0 then return end
	
	local time = PTV3.HUD_returnTime(PTV3.hud_pt, 5*FU)

	local f = v.cachePatch('PIZZAFILL')
	local b = v.cachePatch('PIZZABAR')
	
	local scale = FU/4
	scale = $*3/2
	
	local x = 8*FU
	local y = ease.linear(time, 220*FU, 180*FU)
	
	local o = 5*scale
	local of = 5*FU

	local time = PTV3.time*FU
	local maxtime = (CV_PTV3['time'].value*TICRATE)*FU

	local width = (b.width*FU)-of
	local bwidth = (b.width*scale)
	local progress = FixedMul(width, FixedDiv(maxtime-time, maxtime))

	local frame = leveltime % 22
	local j = v.cachePatch('JOHN'..frame)

	local j_prog = max(-6*scale, min(FixedMul(progress, scale)+o-(j.width*scale/2), (b.width*scale)-(j.width*scale)+(8*scale)))

	drawBarFill(v, x+o, y+o, f, V_SNAPTOBOTTOM|V_SNAPTOLEFT, scale, (leveltime/2) % f.width, progress)
	if PTV3.overtime then
		local maxtime = 120*TICRATE
		maxtime = $*FU
		local progress = FixedMul(width, FixedDiv(maxtime-(PTV3.overtime_time*FU), maxtime))
		
		drawBarFill(v, x+o, y+o, f, V_SNAPTOBOTTOM|V_SNAPTOLEFT, scale, (leveltime/2) % f.width, progress, v.getColormap(TC_RAINBOW, SKINCOLOR_PEPPER))
	end
	v.drawScaled(x, y, scale, b, V_SNAPTOBOTTOM|V_SNAPTOLEFT)
	v.drawScaled(x+j_prog, y-(3*scale), scale, j, V_SNAPTOBOTTOM|V_SNAPTOLEFT)
	local text = string.format("%d:%02d", G_TicsToMinutes(PTV3.time), G_TicsToSeconds(PTV3.time))
	if PTV3.overtime then
		local text = string.format("%d:%02d", G_TicsToMinutes(PTV3.overtime_time), G_TicsToSeconds(PTV3.overtime_time))
		--color = leveltime / 2 % 4 and v.getColormap(TC_RAINBOW, SKINCOLOR_RED)
	end
	PTV3.drawText(v, x+((b.width/2)*scale), y+(6*scale), text, {
		--scale = scale*3+(scale/3),
		align = "center",
		flags = V_SNAPTOBOTTOM|V_SNAPTOLEFT}
	)

	--PTV3.drawText(v, x+(bwidth/2), y-(16*FU), "WILL ADD SMTH HERE LATER")
end