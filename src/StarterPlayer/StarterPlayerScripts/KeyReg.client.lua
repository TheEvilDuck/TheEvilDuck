local Player = game.Players.LocalPlayer
Player:WaitForChild("Status")
Player:WaitForChild("Inventory")

local InputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalStatus = require(Player.PlayerScripts.LocalStatus)
local AllTheStuff = require(game.ReplicatedStorage.ModuleScripts.AllTheStuff)
local LocalEquipment = require(Player.PlayerScripts.LocalEquipment)
local PlayerModule = require(Player.PlayerScripts.PlayerModule)
local Controls = PlayerModule:GetControls()

local Hand = nil
local tween

local function DefineHand(IsLeft)
	Hand = "LeftHand"
	if not IsLeft then
		Hand = "RightHand"
	end
end



local SpeedTable = 
	{
		Sword = 0.4,
		["Great sword"] = 0.7,
		Dagger = 0.2,
		Axe = 0.5
	}

local HandAttackBuffer = nil

local function PlayAnimation(Name,Hand)
	game.ReplicatedStorage.Events.PlayBattleAnimation:Fire(Name,Hand)
end

local ComboTimer = 0
local ComboHit = 1
local ComboDebounce = true

local function StartCombo()
	LocalStatus.ComboTimer = LocalStatus.ComboTimerMax
	if ComboDebounce then
		ComboDebounce = false
		coroutine.resume(coroutine.create(function()
			while LocalStatus.ComboTimer>=0 do
				LocalStatus.ComboTimer-=1
				wait(0.1)
			end
			LocalStatus.ComboTimer = 0
			ComboHit = 1
			ComboDebounce = true
			game.ReplicatedStorage.Events.AttackEvent:FireServer(Hand,false)
		end))
	end
	ComboHit+=1
	if ComboHit>3 then
		ComboHit = 1
	end
end

local function Attack()
	local Weapon = LocalEquipment.GetEquipment(Hand)
	if Weapon then
		local CanAttack,Weight = game.ReplicatedStorage.Events.CanAttack:InvokeServer(Hand)
		if CanAttack then
			LocalStatus.Attacking = true
			local StrongTimeK = 1
			local Strong = ""
			if LocalStatus.Shifting then
				Strong = "Strong"
				StrongTimeK = 1.5
			end
			local AfterRoll = ""
			if LocalStatus.AfterRollAttack then
				AfterRoll = "AfterRoll"
			end
			local Hit = ""
			if ComboHit>1 then
				Hit = tostring(ComboHit)
			end
			if LocalStatus.TwoHanded then
				PlayAnimation(AfterRoll.."Both"..Strong..Hit,Hand)
			else
				PlayAnimation(AfterRoll..Hand..Strong..Hit,Hand)
			end
			StartCombo()
			wait(SpeedTable[Weapon.Type]*0.2*StrongTimeK)
			local MoveVector = LocalStatus.GetMoveVector()
			local CCFrame = game.Workspace.CurrentCamera.CFrame
			game.ReplicatedStorage.Events.AttackEvent:FireServer(Hand,true)
			LocalStatus.Swinging = true
			wait(SpeedTable[Weapon.Type]*0.2*StrongTimeK)
			LocalStatus.Swinging = false
			local MoveVector = LocalStatus.GetMoveVector()
			if MoveVector==Vector3.new(0,0,0) then
				MoveVector = Vector3.new(0,0,-1)
			end
			local Camera = game.Workspace.CurrentCamera
			local Main = Player.Character.HumanoidRootPart
			local Direction = Camera.CFrame:VectorToWorldSpace(MoveVector)
			local GoalVector = (Main.CFrame+Direction).p
			local Goal = Vector3.new(GoalVector.x,Main.CFrame.p.y,GoalVector.z)

			local goal = {}
			goal.CFrame = CFrame.new(Main.CFrame.p,Goal)

			local tweenInfo = TweenInfo.new(0.075)

			tween = TweenService:Create(Main, tweenInfo, goal)

			tween:Play()
			
			Player:Move(Direction)
			
			LocalStatus.ShakeCamera(Weight/15*StrongTimeK)
			wait(SpeedTable[Weapon.Type]*0.6*StrongTimeK)
			game.ReplicatedStorage.Events.AttackEvent:FireServer(Hand,false)
			LocalStatus.Attacking = false
			if tween then
				tween:Pause()
			end
		end
		end
end

local function TryAttack(IsLeft)
	if not LocalStatus.Attacking
		and not LocalStatus.Rolling 
	then
		DefineHand(IsLeft)
		Attack()
	end
	if not LocalStatus.Attacking 
		and LocalStatus.Rolling then
		LocalStatus.AfterRollAttack = true
		DefineHand(IsLeft)
	end
end

