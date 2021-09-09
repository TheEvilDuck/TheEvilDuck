local module = {}
local Player = script.Parent
local DataService = game:GetService("DataStoreService")
local DataStore = DataService:GetDataStore("PlayerData")
local AllTheStuff = require(game.ReplicatedStorage.ModuleScripts.AllTheStuff)
local PlayerKey = "Player_"..Player.UserId
local Inventory,Status
local CommonThings = require(game.ServerScriptService.CommonThings)
local Operations = require(game.ServerScriptService.Operations)

local BaseValues = {}
BaseValues.MaxHealth = 30
BaseValues.Speed = 18
BaseValues.MaxWeight = 15
BaseValues.MaxMana = 10
BaseValues.MaxStamina = 20
BaseValues.HealthRegen = 0.0075
BaseValues.ManaRegen = 0.01
BaseValues.StaminaRegen = 0.085

local PlayerStats = {}
PlayerStats.HStats = {}
PlayerStats.PStats = {}
PlayerStats.MStats = {}

local InpactTable = {}

function module.GetStat(Folder,Stat)
	if PlayerStats[Folder] then
		return PlayerStats[Folder][Stat]
	end
end

function module.EnoughReqs(ReqsTable)
	local TwoHandedK = 1
	if Status.TwoHanded then
		TwoHandedK = 0.65
	end
	local Can = true
	local Sum = 0
	table.foreach(ReqsTable,function(K,V)
		if PlayerStats.PStats[K] < V*TwoHandedK then
			Can = false
			Sum+=PlayerStats.PStats[K]/V*TwoHandedK
		end
	end)
	return Can,1+Sum
end

local function OnStatUpdated(Folder,Stat,Value,Max)
	game.ReplicatedStorage.Events.StatUpdated:FireClient(Player,Folder,Stat,Value,Max)
end

local function ThrowGuiBarUpdate(Folder,Name,What,WhatMax)
	OnStatUpdated(Folder,Name,What,WhatMax)
end

local function GetInpact(Stat)
	local Sum = 0
	table.foreach(InpactTable[Stat].Sum,function(K,V)
		Sum+=V.Value
	end)
	local Ks = 1
	table.foreach(InpactTable[Stat].K,function(K,V)
		Ks*=V.Value
	end)
	return Sum,Ks
end

