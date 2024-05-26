fsmstates[ntopp_v2.enums.UPPERCUT]['npeppino'] = {
	name = "Belly Slide",
	enter = function(self, player)
		player.ntoppjump = false
		player.pvars.movespeed = ntopp_v2.machs[1]
		
		if not P_IsObjectOnGround(player.mo) then
			if player.mo.skin ~= "nthe_noise" then
				L_ZLaunch(player.mo, 13*skins[player.mo.skin].jumpfactor)
			else
				L_ZLaunch(player.mo, 28*skins[player.mo.skin].jumpfactor)
			end
		else
			if player.mo.skin ~= "nthe_noise" then
				L_ZLaunch(player.mo, 16*skins[player.mo.skin].jumpfactor)
			else
				L_ZLaunch(player.mo, 31*skins[player.mo.skin].jumpfactor)
			end
		end
		
		if player.mo.skin == "nthe_noise"
			for i = 1, 4 do
				local p = player
				local pmo = p.mo
				local fx = P_SpawnMobjFromMobj(pmo, P_RandomRange(-40, 40)*FU, P_RandomRange(-40, 40)*FU, P_RandomRange(-40, 40)*FU, MT_THOK)
				fx.state = S_SHINEEFFECT
			end
		end
		
		player.pvars.forcedstate = S_PEPPINO_UPPERCUTEND
		player.pflags = $|PF_JUMPED & ~PF_STARTJUMP
		S_StartSound(player.mo, sfx_upcut)
		S_StartSound(player.mo, sfx_upcu2)
	end,
	playerthink = function(self, player)
		if player.ntoppv2_diagonalspring then return end
	
		local speed = ntopp_v2.machs[1]
		/*player.mo.momx = max(-speed, min($, speed))
		player.mo.momy = max(-speed, min($, speed))*/
		if player.speed > speed
			P_InstaThrust(player.mo, R_PointToAngle2(0, 0, player.mo.momx, player.mo.momy), speed)
		end
	end,
	think = function(self, player)
		if player.mo.momz*P_MobjFlip(player.mo) > 0 and not (leveltime % 4) then
			TGTLSAfterImage(player)
			
			if player.mo.skin == "nthe_noise"
				local p = player
				
				local fx = P_SpawnMobjFromMobj(p.mo, 0, 0, 0, MT_THOK)
				fx.state = S_SHINEEFFECT
			end
		end
		
		if P_IsObjectOnGround(player.mo) then
			fsm.ChangeState(player, ntopp_v2.enums.BASE)
			player.pvars.movespeed = ntopp_v2.machs[1]
		end
	end
}