local function Roll()
	if not LocalStatus.Rolling 
		and not LocalStatus.FreeFalling
		and not LocalStatus.Jumping
		and not LocalStatus.Attacking
	then
	local CanRoll = game.ReplicatedStorage.Events.CanRoll:InvokeServer(true)
	if CanRoll then
			LocalStatus.Rolling = true
			local MoveVector = LocalStatus.GetMoveVector()
			local CCFrame = game.Workspace.CurrentCamera.CFrame
			local Direction = CCFrame:VectorToWorldSpace(MoveVector)
			if MoveVector == Vector3.new(0,0,0) then
				Direction = CCFrame:VectorToWorldSpace(Vector3.new(0,0,-1))
			end
			game.ReplicatedStorage.Events.LocalRolling:Fire()
			Player:Move(Direction)
			wait(0.8)
			game.ReplicatedStorage.Events.CanRoll:InvokeServer(false)
			if LocalStatus.AfterRollAttack then
				Attack()
			end
			LocalStatus.Rolling = false
			LocalStatus.AfterRollAttack = false
			game.ReplicatedStorage.Events.LocalRolling:Fire()
		end
	end
end

local function Run()
	local Coroutine = coroutine.create(function()
		LocalStatus.RunningWithShift = game.ReplicatedStorage.Events.CanRunWithShift:InvokeServer()
		game.ReplicatedStorage.Events.LocalShifting:Fire()
	end)
	coroutine.resume(Coroutine)
end

InputService.InputBegan:Connect(function(Key)
	local Char = Player.Character
	if Char then
		Char:WaitForChild("Humanoid")
		if Char.Humanoid.Health>0 then
			local Action = Key.KeyCode
			if Action==Enum.KeyCode.Unknown then
				Action = Key.UserInputType
			end
			local Table = string.split(tostring(Action),".")
			Action = Table[#Table]
			local TableFunction = {}
			TableFunction.E = function()
				local Loot = LocalStatus.GetLoot()
				if Loot then
					local Done = game.ReplicatedStorage.Events.AddItem:InvokeServer(Loot)
					if Done then
						LocalStatus.RemoveFromLootTable()
						local Point = Loot.Model.Collision:FindFirstChild("Point")
						if Point then
							Point.Value:Remove()
							Point:Remove()
							game.ReplicatedStorage.Events.RemoveLoot:FireServer(Loot.Model)
						end
						else
					end
				end
			end
			TableFunction.MouseButton1 = function()
				if LocalStatus.BattleMode then
					TryAttack(false)
				end
			end
			TableFunction.MouseButton2 = function()
				if LocalStatus.BattleMode then
					TryAttack(true)
				end
			end
			TableFunction.T = function()
				if not LocalStatus.Attacking
				and not LocalStatus.Rolling
				then
					LocalStatus.ChangeBattleMode()
					if LocalStatus.BattleMode then
						Player.PlayerGui.Menu.Main.Visible = false
					end
				end
			end
			TableFunction.F = function()
				if not LocalStatus.Attacking
					and not LocalStatus.Rolling
				then
					LocalStatus.ChangeTwoHanded()
				end
			end
			TableFunction.LeftControl = function()
				Roll()
			end
			TableFunction.LeftShift = function()
				LocalStatus.Shifting = true
				LocalStatus.RunningWithShift = true
				game.ReplicatedStorage.Events.ShiftStatusChange:FireServer(LocalStatus.Shifting)
				game.ReplicatedStorage.Events.LocalShifting:Fire()
				Run()
				while InputService:IsKeyDown(Enum.KeyCode.LeftShift) do
					wait()
				end
				LocalStatus.RunningWithShift = false
				LocalStatus.Shifting = false
				game.ReplicatedStorage.Events.ShiftStatusChange:FireServer(LocalStatus.Shifting)
				game.ReplicatedStorage.Events.LocalShifting:Fire()
			end
			local Execute = TableFunction[Action]
			if Execute then
				Execute()
			end
		end
	end
	
end)

--[[InputService.InputBegan:Connect(function(Key)
	local Char = Player.Character
	if Char then
	Char:WaitForChild("Humanoid")
	if Char.Humanoid.Health>0 then
	if Key.KeyCode == Enum.KeyCode.E then
		local Loot = LocalStatus.GetLoot()
		if Loot then
			local Done = game.ReplicatedStorage.Events.AddItem:InvokeServer(Loot)
			if not Done then
				--NO SPACE AAA
			end
		end
	elseif Key.UserInputType == Enum.UserInputType.MouseButton1  then
		if LocalStatus.BattleMode then
			Attack(false)
			if LocalStatus.TwoHanded then
				Attack(true)
			end
		end
	elseif Key.UserInputType == Enum.UserInputType.MouseButton2 then
		if LocalStatus.BattleMode then
			Attack(true)
		end
			elseif Key.KeyCode == Enum.KeyCode.T 
				and not LocalStatus.Attacking
				and not LocalStatus.Rolling
			then
		LocalStatus.ChangeBattleMode()
		if LocalStatus.BattleMode then
					InputService.MouseIconEnabled = false
					Player.PlayerGui.Menu.Main.Visible = false
		else
			InputService.MouseIconEnabled = true
		end
			elseif Key.KeyCode == Enum.KeyCode.F 
				and not LocalStatus.Attacking
				and not LocalStatus.Rolling
			then
		LocalStatus.ChangeTwoHanded()
	elseif Key.KeyCode == Enum.KeyCode.LeftControl then
				Roll()
		end
		end
	end
end)--]]