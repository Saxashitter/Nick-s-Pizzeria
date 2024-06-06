local function KillAndRemoveMobj(mo,i,s)
	if not mo then return end
	P_KillMobj(mo,i,s)
	if mo.valid then
		S_StopSound(mo)
		P_RemoveMobj(mo)
	end
end

local function CheckAndCrumble(mo, sec)
	if not mo.player.fsm then return end
	if mo.player.fsm.state ~= ntopp_v2.enums.BODYSLAM and mo.player.fsm.state ~= ntopp_v2.enums.PILEDRIVER then return end
	if mo.momz > 0 then return end
	for fof in sec.ffloors()
		if not (fof.flags & FF_EXISTS) continue end -- Does it exist?
		if not (fof.flags & FF_BUSTUP) continue end -- Is it bustable?

		if (mo.z+mo.momz) + mo.height < fof.bottomheight continue end -- Are we too low?
		if (mo.z+mo.momz) > fof.topheight continue end -- Are we too high?

		-- Check for whatever else you may want to    

		EV_CrumbleChain(fof) -- Crumble
	end
end

addHook("PlayerThink", function(p)
	if not p.mo return end
	if not isPTSkin(p.mo.skin) then return end
	
	CheckAndCrumble(p.mo, p.mo.subsector.sector)
	if not (p.cmd.buttons & BT_JUMP)
	and p.ntoppjump
	and p.mo.momz*P_MobjFlip(p.mo) > 0 then
		p.mo.momz = 0
	end
	
	if P_IsObjectOnGround(p.mo) then
		p.mo.ntoppv2_airspring = false
	elseif (p.mo.eflags & MFE_SPRUNG) then
		p.mo.ntoppv2_airspring = true
	end

	if p.pflags & PF_STARTJUMP and p.mo.momz*P_MobjFlip(p.mo) > 0 then
		p.ntoppjump = true
	else
		p.ntoppjump = false
	end

	if not (p.mo.flags & MF_NOTHINK) -- shoutouts to tdpjr for showing me how to do the player grsvity shit
	and not (p.mo.flags & MF_NOGRAVITY)
	and not p.ntoppv2_gravitydisabled
	and not p.mo.ntoppv2_airspring
	and abs(p.mo.momz) then
		local gravity = FixedMul(P_GetMobjGravity(p.mo), skins[p.mo.skin].jumpfactor-FU)
		p.mo.momz = $+gravity
	end
end)

-- CODE BY JosephLol, GIVE EM PRAISE!
-- hi guys its me pacola, i edited his coed haha

local function convertFrame(mspf) -- mspf = milisecond per frame
	local secs = FixedDiv(mspf, 1000)
	local f = secs*TICRATE
	
	return FixedRound(f)/FU
end

addHook("PlayerThink",function(p)
	if not p.mo then return end
	if isPTSkin(p.mo.skin) then
		local mo = p.mo
		local fpsconv = FixedDiv(60, 35)
		if mo.state == S_PLAY_STND
		or mo.state == S_PLAY_WAIT
			if not (mo.frame & FF_ANIMATE)
				mo.frame = $|FF_ANIMATE
			end
			mo.anim_duration = min($,convertFrame(50)) -- its just 2
		end
		if mo.state == S_PLAY_WALK
			mo.tics = min($,convertFrame(50))
			mo.anim_duration = min($,convertFrame(50))
		end
	end
end)

addHook("MobjLineCollide", function(mo, line)
  if not mo.player return end
  if not isPTSkin(mo.skin) then return end

  for _, sec in ipairs({line.frontsector, line.backsector})
    CheckAndCrumble(mo, sec)
  end
end, MT_PLAYER)

local savedkeys = nil
local jump_buffer = false

local jumpdown

addHook('PlayerCmd', function(player, cmd)
	if not NTOPP_Check(player) then savedkeys = nil; jump_buffer = false; return end
	
	if (player.fsm.state == ntopp_v2.enums.BASE
	or player.fsm.state == ntopp_v2.enums.MACH1
	or player.fsm.state == ntopp_v2.enums.MACH2
	or player.fsm.state == ntopp_v2.enums.MACH3
	or player.fsm.state == ntopp_v2.enums.WALLCLIMB
	or player.fsm.state == ntopp_v2.enums.GRAB
	or player.fsm.state == ntopp_v2.enums.LONGJUMP) then
		if ntopp_v2.HOLD_TO_WALK.value then
			if (cmd.sidemove or cmd.forwardmove) and not (cmd.buttons & BT_SPIN) then
				cmd.buttons = $|BT_SPIN
			elseif cmd.buttons & BT_SPIN then
				cmd.buttons = $ & ~BT_SPIN
			end
		end
	end

	if not P_IsObjectOnGround(player.mo) then
		if cmd.buttons & BT_JUMP
		and not jumpdown then
			jump_buffer = true
		elseif not (cmd.buttons & BT_JUMP) then
			jump_buffer = false
		end
	elseif jump_buffer then
		cmd.buttons = $|BT_JUMP
		jump_buffer = false
	end

	jumpdown = (cmd.buttons & BT_JUMP)
end)



