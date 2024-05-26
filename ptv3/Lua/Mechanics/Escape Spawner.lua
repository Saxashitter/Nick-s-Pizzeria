freeslot(
	"MT_PTV3_ESCAPESPAWNER",
	"SPR_SPWE",
	"S_ESCAPESPAWNERIDLE",
	"sfx_espawn"
)

for i=1,20 do
	freeslot('S_ESCAPESPAWNER'..i)
end

sfxinfo[sfx_espawn] = {
	flags = SF_X4AWAYSOUND,
	caption = "CEUGH"
}

mobjinfo[MT_PTV3_ESCAPESPAWNER] = {
        doomednum = -1,
        spawnstate = S_ESCAPESPAWNERIDLE,
        spawnhealth = MT_BLUECRAWLA, --Object to Spawn in
        seestate = S_ESCAPESPAWNER1,
        seesound = sfx_espawn,
        reactiontime = 350, --Time that takes to Spawn the Enemy
        attacksound = sfx_None,
        painstate = S_NULL,
        painchance = 200,
        painsound = sfx_None,
        meleestate = S_NULL,
        missilestate = S_NULL,
        deathstate = S_NULL,
        xdeathstate = S_NULL,
        deathsound = sfx_None,
        speed = 0,
        radius = 50*FRACUNIT,
        height = 100*FRACUNIT,
        dispoffset = 0,
        mass = 100,
        damage = 0,
        activesound = sfx_None,
        flags = MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT|MF_NOCLIPTHING,
        raisestate = S_NULL
}

states[S_ESCAPESPAWNERIDLE] = { sprite = SPR_NULL, frame = A, tics = -1, nextstate = S_ESCAPESPAWNERIDLE }
states[S_ESCAPESPAWNER1] = { sprite = SPR_SPWE, frame = FF_FULLBRIGHT|A, tics = 1, nextstate = S_ESCAPESPAWNER2 }
states[S_ESCAPESPAWNER2] = { sprite = SPR_SPWE, frame = FF_FULLBRIGHT|B, tics = 1, nextstate = S_ESCAPESPAWNER3 }
states[S_ESCAPESPAWNER3] = { sprite = SPR_SPWE, frame = FF_FULLBRIGHT|C, tics = 1, nextstate = S_ESCAPESPAWNER4 }
states[S_ESCAPESPAWNER4] = { sprite = SPR_SPWE, frame = FF_FULLBRIGHT|D, tics = 1, nextstate = S_ESCAPESPAWNER5 }
states[S_ESCAPESPAWNER5] = { sprite = SPR_SPWE, frame = FF_FULLBRIGHT|E, tics = 1, nextstate = S_ESCAPESPAWNER6 }
states[S_ESCAPESPAWNER6] = { sprite = SPR_SPWE, frame = FF_FULLBRIGHT|F, tics = 1, nextstate = S_ESCAPESPAWNER7 }
states[S_ESCAPESPAWNER7] = { sprite = SPR_SPWE, frame = FF_FULLBRIGHT|G, tics = 1, nextstate = S_ESCAPESPAWNER8 }
states[S_ESCAPESPAWNER8] = { sprite = SPR_SPWE, frame = FF_FULLBRIGHT|H, tics = 1, nextstate = S_ESCAPESPAWNER9 }
states[S_ESCAPESPAWNER9] = { sprite = SPR_SPWE, frame = FF_FULLBRIGHT|I, tics = 1, nextstate = S_ESCAPESPAWNER10 }
states[S_ESCAPESPAWNER10] = { sprite = SPR_SPWE, frame = FF_FULLBRIGHT|J, tics = 1, nextstate = S_ESCAPESPAWNER11 }
states[S_ESCAPESPAWNER11] = { sprite = SPR_SPWE, frame = FF_FULLBRIGHT|K, tics = 3, nextstate = S_ESCAPESPAWNER12 }
states[S_ESCAPESPAWNER12] = { sprite = SPR_SPWE, frame = FF_FULLBRIGHT|L, tics = 1, nextstate = S_ESCAPESPAWNER13 }
states[S_ESCAPESPAWNER13] = { sprite = SPR_SPWE, frame = FF_FULLBRIGHT|M, tics = 1, nextstate = S_ESCAPESPAWNER14 }
states[S_ESCAPESPAWNER14] = { sprite = SPR_SPWE, frame = FF_FULLBRIGHT|N, tics = 1, nextstate = S_ESCAPESPAWNER15 }
states[S_ESCAPESPAWNER15] = { sprite = SPR_SPWE, frame = FF_FULLBRIGHT|O, tics = 1, nextstate = S_ESCAPESPAWNER16 }
states[S_ESCAPESPAWNER16] = { sprite = SPR_SPWE, frame = FF_FULLBRIGHT|P, tics = 1, nextstate = S_ESCAPESPAWNER17 }
states[S_ESCAPESPAWNER17] = { sprite = SPR_SPWE, frame = FF_FULLBRIGHT|Q, tics = 1, nextstate = S_ESCAPESPAWNER18 }
states[S_ESCAPESPAWNER18] = { sprite = SPR_SPWE, frame = FF_FULLBRIGHT|R, tics = 1, nextstate = S_ESCAPESPAWNER19 }
states[S_ESCAPESPAWNER19] = { sprite = SPR_SPWE, frame = FF_FULLBRIGHT|S, tics = 1, nextstate = S_ESCAPESPAWNER20 }
states[S_ESCAPESPAWNER20] = { sprite = SPR_SPWE, frame = FF_FULLBRIGHT|T, tics = 1, nextstate = S_ESCAPESPAWNERIDLE }

