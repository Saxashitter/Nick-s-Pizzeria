
local function NerfAbility()
	return (ntopp_v2.NERFED_PEPPINO_IN_OTHER.value 
	and (gametyperules & GTR_RACE or G_RingSlingerGametype()))
	or (ntopp_v2.NERFED_PEPPINO_IN_COOP.value
	and G_CoopGametype())
end

fsmstates[ntopp_v2.enums.WALLCLIMB]['nthe_noise'] = {
	enter = function(self, player, state)
		player.pflags = $|PF_JUMPED & ~PF_STARTJUMP
		player.ntoppjump = false
		
		if player.pvars.cancrusher == nil then
			player.pvars.cancrusher = true
		end
		
		if player.pvars.jumpheight
			player.pvars.jumpheight = $ == nil and 20*player.jumpfactor or $-((20*player.jumpfactor)/5)
		else
			player.pvars.jumpheight = $ == nil and 20*player.jumpfactor or $-((10*player.jumpfactor)/5)
		end
		if state == ntopp_v2.enums.DIVE then
			L_ZLaunch(player.mo, 8*player.jumpfactor)
			player.mo.momx = $/2
			player.mo.momy = $/2
			S_StartSound(player.mo, sfx_nmccnc)
		elseif state ~= ntopp_v2.enums.TAUNT then
			--if player.pvars.jumpheight > 0 then
				L_ZLaunch(player.mo, player.pvars.jumpheight)
				S_StartSound(player.mo, sfx_nmccnc)
			--end
		end
		
		player.pvars.forcedstate = S_PEPPINO_WALLCLIMB
	end,
	playerthink = function(self, player)
		if player.cmd.buttons & BT_CUSTOM2 then
			fsm.ChangeState(player, ntopp_v2.enums.DIVE)
			return
		end
		if (player.cmd.buttons & BT_CUSTOM3)
		and (player.cmd.buttons & BT_CUSTOM1 and not (player.pvars.prevkeys & BT_CUSTOM1)) then
			fsm.ChangeState(player, ntopp_v2.enums.UPPERCUT)
			return
		end
		if player.cmd.buttons & BT_CUSTOM1
		and not (player.pvars.prevkeys & BT_CUSTOM1) then
			player.pvars.movespeed = ntopp_v2.machs[3]
			player.drawangle = NTOPP_ReturnControlsAngle(player)
			fsm.ChangeState(player, ntopp_v2.enums.MACH2)
			player.pvars.forcedstate = S_NOISE_SPIN
			L_ZLaunch(player.mo, max(player.mo.momz, 4*FU))
			return
		end
		if (player.cmd.buttons & BT_CUSTOM3)
		and ((player.cmd.buttons & BT_JUMP) and not (player.pvars.prevkeys & BT_JUMP)) 
		and player.pvars.cancrusher then
			fsm.ChangeState(player, ntopp_v2.enums.BODYSLAM)
			L_ZLaunch(player.mo, 40*FU)
			player.pvars.savedmomz = player.mo.momz
			player.pvars.forcedstate = S_NOISE_CRUSHER
		end
		if (player.cmd.buttons & BT_TOSSFLAG) and not (player.pvars.prevkeys and player.pvars.prevkeys & BT_TOSSFLAG) then
			fsm.ChangeState(player, ntopp_v2.enums.TAUNT)
			return
		end
		
		if not (leveltime % 4)
			NTOPP_NoiseAI(player.mo, 1)
		end
	end,
	think = function(self, player)
		if P_IsObjectOnGround(player.mo) then
			if (player.cmd.buttons & BT_SPIN) then
				player.drawangle = NTOPP_ReturnControlsAngle(player)
				player.pvars.movespeed = ntopp_v2.machs[3]
				fsm.ChangeState(player, ntopp_v2.enums.MACH3)
				S_StartSound(player.mo, sfx_nmclnd)
			else
				player.pvars.movespeed = ntopp_v2.machs[1]
				fsm.ChangeState(player, ntopp_v2.enums.BASE)
			end
		end
	end
}

