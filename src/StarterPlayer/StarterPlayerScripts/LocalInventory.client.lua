local Player = game.Players.LocalPlayer
local InventoryGUI = Player.PlayerGui:WaitForChild("Menu").Main.Frames.Inventory.Frame
local AllTheStuff = require(game.ReplicatedStorage.ModuleScripts.AllTheStuff)
local Info = InventoryGUI.Parent.Info
local LocalEquipment = require(Player.PlayerScripts.LocalEquipment)

local UseButton = Instance.new("TextButton")
UseButton.Text = "Use"
local UseButtonLeft = Instance.new("TextButton")
UseButtonLeft.Text = "Left"
UseButton.Visible = false
UseButtonLeft.Visible = false
UseButton.ZIndex = 4
UseButtonLeft.ZIndex = 4

local CountTable = {}

local IdForUse,MouseHoveredId
local ViewPort = Info.Image
local ViewPortCamera = Instance.new("Camera")
ViewPort.CurrentCamera = ViewPortCamera
ViewPortCamera.Parent = ViewPort
local ViewPortModel = nil

local Angle = -180


	
local function SetViewPortCFrame(Type)
	local Offset = CFrame.new(Vector3.new(0,1,2))
	local A = CFrame.Angles(0,math.rad(Angle),0)
	local BaseCFrame = CFrame.new(Vector3.new(0,0,0))
	local CF = BaseCFrame*A*Offset
	if Type == "Weapon" then
		Offset = CFrame.new(Vector3.new(0,0,4))
		BaseCFrame = CFrame.new(Vector3.new(0,2,0))
		CF = BaseCFrame*A*Offset
	end
	ViewPortCamera.CFrame = CFrame.new(CF.p,BaseCFrame.p)
end

UseButton.MouseButton1Click:Connect(function()
	game.ReplicatedStorage.Events.UseItem:FireServer(IdForUse,false)
end)
UseButtonLeft.MouseButton1Click:Connect(function()
	game.ReplicatedStorage.Events.UseItem:FireServer(IdForUse,true)
end)

local function CountUpdate(Id,Count)
	if Count > 0 then
		CountTable[Id]=Count
		if Info.Visible 
			and Id == MouseHoveredId
		then
			Info.Count.Text = Count
		end
	else
		local Slot = InventoryGUI:FindFirstChild(tostring(Id))
		if Slot then
			Slot:Remove()
		end
	end
end

game.ReplicatedStorage.Events.InventoryUpdate.OnClientEvent:Connect(function (Name,Type,Id,Count)
	local Button = Instance.new("ViewportFrame",InventoryGUI)
	local VPCamera = Instance.new("Camera")
	Button.CurrentCamera = VPCamera
	VPCamera.Parent = Button
	local Offset = CFrame.new(Vector3.new(2,1,1))
	local BaseCFrame = CFrame.new(Vector3.new(0,0,0))
	local CF = BaseCFrame*Offset
	local AngleK = CFrame.Angles(0,0,0)
	if Type == "Weapon" then
		Offset = CFrame.new(Vector3.new(4,0,0))
		BaseCFrame = CFrame.new(Vector3.new(0,2,0))
		CF = BaseCFrame*Offset*CFrame.Angles(0,math.rad(20),0)
		AngleK = CFrame.Angles(0,0,math.rad(60))
	elseif Type == "Armor" then
		Offset = CFrame.new(Vector3.new(-2,1,-1))
		BaseCFrame = CFrame.new(Vector3.new(0,0,0))
		CF = BaseCFrame*Offset
		AngleK = CFrame.Angles(0,0,0)
	end
	
	VPCamera.CFrame = CFrame.new(CF.p,BaseCFrame.p)*AngleK
	
	local ModelFolder = game.ReplicatedStorage.Models:FindFirstChild(Type)
	local Model = ModelFolder:FindFirstChild(Name)
	
	if Model then
		local Clone = Model:Clone()
		Clone.Parent = Button
		Clone:SetPrimaryPartCFrame(CFrame.new(Vector3.new(0,0,0)))
		Clone.Name = "Model"
	end
	
	Button.Name = Id
	Button.Size = UDim2.new(1,0,1,0)
	Button.BackgroundColor3 = Color3.new(0.85098, 0.807843, 0.627451)
	Button.Ambient = Color3.new(0.764706, 0.756863, 0.658824)
	Button.LightColor = Color3.new(0.870588, 0.890196, 0.796078)
	Button.BorderSizePixel = 2
	
	VPCamera.FieldOfView = 35
	local Thing = AllTheStuff.GetThing(Name,Type)
	
	CountTable[Id] = Count
	
	Button.MouseEnter:Connect(function()
		if MouseHoveredId~=Id then
			local PrevModel = ViewPort:FindFirstChild("Model")
			if PrevModel then
				PrevModel:Remove()
			end
			local Model = Button:FindFirstChild("Model")
			if Model then
				ViewPortModel = Model:Clone()
				ViewPortModel.Parent = ViewPort
				ViewPortModel:SetPrimaryPartCFrame(CFrame.new(Vector3.new(0,0,0)))
				ViewPortModel.Name = "Model"
			end
			Info.Top.Text = Name
			local Text = ""
			table.foreach(Thing,function(K,V)
				local TableText = ""
				if type(V)=="table" then
					table.foreach(V,function(K2,V2)
						TableText = TableText..K2..": "..V2.."\n"
					end)
				else
					TableText = V
				end
				Text = Text..K..": "..TableText.."\n"
			end)
			Info.Desc.Text = Text
			Info.Count.Text = CountTable[Id]
			MouseHoveredId = Id
		end
		Info.Visible = true
		local CurrentModel = ViewPortModel
			while Info.Visible 
			and CurrentModel == ViewPortModel do
			SetViewPortCFrame(Type)
			wait(0.1)
			Angle+=3
			end
	end)
	Button.MouseLeave:Connect(function()
		Angle = -180
		Info.Visible = false
	end)
	
	Button.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			if IdForUse==Id then
				UseButton.Visible = not UseButton.Visible
				if Type == "Weapon" then
					UseButtonLeft.Visible = not UseButtonLeft.Visible
				else
					UseButtonLeft.Visible = false
				end
			else
				IdForUse = Id
				UseButton.Parent = Button
				UseButton.Size = UDim2.new(1,0,0.2,0)
				UseButton.Position = UDim2.new(1,0,0,0)
				UseButton.Visible = true
				UseButtonLeft.Parent = Button
				UseButtonLeft.Size = UDim2.new(1,0,0.2,0)
				UseButtonLeft.Position = UDim2.new(1,0,0.2,0)
				if Type == "Weapon" then
					UseButton.Text = "Right"
					UseButtonLeft.Visible = true
				else
					UseButton.Text = "Use"
					UseButtonLeft.Visible = false
				end
			end
		end
	end)
end)

game.ReplicatedStorage.Events.InventorySlotUpdate.OnClientEvent:Connect(function(Id,Count)
	CountUpdate(Id,Count)
end)

game.ReplicatedStorage.Events.LocalEquipmentUpdate.OnClientEvent:Connect(function(Where,Name,Type)
	if Type then
		LocalEquipment.SetEquipment(Where,Name,Type)
	else
		LocalEquipment.RemoveEquipment(Where)
	end
end)