local function drawTransString(v,x,y,text,flags,alpha,align)
	if alpha ~= nil and alpha == 10 then return end

	local dflags = flags
	if alpha ~= nil and alpha > 0 then
		dflags = alpha<<V_ALPHASHIFT|flags
	end

	return v.drawString(x,y,text,dflags,align)
end

return function(v)
	if PTV3.hud_secret < 0 then return end
	local time = PTV3.HUD_returnTime(PTV3.hud_secret, 5*FU)
	if time > FU then return end
	
	local first_visible = min(time * 30 / FU, 10)
	local second_visible = min((FU-time) * 30 / FU, 10)
	
	first_visible = 10-$
	second_visible = 10-$
	
	local visible = max(first_visible, second_visible)

	local text = string.format('You found %d secret%s out of %d', 
		consoleplayer.ptv3.secretsfound,
		consoleplayer.ptv3.secretsfound > 1 and "s" or "",
		#PTV3.secrets
	)

	local flags = V_SNAPTOBOTTOM
	
	drawTransString(v,160,180,text,flags,visible,"center")
end