local function Recalculate(Folder,Stat)
	local TableFunction = {}
	local function MaxSomething(Val,PStat)
		local Sum,Ks = GetInpact(Stat)
		local Value = (BaseValues[Stat]+Val*PlayerStats.PStats[PStat])*Ks+Sum
		PlayerStats[Folder][Stat] = Value
	end
	TableFunction.MaxHealth = function()
		MaxSomething(6,"Strength")
		Player.Character.Humanoid.MaxHealth = PlayerStats[Folder][Stat]
	end
	TableFunction.MaxMana = function ()
		MaxSomething(4,"Intelligence")
	end
	TableFunction.MaxStamina = function ()
		MaxSomething(3,"Persistance")
	end
	TableFunction.Armor = function()
		local Sum,Ks = GetInpact(Stat)
		local Armor = Inventory.GetArmor()
		PlayerStats[Folder][Stat] = Armor
	end
	TableFunction.Speed = function ()
		MaxSomething(0.1,"Agility")
		local K = PlayerStats.HStats.Weight/PlayerStats.HStats.MaxWeight
		local KofBattleMode = 1
		if Status.BattleMode then
			KofBattleMode = 0.75
		end
		local RunWithShiftK = 1
		if Status.Run 
			and not Status.Rolling
		then
			RunWithShiftK = 1.75
		end
		local RollingK = 1
		if Status.Rolling and not Status.Run then
			RollingK = 1.75
		end
		local AttackingK = 1
		if Status.Attacking and Status.Swing then
			AttackingK = 0.3
		end
		PlayerStats[Folder][Stat]*=(1-K)*KofBattleMode*RunWithShiftK*RollingK*AttackingK
		Player.Character.Humanoid.WalkSpeed = PlayerStats[Folder][Stat]
			
	end
	TableFunction.MaxWeight = function()
		MaxSomething(4,"Persistance")
		Recalculate("HStats","Weight")
	end
	TableFunction.StaminaRegen = function()
		MaxSomething(0.003,"Adaptation")
	end
	TableFunction.HealthRegen = function()
		MaxSomething(0.0025,"Adaptation")
	end
	TableFunction.ManaRegen = function ()
		MaxSomething(0.001,"Intelligence")
	end
	TableFunction.Weight = function()
		local Sum,Ks = GetInpact(Stat)
		local Weight = Inventory.GetEquipmentWeight()*Ks+Sum
		if Weight<0 then
			Weight = 0
		end
		PlayerStats[Folder][Stat] = Weight
		Recalculate("HStats","Speed")
		
	end
	local function CheckDamage(Weapon)
		if Weapon then
			local Sum,Ks = GetInpact(Stat)
			local Info = AllTheStuff.GetThing(Weapon.Name,Weapon.Type)
			local PStatsSum = 0
			local CanUse = true
			local TwoHandedK = 1
			if Status.TwoHanded then
				TwoHandedK = 0.75
			end
			local ShiftingK = 1
			if Status.Shifting then
				ShiftingK = 1.5
			end
			table.foreach(Info.Required,function(K,V)
				if PlayerStats.PStats[K] >= V*TwoHandedK 
					and CanUse
				then
					PStatsSum+=PlayerStats.PStats[K]*Info.Scaling[K]
				else
					CanUse = false
					PStatsSum = -0.5
					return
				end
			end)
			local DamageTable = {}
			local Length = Operations.HashTableLength(Info.Damage)
			table.foreach(Info.Damage,function(K,V)
				DamageTable[K] = (V+V*PStatsSum)/TwoHandedK*Ks*ShiftingK+Sum/Length
			end)
			return DamageTable
		end
		return {
			Piercing = 0,
			Cutting = 0,
			Slashing = 0,
			Bludgeoning = 0
		}
	end
	TableFunction.DamageLeftHand = function()
		PlayerStats[Folder][Stat] = CheckDamage(Inventory.GetEquipment("LeftHand"))
	end
	TableFunction.DamageRightHand = function()
		PlayerStats[Folder][Stat] = CheckDamage(Inventory.GetEquipment("RightHand"))
	end
	local Execute = TableFunction[Stat]
	
	if Execute then
		Execute()
	end
	OnStatUpdated(Folder,Stat,PlayerStats[Folder][Stat])
end

function module.ResetStats()
	table.foreach(PlayerStats.PStats,function(K,V)
		PlayerStats.PStats[K] = 1
		OnStatUpdated("PStats",K,PlayerStats.PStats[K])
	end)
	PlayerStats.MStats.Points=PlayerStats.MStats.Level
	OnStatUpdated("MStats","Points",PlayerStats.MStats.Points)
	table.foreach(PlayerStats.HStats,function(K,V)
		Recalculate("HStats",K)
	end)
end


function module.RecalculateDamage()
	Recalculate("HStats","DamageRightHand")
	Recalculate("HStats","DamageLeftHand")
end

function module.RecalculateWeight()
	Recalculate("HStats","Weight")
end

function module.RecalculateArmor()
	Recalculate("HStats","Armor")
end

function module.RecalculateSpeed()
	Recalculate("HStats","Speed")
end

function module.GetDamage(Hand)
	return PlayerStats.HStats["Damage"..Hand]
end

function module.BarUpdate(Name,Max,Value)
	PlayerStats.HStats[Name]+=Value
	if PlayerStats.HStats[Name]>PlayerStats.HStats[Max] then
		PlayerStats.HStats[Name]=PlayerStats.HStats[Max]
	end
	ThrowGuiBarUpdate("HStats",Name,PlayerStats.HStats[Name],PlayerStats.HStats[Max])
end

function module.HealthBarUpdate()
	ThrowGuiBarUpdate("HStats","Health",Player.Character.Humanoid.Health,PlayerStats.HStats.MaxHealth)
end



