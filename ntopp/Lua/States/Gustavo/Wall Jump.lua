local function NerfAbility(player)
	return (ntopp_v2.NERFED_PEPPINO_IN_OTHER.value 
		and (gametyperules & GTR_RACE 
		or ((G_RingSlingerGametype() 
			and gametype ~= GT_CTF) 
		or (gametype == GT_CTF 
			and player.gotflag))))
	or (ntopp_v2.NERFED_PEPPINO_IN_COOP.value
	and G_CoopGametype())
end

local function NerfAbility()
	return (ntopp_v2.NERFED_PEPPINO_IN_OTHER.value 
	and (gametyperules & GTR_RACE or G_RingSlingerGametype()))
	or (ntopp_v2.NERFED_PEPPINO_IN_COOP.value
	and G_CoopGametype())
end

fsmstates[ntopp_v2.enums.WALLCLIMB]['ngustavo'] = {
	name = "Wall Jump",
	enter = function(self, player)
		player.pvars.forcedstate = S_GUSTAVO_WALLJUMP
		player.gustavowalljumptimer = 7
		S_StartSound(player.mo, sfx_gwj1)
	end,
	playerthink = function(self, player)
		if not (player.mo) then return end
		if not (player.pvars) or player.playerstate == PST_DEAD then
			player.pvars = NTOPP_Init()
			if (player.playerstate == PST_DEAD) then
				return
			end
		end
		
		player.gustavowalljumptimer = $ - 1
		player.mo.momx = 0
		player.mo.momy = 0
		player.mo.momz = 0
		player.pflags = $|PF_FULLSTASIS
		if player.gustavowalljumptimer == 0 then
			fsm.ChangeState(player, ntopp_v2.enums.DIVE)
			player.pvars.forcedstate = S_PEPPINO_BODYSLAM
			S_StartSound(player.mo, sfx_gwj2)
		end
	end,
	exit = function(self, player)
		player.pflags = $|PF_JUMPED|PF_STARTJUMP
		player.pflags = $ & ~PF_FULLSTASIS
		
		player.drawangle = $+ANGLE_180
		player.mo.angle = player.drawangle
		
		player.pvars.savedline = nil
		player.pvars.mobjblocked = nil
		
		P_InstaThrust(player.mo, player.drawangle, FixedMul(22*FU, player.mo.scale))
	end
}