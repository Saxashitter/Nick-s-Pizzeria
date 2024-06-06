//reskinned the grab state cause is easier
//TO DO FOR CODERS: make peppino fit through small gaps (done)

fsmstates[ntopp_v2.enums.CROUCH]['ngustavo'] = {
	name = "Crouch",
	enter = function(self, player)
		if (player.pvars) then
			player.pvars.forcedstate = S_PEPPINO_CROUCH
		end
		player.normalspeed = 8*FU
		player.jumpfactor = $-($/3)
		player.ntoppv2_hasbrick = false
	end,
	playerthink = function(self, player)
		if not (player.mo) then return end
		if not (player.pvars) or player.playerstate == PST_DEAD then
			player.pvars = NTOPP_Init()
			if (player.playerstate == PST_DEAD) then
				return
			end
		end
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
		
		
		local p = player
		local ch = (p.mo.eflags & MFE_VERTICALFLIP) and p.mo.floorz or p.mo.ceilingz
		local spingap = false
		if p.mo.z+skins[p.mo.skin].height > ch
			spingap = true
		end
		
		if not (player.cmd.buttons & BT_CUSTOM2) and P_IsObjectOnGround(player.mo) and not spingap then
			fsm.ChangeState(player, ntopp_v2.enums.BASE)
		end
		
		p.pflags = $|PF_JUMPSTASIS
	end,
	exit = function(self, player)
		if player.mo then
			player.normalspeed = skins[player.mo.skin].normalspeed
			player.jumpfactor = skins[player.mo.skin].jumpfactor
			player.pflags = $ & ~PF_JUMPSTASIS
			player.ntoppv2_hasbrick = true
			player.pvars.forcedstate = S_PLAY_STND
			player.mo.state = S_PLAY_STND
		end
	end
}