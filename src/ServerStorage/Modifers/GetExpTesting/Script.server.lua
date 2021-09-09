
script.Parent.Touched:Connect(function(Hit)
		local Player = game.Players:GetPlayerFromCharacter(Hit.Parent)
		if Player then
		local Stats = require(Player.Stats)
		Stats.ChangeStat("MStats","Exp",200)
		end
end)