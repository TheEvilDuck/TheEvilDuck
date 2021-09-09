local module = {}
function module.CheckWalls(from,to)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {from.Parent, to.Parent}
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	local Wall = workspace:Raycast(from.Position, to.Position-from.Position, raycastParams)
	if Wall then
		Wall = Wall.Instance
	end
	return Wall
end
return module
