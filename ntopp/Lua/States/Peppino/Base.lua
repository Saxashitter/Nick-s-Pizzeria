local function NerfAbility()
	return (ntopp_v2.NERFED_PEPPINO_IN_OTHER.value 
	and (gametyperules & GTR_RACE or G_RingSlingerGametype()))
	or (ntopp_v2.NERFED_PEPPINO_IN_COOP.value
	and G_CoopGametype())
end

local function IsPanicSprite(player)
	return ((player.ptsp and player.ptsp.pizzatime)
		or (PTSR and PTSR.pizzatime)
		or (PizzaTime and PizzaTime.sync and PizzaTime.sync.PizzaTime)
		or (PTV3 and PTV3.pizzatime))
end

local function shouldChange(p) -- guess who made this. obviously me, barack obama
	if P_PlayerInPain(p)
	or p.playerstate == PST_DEAD
	or p.powers[pw_carry]
		return false
	end
	return true
end

fsmstates[ntopp_v2.enums.BASE]['npeppino'] = {
	name = "Standard",
	enter = function(self, player, state)
		player.pvars.forcedstate = nil
		player.pvars.landanim = P_IsObjectOnGround(player.mo)
		player.pvars.taunthold = 0
		if (player.mo)
		and shouldChange(player) then
			player.mo.state = S_PLAY_STND // will default to what state it should be
		end
		player.ntoppv2_boogie = false
	end,
	playerthink = function(self, player)
		if player.mo.skin == "nthe_noise" and player.cmd.buttons & BT_CUSTOM3 then
			player.pflags = $|PF_JUMPSTASIS
		end
		
		if player.pvars.forcedstate == S_PEPPINO_LEVELCOMPLETE
			player.pflags = $1|PF_FULLSTASIS
			return
		end
		
		player.pvars.movespeed = max(ntopp_v2.machs[1], $-FU)
		player.normalspeed = max(player.pvars.movespeed, skins[player.mo.skin].normalspeed)

		if IsPanicSprite(player)
		and P_IsObjectOnGround(player.mo) then
			if player.mo.momx == 0
			and player.mo.momy == 0
			and player.mo.state ~= S_PEPPINO_PANIC then
				player.mo.state = S_PEPPINO_PANIC
				player.panim = PA_IDLE
			elseif not (player.mo.momx == 0
			and player.mo.momy == 0)
			and player.mo.state == S_PEPPINO_PANIC then
				player.mo.state = S_PLAY_STND
			end
		end
		
		if player.ntoppv2_boogie and P_IsObjectOnGround(player.mo) then
			player.mo.state = S_PEPPINO_BOOGIE
			if player.speed ~= 0 then
				player.panim = PA_WALK
			else
				player.panim = PA_IDLE
			end
		end
		
		if player.pvars.hassprung then
			player.powers[pw_strong] = $ & ~STR_SPRING
			player.pvars.hassprung = nil
		end
		
		if (player.powers[pw_carry]) then return end
		if (player.pflags & PF_SLIDING) then return end
		if (player.pflags & PF_SPINNING) then return end
		if P_PlayerInPain(player) return end
		
		if (player.cmd.buttons & BT_TOSSFLAG) and not (player.pvars.prevkeys and player.pvars.prevkeys & BT_TOSSFLAG) then
			fsm.ChangeState(player, ntopp_v2.enums.TAUNT)
			return
		end
		
		if (player.cmd.buttons & BT_TOSSFLAG)then
			if player.pvars.taunthold < 8 then
				player.pvars.taunthold = $+1
			elseif P_IsObjectOnGround(player.mo)
				player.pvars.taunthold = 0
				fsm.ChangeState(player, ntopp_v2.enums.BREAKDANCE)
			end
		else
			player.pvars.taunthold = 0
		end
		
		if (gametyperules & GTR_RACE and leveltime < 4*TICRATE) then return end
		if (player.pflags & PF_STASIS) then return end
		if (player.exiting) then return end
		
		if (player.cmd.buttons & BT_CUSTOM3)
		and (player.cmd.buttons & BT_CUSTOM1 and not (player.pvars.prevkeys & BT_CUSTOM1)) then
			fsm.ChangeState(player, ntopp_v2.enums.UPPERCUT)
			return
		end
		
		if not (player.gotflag) and ((player.cmd.buttons & BT_CUSTOM1 and not (player.pvars.prevkeys and player.pvars.prevkeys & BT_CUSTOM1))) then
			fsm.ChangeState(player, ntopp_v2.enums.GRAB)
			return
		end
		
		if player.mo.skin == "nthe_noise" then
			if (P_IsObjectOnGround(player.mo) and not (player.gotflag) or
			not P_IsObjectOnGround(player.mo))
			and (player.cmd.buttons & BT_CUSTOM3)
			and ((player.cmd.buttons & BT_JUMP) and not (player.pvars.prevkeys & BT_JUMP)) then
				if (P_IsObjectOnGround(player.mo)
				or player.ntoppv2_midairsj) then
					fsm.ChangeState(player, ntopp_v2.enums.SUPERJUMPSTART)
					return
				elseif player.pvars.cancrusher then
					fsm.ChangeState(player, ntopp_v2.enums.BODYSLAM)
					L_ZLaunch(player.mo, 40*FU)
					player.pvars.savedmomz = player.mo.momz
					player.pvars.forcedstate = S_NOISE_CRUSHER
					return
				end
			end
		end
		
		if (player.cmd.buttons & BT_SPIN and P_IsObjectOnGround(player.mo)) then
			fsm.ChangeState(player, ntopp_v2.enums.MACH1)
			return
		end
		
		if (player.cmd.buttons & BT_CUSTOM2) and P_IsObjectOnGround(player.mo) then
			fsm.ChangeState(player, ntopp_v2.enums.CROUCH)
			return
		end
		
		if not (player.gotflag) and ((player.cmd.buttons & BT_CUSTOM2) and not (player.pvars.prevkeys and player.pvars.prevkeys & BT_CUSTOM2)) and not P_IsObjectOnGround(player.mo)
			fsm.ChangeState(player, ntopp_v2.enums.BODYSLAM)
			return
		end
		
		if NerfAbility() then return end
		
		if player.pvars.supertauntready and player.cmd.buttons & BT_CUSTOM3 and (player.cmd.buttons & BT_TOSSFLAG) and not (player.pvars.prevkeys and player.pvars.prevkeys & BT_TOSSFLAG) then
			fsm.ChangeState(player, ntopp_v2.enums.SUPERTAUNT)
			return
		end
		
		--[[if not (NerfAbility()) and (player.cmd.buttons & BT_FIRENORMAL) and not (player.pvars.prevkeys and player.pvars.prevkeys & BT_FIRENORMAL) then
			if player.ntoppv2_asslauncher then
				fsm.ChangeState(player, ntopp_v2.enums.BREAKDANCESTART)
			else
				fsm.ChangeState(player, ntopp_v2.enums.BREAKDANCE)
			end
			return
		end]]--
	end,
	exit = function(self,player)
		player.ntoppv2_gravitydisabled = false
		local wasboogie = player.ntoppv2_boogie
		player.ntoppv2_boogie = false
		if wasboogie then
			S_ChangeMusic(mapmusname, true, player)
		end
	end
}

