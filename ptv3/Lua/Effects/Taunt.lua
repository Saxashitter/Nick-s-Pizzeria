freeslot("sfx_taunt", "SPR_TANT", "S_PTV3_TAUNT")
sfxinfo[sfx_taunt].caption = "POW!"

states[S_PTV3_TAUNT] = {
	sprite = SPR_TANT,
	frame = FF_ANIMATE|A,
	tics = 8*2,
	action = nil,
	var1 = 8*2,
	var2 = 2,
	dispoffset = 1,
	nextstate = S_NULL
}

return {
	state = S_PTV3_TAUNT,
	follow = true,
	func = function(mo)
		S_StartSound(mo, sfx_taunt)
	end
}