addHook('PostThinkFrame', function()
	for player in players.iterate do
		if not player.mo then continue end
		if not isPTSkin(player.mo.skin) then continue end
		if player.powers[pw_carry] then continue end
		if (player.pvars and player.pvars.forcedstate) then continue end

		if not P_IsObjectOnGround(player.mo) 
		and (player.mo.state == S_PLAY_WALK
		or player.mo.state == S_PLAY_STND) then
			player.mo.state = S_PLAY_FALL
		end
	end
end)

addHook('MobjDeath', function(mo) //rbf was here
	local player = mo.player
	if not (player.valid) then return end
	if not (player.fsm) then return end
	
	fsm.ChangeState(player, ntopp_v2.enums.PAIN)
	if player.mo.skin == "nthe_noise" //woag 
	S_StartSound(player.mo, sfx_dwaha)
	else
	S_StartSound(player.mo, sfx_eyaow)
	end
end, MT_PLAYER)

addHook('PlayerSpawn', function(player)
	if not (player.valid) then return end
	if not (player.fsm) then return end
	
	if player.powers[pw_carry] then
		player.powers[pw_carry] = 0
	end
	
	fsm.ChangeState(player, ntopp_v2.enums.BASE)
	if player.pvars then player.pvars.movespeed = ntopp_v2.machs[1] end
end)

addHook('PlayerCanEnterSpinGaps', function(player)
	return true
end)

--[[addHook('MobjMoveBlocked', function(mo)
	if not (mo.valid) then return end
	if not (mo.ntoppv2_deathcollide) then return end
	
	local src = mo.ntoppv2_deathcollide.valid and mo.ntoppv2_deathcollide or nil
	P_KillMobj(mo, src, src)
	mo.ntoppv2_deathcollide = nil
end, MT_)]]
addHook('MobjSpawn', function(mo)
	mo.setx,mo.sety,mo.setz = 0,0,0
	mo.killed = false
end, MT_NTOPP_GRABBED)

addHook('MobjThinker', function(mo)
	if not mo.valid then return end

	if mo.target
	and mo.target.valid 
	and not mo.killed then
		P_SetOrigin(mo,
			mo.target.x+mo.setx-mo.target.momx,
			mo.target.y+mo.sety-mo.target.momy,
			mo.target.z+mo.setz-mo.target.momz
		)
		mo.momx = mo.target.momx
		mo.momy = mo.target.momy
		mo.momz = mo.target.momz
	end
	if mo.tracer
	and mo.tracer.valid then
		mo.state = mo.tracer.state
		mo.sprite = mo.tracer.sprite
		mo.frame = mo.tracer.frame
		mo.radius = mo.tracer.radius
		mo.height = mo.tracer.height
		if not mo.savedflags then
			mo.savedflags = mo.tracer.flags
			mo.savedflags2 = mo.tracer.flags2
			mo.savedeflags = mo.tracer.eflags
			mo.tracer.flags = MF_NOCLIPHEIGHT|MF_NOCLIP|MF_NOGRAVITY
			mo.tracer.flags2 = MF2_DONTDRAW
			mo.tracer.ngrab = true
		end
	end
	if mo.killed then
		if mo.z <= mo.floorz
		or mo.z+mo.height >= mo.ceilingz then
			P_KillMobj(mo)
		end
	end
end, MT_NTOPP_GRABBED)

addHook('MobjMoveBlocked', function(mo)
	if mo.killed then
		P_KillMobj(mo)
	end
end, MT_NTOPP_GRABBED)

addHook('MobjDeath', function(mo)
	mo.flags2 = $|MF2_DONTDRAW
	if mo.tracer then
		mo.tracer.flags = mo.savedflags
		mo.tracer.flags2 = mo.savedflags2
		mo.tracer.eflags = mo.savedeflags
		P_SetOrigin(mo.tracer, mo.x, mo.y, mo.z)
		if mo.killed then
			P_KillMobj(mo.tracer, mo.target, mo.target)
		else
			mo.tracer.ngrab = nil
		end
	end
end, MT_NTOPP_GRABBED)

