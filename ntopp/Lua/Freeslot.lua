// SHIT FOR GRABBING

freeslot('MT_NTOPP_GRABBED')

mobjinfo[MT_NTOPP_GRABBED] = {
	doomednum = -1,
	spawnstate = S_PLAY_WAIT,
	flags = MF_NOCLIP|MF_NOCLIPHEIGHT
}

// MOBJ (EFFECTS, PARTICLES) SHIT

freeslot('MT_NTOPP_AFTERIMAGE')

freeslot('MT_LINEPARTICLE')
freeslot('MT_PARTICLE')

freeslot('S_LINEPARTICLE_MACHDUST')
freeslot('SPR_MCDS')

freeslot('S_LINEPARTICLE_RUNDUST')
freeslot('SPR_SDSC')

freeslot("S_DASHCLOUD","SPR_DSHC","S_SMALLDASHCLOUD","S_CLOUDEFFECT","SPR_CLEF")
freeslot("S_PJUMPDUST", "SPR_JPDT", "sfx_pjump")

freeslot("S_CCWATERFX", "SPR_WTFX") -- added by pacola :D
freeslot("S_SHINEEFFECT", "SPR_NUPC") -- also added by pacola :D
freeslot("S_FLOATERDEBRIS", "SPR_FTDB") -- added by pacola again :D

freeslot("S_PSTNDJUMPDUST", "SPR_JPDU")

freeslot("MT_NTOPP_RAGDOLLENEMY","S_SUPERTAUNTEFFECT","SPR_STSP")

freeslot("MT_NTOPP_EFFECTFOLLOWPLAYER")

freeslot("S_NTOPPEFFECTS_MACHCHARGE", "SPR_MCEF")
freeslot("S_NTOPPEFFECTS_TAUNTEFFECT", "SPR_TANT")
freeslot("S_NTOPPEFFECTS_PARRYEFFECT", "SPR_PARY")
freeslot("S_NTOPPEFFECTS_BODYSLAMEFFECT", "SPR_GRPE")

freeslot("MT_NMEGIBS", "S_NMEGIBS", "SPR_EGIB")

freeslot("MT_NOISE_OVERLAY")
freeslot("MT_NTOPP_BOSSHP")

mobjinfo[MT_NMEGIBS] = {
	spawnstate = S_NMEGIBS,
	spawnhealth = 20,
	deathstate = S_NULL,
	speed = 10,
	radius = 1*FRACUNIT,
	height = 1*FRACUNIT,
	dispoffset = 0,
	mass = 10,
	damage = 0,
	activesound = sfx_none,
	flags = MF_NOCLIP|MF_NOCLIPHEIGHT,
}

states[S_NMEGIBS] = {
	sprite = SPR_EGIB,
	frame = A,
	tics = -1,
	nextstate = S_NULL
}

states[S_LINEPARTICLE_MACHDUST] = {SPR_MCDS, FF_PAPERSPRITE|FF_ANIMATE|A, 6*2, nil, 5, 2, S_NULL}
states[S_LINEPARTICLE_RUNDUST] = {SPR_SDSC, FF_PAPERSPRITE|FF_ANIMATE|A, 5*2, nil, 4, 2, S_NULL}
states[S_PJUMPDUST] = {SPR_JPDT, FF_PAPERSPRITE|FF_ANIMATE|A, 6, nil, 5, 1, S_NULL}
states[S_PSTNDJUMPDUST] = {SPR_JPDU, FF_ANIMATE|A, 7, nil, 6, 1, S_NULL}

states[S_NTOPPEFFECTS_MACHCHARGE] = {SPR_MCEF, FF_ANIMATE|A, 10, nil, 9, 1, S_NTOPPEFFECTS_MACHCHARGE}
states[S_NTOPPEFFECTS_TAUNTEFFECT] = {SPR_TANT, FF_ANIMATE|A, 9*2, nil, 8, 2, S_NULL}
states[S_NTOPPEFFECTS_PARRYEFFECT] = {SPR_PARY, FF_ANIMATE|A, 6*2, nil, 5, 2, S_NULL}
states[S_NTOPPEFFECTS_BODYSLAMEFFECT] = {SPR_GRPE, FF_ANIMATE|A, 4*2, nil, 3, 2, S_NTOPPEFFECTS_BODYSLAMEFFECT}

states[S_SUPERTAUNTEFFECT] = {
	sprite = SPR_STSP,
	frame = A|FF_ANIMATE,
	tics = 10,
	var1 = 5,
	var2 = 2,
	nextstate = S_DEATHSTATE
}

mobjinfo[MT_LINEPARTICLE] = {
	doomednum = -1,
	spawnstate = S_LINEPARTICLE_MACHDUST,
	flags = MF_NOCLIP|MF_NOBLOCKMAP|MF_NOCLIPHEIGHT|MF_NOGRAVITY
}

mobjinfo[MT_NTOPP_EFFECTFOLLOWPLAYER] = {
	doomednum = -1,
	spawnstate = S_LINEPARTICLE_MACHDUST,
	flags = MF_NOCLIP|MF_NOBLOCKMAP|MF_NOCLIPHEIGHT|MF_NOGRAVITY
}

