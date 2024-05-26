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