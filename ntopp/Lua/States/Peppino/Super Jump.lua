local function NerfAbility()
	return (ntopp_v2.NERFED_PEPPINO_IN_OTHER.value 
	and (gametyperules & GTR_RACE or G_RingSlingerGametype()))
	or (ntopp_v2.NERFED_PEPPINO_IN_COOP.value
	and G_CoopGametype())
end

fsmstates[ntopp_v2.enums.SUPERJUMPSTART]['npeppino'] = {
	name = "Super Jump Start",
	enter = function(self, player)
		if (player.pvars) then
			player.pvars.forcedstate = S_PEPPINO_SUPERJUMPSTART
			if not player.ntoppv2_instasj then
				player.pvars.superjumpstarttime = 16
			else
				player.pvars.superjumpstarttime = 0
			end
			player.pvars.landanim = false
			if player.mo.skin ~= "nthe_noise"
				S_StartSound(player.mo, sfx_sjpre)
			else
				S_StartSound(player.mo, sfx_nsjstr)
			end
			if (player.mo) then
				player.mo.state = S_PLAY_STND // will default to what state it should be
			end
		end
	end,
	think = function(self, player)
		if player.mo.skin ~= "nthe_noise" and not S_SoundPlaying(player.mo, sfx_sjpre) then
			if not S_SoundPlaying(player.mo, sfx_sjhol) then
				S_StartSound(player.mo, sfx_sjhol)
			end
		elseif player.mo.skin == "nthe_noise" and not S_SoundPlaying(player.mo, sfx_nsjstr)
			if not S_SoundPlaying(player.mo, sfx_nsjlop) then
				S_StartSound(player.mo, sfx_nsjlop)
			end
		end
		
		if (player.pvars.superjumpstarttime) then 
			player.pvars.superjumpstarttime = $-1
			if (player.mo.state ~= S_PEPPINO_SUPERJUMPSTARTTRNS)
			and (player.pvars.superjumpstarttime > 14 or player.mo.skin ~= "nthe_noise") then
				player.mo.state = S_PEPPINO_SUPERJUMPSTARTTRNS
			end
			player.pflags = $|PF_FULLSTASIS
			return
		else
			player.pflags = $|PF_JUMPSTASIS
			player.normalspeed = 4*FU
		end

		if not (player.cmd.buttons & BT_CUSTOM3) and (P_IsObjectOnGround(player.mo) or player.ntoppv2_midairsj) then
			fsm.ChangeState(player, ntopp_v2.enums.SUPERJUMP)
		end
	end,
	exit = function(self, player, state)
		if player.mo then
			player.normalspeed = skins[player.mo.skin].normalspeed
			if player.mo.skin ~= "nthe_noise"
				S_StopSoundByID(player.mo, sfx_sjpre)
				S_StopSoundByID(player.mo, sfx_sjhol)
			else
				S_StopSoundByID(player.mo, sfx_nsjstr)
				S_StopSoundByID(player.mo, sfx_nsjlop)
			end
		end
	end
}

addHook("PlayerHeight", function(p)
	if not (p.mo and p.mo.valid)
	or not isPTSkin(p.mo.skin)
	or not p.fsm 
	or p.fsm.state ~= ntopp_v2.enums.SUPERJUMPSTART return end
	
	return P_GetPlayerSpinHeight(p)
end)

