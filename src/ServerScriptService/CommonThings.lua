local module = {}

local Operations = require(game.ServerScriptService.Operations)

function module.SpawnDrop(Name,Type,Where,Count)
	local Folder = game.ReplicatedStorage.Models:FindFirstChild(Type)
	local Model = Folder:FindFirstChild(Name)
	local Thing = Model:Clone()
	Operations.Weld(Thing)
	Thing.Parent = game.Workspace
	Operations.ChangeCollisions(Thing,true)
	local Collision = Instance.new("Part",Thing)
	Collision.Name = "Collision"
	Collision.Shape = Enum.PartType.Ball
	local Size = 10
	Collision.Size = Vector3.new(Size,Size,Size)
	Collision.CanCollide = false
	Collision.Transparency = 1
	Operations.WeldOneToAnother(Collision,Thing.PrimaryPart,CFrame.Angles(180,0,0))
	Thing:MoveTo(Where)
	local TableOfPlayers = {}
	Collision.Touched:Connect(function(Hit)
		local Player = game.Players:GetPlayerFromCharacter(Hit.Parent)
		if Player then
			if not table.find(TableOfPlayers,Player) then
				game.ReplicatedStorage.Events.AddDrop:FireClient(Player,Collision,Name,Type,Count,true)
				table.insert(TableOfPlayers,Player)
				local Pos = table.find(TableOfPlayers,Player)
				while Player
					and Player.Character
					and Player.Character.Humanoid.Health>0
					and Collision
					and (Player.Character.HumanoidRootPart.Position-Collision.Position).magnitude<Size
				do
					wait(1)
				end
				table.remove(TableOfPlayers,Pos)
				game.ReplicatedStorage.Events.AddDrop:FireClient(Player,Collision,Name,Type,Count,false)
			end
		end
	end)
end

function module.TeleportationButton(Button1,Button2,AdditionFunction)
	Button1.Touched:Connect(function(Hit)
		if game.Players:GetPlayerFromCharacter(Hit.Parent) then
			Hit.Parent:MoveTo(Button2.Position+Vector3.new(0,0,5))
			if AdditionFunction then
				AdditionFunction(game.Players:GetPlayerFromCharacter(Hit.Parent),true)
			end
		end
	end)
	Button2.Touched:Connect(function(Hit)
		if game.Players:GetPlayerFromCharacter(Hit.Parent) then
			Hit.Parent:MoveTo(Button1.Position+Vector3.new(0,0,5))
			if AdditionFunction then
				AdditionFunction(game.Players:GetPlayerFromCharacter(Hit.Parent),false)
			end
		end
	end)
end

function module.ResetStats(Player)
	local Stats = require(Player.Stats)
	Stats.ResetStats()
end

function module.AddArmorModel(Name,Type,Player,Where)
	local Model = game.ReplicatedStorage.Models.Armor:FindFirstChild(Name)
	local Clone = Model:Clone()
	Operations.Weld(Clone)
	if Type == "Pants" then
		Operations.Weld(Clone.Left)
		Operations.Weld(Clone.Right)
		Operations.Weld(Clone.Right.Lower)
		Operations.Weld(Clone.Left.Lower)
	end
	if Type == "Left glove" 
		or Type == "Right glove"
	then
		Operations.Weld(Clone.Lower)
		Operations.Weld(Clone.Mid)
	end
	Clone.Parent = Player.Character
	Clone.Name = Type
	local Where = Player.Character:FindFirstChild(Where)
	local Angles = CFrame.Angles(0,0,0)
	if Type == "Pants" then
		Operations.WeldOneToAnother(Clone.Right.PrimaryPart,Player.Character.RightUpperLeg)
		Operations.WeldOneToAnother(Clone.Right.Lower.PrimaryPart,Player.Character.RightLowerLeg)
		Operations.WeldOneToAnother(Clone.Left.PrimaryPart,Player.Character.LeftUpperLeg)
		Operations.WeldOneToAnother(Clone.Left.Lower.PrimaryPart,Player.Character.LeftLowerLeg)
	end
	if Type == "Left glove" then
		Operations.WeldOneToAnother(Clone.Mid.PrimaryPart,Player.Character.LeftHand1)
		Operations.WeldOneToAnother(Clone.Lower.PrimaryPart,Player.Character.LeftHand2)
	end
	if Type == "Right glove" then
		Angles = CFrame.Angles(math.rad(180),0,0)
		Operations.WeldOneToAnother(Clone.Mid.PrimaryPart,Player.Character.RightHand1,Angles)
		Operations.WeldOneToAnother(Clone.Lower.PrimaryPart,Player.Character.RightHand2,Angles)
	end
	Operations.WeldOneToAnother(Clone.PrimaryPart,Where,Angles)
