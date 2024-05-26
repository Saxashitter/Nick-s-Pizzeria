freeslot("SKINCOLOR_AFTERIMAGERED","SKINCOLOR_AFTERIMAGEGREEN")

skincolors[SKINCOLOR_AFTERIMAGERED] = {
    name = "After Image Red",
    ramp = {35,35,35,35,35,35,35,35,35,35,35,41,41,41,41,41},
    invcolor = SKINCOLOR_RED,
    invshade = 9,
    chatcolor = V_REDMAP,
    accessible = true
}

skincolors[SKINCOLOR_AFTERIMAGEGREEN] = {
    name = "After Image Green",
    ramp = {100,100,100,100,100,100,100,100,100,100,100,191,191,191,191,191},
    invcolor = SKINCOLOR_GREEN,
    invshade = 9,
    chatcolor = V_GREENMAP,
    accessible = true
}

rawset(_G, "TGTLSGhost", function(p)
	local afti = P_SpawnGhostMobj(p.mo)
	// afti.colorized = true
	afti.fuse = 8
	afti.tics = 8
	afti.color = p.mo.color
	afti.frame = TR_TRANS30|p.mo.frame
	if p.mo.frame & FF_PAPERSPRITE then
		afti.frame = $|FF_PAPERSPRITE
	end
	afti.angle = p.drawangle
	afti.scale = p.mo.scale
	return afti
end)

rawset(_G, "TGTLSAfterImage", function(p)
	local afti = P_SpawnGhostMobj(p.mo)
	afti.colorized = true
	afti.fuse = 999
	afti.tics = 5
	afti.color = leveltime % 16 < 8 and SKINCOLOR_AFTERIMAGERED or SKINCOLOR_AFTERIMAGEGREEN
	afti.frame = TR_TRANS10|p.mo.frame|FF_FULLBRIGHT
	if p.mo.frame & FF_PAPERSPRITE then
		afti.frame = $|FF_PAPERSPRITE
	end
	afti.angle = p.drawangle
	afti.scale = p.mo.scale
	return afti
end)

-- hello guys it is me
-- pacola
-- i am doing noise's cool afterimages now

freeslot("SPR_NCAI", "S_NTOPP_TORNADOAI", "S_NTOPP_MCANCELAI")

states[S_NTOPP_TORNADOAI] = {
	sprite = SPR_NCAI,
	frame = K|FF_ANIMATE,
	tics = -1,
	nextstate = S_NULL,
	var1 = 3,
	var2 = 2
}

states[S_NTOPP_MCANCELAI] = {
	sprite = SPR_NCAI,
	frame = A|FF_ANIMATE,
	tics = -1,
	nextstate = S_NULL,
	var1 = J,
	var2 = 2
}

rawset(_G, "NTOPP_NoiseAI", function(mo, type)
	type = $ or 1
	
	local g = P_SpawnMobj(mo.x, mo.y, mo.z, MT_THOK)
	local state = (type == 1 and S_NTOPP_MCANCELAI) or S_NTOPP_TORNADOAI
	g.state = state
	local fone = (mo.frame & FF_FRAMEMASK)+(states[state].frame & FF_FRAMEMASK)
	local ftwo = (states[state].frame & FF_FRAMEMASK)+states[state].var1
	local frame = min(fone, ftwo)|(mo.frame & ~FF_FRAMEMASK)|FF_TRANS20|FF_FULLBRIGHT
	g.frame = frame
	g.tics = 7
	g.color = (mo.player and mo.player.valid) and mo.player.skincolor or mo.color
end)