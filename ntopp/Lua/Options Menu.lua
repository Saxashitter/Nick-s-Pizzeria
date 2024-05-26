

local function drawScrollingBG(v,bgp,scale)
    local width = FixedMul(bgp.width*FU, scale)
    local height = FixedMul(bgp.height*FU, scale)
    local x = leveltime % (width/FU)
    local y = leveltime % (height/FU)
    
    local screen_width = v.width()/v.dupx()*FU
    local screen_height = v.height()/v.dupy()*FU

	for w = 0,FixedDiv(screen_width+width, width)/FU do
		for h = 0,FixedDiv(screen_height+height, height)/FU do
			local badfix = 0
			if FixedMul(h*FU,height) > screen_height then
				badfix = 1
			end
			v.drawScaled(FixedMul(w*FU, width)-(x*FU), FixedMul(h*FU, height)-(y*FU)-(badfix*FU), scale, bgp, V_SNAPTOLEFT|V_SNAPTOTOP)
		end
	end
end

addHook('PlayerThink', function(player)
	if player and player.mo and player.valid and player.mo.valid then
	if not isPTSkin(player.mo.skin) then player.ntoppv2_optionsopen = false return end
	local sector = player.mo.subsector.sector
	if sector.special == 576 and not player.ntoppv2_optionsexit and not player.ntoppv2_optionsopen then
		player.ntoppv2_optionsopen = true
		player.ntoppv2_optionsexit = true
		player.ntoppv2_lastsong = S_MusicName()
		player.ntoppv2_optionstime = 10*TICRATE
		S_ChangeMusic("NOWAY",true,player)
	elseif sector.special ~= 576 and player.ntoppv2_optionsexit then
		player.ntoppv2_optionsexit = false
	end
	
	if not player.ntoppv2_optionsopen then return end
	
	
	if not (player.ntoppv2_optionstime) then 
		player.ntoppv2_optionsopen = false
		S_ChangeMusic(player.ntoppv2_lastsong,true,player)
	return end

	player.pflags = $|PF_FULLSTASIS
	player.ntoppv2_optionstime = $-1
	end
end)

addHook('HUD', function(v)
	if not consoleplayer then return end
	if not consoleplayer.ntoppv2_optionsopen then return end
	drawScrollingBG(v,v.cachePatch('OPTIONBG'),FU/3)

	local string = "BREAKDANCE CANCELLER? BREAKDANCE CANCELLER! "
	local width = v.stringWidth(string)
	local screen_width = v.width()/v.dupx()
	
	local x = -(leveltime*2 % width)
	
	v.drawString(160, 8, "Options are temporarily removed.", V_ALLOWLOWERCASE|V_SNAPTOTOP, "small-center")
	v.drawString(160, 12, "It's becoming hard to manage. And those pesky PTSR cheesers had enough fun. Fuck you!", V_ALLOWLOWERCASE|V_SNAPTOTOP, "small-center")
	v.drawString(160, 190, "This screen will be dismissed in "..tostring(consoleplayer.ntoppv2_optionstime/TICRATE).." seconds. Play fairly, bitch!", V_ALLOWLOWERCASE|V_SNAPTOBOTTOM, "small-center")
	
	local noisette = v.cachePatch('NOISEANDETTE')
	v.drawScaled(220*FU-(noisette.width*(FU/3)), 50*FU, FU/3, noisette)
	
	for w = 0,screen_width/width do
		v.drawString(x+(width*w), 40, string, V_SNAPTOLEFT|V_SNAPTOTOP)
	end
end)