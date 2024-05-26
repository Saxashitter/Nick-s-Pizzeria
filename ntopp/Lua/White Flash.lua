freeslot("SKINCOLOR_WHITEFLASH")

skincolors[SKINCOLOR_WHITEFLASH] = {
    name = "White Flash",
    ramp = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    invcolor = SKINCOLOR_WHITE,
    invshade = 9,
    chatcolor = V_WHITEMAP,
    accessible = false
}

local function init_flash()
	local t = {}
	t.flashtime = 4
	t.enabled = false
	t.wascolorized = false
	return t
end

addHook("ThinkFrame", do
	for p in players.iterate do
		if not p.mo then continue end
		if not p.ntoppv2_whiteflash then continue end
		if not p.ntoppv2_whiteflash.enabled then continue end

		if not (p.ntoppv2_whiteflash.flashtime) then
			p.mo.color = p.skincolor
			p.mo.colorized = p.ntoppv2_whiteflash.wascolorized
			p.ntoppv2_whiteflash = init_flash()
			continue
		end

		p.mo.color = SKINCOLOR_WHITEFLASH
		p.mo.colorized = true
		p.ntoppv2_whiteflash.flashtime = $-1
	end
end)

ntopp_v2.WhiteFlash = function(p)
	// scrapped effect due to stupidity
end