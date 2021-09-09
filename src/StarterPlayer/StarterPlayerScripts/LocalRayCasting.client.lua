local Module = require(game.ReplicatedFirst.LocalModuleScripts.LocalFunctions)
local Player = game.Players.LocalPlayer

local RC = game.ReplicatedStorage.Events.RC
RC.OnClientInvoke= function(mobtorso)
	local Wall
	local Char = Player.Character
	if Char then
		if Char.Humanoid.Health>0 then
			Wall = Module.CheckWalls(Char.HumanoidRootPart,mobtorso)
		end
	end
	return Wall
end