end

function module.AddWeaponModel(HandFromButton,Thing,Player,IsLeft,Status,Stats,CertainType)
	local Model = game.ReplicatedStorage.Models.Weapon:FindFirstChild(Thing.Name)
	local Clone = Model:Clone()
	Operations.Weld(Clone)
	Clone.Parent = Player.Character
	Clone.Name = "Weapon"..HandFromButton.L
	local Where = Player.Character.LowerTorso
	local Side = 1
	if IsLeft then
		Side = -1
	end
	local Offset = CFrame.new(Side*Where.Size.X*1.05,0,0)
	local Angles = CFrame.Angles(-90,0,0)
	if CertainType == "Great sword" then
		Where = Player.Character.UpperTorso
		Angles = CFrame.Angles(0,math.rad(90),math.rad(Side*160))
		Offset = CFrame.new(0,-Where.Size.Y*0.5,-Where.Size.Z*1.3)
	end
	Operations.WeldOneToAnother(Clone.PrimaryPart,Where,Angles*Offset)
	Status.AddSourceOfDamage(HandFromButton.Hand)
	if Status.Connections[HandFromButton.Hand] then
		Status.Connections[HandFromButton.Hand]:Disconnect()
	end
	local Attachment1 = Instance.new("Attachment",Clone.Blade)
	local Attachment2 = Instance.new("Attachment",Clone.Blade)
	Attachment1.Position = Vector3.new(0,2,0)
	Attachment2.Position = Vector3.new(0,-2,0)
	local Trail = Instance.new("Trail",Clone.Blade)
	Trail.Attachment1 = Attachment2
	Trail.Attachment0 = Attachment1
	Trail.Lifetime = 0.1
	Trail.Transparency = NumberSequence.new(1)
	Status.Connections[HandFromButton.Hand] = Clone.Blade.Touched:Connect(function(Hit)
		if Hit.Parent~=Player.Character 
			and Status.GetCanDamage(HandFromButton.Hand)
		then
			local Hum = Hit.Parent:FindFirstChild("Humanoid")
			if Hum then
				local Found = false
				table.foreach(Status.GetSourceOfDamage(HandFromButton.Hand),function(K,V)
					if V == Hit.Parent then
						Found = true
						return
					end
				end)
				if not Found then
					local EnemyPlayer = game.Players:GetPlayerFromCharacter(Hit.Parent)
					local EnemyStatus,EnemyStats
					local CanDamage = true
					if EnemyPlayer then
						EnemyStatus = require(EnemyPlayer.Status)
						EnemyStats = require(EnemyPlayer.Stats)
						if EnemyStatus.Pvp 
							or Status.Pvp
						then
							CanDamage = false
						end
						else
						EnemyStatus = Hum.Parent:FindFirstChild("MobStatus")
						EnemyStats = Hum.Parent:FindFirstChild("MobStats")
						if EnemyStatus then
							EnemyStatus = require(EnemyStatus)
							EnemyStats = require(EnemyStats)
						end
					end
					if not EnemyStatus.Rolling and CanDamage then
						Status.AddToDamageTable(Hit.Parent,HandFromButton.Hand)
						local EnemyArmor = EnemyStats.GetStat("HStats","Armor")
						local Damage = Stats.GetDamage(HandFromButton.Hand)
						local DamageSum = 0
						table.foreach(EnemyArmor,function(Key,V)
							if V>Damage[Key] then
								local K = Damage[Key]/V
								if K>0.25 then
									DamageSum+=Damage[Key]*(K/2)
								end
							else
								DamageSum+=Damage[Key]
							end
						end)
						if not EnemyPlayer then
							EnemyStatus.AddDamage(Player,DamageSum)
						end
						Status.PlayWeaponSound("Hit",HandFromButton.Hand)
						Hum:TakeDamage(DamageSum)
					end
				end
			end
		end
	end)
end

function module.ReturnHand(IsLeft)
	if not IsLeft then
		return {
			Hand = "RightHand",
			L = ""
		}
	else
		return
			{
				Hand = "LeftHand",
				L = "L"
			}
	end
end

return module