mobjinfo[MT_NTOPP_AFTERIMAGE] = {
	doomednum = -1,
	spawnstate = S_LINEPARTICLE_MACHDUST,
	flags = MF_NOCLIP|MF_NOBLOCKMAP|MF_NOCLIPHEIGHT|MF_NOGRAVITY
}

mobjinfo[MT_NTOPP_RAGDOLLENEMY] = {
	doomednum = -1,
	spawnstate = S_INVISIBLE,
	flags = MF_SCENERY|MF_NOBLOCKMAP|MF_NOCLIP
}

mobjinfo[MT_NOISE_OVERLAY] = {
	doomednum = -1,
	spawnstate = S_INVISIBLE,
	flags = MF_NOCLIP|MF_NOCLIPHEIGHT|MF_NOGRAVITY
}

mobjinfo[MT_NTOPP_BOSSHP] = {
	doomednum = -1,
	spawnstate = S_INVISIBLE,
	radius = 16*FU,
	height = 16*FU,
	flags = MF_SPECIAL
}



// PLAYER SHIT

freeslot('sfx_pstep')

freeslot('sfx_mach1')
freeslot('sfx_mach2')
freeslot('sfx_mach3')
freeslot('sfx_mach4')

sfxinfo[freeslot("sfx_dshpad")].caption = "Dashpad"

freeslot("sfx_nmesca")

sfxinfo[sfx_nmesca].caption = "Enemy Scared"

for i = 2, 4 do
	sfxinfo[freeslot("sfx_nmch"+i)].caption = "Mach "+i
	sfxinfo[freeslot("sfx_nmc"+i+"g")].caption = "Mach "+i
end

for i = 1, 4 do
	if i ~= 4
		sfxinfo[freeslot("sfx_etbm"+i)].caption = "Mach "+i
	end
	sfxinfo[freeslot("sfx_de2m"+i)].caption = "Mach "+i
end

for i = 1, 3 do
	if i ~= 3
		sfxinfo[freeslot("sfx_hwma"+i)].caption = "Mach "+i
	else
		sfxinfo[freeslot("sfx_hwma"+i)].caption = "Enter Mach "+i
	end
end

sfxinfo[freeslot("sfx_nmccnc")].caption = "Mach Cancel"
sfxinfo[freeslot("sfx_nmclop")].caption = "Mach Cancel Loop"
sfxinfo[freeslot("sfx_nmclnd")].caption = "Mach Cancel Land"
sfxinfo[freeslot("sfx_naspin")].caption = "Air Spin"
sfxinfo[freeslot("sfx_ntrnd")].caption = "Tornado"
sfxinfo[freeslot("sfx_gum1")].caption = "Mach 1"
sfxinfo[freeslot("sfx_gum2")].caption = "Mach 3"
sfxinfo[freeslot("sfx_gwj1")].caption = "Cling onto Wall"
sfxinfo[freeslot("sfx_gwj2")].caption = "Wall Jump"

freeslot('sfx_pskid')
freeslot('sfx_drift')

freeslot('sfx_pgrab')

freeslot('sfx_kenem')
sfxinfo[sfx_kenem].caption = "Killed an enemy"
freeslot('sfx_parry')
freeslot('sfx_taunt')
freeslot('sfx_staunt')

freeslot('sfx_sjpre')
freeslot('sfx_sjhol')
freeslot('sfx_sjrel')

sfxinfo[freeslot("sfx_nsjstr")].caption = "Super Jump Start"
sfxinfo[freeslot("sfx_nsjlop")].caption = "Super Jump Hold"
sfxinfo[freeslot("sfx_nsjend")].caption = "Super Jump Release"

freeslot('sfx_sjcan')
freeslot('sfx_phalo')

freeslot('sfx_grpo')
freeslot('sfx_mabmp')

freeslot('sfx_owmyas')
freeslot('sfx_pain1')
freeslot('sfx_pain2')
freeslot('sfx_npain1')
freeslot('sfx_npain2')
freeslot('sfx_npain3')
freeslot('sfx_npain4')
freeslot('sfx_eyaow')
freeslot('sfx_dwaha')

freeslot('sfx_upcut')
freeslot('sfx_upcu2')

freeslot('sfx_breda')
freeslot('sfx_brdam')

freeslot('sfx_strea')

freeslot('sfx_gploop','sfx_gpstar')
sfxinfo[sfx_gploop].caption = "Body Slam Loop"
sfxinfo[sfx_gpstar].caption = "Body Slam Start"
sfxinfo[sfx_grpo].caption = "Body Slam"

freeslot('SPR2_GRAB')
freeslot('SPR2_SDHA')

freeslot('SPR2_LOJU')

freeslot('SPR2_HLID')
freeslot('SPR2_HLFL')
freeslot('SPR2_HLLA')
freeslot('SPR2_HLWA')

freeslot('SPR2_CRTR')
freeslot('SPR2_CRCH')
freeslot('SPR2_CRAL')
freeslot('SPR2_CRFA')

