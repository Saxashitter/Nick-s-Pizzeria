rawset(_G, "PTV3", {})
rawset(_G, "CV_PTV3", {})

-- this seems out of place, i know, but its for a reason

G_AddGametype({
    name = "Pizza Time",
    identifier = "PTV3",
    typeoflevel = TOL_RACE,
    rules = GTR_EMERALDTOKENS|GTR_FRIENDLYFIRE|GTR_SPAWNINVUL|GTR_CAMPAIGN|GTR_SPAWNENEMIES|GTR_NOTITLECARD|GTR_DEATHPENALTY|GTR_FRIENDLY,
    intermissiontype = int_match,
    headerleftcolor = 222,
    headerrightcolor = 84,
    description = "Go head-to-head against your friends! Use items, kill enemies, and be the one that starts Pizza Time in the classic mode you know and love, but better!"
})

G_AddGametype({
    name = "P.T.: Death Mode",
    identifier = "PTV3DM",
    typeoflevel = TOL_RACE,
    rules = GTR_EMERALDTOKENS|GTR_FRIENDLYFIRE|GTR_SPAWNINVUL|GTR_CAMPAIGN|GTR_SPAWNENEMIES|GTR_NOTITLECARD|GTR_DEATHPENALTY|GTR_FRIENDLY,
    intermissiontype = int_match,
    headerleftcolor = 222,
    headerrightcolor = 84,
    description = "Pizzaface and Snick just won't give you a break, won't they? Maneuver your way over the two, eliminate your friends and be the last one standing in this high-stake version of Pizza Time!"
})

G_AddGametype({
    name = "P.T.: PizzaTag",
    identifier = "PTV3T",
    typeoflevel = TOL_MATCH,
    rules = GTR_TAG|GTR_FRIENDLYFIRE|GTR_OVERTIME|GTR_POINTLIMIT|GTR_TIMELIMIT|GTR_HURTMESSAGES
    intermissiontype = int_match,
    headerleftcolor = 222,
    headerrightcolor = 84,
    description = "Things are heating up. Play a match of Tag while Pizzaface chases all the players! If Overtime starts, Pizzaface will begin eliminating all the players!"
})

function PTV3:isPTV3(dontCheckState)
	if not dontCheckState
	and gamestate ~= GS_LEVEL then
		return false
	end

	return gametype == GT_PTV3 or gametype == GT_PTV3DM or not multiplayer
end

-- Actions

--Escape Spawner from Pizza Tower
--The Spawning Action
function A_PizzaTowerEscapeSpawn(actor, var1, var2)
	A_PlaySeeSound(actor,var1,var2)
	local z = actor.z

	if actor.eflags&MFE_VERTICALFLIP then
		z = $1+FixedMul(actor.info.height-mobjinfo[actor.health].height,actor.scale)
	end

	local enemy = P_SpawnMobj(actor.x,actor.y,z,actor.health)

	if actor.eflags&MFE_VERTICALFLIP then
		enemy.eflags = $1|MFE_VERTICALFLIP
		enemy.flags2 = $1|MF2_OBJECTFLIP
	end
	enemy.scale = actor.scale

	P_MoveOrigin(enemy,actor.x,actor.y,z)

	if P_SupermanLook4Players(enemy) then
		A_FaceTarget(enemy,0,0)
	end

	actor.target = enemy
end

dofile "Libs/customhudlib"

dofile "Variables"
dofile "Callbacks"
dofile "Functions"
dofile "Effects/Main"
dofile "Mechanics/Main"
dofile "Items/Main"
dofile "Main"
dofile "Music"
dofile "HUD/Main"
dofile "Intermission/Main"