--[[addHook("MobjThinker", function(mobj)
    if (mobj.flags & MF_ENEMY) and (mobj.health) then
        P_LookForPlayers(mobj, 200*mobj.scale, true, true)
        
		if mobj.scared > 0 then
			mobj.scared = $ - 1
		end

        if mobj.tracer
		and mobj.tracer.player then
			if isPTSkin and ntopp_v2 then
		        if isPTSkin(mobj.tracer.player.mo.skin)
		        and mobj.tracer.player.fsm
		        and mobj.tracer.player.fsm.state == ntopp_v2.enums.MACH3 then
					if mobj.scared == 0 then
						local alart = P_SpawnMobjFromMobj(mobj, 0, 0, 0, MT_GHOST)
						alart.state = S_ALART1
						alart.fuse = TICRATE
						alart.spriteyoffset = mobj.height+15*FRACUNIT
						if P_RandomRange(0,30) > 25
							S_StartSound(mobj, sfx_nmesca, mobj.tracer.player)
						end
					    mobj.state = mobjinfo[mobj.type].spawnstate
						mobj.tics = 5*TICRATE
					    mobj.scared = 90
					end
				end
		    end
        end
    end
end)]]

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
	if player and player.valid then
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
					local notes = P_SpawnMobjFromMobj(mobj, P_RandomRange(-20,20)*FRACUNIT, P_RandomRange(-20,20)*FRACUNIT, (10*FRACUNIT)*P_MobjFlip(mobj), MT_THOK)
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