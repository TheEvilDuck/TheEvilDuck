local Used = false
script.Parent.Touched:Connect(function(Hit)
		local Player = game.Players:GetPlayerFromCharacter(Hit.Parent)
	if Player and not Used then
		Used = true
		local Stats = require(Player.Stats)
		Stats.ChangeStat("PStats","Agility",1)
		end
end)