function module.ChangeStat(Folder,Name,Value)
	PlayerStats[Folder][Name]+=Value
	local TableFunction = {}
	TableFunction.Exp = function()
		while PlayerStats.MStats.Exp>=PlayerStats.MStats.Level*10 do
			PlayerStats.MStats.Exp-=PlayerStats.MStats.Level*10
			module.ChangeStat("MStats","Level",1)
			module.ChangeStat("MStats","Points",1)
		end
	end
	TableFunction.Strength = function()
		Recalculate("HStats","MaxHealth")
	end
	TableFunction.Agility = function()
		Recalculate("HStats","Speed")
	end
	TableFunction.Intelligence = function()
		Recalculate("HStats","MaxMana")
		Recalculate("HStats","ManaRegen")
	end
	TableFunction.Persistance = function()
		Recalculate("HStats","MaxWeight")
		Recalculate("HStats","MaxStamina")
	end
	TableFunction.Adaptation = function()
		Recalculate("HStats","HealthRegen")
		Recalculate("HStats","StaminaRegen")
	end
	local Execute = TableFunction[Name]
	if Execute then
		Execute()
	end
	module.RecalculateDamage()
	OnStatUpdated(Folder,Name,PlayerStats[Folder][Name])
end

function module.AddInpact(Folder,Stat,KorSum,Value,Time,Source)
	local Inpact = {}
	Inpact.Value = Value
	Inpact.Time = Time
	Inpact.Source = Source
	local Coroutine = coroutine.create(function()
		table.insert(InpactTable[Stat][KorSum],Inpact)
		Recalculate(Folder,Stat)
		local function GetPos()
			return table.find(InpactTable[Stat][KorSum],Inpact)
		end
		while InpactTable[Stat][KorSum][GetPos()]
			and InpactTable[Stat][KorSum][GetPos()].Time>0 do
			InpactTable[Stat][KorSum][GetPos()].Time-=1
			wait(1)
		end
		if GetPos() then
			table.remove(InpactTable[Stat][KorSum],GetPos())
		end
		Recalculate(Folder,Stat)
	end)
	coroutine.resume(Coroutine)
end


function ClearInpactTable()
	table.foreach(InpactTable,function(K,V)
		table.foreach(V,function(K2,V2)
			V2 = {}
		end)
	end)
end

local function RemoveData()
	local success, val = pcall(function()
		return DataStore:RemoveAsync(PlayerKey)
	end)

		if success then
			return val
		end
end

local function DataLoad()
	local DataTable = DataStore:GetAsync(PlayerKey)
	if DataTable then
		table.foreach(DataTable,function(K,V)
			table.foreach(V,function(K2,V2)
				PlayerStats[K][K2] = V2
			end)
		end)
	end
end

local function DataSave()
	local success,err = pcall(function ()
		local Data = {
			MStats = {},
			PStats = {},
		}
		table.foreach(PlayerStats.MStats,function(K,V)
			 Data.MStats[K] = V
		end)
		table.foreach(PlayerStats.PStats,function(K,V)
			Data.PStats[K] = V
		end)
		DataStore:SetAsync(PlayerKey,Data)
	end)
	if not success then
		warn("Can't save data!")
	end
end

