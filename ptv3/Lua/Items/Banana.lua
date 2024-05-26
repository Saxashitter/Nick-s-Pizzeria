freeslot("MT_PTV3_BANANA", "S_PTV3_BANANA", "SPR_BNAN")
freeslot("sfx_bslip")

sfxinfo[sfx_bslip].caption = "slipped on a banan"

mobjinfo[MT_PTV3_BANANA] = {
	doomednum = -1,
	spawnstate = S_PTV3_BANANA,
	spawnhealth = 1000,
	deathstate = S_NULL,
	radius = 16*FU,
	height = 16*FU,
	flags = MF_SPECIAL
}

states[S_PTV3_BANANA] = {
    sprite = SPR_BNAN,
    frame = A,
    tics = -1,
    action = nil,
    var1 = 0,
    var2 = 0,
    nextstate = S_PTV3_BANANA
}

local function bananaUse(mo, pmo)

	P_SetOrigin(mo,
		pmo.x+FixedMul(pmo.radius, FixedMul(cos(pmo.angle), pmo.scale)),
		pmo.y+FixedMul(pmo.radius, FixedMul(sin(pmo.angle), pmo.scale)),
		pmo.z+FixedMul(pmo.height, pmo.scale)
	)
	if not mo.valid or not pmo.valid then return end

	mo.momx = 18*cos(pmo.angle)
	mo.momy = 18*sin(pmo.angle)
	mo.momz = 8*(FU*P_MobjFlip(mo))
end

addHook('TouchSpecial', function(mo, pmo)
	if not mo.valid then return true end
	if pmo == mo.target then return true end
	if not (pmo and pmo.player and pmo.player.ptv3 and not pmo.player.ptv3.swapModeFollower) then return true end

	pmo.player.ptv3.banana = 1
	pmo.player.ptv3.banana_angle = R_PointToAngle2(0,0, pmo.momx, pmo.momy)
	pmo.player.ptv3.banana_speed = pmo.player.speed
	pmo.momz = 8*(FU*P_MobjFlip(pmo))
	S_StartSound(pmo, sfx_bslip)

	if mo.target
	and mo.target.player
	and pmo.player then
		PTV3:logEvent(pmo.player.name.." has slipped on "..mo.target.player.name.."'s banana!")
	end

	P_RemoveMobj(mo)
end, MT_PTV3_BANANA)

return {
	name = "Banana",
	object = MT_PTV3_BANANA,
	sprite = "BANARONI", -- i need this for da hud
	offset_x = -3*FU,
	offset_y = -9*FU,
	scale = FU/2,
	use = bananaUse
}