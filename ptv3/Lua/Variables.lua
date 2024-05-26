-- Command Variables and Commands

CV_PTV3['time'] = CV_RegisterVar({
	name = "PTV3_time",
	defaultvalue = 300,
	flags = CV_NETVAR,
	PossibleValue = CV_Unsigned
})
CV_PTV3['max_laps'] = CV_RegisterVar({
	name = "PTV3_laps",
	defaultvalue = 4,
	flags = CV_NETVAR,
	PossibleValue = CV_Unsigned
})
CV_PTV3['max_elaps'] = CV_RegisterVar({
	name = "PTV3_extreme_laps",
	defaultvalue = 5,
	flags = CV_NETVAR,
	PossibleValue = CV_Unsigned
})
CV_PTV3['max_erings'] = CV_RegisterVar({
	name = "PTV3_max_erings",
	defaultvalue = 60,
	flags = CV_NETVAR,
	PossibleValue = CV_Unsigned
})
CV_PTV3['ai_pizzaface'] = CV_RegisterVar({
	name = "PTV3_ai_pizzaface",
	defaultvalue = "No",
	flags = CV_NETVAR,
	PossibleValue = CV_YesNo
})
CV_PTV3['time_for_pizzaface_ai'] = CV_RegisterVar({
	name = "PTV3_time_for_pizzaface_ai",
	defaultvalue = 120+30,
	flags = CV_NETVAR,
})
CV_PTV3['time_for_pizzaface_player'] = CV_RegisterVar({
	name = "PTV3_time_for_pizzaface_player",
	defaultvalue = 10,
	flags = CV_NETVAR,
})

