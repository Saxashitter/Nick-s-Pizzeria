
local function NerfAbility()
	return (ntopp_v2.NERFED_PEPPINO_IN_OTHER.value 
	and (gametyperules & GTR_RACE or G_RingSlingerGametype()))
	or (ntopp_v2.NERFED_PEPPINO_IN_COOP.value
	and G_CoopGametype())
end

fsmstates[ntopp_v2.enums.WALLCLIMB]['nthe_noise'] = {
	enter = function(self, player, state)
		player.pflags = $|PF_JUMPED
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
		else
			--if player.pvars.jumpheight > 0 then
				L_ZLaunch(player.mo, player.pvars.jumpheight)
			--end
		end
		
		player.pvars.forcedstate = S_PEPPINO_WALLCLIMB
		//from effects but idfk -rbf
	local fxfive = P_SpawnMobjFromMobj(player.mo, 0, 0, 0, MT_THOK)
	fxfive.tics = 35
    fxfive.state = S_NBONKEFFECT
	fxfive.color = player.skincolor
	//
		S_StartSound(player.mo, sfx_nmccnc)
	end,
	playerthink = function(self, player)
		if PT_FindPressed(player, "down", player.cmd.buttons) then
			fsm.ChangeState(player, ntopp_v2.enums.DIVE)
			return
		end
		if (PT_FindPressed(player, "up", player.cmd.buttons))
		and (PT_FindPressed(player, "atk", player.cmd.buttons) and not (PT_FindPressed(player, "atk", player.prevkeys))) then
			fsm.ChangeState(player, ntopp_v2.enums.UPPERCUT)
			return
		end
		if PT_FindPressed(player, "atk", player.cmd.buttons)
		and not (PT_FindPressed(player, "atk", player.prevkeys)) then
			player.pvars.movespeed = ntopp_v2.machs[3]
			fsm.ChangeState(player, ntopp_v2.enums.MACH2)
			player.pvars.forcedstate = S_NOISE_SPIN
			L_ZLaunch(player.mo, 4*FU)
			return
		end
		if (PT_FindPressed(player, "up", player.cmd.buttons))
		and ((player.cmd.buttons & BT_JUMP) and not (player.prevkeys & BT_JUMP)) 
		and player.pvars.cancrusher then
			fsm.ChangeState(player, ntopp_v2.enums.BODYSLAM)
			L_ZLaunch(player.mo, 40*FU)
			player.pvars.savedmomz = player.mo.momz
			player.pvars.forcedstate = S_NOISE_CRUSHER
		end
		
		if not (leveltime % 4)
			NTOPP_NoiseAI(player.mo, 1)
		end
	end,
	think = function(self, player)
		if P_IsObjectOnGround(player.mo) then
			if (PT_FindPressed(player, "run", player.cmd.buttons)) then
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
		
		if not player.pvars.groundthing
			player.pvars.forcedstate = S_NOISE_DRILLAIR
		elseif player.pvars.forcedstate == S_NOISE_DRILLAIR
		    player.pvars.forcedstate = S_NOISE_DRILLLAND
		else
			player.pvars.forcedstate = S_PEPPINO_DIVEBOMB
		end
		
		player.pflags = $|PF_JUMPSTASIS
		player.powers[pw_strong] = $1|STR_ATTACK|STR_SPIKE|STR_ANIM
		if (PT_FindPressed(player, "atk", player.cmd.buttons))
		and not (PT_FindPressed(player, "atk", player.prevkeys)) then -- look nick you can do it in this state dummy.............
			player.pvars.movespeed = ntopp_v2.machs[3]
			fsm.ChangeState(player, ntopp_v2.enums.MACH2)
			player.pvars.forcedstate = S_NOISE_SPIN
			if not P_IsObjectOnGround(player.mo)
				L_ZLaunch(player.mo, 4*FU)
			end
			return
		end
	end,
	think = function(self, player)
		if not PT_FindPressed(player, "down", player.cmd.buttons) and P_IsObjectOnGround(player.mo) then
			fsm.ChangeState(player, ntopp_v2.enums.WALLCLIMB)
			L_ZLaunch(player.mo, 6*FU)
			return
		end
		if not P_IsObjectOnGround(player.mo) and player.pvars.groundthing then
			L_ZLaunch(player.mo, -23*FU)
		end
		if not P_IsObjectOnGround(player.mo)
		and (PT_FindPressed(player, "up", player.cmd.buttons))
		and (PT_FindPressed(player, "atk", player.cmd.buttons) and not (PT_FindPressed(player, "atk", player.prevkeys))) then
			fsm.ChangeState(player, ntopp_v2.enums.UPPERCUT)
			return
		end
		
		/*if not (leveltime % 4)
			NTOPP_NoiseAI(player.mo, 2)
		end*/
	end,
	exit = function(self, player, state)
		player.normalspeed = skins[player.mo.skin].normalspeed
	
		if state == ntopp_v2.enums.ROLL then
			player.pvars.movespeed = player.speed
		end
	end
}