function module.OnPlayerAdded()
	local InventoryScript = game.ServerScriptService.Inventory:Clone()
	InventoryScript.Parent = Player
	local StatusScript = game.ServerScriptService.Status:Clone()
	StatusScript.Parent = Player
	Inventory = require(InventoryScript)
	Status = require(StatusScript)
	
	--All MStats
	PlayerStats.MStats.Money = 100
	PlayerStats.MStats.Level = 80
	PlayerStats.MStats.Exp = 0
	PlayerStats.MStats.Points = 80
	
	--All PStats
	PlayerStats.PStats.Strength = 1
	PlayerStats.PStats.Agility = 1
	PlayerStats.PStats.Intelligence = 1
	PlayerStats.PStats.Persistance = 1
	PlayerStats.PStats.Adaptation = 1
	--PlayerStats.PStats.Luck = 1
	
	--Create HStats from BaseValues
	table.foreach(BaseValues,function(K,V)
		PlayerStats.HStats[K] = V
	end)
	
	--The rest of HStats
	PlayerStats.HStats.Weight = 0
	PlayerStats.HStats.Mana = PlayerStats.HStats.MaxMana
	PlayerStats.HStats.Stamina = PlayerStats.HStats.MaxStamina
	PlayerStats.HStats.DamageLeftHand = {
		Piercing = 0,
		Cutting = 0,
		Slashing = 0,
		Bludgeoning = 0
	}
	PlayerStats.HStats.DamageRightHand = {
		Piercing = 0,
		Cutting = 0,
		Slashing = 0,
		Bludgeoning = 0
	}
	PlayerStats.HStats.Armor = {
			Piercing = 0,
			Cutting = 0,
			Slashing = 0,
			Bludgeoning = 0
	}
	
	--Add inpact tables for every HStat
	table.foreach(PlayerStats.HStats,function(K,V)
			InpactTable[K] = {}
			InpactTable[K].K = {}
			InpactTable[K].Sum = {}
	end)
	
	local Inventory = require(InventoryScript)
	Inventory.AddThing("Rusted sword", "Weapon", 1,false)
	Inventory.AddThing("Heavy sword", "Weapon", 1,false)
	Inventory.AddThing("Long sword", "Weapon", 1,false)
	Inventory.AddThing("Fang", "Weapon", 1,false)
	Inventory.AddThing("Great sword", "Weapon", 2,false)
	Inventory.AddThing("Knife", "Weapon", 1,false)
	Inventory.AddThing("Bandit axe", "Weapon", 1,false)
	Inventory.AddThing("Small stamina potion", "Potion", 5,false)
	Inventory.AddThing("Bronze helmet", "Armor", 1,false)
	Inventory.AddThing("Bronze chessplate", "Armor", 1,false)
	Inventory.AddThing("Bronze left shauldron", "Armor", 1,false)
	Inventory.AddThing("Bronze right shauldron", "Armor", 1,false)
	Inventory.AddThing("Bronze left shoe", "Armor", 1,false)
	Inventory.AddThing("Bronze right shoe", "Armor", 1,false)
	Inventory.AddThing("Bronze pants", "Armor", 1,false)
	Inventory.AddThing("Bronze left glove", "Armor", 1,false)
	Inventory.AddThing("Bronze right glove", "Armor", 1,false)
	Inventory.AddThing("Demon helmet", "Armor", 1,false)
	Inventory.AddThing("Steel helmet", "Armor", 1,false)
	Inventory.AddThing("Horned helmet", "Armor", 1,false)
	Inventory.AddThing("Yorks chessplate", "Armor", 1,false)
	Inventory.AddThing("Dragonscale right glove", "Armor", 1,false)
	
	--Delete When Need To Save Data
	local Deleted = RemoveData()
	DataLoad()

	--loadCharacter
	local Char = game.ReplicatedStorage.StarterCharacter:Clone()
	Char.Parent = game.StarterPlayer
	Player.Character = Char
	Player:LoadCharacter()
end

function module.OnCharacterAdded(Char)
	ClearInpactTable()
	table.foreach(InpactTable,function(K,V)
		Recalculate("HStats",K)
	end)
	table.foreach(PlayerStats,function(K,V)
		table.foreach(V,function(K2,V2)
			OnStatUpdated(K,K2,V2)
		end)
	end)
	local EqRight = Inventory.GetEquipment("RightHand")
	local EqLeft = Inventory.GetEquipment("LeftHand")
	if EqRight then
		local IsLeft = false
		local Hand = CommonThings.ReturnHand(IsLeft)
		CommonThings.AddWeaponModel(Hand,EqRight,Player,IsLeft,Status,module)
	end
	if EqLeft then
		local IsLeft = true
		local Hand = CommonThings.ReturnHand(IsLeft)
		CommonThings.AddWeaponModel(Hand,EqRight,Player,IsLeft,Status,module)
	end
	local Rotation = Instance.new("BodyGyro",Char.HumanoidRootPart)
	Rotation.MaxTorque = Vector3.new(0,0,0)
	Rotation.D = 0
	Rotation.P = 4500
end

function module.OnPlayerRemoving()
	DataSave()
end
return module
