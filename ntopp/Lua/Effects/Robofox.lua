//colors for the star sprites
local starcolors = {SKINCOLOR_YELLOW, SKINCOLOR_RED, SKINCOLOR_WHITE, SKINCOLOR_ORANGE, SKINCOLOR_BLACK}

addHook("MobjSpawn",function(mobj)//spawn randomness
	if mobj and mobj.valid then
		mobj.state = S_NMEGIBS
		mobj.tics = P_RandomRange(1, 5)*TICRATE
		mobj.frame = P_RandomRange(A,O)
		if P_RandomRange(0, 10) > 5 then
			mobj.frame = P_RandomRange(A,B)
		end
		mobj.momx = P_RandomRange(-10,10)*FRACUNIT
		mobj.momy = P_RandomRange(-10,10)*FRACUNIT
		mobj.momz = P_RandomRange(-10,10)*FRACUNIT
		mobj.rollangle = P_RandomRange(1,360)*ANG1
		if mobj.frame == A or mobj.frame == B then
			mobj.color = starcolors[P_RandomRange(1,#starcolors)]
		end
	end
end, MT_NMEGIBS)

addHook("MobjThinker", function(gib)
	if not gib.valid then return end

	if gib.z+gib.height < gib.floorz
	or gib.z > gib.ceilingz then
		--print "bye"
		P_RemoveMobj(gib)
	end
end, MT_NMEGIBS)

addHook("MobjDeath",function(mobj, pmo)//spawn em, when i die
	if not (pmo
	and pmo.valid
	and pmo.player
	and isPTSkin(pmo.skin)) then return end

	if mobj and mobj.valid then
		if (mobj.flags & MF_BOSS or mobj.flags & MF_ENEMY) then
			for i = 10,P_RandomRange(10,20) do
				P_SpawnMobjFromMobj(mobj, 0, 0, 0, MT_NMEGIBS)
			end
		end
	end
end)

addHook("MobjDamage",function(mobj)//spawn em, when ouchies
	if not (pmo
	and pmo.valid
	and pmo.player
	and isPTSkin(pmo.skin)) then return end
	
	if mobj and mobj.valid then
		if mobj.health > 1 and (mobj.flags & MF_BOSS or mobj.flags & MF_ENEMY) then
			for i = 10,P_RandomRange(10,20) do
				P_SpawnMobjFromMobj(mobj, 0, 0, 0, MT_NMEGIBS)
			end
		end
	end
end)

freeslot("MT_BOOMBOX", "S_BOOMBOX", "SPR_BDBX", "SPR_BDFX")

addHook("PlayerSpawn",function(player)
local isdancing
player.isdancing = 0
end)

//dance time
mobjinfo[MT_BOOMBOX] = {
	spawnstate = S_BOOMBOX,
	spawnhealth = 20,
	deathstate = S_NULL,
	speed = 10,
	radius = 1*FRACUNIT,
	height = 1*FRACUNIT,
	dispoffset = 0,
	mass = 100,
	damage = 0,
	activesound = sfx_none,
	flags = MF_NOCLIP|MF_NOBLOCKMAP,
}

states[S_BOOMBOX] = {
	sprite = SPR_BDBX,
	frame = A,
	tics = -1,
	nextstate = S_NULL
}


addHook("PlayerThink",function(player)//spawn dat boombox
	if player and player.valid and player.mo and player.mo.valid then
		if isPTSkin and ntopp_v2
			if isPTSkin(player.mo.skin)
			and player.fsm
			and player.fsm.state == ntopp_v2.enums.BREAKDANCE// let's dance!
				if player.isdancing == 0
				and S_SoundPlaying(player.mo, sfx_brdam)
					local beatbox = P_SpawnMobjFromMobj(player.mo, 0, 0, 0, MT_BOOMBOX)
					beatbox.tracer = player.mo
					if (player.mo.skin == "nthe_noise") //noise's special boombox
						beatbox.frame = B
						beatbox.color = player.mo.color
					else
						beatbox.frame = A
					end
					beatbox.angle = player.drawangle+ANGLE_180
					P_SetObjectMomZ(beatbox, 8*FRACUNIT, true)// jump a bit
					player.isdancing = 1
				end
			end
		end
	end
end)

addHook("MobjThinker", function(mobj)
	if mobj.tracer
	and mobj.tracer.player
		if isPTSkin and ntopp_v2
			if isPTSkin(mobj.tracer.player.mo.skin)
			and mobj.tracer.player.fsm
			and mobj.tracer.player.fsm.state == ntopp_v2.enums.BREAKDANCE
				if P_RandomRange(0, 50) > 45 //try to be random.
					local notes = P_SpawnMobjFromMobj(mobj, P_RandomRange(-40,40)*FRACUNIT, P_RandomRange(-40,40)*FRACUNIT, (10*FRACUNIT)*P_MobjFlip(mobj), MT_THOK)
					P_SetObjectMomZ(notes, 10*FRACUNIT, true)
					notes.tics = 70
					notes.sprite = SPR_BDFX //set to the right sprite
					notes.frame = P_RandomRange(A,G)
				end
			else 
				mobj.tracer.player.isdancing = 0
				P_RemoveMobj(mobj)
			end
		end
	end
end, MT_BOOMBOX)
 
freeslot("SPR_DLFX", "SPR_SNFX", "S_NSUPERSPARK", "S_NBONKEFFECT", "S_SUPERREADYFX")

states[S_NSUPERSPARK] = {
	sprite = SPR_SNFX,
	frame = FF_FULLBRIGHT|A|FF_ANIMATE,
	tics = 25,
	var1 = 4,
    var2 = 5,
	nextstate = S_NULL
}

states[S_NBONKEFFECT] = {
	sprite = SPR_DLFX,
	frame = E|FF_ANIMATE,
	tics = 15,
	var1 = 2,
    var2 = 5,
	nextstate = S_NULL
}

states[S_SUPERREADYFX] = {
	sprite = SPR_STSP,
	frame = FF_FULLBRIGHT|A|FF_ANIMATE,
	tics = 20,
	var1 = 4,
    var2 = 5,
	nextstate = S_NULL
}

// the noise effects starts...

addHook("PlayerSpawn",function(player)
local drillframe
player.drillframe = 0
local bonked
player.bonked = false
end)

addHook("PlayerThink",function(player)
player.drillframe = $ or 0
player.bonked = true or false
end)

addHook("PlayerThink",function(player)//tornado effects
	if player and player.valid and player.mo and player.mo.valid then
	if isPTSkin and ntopp_v2 and player.fsm
    if isPTSkin(player.mo.skin) and (player.mo.skin == "nthe_noise")
    if (player.fsm.state == ntopp_v2.enums.WALLCLIMB) or (player.fsm.state == ntopp_v2.enums.DIVE) // tornado!
	if P_IsObjectOnGround(player.mo)// dust when on ground
	local fxone = P_SpawnMobjFromMobj(player.mo, 0, 0, 5*FRACUNIT, MT_THOK)
	fxone.flags = MF_NOCLIP|MF_NOCLIPHEIGHT
    fxone.sprite = SPR_DLFX
    fxone.frame = P_RandomRange(B, D)
    fxone.tics = P_RandomRange(35, 70)
	fxone.momx = P_RandomRange(-3, 3)*FRACUNIT
	fxone.momy = P_RandomRange(-3, 3)*FRACUNIT
	fxone.scale = player.mo.scale
	fxone.eflags = player.mo.eflags
	P_SetObjectMomZ(fxone, P_RandomRange(1, 5)*FRACUNIT, true)
	fxone.color = player.mo.color
	end
	player.drillframe = $ + 1 //tornado rotat e
    local fxtwo = P_SpawnMobjFromMobj(player.mo, 0, 0, P_RandomRange(20, 40)*FRACUNIT, MT_THOK)
    fxtwo.sprite = SPR_DLFX
    fxtwo.frame = A|FF_PAPERSPRITE
	fxtwo.angle = player.drillframe*ANG10 + ANGLE_90
    fxtwo.tics = 2
	fxtwo.scale = player.mo.scale
	fxtwo.eflags = player.mo.eflags
	 P_MoveOrigin(fxtwo,
        player.mo.x - FixedMul(cos(player.drillframe*ANG10), 25*FRACUNIT),
        player.mo.y - FixedMul(sin(player.drillframe*ANG10), 25*FRACUNIT), 
		fxtwo.z)
   end
  end
end
end
end)

addHook("PlayerThink",function(player) //super noise's spark effects
	if player and player.valid and player.mo and player.mo.valid then
	if isPTSkin and ntopp_v2
    if isPTSkin(player.mo.skin)
	and (player.mo.skin == "nthe_noise")
	and player.powers[pw_super]
	if P_RandomRange(0, 50) > 40 and leveltime%2
local fxthree = P_SpawnMobjFromMobj(player.mo, 0, 0, 0, MT_THOK)
fxthree.scale = player.mo.scale
fxthree.state = S_NSUPERSPARK
fxthree.eflags = player.mo.eflags
	 P_MoveOrigin(fxthree,
        player.mo.x - FixedMul(cos(P_RandomRange(0, 360)*ANG1), P_RandomRange(20, 30)*FRACUNIT),
        player.mo.y - FixedMul(sin(P_RandomRange(0, 360)*ANG1), P_RandomRange(20, 30)*FRACUNIT),
		fxthree.z)
P_SetObjectMomZ(fxthree, 5*FRACUNIT, true)
end
end
end
end
end)

addHook("PlayerThink",function(player)//the trail when spinning
	if player and player.valid and player.mo and player.mo.valid then
	if isPTSkin and ntopp_v2
    if isPTSkin(player.mo.skin)
    and player.fsm
	and player.pvars
	and player.pvars.forcedstate
	and (player.mo.skin == "nthe_noise")// woag.
	and leveltime%4
    and  (player.fsm.state == ntopp_v2.enums.DIVE)//tornado
	if player.pvars.forcedstate == S_NOISE_DRILLAIR
	NTOPP_NoiseAI(player.mo, S_NTOPP_AIRTORNADOAI)
	elseif player.pvars.forcedstate == S_NOISE_DRILLLAND
	NTOPP_NoiseAI(player.mo, S_NTOPP_LANDTORNADOAI)
	else
	NTOPP_NoiseAI(player.mo, S_NTOPP_TORNADOAI)
	end
	end
  end
 end
end)

/*/ //it just doesn't work anymore lol
addHook("PlayerThink",function(player)// the wall kick effect
if player and player.valid and player.mo and player.mo.valid then
	if isPTSkin and ntopp_v2
    if isPTSkin(player.mo.skin)
    and player.pvars
	and player.pvars.forcedstate
	and (player.mo.skin == "nthe_noise")
	 if (player.bonked) and (player.pvars.forcedstate != S_PEPPINO_WALLCLIMB)// is "wall kicking"
	 player.bonked = false
	 end
    if (player.pvars.forcedstate == S_PEPPINO_WALLCLIMB) and not(player.bonked)
	local fxfive = P_SpawnMobjFromMobj(player.mo, 0, 0, 0, MT_THOK)
	fxfive.tics = 35
    fxfive.state = S_NBONKEFFECT
	fxfive.color = player.skincolor
	  player.bonked = true
	  end
   end
  end
  end
end)
/*/

addHook("PlayerThink",function(player)// put your super taunt in an oven until its ready
if player and player.valid and player.mo and player.mo.valid then
	if isPTSkin and ntopp_v2
    if isPTSkin(player.mo.skin)
	and player.pvars
	and player.pvars.supertauntready
	and (leveltime%10 >= 8)
 local fxsix = P_SpawnMobjFromMobj(player.mo, P_RandomRange(-40,40)*FRACUNIT, P_RandomRange(-40,40)*FRACUNIT, P_RandomRange(-40,40)*FRACUNIT, MT_THOK)
    fxsix.state =  S_SUPERREADYFX
	   end
	  end
    end
end)
 
 
 
 