
local mm = {}
local function resetMM()
	mm = {
		dark = true,
		activate = false,
		time = 0,
		ptcountvar = 0,
		curmus = mapmusname,
		jumpscare = {
			active = false,
			time = 0,
			scale = FU,
			quit = false
		}
	}
end
resetMM()

local function activateTrans()
	mm.ptcountvar = 7
	mm.time = 5
	mm.activate = true
	S_StartSound(nil, sfx_mmlswt)
end

addHook('HUD', function(v)
	local scale = FixedDiv((v.height()/v.dupx())*FU, 200*FU)
	local scale2 = FixedDiv(200*FU, 540*FU)
	v.drawFill()
	local pos = S_GetMusicPosition()
	local js = mm.jumpscare
	
	if menuactive
	and mm.dark
	and not mm.activate
		activateTrans()
	elseif not menuactive
	and not mm.dark
		mm.activate = false
		mm.dark = true
		S_StartSound(nil, sfx_mmlswt)
	elseif mm.activate
		mm.time = $-1
		
		if mm.time <= 0
			mm.dark = not $
			
			if mm.ptcountvar > 0
				mm.ptcountvar = $-1
				if dark
					mm.time = 2+v.RandomRange(0, 3)
				else
					mm.time = 6+v.RandomRange(0, 5)
				end
				
				if mm.ptcountvar <= 0
					mm.dark = false
                    mm.time = 40
					mm.activate = false
                end
			end
		end
		
		if pos < 13*MUSICRATE+185
			S_SetMusicPosition(13*MUSICRATE+185)
		end	
	end
	
	if mm.dark
		js.time = $+1
		
		v.drawScaled((320*FU)/2, (200*FU)/2, FixedMul(scale2, scale), v.cachePatch("DARKPEP_MM"))
		
		if pos > 4*MUSICRATE+808
		and not mm.activate
		and mm.curmus == "_title"
			S_SetMusicPosition(0)
		end
	else
		js.time = 0
		
		v.drawScaled((320*FU)/2, (200*FU)/2, FixedMul(scale2, scale), v.cachePatch('BACKGROUND_MM'))
		v.drawScaled((320*FU)/2, (200*FU)/2, FixedMul(scale2, scale), v.cachePatch('PEPPINO_MM'))
		v.drawScaled((320*FU)/2, (200*FU)/2, FixedMul(scale2, scale), v.cachePatch('NTOPP_MM'))
		
		if pos < 13*MUSICRATE+185
		and not mm.activate
		and mm.curmus == "_title"
			S_SetMusicPosition(16*MUSICRATE+794)
		end
	end
	
	if js.time >= FixedRound(2400*FixedDiv(35, 60))
	--if js.time >= TICRATE
	and not js.active
		S_StartSound(nil, sfx_mmjsc)
		js.active = true
	end
	
	if js.active
		--js.scale = $+FixedMul(2*FU/10, FixedDiv(35, 60)) -- is this more accurate?? idk, it's a slower one though
		js.scale = $+2*FU/10
		v.drawScaled((320*FU)/2, (200*FU)/2, FixedMul(FixedMul(scale2, scale), js.scale), v.cachePatch("JUMPSCARE_MM"))
		if js.scale >= 5*FU
			js.quit = true
		end
		if js.scale >= 8*FU -- did we not have a titlemap (which means thinkframe doesnt happen)? well, just do what the pt code does and get rid of it (how does it get past 8 size in pt......)
			js.active = false
			js.time = 0
			js.scale = FU
			js.quit = false
		end
	end
end, 'title')

addHook("ThinkFrame", function()
	if gamestate ~= GS_TITLESCREEN resetMM() return end
	
	local js = mm.jumpscare
	if js.quit
		COM_BufInsertText(consoleplayer, "quit")
	end
	mm.curmus = S_MusicName(consoleplayer)
end)

