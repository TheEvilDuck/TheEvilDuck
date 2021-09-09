local Operations = require(game.ServerScriptService.Operations)
local ItemUsation = require(game.ServerScriptService.ItemUsation)
local AllTheStuff = require(game.ReplicatedStorage.ModuleScripts.AllTheStuff)
local CommonThings = require(game.ServerScriptService.CommonThings)


game.ReplicatedStorage.Events.BattleModeServerUpdate.OnServerEvent:Connect(function(Player,BattleMode)
	local Names = {"","L"}
	local Weapons = {}
	local Status = require(Player.Status)
	local Stats = require(Player.Stats)
	local Inventory = require(Player.Inventory)
	local Hands = {}
	Hands.LeftHand = Inventory.GetEquipment("LeftHand")
	Hands.RightHand = Inventory.GetEquipment("RightHand")
	if Hands.RightHand then
		Hands.RightHand = AllTheStuff.GetThing(Hands.RightHand.Name,Hands.RightHand.Type).Type
	end
	if Hands.LeftHand then
		Hands.LeftHand = AllTheStuff.GetThing(Hands.LeftHand.Name,Hands.LeftHand.Type).Type
	end
	Status.BattleMode = BattleMode
	table.foreach(Names,function(K,V)
		local Weapon = Player.Character:FindFirstChild("Weapon"..V)
		if Weapon then
			if V == "L" then
				Weapons.LeftHand = Weapon
			else
				Weapons.RightHand = Weapon
			end
		end
	end)
	table.foreach(Weapons,function(K,V)
		V.PrimaryPart.MainWeld:Remove()
		local Where = Player.Character[K.."1"]
		local CF = CFrame.Angles(math.rad(90),0,math.rad(90))
		if not BattleMode then
			Where = Player.Character.LowerTorso
			local Side = 1
			if K == "LeftHand" then
				Side = -1
			end
			CF = CFrame.new(Side*Where.Size.X*1.05,0,0)*CFrame.Angles(-90,0,0)
			if Hands[K] == "Great sword" then
				local Angles = CFrame.Angles(0,math.rad(90),math.rad(Side*160))
				Where = Player.Character.UpperTorso
				local Offset = CFrame.new(0,-Where.Size.Y*0.5,-Where.Size.Z*1.3)
				CF = Angles*Offset
			end
		end
		Operations.WeldOneToAnother(V.PrimaryPart,Where,CF)
	end)
	if not BattleMode then
		Status.TwoHanded = false
		Stats.RecalculateDamage()
		
	else
		
		local RightHand = Inventory.GetEquipment("RightHand")
		local LeftHand = Inventory.GetEquipment("LeftHand")
		if RightHand then
			local Thing = AllTheStuff.GetThing(RightHand.Name,RightHand.Type)
			Status.UpdateWeaponSounds(Thing.Type,"RightHand")
		end
		if LeftHand then
			local Thing = AllTheStuff.GetThing(LeftHand.Name,LeftHand.Type)
			Status.UpdateWeaponSounds(Thing.Type,"LeftHand")
		end
	end
	Stats.RecalculateSpeed()
end)