freeslot('SPR2_SJPR')
freeslot('SPR2_SJRE')
freeslot('SPR2_SJGO')
freeslot('SPR2_SJCS')
freeslot('SPR2_SJCA')

freeslot('SPR2_BSST')
freeslot('SPR2_BSFL')
freeslot('SPR2_BSLD')

freeslot('SPR2_DVBM')
freeslot('SPR2_DVBE')
freeslot('SPR2_DVBL')
freeslot('SPR2_UPCE')

freeslot('SPR2_WJEN')

freeslot('SPR2_KNFU')
freeslot('SPR2_KNF2')
freeslot('SPR2_KNF3')

freeslot('SPR2_WLSP')
freeslot('SPR2_SJLA')
freeslot('SPR2_M3HW')

freeslot('SPR2_PIDR')
freeslot('SPR2_PIDL')

freeslot('SPR2_TAUN')

freeslot('SPR2_PARR')
freeslot('SPR2_PAR2')

freeslot('SPR2_BRD1')
freeslot('SPR2_BRD2')
freeslot('SPR2_BTAT')

freeslot('SPR2_PRAM')

freeslot('SPR2_STA1')
freeslot('SPR2_STA2')
freeslot('SPR2_STA3')
freeslot('SPR2_STA4')

freeslot('SPR2_PANC')
freeslot('SPR2_SWDN')
freeslot('SPR2_SWDE')

freeslot("S_PEPPINO_WATERSLIDE")

freeslot('S_PEPPINO_JUMPTRNS')
freeslot('S_PEPPINO_FALLTRNS')

freeslot('S_PEPPINO_MACH1')
freeslot('S_PEPPINO_MACH2')
freeslot('S_PEPPINO_MACH3')
freeslot('S_PEPPINO_MACH4')
freeslot("S_NOISE_WATERRUN") -- added by pacola :D

freeslot("S_PEPPINO_DASHPAD")

freeslot('S_PEPPINO_SECONDJUMP')

freeslot('S_PEPPINO_MACH3JUMP')

freeslot('S_PEPPINO_MACH3HIT')

freeslot('S_PEPPINO_MACHSKID')

freeslot('S_PEPPINO_MACHDRIFTTRNS2')
freeslot('S_PEPPINO_MACHDRIFTTRNS3')

freeslot('S_PEPPINO_MACHDRIFT2')
freeslot('S_PEPPINO_MACHDRIFT3')

freeslot('S_PEPPINO_SUPLEXDASH')
freeslot("S_PEPPINO_SUPLEXDASHCNCL")
freeslot('S_PEPPINO_AIRSUPLEXDASH')

freeslot('S_PEPPINO_LONGJUMP')

freeslot('S_PEPPINO_HAULINGIDLE')
freeslot('S_PEPPINO_HAULINGFALL')
freeslot('S_PEPPINO_HAULINGWALK')

freeslot('S_PEPPINO_WALLCLIMB')

freeslot('S_PEPPINO_CROUCH')
freeslot('S_PEPPINO_CROUCHWALK')
freeslot('S_PEPPINO_CROUCHFALL')

freeslot('S_PEPPINO_ROLL')

freeslot('S_PEPPINO_DIVE')

freeslot('S_PEPPINO_SUPERJUMPSTARTTRNS')
freeslot('S_PEPPINO_SUPERJUMPSTART')
freeslot('S_PEPPINO_SUPERJUMP')
freeslot('S_PEPPINO_SUPERJUMPCANCELTRNS')
freeslot('S_PEPPINO_SUPERJUMPCANCEL')

freeslot('S_PEPPINO_BODYSLAMSTART')
freeslot('S_PEPPINO_BODYSLAM')
freeslot('S_PEPPINO_BODYSLAMLAND')

freeslot('S_PEPPINO_DIVEBOMB')
freeslot('S_PEPPINO_DIVEBOMBEND')

freeslot('S_PEPPINO_UPPERCUTEND')

freeslot('S_PEPPINO_WALLJUMP')

freeslot('S_PEPPINO_PILEDRIVER')
freeslot('S_PEPPINO_PILEDRIVERLAND')

freeslot('S_PEPPINO_TAUNT')

freeslot('S_PEPPINO_BREAKDANCE1')
freeslot('S_PEPPINO_BREAKDANCE2')
freeslot('S_PEPPINO_BREAKDANCELAUNCHTRNS')
freeslot('S_PEPPINO_BREAKDANCELAUNCH')

freeslot('S_PEPPINO_BOOGIE')

freeslot('S_PEPPINO_SWINGDING')
freeslot('S_PEPPINO_SWINGDINGEND')

// call me lazy but no reason to type a shit ton of code when you can just
for i = 1,5 do
	freeslot('SPR2_FIB'..i)
	freeslot('S_PEPPINO_FINISHINGBLOW'..i)
end
	freeslot('S_PEPPINO_FINISHINGBLOWUP')
	freeslot('SPR2_UGRA')

freeslot('S_PEPPINO_BELLYSLIDE')

