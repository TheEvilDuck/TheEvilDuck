local module = {}

local Operations = require(game.ServerScriptService.Operations)
local CommonThings = require(game.ServerScriptService.CommonThings)
local PathfindingService = game:GetService("PathfindingService")

function FindNearestPlayer(Model,Radius)
	local Players = game.Players:GetChildren()
	local Root = Model.HumanoidRootPart
	local Target
	table.foreach(Players,function(K,V)
		if V.Character then
			if V.Character.Humanoid.Health>0 then
				if Operations.CheckDistance(Root.Position,V.Character.HumanoidRootPart.Position)<=Radius then
					Target = V
					return
				end
			end
		end
	end)
	return Target
end

function PathFind(mob,from,point)
		local path = PathfindingService:CreatePath()
		path:ComputeAsync(from.Position, point)
		local waypoints = path:GetWaypoints()
		for i = 1,#waypoints do
		if Operations.CheckDistance(waypoints[#waypoints].Position,point)>10 then
				break
			end
			if mob.Humanoid.Health>0 then
				mob.Humanoid:MoveTo(waypoints[i].Position)
				local MoveToFinished = false
				local ListenConn
				ListenConn = mob.Humanoid.MoveToFinished:connect(function()
					ListenConn:Disconnect()
					MoveToFinished = true
			end)
			while not MoveToFinished 
			do
				if Operations.CheckDistance(waypoints[i].Position,mob.HumanoidRootPart.Position)<=7 then
					ListenConn:Disconnect()
					MoveToFinished = true
					break
				end
				wait()
			end
			end
		end
end

local LivingThing = {}
LivingThing.new = function(Stats)
	local obj = Stats
	obj.Animations = {}
	obj.StartPosition = obj.Model.PrimaryPart.Position
	obj.TouchedConnections = {}
	obj.DamageTable = {}
	
	obj.CDList = {}
	
	obj.ActionTable = {}
	
	obj.BodyGyro = Instance.new("BodyGyro",obj.Model.PrimaryPart)
	
	obj.AddAction = function(Action)
		table.insert(obj.ActionTable,Action)
	end
	
	obj.DefineAction = function(InputInfo)
		local F = nil
		local Max = 0
		local Name = nil
		table.foreach(obj.ActionTable,function(K,V)
			local Weight = V.Weights(InputInfo)
			if Weight>Max then
				F = V.F
				Max = Weight
				Name = K
			end
		end)
		if F then
			F(InputInfo)
		end
	end
	
	obj.SetCoolDown = function(ActionName,Time)
		coroutine.resume(coroutine.create(function()
			obj.CDList[ActionName] = Time
			while obj.CDList[ActionName]>0 do
				obj.CDList[ActionName]-=1

				wait(1)
			end
			obj.CDList[ActionName] = 0
		end))
	end
	
	obj.FindTarget = function()
		return FindNearestPlayer(obj.Model,obj.ViewRadius)
	end
	
	obj.OnSpawn = function()
		local Status = game.ServerStorage.Scripts.MobStatus:Clone()
		Status.Parent = obj.Model
		local MobStats = game.ServerStorage.Scripts.MobStats:Clone()
		MobStats.Parent = obj.Model
		obj.Status = require(Status)
		obj.Stats = require(MobStats)
		obj.Status.OnSpawn(obj.Model)
		obj.Status.BaseSpeed = Stats.Speed
		obj.Status.RecalculateSpeed()
	end
	
	obj.OnDied = function()
		table.foreach(obj.Status.GetImpact(),function(K,V)
			local Player = game.Players:GetPlayerByUserId(K)
			if Player then
				local Stats = require(Player.Stats)
				local Exp = obj.Exp*obj.Model.Humanoid.MaxHealth/V
				Stats.ChangeStat("MStats","Exp",Exp)
			end
		end)
		wait(1)
		obj.Model:Remove()
	end
	
	obj.LoadAnimations = function()
		
	end
	
	obj.AnimationHandler = function()
		
	end
	
	return obj
end

local Human = {}
Human.new = function(Stats)
	local obj = LivingThing.new(Stats)
	
	obj.FindTarget = function()
		local InputInfo = {}
		local NearestPlayer = FindNearestPlayer(obj.Model,obj.ViewRadius)
		if NearestPlayer then
			InputInfo.Target = NearestPlayer
			local Wall = game.ReplicatedStorage.Events.RC:InvokeClient(NearestPlayer,obj.Model.HumanoidRootPart)
			if Wall then
				InputInfo.Wall = Wall
			end
		else InputInfo.Wall = nil
		end
		return InputInfo
		
	end
	
	
	local PreOnSpawn = obj.OnSpawn
	obj.OnSpawn = function()
		PreOnSpawn()
		obj.BodyGyro.MaxTorque = Vector3.new(0,0,0)
		obj.BodyGyro.D = 0
		obj.BodyGyro.P = 4500
		obj.Status.AddStatus("ChasingRight",false)
		obj.Status.ConnectStatAndStatus("Speed","ChasingRight",0.1)
		--AddActions
		local SetOwner = {}
		local RemoveOwner = {}
		local Attack  = {}
		local Roll  = {}
		local ChasePlayer  = {}
		local Idle = {}
		local ComeBackToStartPosition = {}
		SetOwner.F = function(InputInfo)
			obj.Status.Owner = InputInfo.Target
			obj.Model.PrimaryPart:SetNetworkOwner(InputInfo.Target)
		end
		SetOwner.Weights = function(InputInfo)
			local Weight = 0
			if not obj.Status.Owner then
				Weight+=300
			else
				Weight-=300
			end
			if not InputInfo.Target then
				Weight-=300
			end
			return Weight
		end
		RemoveOwner.F = function(InputInfo)
			obj.Status.Owner = nil
			obj.Model.PrimaryPart:SetNetworkOwner(nil)
		end
		RemoveOwner.Weights = function(InputInfo)
			local Weight = 0
			if obj.Status.Owner then
				Weight+=300
			else
				Weight-=300
			end
			if InputInfo.Target then
				Weight-=300
			end
			return Weight
		end
		Idle.F = function(InputInfo)
			obj.Status.Walking = false
		end
		Idle.Weights = function(InputInfo)
			local Weight = 0
			if not obj.Status.Attacking then
				Weight+=40
			end
			if Operations.CheckDistance(obj.Model.PrimaryPart.Position,obj.StartPosition)<=obj.DistanceToAttack then
				Weight+=40
			end
			if not InputInfo.Target then
				Weight+=60
			end
			if obj.Status.Owner then
				Weight-=100
			end
			return Weight
		end
		ComeBackToStartPosition.F = function(InputInfo)
			obj.Status.Walking = true
			obj.Model.Humanoid:MoveTo(obj.StartPosition)
		end
		ComeBackToStartPosition.Weights = function(InputInfo)
			local Weight = 0
			if not obj.Status.Attacking then
				Weight+=40
			end
			if Operations.CheckDistance(obj.Model.PrimaryPart.Position,obj.StartPosition)>obj.DistanceToAttack then
				Weight+=40
			end
			if not InputInfo.Target then
				Weight+=60
			end
			if obj.Status.Owner then
				Weight-=100
			end
			return Weight
		end
		Attack.F = function(InputInfo)
			obj.Model.Humanoid:Move(Vector3.new(0,0,0))
			obj.Status.Walking = false
			obj.Status.Attacking = true
			obj.Status.AnimDebounce = true
			obj.BodyGyro.MaxTorque = Vector3.new(0,2000,0)
			obj.BodyGyro.CFrame = CFrame.new(obj.Model.PrimaryPart.Position,InputInfo.Target.Character.PrimaryPart.Position)
			wait(0.3)
			obj.BodyGyro.MaxTorque = Vector3.new(0,0,0)
			obj.DamageTable = {}
			obj.Status.CanDamage = true
			wait(0.7)
			obj.DamageTable = {}
			obj.Status.CanDamage = false
			obj.Status.Attacking = false
		end
		Attack.Weights = function(InputInfo)
			local Weight = 0
			if InputInfo.Target then
				Weight+=50
				if not obj.Status.Attacking 
					and not obj.Status.Rolling then
					Weight+=50
				end
				if Operations.CheckDistance(obj.Model.PrimaryPart.Position,InputInfo.Target.Character.PrimaryPart.Position)<=obj.DistanceToAttack then
					Weight+=60
				end
			end
			return Weight
		end
		Roll.F = function(InputInfo)
			obj.Status.AnimDebounce = true
			obj.Status.Rolling = true
			obj.SetCoolDown("Roll",4)
			obj.Status.RecalculateSpeed()
			local CF = obj.Model.HumanoidRootPart.CFrame*CFrame.new(0,0,20)
			obj.Model.Humanoid:MoveTo(CF.p)
			wait(1)
			obj.Status.Rolling = false
			obj.Status.RecalculateSpeed()
		end
		Roll.Weights = function(InputInfo)
			local Weight = 0
			if InputInfo.Target then
				Weight+=50
				local PlayerStatus = require(InputInfo.Target.Status)
				if PlayerStatus.Attacking 
					and obj.CDList["Roll"]<=0
				then
					Weight+=100
				end
				if not obj.Status.Attacking then
					Weight+=50
				end
			end
			return Weight
		end
		ChasePlayer.F = function(InputInfo)
			obj.Model.Humanoid.AutoRotate = true
			obj.Status.Walking = true
			if InputInfo.Wall then
				PathFind(obj.Model,obj.Model.HumanoidRootPart,InputInfo.Target.Character.HumanoidRootPart.Position)
			else
				local Direction = InputInfo.Target.Character.PrimaryPart.Position-obj.Model.HumanoidRootPart.Position
				obj.Model.Humanoid:Move(Direction)
			end
		end
		ChasePlayer.Weights = function(InputInfo)
			local Weight = 0
			if InputInfo.Target then
				Weight+=40
				if not obj.Status.Attacking 
					and not obj.Status.Rolling then
					Weight+=40
				end
				if Operations.CheckDistance(obj.Model.PrimaryPart.Position,InputInfo.Target.Character.PrimaryPart.Position)>obj.DistanceToAttack then
					Weight+=40
				end
			end
			return Weight
		end
		--Add actions to actiontable
		obj.AddAction(Attack)
		obj.AddAction(ChasePlayer)
		obj.AddAction(SetOwner)
		obj.AddAction(RemoveOwner)
		obj.AddAction(ComeBackToStartPosition)
		obj.AddAction(Idle)
		obj.AddAction(Roll)
		obj.CDList.Roll = 0
		obj.TouchedConnections.Weapon = obj.Model:FindFirstChild("Weapon").Blade.Touched:Connect(function(Hit)
			if Hit.Parent~=obj.Model then
				if obj.Status.CanDamage then
					local Player = game.Players:GetPlayerFromCharacter(Hit.Parent)
					if Player then
						if Player.Character.Humanoid.Health>0 then
							if not table.find(obj.DamageTable,Player.Character) then
								table.insert(obj.DamageTable,Player.Character)
								local PlayerStats = require(Player.Stats)
								local EnemyArmor = PlayerStats.GetStat("HStats","Armor")
								local Damage = 0
								table.foreach(EnemyArmor,function(Key,V)
									if V>obj.Damage[Key] then
										local K = obj.Damage[Key]/V
										if K>0.25 then
											Damage+=obj.Damage[Key]*(K/2)
										end
									else
										Damage+=obj.Damage[Key]
									end
								end)
								Player.Character.Humanoid:TakeDamage(Damage)
							end
						end
					end
				end
			end
		end)
	end

	local function LoadAnimation(Name)
		local Folder = game.ReplicatedStorage.Animations.Human.Common
		local Anim = Folder:FindFirstChild(Name)
		if not Anim then
			Anim = Folder.Parent.Sword:FindFirstChild("RightHand") 
		end
		if not Anim then
			Anim = Folder.Parent.Sword:FindFirstChild("IdleRight") 
		end
		if Anim then
			return obj.Model.Humanoid.Animator:LoadAnimation(Anim)
		end
		return
	end

	obj.LoadAnimations = function()
		obj.Animations.Idle = LoadAnimation("Idle")
		obj.Animations.SwordIdle = LoadAnimation("SwordIdle")
		obj.Animations.Walk = LoadAnimation("Walk")
		obj.Animations.Attack = LoadAnimation("Attack")
		obj.Animations.Roll = LoadAnimation("Roll")
		obj.Animations.ChasingRight = LoadAnimation("ChasingRight")
	end
	
	obj.AnimationHandler = function()
		coroutine.resume(coroutine.create(function()
			obj.Animations.Idle:Play()
			obj.Animations.SwordIdle:Play()
			while obj.Model.Humanoid.Health>0 do
				if obj.Status.Walking 
					and not obj.Status.GetAdditionalStatus("ChasingRight")
				then
					if not obj.Animations.Walk.IsPlaying then
						obj.Animations.Idle:Stop()
						obj.Animations.Walk:Play()
					end
				else
					if obj.Animations.Walk.IsPlaying then
						obj.Animations.Walk:Stop()
						obj.Animations.Idle:Play()
					end
				end
				
				if obj.Status.Rolling 
					and obj.Status.AnimDebounce
				then
					if not obj.Animations.Roll.IsPlaying then
						obj.Status.AnimDebounce = false
						obj.Animations.Roll:Play()
					end
				end
				
				if obj.Status.Attacking and
					obj.Status.AnimDebounce
				then
					if not obj.Animations.Attack.IsPlaying then
						obj.Animations.Attack:Play()
						obj.Status.AnimDebounce= false
					end
				end
				
				if obj.Status.GetAdditionalStatus("ChasingRight") then
					if not obj.Animations.ChasingRight.IsPlaying then
						obj.Animations.Walk:Stop()
						obj.Animations.ChasingRight:Play()
					end
				else
					if obj.Animations.ChasingRight.IsPlaying then
						obj.Animations.ChasingRight:Stop()
					end
				end
				wait()
			end
		end))
	end
	
	return obj
end

local Bandit = {}
Bandit.new = function(Stats)
	local obj = Human.new(Stats)
	return obj
end

local MobTable = {}
MobTable.LivingThing = LivingThing
MobTable.Human = Human
MobTable.Bandit = Bandit

module.Behavior = function(Stats)
	local Mob = MobTable[Stats.Name].new(Stats)
	Mob.LoadAnimations()
	Mob.OnSpawn()
	Mob.AnimationHandler()
	coroutine.wrap(function(Mob)
		while true do
			if Mob.Model.Humanoid.Health>0 then
				local InputInfo = Mob.FindTarget()
				Mob.DefineAction(InputInfo)
			else
				break
			end
			wait(.0001)
		end
		Mob.OnDied()
	end)(Mob)
end

return module
