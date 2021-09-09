local TweenService = game:GetService("TweenService")
local Player= game.Players.LocalPlayer
local Status = require(Player.PlayerScripts.LocalStatus)
local Brick = Instance.new("Part",game.Workspace)
Brick.Anchored = false
Brick.CanCollide = false
Brick.Color = Color3.new(1, 0.25098, 0.101961)
local TorsoAngle = math.rad(45)
local tweenMain,tweenLowerTorso,tweenUpperTorso
local Camera = game.Workspace.CurrentCamera
local Neck = Player.Character.Head.Joint
local Main = Player.Character.HumanoidRootPart
local LowerTorso = Player.Character.LowerTorso.Joint
local LowerTorsoC0Buf = LowerTorso.C0
local UpperTorso = Player.Character.UpperTorso.Joint
local UpperTorsoC0Buf = UpperTorso.C0

game:GetService("RunService").RenderStepped:Connect(function()
	if Status.BattleMode 
		and not Status.Attacking
		and not Status.Rolling
		and not Status.Swinging
		and not Status.RunningWithShift
		and Status.ComboTimer<=Status.ComboTimerMax/2
	then
		Player.Character.Humanoid.AutoRotate = false
		local MoveVector = Status.GetMoveVector()
		if MoveVector~=Vector3.new(0,0,0) then
			local Direction = Camera.CFrame:VectorToWorldSpace(Vector3.new(0,0,-1))
			local GoalVector = (Main.CFrame+Direction).p
			
			local GoalMain = Vector3.new(GoalVector.x,Main.CFrame.p.y,GoalVector.z)
			
			local goalMain = {}
			goalMain.CFrame = CFrame.new(Main.CFrame.p,GoalMain)
			local goalLowerTorso = {}
			local K = MoveVector.X
			if MoveVector.Z==-1 then
				K = -K
			end
			goalLowerTorso.C0 = LowerTorsoC0Buf*CFrame.Angles(0,TorsoAngle*K,0)
			local goalUpperTorso = {}
			goalUpperTorso.C0 = UpperTorsoC0Buf*CFrame.Angles(0,-TorsoAngle*K,0)
			
			local tweenInfoMain = TweenInfo.new(0.2)
			local tweenInfoLowerTorso = TweenInfo.new(0.2)
			local tweenInfoUpperTorso = TweenInfo.new(0.2)

			tweenMain = TweenService:Create(Main, tweenInfoMain, goalMain)
			tweenLowerTorso = TweenService:Create(LowerTorso, tweenInfoLowerTorso, goalLowerTorso)
			tweenUpperTorso = TweenService:Create(UpperTorso, tweenInfoUpperTorso, goalUpperTorso)
			
			tweenMain:Play()
			tweenLowerTorso:Play()
			tweenUpperTorso:Play()
			--Brick.CFrame = CFrame.new(Main.CFrame.p,GoalMain)
		end
	else
		if tweenMain then
			tweenMain:Pause()
		end
		if tweenLowerTorso then
			tweenLowerTorso:Pause()
		end
		if tweenUpperTorso then
			tweenUpperTorso:Pause()
		end
		if LowerTorso.C0~=LowerTorsoC0Buf then
			LowerTorso.C0=LowerTorsoC0Buf
		end
		if UpperTorso.C0~=UpperTorsoC0Buf then
			UpperTorso.C0=UpperTorsoC0Buf
		end
		Player.Character.Humanoid.AutoRotate = true
	end
end)

game.ReplicatedStorage.Events.HeadRotation.OnClientEvent:Connect(function(TargetPlayer,CF)
	if TargetPlayer~=Player then
		if TargetPlayer.Character then
			TargetPlayer.Character.Neck.Joint.C0 = CF
			end
	end
end)