return function(v,p)
	if not p.ptv3 then return end
	local rank = PTV3.ranks[p.ptv3.rank]
	local rank_patch = v.cachePatch(rank.rank.."RANK")

	local x = 50*FU
	local y = (42+16+10)*FU
	local s = FU/3
	
	if p.ptv3.rank_changetime >= 0 then
		local time = PTV3.HUD_returnTime(p.ptv3.rank_changetime, FU/8)

		if time < FU then
			s = ease.linear(time, FU/2, FU/3)
		end
	end

	x = $-((rank_patch.width/2)*s)
	y = $-((rank_patch.width/2)*s)

	v.drawScaled(x, y, s, rank_patch, V_SNAPTOLEFT|V_SNAPTOTOP)

	if rank.fill then
		local percent = PTV3:returnNextRankPercent(p)
		if percent == 0 then return end

		local y = y+(rank_patch.height*s)-(rank_patch.height*FixedMul(percent, s))
		local croph = FixedMul(rank_patch.height*FU, max(0,percent))
		local cropy = (rank_patch.height*FU)-croph

		v.drawCropped(
			x, y,
			s, s,
			v.cachePatch(rank.rank.."FILL"),
			V_SNAPTOLEFT|V_SNAPTOTOP, nil,
			0, cropy,
			rank_patch.width*FU,
			croph
		)
	end
end