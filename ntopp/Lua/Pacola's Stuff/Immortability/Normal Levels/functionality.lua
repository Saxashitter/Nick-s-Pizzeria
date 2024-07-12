
-- makes pepigno and the other peopl importal
-- on normal elvels onley
-- except snick he could die before

rawset(_G, "isIM", function(skin) -- snick was removed, lazy to remvoe this for now
	if isPTSkin(skin)
		return true
	end
	return false
end)

addHook("MobjDamage", function(pmo, inf, src, _, dmg)
	local p = pmo.player
	if not isIM(pmo.skin)
	or mapheaderinfo[gamemap].bonustype == 1 return end
	
	if dmg == DMG_FIRE return end
	
	if p.rings == 0 and not p.powers[pw_shield]
		P_DoPlayerPain(p, src, inf)
		return true
	end
end, MT_PLAYER)

-- player think that does a bunch of stuff

local function initializeVars(p)
	local pmo = p.mo
	p.ntoppimmortal = {
		upos = {
			x = pmo.x,
			y = pmo.y,
			z = pmo.z,
			a = pmo.angle
		},
		timer = 0,
		difficulty = false,
		difft = {
			frame = 1,
			ustatic = false,
			sframe = 0,
			sadd = 1
		},
		camz = 0
	}
end

freeslot("sfx_tvswtc")
freeslot("sfx_tvswbc")

addHook("PlayerSpawn", function(p)
	if p.ntoppimmortal == nil
		initializeVars(p)
	else
		local i = p.ntoppimmortal
		i.timer = 0
		i.difficulty = false
		i.difft = {
			frame = 1,
			ustatic = false,
			sframe = 0,
			sadd = 1
		}
	end
end)

addHook("PlayerThink", function(p)
	if not NTOPP_Check(p) then
		if p.ntoppimmortal
		and p.ntoppimmortal.difficulty
			local i = p.ntoppimmortal
			i.difficulty = false
			i.timer = 0
		end
		return
	end
	
	local pmo = p.mo
	if p.ntoppimmortal == nil
		initializeVars(p)
	end
	p.powers[pw_underwater] = 0 -- how'd i forget
	p.powers[pw_spacetime] = 0 -- about these
	local i = p.ntoppimmortal
	local d = i.difft
	
	if leveltime <= 2
		for mt in mapthings.iterate do
			local pn = #p
			if mt.type ~= pn+1 continue end
			
			i.upos.x = mt.x*FU
			i.upos.y = mt.y*FU
			local sec = R_PointInSubsector(mt.x*FU, mt.y*FU).sector
			local fh = ((mt.options & MTF_OBJECTFLIP) and sec.ceilingheight) or sec.floorheight
			i.upos.z = mt.z*FU+fh
			i.upos.a = FixedAngle(mt.angle*FU)
			break
		end
	end
	
	if i.difficulty
		if d.sadd > 0
			p.pflags = $1|PF_FULLSTASIS
			pmo.flags2 = $1|MF2_DONTDRAW
			if (displayplayer and displayplayer == p)
				local c = camera
				c.chase = true
				c.z = i.camz
			end
		elseif d.sadd < 0
		and i.fakeplyr
		and i.fakeplyr.valid
			P_RemoveMobj(i.fakeplyr)
		end
		i.timer = $+1
		if i.timer == FixedRound(80*FixedDiv(60, TICRATE))/FU
			pmo.state = S_PLAY_STND
			pmo.momx = 0
			pmo.momy = 0
			pmo.momz = 0
			P_SetOrigin(pmo, i.upos.x, i.upos.y, i.upos.z)
			pmo.angle = i.upos.a
			p.drawangle = i.upos.a
			d.sadd = -1
			d.ustatic = true
			S_StartSound(p.mo, sfx_tvswbc, p)
			pmo.flags = i.oldflags
			pmo.flags2 = $ & ~MF2_DONTDRAW
			i.timer = 0
		end
		
		if (i.fakeplyr and i.fakeplyr.valid)
			local fp = i.fakeplyr
			fp.state = pmo.state
			fp.sprite = pmo.sprite
			fp.sprite2 = pmo.sprite2 -- making sure
			fp.frame = pmo.frame
		end
		
		if d.ustatic
			d.sframe = $+(FixedMul(FixedDiv(35, 100), FixedDiv(60, 35))*d.sadd)
			if d.sframe > 9*FU
			and d.sadd > 0
				d.ustatic = false
			end
		end
		
		if d.sframe < 1
		and d.sadd < 0
			i.difficulty = false
			if (i.fakeplyr and i.fakeplyr.valid)
				P_RemoveMobj(i.fakeplyr)
			end
			return
		end
	end
	
	if d.sframe > 9*FU
		d.sframe = 9*FU
	elseif d.sframe < 0
		d.sframe = 0
	end
	
	if p.starpostnum ~= 0
		i.upos.x = p.starpostx*FU
		i.upos.y = p.starposty*FU
		i.upos.z = p.starpostz*FU
		i.upos.a = FixedAngle(p.starpostangle*FU)+ANGLE_180
	end
end)

-- pit handling stuff yay

addHook("ShouldDamage", function(pmo, _, _, _, dmg)
	local p = pmo.player
	if not NTOPP_Check(p) return end
	
	local i = p.ntoppimmortal
	local d = i.difft
	
	if i.difficulty return false end
	
	if dmg ~= DMG_DEATHPIT return end
	
	fsm.ChangeState(p, ntopp_v2.enums.BASE)
	p.pvars.forcedstate = nil
	p.pvars.movespeed = ntopp_v2.machs[1]
	if pmo.skin == "nthe_noise"
		i.difft.frame = P_RandomRange(5, 7)
	elseif pmo.skin == "ngustavo"
		i.difft.frame = 4
	else
		i.difft.frame = P_RandomRange(1, 3)
	end
	d.sframe = 1
	d.ustatic = true
	d.sadd = 1
	p.pflags = $ & ~(PF_JUMPED|PF_STARTJUMP)
	if (displayplayer and displayplayer == p)
		camera.chase = true
		i.camz = camera.z
	end
	i.difficulty = true
	S_StartSound(p.mo, sfx_tvswtc, p)
	i.oldflags = pmo.flags
	--i.fakeplyr = P_SpawnGhostMobj(pmo)
	i.fakeplyr = P_SpawnMobj(pmo.x, pmo.y, pmo.z, MT_GHOST)
	local fp = i.fakeplyr
	fp.target = pmo
	fp.skin = pmo.skin
	fp.state = pmo.state
	fp.flags = MF_NOCLIP|MF_NOCLIPHEIGHT
	fp.flags2 = pmo.flags2 & ~MF2_DONTDRAW
	fp.eflags = pmo.eflags
	fp.momx = pmo.momx
	fp.momy = pmo.momy
	fp.momz = pmo.momz
	fp.angle = p.drawangle
	fp.color = pmo.color
	fp.colorized = pmo.colorized
	pmo.flags = MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT
	pmo.z = $+FU
	pmo.momz = 0
	return false
end, MT_PLAYER)