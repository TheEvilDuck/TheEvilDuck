local Player = game.Players.LocalPlayer
local Character = Player.Character
local Humanoid = Character.Humanoid
local Animator = Humanoid.Animator

local WalkSpeedAnimationK = 18
local RunSpeedddAnimationK = 15

local Status = require(Player.PlayerScripts:WaitForChild("LocalStatus"))

local CommonAnimations = {}

local function LoadCertainAnimation(Name)
	local Anim = game.ReplicatedStorage.Animations.Human.Common:FindFirstChild(Name)
	if Anim then
		CommonAnimations[Name] = Humanoid.Animator:LoadAnimation(Anim)
	end
end

LoadCertainAnimation("Walk")
LoadCertainAnimation("Idle") 
LoadCertainAnimation("Jump") 
LoadCertainAnimation("FreeFalling") 
LoadCertainAnimation("Roll") 
LoadCertainAnimation("Run") 

CommonAnimations.Idle:Play()

local function CalculateK()
	if not Status.BattleMode or Status.Attacking then
		return 1
	else
		local MoveVector = Status.GetMoveVector()
		if (MoveVector.X~=0 or MoveVector.Z==1)
			and not (MoveVector.Z==-1) then
			return -1
		else
			return 1
		end
	end
end

local function onChangedDirectionOfMovement()
	CommonAnimations.Walk:AdjustSpeed(Humanoid.WalkSpeed/WalkSpeedAnimationK*1.5*CalculateK())
end

local function onRunning(Speed)
	if not Status.Jumping then
		if Speed >Humanoid.WalkSpeed*0.1 and not Status.Running
			then
			Status.Running = true
			CommonAnimations.Idle:Stop()
			if Status.Shifting 
				and Status.RunningWithShift
			then
				CommonAnimations.Run:Play()
				else
				CommonAnimations.Walk:Play()
			end
		elseif Speed <= Humanoid.WalkSpeed*0.1 and Status.Running 
		then
			Status.Running = false
			CommonAnimations.Idle:Play()
			CommonAnimations.Walk:Stop()
			CommonAnimations.Run:Stop()
		end
		game.ReplicatedStorage.Events.PlayerWalked:FireServer(Status.Running)
		CommonAnimations.Walk:AdjustSpeed(Humanoid.WalkSpeed/WalkSpeedAnimationK*1.5*CalculateK())
		CommonAnimations.Run:AdjustSpeed(Humanoid.WalkSpeed/RunSpeedddAnimationK)
	end
end

local function onJumping(IsJumping)
	if IsJumping then
	Status.Jumping = true
	CommonAnimations.Jump:Play()
		CommonAnimations.Walk:Stop()
		CommonAnimations.Run:Stop()
	end
end

local FallTime = 0
local TimeForChangeAnimation = 6


function LandedStateListen(OldState,NewState)
	if NewState == Enum.HumanoidStateType.Freefall then
		Status.FreeFalling = true
		if Status.Jumping then
			TimeForChangeAnimation = 10
		else
			TimeForChangeAnimation = 5
		end
		while Status.FreeFalling do
			wait(0.05)
			FallTime+=1
			if FallTime>=TimeForChangeAnimation then
				CommonAnimations.Jump:Stop()
				CommonAnimations.FreeFalling:Play()
				break
			end
		end
	elseif NewState == Enum.HumanoidStateType.Landed then
		Status.FreeFalling = false
		CommonAnimations.Jump:Stop()
		CommonAnimations.FreeFalling:Stop()
		FallTime = 0
		Status.Jumping = false
		if Status.Running then
			if Status.Shifting 
				and Status.RunningWithShift
			then
				CommonAnimations.Run:Play()
			else
				CommonAnimations.Walk:Play()
			end
		end
		CommonAnimations.Walk:AdjustSpeed(Humanoid.WalkSpeed/WalkSpeedAnimationK*1.5*CalculateK())
		CommonAnimations.Run:AdjustSpeed(Humanoid.WalkSpeed/RunSpeedddAnimationK)
	end
end

function OnRolling()
	if Status.Rolling then
		CommonAnimations.Walk:Stop()
		CommonAnimations.Run:Stop()
		CommonAnimations.Roll:Play()
	else
		if Status.Running then
			if Status.Shifting 
				and Status.RunningWithShift
			then
				CommonAnimations.Run:Play()
			else
				CommonAnimations.Walk:Play()
			end
		end
		CommonAnimations.Walk:AdjustSpeed(Humanoid.WalkSpeed/WalkSpeedAnimationK*1.5*CalculateK())
		CommonAnimations.Run:AdjustSpeed(Humanoid.WalkSpeed/RunSpeedddAnimationK)
	end
end

function OnShifting()
	if not Status.Jumping 
		and not Status.FreeFalling
		and not Status.Rolling
		and not Status.Attacking
	then
		if Status.Running then
			if Status.Shifting 
				and Status.RunningWithShift
			then
				CommonAnimations.Walk:Stop()
				CommonAnimations.Run:Play()
			else
				CommonAnimations.Run:Stop()
				if not CommonAnimations.Walk.IsPlaying then
					CommonAnimations.Walk:Play()
				end
			end
		end
		CommonAnimations.Walk:AdjustSpeed(Humanoid.WalkSpeed/WalkSpeedAnimationK*1.5*CalculateK())
		CommonAnimations.Run:AdjustSpeed(Humanoid.WalkSpeed/RunSpeedddAnimationK)
	end
end

Humanoid.Running:connect(onRunning)
Humanoid.Jumping:connect(onJumping)
Humanoid.StateChanged:Connect(LandedStateListen)
game.ReplicatedStorage.Events.LocalRolling.Event:Connect(OnRolling)
game.ReplicatedStorage.Events.LocalShifting.Event:Connect(OnShifting)
game.ReplicatedStorage.Events.ChangedDirectionOfMovement.Event:Connect(onChangedDirectionOfMovement)