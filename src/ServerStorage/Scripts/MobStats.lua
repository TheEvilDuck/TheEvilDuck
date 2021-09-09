local module = {}
local HStats = {}
HStats.Armor = 
	{
		Piercing = 0,
		Cutting = 0,
		Slashing = 0,
		Bludgeoning = 0
	}
HStats.Damage = 
	{
		Piercing = 0,
		Cutting = 0,
		Slashing = 0,
		Bludgeoning = 0
	}
function module.GetStat(Folder,Name)
	if Folder == "HStats" then
		return HStats[Name]
	end
end
return module
