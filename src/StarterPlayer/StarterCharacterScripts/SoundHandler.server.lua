local Char = script.Parent
local Player = game.Players:GetPlayerFromCharacter(Char)

local Stats = require(Player.Stats)
local Status = require(Player.Status)

while Char.Humanoid.Health>0 do
	if Status.FloorMaterial~=Char.Humanoid.FloorMaterial then
		Status.FloorMaterial = Char.Humanoid.FloorMaterial
		if Status.FloorMaterial == Enum.Material.Plastic then
			Status.UpdateStepSound("Bricks")
		elseif Status.FloorMaterial == Enum.Material.Grass then
			Status.UpdateStepSound("Dirt")
		elseif Status.FloorMaterial == Enum.Material.Metal
			or 	Status.FloorMaterial == Enum.Material.DiamondPlate
		then
			Status.UpdateStepSound("Metal")
		end
	end
	if Status.FloorMaterial ~= Enum.Material.Air then
		while (Status.Moving or Status.Run)
			and not Status.Jumping 
			and not Status.Falling
			and not Status.Rolling
			and not Status.Attacking 
			and Status.FloorMaterial==Char.Humanoid.FloorMaterial
		do
			local Speed = Stats.GetStat("HStats","Speed")
			if Speed>0 then
				Status.PlayStepSound()
			else
				Speed = 5
			end
			wait(6.5/Stats.GetStat("HStats","Speed"))
		end
	end
	wait(.0001)
end