rawset(_G, 'fsm', {})
rawset(_G, 'fsmstates', {})

fsmstates[ntopp_v2.enums.BASE] = {}
fsmstates[ntopp_v2.enums.MACH1] = {}
fsmstates[ntopp_v2.enums.MACH2] = {}
fsmstates[ntopp_v2.enums.MACH3] = {}
fsmstates[ntopp_v2.enums.SKID] = {}
fsmstates[ntopp_v2.enums.DRIFT] = {}
fsmstates[ntopp_v2.enums.GRAB] = {}
fsmstates[ntopp_v2.enums.BASE_GRABBEDENEMY] = {}
fsmstates[ntopp_v2.enums.GRAB_KILLENEMY] = {}
fsmstates[ntopp_v2.enums.CROUCH] = {}
fsmstates[ntopp_v2.enums.ROLL] = {}
fsmstates[ntopp_v2.enums.DIVE] = {}
fsmstates[ntopp_v2.enums.BELLYSLIDE] = {}
fsmstates[ntopp_v2.enums.SUPERJUMPSTART] = {}
fsmstates[ntopp_v2.enums.SUPERJUMP] = {}
fsmstates[ntopp_v2.enums.SUPERJUMPCANCEL] = {}
fsmstates[ntopp_v2.enums.PAIN] = {}
fsmstates[ntopp_v2.enums.WALLCLIMB] = {}
fsmstates[ntopp_v2.enums.BODYSLAM] = {}
fsmstates[ntopp_v2.enums.UPPERCUT] = {}
fsmstates[ntopp_v2.enums.TAUNT] = {}
fsmstates[ntopp_v2.enums.GRABBED] = {}
fsmstates[ntopp_v2.enums.PARRY] = {}
fsmstates[ntopp_v2.enums.STUN] = {}
fsmstates[ntopp_v2.enums.PILEDRIVER] = {}
fsmstates[ntopp_v2.enums.BREAKDANCESTART] = {}
fsmstates[ntopp_v2.enums.BREAKDANCELAUNCH] = {}
fsmstates[ntopp_v2.enums.BREAKDANCE] = {}
fsmstates[ntopp_v2.enums.SUPERTAUNT] = {}
fsmstates[ntopp_v2.enums.SWINGDING] = {}
fsmstates[ntopp_v2.enums.FIREASS] = {}

fsm.getState = function(skin, state)
	if not fsmstates[state] then
		return
	end

	local skin = fsmstates[state][skin] and skin or "npeppino"
	
	return fsmstates[state][skin]
end

fsm.Init = function(player)
	player.fsm = {}
	player.fsm.state = 1
	fsm.ChangeState(player, 1)
end

fsm.ChangeState = function(player, state)
	if not (player.mo) then return end
	local old_state = fsm.getState(player.mo.skin, player.fsm.state)
	local new_state = fsm.getState(player.mo.skin, state)
	
	player.ntoppv2_diagonalspring = false
	
	if (old_state and old_state.exit) then
		old_state:exit(player, state) // so we can reference the new state upon exit, useful for transitioning n such
	end
	if (new_state and new_state.enter) then
		new_state:enter(player, player.fsm.state)
	end
	
	if (new_state) then
		player.fsm.state = state
	end	
end

local function canRun(player)
	if not (NTOPP_IsValid_1(player)) then
		if (player.fsm or player.pvars) then
			if player.fsm then
				player.fsm = nil
			end
			if player.pvars and player.pvars.ntoppv2_grabbed then
				if player.pvars.ntoppv2_grabbed.valid and player.pvars.ntoppv2_grabbed.type ~= MT_PLAYER then
					player.pvars.ntoppv2_grabbed.ntoppv2_grabbed = nil
					player.pvars.ntoppv2_grabbed = nil
				end
			end
			if player.mo and player.ntoppv2_3dish then
				player.mo.frame = $ & ~FF_PAPERSPRITE
				player.ntoppv2_3dish = false
			end
			player.pvars = nil
		end
		return false
	end
	return true
end

addHook('PlayerThink', function(player)
	if not canRun(player) then return end
	if not (player.pvars) then
		player.pvars = NTOPP_Init()
	end
	if (player.fsm == nil) then
		fsm.Init(player)
	end

	local state = fsm.getState(player.mo.skin, player.fsm.state)

	if (state
	and state.playerthink) then
		state:playerthink(player)
	end
	
	player.pvars.prevkeys = player.cmd.buttons
	
	if player.ntoppv2_3dish then
		player.mo.frame = $|FF_PAPERSPRITE
	end
	
	if (player.pvars.forcedstate 
	and player.mo.state ~= player.pvars.forcedstate
	and (
		(not (states[player.mo.state].frame & FF_SPR2ENDSTATE) and
		states[player.mo.state].nextstate ~= player.pvars.forcedstate
	)
	or (
		states[player.mo.state].frame & FF_SPR2ENDSTATE
		and states[player.mo.state].var1 ~= player.pvars.forcedstate
	))) then
	//phew, thats alotta checks
		player.mo.state = player.pvars.forcedstate // useful to force animations
	end
end)

addHook('ThinkFrame', function()
	for player in players.iterate do
		if not canRun(player) then continue end

		if (player.pvars.curstate ~= player.pvars.state) then
			player.pvars.laststate = player.pvars.curstate
			player.pvars.curstate = player.mo.state
		end

		if player.ntoppv2_gravitydisabled and P_IsObjectOnGround(player.mo) then
			player.ntoppv2_gravitydisabled = false
		end
		if player.ntoppv2_diagonalspring and P_IsObjectOnGround(player.mo) then
			player.ntoppv2_diagonalspring = false
		end
		if player.pvars.jumpheight ~= nil and P_IsObjectOnGround(player.mo) then
			player.pvars.jumpheight = nil
		end
		if player.mo.skin == "nthe_noise" and not player.pvars.cancrusher and P_IsObjectOnGround(player.mo) then
			player.pvars.cancrusher = true
		end
		local state = fsm.getState(player.mo.skin, player.fsm.state)

		if (state
		and state.think) then
			state:think(player)
		end
	end
end)