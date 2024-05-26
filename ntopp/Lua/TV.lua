rawset(_G, "tv", {})

tv.states = {
	PEP_ = {
		Idle = {"IDLE", 14, 2},
		IdleAnim1 = {"IDA1", 27, 2},
		IdleAnim2 = {"IDA2", 31, 2},
		Mach3 = {"MAC3", 3, 2},
		Mach4 = {"MAC4", 3, 2},
		Panic = {"PANC", 8, 2},
		Hurt = {"HURT", 11, 2},
		Combo = {"COMB", 9, 2},
		Heat = {"HEAT", 18, 2},
		Fireass = {"FASS", 2, 1}
	},
	NOS_ = {
		Idle = {"IDLE", 3, 2, 14*2},
		IdleAnim1 = {"IDA1", 22, 2},
		IdleAnim2 = {"IDA2", 22, 2},
		Mach3 = {"MAC3", 3, 2},
		Mach4 = {"MAC4", 3, 2},
		Panic = {"PANC", 17, 2},
		Hurt = {"HURT", 6, 2},
		Combo = {"COMB", 20, 2},
		Heat = {"HEAT", 8, 2},
		Fireass = {"FASS", 2, 1}
	},
	GUS_ = {
		Idle = {"IDLE", 14, 2},
		Panic = {"PANC", 8, 2},
		Hurt = {"HURT", 8, 2}
	}
}

function tv.states.PEP_.Idle.onFinish(p)
	tv.changeState(p, "IdleAnim"..(P_RandomKey(2)+1), true)
end
function tv.states.PEP_.IdleAnim1.onFinish(p)
	tv.changeState(p, "Idle", true)
end
function tv.states.PEP_.IdleAnim2.onFinish(p)
	tv.changeState(p, "Idle", true)
end
function tv.states.NOS_.Idle.onFinish(p)
	tv.changeState(p, "IdleAnim"..(P_RandomKey(2)+1), true)
end
function tv.states.NOS_.IdleAnim1.onFinish(p)
	tv.changeState(p, "Idle", true)
end
function tv.states.NOS_.IdleAnim2.onFinish(p)
	tv.changeState(p, "Idle", true)
end

tv.skinRefs = {
	npeppino = "PEP_",
	nthe_noise = "NOS_",
	ngustavo = "GUS_"
}

local function PizzaTimeFunc(player)
	return ((player.ptsp and player.ptsp.pizzatime)
		or (PTSR and PTSR.pizzatime)
		or (PizzaTime and PizzaTime.sync and PizzaTime.sync.PizzaTime)
		or (PTV3 and PTV3.pizzatime))
end

local function isCurState(p, state)
	if p.pvars.tv.anim == state then return true end
	if p.pvars.tv.trans and p.pvars.tv.trans.state == state then return true end
	return false
end

tv.changeState = function(p, state, skiptrans)
	if not NTOPP_Check(p) then return end
	if not p.pvars.tv then return end
	local sr = tv.skinRefs[p.mo.skin] or "PEP_"
	if not tv.states[sr][state] then return end

	if skiptrans then
		p.pvars.tv.trans = nil
		p.pvars.tv.anim = state
		p.pvars.tv.starttime = leveltime
	else
		if p.pvars.tv.trans then
			p.pvars.tv.anim = p.pvars.tv.trans.state
			p.pvars.tv.starttime = leveltime
		end
		p.pvars.tv.trans = {
			state = state,
			starttime = leveltime
		}
	end
end

addHook('MapChange', function()
	for player in players.iterate do
		if player.pvars
		and player.pvars.tv then
			player.pvars.tv = nil
		end
	end
end)

addHook("PlayerThink", function(p)
	if not NTOPP_Check(p) then return end
	if not p.pvars.tv then return end
	local state = p.pvars.forcedstate

	if (state == S_PEPPINO_FIREASS
	or state == S_PEPPINO_FIREASSGRND) then
		if not isCurState(p, "Fireass") then
			tv.changeState(p, "Fireass", true)
		end
	elseif P_PlayerInPain(p) or not (p.mo.health) then
		if not isCurState(p, "Hurt") then
			tv.changeState(p, "Hurt")
		end
	elseif (state == S_PEPPINO_MACH4) then
		if not isCurState(p, "Mach4") then
			tv.changeState(p, "Mach4")
		end
	elseif (state == S_PEPPINO_MACH3
	or state == S_PEPPINO_MACH3HIT
	or state == S_PEPPINO_MACH3JUMP) then
		if not isCurState(p, "Mach3") then
			tv.changeState(p, "Mach3")
		end
	elseif p.ptv3 and p.ptv3.combo then
		if not isCurState(p, "Combo") then
			tv.changeState(p, "Combo")
		end
	elseif p.ptv3 and p.ptv3.extreme then
		if not isCurState(p, "Heat") then
			tv.changeState(p, "Heat")
		end
	elseif PizzaTimeFunc(p) then
		if not isCurState(p, "Panic") then
			tv.changeState(p, "Panic")
		end
	elseif not isCurState(p, "Idle")
	and not isCurState(p, "IdleAnim1")
	and not isCurState(p, "IdleAnim2") then
		tv.changeState(p, "Idle")
	end
end)

addHook("ThinkFrame", do
	for p in players.iterate do
		if not NTOPP_Check(p) then return end
		if not p.pvars.tv then p.pvars.tv = {
			starttime = leveltime,
			anim = "Idle"
		} end
	
		local sr = tv.skinRefs[p.mo.skin] or "PEP_"
		local anim = tv.states[sr][p.pvars.tv.anim]
		local time = leveltime-p.pvars.tv.starttime
		local length = anim[2]*anim[3]
		if anim[4] then length = anim[4] end
	
		if time > anim[2]*anim[3] and anim.onFinish then
			anim.onFinish(p)
		end
		if p.pvars.tv.trans
		and leveltime-p.pvars.tv.trans.starttime > 5*2 then
			tv.changeState(p, p.pvars.tv.trans.state, true)
		end
	end
end)

local function draw_tv(v, p)
	if not NTOPP_Check(p) then return end
	if not p.pvars.tv then return end

	local sr = tv.skinRefs[p.mo.skin] or "PEP_"
	//print(sr, p.mo.skin)
	local anim = tv.states[sr][p.pvars.tv.anim]
	local time = leveltime-p.pvars.tv.starttime

	local frame = (time % (anim[2]*anim[3])) / anim[3]
	local patch = v.cachePatch(sr..anim[1].."_"..tostring(frame))
	
	local x,y,s = 230*FU, -24*FU, FU/3

	v.drawScaled(x,y,s, v.cachePatch("GLOB_BG"), V_SNAPTOTOP|V_SNAPTORIGHT)
	v.drawScaled(x,y,s, patch, V_SNAPTOTOP|V_SNAPTORIGHT, v.getColormap(p.mo.skin, p.mo.color))

	if p.pvars.tv.trans then
		local frame = ((leveltime-p.pvars.tv.trans.starttime) % (5*2)) / 2
		local patch = v.cachePatch("GLOB_WHNO_"..frame)

		v.drawScaled(x,y,s, patch, V_SNAPTOTOP|V_SNAPTORIGHT)
	end
end

customhud.SetupItem("NTOPP_TV", "ntopp", draw_tv, "game", 0)