local function findPlayer(name)
	local player
	local namenum = tonumber(name)
	for p in players.iterate do
		if p.name:lower() == tostring(name):lower() 
		or (namenum ~= nil
		and namenum >= 0
		and namenum < 31
		and #p == namenum) then
			player = p
			break
		end
	end

	return player
end

local swap_mode_requests = {}

COM_AddCommand('PTV3_swaprequest', function(p, name)
	if name == nil
	or not PTV3:isPTV3() then
		CONS_Printf(p, "Usage: ptv3_swaprequest playername")
		CONS_Printf(p, "Sends a Swap Mode request to a player, only works in PTV3")
		return
	end

	local player = findPlayer(name)

	if not player then
		CONS_Printf(p, "Invalid player, try again!")
		CONS_Printf(p, "Usage: ptv3_swaprequest playername")
		CONS_Printf(p, "Sends a Swap Mode request to a player, only works in PTV3")
		return
	end
	if player == p then
		CONS_Printf(p, "Invalid player, try again!")
		CONS_Printf(p, "Usage: ptv3_swaprequest playername")
		CONS_Printf(p, "Sends a Swap Mode request to a player, only works in PTV3")
		return
	end

	if not p.ptv3 then return end
	if not player.ptv3 then return end

	if not swap_mode_requests[p] then
		swap_mode_requests[p] = {}
	end
	if not swap_mode_requests[player] then
		swap_mode_requests[player] = {}
	end

	if player.ptv3.isSwap then
		CONS_Printf(p, "Player is in Swap Mode with another already, try again!")
		return
	end

	if swap_mode_requests[p][player] then
		swap_mode_requests[p][player] = nil
		if PTV3:initSwapMode(player, p) then
			CONS_Printf(player, "Success! Fire Normal to switch spots.")
			CONS_Printf(p, "Success! Fire Normal to switch spots.")
		else
			CONS_Printf(p, "Didn't work, lazy to list the reason.")
			CONS_Printf(player, "Didn't work, lazy to list the reason.")
		end
		return
	end

	swap_mode_requests[player][p] = true
	CONS_Printf(player, p.name.." wants to team up with you. (Swap Mode)")
	CONS_Printf(player, "To accept, type \"ptv3_swaprequest "..tostring(#p).."\"!")

	CONS_Printf(p, "Invite sent to "..player.name.." successfully.")
end)
COM_AddCommand('PTV3_pizzatimenow', function(p)
	if not PTV3:isPTV3() then return end
	if not (IsPlayerAdmin(p) or p == server) then return end
	
	PTV3:startPizzaTime(p)
end)
COM_AddCommand('PTV3_endgame', function(p)
	if not PTV3:isPTV3() then return end

	PTV3:endGame()
end, COM_ADMIN)

-- vars
local synced_variables = {
	['pizzatime'] = false,
	['total_laps'] = 1,
	['spawn'] = {x=0,y=0,z=0},
	['endpos'] = {x=0,y=0,z=0,a=0},
	['spawnsector'] = false,
	['game_ended'] = false,
	['extreme'] = false,
	['skybox'] = false,
	['pizzaface'] = false,
	['snick'] = false,
	['overtime'] = false,
	['time'] = 600*TICRATE,
	['pftime'] = 30*TICRATE,
	['overtime_time'] = 120*TICRATE,
	['secrets'] = {},
	['game_over'] = -1,
	['hud_pt'] = -1,
	['matchLog'] = {}
}

local unsynced_variables = {
	['hud_lap'] = -1,
	['hud_secret'] = -1
}

-- functions

local function spawnSector(t)
	if t.type ~= 1 then return end

	PTV3.spawn = {
		x = t.x*FU,
		y = t.y*FU,
		z = P_FloorzAtPos(t.x*FU,t.y*FU,0,64*FU) + (t.z*FU)
	}
end
local function endSector(t)
	if t.type ~= 501 then return end

	PTV3.endpos = {
		x = t.x*FU,
		y = t.y*FU,
		z = P_FloorzAtPos(t.x*FU, t.y*FU, 0,64*FU) + t.z*FU,
		a = t.angle*ANG1
	}
end

local function cloneTable(table)
	if type(table) ~= "table" then
		return table
	end

	local clone = {}

	for k,v in pairs(table) do
		if type(table) == "table" then
			clone[k] = cloneTable(v)
			continue
		end

		clone[k] = v
	end

	return clone
end

function PTV3:player(player)
	local isSwap = player.ptv3 and player.ptv3.isSwap
	local swapModeFollower = player.ptv3 and player.ptv3.swapModeFollower

	player.ptv3 = {
		["buttons"] = player.cmd.buttons,
		['laps'] = 1,
		['pizzaface'] = false,
		['specforce'] = false,
		['extreme'] = false,
		['fake_exit'] = false,
		['insecret'] = 0,
		['secretsfound'] = 0,
		['secret_tptoend'] = false,
		['combo'] = 0,
		['combo_pos'] = 0,
		['combo_display'] = 0,
		['combo_start_time'] = 0,
		['combo_offtime'] = false,
		['combo_rank'] = false,
		['lap_time'] = -1,
		['curItem'] = false,
		
		['banana'] = 0,
		['banana_angle'] = 0,
		['banana_speed'] = 0,
		
		['savedData'] = {},
		
		['rank'] = 1,
		['rank_changetime'] = -1
	}
	
	if self.pizzatime then
		player.ptv3.specforce = true
	end
	player.score = 0
	player.ptv3.swapModeFollower = swapModeFollower
	player.ptv3.isSwap = isSwap
	P_ResetPlayer(player)

	PTV3.callbacks('PlayerInit', player)
end

local has_inited = false
function PTV3:init()
	if has_inited then return end
	for _,i in pairs(synced_variables) do
		self[_] = cloneTable(i)
	end

	for _,i in pairs(CV_PTV3) do
		self[_] = i.value
	end

	for _,i in pairs(unsynced_variables) do
		self[_] = cloneTable(i)
	end

	for player in players.iterate do
		player.ptv3 = nil
	end
	
	if PTV3.callbacks then --ahaaaa got cha now error
		PTV3.callbacks('VariableInit')
	end
	has_inited = true
end

PTV3:init()

-- hooks

addHook('NetVars', function(n)
	for _,i in pairs(synced_variables) do
		PTV3[_] = n($)
	end
	for _,i in pairs(CV_PTV3) do
		PTV3[_] = n($)
	end
	swap_mode_requests = n($)
end)

addHook('MapChange', function()
	has_inited = false
	PTV3:init()
end)

addHook('MapLoad', function()
	PTV3:init()
	-- one more for safety
	for p in players.iterate do
		p.ptv3 = nil
	end

	if not PTV3:isPTV3() then 
		hud.enable('lives')
		return
	end
	hud.disable('lives')

	for thing in mapthings.iterate do
		spawnSector(thing)
		endSector(thing)
	end

	local alive, pizzafaces, total = PTV3.playerCount and PTV3:playerCount()
	PTV3.time = CV_PTV3['time'].value*TICRATE
	PTV3.pftime = 30*TICRATE

	if gametype == GT_PTV3DM then
		PTV3:pizzafaceSpawn()
		PTV3:snickSpawn()
	end
end)