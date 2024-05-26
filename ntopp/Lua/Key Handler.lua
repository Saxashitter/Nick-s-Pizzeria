 //button mapping woooooooo! -rbf
 
local atkbutton
local runbutton
local upbutton
local downbutton
local tauntbutton

local function consoleassist(player, arg, text) //less ctrl+c, ctrl+v
if arg == "c1"
CONS_Printf(player, "[ "+text+" ] is now set to custom 1.")
return BT_CUSTOM1
end
if arg == "c2"
CONS_Printf(player, "[ "+text+" ] is now set to custom 2.")
return BT_CUSTOM2
end
if arg == "c3"
CONS_Printf(player, "[ "+text+" ] is now set to custom 3.")
return BT_CUSTOM3
end
if arg == "fire"
CONS_Printf(player, "[ "+text+" ] is now set to fire.")
return BT_ATTACK
end
if arg == "tossflag"
CONS_Printf(player, "[ "+text+" ] is now set to tossflag.")
return BT_TOSSFLAG
end
if arg == "spin"
CONS_Printf(player, "[ "+text+" ] is now set to spin.")
return BT_USE
end
if arg == "firenormal"
CONS_Printf(player, "[ "+text+" ] is now set to firenormal.")
return BT_FIRENORMAL
end
if arg == nil
CONS_Printf(player, "sets the [ "+text+" ] button. (c1, c2, c3, tossflag, fire, firenormal, spin)")
else
CONS_Printf(player, "that button isn't usable.")
end
end

//next is just commands, please shortend this shite

COM_AddCommand("tauntkey", function(p, arg)// 1 of 5
if p.mo and p.mo.valid
p.tauntbutton = consoleassist(p, arg, "taunt")
end
end)

COM_AddCommand("upkey", function(p, arg)// 2 of 5
if p.mo and p.mo.valid
p.upbutton = consoleassist(p, arg, "up")
end
end)

COM_AddCommand("downkey", function(p, arg)// 3 of 5
if p.mo and p.mo.valid
p.downbutton = consoleassist(p, arg, "down")
end
end)

COM_AddCommand("attackkey", function(p, arg)// 4 of 5
if p.mo and p.mo.valid
p.downbutton = consoleassist(p, arg, "attack")
end
end)

COM_AddCommand("runkey", function(p, arg)// 5 of 5
if p.mo and p.mo.valid
p.runbutton = consoleassist(p, arg, "run")
end
end)


rawset(_G, "PT_FindPressed", function(p, btnpicked, whatpressed)// for finding what button/key the player is pressing.
if p and p.valid and p.mo and p.mo.valid
if btnpicked == nil // you forgot to add the string, ya dingus.
print("idiot")
return false
elseif (btnpicked == "atk") and (whatpressed & p.atkbutton)
return true
elseif (btnpicked == "run") and (whatpressed & p.runbutton)
return true
elseif (btnpicked == "up")
if ((p.cmd.forwardmove >= 5) and ((p.mo.flags2 & MF2_TWOD) or (maptol & TOL_2D)))
return true
elseif (whatpressed & p.upbutton)
return true
end
elseif (btnpicked == "down")
if ((p.cmd.forwardmove <= -5) and ((p.mo.flags2 & MF2_TWOD) or (maptol & TOL_2D)))
return true
elseif (whatpressed & p.downbutton)
return true
end
elseif (btnpicked == "taunt") and (whatpressed & p.tauntbutton)
return true
elseif btnpicked == nil
print("idiot")
return false
else
return false
end
end
end)


addHook("PreThinkFrame", function()
	for p in players.iterate do
		if p.tauntbutton == nil //nil values suck
		p.atkbutton = BT_CUSTOM1
		p.runbutton = BT_USE
		p.upbutton = BT_CUSTOM3
		p.downbutton = BT_CUSTOM2
		p.tauntbutton = BT_TOSSFLAG
		end
	//todo: saving the values to a config file, idk how
	end
end)













