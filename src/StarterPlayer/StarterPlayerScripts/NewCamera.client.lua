local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

script.Parent:WaitForChild("LocalStatus")
local Status = require(script.Parent.LocalStatus)

local Camera = workspace.CurrentCamera
local cameraOffset = Vector3.new(2.75, 2.5, 9)
local offset = cameraOffset
local OffsetDirection = -1
local LastPos
local Player = Players.LocalPlayer


local cameraAngleX = 0
local cameraAngleY = 0

local function playerInput(actionName, inputState, inputObject)
	-- Calculate camera/player rotation on input change
	if inputState == Enum.UserInputState.Change then
		cameraAngleX = cameraAngleX - inputObject.Delta.X
		-- Reduce vertical mouse/touch sensitivity and clamp vertical axis
		cameraAngleY = math.clamp(cameraAngleY-inputObject.Delta.Y*0.4, -75, 75)
	end
end
ContextActionService:BindAction("PlayerInput", playerInput, false, Enum.UserInputType.MouseMovement, Enum.UserInputType.Touch)


	RunService.RenderStepped:Connect(function()
	if Player.Character then
		if Status.BattleMode then
			if Camera.CameraType ~= Enum.CameraType.Scriptable then
				Camera.CameraType = Enum.CameraType.Scriptable
				UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
				UserInputService.MouseIconEnabled = false
				LastPos = Player.Character.PrimaryPart.Position
			end
			local K = Status:GetMoveVector().X
			if OffsetDirection~=-K and K~=0 then
				OffsetDirection = -K
			end
			local Difference = offset.X-cameraOffset.X*OffsetDirection
			if math.abs(Difference)>=0.1 then
				offset = Vector3.new(offset.X+math.abs(Difference)*0.05*OffsetDirection,cameraOffset.Y,cameraOffset.Z)
			else
				offset = Vector3.new(cameraOffset.X*OffsetDirection,cameraOffset.Y,cameraOffset.Z)
			end
			
			if not LastPos then
				LastPos = Player.Character.PrimaryPart.Position
			end
			if LastPos~=Player.Character.PrimaryPart.Position then
				local Vector = Player.Character.PrimaryPart.Position-LastPos
				if Vector.magnitude<=0.001 then
					LastPos=Player.Character.PrimaryPart.Position
				else
					LastPos = LastPos+Vector*0.065
				end
			end
			local startCFrame = CFrame.new((LastPos)) * CFrame.Angles(0, math.rad(cameraAngleX), 0) * CFrame.Angles(math.rad(cameraAngleY), 0, 0)
			local cameraCFrame = startCFrame:ToWorldSpace(CFrame.new(offset))
			local cameraFocus = startCFrame:ToWorldSpace(CFrame.new(offset.X, offset.Y, -10000))
			Camera.CFrame = CFrame.new(cameraCFrame.Position, cameraFocus.Position)
		else
			if Camera.CameraType ~= Enum.CameraType.Custom then
				Camera.CameraType = Enum.CameraType.Custom
				UserInputService.MouseBehavior = Enum.MouseBehavior.Default
				UserInputService.MouseIconEnabled = true
			end
		end
	end
	end)