addHook('MobjMoveBlocked', function(mo, mobj, line)
	local player = mo.player
	if not NTOPP_Check(player) then return end
	if not line and line.valid then return end
	
	if line.flags & ML_NOCLIMB then return end
	
	if player.fsm.state ~= ntopp_v2.enums.MACH1 
	and player.fsm.state ~= ntopp_v2.enums.MACH2 
	and player.fsm.state ~= ntopp_v2.enums.MACH3
	and (player.fsm.state ~= ntopp_v2.enums.GRAB or player.mo.skin == "ngustavo")
	and player.fsm.state ~= ntopp_v2.enums.LONGJUMP
	and player.fsm.state ~= ntopp_v2.enums.BREAKDANCELAUNCH
	then return end
	
	if P_IsObjectOnGround(mo) and not player.mo.standingslope then return end
	if P_PlayerInPain(player) or player.playerstate == PST_DEAD then return end
	
	local wallfound = WallCheckHelper(player, line)
	
	if not wallfound then return end
	
	local angle = 0
	if line and line.valid then
		local linex,liney = P_ClosestPointOnLine(player.mo.x,player.mo.y,line)
		angle = R_PointToAngle2(player.mo.x,player.mo.y,linex,liney)
	end
	local diff = player.mo.angle - angle
	if diff <= ANG1*35 and diff >= -ANG1*35 then
		fsm.ChangeState(player, ntopp_v2.enums.WALLCLIMB)
		player.pvars.drawangle = angle
	end
end, MT_PLAYER)

addHook('JumpSpecial', function(player)
	if not NTOPP_Check(player) then return end
	if not P_IsObjectOnGround(player.mo) then return end
	if player.pflags & PF_JUMPDOWN then return end

	local p = player
	local me = p.mo //luigi budd is lazy
	
	if player.fsm.state == ntopp_v2.enums.MACH1 
	or player.fsm.state == ntopp_v2.enums.MACH2
	or player.fsm.state == ntopp_v2.enums.MACH3
	or player.fsm.state == ntopp_v2.enums.GRAB then
		local dist = -40
		local d1 = P_SpawnMobjFromMobj(me, dist*cos(p.drawangle + ANGLE_45), dist*sin(p.drawangle + ANGLE_45), 0, MT_LINEPARTICLE)
		local d2 = P_SpawnMobjFromMobj(me, dist*cos(p.drawangle - ANGLE_45), dist*sin(p.drawangle - ANGLE_45), 0, MT_LINEPARTICLE)
		d1.angle = R_PointToAngle2(d1.x, d1.y, me.x+me.momx, me.y+me.momy) --- ANG5
		d2.angle = R_PointToAngle2(d2.x, d2.y, me.x+me.momx, me.y+me.momy) --- ANG5
		d1.state = S_PJUMPDUST
		d2.state = S_PJUMPDUST
	else
		local dust = P_SpawnMobjFromMobj(me, 0,0,0, MT_LINEPARTICLE)
		dust.state = S_PSTNDJUMPDUST
	end
end)