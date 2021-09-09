local Player = game.Players.LocalPlayer
local PlayerGui =  Player:WaitForChild("PlayerGui")
PlayerGui:WaitForChild("Menu")

local DamageInfo = {}
DamageInfo.DamageRightHand = 0
DamageInfo.DamageLeftHand = 0

game.ReplicatedStorage.Events.StatUpdated.OnClientEvent:Connect(function(Folder,Name,Value,ValueMax)
	local TableFunction = {}
	TableFunction.MStats = function()
		local Info,Text
		if Name == "Points" then
			local Where = PlayerGui.Menu.Main.Frames.Stats.Frame
			Info = Where.MStats:FindFirstChild(Name)
			Text = "Points: "..Value
			local Vis = false
			if Value>0 then
				Vis = true
			end
			table.foreach(Where.PStatsButtons:GetChildren(),function(K,V)
				if V.ClassName == "TextButton" then
					V.Visible = Vis
				end
			end)
		else
			Info = PlayerGui.Stats.MStats:FindFirstChild(Name)
			Text = Value
		end
		if Info then
			Info.Text = Text
		end
	end
	TableFunction.PStats = function()
		local Info = PlayerGui.Menu.Main.Frames.Stats.Frame.PStats:FindFirstChild(Name)
		if Info then
			Info.Text = Name..": "..Value
		end
	end
	TableFunction.HStats = function()
		local Info,Text
		if ValueMax then
			local What = PlayerGui.Stats.HStats:FindFirstChild(Name)
			Info = What.Value
			Text = math.floor(Value).."/"..ValueMax
			What.Bar.Size = UDim2.new(Value/ValueMax,0,1,0)
		else
			if Name == "DamageRightHand" or Name=="DamageLeftHand" then
				Info = PlayerGui.Menu.Main.Frames.Stats.Frame.HStats.Damage
				local Sum = 0
				table.foreach(Value,function(K,V)
					Sum+=V
				end)
				DamageInfo[Name] = Sum
				Text = "Damage: "..DamageInfo.DamageRightHand.."(Right)+"..DamageInfo.DamageLeftHand.."(Left)"
			else
				Info = PlayerGui.Menu.Main.Frames.Stats.Frame.HStats:FindFirstChild(Name)
				local V = Value
				if Name == "Armor" then
					local Sum = 0
					table.foreach(Value,function(K,V)
						Sum+=V
					end)
					V = Sum
				end
				Text = Name..": "..V
			end
		end
		if Info then
			Info.Text = Text
		end
	end
	
	local Execute = TableFunction[Folder]
	if Execute then
		Execute()
	end
end)

--Connecting update events to PStats buttons
table.foreach(PlayerGui.Menu.Main.Frames.Stats.Frame.PStatsButtons:GetChildren(), function(K,V)
	if V.ClassName == "TextButton" then
		V.MouseButton1Click:Connect(function()
			game.ReplicatedStorage.Events.IncreasePStat:FireServer(V.Name)
		end)
	end
end)