states[S_ESCAPESPAWNER6].action = A_PizzaTowerEscapeSpawn

--The Pizza Tower Escape Spawning List
if not(PT_EscapeSpawnList)
	rawset(_G, "PT_EscapeSpawnList", {})
end
PT_EscapeSpawnList[MT_BLUECRAWLA] = MT_BLUECRAWLA
PT_EscapeSpawnList[MT_REDCRAWLA] = MT_REDCRAWLA
PT_EscapeSpawnList[MT_GFZFISH] = MT_JETTGUNNER
PT_EscapeSpawnList[MT_GOLDBUZZ] = MT_GOLDBUZZ
PT_EscapeSpawnList[MT_REDBUZZ] = MT_REDBUZZ
PT_EscapeSpawnList[MT_JETTBOMBER] = MT_JETTBOMBER
PT_EscapeSpawnList[MT_JETTGUNNER] = MT_JETTGUNNER
PT_EscapeSpawnList[MT_CRAWLACOMMANDER] = MT_CRAWLACOMMANDER
PT_EscapeSpawnList[MT_SKIM] = MT_SKIM
PT_EscapeSpawnList[MT_POPUPTURRET] = MT_JETTGUNNER
PT_EscapeSpawnList[MT_SPINCUSHION] = MT_SPINCUSHION
PT_EscapeSpawnList[MT_CRUSHSTACEAN] = MT_REDCRAWLA
PT_EscapeSpawnList[MT_BANPYURA] = MT_SPRINGSHELL
PT_EscapeSpawnList[MT_JETJAW] = MT_JETJAW
PT_EscapeSpawnList[MT_VULTURE] = MT_VULTURE
PT_EscapeSpawnList[MT_POINTY] = MT_JETTBOMBER
PT_EscapeSpawnList[MT_ROBOHOOD] = MT_ROBOHOOD
PT_EscapeSpawnList[MT_FACESTABBER] = MT_FACESTABBER
PT_EscapeSpawnList[MT_EGGGUARD] = MT_FACESTABBER
PT_EscapeSpawnList[MT_GSNAPPER] = MT_MINUS
PT_EscapeSpawnList[MT_MINUS] = MT_MINUS
PT_EscapeSpawnList[MT_SPRINGSHELL] = MT_SPRINGSHELL
PT_EscapeSpawnList[MT_YELLOWSHELL] = MT_SPRINGSHELL
PT_EscapeSpawnList[MT_UNIDUS] = MT_JETTBOMBER
PT_EscapeSpawnList[MT_CANARIVORE] = MT_CANARIVORE
PT_EscapeSpawnList[MT_PYREFLY] = MT_PYREFLY
PT_EscapeSpawnList[MT_PTERABYTE] = MT_PYREFLY
PT_EscapeSpawnList[MT_DRAGONBOMBER] = MT_PYREFLY
PT_EscapeSpawnList[MT_CRAWLASTATUE] = MT_REDCRAWLA
PT_EscapeSpawnList[MT_FACESTABBERSTATUE] = MT_FACESTABBER
PT_EscapeSpawnList[MT_SUSPICIOUSFACESTABBERSTATUE] = MT_FACESTABBER
PT_EscapeSpawnList[MT_ROSY] = MT_METALSONIC_BATTLE --In Sonic CD, Amy get's kidnapped by Metal Sonic!
PT_EscapeSpawnList[MT_GOOMBA] = MT_GOOMBA
PT_EscapeSpawnList[MT_BLUEGOOMBA] = MT_BLUEGOOMBA
PT_EscapeSpawnList[MT_PIAN] = MT_SHLEEP
PT_EscapeSpawnList[MT_SHLEEP] = MT_SHLEEP
PT_EscapeSpawnList[MT_PENGUINATOR] = MT_PENGUINATOR
PT_EscapeSpawnList[MT_POPHAT] = MT_POPHAT
PT_EscapeSpawnList[MT_HIVEELEMENTAL] = MT_BUMBLEBORE
PT_EscapeSpawnList[MT_BUMBLEBORE] = MT_BUMBLEBORE
PT_EscapeSpawnList[MT_BUGGLE] = MT_JETJAW
PT_EscapeSpawnList[MT_CACOLANTERN] = MT_CACOLANTERN
PT_EscapeSpawnList[MT_SPINBOBERT] = MT_CACOLANTERN
PT_EscapeSpawnList[MT_HANGSTER] = MT_HANGSTER

