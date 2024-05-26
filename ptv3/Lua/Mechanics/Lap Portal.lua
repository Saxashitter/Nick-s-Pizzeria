freeslot("MT_PTV3_LAPPORTAL", "S_PTV3_LAPPORTAL", "SPR_LAPR")

mobjinfo[MT_PTV3_LAPPORTAL] = {
    doomednum = 2048,
    spawnstate = S_PTV3_LAPPORTAL,
    radius = 50*FRACUNIT,
    height = 60*FRACUNIT,
    flags = MF_SPECIAL|MF_NOCLIP|MF_NOCLIPHEIGHT|MF_NOGRAVITY
}

states[S_PTV3_LAPPORTAL] = {
	sprite = SPR_LAPR,
	frame = FF_PAPERSPRITE|A,
	tics = -1
}

local tplist = {}

addHook("NetVars", function(n)
	tplist = n($)
end)

addHook("MobjSpawn", function(mo)
	mo.teleported = {}
end, MT_PTV3_LAPPORTAL)

addHook("ThinkFrame", do
	local rmvlist = {}
	for pmo,_ in pairs(tplist) do
		if not (pmo and pmo.valid and pmo.player) then
			table.insert(rmvlist, _)
			continue
		end

		PTV3:newLap(pmo.player)
		table.insert(rmvlist, pmo)
	end
	for _,i in pairs(rmvlist) do
		tplist[i] = nil
	end
end)

addHook("TouchSpecial", function(mo, pmo)
	if not PTV3.pizzatime then return true end
	if not (mo and mo.valid) then return true end
	if not (pmo and pmo.player and pmo.player.ptv3) then return true end
	if tplist[pmo] then return true end
	if not (PTV3:canLap(pmo.player)) then return true end

	tplist[pmo] = true
	print "lap"
	return true
end, MT_PTV3_LAPPORTAL)