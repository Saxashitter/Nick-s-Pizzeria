-- Callbacks work sort of like hooks. Returning does nothing for most of them.

PTV3.callbacks = {
	['PlayerThink'] = {},
	-- Use this to execute thinkers in PT safely.

	['TeleportPlayer'] = {},
	-- Usually used to teleport the player to a secret, or the end.

	['NewLap'] = {},
	-- Self-explanatory. Executes all functions here after new lap.
	
	['PizzaTime'] = {},
	-- Triggers on Pizza Time.
	
	['VariableInit'] = {},
	-- Runs when all variables get initalized, except the player for reasons.
	
	['PlayerInit'] = {},
	-- Runs when the player gets initalized.

	['FoundSecret'] = {},
	-- Runs when the player finds a secret.
	
	['ExitSecret'] = {},
	-- Vice-versa to above.

	['OvertimeStart'] = {},
	-- When Overtime starts, if it could atleast.

	['GameEnd'] = {}
	-- When the game ends.
}

setmetatable(PTV3.callbacks, {__call = function(self, name, ...)
	if not PTV3.callbacks[name] then return end
	local value = nil

	for _,func in ipairs(PTV3.callbacks[name]) do
		local temp = func(...)
		if temp ~= nil then value = temp end
	end

	return temp
end})

function PTV3:insertCallback(name, func)
	if not name or not PTV3.callbacks[name] then
		print('Callback name invalid. Please check TableManager.lua to see valid callbacks.')
		return
	end

	table.insert(PTV3.callbacks[name], func)
end