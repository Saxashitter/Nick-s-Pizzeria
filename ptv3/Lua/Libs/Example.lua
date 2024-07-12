-- This script demonstrates some ways on how to use this system to produce dynamic hud objects.
assert(hudobjs != nil, "Could not find hudobjs table!")

local n = 1
local function random()
	n = ($ * 3 + 1) % 65535
	return n
end

-- Sparkle spawn function
local function spawnSparkle(v)
	local _momx = random() % 8 - 3
	local _momy = random() % 8 - 3
	local _scale = (random() % 8 + 1) * FRACUNIT / 8
	table.insert(hudobjs, {
		drawtype = "sprite",
		string = "SPRK",
		frame = 1,
		animlength = 8,
		animspeed = 4,
		animloop = false,
		flags = V_SNAPTOTOP|V_SNAPTOLEFT|V_PERPLAYER,
		x = FRACUNIT * 112,
		y = FRACUNIT * 58,
		momy = _momx * FRACUNIT,
		momx = _momy * FRACUNIT,
		friction = FRACUNIT * 7 / 8,
		scale = _scale
	})
end

-- Ring spawn function
local function spawnRing(v)
	local _momx = random() % 8 - 3
	local _scale = (random() % 8 + 1) * FRACUNIT / 8
	table.insert(hudobjs, {
		drawtype = "sprite",
		string = "RING",
		animlength = 23,
		animspeed = 1,
		animloop = true,
		accely = FRACUNIT/2,
		fuse = TICRATE * 3,
		flags = V_SNAPTOTOP|V_SNAPTOLEFT|V_PERPLAYER,
		x = FRACUNIT * 112,
		y = FRACUNIT * 58,
		momy = -FRACUNIT * 3,
		momx = FRACUNIT * _momx,
		scale = _scale
	})
end

local function spawnLife(v, player)
	local _momx = random() % 8 - 3
	table.insert(hudobjs, {
		drawtype = "sprite2",
		skin = player.skin,
		string = "LIFE",
		color = player.skincolor,
		accely = FRACUNIT/2,
		fuse = 40,
		flags = V_SNAPTOBOTTOM|V_SNAPTOLEFT|V_PERPLAYER,
		x = FRACUNIT * 24,
		y = FRACUNIT * 192,
		momy = -FRACUNIT * 3,
		momx = FRACUNIT * _momx,
		scale = _scale
	})
end

-- A master HUD object, for spawning additional HUD objects
table.insert(hudobjs, {
-- 	drawtype = "nametag",
-- 	scale = FRACUNIT/4,
-- 	color = SKINCOLOR_BLUE,
-- 	color2 = SKINCOLOR_YELLOW,
	string = "error: no function",
	flags = V_SNAPTOTOP|V_SNAPTORIGHT,
	align = "right",
	x = 320,
	player = nil,
	rings = nil,
	func = function(v, player, cam, obj)
		if player != obj.player
			obj.player = player
			obj.rings = player.rings
		end
		if obj.player == nil
			return
		end
		if obj.rings > obj.player.rings
			obj.rings = max(obj.player.rings, ($ + obj.player.rings) / 2 - 1)
			spawnRing(v) -- Spawn a sparkle graphic
		elseif obj.rings < obj.player.rings
			obj.rings =  min(obj.player.rings, ($ + obj.player.rings) / 2 + 1)
			spawnSparkle(v) -- Spawn a ring graphic
		end
		if player.playerstate == PST_DEAD and obj.playerstate != PST_DEAD
			spawnLife(v, player)
		end
		obj.playerstate = player.playerstate
		
		obj.string = "#hudobjs "..tostring(#hudobjs)
	end,
})

-- For debugging
COM_AddCommand("listhud", function(player, arg)
	print(hudobjs)
	-- Retrieve hudobjs 
	for n,m in pairs(hudobjs) do
		print(	"["..n.."] "..tostring(m.drawtype)..' '..tostring(m.string).."\x83")
		if arg != nil
			for nn,mm in pairs(m)
				print(nn..": "..tostring(mm))
			end
		end
	end
end, COM_LOCAL)

COM_AddCommand("clearhud", do
	while #hudobjs > 0 do
		table.remove(hudobjs,1)
	end
end, COM_LOCAL)