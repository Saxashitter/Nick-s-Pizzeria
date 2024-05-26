local function NerfAbility()
	return (ntopp_v2.NERFED_PEPPINO_IN_OTHER.value 
	and (gametyperules & GTR_RACE or G_RingSlingerGametype()))
	or (ntopp_v2.NERFED_PEPPINO_IN_COOP.value
	and G_CoopGametype())
end

fsmstates[ntopp_v2.enums.LONGJUMP]['npeppino'] = {
	name = "Long Jump",
	enter = function(self, player)
		player.pvars.forcedstate = S_PEPPINO_LONGJUMP
	end,
	think = function(self, player)
		if not (player.mo) then return end
		if not (player.pvars) or player.playerstate == PST_DEAD then
			player.pvars = NTOPP_Init()
			if (player.playerstate == PST_DEAD) then
				return
			end
		end
		
		if (P_IsObjectOnGround(player.mo)) then
			fsm.ChangeState(player, GetMachSpeedEnum(player.pvars.movespeed))
			return
		end
		
		player.pvars.drawangle = player.drawangle
		
		if not (leveltime % 4) then
			TGTLSAfterImage(player)
		end
		P_InstaThrust(player.mo, player.drawangle, FixedMul(player.pvars.movespeed, player.mo.scale))
		P_MovePlayer(player)
		
		if (player.cmd.buttons & BT_CUSTOM2) and not P_IsObjectOnGround(player.mo) then
			fsm.ChangeState(player, ntopp_v2.enums.DIVE)
		end
		
		if not (player.gotflag) and ((player.cmd.buttons & BT_CUSTOM1 and not (player.prevkeys and player.prevkeys & BT_CUSTOM1))) then
			if (PT_FindPressed(player, "up", player.cmd.buttons)) then
				fsm.ChangeState(player, ntopp_v2.enums.UPPERCUT)
				return
			end
			fsm.ChangeState(player, ntopp_v2.enums.GRAB)
			return
		end
		
		if NerfAbility() then return end
		
		if (player.cmd.buttons & BT_ATTACK) and not (player.prevkeys and player.prevkeys & BT_ATTACK) then
			fsm.ChangeState(player, ntopp_v2.enums.TAUNT)
			return
		end
	end,
	exit = function(self, player, state)
		if (state == ntopp_v2.enums.BASE) then
			player.pvars.movespeed = 8*FU
			if (player.mo) then
				player.mo.momx = 0
				player.mo.momy = 0
			end
		end
	end
}