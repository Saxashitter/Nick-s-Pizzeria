freeslot(
	"MT_PTV3_TOPPINCAGE",
	"SPR_TCGE",
	"S_PTV3_TOPPINCAGE"
)

freeslot("SPR_CDBR", "S_PTV3_CAGEDEBRIS", "MT_PTV3_CAGEDEBRIS")

mobjinfo[MT_PTV3_CAGEDEBRIS] = {
	doomednum = -1,
	spawnstate = S_PTV3_CAGEDEBRIS,
	spawnhealth = 1000,
	deathstate = S_NULL,
	radius = 32*FU,
	height = 32*FU,
	flags = MF_NOCLIPHEIGHT|MF_NOCLIP
}

states[S_PTV3_CAGEDEBRIS] = {
	sprite = SPR_CDBR,
	frame = A,
	tics = -1,
	action = nil,
	var1 = 0,
	var2 = 0,
	nextstate = S_PTV3_CAGEDEBRIS
}

mobjinfo[MT_PTV3_TOPPINCAGE] = {
	doomednum = -1,
	spawnstate = S_PTV3_TOPPINCAGE,
	spawnhealth = 1000,
	deathstate = S_NULL,
	radius = 32*FU,
	height = 32*FU,
	flags = MF_SPECIAL
}

states[S_PTV3_TOPPINCAGE] = {
    sprite = SPR_TCGE,
    frame = FF_ANIMATE|A,
    tics = -1,
    action = nil,
    var1 = 28,
    var2 = 1,
    nextstate = S_PTV3_TOPPINCAGE
}

local function choose(t)
	local args = t
	local choice = P_RandomRange(1,#args)
	print(args[choice])
	return args[choice]
end

addHook("TouchSpecial", function(mo, pmo)
	if not (pmo.valid
	and pmo.player
	and pmo.player.ptv3
	and not pmo.player.ptv3.swapModeFollower) then return true end

	local p = pmo.player

	local angle = ANGLE_180/8

	for i = 0,15 do
		local d = P_SpawnMobjFromMobj(mo, 0,0,0, MT_PTV3_CAGEDEBRIS)

		d.momx = 4*cos(angle*i)
		d.momy = 4*sin(angle*i)
		d.momz = 2*(FU*P_MobjFlip(d))

		d.frame = P_RandomKey(5)
	end
	
	local funny = {}
	for _,i in pairs(PTV3.items) do
		table.insert(funny, i)
	end

	PTV3:givePlayerItem(p, choose(funny).name)
end, MT_PTV3_TOPPINCAGE)

addHook("MobjThinker", function(mo)
	if mo.z+FixedMul(mo.height, mo.scale) < mo.floorz
	or mo.z > mo.ceilingz then
		P_RemoveMobj(mo)
	end
end, MT_PTV3_CAGEDEBRIS)

return true