local Main = script.Parent.Parent

table.foreach(script.Parent.AllButtons:GetChildren(),function(K,V)
	V.MouseButton1Click:Connect(function()
		local Folder = Main.Frames:FindFirstChild(V.Name)
		if Folder then
			Folder.Frame.Visible = true
		end
		table.foreach(Main.Frames:GetChildren(),function(K2,V2)
			if V2~=Folder then
				V2.Frame.Visible = false
			end
		end)
		table.foreach(script.Parent.AllButtons:GetChildren(),function(K2,V2)
			if V2~=V then
				V2.BackgroundColor3 = Color3.new(1,1,1)
			end
		end)
		V.BackgroundColor3 = Color3.new(0.501961, 0.501961, 0.501961)
		end)
end)