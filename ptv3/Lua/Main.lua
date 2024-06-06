sfxinfo[freeslot("sfx_winer")].caption = "You won!"

local function FakeExit(p)
	if not PTV3:isPTV3() then return end
	if not p.ptv3 then return end
	if not p.ptv3.fake_exit then return end

	if p.ptv3.swapModeFollower
	and p.ptv3.swapModeFollower.valid then
		return
	end

	p.pflags = $|PF_FULLSTASIS
	if not (p.exiting) then
		S_StartSound(p.mo, sfx_winer)
		P_DoPlayerExit(p)
		
		if gametype == GT_PTV3DM
		and p.ptv3.laps == PTV3.max_laps+PTV3.max_elaps then
			P_AddPlayerScore(p, 200)
		end
	end

	if (p.cmd.buttons & BT_ATTACK
	and not (p.ptv3.buttons & BT_ATTACK))
	or p.ptv3.extreme
	or gametype == GT_PTV3DM then
		PTV3:newLap(p)
	end
end

addHook('PlayerSpawn', function(p)
	if not PTV3:isPTV3() then return end
	if not (p and p.mo) then return end
	if not p.ptv3 then PTV3:player(p) end

	if PTV3.pizzatime then
		PTV3:teleportPlayer(p)
	end
	if p.ptv3.insecret then
		local link = PTV3.secrets[p.ptv3.insecret][0]
		PTV3:teleportPlayer(p, {x=link.x,y=link.y,z=link.z,a=p.mo.angle})
		return
	end
end)

addHook('MobjDamage', function(mo)
	if not PTV3:isPTV3() then return end
	if not mo.player then return end

	mo.player.score = max($-250, 0)
end, MT_PLAYER)

local function normalThinker(p)
	if not PTV3.pizzatime
	and GetSecSpecial(p.mo.subsector.sector.special, 4) == 2 then
		PTV3:startPizzaTime(p)
	end

	if PTV3.spawnsector and PTV3.pizzatime and p.mo.subsector.sector == PTV3.spawnsector and PTV3:canExit(p) then
		p.ptv3.fake_exit = true
	end

	PTV3.callbacks("PlayerThink", p)

	FakeExit(p)

	-- UH OH, BANANA TIME
	if p.playerstate == PST_DEAD
	and p.ptv3.banana then
		p.ptv3.banana = 0
	end

	if p.ptv3.banana then
		p.mo.state = S_PLAY_PAIN
		p.mo.momx = FixedMul(p.ptv3.banana_speed, cos(p.ptv3.banana_angle))
		p.mo.momy = FixedMul(p.ptv3.banana_speed, sin(p.ptv3.banana_angle))
		p.pflags = $|PF_FULLSTASIS
	end

	if p.ptv3.curItem
	and p.cmd.buttons & BT_CUSTOM1
	and not (p.ptv3.banana) then
		PTV3:useItem(p)
	end

	if p.ptv3.isSwap
	and p.ptv3.isSwap.valid then
		local p2 = p.ptv3.isSwap
		
		p2.ptv3.banana = p.ptv3.banana
		p2.ptv3.banana_angle = p.ptv3.banana_angle
		p2.ptv3.banana_speed = p.ptv3.banana_speed

		if p2.ptv3
		and p2.ptv3.swapModeFollower ~= p.mo then
			p2.ptv3.swapModeFollower = p.mo
		end

		if (not (p.exiting) and p.cmd.buttons & BT_ATTACK
		and not (p.ptv3.buttons & BT_ATTACK))
		and p2.mo
		and p2.mo.health then
			P_SetOrigin(p2.mo, p.mo.x, p.mo.y, p.mo.z)
			p.ptv3.savedData = {}
		
			PTV3:initSwapMode(p, p2)
		end
	end

	table.insert(p.ptv3.savedData, {
		exiting = p.exiting,
		pflags = p.pflags,
		angle = p.drawangle,
		x = p.mo.x,
		y = p.mo.y,
		z = p.mo.z,
		momx = p.mo.momx,
		momy = p.mo.momy,
		momz = p.mo.momz
	})

	if #p.ptv3.savedData > (6*2) then
		table.remove(p.ptv3.savedData, 1)
	end