addHook('MusicChange', function(old, new)
	if not (consoleplayer and consoleplayer.valid) return end
	
	if (old == "PBSBEA" or old == "NBSBEA") and (new == "_clear" or new == "_CLEAR") then
		return true
	end
	
	if new == mapmusname and consoleplayer.ntoppv2_boogie then return 'MVITBY' end
	if ((gamestate == GS_LEVEL and consoleplayer.mo and consoleplayer.mo.skin == "nthe_noise")
	or (consoleplayer.skin == "nthe_noise")) then
		local music = {
			['PIZTIM'] = "NOISL1",
			['DEAOLI'] = "NOISL2",
			['PIJORE'] = "NOISL3",
			['LAP3LO'] = "NOISL3",
			['LAP4LO'] = "NOISL3"
		}
		if music[new] and old == music[new] then return true end
		
		return music[new]
	end
end)

addHook("MusicChange", function(old, new)
	if gamestate ~= GS_LEVEL then return end

	if not NTOPP_Check(consoleplayer) then return end

	if new:lower() ~= "cezr" then return end
	if old == "PCEZR" then return true end

	return "PCEZR"
end)

addHook('PlayerMsg', function(player, type, target, msg)
	if type ~= 0 then return end
	if gamestate ~= GS_LEVEL then return end
	
	if not player.mo then return end
	if not isPTSkin(player.mo.skin) then return end
	if not player.fsm then return end
	if not player.pvars then return end
	
	if msg:lower() == 'boogie' then
		S_ChangeMusic('MVITBY', true, player)
		player.ntoppv2_boogie = true
		return true
	end
end)

addHook("TouchSpecial", function(s, pmo)
	local p = pmo.player
	if p.fsm.state ~= ntopp_v2.enums.BASE
		fsm.ChangeState(p, ntopp_v2.enums.BASE)
		p.pvars.movespeed = ntopp_v2.machs[1]
		p.drawangle = s.angle
		if p.speed < 10*FU
			P_InstaThrust(pmo, p.drawangle, 10*FU)
		end
	end
end, MT_EGGSHIELD)

addHook('MobjDeath', function(target, inf, source)
    if not (target.flags & MF_ENEMY) return end
    if not (target and target.valid and inf and inf.valid and inf.health and inf.player and isPTSkin(inf.skin) and inf.player.fsm and inf.player.pvars) return end
    local player = inf.player
	
	IncreaseSuperTauntCount(player)
end)

local function doPain(player) //rbf was also here ig
S_StartSound(player.mo, sfx_owmyas)
	fsm.ChangeState(player, ntopp_v2.enums.PAIN)
	--if player.rings > 0 then
	if player.mo.skin == "nthe_noise"
		S_StartSound(player.mo, L_Choose(sfx_npain1, sfx_npain2, sfx_npain3, sfx_npain4))
		else
		S_StartSound(player.mo, L_Choose(sfx_pain1, sfx_pain2))
		end
	--end
end

addHook('MobjDamage', function(target, inf, source, _, dmg)
    if not target.player then return end
    if not isPTSkin(target.skin) then return end
    if P_PlayerInPain(target.player) then return end
	if dmg == DMG_FIRE and not (dmg & DMG_DEATHMASK) return end
	
	doPain(target.player)
end, MT_PLAYER)

addHook('MobjMoveCollide', function(mo, mobj)
	if not (mobj and mobj.valid and mobj.type == MT_ROSY) then return end

	local player = mo.player
	
	if not isPTSkin(player.mo.skin) then return end
	if player.fsm and player.fsm.state ~= ntopp_v2.enums.TAUNT then
		return
	end
	
	player.drawangle = R_PointToAngle2(mo.x, mo.y, mobj.x, mobj.y)
	P_KillMobj(mobj)
	fsm.ChangeState(player, ntopp_v2.enums.PARRY)
end, MT_PLAYER)

addHook('ShouldDamage', function(target, inflictor, source, _, dmg)
	if not target.player then return end
	local player = target.player
	
	if not isPTSkin(player.mo.skin) then return end
	if not (inflictor and inflictor.valid) then return end
	if inflictor.ngrab then return false end

	if player.fsm and player.fsm.state == ntopp_v2.enums.GRAB and target.skin ~= "ngustavo" then
		return false
	end
	if player.fsm and player.fsm.state == ntopp_v2.enums.TAUNT and (dmg ~= DMG_FIRE or mapheaderinfo[gamemap].bonustype == 1) then
		if (inflictor.flags & MF_MISSILE) then
			inflictor.target = target
			inflictor.momx = -$
			inflictor.momy = -$
			inflictor.momz = -$
		else
			P_DamageMobj(inflictor, target, target)
		end
		fsm.ChangeState(player, ntopp_v2.enums.PARRY)
		return false
	end
	if player.fsm and (player.fsm.state == ntopp_v2.enums.PARRY) then
		return false
	end
end)