fsmstates[ntopp_v2.enums.DIVE]['nthe_noise'] = {
	enter = function(self, player, state)
		fsmstates[ntopp_v2.enums.DIVE]['npeppino']:enter(player)
		L_ZLaunch(player.mo, -32*FU)

		player.pvars.forcedstate = S_PEPPINO_DIVEBOMB
		if player.pvars.movespeed >= ntopp_v2.machs[3] then
			player.normalspeed = player.pvars.movespeed
		end
		
		if player.pvars.cancrusher == nil then
			player.pvars.cancrusher = true
		end
	end,
	playerthink = function(self, player)
		player.pvars.groundthing = P_IsObjectOnGround(player.mo)
		
		if (player.cmd.buttons & BT_CUSTOM1) -- i just copied this from think, apparently it fixed it!!
		and not (player.pvars.prevkeys & BT_CUSTOM1) then -- look nick you can do it in this state dummy.............
			player.pvars.movespeed = ntopp_v2.machs[3]
			player.drawangle = NTOPP_ReturnControlsAngle(player)
			fsm.ChangeState(player, ntopp_v2.enums.MACH2)
			player.pvars.forcedstate = S_NOISE_SPIN
			if not P_IsObjectOnGround(player.mo) -- but theres a grounded check and we cant do that in playerthinknor else itll be 1 tic off
				L_ZLaunch(player.mo, 4*FU)
			end
			return
		end
		
		if not player.pvars.groundthing
			player.pvars.forcedstate = S_NOISE_DRILLAIR
		elseif player.pvars.forcedstate == S_NOISE_DRILLAIR
		    player.pvars.forcedstate = S_NOISE_DRILLLAND
		else
			player.pvars.forcedstate = S_PEPPINO_DIVEBOMB
		end
		
		player.pflags = $|PF_JUMPSTASIS
		player.powers[pw_strong] = $1|STR_ATTACK|STR_SPIKE|STR_ANIM
		if (player.cmd.buttons & BT_TOSSFLAG) and not (player.pvars.prevkeys and player.pvars.prevkeys & BT_TOSSFLAG) then
			fsm.ChangeState(player, ntopp_v2.enums.TAUNT)
			return
		end
	end,
	think = function(self, player)
		if not (player.cmd.buttons & BT_CUSTOM2) and P_IsObjectOnGround(player.mo) then
			fsm.ChangeState(player, ntopp_v2.enums.WALLCLIMB)
			L_ZLaunch(player.mo, 6*FU)
			return
		end
		if not P_IsObjectOnGround(player.mo) and player.pvars.groundthing then
			L_ZLaunch(player.mo, -32*FU)
		end
		if not P_IsObjectOnGround(player.mo)
		and (player.cmd.buttons & BT_CUSTOM3)
		and (player.cmd.buttons & BT_CUSTOM1 and not (player.pvars.prevkeys & BT_CUSTOM1)) then
			fsm.ChangeState(player, ntopp_v2.enums.UPPERCUT)
			return
		end
		if not P_IsObjectOnGround(player.mo)
		and (player.cmd.buttons & BT_TOSSFLAG) and not (player.pvars.prevkeys and player.pvars.prevkeys & BT_TOSSFLAG) then
			fsm.ChangeState(player, ntopp_v2.enums.TAUNT)
			return
		end
		
		/*if not (leveltime % 4)
			NTOPP_NoiseAI(player.mo, 2)
		end*/
		local p = player -- i need p -Pacola
		local camera_angle = (p.cmd.angleturn<<16) -- i copied these two from Functions.lua!!
		local controls_angle = R_PointToAngle2(0,0, p.cmd.forwardmove*FU, -p.cmd.sidemove*FU)
		local x = cos(camera_angle+controls_angle)
		local y = sin(camera_angle+controls_angle)
		local cz = (p.mo.eflags & MFE_VERTICALFLIP) and P_FloorzAtPos(p.mo.x+FixedMul(p.mo.radius+8*FU, x), p.mo.y+FixedMul(p.mo.radius+8*FU, y), p.mo.z+p.mo.momz, P_GetPlayerSpinHeight(p)) or P_CeilingzAtPos(p.mo.x+FixedMul(p.mo.radius+8*FU, x), p.mo.y+FixedMul(p.mo.radius+8*FU, y), p.mo.z+p.mo.momz, P_GetPlayerSpinHeight(p))
		local sh = (p.mo.eflags & MFE_VERTICALFLIP) and P_GetPlayerHeight(p)-P_GetPlayerSpinHeight(p) or P_GetPlayerSpinHeight(p)
		local h = (p.mo.eflags & MFE_VERTICALFLIP) and 1 or P_GetPlayerHeight(p)+1
		if not (p.cmd.forwardmove or p.cmd.sidemove)
			cz = (p.mo.eflags & MFE_VERTICALFLIP) and p.mo.floorz or p.mo.ceilingz
		end
		h = $-1
		if p.mo.z+h >= cz
		and p.mo.z+sh <= cz
			fsm.ChangeState(player, ntopp_v2.enums.ROLL)
			return
		end
	end,
	exit = function(self, player, state)
		player.normalspeed = skins[player.mo.skin].normalspeed
	
		if state == ntopp_v2.enums.ROLL then
			player.pvars.movespeed = max(player.speed, ntopp_v2.machs[1])
		end
	end
}