game.ReplicatedStorage.Events.UseItem.OnServerEvent:Connect(function(Player,Id,IsLeft)
	local Inventory = require(Player.Inventory)
	local Thing = Inventory.GetThingById(Id)
	local Status = require(Player.Status)
	local Stats = require(Player.Stats)
	
	local FunctionTable = {
		Scroll = function()
			ItemUsation.Use(Player,Thing.Name,Thing.Type)
			Inventory.Decrease(Id)
		end,
		Potion = function()
			ItemUsation.Use(Player,Thing.Name,Thing.Type)
			Inventory.Decrease(Id)
		end,
		Weapon = function()
			local HandFromButton = CommonThings.ReturnHand(IsLeft)
			local InAllTheStuff = AllTheStuff.GetThing(Thing.Name,Thing.Type)
			local CurrentWeapon = Player.Character:FindFirstChild("Weapon"..HandFromButton.L)
			if CurrentWeapon then
				CurrentWeapon:Remove()
			end
			if Thing.Eq then
				if Status.Connections[HandFromButton.Hand] then
					Status.Connections[HandFromButton.Hand]:Disconnect()
					Status.Connections[HandFromButton.Hand] = nil
					Status.RemoveSourceOfDamage(HandFromButton.Hand)
				end
				local HandOfEquipment = Inventory.GetHand(Id)
				Inventory.UnEquipCertain(Id)
				if HandFromButton.Hand ~= HandOfEquipment then
					Inventory.UnEquipBodyPart(HandFromButton.Hand)
					local OtherHandWeapon = Player.Character:FindFirstChild("Weapon"..CommonThings.ReturnHand(not IsLeft).L)
					if OtherHandWeapon then
						OtherHandWeapon:Remove()
					end
					Inventory.Equip(Id,HandFromButton.Hand)
					CommonThings.AddWeaponModel(HandFromButton,Thing,Player,IsLeft,Status,Stats,AllTheStuff.Type)
				end
			else
				Inventory.UnEquipBodyPart(HandFromButton.Hand,Thing,Player,IsLeft,Status,Stats)
				Inventory.Equip(Id,HandFromButton.Hand)
				CommonThings.AddWeaponModel(HandFromButton,Thing,Player,IsLeft,Status,Stats,InAllTheStuff.Type)
			end
			Stats.RecalculateDamage()
			Stats.RecalculateWeight()
		end,
		Armor = function()
			local InAllTheStuff = AllTheStuff.GetThing(Thing.Name,Thing.Type)
			local CurrentArmor = Player.Character:FindFirstChild(InAllTheStuff.Type)
			if CurrentArmor then
				CurrentArmor:Remove()
			end
			local WhereTable = {}
			WhereTable.Helmet = "Head"
			WhereTable.Chessplate = "UpperTorso"
			WhereTable["Right shauldron"] = "RightUpperArm"
			WhereTable["Left shauldron"] = "LeftUpperArm"
			WhereTable["Left shoe"] = "LeftFoot"
			WhereTable["Right shoe"] = "RightFoot"
			WhereTable.Pants = "LowerTorso"
			WhereTable["Left glove"] = "LeftLowerArm"
			WhereTable["Right glove"] = "RightLowerArm"
			if Thing.Eq then
				Inventory.UnEquipCertain(Id)
			else
				Inventory.UnEquipBodyPart(WhereTable[InAllTheStuff.Type])
				Inventory.Equip(Id,WhereTable[InAllTheStuff.Type])
				CommonThings.AddArmorModel(Thing.Name,InAllTheStuff.Type,Player,WhereTable[InAllTheStuff.Type])
			end
			Stats.RecalculateArmor()
			Stats.RecalculateWeight()
		end,
	}
	FunctionTable[Thing.Type]()
end)




game.ReplicatedStorage.Events.AddItem.OnServerInvoke = function(Player,Loot)
	local Inventory = require(Player.Inventory)
	local Done = Inventory.AddThing(Loot.Name,Loot.Type,Loot.Count,Loot.Type2,false)
	return Done
end

game.ReplicatedStorage.Events.RemoveLoot.OnServerEvent:Connect(function(Player,Model)
	if Model then
		Model:Remove()
	end
end)


game.ReplicatedStorage.Events.AttackEvent.OnServerEvent:Connect(function(Player,Hand,CanDamage)
	local Status = require(Player.Status)
	local Stats = require(Player.Stats)
	local Inventory = require(Player.Inventory)
	Status.SetCanDamage(Hand,CanDamage)
	Status.AddSourceOfDamage(Hand)
	Status.Swinging = false
	if CanDamage and Status.Attacking then
		Inventory.GetModel(Hand).Blade.Trail.Transparency = NumberSequence.new(1,0.25)
	else
	Inventory.GetModel(Hand).Blade.Trail.Transparency = NumberSequence.new(1)
		Status.Attacking = false
		Player.Character.HumanoidRootPart.BodyGyro.MaxTorque = Vector3.new(0,0,0)
	end
	Stats.RecalculateSpeed()
end)

game.ReplicatedStorage.Events.TwoHanded.OnServerInvoke = function(Player,Value)
	local Inventory = require(Player.Inventory)
	local Status = require(Player.Status)
	local Stats = require(Player.Stats)
	if not (Inventory.GetEquipment("RightHand") 
		and Inventory.GetEquipment("LeftHand") )
		and
		not (not Inventory.GetEquipment("RightHand") 
			and not Inventory.GetEquipment("LeftHand") )
	then
		Status.TwoHanded = not Value
		Stats.RecalculateDamage()
		return not Value
	end
	return false
end