addHook('ShouldDamage', function(target,inf,source)
	if not inf then return end
	if not target then return end
	if not (inf.player and isPTSkin(inf.skin) and inf.player.fsm) then return end
	
	if (inf.z > target.z+target.height) then return end
	if (target.z > inf.z+inf.height) then return end
	
	if P_PlayerCanDamage(inf.player,target) and (inf.player.fsm.state == ntopp_v2.enums.GRAB and inf.skin ~= "ngustavo") then
		inf.player.drawangle = R_PointToAngle2(inf.x, inf.y, target.x, target.y)
		fsm.ChangeState(inf.player, ntopp_v2.enums.GRABBED)
	end
end)

addHook('ShouldDamage', function(target,inf,source)
	if not target.valid then return end

	if target.ntoppv2_nodamagetime
	or target.ntoppv2_grabbed
	or (
		target.ntoppv2_deathcollide
		and inf.valid
	)
	then
		return false
	end
end)

addHook('MobjThinker', function(mo)
	if not mo.valid then return end
	if not mo.target then P_KillMobj(mo) return end
	if not mo.target.valid then P_KillMobj(mo) return end
	if not isPTSkin(mo.target.skin) then P_KillMobj(mo) return end
	if not mo.fsmstate then P_KillMobj(mo) return end

	local player = mo.target.player
	if not player.fsm then P_KillMobj(mo) return end

	if player.fsm.state ~= mo.fsmstate then P_KillMobj(mo) return end
	if player.mo.eflags & MFE_VERTICALFLIP then
		mo.eflags = $|MFE_VERTICALFLIP
	else
		mo.eflags = $ & ~MFE_VERTICALFLIP
	end

	local dazee = mo.eflags & MFE_VERTICALFLIP and player.mo.z+player.mo.height or player.mo.z
	local offsetz = mo.offsetz and mo.offsetz*P_MobjFlip(mo) or 0
	local xoff = mo.offsetx or 0
	local yoff = mo.offsety or 0
	P_MoveOrigin(mo,
		mo.target.x-mo.target.momx+xoff,
		mo.target.y-mo.target.momy+yoff,
		dazee + offsetz - mo.target.momz
	)
	mo.momx = mo.target.momx
	mo.momy = mo.target.momy
	mo.momz = mo.target.momz
	mo.angle = player.drawangle
	if (mo.renderflags & RF_PAPERSPRITE)
		mo.angle = $+ANGLE_90
	end
	
	--epic...
	if mo.state == S_NTOPPEFFECTS_MACHCHARGE
		mo.momx,mo.momy,mo.momz = 0,0,0
		local x,y = cos(player.drawangle),sin(player.drawangle)
		local xoff,yoff = mo.offset*x,mo.offset*y
		P_MoveOrigin(mo,
			mo.target.x+xoff,
			mo.target.y+yoff,
			dazee + offsetz - mo.target.momz
		)
	end
	
	if not (camera.chase)
	and (mo.target == displayplayer.mo)
		mo.flags2 = $|MF2_DONTDRAW
	else
		mo.flags2 = $ &~MF2_DONTDRAW
	end
end, MT_NTOPP_EFFECTFOLLOWPLAYER)

addHook('PlayerCanDamage', function(player, mobj)
	if (not player.mo) then return end
	if (not mobj.valid) then return end
	if (not isPTSkin(player.mo.skin)) then return end
	if (not player.fsm) then return end
	if (not player.pvars) then return end
	if (mobj.z > player.mo.z+player.mo.height) then return end
	if (player.mo.z > mobj.z+mobj.height) then return end
	
	if (player.fsm.state == ntopp_v2.enums.MACH3 and (mobj.flags & MF_ENEMY or mobj.flags & MF_MONITOR)) then
		return true
	end
	
	if (player.fsm.state == ntopp_v2.enums.UPPERCUT and (mobj.flags & MF_ENEMY or mobj.flags & MF_MONITOR or mobj.flags & MF_BOSS)) then
		return true
	end
	
	if (player.fsm.state == ntopp_v2.enums.DRIFT and (mobj.flags & MF_ENEMY or mobj.flags & MF_MONITOR)) then return true end
	if (player.fsm.state == ntopp_v2.enums.MACH2 and player.pvars.breakdance and (mobj.flags & MF_ENEMY or mobj.flags & MF_MONITOR)) then return true end
	if (player.fsm.state == ntopp_v2.enums.SUPERJUMP and (mobj.flags & MF_ENEMY or mobj.flags & MF_MONITOR)) then return true end

	if ((player.fsm.state == ntopp_v2.enums.GRAB and player.mo.skin ~= "ngustavo")
	and mobj.flags & MF_ENEMY
	and (not (player.pvars.ntoppv2_grabbed
	and player.pvars.ntoppv2_grabbed.valid)
	or player.pvars.ntoppv2_grabbed == mobj)) then
		return false
	end

	if ((player.fsm.state == ntopp_v2.enums.GRAB and player.mo.skin ~= "ngustavo")
	and (mobj.flags & MF_BOSS
	or mobj.flags & MF_MONITOR)
	and
	(not (player.pvars.ntoppv2_grabbed
	and player.pvars.ntoppv2_grabbed.valid)
	or player.pvars.ntoppv2_grabbed == mobj)) then
		return true
	end

	if (player.fsm.state == ntopp_v2.enums.BASE_GRABBEDENEMY
	and (not player.pvars.killtime
	and (not (player.pvars.ntoppv2_grabbed
	and player.pvars.ntoppv2_grabbed.valid)
	and player.pvars.ntoppv2_grabbed == mobj))) then
		return false
	end
	
	if player.mo.skin ~= "nthe_noise" then return end
	if (player.fsm.state == ntopp_v2.enums.DIVE or player.fsm.state == ntopp_v2.enums.WALLBOUNCE) then
		return true
	end
end)

