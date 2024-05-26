return function(v)
	if not PTV3:isPTV3() then return end
	if PTV3.game_over < 0 then return end
	
	local sw = FixedDiv(v.width()*FU, v.dupx()*FU)
	local sh = FixedDiv(v.height()*FU, v.dupy()*FU)

	local time = PTV3.HUD_returnTime(PTV3.game_over, FU, FU)
	local tween_1 = ease.linear(time, 0, sw/2-(4*FU))
	local tween_2 = ease.linear(time, sw, sw/2+(4*FU))

	PTV3.drawText(v, tween_1, sh/2, "TIME", {
		align = "right",
		flags = V_SNAPTOTOP|V_SNAPTOLEFT
	})
	PTV3.drawText(v, tween_2, sh/2, "OVER", {
		align = "left",
		flags = V_SNAPTOTOP|V_SNAPTOLEFT
	})
end