freeslot('S_PEPPINO_KUNGFU_1')
freeslot('S_PEPPINO_KUNGFU_2')
freeslot('S_PEPPINO_KUNGFU_3')

freeslot('S_PEPPINO_PARRY1')
freeslot('S_PEPPINO_PARRY2')

freeslot('S_PEPPINO_UPSTUN')
freeslot('S_PEPPINO_MACH2STUN')
freeslot('S_PEPPINO_MACH3STUN')

freeslot('S_PEPPINO_BREAKDANCELAUNCHTRNS')
freeslot('S_PEPPINO_BREAKDANCELAUNCH')

freeslot('S_PEPPINO_SLOPEJUMP')

freeslot('S_PEPPINO_SUPERTAUNT1')
freeslot('S_PEPPINO_SUPERTAUNT2')
freeslot('S_PEPPINO_SUPERTAUNT3')
freeslot('S_PEPPINO_SUPERTAUNT4')

freeslot('S_PEPPINO_PANIC')

freeslot("S_PEPPINO_FIREASS")
freeslot("S_PEPPINO_FIREASSGRND")

freeslot('S_NOISE_SPIN')
freeslot('S_NOISE_CRUSHER')
freeslot('S_NOISE_CRUSHEREND')

freeslot('S_GUSTAVO_WALLJUMP')

freeslot("S_EXPLOSIONEFFECT","SPR_EPLO","S_MACH4RING","SPR_M4RI")

sfxinfo[sfx_pstep].caption = "Step"
sfxinfo[sfx_mach1].caption = "Mach 1"
sfxinfo[sfx_mach2].caption = "Mach 2"
sfxinfo[sfx_mach3].caption = "Mach 3"
sfxinfo[sfx_mach4].caption = "Mach 4"
sfxinfo[sfx_pskid].caption = "Skid"
sfxinfo[sfx_drift].caption = "Drift"
sfxinfo[sfx_pgrab].caption = "Grab"
sfxinfo[sfx_pain1].caption = "Painful yelp"
sfxinfo[sfx_pain2].caption = "Painful yelp"
sfxinfo[sfx_npain1].caption = "Painful woag"
sfxinfo[sfx_npain2].caption = "Painful woag"
sfxinfo[sfx_npain3].caption = "Painful woag"
sfxinfo[sfx_npain4].caption = "Painful woag"
sfxinfo[sfx_owmyas].caption = "Got hurt"
sfxinfo[sfx_parry].caption = "Pow!"
sfxinfo[sfx_phalo].caption = "HA!"
sfxinfo[sfx_eyaow].caption = "EYAAAAOAOAOAOAOAOW!"
sfxinfo[sfx_dwaha].caption = "DWAAAAAAHAAAAAAAAA!"
sfxinfo[sfx_breda].caption = "Er-Er-Ere!"
sfxinfo[sfx_brdam].caption = "Breakdance Music"
sfxinfo[sfx_taunt].caption = "Taunt!"
sfxinfo[sfx_staunt].caption = "Super taunt!"
sfxinfo[sfx_strea].caption = "Super taunt ready!"
sfxinfo[sfx_mabmp].caption = "Bump"

sfxinfo[freeslot("sfx_mmlswt")].caption = "Light switch"
sfxinfo[freeslot("sfx_mmjsc")].caption = "Jumpscare"

states[S_MACH4RING] = {
	sprite = SPR_M4RI,
	frame = A|FF_PAPERSPRITE
}

states[S_DASHCLOUD] = {
	sprite = SPR_DSHC,
	frame = A|FF_ANIMATE|FF_PAPERSPRITE,
	tics = 16,
	var1 = 8,
	var2 = 2,
	nextstate = S_DEATHSTATE
}

states[S_CCWATERFX] = {
	sprite = SPR_WTFX,
	frame = A|FF_ANIMATE,
	tics = (K+1)*2,
	var1 = K,
	var2 = 2,
	nextstate = S_DEATHSTATE
}

states[S_SMALLDASHCLOUD] = {
	sprite = SPR_SDSC,
	frame = A|FF_PAPERSPRITE|FF_ANIMATE,
	tics = 10,
	var1 = 5,
	var2 = 2,
	nextstate = S_DEATHSTATE
}

states[S_CLOUDEFFECT] = {
	sprite = SPR_CLEF,
	frame = A|FF_ANIMATE,
	tics = 28,
	var1 = 14,
	var2 = 2,
	nextstate = S_DEATHSTATE
}

states[S_EXPLOSIONEFFECT] = {
	sprite = SPR_EPLO,
	frame = A|FF_ANIMATE,
	tics = 18,
	var1 = 9,
	var2 = 2,
	nextstate = S_DEATHSTATE
}

-- nois efexcts

states[S_SHINEEFFECT] = {
	sprite = SPR_NUPC,
	frame = A|FF_ANIMATE,
	tics = (C+1)*3,
	var1 = C,
	var2 = 3,
	nextstate = S_DEATHSTATE
}