fsmstates[ntopp_v2.enums.SUPERJUMP]['npeppino'] = {
	name = "Super Jump",
	enter = function(self, player)
		player.pflags = $ & ~(PF_STARTJUMP|PF_JUMPED)
		player.mo.momx = 0
		player.mo.momy = 0
		player.normalspeed = 16*FU
		if (player.pvars) then
			player.pvars.forcedstate = S_PEPPINO_SUPERJUMP
			player.pvars.landanim = false
			player.pvars.superjumpery = not NerfAbility() and 38*FU or 22*FU
			if (NerfAbility()) then
				L_ZLaunch(player.mo, player.pvars.superjumpery)
			end
			if player.mo.skin ~= "nthe_noise"
				S_StopSoundByID(player.mo, sfx_sjpre)
				S_StopSoundByID(player.mo, sfx_sjhol)
				S_StartSound(player.mo, sfx_sjrel)
			else
				S_StopSoundByID(player.mo, sfx_nsjstr)
				S_StopSoundByID(player.mo, sfx_nsjlop)
				S_StartSound(player.mo, sfx_nsjend)
			end
			if (player.mo) then
				player.mo.state = S_PLAY_STND // will default to what state it should be
			end
			
			player.pvars.drawangle = player.drawangle
		end
		local explosion = P_SpawnMobj(player.mo.x,player.mo.y,player.mo.z,MT_THOK)
		explosion.state = S_EXPLOSIONEFFECT
	end,
	playerthink = function(self, player)
		if not (player.mo) then return end
		if not (player.pvars or player.playerstate == PST_DEAD) then
			player.pvars = Init()
			if (player.playerstate == PST_DEAD) then
				return
			end
		end
		
		if player.mo.skin ~= "nthe_noise" then
			player.pflags = $|PF_FULLSTASIS
			player.mo.momx = 0
			player.mo.momy = 0
		end
		
		if not (leveltime % 4) then
			TGTLSAfterImage(player)
		end
		if not (NerfAbility()) then
			L_ZLaunch(player.mo, player.pvars.superjumpery)
			player.pvars.superjumpery = $+(FU/6)
		end
		player.pvars.drawangle = $ - ANG15*2
		player.drawangle = player.pvars.drawangle
		
		local spinpressed = (player.cmd.buttons & BT_SPIN) and not (player.pvars.prevkeys and player.pvars.prevkeys & BT_SPIN)
		local grabpressed = (player.cmd.buttons & BT_CUSTOM1) and not (player.pvars.prevkeys and player.pvars.prevkeys & BT_CUSTOM1)
		
		if (spinpressed or grabpressed) then
			local state = player.mo.skin == "nthe_noise" and ntopp_v2.enums.MACH2 or ntopp_v2.enums.SUPERJUMPCANCEL
			if state == ntopp_v2.enums.MACH2 then
				player.pvars.movespeed = ntopp_v2.machs[3]
				player.mo.momz = 0
				player.drawangle = NTOPP_ReturnControlsAngle(player)
			end
			fsm.ChangeState(player, state)
			if state == ntopp_v2.enums.MACH2 then
				player.pvars.forcedstate = S_NOISE_SPIN
			end
		end
	end,
	think = function(self, player)
		local height = player.mo.eflags & MFE_VERTICALFLIP and player.mo.floorz or player.mo.ceilingz
		local hit = player.mo.eflags & MFE_VERTICALFLIP and (player.mo.z == height) or (player.mo.z+player.mo.height == height)
		
		if hit then fsm.ChangeState(player, ntopp_v2.enums.STUN) return end
		
		if (NerfAbility()) and P_IsObjectOnGround(player.mo) then
			fsm.ChangeState(player, ntopp_v2.enums.BASE)
		end
	end,
	exit = function(self, player, state)
		player.normalspeed = skins[player.mo.skin].normalspeed
	end
}

fsmstates[ntopp_v2.enums.SUPERJUMPCANCEL]['npeppino'] = {
	name = "Super Jump Cancel",
	enter = function(self, player)
		player.pvars.forcedstate = nil
		player.mo.state = S_PEPPINO_SUPERJUMPCANCELTRNS
		player.mo.momz = 0
		S_StopSound(player.mo, sfx_sjrel)
		S_StartSound(player.mo, sfx_sjcan)
	end,
	playerthink = function(self, player)
		if not (player.mo) then return end
		if not (player.pvars or player.playerstate == PST_DEAD) then
			player.pvars = Init()
			if (player.playerstate == PST_DEAD) then
				return
			end
		end
		
		player.mo.momx = 0
		player.mo.momy = 0
		player.mo.momz = 0
		if player.mo.state ~= S_PEPPINO_SUPERJUMPCANCELTRNS then
			player.pvars.movespeed = ntopp_v2.machs[3]
			fsm.ChangeState(player, ntopp_v2.enums.MACH3)
			player.pvars.forcedstate = S_PEPPINO_SUPERJUMPCANCEL

			L_ZLaunch(player.mo, 4*skins[player.mo.skin].jumpfactor)
			--S_StartSound(player.mo, sfx_phalo)

			local ring = P_SpawnMobj(player.mo.x,player.mo.y,player.mo.z,MT_THOK)
			ring.state = S_MACH4RING
			ring.fuse = 999
			ring.tics = 20
			ring.angle = player.drawangle+ANGLE_90
			ring.scale = player.mo.scale-FRACUNIT/2
			ring.destscale = player.mo.scale*2
			ring.colorized = true
			ring.color = SKINCOLOR_WHITE
			if (player.mo.eflags & MFE_VERTICALFLIP) then
				ring.flags2 = $|MF2_OBJECTFLIP
				ring.eflags = $|MFE_VERTICALFLIP
			end
		end
	end,
	exit = function(self, player)
	
	end
}