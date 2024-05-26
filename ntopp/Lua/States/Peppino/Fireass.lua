
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
		L_ZLaunch(player.mo, 25*FU)
		player.pvars.forcedstate = S_PEPPINO_FIREASS
		player.pvars.fireasstime = 5
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
		if not (p.mo) then return end
		if not (p.pvars) or p.playerstate == PST_DEAD then
			p.pvars = NTOPP_Init()
			if (p.playerstate == PST_DEAD) then
				return
			end
		end
		
		p.pflags = $1|PF_JUMPSTASIS
		
		local pv = p.pvars
		local move = P_GetPlayerControlDirection(p)
		
		if pv.fireasstime
			pv.fireasstime = abs($)-1
		end
		if p.mo.state ~= S_PEPPINO_FIREASSGRND
			/*if move ~= 0
				if move == 1
					pv.movespeed = PT_Approach($, ntopp_v2.machs[1], convertMach(FU/2))
				else
					pv.movespeed = PT_Approach($, 0, convertMach(FU/2))
				end
			else
				pv.movespeed = PT_Approach($, 0, convertMach(FU/10))
			end*/
			pv.movespeed = ntopp_v2.machs[1]
		end
		p.normalspeed = skins[p.mo.skin].normalspeed
		
		if not P_IsObjectOnGround(p.mo)
		and move == 0
			p.mo.momx = FixedMul($, p.mo.friction)
			p.mo.momy = FixedMul($, p.mo.friction)
		elseif pv.forcedstate ~= S_PEPPINO_FIREASSGRND
		and not pv.fireasstime
		and not (p.mo.eflags & MFE_TOUCHLAVA)
			pv.forcedstate = S_PEPPINO_FIREASSGRND
			pv.movespeed = convertMach(6*FU)
		end
		
		if (p.mo.eflags & MFE_JUSTHITFLOOR)
		and not pv.fireasstime
			if (p.mo.eflags & MFE_TOUCHLAVA)
				p.powers[pw_flashing] = 0
				return
			end
			pv.thrustangle = p.drawangle
		end
		
		if P_GetPlayerControlDirection(p) ~= 2
			p.acceleration = 200
		else
			p.acceleration = skins[p.mo.skin].acceleration
		end
		
		local uframe = ((p.mo.sprite2 ~= 0) and p.mo.sprite2) or 1
		if p.mo.state == S_PEPPINO_FIREASSGRND
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