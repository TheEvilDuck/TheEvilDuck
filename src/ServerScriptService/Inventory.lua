local module = {}
local MaxSlots = 25
local Inventory = {}
local Equipment = {
	RightHand = nil,
	LeftHand = nil,
	Head = nil
}
local Player = script.Parent
local AllTheStuff = require(game.ReplicatedStorage.ModuleScripts.AllTheStuff)
local InventorySlotUpdateEvent = game.ReplicatedStorage.Events.InventorySlotUpdate

function module.GetEquipment(Slot)
	local Thing
	if Equipment[Slot] then
		Thing = Inventory[Equipment[Slot]]
	end 
	return Thing
end
function module.GetThing(Name)
	for i = 1,#Inventory do
		if Inventory[i].Name == Name then
			return Inventory[i]
		end
	end
end

function module.GetModel(Slot)
	local What = module.GetEquipment(Slot)
	local L = ""
	if Slot == "LeftHand" then
		L = "L"
	end
	return Player.Character:FindFirstChild(What.Type..L)
end

function module.GetEquipmentWeight()
	local Sum = 0
	table.foreach(Equipment,function(K,V)
		if V then
			local Thing = AllTheStuff.GetThing(Inventory[V].Name,Inventory[V].Type)
			Sum+=Thing.Weight
		end
	end)
	return Sum
end

function module.GetArmor()
	local Sum = {
			Piercing = 0,
			Cutting = 0,
			Slashing = 0,
			Bludgeoning = 0
	}
	table.foreach(Equipment,function(K,V)
		if V then
			if Inventory[V].Type == "Armor" then
				local Thing = AllTheStuff.GetThing(Inventory[V].Name,Inventory[V].Type) 
				table.foreach(Thing.Armor,function(K2,V2)
					Sum[K2]+=V2
				end)
			end
		end
	end)
	return Sum
end

function module.GetThingById(Id)
	return Inventory[Id]
end

function module.UnEquipCertain(Id)
	table.foreach(Equipment,function(K,V)
		if V==Id then
			Equipment[K] = nil
			Inventory[Id].Eq = false
			game.ReplicatedStorage.Events.LocalEquipmentUpdate:FireClient(Player,K,nil)
			return
		end
	end)
end

function module.GetHand(Id)
	local Hand = nil
	table.foreach(Equipment,function(K,V)
		if V == Id then
			Hand = K
		end
	end)
	return Hand
end

function module.UnEquipBodyPart(Where)
	if Equipment[Where] then
		Inventory[Equipment[Where]].Eq = false
		Equipment[Where] = nil
	end
	game.ReplicatedStorage.Events.LocalEquipmentUpdate:FireClient(Player,Where,nil)
end

function module.Equip(Id,Where)
	Equipment[Where] = Id
	Inventory[Id].Eq = true
	game.ReplicatedStorage.Events.LocalEquipmentUpdate:FireClient(Player,Where,Inventory[Id].Name,Inventory[Id].Type)
end

function module.Decrease(Id)
	Inventory[Id].Count-=1
	InventorySlotUpdateEvent:FireClient(Player,Id,Inventory[Id].Count)
	if Inventory[Id].Count<=0 then
		Inventory[Id] = nil
	end
	
end

function module.AddThing(Name,Type,Count,Status)
	local Found = false
	local Info = AllTheStuff.GetThing(Name,Type)
	for i = 1,#Inventory do
		if Inventory[i].Name == Name 
			and Inventory[i].Count+Count<=Info.MaxCount
		then
			Found = true
			Inventory[i].Count+=Count
			InventorySlotUpdateEvent:FireClient(Player,i,Inventory[i].Count)
			break
		end
	end
	if not Found then
		if #Inventory<MaxSlots then
			for i = 1,#Inventory do
				if Inventory[i] == nil then
					Found = i
					break
				end
			end
			local Thing = 
				{
					Name = Name,
					Type = Type,
					Count = Count,
					Eq = Status
				}
			if Count>Info.MaxCount then
				Thing.Count = Info.MaxCount
				module.AddThing(Name,Type,Count-Info.MaxCount,Status)
			end
			if Found then
				Inventory[Found] = Thing
			else
				table.insert(Inventory,Thing)
				Found = #Inventory
			end
			game.ReplicatedStorage.Events.InventoryUpdate:FireClient(Player,Name,Type,Found,Thing.Count)
		end
	end
	return Found
end
return module
