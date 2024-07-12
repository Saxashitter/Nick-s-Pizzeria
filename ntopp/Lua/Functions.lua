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
			local val = 2
			if font == "PTFNT" then val = 8 end
			if font == "PCFNT" then val = 5 end
			width = $1+val
			continue
		end
		-- Ignore skincolors completely
		if str:sub(i):byte() >= 131 and str:sub(i):byte() <= 198 then
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
		elseif (font == "PCFNT") then
			width = $1+5
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
		else
			width = $1+8
		end
	end
	return width
end


local function drawSuperText(v, x, y, str, parms)

	-- Scaling
	local scale = (parms and parms.scale) or 1*FRACUNIT
	local hscale = (parms and parms.hscale) or 0
	local vscale = (parms and parms.vscale) or 0
	local yscale = (8*(FRACUNIT-scale))
	-- Spacing
	local xspacing = (parms and parms.xspace) or 0 -- Default: 8
	local yspacing = (parms and parms.yspace) or 4
	-- Text Font
	local font = (parms and parms.font) or "STCFN"
	local color = (parms and parms.color) or v.getColormap(nil, SKINCOLOR_WHITE)
	local uppercs = (parms and parms.uppercase) or false
	local align = (parms and parms.align) or nil
	local flags = (parms and parms.flags) or 0
	
	-- Split our string into new lines from line-breaks
	local lines = {}
	
	local scalefix = FU

	for ls in str:gmatch("[^\r\n]+") do
		table.insert(lines, ls)
	end

	if font == "PTFNT" or font == "PCFNT" then
		scalefix = FixedMul($, FU/3)
	end

	-- For each line, set some stuff up
	for seg=1,#lines do
		
		local line = lines[seg]
		-- Fixed Position
		local fx = x << FRACBITS
		local fy = y << FRACBITS
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
				fx = $1-FixedMul( (GetInternalFontWidth(line, font)/2), scale) << FRACBITS -- accs for scale
				-- 	fx = $1-FixedMul( (v.stringWidth(line, 0, "normal")/2), scale) << FRACBITS
			elseif (align == "right") then
				fx = $1-FixedMul( (GetInternalFontWidth(line, font)), scale) << FRACBITS
				-- fx = $1-FixedMul( (v.stringWidth(line, 0, "normal")), scale) << FRACBITS
			end
		end

		-- Go over each character in the line
		for strpos=1,#line do

			-- get our character step by step
			char = line:sub(strpos, strpos)

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
				local val = 2
				if font == "PTFNT" then val = 8 end
				if font == "PCFNT" then val = 5 end
				fx = $1+val*scale
				continue
			end

			-- Unavoidable non V_ALLOWLOWERCASE flag toggle (exclude specials above 210)
			if (uppercs or (font == "CRFNT" or font == "NTFNT" or font == "PTFNT"))
			and not (char:byte() >= 210) then
				char = tostring(char):upper()
			end

			-- transform the char to byte to a font patch
			charpatch = v.cachePatch( string.format("%s%03d", font, string.byte(char)) )

			-- Draw char patch
			v.drawStretched(
				fx+off_x, fy+off_y+yscale,
				FixedMul(scale+hscale, scalefix), FixedMul(scale+vscale, scalefix),
				charpatch, flags, color
			)
			-- Sets the space between each character using font width
			local width = charpatch.width
			if font == "PCFNT" then width = 5*3 end
			fx = $1+(xspacing+width)*FixedMul(scale, scalefix)
			--fy = $1+yspacing*scale
		end

		-- Break new lines by spacing and patch width for semi-accurate spacing
		local height = charpatch.height
		if font == "PCFNT" then height = 8*3 end
		y = $1+(yspacing+height)*FixedMul(scale, scalefix) >> FRACBITS 
	end	

end

--[[
* l_worldtoscreen.lua
* (sprkizard)
* (‎Aug 19, ‎2021, ‏‎22:51:56)
* Desc: WIP

* Usage: TODO
]] -- (added by Pacola, used for the bossfight hp pickups)

