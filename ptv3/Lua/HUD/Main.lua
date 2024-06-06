local PizzaTimeHUD = dofile "HUD/Pizza Time"
local LapHUD = dofile "HUD/Laps"
local SecretHUD = dofile "HUD/Secrets"
local TimerHUD = dofile "HUD/Normal Timer"
local EndHUD = dofile "HUD/Overtime End"
local InventoryHUD = dofile "HUD/Inventory"
local RankHUD = dofile "HUD/Ranks"
local ComboHUD = dofile "HUD/Combo"

function PTV3.HUD_returnTime(startTime, length, offset)
	if offset == nil then
		offset = 0
	end
	return max(0, min((leveltime-(startTime+offset))*(FixedDiv(FU, length))/35, FU))
end

customhud.SetupItem("Laps", "ptv3", LapHUD, "game", 1)
customhud.SetupItem("Pizza Time", "ptv3", PizzaTimeHUD, "game", 1)
customhud.SetupItem("Secrets", "ptv3", SecretHUD, "game", 1)
customhud.SetupItem("Timer", "ptv3", TimerHUD, "game", 1)
customhud.SetupItem("End", "ptv3", EndHUD, "game", 1)
customhud.SetupItem("Inventory", "ptv3", InventoryHUD, "game", -1)
customhud.SetupItem("Rank", "ptv3", RankHUD, "game", -1)
customhud.SetupItem("Combo", "ptv3", ComboHUD, "game", -1)