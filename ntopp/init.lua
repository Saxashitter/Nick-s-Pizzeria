//// NTOPP ////

rawset(_G, 'ntopp_v2', {})
ntopp_v2.machs = {
	15*FU,
	20*FU,
	40*FU,
	75*FU
}

rawset(_G, 'L_Choose', function(...)
	local args = {...}
	local choice = P_RandomRange(1,#args)
	return args[choice]
end)

dofile('Libs/customhudlib.lua')
dofile('Libs/PacolaAnim.lua')

dofile("noisecolors.lua") -- this has stuff for noise's skin color, needs to be loaded BEFORE Hooks.lua

dofile('Freeslot.lua')
dofile('Afterimages.lua')
dofile('White Flash.lua')
dofile('Enums.lua')
dofile('TV.lua')
dofile('Options.lua')
dofile('CVars.lua')
dofile('FSM.lua')
dofile('HUD.lua')

dofile('Hooks.lua')
dofile('Functions.lua')

for _,p in ipairs({'Peppino'}) do
	local path = "States/"..p.."/"

	dofile(path..'Base.lua')
	for i = 1,3 do
		dofile(path.."Machs/"..i..".lua")
	end
	dofile(path.."Skid.lua")
	dofile(path.."Drift.lua")
	dofile(path.."Grab.lua")
	dofile(path.."Grabbed Enemy.lua")
	dofile(path.."Kill Enemy.lua")
	dofile(path.."Crouch.lua")
	dofile(path.."Roll.lua")
	dofile(path..'Dive.lua')
	dofile(path..'Belly Slide.lua')
	dofile(path.."Super Jump.lua")
	dofile(path.."Pain.lua")
	dofile(path.."Wall Climb.lua")
	dofile(path.."Body Slam.lua")
	dofile(path.."Uppercut.lua")
	dofile(path.."Taunt.lua")
	dofile(path.."Grabbed.lua")
	dofile(path.."Parry.lua")
	dofile(path.."Stun.lua")
	dofile(path.."Piledriver.lua")
	dofile(path.."Breakdance.lua")
	dofile(path.."Super Taunt.lua")
	dofile(path.."Swing Ding.lua")
	dofile(path+"Fireass.lua")
end

-- gustavo and bread
-- -Pacola
local gp = "States/Gustavo/"
dofile(gp+"Base.lua")
dofile(gp+"Spin (Grab).lua")

dofile("Pacola's Stuff/Immortability/Normal Levels/functionality.lua")
dofile("Pacola's Stuff/Immortability/Normal Levels/hud.lua")
dofile("Pacola's Stuff/Immortability/Boss Levels/functionality.lua")
dofile("Pacola's Stuff/Immortability/Boss Levels/hud.lua")

dofile('States/NoiseMoveset')
dofile("Effects/TGTLS.lua")
dofile("Effects/Robofox.lua")

local function PTV3_Support()

	local function TP_Player(p)
		if not (p.mo and isPTSkin(p.mo.skin) and p.pvars) then return end

		fsm.ChangeState(p, ntopp_v2.enums.BASE)
		p.pvars.movespeed = ntopp_v2.machs[1]
	end

	PTV3:insertCallback('TeleportPlayer', TP_Player)

	ntopp_v2.ptv3 = true
end

if not ntopp_v2.ptv3 and PTV3 then
	PTV3_Support()
end

addHook('ThinkFrame', do
	if not ntopp_v2.ptv3 and PTV3 then
		PTV3_Support()
	end
end)