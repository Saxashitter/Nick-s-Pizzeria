freeslot("sfx_secfou",
	"MT_PTV3_SECRET",
	"MT_PTV3_SECRETEXIT",
	"MT_PTV3_SECRETTP",
	"MT_PTV3_CODESECRET",
	"SPR_SIDL",
	"SPR_SCRY",
	"S_PTV3_SECRET",
	"S_PTV3_SECRET_CRY"
)

sfxinfo[sfx_secfou].caption = "Secret found!"

mobjinfo[MT_PTV3_SECRET] = {
    doomednum = 2222,
    spawnstate = S_NULL,
    radius = 16*FRACUNIT,
    height = 48*FRACUNIT,
}
mobjinfo[MT_PTV3_SECRETTP] = {
    doomednum = 2223,
    spawnstate = S_NULL,
    radius = 16*FRACUNIT,
    height = 48*FRACUNIT,
}
mobjinfo[MT_PTV3_SECRETEXIT] = {
    doomednum = 2224,
    spawnstate = S_NULL,
    radius = 16*FRACUNIT,
    height = 48*FRACUNIT,
}

mobjinfo[MT_PTV3_CODESECRET] = {
    doomednum = -1,
	spawnstate = S_PTV3_SECRET_CRY,
	spawnhealth = 1000,
	deathstate = S_NULL,
	radius = 48*FU,
	height = 64*FU,
	flags = MF_NOCLIP|MF_NOGRAVITY|MF_NOCLIPHEIGHT|MF_SPECIAL
}

states[S_PTV3_SECRET] = {
    sprite = SPR_SIDL,
    frame = A,
    tics = -1,
    action = nil,
    var1 = 2,
    var2 = 2,
    nextstate = S_PTV3_SECRET
}

states[S_PTV3_SECRET_CRY] = {
    sprite = SPR_SCRY,
    frame = A,
    tics = -1,
    action = nil,
    var1 = 2,
    var2 = 2,
    nextstate = S_PTV3_SECRET_CRY
}

local tplist = {}
local saved_sky = 0

addHook('NetVars', function(n)
	tplist = n($)
end)
addHook('MapLoad', function()
	saved_sky = 0
end)

local function SpawnSecret(x,y,z,angle,type)
	if not PTV3:isPTV3() then return end
	local z = P_FloorzAtPos(x*FU, y*FU, 0*FU, 64*FU)+(z*FU)
	local secret = P_SpawnMobj(x*FU, y*FU, z, MT_PTV3_CODESECRET)
	secret.stype = type

	if not PTV3.secrets[angle] then
		PTV3.secrets[angle] = {}
	end
	PTV3.secrets[angle][type] = secret
	secret.link = angle
end

addHook('MapThingSpawn', function(mo,thing)
	if thing.type == 2222 then
		SpawnSecret(thing.x,thing.y,thing.z,thing.angle,1)
	end
	if thing.type == 2223 then
		SpawnSecret(thing.x,thing.y,thing.z,thing.angle,0)
	end
	if thing.type == 2224 then
		SpawnSecret(thing.x,thing.y,thing.z,thing.angle,2)
	end
end)

addHook('MobjSpawn', function(secret)
	secret.stype = 1
	secret.teleported = {}
end, MT_PTV3_CODESECRET)

addHook("MobjThinker", function(secret)
	if secret.stype == 0 then
		if secret.state ~= S_PTV3_SECRET_CRY then
			secret.state = S_PTV3_SECRET_CRY
		end
		return
	else
		if secret.state ~= S_PTV3_SECRET then
			secret.state = S_PTV3_SECRET
		end
		return
	end
end, MT_PTV3_CODESECRET)

local function SecretCollide(secret,mo)
end

addHook('TouchSpecial', function(secret,mo)
	if secret.stype == 0 then return true end
	if mo.type ~= MT_PLAYER then return true end
	if not (mo and mo.valid) then return true end
	if PTV3.overtime
	and not (mo.player and mo.player.ptv3 and mo.player.ptv3.insecret) then
		return  true
	end
	if secret.teleported[mo.player] then return true end
	
	local type = 0
	local type2 = secret.link
	if secret.stype == 2 then
		type = 1
		type2 = 0
		PTV3.callbacks('ExitSecret', mo.player)
	elseif mo.player.ptv3 then
		mo.player.ptv3.secretsfound = $+1
		S_StartSound(nil, sfx_secfou, mo.player)
		PTV3.callbacks('FindSecret', mo.player)
	end
	
	
	local link = PTV3.secrets[secret.link][type]
	
	table.insert(tplist, {mo.player, {x=link.x, y=link.y, z=link.z, a=mo.angle}, type})
	-- sometimes this doesnt like to work so i gotta improvise

	secret.teleported[mo.player] = true
	mo.player.ptv3.insecret = type2
	return true
end, MT_PTV3_CODESECRET)

addHook('ThinkFrame', do
	for _,tp in ipairs(tplist) do
		if not tp[1].mo.valid then
			table.remove(tplist, _)
			continue
		end
		if (tp[3] == 1 and not tp[1].ptv3.secret_tptoend)
		or tp[3] ~= 1 then
			PTV3:teleportPlayer(unpack(tp))
		end
		
		if tp[3] == 0 then
			if tp[1] == consoleplayer then
				saved_sky = levelskynum
				P_SetupLevelSky(102, tp[1].player)
				PTV3.hud_secret = leveltime
			end
		elseif tp[3] == 1 then
			if tp[1].ptv3.secret_tptoend then
				PTV3:teleportPlayer(tp[1])
				tp[1].ptv3.secret_tptoend = false
			end
			if tp[1] == consoleplayer then
				P_SetupLevelSky(saved_sky, tp[1].player)
				if PTV3.extreme then
					P_SetSkyboxMobj(nil, false)
					P_SetupLevelSky(34)
				end
				if PTV3.overtime then
					P_SetSkyboxMobj(nil, false)
					P_SetupLevelSky(9)
				end
				saved_sky = 0
			end
		end
		
		table.remove(tplist, _)
	end
end)