rawset(_G, 'ptsp', {enabled = false, death_mode = false})

rawset(_G, 'L_Choose', function(...)
	local args = {...}
	local choice = P_RandomRange(1,#args)
	return args[choice]
end)

rawset(_G, "CanPlayPTSP", function(player)
	local canplay = true
	if multiplayer then
		return false
	end
	if gamemap == 102 then return false end
	
	
	if ntopp_v2 and isPTSkin then
		if player and (player.mo and isPTSkin(player.mo.skin)) and player.ptsp and player.ptsp.enabled then
			canplay = true
		else
			canplay = false
		end
	end
	
	return (ptsp.enabled and canplay)
end)

// freeslot
freeslot('MT_EGGMANPF', 'S_EGGMANPF_CHASE')
freeslot('MT_METALSONIC_SNICK')

mobjinfo[MT_EGGMANPF] = {
	doomednum = -1,
	spawnstate = S_EGGMANPF_CHASE,
	spawnhealth = 1000,
	deathstate = S_NULL,
	radius = 18*FU,
	height = 48*FU,
	flags = MF_NOCLIP|MF_NOGRAVITY|MF_NOCLIPHEIGHT|MF_SPECIAL
}
mobjinfo[MT_METALSONIC_SNICK] = {
	doomednum = -1,
	spawnstate = S_PLAY_STND,
	spawnhealth = 1000,
	deathstate = S_NULL,
	radius = mobjinfo[MT_PLAYER].radius,
	height = mobjinfo[MT_PLAYER].height,
	flags = MF_NOCLIP|MF_NOGRAVITY|MF_NOCLIPHEIGHT|MF_SPECIAL
}

states[S_EGGMANPF_CHASE] = {
    sprite = SPR_EGGM,
    frame = A,
    tics = -1,
    nextstate = S_EGGMANPF_CHASE
}

// cvars

ptsp.PIZZA_TIME_ONLINE = CV_RegisterVar({
	name = "ntoppv2_pizza_time_online",
	defaultvalue = "No",
	flags = CV_NETVAR|CV_SHOWMODIF,
	PossibleValue = CV_YesNo,
})

dofile('PTSP.lua')
dofile('Lap Portal.lua')