addHook("MapLoad", function()
	if not PTV3:isPTV3() then return end
	local listofspawners = {}
	for enemy in mobjs.iterate()
		if PT_EscapeSpawnList[enemy.type] == nil then continue end --You want the Object to spawn in
		local spawnlocation = {
			x = enemy.x,
			y = enemy.y,
			z = enemy.z,
			objtype = PT_EscapeSpawnList[enemy.type],
			scale = enemy.scale,
			flip = false,
			target = enemy
		}
		if enemy.eflags&MFE_VERTICALFLIP then
			spawnlocation.flip = true
			spawnlocation.z = $1+enemy.height-FixedMul(100*FRACUNIT,enemy.scale)
		end
		table.insert(listofspawners,spawnlocation)
	end
	for _,v in ipairs(listofspawners) do
		--Add a lot of Escape Spawners
		local escapespawner = P_SpawnMobj(v.x,v.y,v.z,MT_PTV3_ESCAPESPAWNER)
		escapespawner.health = v.objtype
		escapespawner.scale = v.scale
		if v.flip == true then
			escapespawner.eflags = $1|MFE_VERTICALFLIP
		end
		escapespawner.target = v.target
		escapespawner.spawnlap = 0
		escapespawner.reactiontime = 5*TICRATE
	end
end)

addHook("MobjThinker", function(spawner)
	if not PTV3:isPTV3() then return end

	if spawner.state ~= S_ESCAPESPAWNERIDLE then
		if mobjinfo[spawner.health].flags&MF_SPAWNCEILING then
			spawner.renderflags = RF_VERTICALFLIP|RF_FULLBRIGHT|RF_NOCOLORMAPS
		else
			spawner.renderflags = RF_FULLBRIGHT|RF_NOCOLORMAPS
		end
		return false
	end

	spawner.flags2 = $1|MF2_DONTDRAW --Make him Invisible

	local spawnrange = 600*FRACUNIT
	if mobjinfo[spawner.health].flags&MF_NOGRAVITY then spawnrange = $1+400*FRACUNIT end
	if mobjinfo[spawner.health].flags&MF_BOSS then spawnrange = FixedMul($1,0x00018000) end
	if spawner.target ~= nil and spawner.target.valid == true then --The Enemy is still there!
		spawner.reactiontime = 5*TICRATE
	elseif spawner.reactiontime > 0 then
		spawner.reactiontime = $1-1
	elseif PTV3.pizzatime
	and P_LookForPlayers(spawner,FixedMul(spawnrange,spawner.scale),true,false) == true
	and (spawner.target and spawner.target.player.ptv3 and spawner.target.player.ptv3.laps > spawner.spawnlap) then
		--Spawn in
		spawner.state = S_ESCAPESPAWNER1
		spawner.spawnlap = spawner.target.player.ptv3.laps
		spawner.tics = 1
		spawner.flags2 = $1&~MF2_DONTDRAW
	end
	return true
end,MT_PTV3_ESCAPESPAWNER)