states[S_FLOATERDEBRIS] = {
	sprite = SPR_FTDB,
	frame = A,
	tics = -1,
	nextstate = S_DEATHSTATE
}

PacolaCASkin["nthe_noise"] = {}

states[S_PEPPINO_WATERSLIDE] = { -- noise doesnt get recolorability haha, and animation is also all code handled
	sprite = SPR_PLAY,
	frame = SPR2_TAL0,
	nextstate = S_PEPPINO_WATERSLIDE
}

states[S_PEPPINO_JUMPTRNS] = {
	sprite = SPR_PLAY,
	frame = SPR2_JUMP|FF_ANIMATE,
	tics = 69420,
	nextstate = S_PLAY_FALL,
	var1 = 63,
	var2 = 2
}

states[S_PEPPINO_MACH1] = {SPR_PLAY, SPR2_RUN_, 1, nil, 0, 0, S_PEPPINO_MACH1}
states[S_PEPPINO_MACH2] = {SPR_PLAY, SPR2_MLEL, 1, nil, 0, 0, S_PEPPINO_MACH2}
states[S_PEPPINO_MACH3] = {SPR_PLAY, SPR2_SPIN, 2, nil, 0, 0, S_PEPPINO_MACH3}
states[S_PEPPINO_MACH4] = {SPR_PLAY, SPR2_DASH, 1, nil, 0, 0, S_PEPPINO_MACH4}

states[S_PEPPINO_DASHPAD] = {
	sprite = SPR_PLAY,
	frame = SPR2_TAL6|FF_ANIMATE,
	tics = 69420,
	nextstate = S_PEPPINO_MACH3,
	var1 = 63,
	var2 = 2
}

states[S_PEPPINO_MACH3HIT] = {
	sprite = SPR_PLAY,
	frame = SPR2_TAL5|FF_ANIMATE,
	tics = 69420,
	nextstate = S_PEPPINO_MACH3,
	var1 = 63,
	var2 = 2
}

states[S_NOISE_WATERRUN] = {
	sprite = SPR_PLAY,
	frame = SPR2_TALB,
	tics = 2,
	nextstate = S_NOISE_WATERRUN
}

states[S_PEPPINO_SECONDJUMP] = {
	sprite = SPR_PLAY,
	frame = SPR2_FLY_,
	tics = -1,
	action = A_PacolaCustomAnim,
	var1 = 0,
	var2 = I,
	nextstate = S_PEPPINO_SECONDJUMP
}

PacolaCAVar3[S_PEPPINO_SECONDJUMP] = 2
PacolaCASkin["ngustavo"] = {}
PacolaCASkin["ngustavo"][S_PEPPINO_SECONDJUMP] = {
	v1 = 2,
	v2 = A
}

states[S_PEPPINO_MACH3JUMP] = {
	sprite = SPR_PLAY,
	frame = SPR2_TAL1|FF_ANIMATE,
	tics = 69420,
	nextstate = S_PEPPINO_MACH3,
	var1 = 63,
	var2 = 2
}

states[S_PEPPINO_MACHSKID] = {SPR_PLAY, SPR2_MLEE, 2, nil, 0, 0, S_PEPPINO_MACHSKID}

states[S_PEPPINO_MACHDRIFTTRNS2] = {SPR_PLAY, SPR2_TWIN|FF_SPR2ENDSTATE, 2, nil, S_PEPPINO_MACHDRIFT2, 0, S_PEPPINO_MACHDRIFTTRNS2}
states[S_PEPPINO_MACHDRIFTTRNS3] = {SPR_PLAY, SPR2_BNCE|FF_SPR2ENDSTATE, 2, nil, S_PEPPINO_MACHDRIFT3, 0, S_PEPPINO_MACHDRIFTTRNS3}

states[S_PEPPINO_MACHDRIFT2] = {SPR_PLAY, SPR2_FIRE, 2, nil, 0, 0, S_PEPPINO_MACHDRIFT2}
states[S_PEPPINO_MACHDRIFT3] = {SPR_PLAY, SPR2_FLT_, 2, nil, 0, 0, S_PEPPINO_MACHDRIFT3}

--states[S_PEPPINO_SUPLEXDASH] = {SPR_PLAY, SPR2_GRAB, 2, nil, 0, 0, S_PEPPINO_SUPLEXDASH}

states[S_PEPPINO_SUPLEXDASH] = {SPR_PLAY, SPR2_GRAB, 2, nil, 0, 0, S_PEPPINO_SUPLEXDASH}

states[S_PEPPINO_SUPLEXDASHCNCL] = {
	sprite = SPR_PLAY,
	frame = SPR2_TAL4|FF_SPR2ENDSTATE,
	tics = 2,
	nextstate = S_PEPPINO_SUPLEXDASHCNCL,
	var1 = S_PLAY_FALL
}

