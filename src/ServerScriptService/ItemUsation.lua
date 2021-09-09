local module = {}
local AllTheStuff = require(game.ReplicatedStorage.ModuleScripts.AllTheStuff)
module.Use = function(Player,Name,Type)
	local Thing = AllTheStuff.GetThing(Name,Type)
	local TableFunction = {}
	TableFunction["Teleport scroll"] = function()
		local Char = Player.Character
		if Char then
			if Char.Humanoid.Health>0 then
				Char:MoveTo(Thing.Target)
			end
		end
	end
	TableFunction["HStat potion"] = function()
		local Char = Player.Character
		if Char then
			if Char.Humanoid.Health>0 then
				local Stats = require(Player.Stats)
				Stats.AddInpact("HStats","StaminaRegen","Sum",Thing.Power,Thing.Time,Name)
			end
		end
	end
	local Execute = TableFunction[Thing.Type]
	if Execute then
		Execute()
	end
end

return module
