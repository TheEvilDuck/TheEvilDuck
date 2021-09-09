local Player = game.Players:GetPlayerFromCharacter(script.Parent)
local Stats = require(Player:WaitForChild("Stats"))


coroutine.resume(coroutine.create(function()
	while true do
		while Player.Character.Humanoid.Health<Stats.GetStat("HStats","MaxHealth") do
			Player.Character.Humanoid.Health+=Stats.GetStat("HStats","HealthRegen")
			Stats.HealthBarUpdate()
			wait()
		end
		Player.Character.Humanoid.Health = Stats.GetStat("HStats","MaxHealth")
		Stats.HealthBarUpdate()
		wait()
	end
end))

local function Update(What,Max,Regen)
	while true do
		while Stats.GetStat("HStats",What)<Stats.GetStat("HStats",Max) do
			Stats.BarUpdate(What,Max,Stats.GetStat("HStats",Regen))
			wait()
		end
		wait()
	end
end

coroutine.resume(coroutine.create(function()
	Update("Mana","MaxMana","ManaRegen")
end))
coroutine.resume(coroutine.create(function()
	Update("Stamina","MaxStamina","StaminaRegen")
end))

