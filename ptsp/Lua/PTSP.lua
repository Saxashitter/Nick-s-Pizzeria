// variables
local MAX_TIME = (2*(TICRATE*60))+(30*TICRATE)

local ptsp_defaultvars = {
	{"spawn_sector", nil},
	{"exit_pos", nil},
	{"LAP_PORTAL", false}
}

local vars = {
	{"pizzatime", false},
	{"laps", 1},
	{"showtime", false},
	{"time", (2*(TICRATE*60))+(30*TICRATE)},
	{"lap_time", 5*TICRATE},
	{"eggman", nil},
	{"metalsonic", nil},
	{"rank", 1}
}

local score_for_ranks = 500
rawset(_G, "ptsp_ranks", {
	"D",
	"C",
	"B",
	"A",
	"S",
	"P"
})

// hud vars

local PIZZATIME_TIME = 0
local LAP_ANIMS = {}

// functions

local function initvars(player)
	if not player.ptsp then
		player.ptsp = {}
		player.ptsp.enabled = false
	end
	for _,i in pairs(vars) do
		player.ptsp[i[1]] = i[2]
	end
end

local function removevars(player)
	player.ptsp = nil
end

local function musicbylap()
	if ptsp.death_mode then return end
	local music = {}
	music['npeppino'] = {
		'PIZTIM',
		'DEAOLI',
		'LAP3LO',
		'LAP4LO'
	}
	music['nthe_noise'] = {
		'NOISL1',
		'NOISL2',
		'NOISL3',
		'LAP4LO'
	}
	
	local music = music[consoleplayer.mo.skin] and music[consoleplayer.mo.skin][consoleplayer.ptsp.laps] or music['npeppino'][consoleplayer.ptsp.laps]
	mapmusname = music
	S_ChangeMusic(mapmusname, true, consoleplayer)
end

rawset(_G, "PTSP_NEWLAP_CLIENT", function()
	musicbylap()
	
	local tbl = {}
	tbl.animtime = 0
	tbl.text = 'LAP'..consoleplayer.ptsp.laps
	table.insert(LAP_ANIMS, tbl)
end)

local function P_FlyTo(mo, fx, fy, fz, sped, addques)
    if mo.valid
        local flyto = P_AproxDistance(P_AproxDistance(fx - mo.x, fy - mo.y), fz - mo.z)
        if flyto < 1
            flyto = 1
        end
		
        if addques
            mo.momx = $ + FixedMul(FixedDiv(fx - mo.x, flyto), sped)
            mo.momy = $ + FixedMul(FixedDiv(fy - mo.y, flyto), sped)
            mo.momz = $ + FixedMul(FixedDiv(fz - mo.z, flyto), sped)
        else
            mo.momx = FixedMul(FixedDiv(fx - mo.x, flyto), sped)
            mo.momy = FixedMul(FixedDiv(fy - mo.y, flyto), sped)
            mo.momz = FixedMul(FixedDiv(fz - mo.z, flyto), sped)
        end    
    end    
end

local function canGetRank(p)
	local currank = ptsp_ranks[p.ptsp.rank]
	local nextrank = ptsp_ranks[p.ptsp.rank+1]
	local prevrank = ptsp_ranks[p.ptsp.rank-1]
	
	if not nextrank then return false end
	if nextrank == "P" then
		if p.ptsp.laps < 2 then
			return false
		end
	end
	if p.score > score_for_ranks * p.ptsp.rank then
		return true
	end
	return false
end

rawset(_G, "PTSP_SPAWNTHINGS", function(p)
	if p.ptsp.eggman and p.ptsp.eggman.valid then
		P_SetOrigin(p.ptsp.eggman, ptsp.exit_pos.x, ptsp.exit_pos.y, ptsp.exit_pos.z)
		p.ptsp.eggman.angle = ptsp.exit_pos.a
		p.ptsp.eggman.cooldown = 3*TICRATE
	end
	if p.ptsp.metalsonic and p.ptsp.metalsonic.valid then
		p.ptsp.metalsonic.playermovement = {}
		P_SetOrigin(p.ptsp.metalsonic, ptsp.exit_pos.x, ptsp.exit_pos.y, ptsp.exit_pos.z)
		p.ptsp.metalsonic.angle = ptsp.exit_pos.a
		p.ptsp.metalsonic.cooldown = TICRATE
	end
	if not ptsp.death_mode and p.ptsp.laps >= 3 and not p.ptsp.eggman then
		p.ptsp.time = 0
		p.ptsp.eggman = P_SpawnMobj(p.mo.x, p.mo.y, p.mo.z, MT_EGGMANPF)
		p.ptsp.eggman.target = p.mo
	end
	if p.ptsp.laps >= 4 and not p.ptsp.metalsonic then
		p.ptsp.metalsonic = P_SpawnMobj(p.mo.x, p.mo.y, p.mo.z, MT_METALSONIC_SNICK)
		p.ptsp.metalsonic.target = p.mo
	end
	if ntopp_v2 and isPTSkin(p.mo.skin) and p.fsm and fsm then
		fsm.ChangeState(p, ntopp_v2.enums.BASE)
		//p.mo.momx = 0
		//p.mo.momy = 0
	end
end)

