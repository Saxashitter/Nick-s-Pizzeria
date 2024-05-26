freeslot("MT_PTV3_EFFECT")

mobjinfo[MT_PTV3_EFFECT] = {
	doomednum = -1,
	spawnstate = S_THOK,
	spawnhealth = 1000,
	deathstate = S_NULL,
	radius = FU,
	height = FU,
	flags = MF_NOCLIP|MF_NOGRAVITY|MF_NOCLIPHEIGHT
}

local files = {
	"Taunt",
	"PF Afterimage"
}

PTV3.effects = {}
for _,i in ipairs(files) do
	PTV3.effects[i] = dofile("Effects/"..i)
end

function PTV3:doEffect(mo, effect)
	effect = self.effects[effect]

	if type(effect.state) == "string"
	and effect.state == "ghost" then
		local mobj = P_SpawnGhostMobj(mo)

		mobj.fuse = effect.fuse
		mobj.tics = effect.tics
		mobj.color = effect.color
		mobj.colorized = true

		if effect.follow then
			mobj.target = mo
		end

		return mobj
	end

	local mobj = P_SpawnMobjFromMobj(mo, 0,0,0, MT_PTV3_EFFECT)

	if effect.follow then
		mobj.target = mo
	end
	if effect.gravity then
		mobj.flags = $ & ~(MF_NOGRAVITY|MF_NOCLIPHEIGHT|MF_NOCLIP)
		mobj.kafc = true --kill after floor or ceiling
	end
	if effect.randomframe then
		mobj.frame = P_RandomKey(effect.randomframe)
	end
	mobj.state = effect.state

	if effect.func then
		effect.func(mo, mobj)
	end

	return mobj
end

addHook('MobjThinker', function(mobj)
	if mobj.target then
		if not mobj.target.valid then
			P_RemoveMobj(mobj)
			return
		end

		P_SetOrigin(mobj,
			mobj.target.x+mobj.target.momx,
			mobj.target.y+mobj.target.momy,
			mobj.target.z+mobj.target.momz
		)
	end
	if mobj.kafc then
		if mobj.z+mobj.height < mobj.floorz
		or mobj.z > mobj.ceilingz then
			print "die"
			P_RemoveMobj(mobj)
			return
		end
	end
end, MT_PTV3_EFFECT)