local files = {
	"Banana",
	"Shotgun"
}

PTV3.items = {}

function PTV3:addItem(item)
	self.items[item.name] = item
end

for _,i in ipairs(files) do
	PTV3:addItem(dofile("Items/"..i))
end

function PTV3:givePlayerItem(p, item)
	if not p.ptv3 then return end

	p.ptv3.curItem = item
end

function PTV3:useItem(p)
	if not p.mo then return end
	if not p.ptv3 then return end
	if not p.ptv3.curItem then return end

	local rawitem = self.items[p.ptv3.curItem]
	local item = P_SpawnMobjFromMobj(p.mo, 0,0,0, rawitem.object)
	item.target = p.mo

	if rawitem.use then
		rawitem.use(item, p.mo)
	end

	PTV3:logEvent(p.name.." has used "..rawitem.name.."!")
	
	p.ptv3.curItem = nil
end