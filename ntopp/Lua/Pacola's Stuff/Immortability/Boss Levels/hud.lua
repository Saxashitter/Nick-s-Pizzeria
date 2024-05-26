
-- spinning hats
-- from hit game
-- scooby doo for the ps2

freeslot("SKINCOLOR_PUREBLACK")

skincolors[SKINCOLOR_PUREBLACK] = {
	name = "Pure Black",
	ramp = {31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31},
	invcolor = SKINCOLOR_BLACK,
	invshade = 16,
	chatcolor = V_GRAYMAP,
	accessible = false
}

ntopp_v2.charhp["ngustavo"] = ntopp_v2.charhp["npeppino"]

local function getHPpos(hpn, mhp)
	mhp = $ or 6
	hpn = $ ~= nil and min($, mhp-1) or 0
	local size = 1
	local xadd = 48*hpn*size
	local yadd = 0
	
	local thign = max(mhp/2, 3)
	size = hpn/thign
	
	xadd = 48*(hpn%thign)
	yadd = 48*size
	
	return xadd, yadd
end

local bosslist = {}
bosslist[MT_FANG] = {
	graph = "VIGIHP",
	mframe = 20
}

local function drawHP(v, p, x, y, num, size, flags, mhp)
	if not v return end
	
	x = $ or 0
	y = $ or 0
	num = $ or 0
	size = $ or FU
	flags = $ or 0
	mhp = $ or 6
	
	local isplyr = type(p) ~= "number" and (p and p.valid)
	
	local b = isplyr and p.ntoppboss or nil
	for i = 1, mhp do
		local color
		local scolor
		if isplyr
			color = v.getColormap(skins[p.skin].name, p.skincolor)
			scolor = v.getColormap(skins[p.skin].name, (NoiseSkincolor[p.skincolor] or SKINCOLOR_FLESHEATER))
		end
		
		if i > num
			color = v.getColormap(TC_RAINBOW, SKINCOLOR_PUREBLACK)
			scolor = color
		end
		
		local xadd, yadd = getHPpos(i-1, mhp)
		if mhp == 1
			xadd = 0
			yadd = 0
		else
			xadd = $*size
			yadd = $*size
		end
		
		local chp
		local graph = bosslist[p] and bosslist[p].graph or "PEPPERHP"
		local mframe = bosslist[p] and bosslist[p].mframe or 12
		local frame = (leveltime/2)%mframe+1
		--local frame = chp.sframe+leveltime%chp.mframe
		local spr = v.cachePatch(graph+frame)
		if isplyr
			chp = ntopp_v2.charhp[skins[p.skin].name]
			graph = chp.spr or SPR_PTHP
			frame = min(b.hud.frame-1+chp.sframe, chp.mframe-1+chp.sframe)
			spr = v.getSpritePatch(graph, frame, 0)
		end
		v.drawScaled(x+xadd, y+yadd, size, spr, flags, color)
		if (chp and chp.sclr ~= nil)
			local sc = chp.sclr
			local scgraph = sc.spr or graph
			local scspr = v.getSpritePatch(scgraph, min(b.hud.frame-1+sc.sframe, chp.mframe-1+sc.sframe), 0)
			v.drawScaled(x+xadd, y+yadd, size, scspr, flags, scolor)
		end
	end
end

local hpmaxtime = TICRATE-TICRATE/3

addHook("PlayerThink", function(p)
	if not (p.mo and p.mo.valid)
	or not isIM(skins[p.skin].name)
	or not p.ntoppboss
	or mapheaderinfo[gamemap].bonustype ~= 1
		if mapheaderinfo[gamemap].bonustype ~= 1
		and (p.ntoppbosshud or p.ntoppbosshud == nil)
		and displayplayer
			hud.enable("rings")
			hud.enable("time")
			hud.enable("score")
			p.ntoppbosshud = false
		end
		return
	end
	
	if displayplayer
		local dp = displayplayer
		hud.disable("rings")
		hud.disable("time")
		hud.disable("score")
		p.ntoppbosshud = true
	end
	
	local b = p.ntoppboss
	local h = b.hud
	h.frame = $ or 1
	local chp = ntopp_v2.charhp[skins[p.skin].name]
	local mframe = chp.mframe or 19
	if leveltime%2 == 0
		if h.frame < mframe
			h.frame = $+1
		else
			h.frame = 1
		end
	end
	if h.hp[1]
		for k, t in ipairs(h.hp) do
			if type(t) ~= "table" continue end
			
			if t.time > hpmaxtime+TICRATE/2
				table.remove(h.hp, k)
				b.hp = min($+1, 6)
				continue
			else
				t.time = $+1
			end
		end
	end
	--print(h.frame)
end)

local bossmo
local btype

addHook("MapLoad", function()
	if mapheaderinfo[gamemap].bonustype ~= 1 bossmo = nil return end
	
	for mo in mobjs.iterate() do
		if not (mo.flags & MF_BOSS) continue end
		
		bossmo = mo
		btype = bossmo.type
		break
	end
end)

addHook("NetVars", function(net)
	bossmo = net(bossmo)
	btype = net(btype)
end)

addHook("HUD", function(v, p)
	if not (p.mo and p.mo.valid)
	or not isIM(skins[p.skin].name)
	or p.spectator
	or mapheaderinfo[gamemap].bonustype ~= 1 return end
	
	local b = p.ntoppboss
	local h = b.hud
	
	local size = FU/2
	drawHP(v, p, 32*FU, 16*FU, b.hp, size, V_SNAPTOTOP|V_SNAPTOLEFT)
	
	local bhp = bossmo.info.spawnhealth
	drawHP(v, btype, 320*FU-(32+48*(bhp/2))*size, 16*FU, bossmo.health, size, V_SNAPTOTOP|V_SNAPTOLEFT, bhp)
	
	if h.hp[1]
		for _, t in ipairs(h.hp) do
			if type(t) ~= "table"
			/*or not t.onscreen*/ continue end
			
			local scale = ease.linear(min(FixedDiv(t.time, hpmaxtime), FU), t.scale, size)
			local hpx, hpy = getHPpos(t.hpv, 6)
			hpx = $*size
			hpy = $*size
			local x = ease.linear(min(FixedDiv(t.time, hpmaxtime), FU), t.x, 32*FU+hpx)
			local y = ease.linear(min(FixedDiv(t.time, hpmaxtime), FU), t.y, 16*FU+hpy)
			drawHP(v, p, x, y, 1, scale, V_SNAPTOTOP|V_SNAPTOLEFT, 1)
		end
	end
end, "game")