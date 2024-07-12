local ot = {}

ot.x = 160*FU
ot.y = 320*FU
ot.friction = 0
ot.xfriction = 0
ot.yfriction = 0
ot.flags = V_SNAPTOBOTTOM
ot.drawtype = "string"
ot.string = "OVERTIME!"

addHook("MapChange", do
	ot.y = 320*FU
end)

function ot.func(v, player, cam, obj)
	local height = FixedDiv(v.height(), v.dupy())
	if PTV3:isPTV3()
	and PTV3.overtime then
		ot.momy = -4*FU
		if ot.y < 0-((320*FU)-height) then
			ot.momy = 0
		end
	end
end

table.insert(hudobjs, ot)