rawset(_G, "PTSP_NEWLAP", function(p)
	p.mo.momx = 0
	p.mo.momy = 0
	p.mo.momz = 0

	P_SetOrigin(p.mo, ptsp.exit_pos.x, ptsp.exit_pos.y, ptsp.exit_pos.z)
	p.mo.angle = ptsp.exit_pos.a

	-- P_TeleportCameraMove(camera, ptsp.exit_pos.x, ptsp.exit_pos.y, ptsp.exit_pos.z)
	-- camera.angle = ptsp.exit_pos.a
	
	p.ptsp.lap_time = 5*TICRATE
	
	p.ptsp.laps = $+1
	p.exiting = 0
	
	if ntopp_v2 and isPTSkin(p.mo.skin) and p.fsm and fsm then
		fsm.ChangeState(p, ntopp_v2.enums.BASE)
	end
end)

// hooks

addHook('NetVars', function(net)
	for _,i in pairs(ptsp_defaultvars) do
		ptsp[i[1]] = net($)
	end
	ptsp.enabled = net($)
	ptsp.death_mode = net($)
end)

addHook('MapChange', function()
	ptsp.enabled = true
	if multiplayer and not (ptsp.PIZZA_TIME_ONLINE.value) then
		ptsp.enabled = false
	end
	PIZZATIME_TIME = 0
	LAP_ANIMS = {}

	for _,i in pairs(ptsp_defaultvars) do
		ptsp[i[1]] = i[2]
	end
	for p in players.iterate do
		initvars(p)
	end
	if multiplayer and ptsp.death_mode then
		ptsp.death_mode = false
	end
	for p in players.iterate do
		if p and CanPlayPTSP(p) then
			p.score = 0
		end
	end
end)

addHook('MapLoad', function()
	for thing in mapthings.iterate do
		if thing.type == 501 then
			ptsp.exit_pos = {}
			ptsp.exit_pos.x = thing.x*FU
			ptsp.exit_pos.y = thing.y*FU
			ptsp.exit_pos.z = R_PointInSubsector(thing.x*FU, thing.y*FU).sector.floorheight + (thing.z*FU)
			ptsp.exit_pos.a = thing.angle*ANG1
			
			if not multiplayer and ptsp.death_mode and (consoleplayer and consoleplayer.mo and consoleplayer.ptsp and not consoleplayer.ptsp.eggman) then
				consoleplayer.ptsp.eggman = P_SpawnMobj(consoleplayer.mo.x, consoleplayer.mo.y, consoleplayer.mo.z, MT_EGGMANPF)
				consoleplayer.ptsp.eggman.target = consoleplayer.mo
			end
		end
		if thing.type ~= 1 then continue end
		ptsp.spawn_sector = R_PointInSubsector(thing.x*FU, thing.y*FU).sector
	end
end)

addHook('PlayerThink', function(p)
	if not p then return end
	if not p.mo then return end
	if not p.ptsp then return end
	if not ntopp_v2 then return end
	if not CanPlayPTSP(p) then return end
	if not isPTSkin(p.mo.skin) then return end

	if canGetRank(p) then
		p.ptsp.rank = $+1
	end
end)

// NTOPPV2 RANK SCREEN SUPPORT
addHook('PostThinkFrame', do
	if not consoleplayer then return end
	if not consoleplayer.mo then return end
	if not ntopp_v2 then return end
	if not CanPlayPTSP(consoleplayer) then return end
	if not isPTSkin(consoleplayer.mo.skin) then return end

	local p = consoleplayer
	if not p.ptsp then return end

	if (p.ntoppv2_ranks == false) then return end
	if multiplayer then return end
	if not (p.exiting)then return end
	p.exiting = 10

	if not p.ptsp.lap_time and not ntopp_v2.PLAY_RANK_SCREEN then
		ntopp_v2.PLAY_RANK_SCREEN = true
		ntopp_v2.RANK_GOT = ptsp_ranks[p.ptsp.rank]
		S_ChangeMusic(ntopp_v2.RANK_GOT.."RANK", false, consoleplayer)
	end
	
	if not ntopp_v2.RANK_SCREEN_TIME then
		G_SetCustomExitVars(nil, 1)
		G_ExitLevel()
		return
	end
end)

