local CommonThing = require(game.ServerScriptService.CommonThings)

game.Players.PlayerAdded:Connect(function(Player)
	local StatsSource = game.ServerScriptService.Stats:Clone()
	StatsSource.Parent = Player
	local Stats = require(StatsSource)
	Stats.OnPlayerAdded()
end)

game.Players.PlayerRemoving:Connect(function(Player)
	local Stats = require(Player.Stats)
	Stats.OnPlayerRemoving()
end)

CommonThing.TeleportationButton(game.Workspace.Teleports.TeleportToPve,game.Workspace.Teleports.BackFromPve)
ChangePvp = function(Player,Value)
	local Status = require(Player.Status)
	Status.Pvp = Value
end
CommonThing.TeleportationButton(game.Workspace.Teleports.TeleportToPvp,game.Workspace.Teleports.BackFromPvp,ChangePvp)

local Debounce = true
game.Workspace.Map.StatsReset.Touched:Connect(function(Hit)
	local Player = game.Players:GetPlayerFromCharacter(Hit.Parent)
	if Player then
		if Debounce then
			Debounce = false
			CommonThing.ResetStats(Player)
			wait(1)
			Debounce = true
		end
	end
end)