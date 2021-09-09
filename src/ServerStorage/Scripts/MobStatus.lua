local module = {}
local PlayersTable = {}

module.Walking = false
module.Attacking = false
module.CanDamage = false
module.Running = false
module.Rolling = false
module.Owner = nil
module.AnimDebounce = true

local AdditionStatus = {}
local Connections = {}

function module.AddStatus(Status,Value)
	AdditionStatus[Status] = Value
end

function module.ConnectStatAndStatus(Stat,Status,K)
	Connections[Stat] = {}
	Connections[Stat].Status = Status
	Connections[Stat].K = K
end

function module.SetAdditionalStatus(Status,Value)
	if AdditionStatus[Status]~=nil then
		AdditionStatus[Status] = Value
	end
end

function module.GetAdditionalStatus(Status)
	return AdditionStatus[Status]
end

local Model = nil

module.BaseSpeed = 16
module.Speed = module.BaseSpeed

local ImpactTable = {}

ImpactTable.new = function(What)
	local obj = {}
	obj.K = {}
	obj.Sum = {}
	ImpactTable[What] = obj
end



function module.OnSpawn(Mob)
	ImpactTable.new("Speed")
	ImpactTable.new("Damage")
	ImpactTable.new("MaxHealth")
	Model = Mob
end

function module.AddImpact(What,KorSum,Power,Time)
	local Impact = {}
	Impact.Time = Time
	Impact.Power = Power
	table.insert(ImpactTable[What][KorSum],Impact)
	local function GetPos()
		return table.find(ImpactTable[What][KorSum],Impact)
	end
	coroutine.resume(coroutine.create(function()
		module.RecalculateSpeed()
		while ImpactTable[What][KorSum][GetPos()].Time>0 do
			ImpactTable[What][KorSum][GetPos()].Time-=1
			wait(1)
		end
		table.remove(ImpactTable[What][KorSum],GetPos())
		module.RecalculateSpeed()
	end))
end

local function CalculateImpact(What)
	local Sum = 0
	local K = 1
	table.foreach(ImpactTable[What].Sum,function(K,V)
		Sum+=V.Power
	end)
	table.foreach(ImpactTable[What].K,function(K1,V)
		K*=V.Power
	end)
	return Sum,K
end

function module.RecalculateSpeed()
	local RollingK = 1
	if module.Rolling then
		RollingK = 1.5
	end
	local Sum,K = CalculateImpact("Speed")
	local AdditionalK = 1
	if Connections["Speed"] then
		if AdditionStatus[Connections["Speed"].Status] then
			AdditionalK = Connections["Speed"].K
		end
	end
	module.Speed = (module.BaseSpeed+Sum)*RollingK*K*AdditionalK
	Model.Humanoid.WalkSpeed = module.Speed
end

function module.AddDamage(Player,Damage)
	local Id = game.Players:GetUserIdFromNameAsync(Player.Name)
	if Id then
		if not PlayersTable[Id] then
			PlayersTable[Id] = Damage
		else
			PlayersTable[Id]+=Damage
		end
	end
end

function module.GetImpact()
	return PlayersTable
end
return module
