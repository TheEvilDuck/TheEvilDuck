local module = {}
local Operations = require(game.ServerScriptService.Operations)
local MobBehavior = require(game.ServerScriptService.MobBehavior)

function module.Spawn(mob,position)
	local Copy = mob:Clone()
	Copy.Parent = game.Workspace
	Copy:MoveTo(position)
	return Copy
end

local function AddWeapon(mobinmoblist)

	local Index = 1
	local Min = 1
	local Chance = math.random()
	for i = 1,#mobinmoblist.Weapons do
		if mobinmoblist.Weapons[i].Chance<=Min and mobinmoblist.Weapons[i].Chance>Chance then
			Min = mobinmoblist.Weapons[i].Chance
			Index = i
		end
	end
	return mobinmoblist.Weapons[Index].Name,mobinmoblist.Weapons[Index].Damage
end

function module.Spawner(area,max,moblist)
	local Mobs = {}
	while true do
		table.foreach(Mobs,function(K,V)
			if V.Parent~=game.Workspace then
				table.remove(Mobs,K)
			end
		end)
		while #Mobs<max do
			local Chance = math.random()
			local Min = 1
			local Index
			for i = 1,#moblist do
				if moblist[i].Chance<=Min and moblist[i].Chance>Chance then
					Min = moblist[i].Chance
					Index = i
				end
			end
			if Index then
				local Mob = game.ServerStorage.Mobs:FindFirstChild(moblist[Index].Name)
				if Mob then
					local X = math.random(-area.Size.X/2,area.Size.X/2)
					local Z = math.random(-area.Size.Z/2,area.Size.Z/2)
					local Pos = area.Position+Vector3.new(X,0,Z)
					local Clone = module.Spawn(Mob,Pos)
					table.insert(Mobs,Clone)

					local HPdiff = math.random(-moblist[Index].HPDiff,moblist[Index].HPDiff)
					Clone.Humanoid.MaxHealth = moblist[Index].HP+HPdiff
					Clone.Humanoid.Health = Clone.Humanoid.MaxHealth
					local Name,DamageAmount = AddWeapon(moblist[Index])
					local Weapon = game.ServerStorage.MobWeapons:FindFirstChild(Name)
					local CloneWeapon = Weapon:Clone()
					Operations.Weld(CloneWeapon)
					CloneWeapon.Parent = Clone
					CloneWeapon.Name = "Weapon"
					Operations.WeldOneToAnother(CloneWeapon.PrimaryPart,Clone.RightHand1,CFrame.Angles(90,0,90))
					CloneWeapon:SetPrimaryPartCFrame(Clone.RightHand1.CFrame*CFrame.Angles(45,0,0))
					local Stats = {}
					Stats.Name = moblist[Index].Name
					Stats.Model = Clone
					Stats.Damage = {
						Piercing = 1,
						Cutting = 1,
						Slashing = 1,
						Bludgeoning = 1
					}
					Stats.ViewRadius = moblist[Index].ViewRadius
					Stats.LootTable = moblist[Index].LootTable
					Stats.Exp = moblist[Index].Exp
					Stats.DistanceToAttack = moblist[Index].DistanceToAttack
					Stats.Speed = moblist[Index].Speed
					MobBehavior.Behavior(Stats)
				end
			end
		end
		wait(1)
	end
end
return module
