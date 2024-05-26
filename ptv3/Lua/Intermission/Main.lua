local drawParallax = dofile "Intermission/Draw Parallax"

local saved_players = {}

local inttime = 0
local has_started = false
local ground_x = 0
local sky_x = 0

local function intermissionStart()
	local _,_,_,_,_,daplayas = PTV3:playerCount()

	table.sort(daplayas, function(a, b)
		return a.score > b.score
	end)

	local rmvlist = {}
	for _,i in ipairs(daplayas) do
		if not (i.ptv3 and not i.ptv3.specforce) then
			table.insert(rmvlist, _)
		end
	end

	for _,i in ipairs(rmvlist) do
		table.remove(rmvlist, _)
	end

	saved_players = daplayas
end

addHook("NetVars", function(n)
	saved_players = n($)
end)

addHook("IntermissionThinker", do
	if not PTV3:isPTV3(true) then return end

	if not has_started then
		intermissionStart()
		has_started = true
	end

	inttime = $+1
	ground_x = $+(FU*5)
	sky_x = $+FU
end)

addHook("MusicChange", function(old, new)
	if PTV3:isPTV3(true)
	and new == "_inter" then
		return "TAKEAB"
	end
end)

addHook("MapLoad", do
	inttime = 0
	ground_x = 0
	sky_x = 0
	saved_players = {}
	has_started = false
	hud.enable "intermissiontally"
end)

local function drawPlayer(v, x, y, scale, p, sprite, frame, rot, flags)
	local patch = v.getSprite2Patch(p.skin, sprite, false, frame, rot)

	v.drawScaled(x, y, scale, patch, flags, v.getColormap(p.skin, p.skincolor))
	
	y = $-(32*FU)-(16*(FU*2))
	PTV3.drawText(v, x, y, p.name, {align = "center", font = "Credits", flags = flags})

	y = $+(8*FU)
	PTV3.drawText(v, x, y, tostring(p.score), {align = "center", font = "Credits", flags = flags})

	y = $+(10*FU)
	local rank = PTV3.ranks[p.ptv3.rank]
	local rp = v.cachePatch(rank.rank.."RANK")

	v.drawScaled(x-(rp.width*((FU/3)/2)), y, FU/3, rp, flags)
end

addHook("HUD", function(v)
	if not PTV3:isPTV3(true) then return end
	hud.disable "intermissiontally"

	drawParallax(v, 0, 0, FU, v.cachePatch("PTINT_BG"), V_SNAPTOLEFT|V_SNAPTOTOP, {x = true, y = true})

	local sun = v.cachePatch("PTINT_SUN"..inttime % 3)
	local clouds = v.cachePatch("PTINT_SKY"..inttime % 3)
	local ground = v.cachePatch("PTINT_GRND")

	local screenWidth = FixedDiv(v.width()*FU, v.dupx()*FU)
	local screenHeight = FixedDiv(v.height()*FU, v.dupy()*FU)

	v.drawScaled(0, 0, FU/3, sun, V_SNAPTOTOP|V_SNAPTORIGHT)
	drawParallax(v, sky_x, 0, FU/3, clouds, V_SNAPTOTOP|V_SNAPTOLEFT)

	drawParallax(v, ground_x, 21*FU, FU/3, ground, V_SNAPTOBOTTOM|V_SNAPTOLEFT)

	for i,p in pairs(saved_players) do
		local runframes = skins[p.skin].sprites[SPR2_RUN_].numframes
		local i = i-1
		local inttime = max(0,inttime-12-(12*i))
		local time = min(inttime*(FU/(35*5)), FU)
		local tween = ease.outcubic(time, screenWidth, 32*FU)
		tween = $+((70*FU)*i)
		
		drawPlayer(v, tween, 165*FU, FU/3, p, SPR2_RUN_, (inttime/2) % runframes, 3, V_SNAPTOLEFT|V_SNAPTOBOTTOM)
	end

	PTV3.drawText(v, 160*FU, 20*FU, "PTV3 IS IN ALPHA! EVERYTHING IS SUBJECT TO CHANGE!", {flags = V_SNAPTOTOP, align = "center"})
end, "intermission")