states[S_PEPPINO_AIRSUPLEXDASH] = {
	sprite = SPR_PLAY,
	frame = SPR2_SDHA,
	tics = -1,
	action = A_PacolaCustomAnim,
	var1 = 1,
	var2 = E,
	nextstate = S_PEPPINO_AIRSUPLEXDASH
}
-- i lovr u pacola #2
states[S_PEPPINO_LONGJUMP] = {
	sprite = SPR_PLAY,
	frame = SPR2_LOJU,
	tics = -1,
	action = A_PacolaCustomAnim,
	var1 = 1,
	var2 = L,
	nextstate = S_PEPPINO_LONGJUMP
}

PacolaCAVar3[S_PEPPINO_LONGJUMP] = 2

-- PacolaCASkin["nthe_noise"][S_PEPPINO_LONGJUMP] = {
-- 	v1 = 2,
-- 	v2 = E
-- }

states[S_PEPPINO_HAULINGIDLE] = {SPR_PLAY, SPR2_HLID, 2, nil, 0, 0, S_PEPPINO_HAULINGIDLE}
states[S_PEPPINO_HAULINGFALL] = {SPR_PLAY, SPR2_HLFL, 2, nil, 0, 0, S_PEPPINO_HAULINGFALL}
states[S_PEPPINO_HAULINGWALK] = {SPR_PLAY, SPR2_HLWA, 2, nil, 2, 2, S_PEPPINO_HAULINGWALK}

states[S_PEPPINO_CROUCH] = {SPR_PLAY, SPR2_CRCH, 2, nil, 2, 2, S_PEPPINO_CROUCH}
states[S_PEPPINO_CROUCHWALK] = {SPR_PLAY, SPR2_CRAL, 2, nil, 2, 2, S_PEPPINO_CROUCHWALK}
states[S_PEPPINO_CROUCHFALL] = {SPR_PLAY, SPR2_CRFA, 2, nil, 2, 2, S_PEPPINO_CROUCHFALL}

states[S_PEPPINO_ROLL] = {SPR_PLAY, SPR2_ROLL, 2, nil, 0, 0, S_PEPPINO_ROLL}

states[S_PEPPINO_DIVE] = {SPR_PLAY, SPR2_LAND, 2, nil, 0, 0, S_PEPPINO_DIVE}

states[S_PEPPINO_BELLYSLIDE] = {SPR_PLAY, SPR2_CLMB, 2, nil, 0, 0, S_PEPPINO_BELLYSLIDE}
states[S_PEPPINO_WALLCLIMB] = {SPR_PLAY, SPR2_SWIM, 1, nil, 2, 2, S_PEPPINO_WALLCLIMB}

--states[S_PEPPINO_SUPERJUMPSTARTTRNS] = {SPR_PLAY, SPR2_SJPR|FF_SPR2ENDSTATE, 2, nil, S_PEPPINO_SUPERJUMPSTART, 0, S_PEPPINO_SUPERJUMPSTARTTRNS}
states[S_PEPPINO_SUPERJUMPSTARTTRNS] = {
	sprite = SPR_PLAY,
	frame = SPR2_SJPR|FF_ANIMATE,
	tics = -1,
	var1 = 99,
	var2 = 2,
	nextstate = S_PEPPINO_SUPERJUMPSTART
}
states[S_PEPPINO_SUPERJUMPSTART] = {SPR_PLAY, SPR2_SJRE, 2, nil, 0, 0, S_PEPPINO_SUPERJUMPSTART}
states[S_PEPPINO_SUPERJUMP] = {SPR_PLAY, SPR2_SJGO, 2, nil, 0, 0, S_PEPPINO_SUPERJUMP}
states[S_PEPPINO_SUPERJUMPCANCELTRNS] = {SPR_PLAY, SPR2_SJCS|FF_SPR2ENDSTATE, 2, nil, S_PEPPINO_SUPERJUMPCANCEL, 2, S_PEPPINO_SUPERJUMPCANCELTRNS}
states[S_PEPPINO_SUPERJUMPCANCEL] = {SPR_PLAY, SPR2_SJCA, 2, nil, 0, 0, S_PEPPINO_SUPERJUMPCANCEL}

states[S_PEPPINO_BODYSLAMSTART] = {SPR_PLAY, SPR2_BSST|FF_SPR2ENDSTATE, 2, nil, S_PEPPINO_BODYSLAM, 2, S_PEPPINO_BODYSLAMSTART}
states[S_PEPPINO_BODYSLAM] = {SPR_PLAY, SPR2_BSFL, 2, nil, 0, 0, S_PEPPINO_BODYSLAM}
states[S_PEPPINO_BODYSLAMLAND] = {SPR_PLAY, SPR2_BSLD|FF_SPR2ENDSTATE, 2, nil, S_PLAY_STND, 0, S_PEPPINO_BODYSLAMLAND}

states[S_PEPPINO_DIVEBOMB] = {SPR_PLAY, SPR2_DVBM, 2, nil, 0, 0, S_PEPPINO_DIVEBOMB}
states[S_PEPPINO_DIVEBOMBEND] = {SPR_PLAY, SPR2_DVBE|FF_SPR2ENDSTATE, 2, nil, S_PLAY_STND, 0, S_PEPPINO_DIVEBOMBEND}

