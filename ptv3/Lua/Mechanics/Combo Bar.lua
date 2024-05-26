local MAX_COMBO_TIME = 10*FU

local ranks = {
	{
		level = 1
	},
	{
		level = 5
	},
	{
		level = 10
	},
	{
		level = 15
	},
	{
		level = 20
	},
	{
		level = 25
	},
	{
		level = 30
	},
	{
		level = 35
	},
	{
		level = 40
	},
	{
		level = 45
	},
	{
		level = 50
	},
	{
		level = 55
	},
	{
		level = 60
	},
	{
		level = 65
	},
	{
		level = 70
	},
	{
		level = 75
	},
}

addHook('MobjDamage', function(t,i,s)
	if not PTV3:isPTV3() then return end
	if not (t.player) then return end
	local p = t.player

	if not (p.ptv3.combo_pos) then return end

	if p.ptv3.combo_pos > MAX_COMBO_TIME/2 then
		p.ptv3.combo_pos = MAX_COMBO_TIME/2
	else
		p.ptv3.combo_pos = 0
	end
end, MT_PLAYER)

local function increaseCombo(p, type, increase)
	if type == 1 then
		p.ptv3.combo_pos = MAX_COMBO_TIME
		if not (p.ptv3.combo) then
			p.ptv3.combo_start_time = leveltime
		end
		p.ptv3.combo = $+1
	elseif type == 2 then
		p.ptv3.combo_pos = min($+increase, MAX_COMBO_TIME)
	elseif type == 3 then
		p.ptv3.combo_pos = MAX_COMBO_TIME
	end
end

addHook('MobjDamage', function(t,i,s)
	if not PTV3:isPTV3() then return end
	if not (s and s.type == MT_PLAYER) then return end
	if not (s.player.ptv3 and s.player.ptv3.combo) then return end
	if not (t.flags & MF_ENEMY) then return end
	
	increaseCombo(s.player, 3)
end)

addHook('MobjDeath', function(t,i,s)
	if not PTV3:isPTV3() then return end
	if not (s and s.type == MT_PLAYER) then return end
	
	if t.flags & MF_ENEMY then
		increaseCombo(s.player, 1)
	elseif t.flags & MF_MONITOR
		increaseCombo(s.player, 3)
	else
		increaseCombo(s.player, 2, MAX_COMBO_TIME/5)
	end
end)

PTV3:insertCallback("PlayerThink", function(p)
	if p.ptv3.combo_offtime then
		local time = min(((leveltime - p.ptv3.combo_offtime)*(FU*2))/35, FU+1)
		if time > FU then
			p.ptv3.combo_offtime = nil
		end
	end
	if not (p.ptv3.combo) then return end

	if not (p.exiting) then
		p.ptv3.combo_pos = $-(FU/TICRATE)
	end

	p.ptv3.combo_display = $ + ((p.ptv3.combo_pos-p.ptv3.combo_display)/2)

	if not (p.ptv3.combo_pos > 0) then
		local combo = p.ptv3.combo
		local very = false
		while combo > 80 do
			combo = $-80
			very = true
		end
		p.ptv3.combo = 0
		p.ptv3.combo_pos = 0
		p.ptv3.combo_display = 0
		p.ptv3.combo_offtime = leveltime
		p.ptv3.combo_dropped = true
		p.ptv3.combo_rank = {}
		
		for _,i in ipairs(ranks) do
			if combo >= i.level then
				p.ptv3.combo_rank.rank = i
				p.ptv3.combo_rank.rankn = _
			else
				break
			end
		end
		
		p.ptv3.combo_rank.time = leveltime
		p.ptv3.combo_rank.very = very
	end
	
	if p.ptv3.isSwap
	and p.ptv3.isSwap.valid then
		local p2 = p.ptv3.isSwap
		p2.ptv3.combo = p.ptv3.combo
		p2.ptv3.combo_pos = p.ptv3.combo_pos
		p2.ptv3.combo_display = p.ptv3.combo_display
		p2.ptv3.combo_offtime = p.ptv3.combo_offtime
		p2.ptv3.combo_dropped = p.ptv3.combo_dropped
		p2.ptv3.combo_rank = p.ptv3.combo_rank
	end
end)