game.ReplicatedStorage.Events.CanRoll.OnServerInvoke = function(Player,Value)
	local Status = require(Player.Status)
	local Stats = require(Player.Stats)
	if Value then
		local WeightK = Stats.GetStat("HStats","Weight")/Stats.GetStat("HStats","MaxWeight")
		local BattleModeK = 0.5
		if Status.BattleMode then
			BattleModeK = 1
		end
		local StaminaRequire = (3+Stats.GetStat("HStats","MaxStamina")*WeightK*0.7)*BattleModeK
		if Stats.GetStat("HStats","Stamina")>=StaminaRequire then
			Stats.BarUpdate("Stamina","MaxStamina",-StaminaRequire)
			local K = 1.5
			if Status.Shifting and Status.Run then
				K = 1
			end
			Status.Rolling = Value
			Stats.RecalculateSpeed()
			return true
		end
	end
	Status.Rolling = Value
	Stats.RecalculateSpeed()
	return false
end

game.ReplicatedStorage.Events.IncreasePStat.OnServerEvent:Connect(function(Player,Name,Value)
	local Stats = require(Player.Stats)
	if Stats.GetStat("MStats","Points")>0 then
		Stats.ChangeStat("MStats","Points",-1)
		Stats.ChangeStat("PStats",Name,1)
	end
end)

game.ReplicatedStorage.Events.CanAttack.OnServerInvoke = function(Player,Hand)
	local AllTheStuff = require(game.ReplicatedStorage.ModuleScripts.AllTheStuff)
	local Stats = require(Player.Stats)
	local Status = require(Player.Status)
	local Inventory = require(Player.Inventory)
	
	local Equipment = Inventory.GetEquipment(Hand)
	local Thing = AllTheStuff.GetThing(Equipment.Name,Equipment.Type)
	local BaseStamina = (Thing.Weight+1)*1.1
	local WeightK = Stats.GetStat("HStats","Weight")/Stats.GetStat("HStats","MaxWeight")
	local TwoHandedK = 1
	if Status.TwoHanded then
		TwoHandedK = 0.5
	end
	local CanUse,SumOfDifference = Stats.EnoughReqs(Thing.Required)
	local CanUseK = 1
	if CanUse then
		CanUseK = 0.75
	end
	local StrongK = 1
	if Status.Shifting then
		StrongK = 1.5
	end
	local StaminaReq = (BaseStamina+BaseStamina*WeightK)*TwoHandedK*CanUseK*StrongK*SumOfDifference
	if Stats.GetStat("HStats","Stamina")>=StaminaReq then
		Stats.BarUpdate("Stamina","MaxStamina",-StaminaReq)
		Status.Attacking = true
		Status.PlayWeaponSound("Swing",Hand)
		Status.Swinging = true
		Stats.RecalculateSpeed()
		return true,Thing.Weight
	end
	Status.SetCanDamage(Hand,false)
	return false
end

game.ReplicatedStorage.Events.ShiftStatusChange.OnServerEvent:Connect(function(Player,Value)
	local Status = require(Player.Status)
	local Stats = require(Player.Stats)
	Status.Shifting = Value
	Stats.RecalculateDamage()
	Stats.RecalculateSpeed()
end)

game.ReplicatedStorage.Events.CanRunWithShift.OnServerInvoke = function(Player)
	local Status = require(Player.Status)
	local Stats = require(Player.Stats)
	local function StaminaReq()
		local WeightK = Stats.GetStat("HStats","Weight")/Stats.GetStat("HStats","MaxWeight")
		local BattleModeK = 0.3
		if Status.BattleMode then
			BattleModeK = 1
		end
		return (0.15+1.75*WeightK)*BattleModeK
	end
	if Status.Shifting 
		and Stats.GetStat("HStats","Stamina")>=StaminaReq()
	then
		Status.Run = true
		Stats.RecalculateSpeed()
		while Status.Shifting 
			and Stats.GetStat("HStats","Stamina")>=StaminaReq()
		do
			if Status.Rolling then
				Status.Run = false
				Stats.RecalculateSpeed()
			elseif Status.Moving then
				Status.Run = true
				Stats.BarUpdate("Stamina","MaxStamina",-StaminaReq())
				Stats.RecalculateSpeed()
			end
			wait()
		end
		Status.Run = false
		Stats.RecalculateSpeed()
		return false
	end
	
end

game.ReplicatedStorage.Events.PlayerWalked.OnServerEvent:Connect(function(Player,Value)
	local Status = require(Player.Status)
	Status.Moving = Value
end)

game.ReplicatedStorage.Events.HeadRotation.OnServerEvent:Connect(function(Player,CF)
	if Player.Character then
		if Player.Character.Humanoid.Health>0 then
			game.ReplicatedStorage.Events.HeadRotation:FireAllClients(Player,CF)
		end
	end
end)