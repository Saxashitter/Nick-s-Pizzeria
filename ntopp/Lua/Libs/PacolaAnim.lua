-- BY PACOLA!!

-- the action stuff
-- which is the actual action definition
-- and the stuff that animates you

if (PacolaCAVar3 or PacolaCAVar4 or PacolaCASkin) then return end

rawset(_G, "PacolaCAVar3", {}) -- so you can change the animation speed when it loops
rawset(_G, "PacolaCAVar4", {}) -- the frame it ends on, by nick
rawset(_G, "PacolaCASkin", {}) -- so you stuff can be skin specific

-- alright so, var1, is how long it takes to go to the next frame (in tics)
-- and var2 is the frame which it is going to loop to
-- if you make var2 be -1 or the last animation frame (or higher than it), it won't loop
-- otherwise it you make it be something like D and you have H frames
-- it'll take you to frame D after the anim finishes
-- var3, (the table that i like, just made) let's you change var1 when you loop the anim
-- so var1 being 3 and var2 being 1 would make the anim faster when it loops.

function A_PacolaCustomAnim(mo, v1, v2) -- var1 is the anim frames, while var2 is whether it should loop or not (read the one above this, this one is outdated)
	if not (mo.player and mo.player.valid) return end
	
	local animvar = v1 or 0
	local animvar2 = v1 or 0
	local loopvar = v2 or -1
	local endvar = nil
	local startvar = nil
	
	if tonumber(PacolaCAVar3[mo.state])
		animvar2 = tonumber(PacolaCAVar3[mo.state])
	end
	if tonumber(PacolaCAVar4[mo.state])
		endvar = tonumber(PacolaCAVar4[mo.state])
	end
	
	if animvar < 0
		animvar = 0
	end
	if animvar2 < 0
		animvar2 = 0
	end
	
	if PacolaCASkin[mo.skin]
	and PacolaCASkin[mo.skin][mo.state]
		local skin = PacolaCASkin[mo.skin][mo.state]
		if skin.v1 ~= nil
			animvar = skin.v1
		end
		if skin.v2 ~= nil
			loopvar = skin.v2
		end
		if skin.v3 ~= nil
			animvar2 = skin.v3
		else
			animvar2 = animvar
		end
		if skin.v4 ~= nil then
			endvar = skin.v4
		end
	end
	
	if not mo.player.paccustomanim
	or mo.state ~= mo.player.pcoldstate
		mo.player.paccustomanim = {
			frame = A,
			animdur = animvar,
			animdur2 = animvar2,
			endf = endvar,
			loop = loopvar,
			looped = false
		}
		mo.player.pcanimtime = animvar
		mo.player.pcoldstate = mo.state
	end
end

addHook("PlayerThink", function(p)
	if not p.mo then return end
	if states[p.mo.state].action ~= A_PacolaCustomAnim
	and p.paccustomanim
		p.paccustomanim = nil
	end
	
	if p.paccustomanim == nil
	or states[p.mo.state].action ~= A_PacolaCustomAnim return end
	
	local pcanim = p.paccustomanim
	local numframes = ((p.mo.sprite2 ~= SPR2_STND) and skins[p.mo.skin].sprites[p.mo.sprite2].numframes) or B
	if p.paccustomanim.endf then
		numframes = min($, p.paccustomanim.endf)
	end
	
	if p.pcanimtime
		p.pcanimtime = $-1
	else
		if pcanim.frame+1 < numframes
			pcanim.frame = $+1
		elseif pcanim.loop ~= -1
		and pcanim.loop < numframes-1
			pcanim.frame = pcanim.loop
			pcanim.looped = true
		end
		
		if pcanim.looped
			p.pcanimtime = pcanim.animdur2
		else
			p.pcanimtime = pcanim.animdur
		end
	end
	
	p.mo.frame = pcanim.frame
end)