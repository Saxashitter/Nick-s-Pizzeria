local function IsMach4(speed)
	return (speed >= ntopp_v2.machs[4])
end

local accel = (PU/4)/10

local function spawnmobjfrommobjflagless(mobj,x,y,z,type)
	return P_SpawnMobj(mobj.x+x, mobj.y+y, mobj.z+z, type)
end

local function NerfAbility()
	return (ntopp_v2.NERFED_PEPPINO_IN_OTHER.value 
	and (gametyperules & GTR_RACE or G_RingSlingerGametype()))
	or (ntopp_v2.NERFED_PEPPINO_IN_COOP.value
	and G_CoopGametype())
end

fsmstates[ntopp_v2.enums.MACH3]['npeppino'] = {
	name = "Mach 3",
	enter = function(self, player)
		player.ntoppv2_machtime = 0
		player.pvars.forcedstate = S_PEPPINO_MACH3
		player.pvars.drawangle = player.drawangle
		player.pvars.thrustangle = player.drawangle
		player.pvars.jumppressed = P_IsObjectOnGround(player.mo)
		player.charflags = $|SF_RUNONWATER|SF_CANBUSTWALLS
		player.runspeed = ntopp_v2.machs[3]
		
		local x,y = cos(player.drawangle),sin(player.drawangle)
		local offset = 20
		local xoff,yoff = offset*x,offset*y
		local charge = P_SpawnMobjFromMobj(player.mo,
			player.mo.momx+xoff,
			player.mo.momy+yoff,
			player.mo.momz,
			MT_NTOPP_EFFECTFOLLOWPLAYER
		)
		charge.offset = offset
		charge.fsmstate = ntopp_v2.enums.MACH3
		charge.target = player.mo
		charge.state = S_NTOPPEFFECTS_MACHCHARGE
		charge.renderflags = $|RF_PAPERSPRITE
		charge.angle = player.drawangle+ANGLE_90
		charge.dispoffset = -1
	end,
	think = function(self, p)
		if (p.pvars and p.pvars.dashpad)
			p.mo.state = S_PEPPINO_DASHPAD
			local frame = (p.mo.sprite2 ~= SPR2_STND and skins[p.mo.skin].sprites[p.mo.sprite2].numframes) or 1
			p.mo.tics = frame*states[p.mo.state].var2
			--print(frame*states[p.mo.state].var2)
			p.pvars.dashpad = false
		end
		
		if p.mo.state == S_PEPPINO_DASHPAD
			p.pflags = $1|PF_STASIS
		end
		
		if IsMach4(p.pvars.movespeed)
		and p.pvars.forcedstate ~= S_PEPPINO_MACH4
			p.ntoppv2_machtime = 0
		end
		p.ntoppv2_machtime = $+1
	end,
	playerthink = function(self, player)
		if not (player.mo) then return end
		if not (player.pvars or player.playerstate == PST_DEAD) then
			player.pvars = Init()
			if (player.playerstate == PST_DEAD) then
				return
			end
		end
		
		if player.mo.state == S_PEPPINO_MACH3HIT
			if player.mo.tics >= 69415
				local frames = (player.mo.sprite2 ~= SPR2_STND and skins[player.mo.skin].sprites[player.mo.sprite2].numframes) or 1
				player.mo.tics = frames*2
			end
		end
		
		if IsMach4(player.pvars.movespeed) then
			player.pvars.forcedstate = S_PEPPINO_MACH4
		elseif not (player.pvars.forcedstate == S_PEPPINO_SUPERJUMPCANCEL)
			if (player.charflags & SF_RUNONWATER)
			and player.mo.z == player.mo.watertop
			and player.mo.skin == "nthe_noise"
				player.pvars.forcedstate = S_NOISE_WATERRUN
			else
				player.pvars.forcedstate = S_PEPPINO_MACH3
			end
		end
		
		player.pvars.thrustangle = player.drawangle

		if (player.pvars.jumppressed and P_IsObjectOnGround(player.mo) and not (player.cmd.buttons & BT_JUMP)) then
			player.pvars.jumppressed = false
		end
		if player.mo.flags2 & MF2_TWOD and not P_IsObjectOnGround(player.mo) then
			player.pflags = $|PF_STASIS
		end
		
		if player.mo.z >= player.mo.watertop-2*FU
			player.charflags = $1|SF_RUNONWATER
		else
			player.charflags = $ & ~SF_RUNONWATER
		end
		
		local thrust,angle = PT_ButteredSlope(player.mo)
		
		if (P_IsObjectOnGround(player.mo)) then
			player.pvars.mach_jump_deb = false
			if (player.cmd.forwardmove or player.cmd.sidemove) then
				local add = player.powers[pw_sneakers] and FU or 0
				add = $ + (angle ~= nil and angle > 0 and angle <= 32*ANG1 and FU or 0)
				if (NerfAbility()) then
					player.pvars.movespeed = min(46*FU, $+(FU/5)+add)
				else
					if player.pvars.movespeed < ntopp_v2.machs[4]
						player.pvars.movespeed = $+accel+add
					end
				end
			else
				player.pvars.movespeed = max(ntopp_v2.machs[3], $-accel)
			end
			
			if (player.pvars.forcedstate == S_PEPPINO_SUPERJUMPCANCEL) then
				player.pvars.forcedstate = IsMach4(player.pvars.movespeed) and S_PEPPINO_MACH4 or S_PEPPINO_MACH3
			end
		elseif not player.pvars.mach_jump_deb
		and (player.pflags & PF_JUMPED)
			player.pvars.mach_jump_deb = true
			player.mo.state = S_PEPPINO_MACH3JUMP
		end
		local supposeddrawangle = player.pvars.drawangle
		if supposeddrawangle == nil then supposeddrawangle = player.pvars.thrustangle end
		
		local diff = supposeddrawangle - player.pvars.thrustangle
		local deaccelerating = (P_GetPlayerControlDirection(player) == 2)
	
		if P_IsObjectOnGround(player.mo) then
			if diff >= 2*ANG1 then
				player.drawangle = player.pvars.drawangle
				player.pvars.thrustangle = player.pvars.drawangle - 4*ANG1
			elseif diff <= -2*ANG1 then
				player.drawangle = player.pvars.drawangle
				player.pvars.thrustangle = player.pvars.drawangle + 4*ANG1
			end
		else
			if diff >= 2*ANG1 then
				player.drawangle = player.pvars.drawangle
				player.pvars.thrustangle = player.pvars.drawangle - 2*ANG1
			elseif diff <= -2*ANG1 then
				player.drawangle = player.pvars.drawangle
				player.pvars.thrustangle = player.pvars.drawangle + 2*ANG1
			end
		end
		
		player.pvars.drawangle = player.pvars.thrustangle
		if not (leveltime % 4) then
			TGTLSAfterImage(player)
		end
		P_InstaThrust(player.mo, player.pvars.thrustangle, FixedMul(player.pvars.movespeed, player.mo.scale))
		P_MovePlayer(player)
		
		if (player.powers[pw_justlaunched] and not (player.pflags & PF_JUMPED) and player.mo.momz > 5*FU) then
			fsm.ChangeState(player, ntopp_v2.enums.MACH2)
			player.pvars.forcedstate = S_PEPPINO_SLOPEJUMP
		end
		
		if (player.cmd.buttons & BT_CUSTOM2) and not P_IsObjectOnGround(player.mo) then
			fsm.ChangeState(player, ntopp_v2.enums.DIVE)
		end
		
		if not (player.gotflag) and ((player.cmd.buttons & BT_CUSTOM1 and not (player.pvars.prevkeys and player.pvars.prevkeys & BT_CUSTOM1))) then
			if (not P_IsObjectOnGround(player.mo) and player.cmd.buttons & BT_CUSTOM3) then
				fsm.ChangeState(player, ntopp_v2.enums.UPPERCUT)
				return
			end
			fsm.ChangeState(player, ntopp_v2.enums.GRAB)
			return
		end
		
		if player.mo.skin == "nthe_noise" then
			if (not P_IsObjectOnGround(player.mo))
			and (player.cmd.buttons & BT_CUSTOM3)
			and ((player.cmd.buttons & BT_JUMP) and not (player.pvars.prevkeys & BT_JUMP))
			and player.pvars.cancrusher then
				fsm.ChangeState(player, ntopp_v2.enums.BODYSLAM)
				L_ZLaunch(player.mo, 40*FU)
				player.pvars.savedmomz = player.mo.momz
				player.pvars.forcedstate = S_NOISE_CRUSHER
				return
			end
		end
		
		if not (player.gotflag) and (player.cmd.buttons & BT_CUSTOM3) and (P_IsObjectOnGround(player.mo) or player.ntoppv2_midairsj) then
			fsm.ChangeState(player, ntopp_v2.enums.SUPERJUMPSTART)
			return
		end
		
		if (player.cmd.buttons & BT_CUSTOM2 and P_IsObjectOnGround(player.mo)) then
			fsm.ChangeState(player, ntopp_v2.enums.ROLL)
		end
		
		if (not (player.cmd.buttons & BT_SPIN) and P_IsObjectOnGround(player.mo)) then
			fsm.ChangeState(player, ntopp_v2.enums.SKID)
		end
		
		if NerfAbility() then return end
		
		if player.pvars.supertauntready and player.cmd.buttons & BT_CUSTOM3 and (player.cmd.buttons & BT_TOSSFLAG) and not (player.pvars.prevkeys and player.pvars.prevkeys & BT_TOSSFLAG) then
			fsm.ChangeState(player, ntopp_v2.enums.SUPERTAUNT)
			return
		end
		
		if (player.cmd.buttons & BT_TOSSFLAG) and not (player.pvars.prevkeys and player.pvars.prevkeys & BT_TOSSFLAG) then
			fsm.ChangeState(player, ntopp_v2.enums.TAUNT)
			return
		end
	end,
	exit = function(self, player, state)
		player.pvars.jumppressed = nil
		player.pvars.drawangle = nil
		player.runspeed = skins[player.mo.skin].runspeed
		player.charflags = $ & ~SF_CANBUSTWALLS
	end
}

