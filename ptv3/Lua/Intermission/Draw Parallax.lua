return function(v, x, y, scale, patch, flags, plax, color)
	x = $ or 0
	y = $ or 0
	scale = $ or FU
	plax = $ or {x = true, y = false}

	local patchWidth = patch.width*scale
	local patchHeight = patch.height*scale
	local screenWidth = FixedDiv(v.width()*FU, v.dupx()*FU)
	local screenHeight = FixedDiv(v.height()*FU, v.dupy()*FU)

	x = $ % patchWidth
	y = $ % patchHeight

	v.drawScaled(x, y, scale, patch, flags, color)


	if plax.x then
		local _x = x
		while x > 0 do
			x = $-patchWidth
			v.drawScaled(x, y, scale, patch, flags, color)
		end
		
		x = _x
	
		while x+patchWidth < screenWidth do
			x = $+patchWidth
			v.drawScaled(x, y, scale, patch, flags, color)
		end

		x = _x
	end
	if plax.y then
		local _y = y
		while y > 0 do
			y = $-patchHeight
			v.drawScaled(x, y, scale, patch, flags, color)
		end
		
		y = _y
	
		while x+patchHeight < screenWidth do
			y = $+patchWidth
			v.drawScaled(x, y, scale, patch, flags, color)
		end

		y = _y
	end
end