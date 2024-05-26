freeslot("SPR_SHGN", "S_PTV3_SHOTGUN", "MT_PTV3_SHOTGUN")

mobjinfo[MT_PTV3_SHOTGUN] = {
	doomednum = -1,
	spawnstate = S_PTV3_SHOTGUN,
	spawnhealth = 1000,
	deathstate = S_NULL,
	radius = 16*FU,
	height = 16*FU,
	flags = MF_NOCLIP|MF_NOCLIPHEIGHT
}

states[S_PTV3_SHOTGUN] = {
    sprite = SPR_SHGN,
    frame = A,
    tics = -1,
    action = nil,
    var1 = 0,
    var2 = 0,
    nextstate = S_PTV3_SHOTGUN
}

local function shotgunUse(mo, pmo)

end

addHook("MobjThinker", function(mo)
	if not (mo.target
	and mo.target.valid) then return end

	local pmo = mo.target
	local p = pmo.player

	P_SetOrigin(mo,
		pmo.x+FixedMul(mo.radius*2, cos(p.drawangle-ANGLE_90)),
		pmo.y+FixedMul(mo.radius*2, sin(p.drawangle-ANGLE_90)),
		pmo.z+(pmo.height/2)
	)
	mo.angle = pmo.angle
	mo.momx,mo.momy,mo.momz = 0,0,0

	if p.ptv3.fake_exit then return end

	if p.cmd.buttons & BT_FIRENORMAL then
		local bullet = P_SpawnPlayerMissile(pmo, MT_REDRING, MF2_RAILRING)
		if bullet then
			if bullet.valid then
				bullet.momx = 256*cos(bullet.angle)
				bullet.momy = 256*sin(bullet.angle)
			end

			P_RemoveMobj(mo)
		end
	end
end, MT_PTV3_SHOTGUN)

return {
	name = "Shotgun",
	object = MT_PTV3_SHOTGUN,
	sprite = "SHOTGUNNY", -- i need this for da hud
	offset_x = -3*FU,
	offset_y = -9*FU,
	scale = FU/2,
	use = shotgunUse
}