local function R_WorldToScreen2(p, cam, target)

	-- local sx = cam.angle - R_PointToAngle2(p.mo.x, p.mo.y, target.x, target.y)
	local sx = cam.angle - R_PointToAngle(target.x, target.y)
	local visible = false

	-- Get the h distance from the target
	local hdist = R_PointToDist(target.x, target.y)
	-- print(AngleFixed(sx)/FU )
	if sx > ANGLE_90 or sx < ANGLE_270 then
		-- sx = 0 -- return {x=0, y=0, scale=0}
		visible = false
	else
		sx = FixedMul(160*FU, tan($1)) + 160*FU
		visible = true
	end

	-- local sx = 160*FU + (160 * tan(cam.angle - R_PointToAngle(target.x, target.y)))
	-- local sy = 100*FU + (100 * (tan(cam.aiming) - FixedDiv(target.z, hdist)))
	local sy = 100*FU + 160 * (tan(cam.aiming) - FixedDiv(target.z-cam.z, 1 + FixedMul(hdist, cos(cam.angle - R_PointToAngle(target.x, target.y))) ))
	
	-- local c = cos(p.viewrollangle)
	-- local s = sin(p.viewrollangle)
	-- sx = $1+FixedMul(c, target.x) + FixedMul(s, target.y)
	-- sy = $1+FixedMul(c, target.y) - FixedMul(s, target.x)

	local ss = FixedDiv(160*FU, hdist)

	return {x=sx, y=sy, scale=ss, onscreen=visible}
end

rawset(_G, "NTOPP_drawSuperText", drawSuperText)
rawset(_G, "NTOPP_GetInternalFontWidth", GetInternalFontWidth)
rawset(_G, "NTOPP_WorldToScreen2", R_WorldToScreen2)

rawset(_G, "PT_ButteredSlope", function(mo)
	local thrust
	local angle
	local slang -- pacola addition here yay!!!

	if (not mo.standingslope) then
		return 0
	end

	if (mo.standingslope.flags & SL_NOPHYSICS) then
		return 0
	end
	
	if (mo.flags & (MF_NOCLIPHEIGHT|MF_NOGRAVITY)) then
		return 0
	end

	if (mo.player) then
		if (abs(mo.standingslope.zdelta) < FRACUNIT/4 and not (mo.player.pflags & PF_SPINNING)) then
			return 0
		end

		if (abs(mo.standingslope.zdelta) < FRACUNIT/2 and not (mo.player.rmomx or mo.player.rmomy)) then
			return 0
		end
	end

	thrust = sin(mo.standingslope.zangle) * 3 / 2 * (mo.eflags & MFE_VERTICALFLIP and 1 or -1)

	if (mo.player) then
		local mult = 0
		if (mo.momx or mo.momy) then
			angle = R_PointToAngle2(0, 0, mo.momx, mo.momy) - mo.standingslope.xydirection
			
			if (P_MobjFlip(mo) * mo.standingslope.zdelta < 0) then
				angle = $^ANGLE_180
			end

			mult = cos(angle)
			angle = cos($)
		end

		thrust = FixedMul(thrust, FRACUNIT*2/3 + mult/8);
	end

	if (mo.momx or mo.momy) then
		thrust = FixedMul(thrust, FRACUNIT+P_AproxDistance(mo.momx, mo.momy)/16)
	end

	thrust = FixedMul(thrust, abs(P_GetMobjGravity(mo)));

	thrust = FixedMul(thrust, mo.friction)

	local sl = mo.standingslope
	if sl
		slang = sl.zangle > 0 and sl.xydirection+ANGLE_180 or sl.xydirection
	end

	return thrust,angle, slang
end)

rawset(_G, 'isPTSkin', function(skin)
	return (skin == "npeppino" or skin == "nthe_noise" or skin == "ngustavo")
end)

