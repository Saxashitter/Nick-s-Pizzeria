freeslot("MT_PIZZATOWER_EXITSIGN_SPAWN")
freeslot("SPR_GSSE")
freeslot("S_EXITSPAWN_PLACEHOLDER")

states[S_EXITSPAWN_PLACEHOLDER] = {
	sprite = SPR_GSSE,
	frame = A,
	tics = -1,
}
mobjinfo[MT_PIZZATOWER_EXITSIGN_SPAWN] = {
	doomednum = 1263, //1-26-[202]3
	spawnstate = S_EXITSPAWN_PLACEHOLDER,
	spawnhealth = 1000, //gus cannot die lol
	radius = 14*FU,
	height = 26*FU,
	flags = MF_NOCLIPTHING
}

freeslot("MT_GUSTAVO_EXITSIGN")
freeslot("S_GUSTAVO_EXIT_WAIT")
freeslot("S_GUSTAVO_EXIT_FALL")
freeslot("SPR_GESF")
freeslot("S_GUSTAVO_EXIT_RALLY")
freeslot("SPR_GESR")
freeslot("S_GUSTAVO_ICE_RALLY")
freeslot("SPR_GESI")
freeslot("S_GUSTAVO_RAT_FALL")
freeslot("SPR_GERF")
freeslot("S_GUSTAVO_RAT_RALLY")
freeslot("SPR_GERR")

states[S_GUSTAVO_EXIT_WAIT] = {
	sprite = SPR_RING,
	frame = A,
	tics = -1,
}
states[S_GUSTAVO_EXIT_FALL] = {
	sprite = SPR_GESF,
	frame = A|FF_PAPERSPRITE|FF_ANIMATE,
	var1 = 3-1,
	var2 = 2,
	tics = -1,
}
states[S_GUSTAVO_EXIT_RALLY] = {
	sprite = SPR_GESR,
	frame = A|FF_PAPERSPRITE|FF_ANIMATE,
	var1 = 9-1,
	var2 = 2,
	tics = -1,
}

states[S_GUSTAVO_ICE_RALLY] = {
	sprite = SPR_GESI,
	frame = A|FF_PAPERSPRITE|FF_ANIMATE,
	var1 = 3-1,
	var2 = 1,
	tics = -1,
}

states[S_GUSTAVO_EXIT_FALL] = {
	sprite = SPR_GESF,
	frame = A|FF_PAPERSPRITE|FF_ANIMATE,
	var1 = 3-1,
	var2 = 2,
	tics = -1,
}
states[S_GUSTAVO_RAT_FALL] = {
	sprite = SPR_GERF,
	frame = A|FF_PAPERSPRITE|FF_ANIMATE,
	tics = -1,
}
states[S_GUSTAVO_RAT_RALLY] = {
	sprite = SPR_GERR,
	frame = A|FF_PAPERSPRITE|FF_ANIMATE,
	var1 = 9-1,
	var2 = 2,
	tics = -1,
}

mobjinfo[MT_GUSTAVO_EXITSIGN] = {
	doomednum = -1,
	spawnstate = S_GUSTAVO_EXIT_WAIT,
	spawnhealth = 1000, //gus cannot die lol
	radius = 14*FU,
	height = 26*FU,
	flags = MF_NOCLIPTHING
}

freeslot("MT_STICK_EXITSIGN")
freeslot("S_STICK_EXIT_WAIT")
freeslot("S_STICK_EXIT_FALL")
freeslot("SPR_SESF")
freeslot("S_STICK_EXIT_RALLY")
freeslot("SPR_SESR")

states[S_STICK_EXIT_WAIT] = {
	sprite = SPR_THOK,
	frame = A,
	tics = -1,
}
states[S_STICK_EXIT_FALL] = {
	sprite = SPR_SESF,
	frame = A|FF_PAPERSPRITE|FF_ANIMATE,
	var1 = 3-1,
	var2 = 2,
	tics = -1,
}
states[S_STICK_EXIT_RALLY] = {
	sprite = SPR_SESR,
	frame = A|FF_PAPERSPRITE|FF_ANIMATE,
	var1 = 6-1,
	var2 = 2,
	tics = -1,
}

mobjinfo[MT_STICK_EXITSIGN] = {
	doomednum = -1,
	spawnstate = S_STICK_EXIT_WAIT,
	spawnhealth = 1000, //gus cannot die lol
	radius = 10*FU,
	height = 32*FU,
	flags = MF_NOCLIPTHING
}

//LUIG BUD!!!
local isIcy = false
local dist = 1500

addHook("NetVars",function(n)
	isIcy = n($)
end)

local function isIcyF(map)
	if (mapheaderinfo[map] == nil)
		return false;
	end
	
	// https://wiki.srb2.org/wiki/Flats_and_textures/Skies
	if (mapheaderinfo[map].skynum == 17
	or mapheaderinfo[map].skynum == 29
	or mapheaderinfo[map].skynum == 30
	or mapheaderinfo[map].skynum == 107
	or mapheaderinfo[map].skynum == 55)
		return true;
	end

	if (mapheaderinfo[map].musname == "MP_ICE"
	or mapheaderinfo[map].musname == "FHZ"
	or mapheaderinfo[map].musname == "CCZ")
		// ice music
		return true;
	end
	
	//time to bust out the thesaurus!
	local icywords = {
		"frozen",
		"christmas",
		"ice",
		"icy",
		"icicle",
		"blizzard",
		"snow",
		"snowstorm",
		"frost",
		"winter",
		"chilly",
		"frigid",
		"artic",
		"polar",
		"glacial",
		"glacier",
		"wintery",
		"subzero",
		"tundra",
		"snowcap",
		"icecap",
	};

	local stageName = string.lower(mapheaderinfo[map].lvlttl);
	for i = 1,#icywords do
		if (string.find(stageName, icywords[i]) != nil)
			-- Has a very distinctly desert word in its title
			return true;
		end
	end

	return false;