end

local function followerThinker(p)
	p.pflags = $|PF_FULLSTASIS

	local flwr = p.ptv3.swapModeFollower.player
	
	p.score = flwr.score
	p.rings = flwr.rings

	if p.ptv3.isSwap
	and flwr ~= p.ptv3.isSwap then
		p.ptv3.swapModeFollower = p.ptv3.isSwap.mo
		flwr = p.ptv3.isSwap
	end

	PTV3:doFollowerTP(p.mo, flwr, 2)
end

addHook('PlayerThink', function(p)
	if not PTV3:isPTV3() then return end
	if not p.ptv3 then PTV3:player(p) end

	p.spectator = p.ptv3.specforce

	if p.ptv3.specforce then
		return
	end

	if not p.mo then return end

	if PTV3.game_over > 0 then
		p.pflags = $|PF_FULLSTASIS
		p.deadtimer = 130
		return
	end

	if (p.ptv3.swapModeFollower
	and p.ptv3.swapModeFollower.valid) then
		followerThinker(p)
	else
		normalThinker(p)
	end

	p.ptv3.buttons = p.cmd.buttons
end)

addHook('ThinkFrame', function()
	if not PTV3:isPTV3() then return end

	for p in players.iterate do
		if not p.mo then continue end
		if not p.ptv3 then continue end
		if p.ptv3.specforce then continue end
		if p.ptv3.swapModeFollower
		and p.ptv3.swapModeFollower.valid then continue end

		if p.ptv3.banana
		and P_IsObjectOnGround(p.mo) then
			p.ptv3.banana = $-1
			p.mo.momz = 8*(FU*P_MobjFlip(p.mo))
		end
	end
end)

addHook("ShouldDamage", function(mobj)
	if not (mobj
	and mobj.valid
	and mobj.player
	and mobj.player.ptv3
	and mobj.player.ptv3.swapModeFollower) then
		return
	end

	return false
end, MT_PLAYER)

addHook('PostThinkFrame', function()
	if not PTV3:isPTV3() then return end

	for p in players.iterate do
		if p.ptv3 then
			if not p.ptv3.fake_exit then
				p.exiting = 0
				p.pflags = $ & ~PF_FINISHED
			end
			PTV3:checkRank(p)
			local percent = PTV3:returnNextRankPercent(p)
		end
	end

	if PTV3.game_over > -1 then
		if leveltime - PTV3.game_over > 5*TICRATE then
			G_ExitLevel()
		end
		return
	end

	if PTV3.pizzatime then
		PTV3.time = max(0, $-1)
		PTV3.pftime = max(0, $-1)
		if PTV3.overtime then
			PTV3.overtime_time = max(0, $-1)

			if PTV3.overtime_time == 0
			or not PTV3:canOvertime() then
				PTV3:endGame()
			end
		end
	end

	if not (PTV3.time)
	and not PTV3.overtime then
		--if PTV3:canOvertime() then
		if PTV3:canOvertime() then
			PTV3:overtimeToggle()
		else
			PTV3:endGame()
		end
	end

	local current,_,_,_,alive,total = PTV3:playerCount()

	if gametype == GT_PTV3DM
	and PTV3.pizzatime
	and not PTV3.overtime
	and #total > 2
	and #current == 2 then
		PTV3:overtimeToggle()
	end

	if (PTV3.pizzaface or PTV3.snick)
	and multiplayer
	and #alive == 0
	or (gametype == GT_PTV3DM and #total > 2 and #alive == 1) then
		PTV3:endGame()
	end

	if gametype == GT_PTV3DM
	and PTV3.pizzaface
	and PTV3.pizzaface.valid then
		local increase = (FU/(TICRATE*5))
		if PTV3.overtime then
			PTV3.pizzaface.flyspeed = $+increase
		end
	end

	if PTV3.pizzatime and not (PTV3.pftime) and not PTV3.pizzaface then
		PTV3:pizzafaceSpawn()
	end
	if PTV3.pizzatime and consoleplayer and multiplayer then
		consoleplayer.realtime = PTV3.time
	end
end)