-- pacola i love you for this
states[S_PEPPINO_UPPERCUTEND] = {
	sprite = SPR_PLAY,
	frame = SPR2_UPCE,
	tics = -1,
	action = A_PacolaCustomAnim,
	var1 = 0, -- duration in tics to advance to next frame
	var2 = -1, -- if it should loop or not (and which frame should it loop to)
	nextstate = S_PEPPINO_UPPERCUTEND
}

PacolaCASkin["nthe_noise"][S_PEPPINO_UPPERCUTEND] = {
	v1 = 1,
	v2 = -1
}

states[S_PEPPINO_WALLJUMP] = {SPR_PLAY, SPR2_WJEN, -1, A_PacolaCustomAnim, 0, J, S_PEPPINO_WALLJUMP}
PacolaCASkin["nthe_noise"][S_PEPPINO_WALLJUMP] = {
	v1 = 2,
	v2 = A
}

// unfortunately the same cant be applied here
states[S_PEPPINO_FINISHINGBLOW1] = {SPR_PLAY, SPR2_FIB1, 2, nil, 0, 0, S_PEPPINO_FINISHINGBLOW1}
states[S_PEPPINO_FINISHINGBLOW2] = {SPR_PLAY, SPR2_FIB2, 2, nil, 0, 0, S_PEPPINO_FINISHINGBLOW2}
states[S_PEPPINO_FINISHINGBLOW3] = {SPR_PLAY, SPR2_FIB3, 2, nil, 0, 0, S_PEPPINO_FINISHINGBLOW3}
states[S_PEPPINO_FINISHINGBLOW4] = {SPR_PLAY, SPR2_FIB4, 2, nil, 0, 0, S_PEPPINO_FINISHINGBLOW4}
states[S_PEPPINO_FINISHINGBLOW5] = {SPR_PLAY, SPR2_FIB5, 2, nil, 0, 0, S_PEPPINO_FINISHINGBLOW5}
states[S_PEPPINO_FINISHINGBLOWUP] = {SPR_PLAY, SPR2_UGRA, 2, nil, 0, 0, S_PEPPINO_FINISHINGBLOWUP}

local time = 12

states[S_PEPPINO_TAUNT] = {SPR_PLAY, SPR2_TAUN, time, nil, 0, 0, S_PEPPINO_TAUNT}

states[S_PEPPINO_KUNGFU_1] = {SPR_PLAY, SPR2_KNFU, 2, nil, 0, 0, S_PEPPINO_KUNGFU_1}
states[S_PEPPINO_KUNGFU_2] = {SPR_PLAY, SPR2_KNF2, 2, nil, 0, 0, S_PEPPINO_KUNGFU_2}
states[S_PEPPINO_KUNGFU_3] = {SPR_PLAY, SPR2_KNF3, 2, nil, 0, 0, S_PEPPINO_KUNGFU_3}

states[S_PEPPINO_PARRY1] = {SPR_PLAY, SPR2_PARR, 1, nil, 0, 0, S_PEPPINO_PARRY1}
states[S_PEPPINO_PARRY2] = {SPR_PLAY, SPR2_PAR2, 1, nil, 0, 0, S_PEPPINO_PARRY2}

states[S_PEPPINO_UPSTUN] = {SPR_PLAY, SPR2_SJLA|FF_ANIMATE|A, 8*2, nil, 20, 2, S_PLAY_STND}
states[S_PEPPINO_MACH3STUN] = {SPR_PLAY, SPR2_M3HW|FF_ANIMATE|A, 12*2, nil, 11, 2, S_PLAY_STND}
states[S_PEPPINO_MACH2STUN] = {SPR_PLAY, SPR2_WLSP|FF_ANIMATE|A, 7*2, nil, 6, 2, S_PLAY_STND}
states[S_PEPPINO_PILEDRIVER] = {SPR_PLAY, SPR2_PIDR, 2, nil, 0, 0, S_PEPPINO_PILEDRIVER}
states[S_PEPPINO_PILEDRIVERLAND] = {SPR_PLAY, SPR2_PIDL|FF_SPR2ENDSTATE, 2, nil, S_PLAY_STND, 0, S_PEPPINO_PILEDRIVERLAND}

states[S_PEPPINO_BREAKDANCE1] = {SPR_PLAY, SPR2_BRD1, 2, nil, 0, 0, S_PEPPINO_BREAKDANCE1}
states[S_PEPPINO_BREAKDANCE2] = {SPR_PLAY, SPR2_BRD2, 2, nil, 0, 0, S_PEPPINO_BREAKDANCE2}
states[S_PEPPINO_BREAKDANCELAUNCH] = {SPR_PLAY, SPR2_BTAT, 2, nil, 0, 0, S_PEPPINO_BREAKDANCELAUNCH}

states[S_PEPPINO_BOOGIE] = {SPR_PLAY, SPR2_TIRE, 3, nil, 0, 0, S_PEPPINO_BOOGIE}

states[S_PEPPINO_SLOPEJUMP] = {
	sprite = SPR_PLAY,
	frame = SPR2_PRAM,
	tics = -1,
	action = A_PacolaCustomAnim,
	var1 = 1,
	var2 = I,
	nextstate = S_PEPPINO_SLOPEJUMP
}

