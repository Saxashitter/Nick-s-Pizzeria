-- Hudobjects framework by CobaltBW
-- To use: Make sure all this lump is executed first.
-- Then create an additional lump which tables to the "hudobjs" master table. ie: table.insert(hudobjs, mytable)
-- The metatable shown below lists all of the variables you can use and what their effects will be.

if hudobjs
	return
end

local ts = tostring
local mt, MT, T
-- Child metatable
local toString = function(tbl) -- Get child table name
	if tbl == mt
		return "hudobj metatable"
	end
	return "hudobj ("..tostring(tbl.index)..")"
end

local getDefaultIndex = function(tbl, key) -- Return default index from child metatable
	if mt == tbl
		return nil
	end
	return mt[key]
end

mt = {
	-- Note: these are required only for this metatable. The variables you need to create for your own hudobjs are just below.
	__tostring = toString,
	__index = getDefaultIndex,
	metatable = true,
	
	-- Object properties. These have direct effects on how an object is drawn, but you can also define additional variables and modify them with your own functions.
	func = nil, -- function(v, player, cam, obj) run on each frame that this object is active. Return "true" to destroy the object.
	drawtype = "string", -- Valid arguments: string, nametag, graphic, sprite, sprite2
	string = nil, -- drawString text / patch string goes here.
	flags = 0, -- Video flags to use for drawing.
	color = 0, -- nametag argument / color to use for colormapping patches
	color2 = 0, -- nametag argument
	skin = 0, -- sprite2 argument
	super = false, -- sprite2 argument
	align = "fixed", -- drawString argument
	-- Animation variables
	tics = 0, -- Counts upward. If animspeed is non-zero, this moves to the next frame and resets tics to 0 when tics == animspeed.
	frame = 0, -- sprite frame to use for patch retrieval
	animlength = 0, -- length of sprite animation
	animspeed = 0,
	animloop = true, -- If false, object is removed at the end of animation.
	angle = 0, -- Angle sprite to use (NOT in degrees!)
	rollangle = 0,
	fuse = -1, -- Destroys object when 0 is reached
	
	-- ATTENTION: The rest of these variables are fixed values!! Make sure you are multiplying by FRACUNIT!
	-- Draw coordinates
	x = 0,
	y = 0,
	
	-- Object speed. x and y will increment by the values entered here.
	momx = 0,
	momy = 0,
	
	-- Acceleration rate. momx and momy will increment by the values entered here.
	accelx = 0,
	accely = 0,
	
	-- friction variables have a multiplier effect on object speed. xfriction and yfriction stack with standard friction.
	friction = FRACUNIT,
	xfriction = FRACUNIT,
	yfriction = FRACUNIT,
	
	-- scale affects image size. hscale and vscale stack with standard scale.
	scale = FRACUNIT,
	hscale = FRACUNIT,
	vscale = FRACUNIT,
}
setmetatable(mt, mt)

-- Parent metatable
local toString = function(tbl) -- Get parent table name
	if tbl == MT
		return "hudobjs master metatable"
	else
		return "hudobjs master table"
	end
end

local getTable = function(t, key)
	return rawget(t, key)
end

local setTable = function(t, key, hudobj) -- Construct child table

	-- Are we clearing this table entry?
	local old = rawget(t, key)
	if hudobj == nil and old != nil
		rawset(t, key, hudobj)
		print("Unset "..tostring(old))
		return
	end
	
	-- Make sure we're actually setting a table
	assert(type(hudobj) == "table", "Got "..type(hudobj).." value for hudobj ID "..key.." (expected table)")

	if hudobj.index == nil
		hudobj.index = tostring(hudobj)
	end
	-- Set metatable
	if getmetatable(hudobj) != mt
		setmetatable(hudobj, mt)
	end
	
	-- Finally, set the table to our master table
	rawset(t, key, hudobj)
	print("Set "..ts(hudobj))
end

-- Setup parent metatable
MT = {
	__index = getTable,
	__newindex = setTable,
	__usedindex = setTable,
	__tostring = toString,
	__metatable = true
}
print("Creating skinvars metatable: "..ts(MT))
setmetatable(MT, MT)

-- Setup parent table
T = {}
setmetatable(T, MT)
print("Set "..ts(T).." to "..ts(MT))

-- Set to global
rawset(_G, "hudobjs", T)

-- Draw HUD
hud.add(function(v, player, cam)
	local n = 1
	while n <= #hudobjs do
		assert(n % FRACUNIT, "Overflow prevented in hudobjs object creation")
		local obj = hudobjs[n]
		if getmetatable(obj) == nil
			setmetatable(obj, mt)
		end
		-- Do timers
		obj.tics = $ + 1
		obj.fuse = max(-1, $ - 1)
		if obj.fuse == 0
			table.remove(hudobjs, n)
			continue			
		end
		-- Do animation
		if obj.animspeed > 0 
			if obj.tics >= obj.animspeed
				obj.frame = ($ + 1) % (obj.animlength + 1)
			end
			if not(obj.animloop) and obj.frame == 0
				table.remove(hudobjs, n)
				continue
			end
		end
		-- Do function
		if obj.func and obj.func(v, player, cam, obj) == true
			table.remove(hudobjs, n)
			continue
		end
		n = $ + 1
		
		-- Apply movement
		local xfriction = FixedMul(obj.friction, obj.xfriction)
		local yfriction = FixedMul(obj.friction, obj.yfriction)
		obj.momx = FixedMul($ + obj.accelx, xfriction)
		obj.momy = FixedMul($ + obj.accely, yfriction)
		obj.x = $ + obj.momx
		obj.y = $ + obj.momy
		
		-- Draw items
		if obj.string == nil
			continue
		end
		if obj.drawtype == "string"
			v.drawString(obj.x, obj.y, obj.string, obj.flags, obj.align)
		elseif obj.drawtype == "nametag"
			v.drawScaledNameTag(obj.x, obj.y, obj.string, obj.flags, obj.scale, obj.color, obj.color2)
		else
			local patch
			if obj.drawtype == "graphic"
				patch = v.cachePatch(obj.string)
			elseif obj.drawtype == "sprite"
				patch = v.getSpritePatch(obj.string, obj.frame, obj.angle, obj.rollangle)
			elseif obj.drawtype == "sprite2"
				patch = v.getSprite2Patch(obj.skin, obj.string, obj.super, obj.frame, obj.angle, obj.rollangle)
			end
			local colormap = v.getColormap(obj.skin, obj.color)
			local hscale = FixedMul(obj.scale, obj.hscale)
			local vscale = FixedMul(obj.scale, obj.vscale)
			v.drawStretched(obj.x, obj.y, hscale, vscale, patch, obj.flags, colormap)
		end
	end
end)