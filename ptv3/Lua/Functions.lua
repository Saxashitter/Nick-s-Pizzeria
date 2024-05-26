-- helper functions

local function randomChoice(...)
	local options = {...}
	return options[P_RandomRange(1,#options)]
end

local function getAllVarNames(array, ...)
	local values = {}
	local ignore = {...}
	for _,i in pairs(array) do
		local add = true
		
		for e,v in pairs(ignore) do
			if _ == v then
				add = false
				break
			end
		end
		
		if add then
			table.insert(values, _)
		end
	end

	return values
end

--[[
* l_supertextfont.lua
* (sprkizard)
* (May 29, 2020 12:42)
* Desc: Custom font drawer

* Usage: TODO
]]


-- Copy of the creditwidth function in-source, but accounting for any given font type
-- https://github.com/STJr/SRB2/blob/225095afa2fb1c61d12cf96c1b7c56cb4dbb4350/src/v_video.c#L3211
local function GetInternalFontWidth(str, font)
	-- No string
	if not (str) then return 0 end

	local width = 0

	for i=1,#str do
		-- Spaces before fonts
		if str:sub(i):byte() == 32 then
			width = $1+2
			continue
		end

		-- TODO: count special characters?
		if str:sub(i):byte() >= 200 then
			width = $1+8
			continue
		end

		-- (Using patch width by the way)
		if (font == "STCFN") then -- default font
			width = $1+8
		elseif (font == "TNYFN") then
			width = $1+7
		elseif (font == "LTFNT") then
			width = $1+20
		elseif (font == "TTL") then
			width = $1+29
		elseif (font == "CRFNT" or font == "NTFNT") then -- TODO: Credit font centers wrongly
			width = $1+16
		elseif (font == "NTFNO") then
			width = $1+20
		elseif (font == "PCFNT") then
			width = $1+5
		else
			width = $1+8
		end
	end
	return width*FU
end

local fonts = {
	['Combo'] = "PTCMB",
	['Credits'] = "PCFNT",
	['Lap'] = "PTLAP",
	['Old'] = "PTFNT",
	['War'] = "WARFN"
}

function PTV3.drawText(v, x, y, str, parms)

	-- Scaling
	local scale = (parms and parms.scale) or 1*FRACUNIT
	local hscale = (parms and parms.hscale) or 0
	local vscale = (parms and parms.vscale) or 0
	local yscale = (8*(FRACUNIT-scale))
	-- Spacing
	local xspacing = (parms and parms.xspace) or 0 -- Default: 8
	local yspacing = (parms and parms.yspace) or 4
	-- Text Font
	local font = (parms and parms.font) or "Old"
	local color = (parms and parms.color) or v.getColormap(nil, SKINCOLOR_WHITE)
	local uppercs = (parms and parms.uppercase) or false
	local align = (parms and parms.align) or nil
	local flags = (parms and parms.flags) or 0

	local drawscale = FU/3
	font = fonts[font] or "PTFNT"

	-- Split our string into new lines from line-breaks
	local lines = {}

	for ls in str:gmatch("[^\r\n]+") do
		table.insert(lines, ls)
	end

	-- For each line, set some stuff up
	for seg=1,#lines do
		
		local line = lines[seg]
		-- Fixed Position
		local fx = x
		local fy = y
		-- Offset position
		local off_x = 0
		local off_y = 0
		-- Current character & font patch (we assign later later instead of local each char)
		local char
		local charpatch

		-- Alignment options
		if (align) then
			-- TODO: not working correctly for CRFNT
			if (align == "center") then
				fx = $1-FixedMul( (GetInternalFontWidth(line, font)/2), scale) -- accs for scale
			elseif (align == "right") then
				fx = $1-FixedMul( (GetInternalFontWidth(line, font)), scale)
			end
		end

		-- Go over each character in the line
		for strpos=1,#line do

			-- get our character step by step
			char = line:sub(strpos, strpos)

			-- TODO: custom skincolors will make a mess of this since the charlimit is 255
			-- Set text color, inputs, and more through special characters
			-- Referencing skincolors https://wiki.srb2.org/wiki/List_of_skin_colors

			-- TODO: effects?
			-- if (char:byte() == 161) then
			-- 	continue
			-- end
			-- print(strpos<<27)
			-- off_x = (cos(v.RandomRange(ANG1, ANG10)*leveltime))
			-- off_y = (sin(v.RandomRange(ANG1, ANG10)*leveltime))
			-- local step = strpos%3+1
			-- print(step)
			-- off_x = cos(ANG10*leveltime)*step
			-- off_y = sin(ANG10*leveltime)*step

			-- Skip and replace non-existent space graphics
			if not char:byte() or char:byte() == 32 then
				fx = $1+2*scale
				continue
			end

			-- Unavoidable non V_ALLOWLOWERCASE flag toggle (exclude specials above 210)
			if (uppercs or (font == "CRFNT" or font == "NTFNT"))
			and not (char:byte() >= 210) then
				char = tostring(char):upper()
			end

			-- transform the char to byte to a font patch
			charpatch = v.cachePatch( string.format("%s%03d", font, string.byte(char)) )

			local _xs = charpatch.width
			if font == "PCFNT" then _xs = 5*3 end

			-- Draw char patch
			v.drawStretched(
				fx+off_x, fy+off_y+yscale,
				FixedMul(drawscale, scale+hscale), FixedMul(drawscale, scale+vscale), charpatch, flags, color)
			-- Sets the space between each character using font width
			fx = $1+(xspacing+_xs)*FixedMul(drawscale, scale+hscale)
			--fy = $1+yspacing*scale
			--fy = $1+yspacing*scale
		end

		-- Break new lines by spacing and patch width for semi-accurate spacing
		y = $1+(yspacing+charpatch.height)*scale 
	end
end

function PTV3:logEvent(text, type)
	local notifer = "* - "
	if type == 1 then
		notifer = "!!! - "
	elseif type == 2 then
		notifer = ">> - "
	end
		
	chatprint(notifer..text)
end

function PTV3:playerCount()
	if not PTV3:isPTV3(true) then return end
	local total = {}
	local alive = {}
	local alive_2 = {}
	local pizzafaces = {}
	local finished = {}
	local unfinished = {}

	for p in players.iterate do
		if not p.ptv3 then continue end
		if p.ptv3.swapModeFollower then continue end
		if p and p.valid then
			table.insert(total, p)
		end
		if p.ptv3.pizzaface then
			table.insert(pizzafaces, p)
			continue
		end
		if p.mo
		and p.mo.valid
		and not p.ptv3.specforce
		and not p.ptv3.swapModeFollower then
			table.insert(alive, p)
			if p.mo.health then
				table.insert(alive_2, p)
			end
			if p.exiting then
				table.insert(finished, p)
			else
				table.insert(unfinished, p)
			end
		end
	end
	
	return alive, pizzafaces, finished, unfinished, alive_2, total
end

function PTV3:canLap(p)
	if not p.ptv3 then return 0 end
	if not self.overtime then
		if p.ptv3.laps < self.max_laps then
			return 1
		end
		if p.ptv3.extreme and p.ptv3.laps < self.max_laps+self.max_elaps then
			return 1
		end
		if not p.ptv3.extreme and self.max_elaps and p.ptv3.laps >= self.max_laps then
			return 2
		end
	end
	return 0
end

function PTV3:canOvertime()
	local alive,_,finished,unfinished = PTV3:playerCount()

	if #alive > 1 then
		if #finished < #alive/2 then
			return true
		end
	elseif #alive ~= #finished then
		return true
	end

	return false
end

function PTV3:endGame()
	if PTV3.game_over >= 0 then return end

	PTV3.game_over = leveltime
	for p in players.iterate do
		if p.mo then
			if p.exiting then
				p.mo.flags = $|MF_NOTHINK
			else
				P_KillMobj(p.mo)
			end
		end
	end
end

function PTV3:canExit(p)
	return true
end

function PTV3:extremeToggle(p)
	p.ptv3.extreme = true
	if not self.extreme then
		self.extreme = true
		
		P_SetSkyboxMobj(nil,false)
		P_SetupLevelSky(34)
	end
end

function PTV3:overtimeToggle()
	if self.overtime then return end
	self.overtime = true
	
	local ps = PTV3:playerCount()

	for _,p in pairs(ps) do
		if p.ptv3.extreme then
			p.ptv3.specforce = true
		end
	end

	if not (PTV3.snick)then
		PTV3:snickSpawn()
	end

	if consoleplayer
	and consoleplayer.ptv3
	and not consoleplayer.ptv3.insecret then
		P_SetSkyboxMobj(nil,false)
		P_SetupLevelSky(9)
	end
end

function PTV3:teleportPlayer(p, coords)
	local e = coords or self.endpos
	P_SetOrigin(p.mo, e.x, e.y, e.z+(2*FU))
	p.mo.angle = e.a
	p.mo.momx,p.mo.momy,p.mo.momz = 0,0,0
	PTV3.callbacks('TeleportPlayer', p)
end

function PTV3:newLap(p)
	if not self.pizzatime then return end
	if not p.ptv3 then return end
	if p.ptv3.pizzaface then return end
	if not (self:canLap(p)) then return end

	if p.ptv3.isSwap
	and not p.ptv3.swapModeFollower then
		self:newLap(p.ptv3.isSwap)
	end

	local raw_time = leveltime - PTV3.hud_pt

	if p.ptv3.lap_time >= 0 then
		raw_time = leveltime - p.ptv3.lap_time
	end
	local time = string.format( "%02d:%02d", G_TicsToMinutes(raw_time), G_TicsToSeconds(raw_time) )
	local event_text = p.name.." has made it to Lap "..p.ptv3.laps.." in "..time.."!"

	if self:canLap(p) == 2 then
		self:extremeToggle(p)
		event_text = $.." If Overtime starts while in Extreme Laps, then this player will die."
	end
	if p.ptv3.laps > self.max_laps then
		event_text:gsub("to Lap", "to Extreme Lap")
	end

	p.ptv3.laps = $+1

	if not p.ptv3.extreme then
		P_AddPlayerScore(p, 450)
	end

	p.ptv3.lap_time = leveltime

	if p == consoleplayer then
		S_StartSound(nil, sfx_lap2, p)
	end

	p.powers[pw_invulnerability] = 5*TICRATE
	if p.ptv3.isSwap
	and p.ptv3.isSwap.valid then
		p.ptv3.isSwap.powers[pw_invulnerability] = 5*TICRATE
	end

	self:teleportPlayer(p)

	p.ptv3.fake_exit = false

	-- HAHA PIZZAFACE LAP 3
	if p.ptv3.laps >= 4
	and not (self.snick and self.snick.valid) then
		self:snickSpawn()
	elseif p.ptv3.laps >= 3 then
		self.pftime = 0
	end
	
	PTV3:logEvent(event_text, 2)
	PTV3.callbacks('NewLap', p)
end

function PTV3:startPizzaTime(p)
	self.pizzatime = true
	self.hud_pt = leveltime
	for player in players.iterate do
		if not player.mo then continue end
		if not player.ptv3 then continue end

		if (player.ptv3.insecret) then
			player.ptv3.secret_tptoend = true
		elseif player ~= p then
			self:teleportPlayer(player, self.endpos)
		end
	end
	
	-- copied from jisk edition, temporary
	local thesign = P_SpawnMobj(0,0,0, MT_SIGN)
	P_SetOrigin(thesign, self.spawn.x, self.spawn.y, self.spawn.z)

	PTV3.spawnsector = thesign.subsector.sector
	local time = string.format( "%02d:%02d", G_TicsToMinutes(leveltime), G_TicsToSeconds(leveltime) )
	PTV3:logEvent(p.name.." has started Pizza Time in "..time.."! Get to the beginning!", 1)
	
	PTV3.callbacks('PizzaTime', p)
end

function PTV3:initSwapMode(p, p2)
	if not (p and p2 and p.ptv3 and p2.ptv3) then return false end
	if not p.mo then return false end
	if not p2.mo then return false end

	if p2.ptv3.swapModeFollower then
		p2.ptv3.swapModeFollower = nil
	end
	p.ptv3.swapModeFollower = p2.mo
	
	p.ptv3.isSwap = p2
	p2.ptv3.isSwap = p

	self:doEffect(p2.mo, "Taunt")

	return true
end

function PTV3:doFollowerTP(flwr, lder, index)
	if index == nil then index = 2 end
	if not lder.ptv3 then return end
	local data = lder.ptv3.savedData
	if not data[1] then return end

	if data[#data-index] then
		local data = data[#data-index]

		if flwr.player then
			local pflags = data.pflags & ~(PF_DIRECTIONCHAR|PF_ANALOGMODE|PF_AUTOBRAKE|PF_APPLYAUTOBRAKE|PF_FORCESTRAFE)
			
			flwr.player.exiting = data.exiting
			flwr.player.pflags = $|pflags
			flwr.player.drawangle = data.angle
		end
		P_SetOrigin(flwr,
			data.x+FixedMul(lder.mo.radius*2, -cos(lder.drawangle)),
			data.y+FixedMul(lder.mo.radius*2, -sin(lder.drawangle)),
			data.z
		)
		flwr.momx = data.momx
		flwr.momy = data.momy
		flwr.momz = data.momz
	end

	local state = S_PLAY_STND

	if (flwr.momx or flwr.momy) then
		state = S_PLAY_WALK
	end
	if not P_IsObjectOnGround(flwr) then
		state = S_PLAY_SPRING
	end

	flwr.state = state
end