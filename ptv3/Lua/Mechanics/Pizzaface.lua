freeslot("MT_PTV3_PIZZAFACE",
	"SPR_PZAT",
	"S_PIZZAFACE_AI",
	"S_PIZZAFACE_OVERLAY",
	"sfx_pflgh"
)
sfxinfo[sfx_pflgh].caption = "Hahahahahaaa!"

mobjinfo[MT_PTV3_PIZZAFACE] = {
	doomednum = -1,
	spawnstate = S_PIZZAFACE_AI,
	spawnhealth = 1000,
	deathstate = S_NULL,
	radius = 60*FU,
	height = 60*FU,
	flags = MF_NOCLIP|MF_NOGRAVITY|MF_NOCLIPHEIGHT|MF_SPECIAL
}

states[S_PIZZAFACE_AI] = {
    sprite = SPR_PZAT,
    frame = FF_ANIMATE|A,
    tics = -1,
    action = nil,
    var1 = 15,
    var2 = 1,
    nextstate = S_PIZZAFACE_AI
}

local function followC(p)
	return p.mo.health and p.ptv3 and not p.ptv3.pizzaface and not p.ptv3.insecret and not (p.exiting)
end

local function P_FlyTo(mo, fx, fy, fz, sped, addques)
	local z = mo.z+(mo.height/2)
    if mo.valid
        local flyto = P_AproxDistance(P_AproxDistance(fx - mo.x, fy - mo.y), fz - z)
        if flyto < 1
            flyto = 1
        end
		
        if addques
            mo.momx = $ + FixedMul(FixedDiv(fx - mo.x, flyto), sped)
            mo.momy = $ + FixedMul(FixedDiv(fy - mo.y, flyto), sped)
            mo.momz = $ + FixedMul(FixedDiv(fz - z, flyto), sped)
        else
            mo.momx = FixedMul(FixedDiv(fx - mo.x, flyto), sped)
            mo.momy = FixedMul(FixedDiv(fy - mo.y, flyto), sped)
            mo.momz = FixedMul(FixedDiv(fz - z, flyto), sped)
        end    
    end    
end

local function getNearestPlayer(pos, conditions)
	local x,y,z,pl

	for p in players.iterate do
		if not p.mo then continue end
		if conditions and not conditions(p) then continue end
		
		local newx = abs(p.mo.x - pos.x)
		local newy = abs(p.mo.y - pos.y)
		local newz = abs(p.mo.z - pos.z)

		if (x == nil
		or y == nil
		or z == nil)
		or (newx < x
		and newy < y
		and newz < z) then
			x = newx
			y = newy
			z = newz
			pl = p
		end
	end

	return pl
end

addHook('MobjSpawn', function(pf)
	pf.flyspeed = 23*FU
	S_StartSound(nil, sfx_pflgh)

	local player = getNearestPlayer(pf, followC)
	pf.cooldown = 5*TICRATE
	if not player then return end
	pf.target = player.mo
end, MT_PTV3_PIZZAFACE)

addHook('MobjThinker', function(pf)
	if pf.tracer then return end
	if pf.cooldown then 
		pf.cooldown = $-1
		return
	end

	if not (leveltime % 4) then
		PTV3:doEffect(pf, "PF Afterimage")
	end

	local player = getNearestPlayer(pf, followC)
	pf.target = player and player.mo
	pf.momx,pf.momy,pf.momz = 0,0,0
	if pf.target then
		pf.angle = R_PointToAngle2(pf.x, pf.y, pf.target.x, pf.target.y)
		P_FlyTo(pf, pf.target.x, pf.target.y, pf.target.z, pf.flyspeed)
	end
end, MT_PTV3_PIZZAFACE)

local function PFTouchSpecial(pf, pmo)
	if pf.tracer == pmo then return end
	if pf.cooldown then return end
	
	if pmo.player.powers[pw_flashing]
	or pmo.player.powers[pw_invulnerability] then
		return
	end
	
	P_KillMobj(pmo, pf, pf)

	if pmo.player.ptv3
	and multiplayer
	and not (pmo.health) then
		pmo.player.ptv3.specforce = true
	end
end

addHook('TouchSpecial', function(pf, pmo)
	PFTouchSpecial(pf, pmo)
	return true
end, MT_PTV3_PIZZAFACE)

local function spawnAIpizza(s)
	return P_SpawnMobj(s.x, s.y, s.z, MT_PTV3_PIZZAFACE)
end

function PTV3:pizzafaceSpawn()
	if not PTV3.pizzaface then
		local position = {}
		local clonething = self.endpos

		if gametype == GT_PTV3DM then
			clonething = self.spawn
		end

		for _,i in pairs(clonething) do
			position[_] = i
		end

		PTV3.pizzaface = spawnAIpizza(clonething)
	end
end