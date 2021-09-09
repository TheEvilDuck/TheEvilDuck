local module = {}
function module.Weld(Folder)
	local d = Folder:GetChildren()
	for i =1,#d-1 do 
		if d[i].ClassName == "Part" 
			or d[i].ClassName == "UnionOperation"
			or d[i].ClassName == "MeshPart"
			or d[i].ClassName == "WedgePart"
		then
			local j = i+1
			while d[j].ClassName~="Part" 
				and d[j].ClassName~="UnionOperation"
				and d[j].ClassName ~= "MeshPart"
				and d[j].ClassName ~= "WedgePart"
				and j+1<=#d
			do
				j+=1
			end
			if d[j].ClassName == "Part" 
				or d[j].ClassName == "UnionOperation"
				or d[j].ClassName == "MeshPart"
				or d[j].ClassName == "WedgePart"
			then
				local w = Instance.new("Weld")
				w.Part0,w.Part1 = d[i],d[j]
				w.C0 = d[i].CFrame:inverse()
				w.C1 = d[j].CFrame:inverse()
				w.Parent = d[i]
			end
		end
	end
end

function module.WeldOneToAnother(What,To,Angles)
	local w = Instance.new("Weld",What)
	w.Name = "MainWeld"
	w.Part0,w.Part1 = What,To
	w.C0 = What.CFrame:inverse()
	local CF = To.CFrame
	if Angles then
		CF*=Angles
	end
	w.C1 = CF:Inverse()
end

function module.ChangeCollisions(Where,Value)
	local d = Where:GetChildren()
	for i = 1,#d do
		d[i].CanCollide = Value
	end
end

function module.CheckDistance(a,b)
	return (b-a).magnitude
end

function module.HashTableLength(Table)
	local Count = 0
	for i,j in pairs(Table) do
		Count+=1
	end
	return Count
end
return module
