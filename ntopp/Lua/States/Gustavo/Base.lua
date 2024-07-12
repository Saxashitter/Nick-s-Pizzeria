
-- i just copied peppino's standard
-- and changed it minimally

-- hi guys, pacola in the second day working in gustavo
-- it no longer is minimally changed
-- yay

local function NerfAbility()
	return (ntopp_v2.NERFED_PEPPINO_IN_OTHER.value 
	and (gametyperules & GTR_RACE or G_RingSlingerGametype()))
	or (ntopp_v2.NERFED_PEPPINO_IN_COOP.value
	and G_CoopGametype())
end

local function convertMach(num)
	return FixedMul(num, ntopp_v2.machs[3]/12)
end

fsmstates[ntopp_v2.enums.BASE]["ngustavo"] = {
	name = "Standard",
	enter = function(self, player, state)
		if (player.pvars) then
			player.pvars.forcedstate = nil
			player.pvars.landanim = P_IsObjectOnGround(player.mo)
			player.pvars.taunthold = 0
			if (player.mo) then
				player.mo.state = S_PLAY_STND // will default to what state it should be
			end
		end
		if player.ntoppv2_hasbrick == nil
			player.ntoppv2_hasbrick = true
		end
		player.ntoppv2_boogie = false
	end,
	playerthink = function(self, player)
		if not (player.mo) then return end
		if not (player.pvars) or player.playerstate == PST_DEAD then
			player.pvars = NTOPP_Init()
			--print(player.pvars)
			if (player.playerstate == PST_DEAD) then
				return
			end
		end
		
		local p = player
		
		/*if p.ntoppv2_hasbrick
			print("i hav brick")
		else
			print("sorru, no bread found")
		end*/
		
		--player.pvars.movespeed = max(ntopp_v2.machs[1], $-FU)
		if (p.cmd.buttons & BT_SPIN) and P_IsObjectOnGround(p.mo) and not p.powers[pw_pushing]
		and p.pvars.movespeed < ntopp_v2.machs[3]
			p.pvars.movespeed = PT_Approach($, ntopp_v2.machs[3], convertMach(FixedDiv(15, 100)))
			--print(p.pvars.movespeed/FU)
		end
		
		if p.pvars.movespeed >= ntopp_v2.machs[3]
			p.powers[pw_strong] = $1|STR_ATTACK|STR_WALL|STR_SPIKE|STR_ANIM
			if p.powers[pw_pushing]
				fsm.ChangeState(player, ntopp_v2.enums.STUN)
			end
		end
		
		if p.powers[pw_pushing] or (abs(p.speed) < 18*FU and not (p.cmd.forwardmove or p.cmd.sidemove)) or not (p.cmd.buttons & BT_SPIN) or abs(p.pvars.movespeed) <= 6*FU
			--gustavodash = 0
			p.pvars.movespeed = 18*FU
		end
		
		if (p.panim == PA_WALK or p.pvars.forcedstate == S_PEPPINO_MACH1 or p.pvars.forcedstate == S_PEPPINO_MACH3) -- i swear this is all just spaghetti code
		and P_IsObjectOnGround(p.mo)
			if p.pvars.movespeed >= ntopp_v2.machs[3]
				p.pvars.forcedstate = S_PEPPINO_MACH3
			elseif (p.cmd.buttons & BT_SPIN)
			and p.speed > 0
				p.pvars.forcedstate = S_PEPPINO_MACH1
			elseif p.panim ~= PA_WALK
				p.mo.state = S_PLAY_WALK
				p.pvars.forcedstate = nil
			end
		elseif p.pvars.forcedstate == S_PEPPINO_MACH3
		and not P_IsObjectOnGround(p.mo)
			p.pvars.forcedstate = nil
			p.mo.state = S_PEPPINO_SECONDJUMP
		elseif p.pvars.forcedstate == S_PEPPINO_MACH1
		and not P_IsObjectOnGround(p.mo)
			p.pvars.forcedstate = nil
			p.mo.state = S_PLAY_JUMP
		elseif (p.panim == PA_WALK or p.pvars.forcedstate == S_PEPPINO_MACH1 or p.pvars.forcedstate == S_PEPPINO_MACH3) and (not P_IsObjectOnGround(p.mo) and p.speed < 18*FU)
			p.pvars.forcedstate = nil
		end
		
		if p.pvars.movespeed >= ntopp_v2.machs[3] then
			if not (leveltime % 4) then
				TGTLSAfterImage(player)
			end
		end
		
		player.normalspeed = max(player.pvars.movespeed, skins[player.mo.skin].normalspeed)
		
		if player.pvars.hassprung then
			player.powers[pw_strong] = $ & ~STR_SPRING
			player.pvars.hassprung = nil
		end
		
		if (player.powers[pw_carry]) then return end
		if (player.pflags & PF_SLIDING) then return end
		if (player.pflags & PF_SPINNING) then return end
		
		if (player.cmd.buttons & BT_TOSSFLAG) and not (player.prevkeys and player.prevkeys & BT_TOSSFLAG) and player.ntoppv2_hasbrick then
			fsm.ChangeState(player, ntopp_v2.enums.TAUNT)
			return
		end
		
		if (gametyperules & GTR_RACE and leveltime < 4*TICRATE) then return end
		if (player.pflags & PF_STASIS) then return end
		if (player.exiting) then return end
		
		if not (player.gotflag) and ((player.cmd.buttons & BT_CUSTOM1 and not (player.prevkeys and player.prevkeys & BT_CUSTOM1))) then
			fsm.ChangeState(player, ntopp_v2.enums.GRAB)
			return
		end
		
		/*if (player.cmd.buttons & BT_SPIN and P_IsObjectOnGround(player.mo)) then
			fsm.ChangeState(player, ntopp_v2.enums.MACH1)
			return
		end*/
		
		if (player.cmd.buttons & BT_CUSTOM2) and P_IsObjectOnGround(player.mo) then
			fsm.ChangeState(player, ntopp_v2.enums.CROUCH)
			return
		end
		
		if not (player.gotflag) and ((player.cmd.buttons & BT_CUSTOM2) and not (player.prevkeys and player.prevkeys & BT_CUSTOM2)) and not P_IsObjectOnGround(player.mo)
			fsm.ChangeState(player, ntopp_v2.enums.BODYSLAM)
			return
		end
		
		if NerfAbility() then return end
		
		if player.pvars.supertauntready and player.cmd.buttons & BT_CUSTOM3 and (player.cmd.buttons & BT_TOSSFLAG) and not (player.prevkeys and player.prevkeys & BT_TOSSFLAG) and player.ntoppv2_hasbrick then
			fsm.ChangeState(player, ntopp_v2.enums.SUPERTAUNT)
			return
		end
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

addHook("AbilitySpecial", function(player)
    if player.mo.skin == "ngustavo" then
        if player.cmd.buttons & BT_JUMP and player.ntoppv2_hasbrick then
			if player.pflags&PF_THOKKED
			return true
			end
            fsm.ChangeState(player, ntopp_v2.enums.DIVE)
			return
        end
    end
end)