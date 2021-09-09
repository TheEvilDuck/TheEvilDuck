local Player = game.Players:GetPlayerFromCharacter(script.Parent)
local Stats = require(Player:WaitForChild("Stats"))
Stats.OnCharacterAdded(script.Parent)