if not PacolaCASkin["nthe_noise"]
	PacolaCASkin["nthe_noise"] = {}
end

PacolaCASkin["nthe_noise"][S_PEPPINO_SLOPEJUMP] = {
	v2 = A
}

if not PacolaCAVar3
	rawset(_G, "PacolaCAVar3", {}) -- so you can change the animation speed when it loops
	rawset(_G, "PacolaCAVar4", {}) -- the frame it ends on, by nick
	rawset(_G, "PacolaCASkin", {}) -- so you stuff can be skin specific
end

states[S_PEPPINO_SUPERTAUNT1] = {SPR_PLAY, SPR2_STA1|FF_ANIMATE|A, 10*2, nil, 9, 2, S_PLAY_STND}
states[S_PEPPINO_SUPERTAUNT2] = {SPR_PLAY, SPR2_STA2|FF_ANIMATE|A, 10*2, nil, 9, 2, S_PLAY_STND}
states[S_PEPPINO_SUPERTAUNT3] = {SPR_PLAY, SPR2_STA3|FF_ANIMATE|A, 10*2, nil, 9, 2, S_PLAY_STND}
states[S_PEPPINO_SUPERTAUNT4] = {SPR_PLAY, SPR2_STA4|FF_ANIMATE|A, 10*2, nil, 9, 2, S_PLAY_STND}

states[S_PEPPINO_PANIC] = {SPR_PLAY, SPR2_PANC, 2, nil, 0, 0, S_PEPPINO_PANIC}
states[S_PEPPINO_SWINGDING] = {SPR_PLAY, SPR2_SWDN, 2, nil, 0, 0, S_PEPPINO_SWINGDING}
states[S_PEPPINO_SWINGDINGEND] = {SPR_PLAY, SPR2_SWDE|FF_SPR2ENDSTATE, 2, nil, S_PLAY_STND, 2, S_PEPPINO_SWINGDINGEND}

states[S_PEPPINO_FIREASS] = {
	sprite = SPR_PLAY,
	frame = SPR2_TAL2|FF_ANIMATE,
	tics = -1,
	nextstate = S_PEPPINO_FIREASSGRND,
	var1 = 35,
	var2 = 2
}

states[S_PEPPINO_FIREASSGRND] = {
	sprite = SPR_PLAY,
	frame = SPR2_TAL3|FF_ANIMATE,
	tics = -1,
	nextstate = S_PEPPINO_FIREASSGRND,
	var1 = 35,
	var2 = 2
}

-- NOISE SPRITES?? NO WAY!!

states[S_NOISE_SPIN] = {
	sprite = SPR_PLAY,
	frame = SPR2_SJCA,
	tics = -1,
	action = A_PacolaCustomAnim,
	var1 = 0,
	var2 = H,
	nextstate = S_NOISE_SPIN
}

states[S_NOISE_CRUSHER] = {
	sprite = SPR_PLAY,
	frame = SPR2_SJCS,
	tics = -1,
	action = A_PacolaCustomAnim,
	var1 = 1,
	var2 = H,
	--nextstate = S_NOISE_SPIN -- NICK YOU FORGOT TO CHANGE THIS AND THE FORCE STATE THING DOESNT CHANGE IT IF NEXTSTATE IS THE SAME ANIMATION AS IT!!!!!!
	nextstate = S_NOISE_CRUSHER
}
states[S_NOISE_CRUSHEREND] = {
	sprite = SPR_PLAY,
	frame = SPR2_LAND|FF_SPR2ENDSTATE,
	tics = 2,
	action = nil,
	var1 = S_PLAY_STND,
	var2 = 0,
	nextstate = S_NOISE_CRUSHEREND
}

freeslot("S_NOISE_DRILLAIR", "S_NOISE_DRILLLAND")

states[S_NOISE_DRILLAIR] = {
	sprite = SPR_PLAY,
	frame = SPR2_DVBE|FF_ANIMATE|A,
	tics = -1,
	var1 = 1,
	var2 = 2,
	nextstate = S_NOISE_DRILLAIR
}

states[S_NOISE_DRILLLAND] = {
	sprite = SPR_PLAY,
	frame = SPR2_DVBL|FF_ANIMATE|A,
	tics = -1,
	var1 = 1,
	var2 = 4,
	nextstate = S_NOISE_DRILLLAND
}

freeslot("S_PEPPINO_LEVELCOMPLETE")

states[S_PEPPINO_LEVELCOMPLETE] = {
	sprite = SPR_PLAY,
	frame = SPR2_TAL7,
	tics = 2,
	nextstate = S_PEPPINO_LEVELCOMPLETE
}

states[S_GUSTAVO_WALLJUMP] = {
	sprite = SPR_PLAY,
	frame = SPR2_SWIM|FF_ANIMATE,
	tics = -1,
	nextstate = S_GUSTAVO_WALLJUMP,
	var1 = 63,
	var2 = 4
}