addHook('PostThinkFrame', function()
	for p in players.iterate do
		if not p then continue end
		if not p.mo then removevars(p) continue end
		if not p.mo.valid then removevars(p) continue end
	
		if not p.ptsp then initvars(p) end
		if not CanPlayPTSP(p) then continue end


		if ((p.pflags & PF_FINISHED) or p.exiting)
		and p.mo.subsector.sector.special == 8192 then
			p.exiting = 0
			p.pflags = $ & ~(PF_FINISHED | PF_FULLSTASIS)
			if not p.ptsp.pizzatime then
				p.ptsp.pizzatime = true
				if p == consoleplayer then
					musicbylap()
				end
			end
		end
		
		if p.ptsp.lap_time and p.exiting then
			p.ptsp.lap_time = $-1
		end
		
		if p.mo.subsector.sector == ptsp.spawn_sector and p.ptsp.pizzatime and not (p.exiting) then
			P_DoPlayerExit(p)
		end

		if not ptsp.LAP_PORTAL and p.exiting and p.ptsp.lap_time and p.cmd.buttons & BT_ATTACK and ptsp.exit_pos and p.ptsp.laps < 4 then
			PTSP_NEWLAP(p)
			PTSP_SPAWNTHINGS(p)
			if p == consoleplayer then
				PTSP_NEWLAP_CLIENT()
			end
		end
		
		if p.ptsp.pizzatime and not ptsp.death_mode then
			if p.ptsp.time then
				p.ptsp.time = $-1
			elseif not p.ptsp.eggman then
				p.ptsp.eggman = P_SpawnMobj(p.mo.x, p.mo.y, p.mo.z, MT_EGGMANPF)
				p.ptsp.eggman.target = p.mo
			end
		end
	end
	
	if consoleplayer and CanPlayPTSP(consoleplayer) and ptsp.death_mode and mapmusname ~= 'AOTKPS' then
		mapmusname = "AOTKPS"
		S_ChangeMusic("AOTKPS", true, consoleplayer)
	end
end)

addHook('ThinkFrame', function()
	if not CanPlayPTSP(consoleplayer) then return end
	if not consoleplayer then return end
	if not consoleplayer.mo then return end
	if not consoleplayer.mo.valid then return end
	if not consoleplayer.ptsp then return end
	if not consoleplayer.ptsp.pizzatime then return end
	
	PIZZATIME_TIME = $+(FU/(TICRATE*2))
	
	for _,lap in pairs(LAP_ANIMS) do
		if lap.animtime > 5*FU then
			table.remove(LAP_ANIMS, _)
			continue
		end
		
		lap.animtime = $+(FU/(TICRATE))
	end
end)

addHook('MobjThinker', function(egg)
	egg.momx = 0
	egg.momy = 0
	egg.momz = 0
	if not egg.target then return end
	if not egg.target.valid then return end
	if not (egg.target.health) then return end
	if (egg.target.player.exiting) then return end

	if egg.cooldown then
		egg.cooldown = $-1
		return
	end

	egg.angle = R_PointToAngle2(egg.x, egg.y, egg.target.x, egg.target.y)
	P_FlyTo(egg, egg.target.x, egg.target.y, egg.target.z, 35*FU)
end, MT_EGGMANPF)

addHook('MobjThinker', function(egg)
	if not egg.target then return end
	if not egg.target.valid then return end
	if not (egg.target.health) then return end
	if (egg.target.player.exiting) then return end
	
	if egg.cooldown then egg.cooldown = $-1 end

	if egg.playermovement[8] then
		local t = egg.playermovement[1]
		P_MoveOrigin(egg, t.x, t.y, t.z)
		egg.angle = t.a
		table.remove(egg.playermovement, 1)
	end

	local playershit = {
		x = egg.target.x,
		y = egg.target.y,
		z = egg.target.z,
		a = egg.target.player.drawangle,
		g = P_IsObjectOnGround(egg.target)
	}

	table.insert(egg.playermovement, playershit)
end, MT_METALSONIC_SNICK)

addHook('TouchSpecial', function(special, toucher)
	if not (toucher and toucher.valid) then return true end
	if not toucher.player then return true end
	if special.cooldown then return true end
	
	P_KillMobj(toucher, special, special)
	return true
end, MT_EGGMANPF)
addHook('TouchSpecial', function(special, toucher)
	if not (toucher and toucher.valid) then return true end
	if not toucher.player then return true end
	if not special.playermovement[8] then return true end
	if special.cooldown then return true end
	
	P_KillMobj(toucher, special, special)
	return true
end, MT_METALSONIC_SNICK)

