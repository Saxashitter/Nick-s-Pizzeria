
local function NerfAbility()
	return (ntopp_v2.NERFED_PEPPINO_IN_OTHER.value 
	and (gametyperules & GTR_RACE or G_RingSlingerGametype()))
	or (ntopp_v2.NERFED_PEPPINO_IN_COOP.value
	and G_CoopGametype())
end

fsmstates[ntopp_v2.enums.BODYSLAM]['ngustavo'] = {
	name = "Stomp",
	enter = function(self, player)
		player.ntoppjump = false
		player.pflags = $ & ~(PF_JUMPED|PF_STARTJUMP)
		player.pvars.forcedstate = S_PEPPINO_BODYSLAM
		player.mo.state = S_PEPPINO_BODYSLAMSTART
		player.pvars.hitfloor = false
		player.pvars.hitfloor_time = 8
		player.pvars.savedmomz = player.mo.momz
		player.pvars.soundtime = 12
		player.powers[pw_strong] = $|STR_SPRING
		S_StartSound(player.mo, sfx_gpstar)
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
	playerthink = function(self, player)
		if player.pvars.forcedstate == S_NOISE_CRUSHER then
			if PT_FindPressed(player, "atk", player.cmd.buttons)
			and not (PT_FindPressed(player, "atk", player.prevkeys)) then
				player.pvars.movespeed = ntopp_v2.machs[3]
				fsm.ChangeState(player, ntopp_v2.enums.MACH2)
				player.pvars.forcedstate = S_NOISE_SPIN
				if NerfAbility()
					player.pvars.cancrusher = false
				else
					player.pvars.cancrusher = true -- nick what were you thinking, we need to maek it acurat........
				end
				L_ZLaunch(player.mo, 4*FU)
				return
			end
		end
	end,
	think = function(self, player)
		if player.pvars.soundtime then
			player.pvars.soundtime = $-1
		elseif not (player.pvars.bodyslamthingy and player.pvars.bodyslamthingy.valid) then
			local taunt = P_SpawnMobjFromMobj(player.mo, 0,0,0, MT_NTOPP_EFFECTFOLLOWPLAYER)
			taunt.fsmstate = ntopp_v2.enums.BODYSLAM
			taunt.target = player.mo
			taunt.state = S_NTOPPEFFECTS_BODYSLAMEFFECT
			taunt.dispoffset = 1
			
			player.pvars.bodyslamthingy = taunt
		end
		
		local grounded = false
		local height = player.mo.eflags & MFE_VERTICALFLIP and player.mo.ceilingz-player.mo.height or player.mo.floorz
		local grounded = player.mo.z == height
		if not grounded then L_ZLaunch(player.mo, -FU, true) end
		if not (leveltime % 4) then
			TGTLSAfterImage(player)
		end
		
		if player.pvars.hassprung then
			fsm.ChangeState(player, ntopp_v2.enums.BASE)
		end
		
		if grounded or player.pvars.hitfloor then
			player.pflags = $|PF_FULLSTASIS

			player.mo.momx = 0
			player.mo.momy = 0
			player.mo.momz = 0
			
			if player.pvars.bodyslamthingy and player.pvars.bodyslamthingy.valid then
				P_KillMobj(player.pvars.bodyslamthingy)
				player.pvars.bodyslamthingy = nil
			end
			if not player.pvars.hitfloor then
				player.pvars.hitfloor = true
				
				if player.pvars.forcedstate == S_PEPPINO_BODYSLAM then
					player.pvars.forcedstate = S_PEPPINO_BODYSLAMLAND
				elseif player.pvars.forcedstate == S_NOISE_CRUSHER then
					player.pvars.forcedstate = S_NOISE_CRUSHEREND
				else
					player.pvars.forcedstate = S_PEPPINO_DIVEBOMBEND
				end
				if player.pvars.forcedstate ~= S_NOISE_CRUSHEREND
				and player.mo.standingslope 
				and player.mo.skin ~= "ngustavo" then
					player.pvars.movespeed = ntopp_v2.machs[1]
-- 					if player.pvars.savedmomz <= -35*FU then
-- 						player.pvars.movespeed = ntopp_v2.machs[3]
-- 					end
					
					local ang = 0
					if player.mo.standingslope.zdelta < 0 then
						ang = ANGLE_180
					end
					
					local drawangle = player.mo.standingslope.xydirection + ang
					player.drawangle = drawangle
					fsm.ChangeState(player, ntopp_v2.enums.ROLL)
				else
					player.pvars.movespeed = ntopp_v2.machs[1]
					if player.pvars.savedmomz <= -35*FU then
						P_Earthquake(player.mo, player.mo, (400*FU)+(abs(player.pvars.savedmomz)*6))
					end
					S_StartSound(player.mo, sfx_grpo)
				end
			end
			if player.pvars.hitfloor_time then
				player.pvars.hitfloor_time = $-1
			else
				fsm.ChangeState(player, ntopp_v2.enums.BASE)
			end
		else
			player.pvars.savedmomz = player.mo.momz
		end
	end,
	exit = function(self, player)
		player.powers[pw_strong] = $ & ~STR_SPRING
		player.ntoppv2_hasbrick = true
	end
}