rawset(_G, 'L_ZLaunch', function(mo,thrust,relative)
	if mo.eflags&MFE_UNDERWATER
		thrust = $*3/5
	end
	P_SetObjectMomZ(mo,FixedMul(thrust,mo.scale),relative)
end)

rawset(_G, "IncreaseSuperTauntCount", function(player)
	if not player.pvars.supertauntcount then
		player.pvars.supertauntcount = 0
	end
	
	player.pvars.supertauntcount = $+1
	
	if player.pvars.supertauntcount >= 10 and not player.pvars.supertauntready then
		player.pvars.supertauntready = true
		S_StartSound(player.mo, sfx_strea)
	end
end)

local function isPlayerInWall(p, l)
	local sector = (l.backsector 
		and p.mo.subsector.sector ~= l.backsector)
	and l.backsector or l.frontsector
	local cheight = sector.ceilingheight
	local fheight = sector.floorheight

	if sector.f_slope then
		fheight = P_GetZAt(sector.f_slope, p.mo.x, p.mo.y)
	end
	if sector.c_slope then
		cheight = P_GetZAt(sector.c_slope, p.mo.x, p.mo.y)
	end

	if p.mo.z+p.mo.height/2 < fheight
	or p.mo.z+p.mo.height/2 > cheight then
		return true
	end

	for _,sector in pairs({sector, p.mo.subsector.sector}) do
		if not sector then continue end
		for wall in p.mo.subsector.sector.ffloors() do
			if (p.mo.z+p.mo.height/2 < wall.topheight)
			and (p.mo.z+p.mo.height/2 > wall.bottomheight)
			and(wall.flags & FF_EXISTS)
			and(wall.flags & FF_BLOCKPLAYER) then //Don't want the player to cling to water. That would be stupid
				return true
			end
		end
	end
	return false
end

rawset(_G, "WallCheckHelper", function(player, l)
	if not (player and player.valid and player.mo and player.mo.valid) then return end
	local atwall = 0
	local climbing = false

	if (l and l.valid and isPlayerInWall(player, l)) then
		player.pvars.savedline = l
	elseif not (player.pvars.savedline and player.pvars.savedline.valid) then
		return false
	end

	climbing = isPlayerInWall(player, player.pvars.savedline)
	if player.pvars.savedline.backsector == nil then
		climbing = true
	end
	if not climbing then
		player.pvars.savedline = nil
	elseif player.fsm and player.fsm.state == ntopp_v2.enums.WALLCLIMB then
		local linex,liney = P_ClosestPointOnLine(player.mo.x,player.mo.y,player.pvars.savedline)
		local lineangle = R_PointToAngle2(player.mo.x,player.mo.y,linex,liney)
		player.drawangle = lineangle
	end

	return climbing
end)

local function normalMovement(p)
	p.mo.momx = p.cmomx
	p.mo.momy = p.cmomy
	
	local camera_angle = (p.cmd.angleturn<<16)
	local controls_angle = R_PointToAngle2(0,0, p.cmd.forwardmove*FU, -p.cmd.sidemove*FU)

	if not (p.cmd.sidemove or p.cmd.forwardmove) then return end
	if not (p.pvars.movespeed) then return end
	
	p.mo.momx = p.cmomx + FixedMul(p.pvars.movespeed, cos(controls_angle+camera_angle))
	p.mo.momy = p.cmomy + FixedMul(p.pvars.movespeed, sin(controls_angle+camera_angle))
end

local function twodMovement(p)
	p.mo.momx = p.cmomx
	p.mo.momy = p.cmomy
	
	local camera_angle = 0
	local controls_angle = R_PointToAngle2(0,0,0, -p.cmd.sidemove*FU)

	if not (p.cmd.sidemove or p.cmd.forwardmove) then return end
	if not (p.pvars.movespeed) then return end
	
	p.mo.momx = p.cmomx + FixedMul(p.pvars.movespeed, cos(controls_angle+camera_angle))
end

