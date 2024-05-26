dofile "Mechanics/Toppins/Cage"

freeslot("MT_PTV3_TOPPIN", "S_PTV3_MTOPPIN", "SPR_MTID")

function PTV3:spawnToppin(x, y, z)
	return P_SpawnMobj(x, y, z, MT_PTV3_TOPPINCAGE)
end

function PTV3:givePlayerToppin(p, x, y, z)
	--P_SpawnMobj(x, y, z, MT_PTV3_TOPPIN)
end

addHook("MapThingSpawn", function(mo, thing)
	if not PTV3:isPTV3() then return end

	PTV3:spawnToppin(mo.x, mo.y, mo.z)
	P_RemoveMobj(mo)
end, MT_EMBLEM)