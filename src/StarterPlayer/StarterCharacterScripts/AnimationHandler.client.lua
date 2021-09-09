local Player = game.Players.LocalPlayer
local Equipment = require(Player.PlayerScripts:WaitForChild("LocalEquipment"))
local Status = require(Player.PlayerScripts:WaitForChild("LocalStatus"))

local IdleAnimations = {}

local function IdleUpdate()
	if Player.Character then
		if Player.Character.Humanoid.Health>0 then
			local Animator = Player.Character.Humanoid.Animator
			table.foreach(IdleAnimations,function(K,V)
				if V then
					V:Stop()
					V:Destroy()
				end
			end)
			local Hands = {}
			Hands.RightHand = Equipment.GetEquipment("RightHand")
			Hands.LeftHand = Equipment.GetEquipment("LeftHand")
			local function LoadIdleAnimation(Side)
				if Hands[Side.."Hand"] then
				local Type = Hands[Side.."Hand"].Type
				local Where = game.ReplicatedStorage.Animations.Human:FindFirstChild(Type)
				local Animation = Where["Idle"..Side]
				if Status.TwoHanded then
					Animation = Where["IdleBoth"]
				end
				IdleAnimations[Side.."Hand"] = Animator:LoadAnimation(Animation)
				else
					IdleAnimations[Side.."Hand"] = nil
				end
			end
			if Status.TwoHanded then
				local Side
				table.foreach(Hands,function(K,V)
					if V then
						Side = K
					end
				end)
				Side = string.gsub(Side,"Hand","")
				LoadIdleAnimation(Side)
			else
				LoadIdleAnimation("Right")
				LoadIdleAnimation("Left")
			end
		end
	end
	
end

local BattleAnims = {}
BattleAnims.RightHand = {}
BattleAnims.LeftHand = {}

local function LoadAnimation(Anim,Where)
	BattleAnims[Where][Anim.Name] = Player.Character.Humanoid.Animator:LoadAnimation(Anim)
end

local function LoadBattleAnims(Type,Hand)
	local Folder = game.ReplicatedStorage.Animations.Human:FindFirstChild(Type)
	
	LoadAnimation(Folder:FindFirstChild(Hand),Hand)
	LoadAnimation(Folder:FindFirstChild(Hand.."2"),Hand)
	LoadAnimation(Folder:FindFirstChild(Hand.."3"),Hand)
	LoadAnimation(Folder:FindFirstChild(Hand.."Strong"),Hand)
	LoadAnimation(Folder:FindFirstChild(Hand.."Strong2"),Hand)
	LoadAnimation(Folder:FindFirstChild(Hand.."Strong3"),Hand)
	LoadAnimation(Folder:FindFirstChild("AfterRoll"..Hand),Hand)
	LoadAnimation(Folder:FindFirstChild("Both"),Hand)
	LoadAnimation(Folder:FindFirstChild("Both2"),Hand)
	LoadAnimation(Folder:FindFirstChild("Both3"),Hand)
	LoadAnimation(Folder:FindFirstChild("BothStrong"),Hand)
	LoadAnimation(Folder:FindFirstChild("BothStrong2"),Hand)
	LoadAnimation(Folder:FindFirstChild("AfterRollBoth"),Hand)
end

local function UnloadBattleAnims()
	table.foreach(BattleAnims,function(K,V)
		table.foreach(V,function(K2,V2)
			V2:Stop()
			V2:Remove()
		end)
		V = {}
	end)
end

local function PlayAnimations(IsPlay)
	IdleUpdate()
	table.foreach(IdleAnimations,function(K,V)
		if V then
			if IsPlay then
				V:Play()
			else
				V:Stop()
			end
		end
	end)
end
game.ReplicatedStorage.Events.BattleModeChanged.Event:Connect(function(Value)
	PlayAnimations(Value)
	if Value then
		local Hands = {}
		local LocalEq = require(Player.PlayerScripts.LocalEquipment)
		local function CheckHand(Hand)
			local Eq = LocalEq.GetEquipment(Hand)
			if Eq then
				LoadBattleAnims(Eq.Type,Hand)
			end
		end
		CheckHand("RightHand")
		CheckHand("LeftHand")
	else
		UnloadBattleAnims()
	end
end)
game.ReplicatedStorage.Events.TwoHandedChanged.Event:Connect(function(Value)
	PlayAnimations(Value)
end)
game.ReplicatedStorage.Events.PlayBattleAnimation.Event:Connect(function(Name,Hand)
	local Anim = BattleAnims[Hand][Name]
	if Anim then
		Anim:Play()
	end
end)