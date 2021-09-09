local module = {}
local CanDamage = {}
CanDamage.RightHand = false
CanDamage.LeftHand = false
module.Connections = {}
module.Connections.RightHand = nil
module.Connections.LeftHand = nil
module.TwoHanded = false
module.BattleMode = false
module.Shifting = false
module.Run = false
module.Moving = false
module.Rolling = false
module.Attacking = false
module.Swinging = false
module.Pvp = false
module.FloorMaterial = nil

local Player = script.Parent

local Sounds = {}
Sounds.Weapons = {}
Sounds.Common = {}
Sounds.Weapons.RightHand = {}
Sounds.Weapons.LeftHand = {}

function module.UpdateWeaponSounds(Type,Hand)
	table.foreach(Sounds.Weapons[Hand],function(K,V)
		V:Remove()
	end)
	Sounds.Weapons[Hand]={}
	local Folder = game.ReplicatedStorage.Sounds.Weapon:FindFirstChild(Type)
	if Folder then
		local d = Folder:GetChildren()
		table.foreach(d,function(K,V)
			local Clone = V:Clone()
			Clone.Parent = Player.Character.HumanoidRootPart
			Sounds.Weapons[Hand][Clone.Name] = Clone
		end)
	end
end

function module.UpdateStepSound(Name)
	local Thing = game.ReplicatedStorage.Sounds.Common.Steps:FindFirstChild(Name)
	local Clone = Thing:Clone()
	if Sounds.Common.Step then
		Sounds.Common.Step:Remove()
	end
	Clone.Parent = Player.Character.HumanoidRootPart
	Sounds.Common.Step = Clone
end

function module.PlayStepSound()
	if Sounds.Common.Step then
		local Rand = math.random(8,12)/10
		Sounds.Common.Step.PlaybackSpeed = Rand
		Sounds.Common.Step:Play()
	end
end

function module.PlayWeaponSound(Name,Hand)
	if Sounds.Weapons[Hand][Name] then
	local Rand = math.random(8,12)/10
	Sounds.Weapons[Hand][Name].PlaybackSpeed = Rand
	Sounds.Weapons[Hand][Name]:Play()
	end
end

function module.GetCanDamage(Hand)
	return CanDamage[Hand]
end
function module.SetCanDamage(Hand,Value)
	CanDamage[Hand] = Value
end

local DamageTable = {}
function module.AddSourceOfDamage(Source)
	DamageTable[Source] = {}
end

function module.RemoveSourceOfDamage(Source)
	DamageTable[Source] = nil
end

function module.GetSourceOfDamage(Source)
	return DamageTable[Source]
end

function module.AddToDamageTable(What,Source)
	table.insert(DamageTable[Source],What)
end

return module
