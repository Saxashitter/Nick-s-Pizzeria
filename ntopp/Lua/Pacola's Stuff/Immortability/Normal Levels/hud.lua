
-- the hud
-- no hu d functionality
-- its essentially part of the non hud stuff at this point
-- for lnormal leveols :D

addHook("HUD", function(v, p)
	if not (p.mo and p.mo.valid)
	or not isIM(p.mo.skin)
	or p.ntoppimmortal == nil
	or not p.ntoppimmortal.difficulty return end
	
	local i = p.ntoppimmortal
	local d = i.difft
	
	local ws = FixedDiv(v.width(), 960)
	local hs = FixedDiv(v.height(), 540)
	
	if d.sframe < 0 return end
	
	if d.ustatic
		local uf = min(FixedRound(d.sframe)/FU, 9)
		v.drawStretched(0, 0, ws, hs, v.cachePatch("TDSTATIC"+uf), V_NOSCALESTART|V_NOSCALEPATCH|V_PERPLAYER)
	else
		local plyrclr = v.getColormap(p.skin, p.skincolor)
		local bg = (p.mo.skin == "nthe_noise" and "TECHDIFFNOISEBG") or "TECHDIFFBG"
		v.drawStretched(0, 0, ws, hs, v.cachePatch(bg), V_NOSCALESTART|V_NOSCALEPATCH|V_PERPLAYER)
		v.drawStretched(300*ws, 352*hs, ws, hs, v.cachePatch("TECHDIFF"+d.frame), V_NOSCALESTART|V_NOSCALEPATCH|V_PERPLAYER, plyrclr)
		if v.patchExists("TECHDIFF"+d.frame+"SC")
			local sclr = v.getColormap(p.skin, (NoiseSkincolor[p.skincolor] or SKINCOLOR_FLESHEATER))
			v.drawStretched(300*ws, 352*hs, ws, hs, v.cachePatch("TECHDIFF"+d.frame+"SC"), V_NOSCALESTART|V_NOSCALEPATCH|V_PERPLAYER, sclr)
		end
	end
end, "game")