addHook('MobjSpawn', function(egg)
	egg.cooldown = 3*TICRATE
end, MT_EGGMANPF)
addHook('MobjSpawn', function(egg)
	egg.playermovement = {}
	egg.skin = "metalsonic"
	egg.cooldown = TICRATE
	egg.color = SKINCOLOR_COBALT
	egg.state = S_PLAY_FLOAT
end, MT_METALSONIC_SNICK)

// hud

local BARXOFF = 5*FU
local BARYOFF = 5*FU

--[[@param v videolib]]
local function drawBarFill(v, x, y, scale, progress)
	local bar = v.cachePatch('SHOWTIMEBAR')
	local width = FixedMul(bar.width*FU, scale)

	local clampedProg = max(0, min(progress, FU))
	local patch = v.cachePatch("BARFILL")
	local secwidth = FixedMul(patch.width*FU, scale)
	local TIMEMODFAC = 4*(secwidth/FU)
	local drawwidth = min(FixedMul(clampedProg, bar.width*FU), (bar.width*FU)-FU*3)
	local barOffset = ((leveltime%TIMEMODFAC)*FU/4)%secwidth
	v.drawCropped(
		(x+FixedMul(BARXOFF, scale)) - (width/2), y+FixedMul(BARYOFF, scale),
		scale, scale, -- hscale, vscale
		patch, V_SNAPTOBOTTOM, -- patch, flags
		nil, -- colormap
		barOffset, 0, -- sx, sy
		drawwidth, patch.height*FU)

	v.drawScaled(x-(width/2),y,scale,bar,V_SNAPTOBOTTOM)

	local time = consoleplayer.ptsp.time
	local mins = tostring(G_TicsToMinutes(time))
	local secs = tostring(G_TicsToSeconds(time))
	if G_TicsToSeconds(time) < 10 then
		secs = '0'..$
	end
	
	v.drawString(x, y + (2*FU), mins..':'..secs, V_SNAPTOBOTTOM, 'fixed-center')
end

local draw_bar = function(v)
	if ptsp.death_mode then return end
	local timeleft = consoleplayer.ptsp.time
	local progress = FixedDiv(MAX_TIME*FRACUNIT-timeleft*FRACUNIT, MAX_TIME*FRACUNIT)
	drawBarFill(v,
		160*FU,
		180*FU,
		FU/3,
		progress)
end

local draw_laps = function(v)
	for _,lap in pairs(LAP_ANIMS) do
		local graphic = v.cachePatch(lap.text)
		local height = FixedMul(graphic.height*FU, FU/3)
		local width = FixedMul(graphic.width*FU, FU/3)
		local tweeny = ease.outcubic(lap.animtime, -height, 4*FU)
		local sheight = (v.height()/v.dupx())*FU
		if lap.animtime >= FU and lap.animtime < FU*3 then
			tweeny = 4*FU
		elseif lap.animtime >= FU*3 then
			tweeny = ease.incubic(min(lap.animtime-(FU*3), FU), 4*FU, -(sheight-200) - height)
		end
		
		v.drawScaled((160*FU)-(width/2), tweeny, FU/3, graphic, V_SNAPTOTOP)
	end
end

local draw_pizzatime = function(v)
	local PIZZATIME_TWEEN = nil
	if PIZZATIME_TIME >= FU then
		PIZZATIME_TWEEN = ease.insine
	else
		PIZZATIME_TWEEN = ease.outsine
	end
	local pttext = (leveltime % 4 < 2) and 'PIZTIM2' or 'PIZTIM1'
	local graphic = v.cachePatch(pttext)
	local height = FixedMul(graphic.height*FU, FU/3)
	local width = FixedMul(graphic.width*FU, FU/3)

	local time = min(PIZZATIME_TIME, FU*2)
	local sheight = (v.height()/v.dupx())*FU
	local start = sheight
	local endt = (sheight/2)-(height/2)
	if time > FU then
		start = endt
		endt = -(sheight-200) - height
		time = $-FU
	end

	local tweeny = PIZZATIME_TWEEN(time, start, endt)
	v.drawScaled((160*FU)-(width/2), tweeny, FU/3, graphic)
end

local function draw_rank(v)
	v.drawString(120, 4, ptsp_ranks[consoleplayer.ptsp.rank], V_SNAPTOLEFT|V_SNAPTOTOP)
end

addHook('HUD', function(v)
	if not CanPlayPTSP(consoleplayer) then return end
	if not consoleplayer then return end
	if not consoleplayer.mo then return end
	if not consoleplayer.mo.valid then return end
	if not consoleplayer.ptsp then return end
	draw_rank(v)
	if not consoleplayer.ptsp.pizzatime then return end

	draw_laps(v)
	draw_pizzatime(v)
	draw_bar(v)
end)