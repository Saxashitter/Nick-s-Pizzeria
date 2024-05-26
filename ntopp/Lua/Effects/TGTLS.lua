addHook("PlayerThink", function(p)
	if not (p.mo and p.mo.valid) return end
	
	if leveltime%10 == 0
	and p.mo.state == S_PEPPINO_MACH4
		P_CreateRing(p)
	end
	if leveltime%10 == 0
	and p.mo.state == S_PEPPINO_SUPERJUMP
		local ring = P_SpawnMobj(p.mo.x,p.mo.y,p.mo.z,MT_THOK)
		ring.state = S_MACH4RING
		ring.fuse = 999
		ring.tics = 20
		ring.angle = p.drawangle+ANGLE_90
		ring.scale = p.mo.scale-FRACUNIT/2
		ring.destscale = p.mo.scale*2
		ring.colorized = true
		ring.color = SKINCOLOR_WHITE
		ring.renderflags = $|RF_FLOORSPRITE
		if (p.mo.eflags & MFE_VERTICALFLIP)
			ring.flags2 = $|MF2_OBJECTFLIP
			ring.eflags = $|MFE_VERTICALFLIP
		end
	end
end)