
-- look its a boss..
-- we should kung fu it to death!!!

freeslot("SPR_PTHP")

ntopp_v2.charhp = {
	["npeppino"] = {
		spr = SPR_PTHP,
		sframe = A,
		mframe = 19
	},
	["nthe_noise"] = {
		spr = SPR_PTHP,
		sframe = T,
		mframe = 18,
		sclr = {
			sframe = 37
		}
	}
}

addHook("MobjDamage", function(pmo, inf, src, _, dmg)
	local p = pmo.player
	if not isIM(pmo.skin)
	or mapheaderinfo[gamemap].bonustype ~= 1 return end
	
	local b = p.ntoppboss
	
	b.hp = $-1
	if p.rings == 0 and not p.powers[pw_shield]
	and b.hp > 0
		P_DoPlayerPain(p, src, inf)
		return true
	elseif b.hp <= 0
		P_KillMobj(pmo, inf, src, dmg)
		return true
	end
	fsm.ChangeState(p, ntopp_v2.enums.PAIN)
	S_StartSound(pmo, L_Choose(sfx_pain1, sfx_pain2))
end, MT_PLAYER)

addHook("MobjDamage", function(mo, inf, src)
	local pmo = (src and src.valid) and src or inf
	if mapheaderinfo[gamemap].bonustype ~= 1
	or not (pmo and pmo.valid)
	or not (pmo.player and pmo.player.valid)
	or not (mo.flags & MF_BOSS)
	or not isIM(pmo.skin) return end
	
	
	local p = pmo.player
	p.ntoppboss.hits = $+1
end)

-- player think that does a bunch of stuff

local function initializeVars(p)
	local pmo = p.mo
	p.ntoppboss = {
		hp = 6,
		hits = 0,
		mustime = 0,
		hud = {
			frame = 1,
			hpv = 6,
			hp = {}
		}
	}
end

addHook("PlayerSpawn", function(p)
	--if p.ntoppboss == nil
		initializeVars(p)
	--else
	--	local b = p.ntoppboss
	--end
end)

/*sfxinfo[freeslot("sfx_pbsbea")].caption = "Boss Beaten"
sfxinfo[freeslot("sfx_nbsbea")].caption = "Boss Beaten"*/

addHook("PlayerThink", function(p)
	if not (p.mo and p.mo.valid)
	or not isIM(p.mo.skin)
	or mapheaderinfo[gamemap].bonustype ~= 1
		return
	end
	
	local pmo = p.mo
	if p.ntoppboss == nil
		initializeVars(p)
	end
	local b = p.ntoppboss
	
	--print(b.hits)
	if b.hits >= 3
		b.hits = 0
		local z = (pmo.eflags & MFE_VERTICALFLIP) and pmo.floorz or pmo.ceilingz
		local height = p.mo.z+64*FU*P_MobjFlip(p.mo)
		z = height > $ and height or $
		local hp = P_SpawnMobj(pmo.x, pmo.y, z, MT_NTOPP_BOSSHP)
		hp.target = p.mo
		hp.sprite = SPR_PTHP
		hp.frame = A
		hp.color = p.skincolor
		--print("hp spawned yay!!!!")
	elseif b.hits < 0
	or b.hits == nil
		b.hits = 0
	end
	
	if p.exiting
		local frame = p.mo.sprite2 ~= SPR2_STND and skins[p.mo.skin].sprites[p.mo.sprite2].numframes-1 or A
		if p.pvars.forcedstate ~= S_PEPPINO_LEVELCOMPLETE
			fsm.ChangeState(p, ntopp_v2.enums.BASE)
			p.pvars.forcedstate = S_PEPPINO_LEVELCOMPLETE
			--S_StopMusic(p)
			local mus = p.mo.skin == "nthe_noise" and "NBSBEA" or "PBSBEA"
			if p.mo.skin == "nthe_noise"
				b.noiseframe = 0
			end
			S_ChangeMusic(mus, false, p)
			b.mustime = FixedDiv(875, 100)*TICRATE
		elseif p.mo.state == S_PEPPINO_LEVELCOMPLETE
		and (p.mo.frame & FF_FRAMEMASK) >= frame
			p.mo.tics = -1
		end
	end
	
	if b.mustime > 0
		b.mustime = $-FU
		--print(FixedInt(b.mustime))
		p.exiting = 5
	else
		b.mustime = 0
	end
	
	if p.mo.skin == "nthe_noise"
	and p.mo.sprite2 == SPR2_TAL7
		b.noiseframe = $+1
		local nf = b.noiseframe/2-1
		local speed = -5*FU
		if nf <= Z+1
		and nf >= P
			speed = 5*FU
		elseif nf >= M
			speed = 0
		end
		p.mo.frame = max(min(nf, skins[p.mo.skin].sprites[p.mo.sprite2].numframes-1), A)|($ & ~FF_FRAMEMASK)
		p.mo.tics = -1
		p.mo.anim_duration = -1
		P_InstaThrust(p.mo, p.mo.angle+ANGLE_90, speed)
		p.mo.momz = 0
	else
		b.noiseframe = 0
	end
end)

addHook("TouchSpecial", function(hp, pmo)
	local p = pmo.player
	if not isIM(pmo.skin) return end
	
	local b = p.ntoppboss
	local h = b.hud
	
	table.insert(h.hp, 1, NTOPP_WorldToScreen2(p, camera, hp))
	h.hp[1].time = 0
	h.hp[1].hpv = b.hp
end, MT_NTOPP_BOSSHP)

addHook("MobjThinker", function(mo)
	if not (mo.target and mo.target.valid) return end
	
	local pmo = mo.target
	local p = pmo.player
	local b = p.ntoppboss
	local h = b.hud
	
	local chp = ntopp_v2.charhp[pmo.skin] or ntopp_v2.charhp["npeppino"]
	local uf = min(h.frame-1+chp.sframe, chp.mframe-1+chp.sframe)
	mo.frame = uf
	mo.spriteyoffset = 28*FU
	
	if pmo.skin == "nthe_noise"
	and not mo.bosshpoverlay
		mo.bosshpoverlay = P_SpawnMobj(mo.x, mo.y, mo.z, MT_NOISE_OVERLAY)
		local o = mo.bosshpoverlay
		o.target = mo
	elseif mo.bosshpoverlay and mo.bosshpoverlay.valid
		if pmo.skin ~= "nthe_noise" P_RemoveMobj(mo.bosshpoverlay) end
		local o = mo.bosshpoverlay
		local scframe = uf+abs(chp.sframe-chp.sclr.sframe)
		
		o.flags2 = mo.flags2
		o.eflags = (mo.eflags & ~MFE_FORCENOSUPER)|MFE_FORCESUPER
		o.state = mo.state
		o.sprite = mo.sprite
		o.frame = scframe
		o.tics = mo.tics
		o.anim_duration = mo.anim_duration
		o.dispoffset = mo.dispoffset+1
		o.spriteyoffset = mo.spriteyoffset
		
		o.angle = p.drawangle
		local zadd = (o.eflags & MFE_VERTICALFLIP) and mo.height or 0
		P_MoveOrigin(mo, mo.x, mo.y, mo.z+zadd)
		
		o.color = NoiseSkincolor[p.skincolor] or SKINCOLOR_FLESHEATER
	end
end, MT_NTOPP_BOSSHP)