addHook('ShieldSpecial', function(player)
	if not player.mo then return end
	if not player.fsm then return end
	if not player.pvars then return end
	if player.pflags & PF_THOKKED then return end
	if not isPTSkin(player.mo.skin) then return end
	
	if player.powers[pw_shield] == SH_ELEMENTAL then
		fsm.ChangeState(player, ntopp_v2.enums.BASE)
		player.pvars.movespeed = ntopp_v2.machs[1]
	end
end)

addHook("ThinkFrame", do
	for player in players.iterate
		local mo = player.mo
		if not player.mo then continue end
		if player.playerstate ~= PST_LIVE then continue end
		if P_IsObjectOnGround(mo)
		and (mo.state == S_PEPPINO_MACH3 or mo.state == S_NOISE_WATERRUN or mo.state == S_PEPPINO_MACH4)
		and leveltime%10 == 0
			for i = 1,2
				local ang = i * ANG10
				local angle = player.drawangle + ANGLE_45
				if i == 2 then
					angle = $-ANGLE_90
				end
				local dust = P_SpawnMobjFromMobj(mo, 14*cos(angle), 14*sin(angle), 0, MT_THOK)
				
				dust.scale = mo.scale
				dust.angle = player.drawangle
				if mo.z == mo.watertop
					P_SetOrigin(dust, mo.x, mo.y, mo.z)
					dust.state = S_CCWATERFX
					break
				else
					dust.state = S_DASHCLOUD
				end
			end
		end
	end
end)

addHook("ThinkFrame", do
	for player in players.iterate
		local mo = player.mo
		if not player.mo then continue end
		if P_IsObjectOnGround(mo)
		and (mo.state == S_PEPPINO_MACH1
		or mo.state == S_PEPPINO_MACH2
		or mo.state == S_PEPPINO_MACHDRIFT3
		or mo.state == S_PEPPINO_MACHDRIFTTRNS3
		or mo.state == S_PEPPINO_MACHDRIFT2
		or mo.state == S_PEPPINO_MACHDRIFTTRNS2
		or mo.state == S_PEPPINO_BELLYSLIDE) --I want to die
		and leveltime%10 == 0
			for i = 1,2
				local ang = i * ANG10
				local angle = player.drawangle + ANGLE_45
				if i == 2 then
					angle = $-ANGLE_90
				end
				local dust = P_SpawnMobjFromMobj(mo, FixedMul(mo.radius, cos(angle)), FixedMul(mo.radius, sin(angle)), 0, MT_THOK)
				
				dust.scale = mo.scale
				dust.angle = player.drawangle
				dust.state = S_SMALLDASHCLOUD
			end
		end
	end
end)

addHook("ThinkFrame", do
	for p in players.iterate
		if not p.mo then continue end
		if p.pepfootstep == nil
			p.pepfootstep = false
		end
		if (p.mo.state == S_PLAY_WALK
		or p.mo.state == S_PEPPINO_WALLCLIMB)
		and stepframes(p)
		and P_IsObjectOnGround(p.mo)
		and isPTSkin(p.mo.skin)
		and not p.pepfootstep
			p.pepfootstep = true
			local step = P_SpawnMobj(p.mo.x,p.mo.y,p.mo.z,MT_THOK)
			step.state = S_CLOUDEFFECT
			
			S_StartSound(p.mo, sfx_pstep)
		end
		if p.pepfootstep
		and not stepframes(p)
			p.pepfootstep = false
		end
	end
end)

--nick you are doing mach speed sounds
// i know

