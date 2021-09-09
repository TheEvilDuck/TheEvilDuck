local Player = game.Players.LocalPlayer
Player:WaitForChild("Status")
local AllTheStuff = require(game.ReplicatedStorage.ModuleScripts.AllTheStuff)
local Status = require(Player.PlayerScripts.LocalStatus)


game.ReplicatedStorage.Events.AddDrop.OnClientEvent:Connect(function(Parent,Name,Type,Count,Visible)
	if Visible then
		if not Parent:FindFirstChild("Point") then
			local Display = Instance.new("BillboardGui",Player.PlayerGui.LootGui)
			Display.Adornee = Parent
			local Point = Instance.new("ObjectValue",Parent)
			Point.Name = "Point"
			Point.Value = Display
			Display.MaxDistance = 20
			Display.Size = UDim2.new(0,200,0,250)
			Display.StudsOffsetWorldSpace = Vector3.new(0,10,0)
			local Info = Player.PlayerGui.Menu.Main.Frames.Inventory.Info:Clone()
			Info.Size = UDim2.new(1,0,1,0)
			Info.Position = UDim2.new(0,0,0,0)
			Info.Parent = Display
			local Thing = AllTheStuff.GetThing(Name,Type)

			local VPCamera = Info.Image.Camera
			Info.Image.CurrentCamera = VPCamera
			VPCamera.Parent = Info.Image
			local Offset = CFrame.new(Vector3.new(4,0,0))
			local BaseCFrame = CFrame.new(Vector3.new(0,2,0))
			local CF = BaseCFrame*Offset*CFrame.Angles(0,math.rad(20),0)
			VPCamera.CFrame = CFrame.new(CF.p,BaseCFrame.p)*CFrame.Angles(0,0,math.rad(60))

			local ModelFolder = game.ReplicatedStorage.Models:FindFirstChild(Type)
			local Model = ModelFolder:FindFirstChild(Name)

			if Model then
				local Clone = Model:Clone()
				Clone.Parent = Info.Image
				Clone:SetPrimaryPartCFrame(CFrame.new(Vector3.new(0,0,0)))
				Clone.Name = "Model"
			end
			
			Info.Top.Text = Name
			Info.Desc.Text = Thing.Desc
			Info.Count.Text = Count
			Info.Visible = true
			Status.AddToLootTable(Parent.Parent,Name,Type,Count,Thing.Type)
		end
	elseif Parent then
		local Point = Parent:FindFirstChild("Point")
		if Point then
			Point.Value:Remove()
			Point:Remove()
			Status.RemoveFromLootTable(Parent.Parent)
		end
	end
end)