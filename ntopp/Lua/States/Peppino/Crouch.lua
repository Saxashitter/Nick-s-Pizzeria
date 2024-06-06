//reskinned the grab state cause is easier
//TO DO FOR CODERS: make peppino fit through small gaps (done)

fsmstates[ntopp_v2.enums.CROUCH]['npeppino'] = {
	name = "Crouch",
	enter = function(self, player)
		if (player.pvars) then
			player.pvars.forcedstate = S_PEPPINO_CROUCH
		end
		player.normalspeed = 8*FU
		player.jumpfactor = $-($/3)
	end,
	think = function(self, player)
		if (not P_IsObjectOnGround(player.mo)) then
			/*if player.mo.state == S_PLAY_JUMP
			or player.mo.state == S_PLAY_SPRING
			or (player.pflags & PF_STARTJUMP)
				local p = player -- I NEED MY P (not rank)
				p.mo.state = S_PEPPINO_JUMPTRNS
				p.mo.sprite2 = SPR2_TAL7
				local fnum = skins[p.mo.skin].sprites[p.mo.sprite2].numframes
				local v2 = states[p.mo.state].var2
				p.mo.tics = fnum*v2-v2
			elseif player.mo.state == S_PEPPINO_JUMPTRNS
				if leveltime%states[p.mo.state].var2 == 0
					p.mo.frame = ($ & FF_FRAMEMASK)+1|($ & ~FF_FRAMEMASK)
				end
			else*/if (player.pvars.forcedstate ~= S_PEPPINO_CROUCHFALL)
			and player.mo.state ~= S_PEPPINO_JUMPTRNS then
				player.pvars.forcedstate = S_PEPPINO_CROUCHFALL
				if not (player.pvars.landanim) then
					player.pvars.landanim = true
				end
			end
		else
			local supposedstate = S_PEPPINO_CROUCH
			if (player.rmomx or player.rmomy) then supposedstate = S_PEPPINO_CROUCHWALK end
			if (player.pvars.forcedstate ~= supposedstate) then
				player.pvars.forcedstate = supposedstate
				
				if (player.pvars.landanim) then
					player.pvars.landanim = false
				end
			end
		end

		if not (player.cmd.buttons & BT_CUSTOM2) and P_IsObjectOnGround(player.mo) then
			fsm.ChangeState(player, ntopp_v2.enums.BASE)
		end
	end,
	exit = function(self, player)
		if player.mo then
			player.normalspeed = skins[player.mo.skin].normalspeed
			player.jumpfactor = skins[player.mo.skin].jumpfactor
		end
	end
}

local function CheckHeight(player)
	if not (player.mo) then return end
	if (not isPTSkin(player.mo.skin)) then return end
	if not (player.fsm) then return end
	if not (player.pvars) then return end
	
	if player.fsm.state == ntopp_v2.enums.CROUCH then
		return P_GetPlayerSpinHeight(player)
	end
end

addHook("PlayerHeight", CheckHeight)
addHook("PlayerCanEnterSpinGaps", CheckHeight)

addHook("PlayerCanEnterSpinGaps", function(player)
	return true
end)