addHook("MusicChange", function(oldn, newn, mf, loop, _, fi, fo)
	local o = string.lower(oldn)
	local n = string.lower(newn)
	
	mm.curmus = n -- MAKING SURE it gets sent (since thinkframe only works if the titlescreen has a titlemap (which might not be always idk im kind of dumb)
end)

//// RANK SCREEN CODE ////

local SPRITE_DATA = {
	['P'] = {
		frames = 61,
		song = "PRANK"
	},
	['S'] = {
		frames = 10,
		song = "SRANK"
	},
	['A'] = {
		frames = 10,
		song = "ARANK"
	},
	['B'] = {
		frames = 10,
		song = "BRANK"
	},
	['C'] = {
		frames = 10,
		song = "CRANK"
	},
	['D'] = {
		frames = 10,
		song = "DRANK"
	}
}

ntopp_v2.RANK_SCREEN_TIME = 20*TICRATE
ntopp_v2.PLAY_RANK_SCREEN = false
local GAME_SHADE = 10
local HUD_SHADE = 10
local CURFRAME = 1
local CURTIME = 0
local RANK_ANIMATION = false
local has_played = false

local function initrank()
	ntopp_v2.RANK_SCREEN_TIME = 20*TICRATE
	ntopp_v2.PLAY_RANK_SCREEN = false
	GAME_SHADE = 10
	HUD_SHADE = 10
	CURFRAME = 1
	CURTIME = 0
	RANK_ANIMATION = false
end

addHook('MapChange', function()
	initrank()
	has_played = false
end)

// PIZZA TIME SPICE RUNNERS RANK SCREEN CHECK
addHook('PostThinkFrame', do
	if not consoleplayer then return end
	if not consoleplayer.mo then return end
	if GT_PTSPICER and gametype ~= GT_PTSPICER then return end
	if not (isPTSkin(consoleplayer.mo.skin) and consoleplayer.ntoppv2_ranks ~= false) then 
		return 
	end
	
	if not PTSR then return end
	
	if not PTSR.gameover then return end
	if not ntopp_v2.PLAY_RANK_SCREEN and not has_played then
		ntopp_v2.RANK_GOT = consoleplayer.ptsr_rank
		ntopp_v2.PLAY_RANK_SCREEN = true
		has_played = true
	end
	if PTSR:inVoteScreen() and ntopp_v2.PLAY_RANK_SCREEN then
		initrank()
		return
	end
	
end)

// RANK SCREEN THINKER, ADDED IN A SEPARATE HOOK TO SUPPORT PTSR
addHook('ThinkFrame', do
	if not consoleplayer then return end
	if not consoleplayer.mo then return end
	if not isPTSkin(consoleplayer.mo.skin) then return end
	if consoleplayer.ntoppv2_ranks == false then return end
	if not ntopp_v2.PLAY_RANK_SCREEN then return end
	local p = consoleplayer

	local sprite = SPRITE_DATA[ntopp_v2.RANK_GOT]
	
	if ntopp_v2.RANK_SCREEN_TIME then
		ntopp_v2.RANK_SCREEN_TIME = $-1
	end

	if ntopp_v2.RANK_SCREEN_TIME < 560 then
		RANK_ANIMATION = true
		if not (CURTIME % 2) and CURFRAME < sprite.frames then
			CURFRAME = $+1
		end
		CURTIME = $+1
	end
	
	if GAME_SHADE then
		GAME_SHADE = $-1
	end
	if not (GAME_SHADE) and HUD_SHADE then
		HUD_SHADE = $-1
	end
end)

local function drawAlphaBox(v,alpha,flags,color)
	if alpha >= 10 then return end
	local g = v.cachePatch(color..'G')
	local f = flags
	local a = alpha<<V_ALPHASHIFT
	if alpha > 0 and alpha < 10 then
		f = $|a
	end

	return v.drawStretched(0,0,v.width()*FU,v.height()*FU,g,f)
end

local function drawAlphaSprite(v,x,y,scale,sprite,alpha,flags,color)
	if alpha >= 10 then return end
	local f = flags
	local a = alpha<<V_ALPHASHIFT
	if alpha > 0 and alpha < 10 then
		if f ~= nil then
			f = $|a
		else
			f = a
		end
	end

	return v.drawScaled(x,y,scale,sprite,f,color)
end

local function the_hud(v)
	if not (consoleplayer and consoleplayer.mo) then return end
	if not isPTSkin(consoleplayer.mo.skin) then return end
	if (consoleplayer.ntoppv2_ranks == false) then return end
	if not ntopp_v2.PLAY_RANK_SCREEN then return end

	local scale = FixedDiv((v.height()/v.dupx())*FU, 200*FU)
	local scale2 = FixedDiv(200*FU, 540*FU)
	local frscale = FixedMul(scale2, scale)
	
	local RANK_GOT = ntopp_v2.RANK_GOT
	
	local spriteanim = {}
	for i = 1,SPRITE_DATA[RANK_GOT].frames do
		table.insert(spriteanim, v.cachePatch('RANKSCR_'..RANK_GOT..i))
	end

	drawAlphaBox(v,GAME_SHADE,V_SNAPTOLEFT|V_SNAPTOTOP,'BLACK')
	drawAlphaBox(v,HUD_SHADE,V_SNAPTOLEFT|V_SNAPTOTOP,'WHITE')
	
	local spr2 = v.getSprite2Patch(consoleplayer.mo.skin, 'STND', false, A, 5)
	if not RANK_ANIMATION then
		drawAlphaSprite(v, 160*FU, 125*FU, FixedMul(scale2, scale), spr2, HUD_SHADE, nil, v.getColormap(consoleplayer.mo.skin,consoleplayer.mo.color))
	end
	
	local rankscr = spriteanim[CURFRAME]
	if not RANK_ANIMATION then return end
	local idkig = FixedMul(960*FU, frscale)
	local idkig2 = FixedMul(540*FU, frscale)
	if (ntopp_v2.RANK_SCREEN_TIME > 310) then
		drawAlphaSprite(v, 160*FU-(idkig/2), 100*FU-(idkig2/2), frscale, rankscr, HUD_SHADE, nil, v.getColormap(consoleplayer.mo.skin,consoleplayer.mo.color))
	else
		drawAlphaSprite(v, 160*FU-(idkig/2), 100*FU-(idkig2/2), frscale, v.cachePatch('RANKEND_'..RANK_GOT), HUD_SHADE, nil, v.getColormap(consoleplayer.mo.skin,consoleplayer.mo.color))
	end
end

customhud.SetupItem("NTOPP_rank", "ntopp", the_hud, "game", 1)