addHook("MobjDamage", function(mo, pmo)
	if not (pmo and pmo.valid)
	or pmo.type ~= MT_PLAYER
	or not isPTSkin(pmo.skin) return end
	
	local p = pmo.player
	
	if p.fsm == nil return end
	
	if p.fsm.state == ntopp_v2.enums.MACH3
		pmo.state = S_PEPPINO_MACH3HIT
	end
end)

// MAKING SPRINGS AT AS BOOSTER PADS

local horizontal_springs = {
	MT_YELLOWDIAG,
	MT_REDDIAG,
	MT_BLUEDIAG,
	MT_YELLOWHORIZ,
	MT_REDHORIZ,
	MT_BLUEHORIZ,
	MT_YELLOWBOOSTER,
	MT_REDBOOSTER
}

addHook('MobjMoveCollide', function(mo, mobj)
	local player = mo.player
	if (not player.mo) then return end
	if not (mobj) then return end
	if (not isPTSkin(player.mo.skin)) then return end
	if (not player.fsm) then return end
	if (not player.pvars) then return end
	if (not mobj.valid) then return end
	
	if (mo.z > mobj.z+mobj.height) then return end
	if (mobj.z > mo.z+mo.height) then return end
	
	local is_spring = false
	
	for _,i in pairs(horizontal_springs) do
		if mobj.type == i then
			is_spring = true
			break
		end
	end
	
	if (is_spring) then
		player.pvars.drawangle = mobj.angle
		player.pvars.thrustangle = mobj.angle
		player.drawangle = mobj.angle
		if not (mobj.type == MT_YELLOWDIAG or mobj.type == MT_REDDIAG or mobj.type == MT_BLUEDIAG) then
			if (player.pvars.movespeed < ntopp_v2.machs[3]
			and player.fsm.state ~= ntopp_v2.enums.SWINGDING) then
				player.pvars.movespeed = ntopp_v2.machs[3]
				if (player.fsm.state ~= ntopp_v2.enums.MACH3) then
					fsm.ChangeState(player, ntopp_v2.enums.MACH3)
				end
			else
				player.pvars.movespeed = $+(2*FU)
			end
			S_StartSound(mo, sfx_dshpad)
			player.pvars.dashpad = true
		else
			if (player.fsm.state == ntopp_v2.enums.BODYSLAM or player.fsm.state == ntopp_v2.enums.PILEDRIVER) then
				player.pvars.hassprung = true
			end
			player.ntoppv2_gravitydisabled = true
			fsm.ChangeState(player, ntopp_v2.enums.BASE)
			player.pvars.movespeed = ntopp_v2.machs[1]
			player.ntoppv2_diagonalspring = true
		end
	elseif mobj.flags & MF_SPRING then
		if (player.fsm.state == ntopp_v2.enums.BODYSLAM or player.fsm.state == ntopp_v2.enums.PILEDRIVER) then
			player.pvars.hassprung = true
		end
		player.ntoppv2_gravitydisabled = true
	end
	
	if (mobj.type == MT_SPIKE or mobj.type == MT_WALLSPIKE) and (player.fsm.state == ntopp_v2.enums.MACH2 or player.fsm.state == ntopp_v2.enums.MACH3) then
		P_KillMobj(mobj, mo, mo)
	end
end, MT_PLAYER)