end

addHook("MapLoad",function(mapid)
	isIcy = isIcyF(mapid)
end)
addHook("MapThingSpawn",function(mo,mt)
	//we dont wanna see EXIT pop up from no where
	//looks like an ERROR in a source game!
	mo.flags2 = $|MF2_DONTDRAW
	
	if PTV3:isPTV3()
		local mul = 14
		if isIcy
			local gus = P_SpawnMobjFromMobj(mo,0,0,(mo.height*mul),MT_GUSTAVO_EXITSIGN)
			gus.state = S_GUSTAVO_EXIT_WAIT
			gus.icygus = true
			gus.angle = mo.angle
			gus.tracer = mo
			return true
		elseif gamemap == A5
			local gus = P_SpawnMobjFromMobj(mo,0,0,(mo.height*mul),MT_GUSTAVO_EXITSIGN)
			gus.state = S_GUSTAVO_EXIT_WAIT
			gus.rattygus = true
			gus.angle = mo.angle
			gus.tracer = mo
			return true
		else
			if (P_RandomChance(FU/2))
				local gus = P_SpawnMobjFromMobj(mo,0,0,(mo.height*mul),MT_GUSTAVO_EXITSIGN)
				gus.state = S_GUSTAVO_EXIT_WAIT
				gus.angle = mo.angle
				gus.tracer = mo
				return true
			else
				local stick = P_SpawnMobjFromMobj(mo,0,0,(mo.height*mul),MT_STICK_EXITSIGN)
				stick.state = S_STICK_EXIT_WAIT
				stick.angle = mo.angle
				stick.tracer = mo
				return true		
			end
		end
	end
	return true
end,MT_PIZZATOWER_EXITSIGN_SPAWN)

addHook("MobjThinker",function(mo)
	if not mo
	or not mo.valid
		return
	end
	
	if not PTV3
		return
	end
	
	local grounded = P_IsObjectOnGround(mo)
	
	mo.angle = mo.tracer.angle
	
	if mo.state == S_GUSTAVO_EXIT_WAIT
	and not mo.alreadyfell
		mo.flags2 = $|MF2_DONTDRAW
		mo.flags = $|MF_NOGRAVITY
		if PTV3.pizzatime
			
			local px = mo.x
			local py = mo.y
			local br = dist*mo.scale

			searchBlockmap("objects", function(mo, found)
				if found and found.valid
				and found.health
				and found.player
				and (P_CheckSight(mo,found))
					if mo.icygus
						mo.state = S_GUSTAVO_ICE_RALLY
					elseif mo.rattygus
						mo.state = S_GUSTAVO_RAT_FALL
					else
						mo.state = S_GUSTAVO_EXIT_FALL
					end
					mo.alreadyfell = true
				end
			end, mo, px-br, px+br, py-br, py+br)
		end
	else
		mo.flags2 = $ &~MF2_DONTDRAW
		mo.flags = $ &~MF_NOGRAVITY
		if grounded
			if mo.rattygus
				if mo.state ~= S_GUSTAVO_RAT_RALLY
					mo.state = S_GUSTAVO_RAT_RALLY
				end
			elseif not (mo.icygus)
				if mo.state ~= S_GUSTAVO_EXIT_RALLY
					mo.state = S_GUSTAVO_EXIT_RALLY
				end
			end
		else
			if mo.rattygus
				mo.state = S_GUSTAVO_RAT_FALL
			elseif not (mo.icygus)
				mo.state = S_GUSTAVO_EXIT_FALL
			end			
		end
	end
end,MT_GUSTAVO_EXITSIGN)

addHook("MobjThinker",function(mo)
	if not mo
	or not mo.valid
		return
	end

	local grounded = P_IsObjectOnGround(mo)
	
	mo.angle = mo.tracer.angle

	if mo.state == S_STICK_EXIT_WAIT
	and not mo.alreadyfell
		mo.flags2 = $|MF2_DONTDRAW
		mo.flags = $|MF_NOGRAVITY
		if PTV3.pizzatime
			local px = mo.x
			local py = mo.y
			local br = dist*mo.scale

			searchBlockmap("objects", function(mo, found)
				if found and found.valid
				and found.health
				and found.player
				and (P_CheckSight(mo,found))
					mo.state = S_STICK_EXIT_FALL
					mo.alreadyfell = true
				end
			end, mo, px-br, px+br, py-br, py+br)
		end
	else
		mo.flags2 = $ &~MF2_DONTDRAW
		mo.flags = $ &~MF_NOGRAVITY
		if grounded
			if mo.state ~= S_STICK_EXIT_RALLY
				mo.state = S_STICK_EXIT_RALLY
			end
		else
			mo.state = S_STICK_EXIT_FALL
		end
	end
end,MT_STICK_EXITSIGN)