local music = {
	"PIZTIM",
	"DEAOLI",
	"LAP3LO",
	"FUNFRE"
}

local function playPizzaTimeMusic()
	if not PTV3:isPTV3() then return end
	if not (consoleplayer and consoleplayer.ptv3) then return end
	if gametype ~= GT_PTV3DM and not PTV3.pizzatime then return end
	
	if consoleplayer.ptv3.insecret then
		if not consoleplayer.ptv3.secret_tptoend then
			return
		end
	end
	
	return true
end

addHook('PostThinkFrame', function()
	if not PTV3:isPTV3() then return end

	if consoleplayer
	and consoleplayer.ptv3 
	and consoleplayer.ptv3.insecret 
	and not playPizzaTimeMusic()
	and mapmusname ~= "SECRET" then
		mapmusname = "SECRET"
		S_ChangeMusic(mapmusname, true)
	end
	
	if consoleplayer
	and consoleplayer.ptv3
	and not consoleplayer.ptv3.insecret
	and not playPizzaTimeMusic()
	and mapmusname == "SECRET" then
		mapmusname = mapheaderinfo[gamemap].musname
		S_ChangeMusic(mapmusname, true)
	end
	

	if not playPizzaTimeMusic() then return end
	local loop = true

	if not (displayplayer
	and displayplayer.ptv3) then return end
	local p = displayplayer
	
	local song = music[max(1, min(p.ptv3.laps, #music))]
	if gametype == GT_PTV3DM then
		song = "AOTKPS"
	end
	if PTV3.overtime then
		song = "OVRTRD"
		loop = false
	elseif p.ptv3.extreme then
		song = "ACFTQ"
	end

	if mapmusname ~= song then
		mapmusname = song
		S_ChangeMusic(mapmusname, loop)
	end
end)