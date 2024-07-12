
-- hi guys pacola here
-- its fireass HOORAY

local function convertMach(num)
	return FixedMul(num, 50*FU/12)
end

local function cTime(time)
	return FixedRound(time*(35*FU/60))/FU
end

fsmstates[ntopp_v2.enums.FIREASS]['npeppino'] = {
	name = "Fireass",
	enter = function(self, player, state)
		local cz = (player.mo.eflags & MFE_VERTICALFLIP) and player.mo.floorz or player.mo.ceilingz
		local height = (player.mo.eflags & MFE_VERTICALFLIP) and 1 or player.mo.height+1
		height = $-1
		if player.mo.z+height ~= cz
			L_ZLaunch(player.mo, 25*FU)
			print(player.mo.z/FU, cz/FU)
		else
			L_ZLaunch(player.mo, -25*FU)
		end
		player.pvars.forcedstate = S_PEPPINO_FIREASS
		player.pvars.fireasstime = 5
		player.pvars.hitground = false
		player.pvars.movespeed = ntopp_v2.machs[1]
		if not player.pvars.fascreamdelay
			if player.mo.skin == "nthe_noise" //added this, i forgot to add it last time lol -rbf
				S_StartSound(player.mo, sfx_dwaha)
			else
				S_StartSound(player.mo, sfx_eyaow)
			end
			player.pvars.fascreamdelay = 3*TICRATE
		end
	end,
	playerthink = function(self, p)
		p.pflags = $1|PF_JUMPSTASIS
		
		local pv = p.pvars
		
		if pv.fireasstime
			pv.fireasstime = abs($)-1
		end
		p.normalspeed = skins[p.mo.skin].normalspeed
		
		if pv.forcedstate ~= S_PEPPINO_FIREASSGRND
		and not pv.fireasstime
		and not (p.mo.eflags & MFE_TOUCHLAVA)
		and pv.hitground
			pv.forcedstate = S_PEPPINO_FIREASSGRND
		end
		
		if (p.mo.eflags & MFE_JUSTHITFLOOR)
		and not pv.fireasstime
			if (p.mo.eflags & MFE_TOUCHLAVA)
				p.powers[pw_flashing] = 0
				return
			end
		end
		
		local uframe = ((p.mo.sprite2 ~= 0) and p.mo.sprite2) or 1
		if p.pvars.hitground
			p.pflags = $1|PF_STASIS
			P_InstaThrust(p.mo, pv.thrustangle, pv.movespeed)
			p.drawangle = pv.thrustangle
			if pv.movespeed > 0
				pv.movespeed = $-convertMach(FU/4)
			end
		elseif p.mo.frame >= skins[p.mo.skin].sprites[uframe].numframes-1|FF_ANIMATE
		and p.mo.anim_duration == 2
			local step = P_SpawnMobj(p.mo.x,p.mo.y,p.mo.z,MT_THOK)
			step.state = S_CLOUDEFFECT
		end
	end,
	think = function(self, p)
		local pv = p.pvars
		local uframe = ((p.mo.sprite2 ~= 0) and p.mo.sprite2) or 1
		if P_IsObjectOnGround(p.mo)
		and not pv.fireasstime then
			if not p.pvars.hitground then
				p.pvars.thrustangle = p.drawangle
			end
			p.pvars.hitground = true
		end
		if p.mo.state == S_PEPPINO_FIREASSGRND
		and p.mo.frame >= (skins[p.mo.skin].sprites[uframe].numframes-1)|FF_ANIMATE
			fsm.ChangeState(p, ntopp_v2.enums.BASE)
		end
	end,
	exit = function(self, player, state)
		local pv = player.pvars
		pv.forcedstate = nil
		player.acceleration = pv.oldaccel
		player.powers[pw_flashing] = 0
		/*if (state == ntopp_v2.enums.BASE) then
			player.pvars.movespeed = 8*FU
			if (player.mo) then
				player.mo.momx = 0
				player.mo.momy = 0
			end
		end*/
	end
}