rawset(_G, "NTOPP_MovementHandler", function(p)
	if not p.mo then return end
	if p.ntoppv2_diagonalspring then return end
	if not (p.mo.health) or P_PlayerInPain(p) then return end
	if p.pflags & PF_SLIDING then return end
	
	if p.mo.flags2 & MF2_TWOD then
		twodMovement(p)
		return
	end
	
	normalMovement(p)
end)

rawset(_G, "NTOPP_Init", function()
	local t = {}
	
	t.movespeed = 8*FU
	t.forcedstate = nil
	
	return t
end)
rawset(_G, "NTOPP_IsValid_1", function(p)
	return (p and p.valid and p.mo and p.mo.valid and p.playerstate ~= PST_DEAD and isPTSkin(p.mo.skin))
end)
rawset(_G, "NTOPP_Check", function(p)
	return (p and p.valid and p.mo and p.mo.valid and isPTSkin(p.mo.skin) and p.pvars and p.fsm)
end)
rawset(_G, "NTOPP_ReturnControlsAngle", function(player)
	return player.cmd.angleturn<<16 + R_PointToAngle2(0, 0, player.cmd.forwardmove*FRACUNIT, -player.cmd.sidemove*FRACUNIT)
end)

rawset(_G, "GetMachSpeedEnum", function(movespeed)
	if movespeed <= ntopp_v2.machs[2] then return ntopp_v2.enums.MACH1 end
	if movespeed >= ntopp_v2.machs[3] then return ntopp_v2.enums.MACH3 end
	
	return ntopp_v2.enums.MACH2
end)

//code by luigi
//LUIGI BUDD WAS HERE!!
//fix whatever nick was doing
rawset(_G, "SpawnGrabbedObject",function(tm,source)
	if not (tm and tm.valid and source and source.valid) then return end
	local ragdoll = P_SpawnMobjFromMobj(tm,0,0,tm.height,MT_GRABBEDMOBJ)
	tm.tics = -1
	ragdoll.sprite = tm.sprite
	ragdoll.color = tm.color
	ragdoll.angle = source.angle
	ragdoll.frame = tm.frame
	ragdoll.height = tm.height
	ragdoll.radius = tm.radius
	ragdoll.scale = tm.scale
	ragdoll.timealive = 1
	ragdoll.target = source
	ragdoll.flags = MF_NOCLIP|MF_NOCLIPHEIGHT|MF_NOGRAVITY|MF_NOCLIPTHING
	ragdoll.ragdoll = true
	ragdoll.tics = -1
	ragdoll.savedtype = tm.type
	P_KillMobj(tm,source,source)
	if tm.valid then
		P_RemoveMobj(tm)
	end

	return ragdoll
end)

rawset(_G, 'stepframes', function(p)
	if p.mo.state == S_PLAY_WALK
		if (p.mo.frame == D or p.mo.frame == I)
			return true
		else
			return false
		end
	else
		return (not (leveltime % 2))
	end
end)

rawset(_G, "P_CreateRing", function(p)
	local ring = P_SpawnMobj(p.mo.x,p.mo.y,p.mo.z,MT_THOK)
	ring.state = S_MACH4RING
	ring.fuse = 999
	ring.tics = 20
	ring.angle = p.drawangle+ANGLE_90
	ring.scale = p.mo.scale-FRACUNIT/2
	ring.destscale = p.mo.scale*2
	ring.colorized = true
	ring.color = SKINCOLOR_WHITE
	if (p.mo.eflags & MFE_VERTICALFLIP)
		ring.flags2 = $|MF2_OBJECTFLIP
		ring.eflags = $|MFE_VERTICALFLIP
	end
end)

rawset(_G, "PT_Approach", function(argument0, argument1, argument2) -- i love stealing code from piz towe -Pacola
	local num = argument0
	if (num < argument1)
        num = $+argument2
        if (num > argument1)
            return argument1
		end
    else
        num = $-argument2
        if (num < argument1)
            return argument1
		end
    end
    return num
end)