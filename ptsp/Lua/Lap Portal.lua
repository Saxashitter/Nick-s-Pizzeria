freeslot('MT_LAPPORTAL', 'S_LAPPORTAL', 'SPR_LAP2')

local lap_portal_coords = {
	["Greenflower Zone 1"] = {
		x = 2080*FU,
		y = 1065*FU,
		z = -32*FU,
		a = 90*ANG1
	}
}

mobjinfo[MT_LAPPORTAL] = {
	doomednum = 2048,
	spawnstate = S_LAPPORTAL,
	spawnhealth = 9999,
	radius = 32*FU,
	height = 130*FU,
	flags = MF_NOCLIP|MF_NOGRAVITY|MF_NOCLIPHEIGHT|MF_SPECIAL
}

states[S_LAPPORTAL] = {
	sprite = SPR_LAP2,
	frame = A
}

local function init_vars(mobj)
	mobj.lap_time = 10
	mobj.lap_player = nil
end

addHook('MobjSpawn', init_vars)
addHook('TouchSpecial', function(mobj, mo)
	if not mo.player then return true end
	local player = mo.player

	if not player.ptsp then return true end
	if not player.ptsp.pizzatime then return true end
	if player.ptsp.laps >= 4 then return true end

	mobj.lap_player = mo.player

	return true
end, MT_LAPPORTAL)

addHook('MobjThinker', function(mobj)
	if not mobj.lap_player then return end
	local p = mobj.lap_player
	if mobj.lap_time then
		mobj.lap_time = $-1
	else
		PTSP_NEWLAP(p)
		PTSP_SPAWNTHINGS(p)
		if p == consoleplayer then
			PTSP_NEWLAP_CLIENT(p)
		end

		init_vars(mobj)
	end
end, MT_LAPPORTAL)

addHook('MapLoad', function()
	if not consoleplayer then return end
	local coordinates = lap_portal_coords[G_BuildMapTitle(gamemap)]
	if not coordinates then return end
	if not CanPlayPTSP(consoleplayer) then return end

	local portal = P_SpawnMobj(coordinates.x, coordinates.y, coordinates.z, MT_LAPPORTAL)
	portal.angle = coordinates.a
	ptsp.LAP_PORTAL = true
end)