freeslot("SPR_STRE", "sfx_tfind", "S_PTV3_TREASURE", "S_PTV3_TREASURE_GOT", "MT_PTV3_TREASURE")
sfxinfo[sfx_tfind].caption = "Treasure jingle!"
mobjinfo[MT_PTV3_TREASURE] = {
	doomednum = -1,
	spawnstate = S_PTV3_TREASURE,
	spawnhealth = 1,
	deathstate = S_NULL,
	radius = 32*FU,
	height = 32*FU,
	flags = MF_SPECIAL|MF_NOCLIP|MF_NOCLIPHEIGHT|MF_NOGRAVITY
}

states[S_PTV3_TREASURE] = {
	sprite = SPR_STRE,
	frame = A,
	tics = -1,
	action = nil,
	var1 = 0,
	var2 = 0,
	nextstate = S_PTV3_TREASURE
}

states[S_PTV3_TREASURE_GOT] = {
	sprite = SPR_STRE,
	frame = A,
	tics = 3*TICRATE,
	action = nil,
	var1 = 0,
	var2 = 0,
	nextstate = S_NULL
}

addHook("MapThingSpawn", function(mo, thing)
	if not PTV3:isPTV3() then return end

	P_SpawnMobj(mo.x,mo.y,mo.z, MT_PTV3_TREASURE)
	P_RemoveMobj(mo)
end, MT_TOKEN)

addHook("MobjSpawn", function(mo)
	local frame = P_RandomKey(20)

	mo.frame = frame
	mo._frame = frame
end, MT_PTV3_TREASURE)

addHook("MobjThinker", function(mo)
	if not mo.valid then return end

	mo.frame = mo._frame

	if mo.target
	and mo.target.valid then
		P_SetOrigin(mo,
			mo.target.x,
			mo.target.y,
			mo.target.z+mo.target.height
		)

		mo.momx = mo.target.momx
		mo.momy = mo.target.momy
		mo.momz = mo.target.momz
	end
end, MT_PTV3_TREASURE)

addHook("TouchSpecial", function(mo, pmo)
	if mo.state == S_PTV3_TREASURE_GOT then return true end

	if not (pmo.valid
	and pmo.player
	and pmo.player.ptv3
	and not pmo.player.ptv3.swapModeFollower) then return true end

	P_AddPlayerScore(pmo.player, 800)

	mo.target = pmo
	mo.state = S_PTV3_TREASURE_GOT
	mo.frame = mo._frame

	S_StartSound(mo, sfx_tfind)

	return true
end, MT_PTV3_TREASURE)