fsmstates[ntopp_v2.enums.PILEDRIVER]['npeppino'] = {
	name = "Piledriver",
	enter = function(self,player,state)
		player.pvars.forcedstate = S_PEPPINO_PILEDRIVER
		if state ~= ntopp_v2.enums.BASE_GRABBEDENEMY then
			L_ZLaunch(player.mo, 32*FU)
		end
		player.pvars.killed = false
		player.pvars.piledriver = true
		player.pvars.hitfloor = false
		player.pvars.deb = false
		player.pvars.soundtime = 12
		player.pvars.ntoppv2_grabbed.setz = 0
		if player.mo.skin == "nthe_noise" then
			player.pvars.ntoppv2_grabbed.setz = player.mo.height
		end
		player.powers[pw_strong] = $|STR_SPRING
		S_StartSound(player.mo, sfx_gpstar)
	end,
	playerthink = function(self,player)
		if player.pvars.soundtime then
			player.pvars.soundtime = $-1
		end
		local height = player.mo.eflags & MFE_VERTICALFLIP and player.mo.ceilingz or player.mo.floorz
		local grounded = P_IsObjectOnGround(player.mo)
		
		if not (player.pvars.ntoppv2_grabbed and player.pvars.ntoppv2_grabbed.valid) then
			player.pvars.ntoppv2_grabbed = nil
			fsm.ChangeState(player, ntopp_v2.enums.BASE)
			return
		end
		
		if not player.pvars.hitfloor then
			player.mo.momz = $-(FU*P_MobjFlip(player.mo))
			if not (leveltime % 4) then
				TGTLSGhost(player)
			end
		else
			player.pvars.forcedstate = nil
			player.pflags = $|PF_FULLSTASIS
			player.mo.momx = 0
			player.mo.momy = 0
			player.mo.momz = 0
			if not player.pvars.deb then
				S_StartSound(player.mo, sfx_grpo)
				player.mo.state = S_PEPPINO_PILEDRIVERLAND
				player.pvars.deb = true
				player.pvars.ntoppv2_grabbed.setz = FU
			end
			if player.mo.state ~= S_PEPPINO_PILEDRIVERLAND then
				fsm.ChangeState(player, ntopp_v2.enums.BASE)
			end
		end
	end,
	think = function(self, player)
		local grounded = P_IsObjectOnGround(player.mo)
		if grounded and not player.pvars.hitfloor then
			player.pvars.hitfloor = true
		end
	end,
	exit = function(self,player)
		if player.pvars and player.pvars.ntoppv2_grabbed and player.pvars.ntoppv2_grabbed.valid then
			S_StartSound(player.mo, sfx_kenem)
			player.pvars.ntoppv2_grabbed.momz = 8*(FU*P_MobjFlip(player.pvars.ntoppv2_grabbed))
			player.pvars.ntoppv2_grabbed.killed = true
			player.pvars.ntoppv2_grabbed = nil
		end
		if not player.pvars.hassprung then
			player.powers[pw_strong] = $ & ~STR_SPRING
		end
		player.pvars.piledriver = nil
	end
}