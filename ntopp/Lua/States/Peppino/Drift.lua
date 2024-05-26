fsmstates[ntopp_v2.enums.DRIFT]['npeppino'] = {
	name = "Drift",
	// this code is half copied from skidding lmfao
	enter = function(self, player, last_state)
		player.pvars.driftspeed = FU*2
		if (last_state == ntopp_v2.enums.MACH2)
			player.pvars.forcedstate = S_PEPPINO_MACHDRIFT2
			player.mo.state = S_PEPPINO_MACHDRIFTTRNS2
			player.pvars.drifttime = 11*2
			S_StartSound(player.mo, sfx_drift)
		else
			player.pvars.driftspeed = $+(FU/3)
			player.pvars.forcedstate = S_PEPPINO_MACHDRIFT3
			player.mo.state = S_PEPPINO_MACHDRIFTTRNS3
			player.pvars.drifttime = 13*2
			S_StartSound(player.mo, sfx_drift)
		end
		player.runspeed = 50*FU
		player.charflags = $|SF_RUNONWATER
		player.pvars.laststate = last_state // gotta use it to continue the speed where it was left off of
		// if (last_state == ntopp_v2.enums.MACH4) then player.pvars.laststate = ntopp_v2.enums.MACH3 end
		
		player.pvars.drawangle = player.drawangle // used so we can force a angle during skidding :DD
	end,
	playerthink = function(self, player)
		if not (player.mo) then return end
		if not (player.pvars) or player.playerstate == PST_DEAD then
			player.pvars = NTOPP_Init()
			if (player.playerstate == PST_DEAD) then
				return
			end
		end
		
		player.pflags = $|PF_JUMPSTASIS
		
		player.pvars.movespeed = max(2*FU, $-player.pvars.driftspeed)
		P_InstaThrust(player.mo, player.pvars.drawangle, FixedMul(player.pvars.movespeed, player.mo.scale))
		if (player.pvars.drifttime) then
			player.pvars.drifttime = $-1
		end
	end,
	think = function(self, player)
		local shouldmach = P_IsObjectOnGround(player.mo)
		if player.ntoppv2_sagedrift
		or player.ntoppv2_waterdrifting then
			shouldmach = true
		end

		if (not player.pvars.drifttime and shouldmach) then
			player.mo.momx = 0
			player.mo.momy = 0
			// i messed it up but i can care less i am not waiting that long like that time
			fsm.ChangeState(player, player.pvars.laststate)
		end
		
		-- pacola stuff to drift on water here now again (i am writing this after the one below it)
		-- this is really scuffed
		local p = player
		local pmo = p.mo
		
		if not (p.ntoppv2_driftmo and p.ntoppv2_driftmo.valid)
		and not p.ntoppv2_waterdrifting
			p.ntoppv2_driftmo = P_SpawnMobj(pmo.x, pmo.y, pmo.z-1000*FU, MT_THOK)
			
			local d = p.ntoppv2_driftmo
			d.ntoppv2_driftmo = pmo
			d.flags = MF_SOLID|MF_NOGRAVITY
			d.flags2 = $1|MF2_DONTDRAW
			d.radius = pmo.radius
			d.height = 8*FU
		elseif (p.ntoppv2_driftmo and p.ntoppv2_driftmo.valid)
			local d = p.ntoppv2_driftmo
			
			if pmo.z < pmo.watertop
				P_SetOrigin(d, pmo.x, pmo.y, pmo.z-1000*FU)
			else
				P_SetOrigin(d, pmo.x, pmo.y, pmo.watertop)
			end
		end
		
		if p.ntoppv2_waterdrifting
		and pmo.z <= pmo.watertop+FU+FU/5
			pmo.z = pmo.watertop+FU
			pmo.momz = 0
			if not P_IsObjectOnGround(pmo)
				pmo.momx = $*pmo.friction
				pmo.momy = $*pmo.friction
			end
			p.charflags = $ & ~SF_RUNONWATER
		end
	end,
	exit = function(self, player, state)
		local tableofspeeds = {}
		
		tableofspeeds[ntopp_v2.enums.MACH2] = ntopp_v2.machs[2]
		tableofspeeds[ntopp_v2.enums.MACH3] = ntopp_v2.machs[3]
		
		player.pvars.movespeed = tableofspeeds[state]
		player.pvars.drawangle = nil
		player.pvars.laststate = nil
		
		player.runspeed = skins[player.mo.skin].runspeed
		player.charflags = $ & ~SF_RUNONWATER
		
		-- pacola stuff to drift on water here
		local p = player
		if (p.ntoppv2_driftmo and p.ntoppv2_driftmo.valid)
			P_RemoveMobj(p.ntoppv2_driftmo)
		end
		p.ntoppv2_driftmo = nil
		if p.ntoppv2_waterdrifting
			p.mo.momz = 2*FU
		end
		p.ntoppv2_waterdrifting = false
	end
}

local function collide(pmo, d)
	if d.type ~= MT_THOK
	or not d.ntoppv2_driftmo
	or pmo.player.ntoppv2_waterdrifting return end
	
	local wdist = R_PointToDist2(pmo.z, pmo.z, pmo.watertop, pmo.watertop)
	
	if pmo.z > d.z+d.height
	or d.z > pmo.z+pmo.height
	or pmo ~= d.ntoppv2_driftmo
	or wdist > 10*FU return false end
	
	pmo.player.charflags = $ & ~SF_RUNONWATER
	pmo.momz = 0
	pmo.player.ntoppv2_waterdrifting = true
	P_RemoveMobj(d)
	--return false
end

addHook("MobjCollide", collide, MT_PLAYER)
addHook("MobjMoveCollide", collide, MT_PLAYER)