local function checkSFX(mmsfx, msfxv, tsfx, sound, v)
	local stop = false
	if mmsfx[msfxv]
		for _, vs in pairs(tsfx[msfxv]) do
			local uvs = (type(vs) ~= "table" and vs) or vs[1]
			if v == uvs
				stop = true
				break
			end
		end
	elseif sound == v
		stop = true
	end
	return stop
end

addHook('ThinkFrame', do
	for player in players.iterate do
		if not player.mo then continue end
		if not isPTSkin(player.mo.skin) then continue end
		if not player.fsm then continue end
		if not player.pvars then continue end
		
		local sound_checks = {}
		local msfx = {}
		local unum = ntopp_v2.MACH_SOUNDS.value
		while ntopp_v2.machsounds[unum] == nil do
			local add = (-1 and ntopp_v2.MACH_SOUNDS.value < 1) or 1
			unum = $-add
		end
		msfx[1] = ntopp_v2.machsounds[unum][1]
		msfx[2] = ntopp_v2.machsounds[unum][2]
		msfx[3] = ntopp_v2.machsounds[unum][3]
		msfx[4] = ntopp_v2.machsounds[unum][4]
		local skinsfx = {}
		if ntopp_v2.machsounds[unum][player.mo.skin]
			for i = 1, 4 do
				local t = ntopp_v2.machsounds[unum][player.mo.skin]
				if t[i]
					msfx[i] = t[i]
					skinsfx[i] = true
				end
			end
		end
		local mmsfx = {} --mm is multiple mach
		local tsfx = {}
		mmsfx[1] = false
		mmsfx[2] = false
		mmsfx[3] = false
		mmsfx[4] = false
		for i = 1, 4 do
			if type(msfx[i]) == "table"
				local t = msfx[i]
				if t[0] ~= nil
					t[0], t[#ntopp_v2.machsounds[unum][i]] = $2, $1
				end
				tsfx[i] = t
				msfx[i] = $[1]
				mmsfx[i] = true
			end
			continue
		end
		sound_checks[S_PEPPINO_MACH1] = {msfx[1], function() return (P_IsObjectOnGround(player.mo)) end, 1}
		sound_checks[S_PEPPINO_MACH2] = {msfx[2], function() return (P_IsObjectOnGround(player.mo)) end, 2}
		sound_checks[S_PEPPINO_WALLCLIMB] = {msfx[2], function() return true end, 2}
		sound_checks[S_PEPPINO_MACH3] = {msfx[3], function() return true end, 3}
		sound_checks[S_NOISE_WATERRUN] = {msfx[3], function() return true end, 3}
		sound_checks[S_PEPPINO_SUPERJUMPCANCEL] = {msfx[3], function() return true end, 3}
		sound_checks[S_PEPPINO_MACH4] = {msfx[4], function() return true end, 4}
		sound_checks[S_PEPPINO_BODYSLAM] = {sfx_gploop, function() return not player.pvars.soundtime end}
		sound_checks[S_PEPPINO_DIVEBOMB] = {sfx_gploop, function() return not player.pvars.soundtime end}
		sound_checks[S_PEPPINO_PILEDRIVER] = {sfx_gploop, function() return not player.pvars.soundtime end}
		sound_checks[S_PEPPINO_SECONDJUMP] = sound_checks[S_PEPPINO_MACH1]
		--sound_checks[S_PEPPINO_SECONDJUMP] = (player.fsm.state == ntopp_v2.enums.MACH1 and sound_checks[S_PEPPINO_MACH1]) or (player.fsm.state == ntopp_v2.enums.MACH2 and sound_checks[S_PEPPINO_MACH2]) or nil
		sound_checks[S_NOISE_SPIN] = sound_checks[S_PEPPINO_MACH2]
		sound_checks[S_NOISE_SPIN] = {sfx_naspin, function() return true end}
		
		if player.mo.skin == "nthe_noise"
			sound_checks[S_PEPPINO_WALLCLIMB] = {sfx_nmclop, function() return true end}
			sound_checks[S_PEPPINO_DIVEBOMB] = {sfx_ntrnd, function() return true end}
			sound_checks[S_NOISE_DRILLAIR] = sound_checks[S_PEPPINO_DIVEBOMB]
			sound_checks[S_PEPPINO_SECONDJUMP] = sound_checks[S_PEPPINO_MACH2]
		end
		
		local sound = player.pvars.forcedstate and sound_checks[player.pvars.forcedstate] and sound_checks[player.pvars.forcedstate][1]
		local can = player.pvars.forcedstate and sound_checks[player.pvars.forcedstate] and sound_checks[player.pvars.forcedstate][2]()
		local msfxv = player.pvars.forcedstate and sound_checks[player.pvars.forcedstate] and sound_checks[player.pvars.forcedstate][3]
		if player.mo.state == S_PEPPINO_SECONDJUMP -- nick please nick, please teigjpfdlkmdd
		and player.mo.skin == "nthe_noise" -- i hate hardcoding these kind of things, but nick's code is being hard to work with when it comes to S_PEPPINO_SECONDJUMP
		-- IM SORRY ILL REWORK THIS :sob:
			sound = sound_checks[S_PEPPINO_MACH1][1]
			can = sound_checks[S_PEPPINO_MACH1][2]()
			msfxv = sound_checks[S_PEPPINO_MACH1][3]
		end
		
		if msfxv and tsfx[msfxv]
			local t = tsfx[msfxv]
			for _, v in pairs(t) do
				local uv = (type(v) == "table" and v[1]) or v
				local check = can
				if type(v) == "table"
					check = v[2](player)
				end
				
				if check
				and not S_SoundPlaying(player.mo, uv)
					S_StartSound(player.mo, uv)
				elseif not check
				and S_SoundPlaying(player.mo, uv)
					S_StopSoundByID(player.mo, uv)
				end
			end
		elseif sound and can then
			if not S_SoundPlaying(player.mo, sound) then
				S_StartSound(player.mo, sound)
			end
		elseif not can and sound
			if S_SoundPlaying(player.mo, sound) then
				S_StopSoundByID(player.mo, sound)
			end
		end
		for _,i in pairs(sound_checks)
			if player.pvars.forcedstate == _ then continue end
			
			if (_ == S_PEPPINO_MACH1 or _ == S_PEPPINO_MACH2)
			and player.mo.state == S_PEPPINO_SECONDJUMP continue end
			
			if i[1] == sound then continue end
			
			if (i[3] == msfxv) and mmsfx[msfxv] continue end
			
			if mmsfx[i[3]]
				local t = tsfx[i[3]]
				for _, v in pairs(t) do
					local uv = (type(v) ~= "table" and v) or v[1]
					
					local stop = checkSFX(mmsfx, msfxv, tsfx, sound, uv)
					if stop continue end
					
					if S_SoundPlaying(player.mo, uv)
						S_StopSoundByID(player.mo, uv)
					end
				end
			elseif S_SoundPlaying(player.mo, i[1]) then
				local stop = checkSFX(mmsfx, msfxv, tsfx, sound, i[1])
				if stop continue end
				
				S_StopSoundByID(player.mo, i[1])
			end
		end
	end
end)

addHook("ThinkFrame", function() -- pacola wuz here
	for p in players.iterate do
		if not NTOPP_Check(p) then continue end

		if (p.pflags & PF_SLIDING)
		and p.mo.state == S_PLAY_PAIN
			p.mo.state = S_PEPPINO_WATERSLIDE
		end
		
		if p.mo.state == S_PEPPINO_WATERSLIDE
			local frame = skins[p.mo.skin].sprites[p.mo.sprite2].numframes
			local tics = 2
			p.mo.frame = leveltime%(frame*tics)/tics
			
			if not (p.pflags & PF_SLIDING)
				p.mo.state = S_PLAY_PAIN -- temporary, please remove this when you add the banana thing
				-- hi nick insert changing to banana slipping thing here
				if p.mo.skin == "nthe_noise" -- dont remove this, it makes the stuff from piza tower apear when youre nois and get out of it
					for i = 1, 3 do
						local d = P_SpawnMobj(p.mo.x, p.mo.y, p.mo.z, MT_THOK)
						P_InstaThrust(d, ANG1*P_RandomRange(0, 359), P_RandomRange(-4, 4)*FU)
						P_SetObjectMomZ(d, P_RandomRange(-5, -2)*FU)
						d.flags = MF_NOCLIP|MF_NOCLIPHEIGHT
						d.state = S_FLOATERDEBRIS
						d.frame = i-1
					end
				end
			end
		end
		
		if p.mo.state == S_PLAY_JUMP
		or p.mo.state == S_PLAY_SPRING
			p.mo.state = S_PEPPINO_JUMPTRNS
			local fnum = skins[p.mo.skin].sprites[p.mo.sprite2].numframes
			local v2 = states[p.mo.state].var2
			p.mo.tics = fnum*v2-v2
		end
		
		if (p.mo.state == S_PEPPINO_MACH3JUMP or p.mo.state == S_PEPPINO_SUPERJUMPSTARTTRNS)
		and (p.mo.tics >= 69415 or p.mo.tics == -1)
			local fnum = p.mo.sprite2 ~= SPR2_STND and skins[p.mo.skin].sprites[p.mo.sprite2].numframes or 1
			local v2 = states[p.mo.state].var2
			p.mo.tics = fnum*v2-v2
		end
		
		if (p.mo.state == S_PEPPINO_JUMPTRNS or p.mo.state == S_PEPPINO_MACH3JUMP)
		and (p.mo.frame & ~FF_ANIMATE) == skins[p.mo.skin].sprites[p.mo.sprite2].numframes-1
			p.mo.frame = $ & ~FF_ANIMATE
		end
		
		if p.pvars.fascreamdelay
			p.pvars.fascreamdelay = $-1
		end
		
		if p.mo.skin == "nthe_noise"
		and p.powers[pw_super]
		and p.mo.color >= skins[p.mo.skin].supercolor
		and p.mo.color <= skins[p.mo.skin].supercolor+4
			p.mo.color = SKINCOLOR_SUPERNOISE
		end
	end
end)

addHook("ShouldDamage", function(pmo, inf, _, _, dmg)
	if not isPTSkin(pmo.skin)
	or pmo.skin == "ngustavo"
	or dmg ~= DMG_FIRE
	or (dmg & DMG_DEATHMASK)
	or mapheaderinfo[gamemap].bonustype == 1 return end
	
	local p = pmo.player
	
	--if (inf and inf.valid) and p.fsm.state == ntopp_v2.enums.TAUNT return end
	
	p.pvars.oldaccel = p.acceleration
	fsm.ChangeState(p, ntopp_v2.enums.FIREASS)
	p.pvars.movespeed = skins[p.mo.skin].normalspeed
	p.powers[pw_flashing] = TICRATE+TICRATE/3
	return false
end, MT_PLAYER)

addHook("MusicChange", function(_, newname)
    if splitscreen
    or not (consoleplayer and consoleplayer.valid)
    or skins[consoleplayer.skin].name ~= "nthe_noise" return end

    if string.upper(newname) == "_SUPER"
        return "NOISUP"
    end
end)

-- gustavo thing

local function nskincheck(p)
	if p.mo
	and p.mo.skin ~= "nthe_noise"
	and p.ntoppv2_skinmo then
		local s = p.ntoppv2_skinmo
		if (s and s.valid)
			P_RemoveMobj(s)
		end
		p.ntoppv2_skinmo = nil
	end	
end

local function soupflagcheck(p)
	if p.ntoppv2_soupflagsapplied
		p.mo.eflags = $ & ~(MFE_FORCESUPER|MFE_FORCENOSUPER)
		p.ntoppv2_soupflagsapplied = false
	end
end

addHook("ThinkFrame", function() -- this doesnt even work properly :sob: (future pacola here, what did i mean with this)
	for p in players.iterate do
		if not NTOPP_Check(p) then
			nskincheck(p)
			soupflagcheck(p)
			continue
		end -- haha i just copied the stuff from above (again)
		nskincheck(p)

		if p.mo.skin ~= "nthe_noise"
		and p.mo.skin ~= "ngustavo" then
			soupflagcheck(p)
			continue
		end
	
		if p.mo.skin == "nthe_noise" then
			p.mo.eflags = ($1|MFE_FORCENOSUPER) & ~MFE_FORCESUPER
			p.ntoppv2_soupflagsapplied = true
			
			if not (p.ntoppv2_skinmo and p.ntoppv2_skinmo.valid) then
				p.ntoppv2_skinmo = P_SpawnMobj(p.mo.x, p.mo.y, p.mo.z, MT_NOISE_OVERLAY)
				local s = p.ntoppv2_skinmo
				s.skin = p.mo.skin
				s.state = p.mo.state
				s.target = p.mo
			else
				local mo = p.ntoppv2_skinmo
				local pmo = p.mo
				mo.flags2 = pmo.flags2
				mo.eflags = (pmo.eflags & ~MFE_FORCENOSUPER)|MFE_FORCESUPER
				mo.state = pmo.state
				mo.sprite = pmo.sprite
				mo.sprite2 = pmo.sprite2|FF_SPR2SUPER
				mo.frame = pmo.frame
				mo.tics = pmo.tics
				mo.scale = pmo.scale
				mo.anim_duration = pmo.anim_duration
				mo.dispoffset = pmo.dispoffset+1
				
				mo.angle = p.drawangle
				local zadd = (mo.eflags & MFE_VERTICALFLIP) and pmo.height or 0
				P_MoveOrigin(mo, pmo.x, pmo.y, pmo.z+zadd)
				
				mo.color = NoiseSkincolor[p.skincolor] or SKINCOLOR_FLESHEATER
			end
		end
			
			if p.mo.skin ~= "ngustavo" continue end
			
			if p.ntoppv2_hasbrick
				p.mo.eflags = ($1|MFE_FORCENOSUPER) & ~MFE_FORCESUPER
			else
				p.mo.eflags = ($1|MFE_FORCESUPER) & ~MFE_FORCENOSUPER
			end
			p.ntoppv2_soupflagsapplied = true
	end
end)