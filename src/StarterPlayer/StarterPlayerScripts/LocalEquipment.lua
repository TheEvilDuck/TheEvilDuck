local module = {}
local AllTheStuff = require(game.ReplicatedStorage.ModuleScripts.AllTheStuff)
local Equipment = 
	{
		LeftHand = nil,
		RightHand = nil,
		Head = nil
	}

function module.GetEquipment(Where)
	return Equipment[Where]
end

function module.SetEquipment(Where,Name,Type)
	local Origin = AllTheStuff.GetThing(Name,Type)
	local Thing = {}
	Thing.Type = Origin.Type
	Equipment[Where] = Thing
end
function module.RemoveEquipment(Where)
	if Equipment[Where]then
		Equipment[Where] = nil
		end
end
return module
