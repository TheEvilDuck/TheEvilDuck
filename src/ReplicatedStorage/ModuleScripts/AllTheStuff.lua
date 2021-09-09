local module = {}
local TableOfAll = 
	{
		Weapon = 
		{
			["Rusted sword"] = 
			{
				Type = "Sword",
				Damage = 
				{
					Piercing = 0.25,
					Cutting = 2,
					Slashing = 0.5,
					Bludgeoning = 0.01
				},
				Desc = "Rusted sword. Start weapon",
				MaxCount = 1,
				Weight = 3,
				Required = {
					Strength = 2,
					Agility = 2
				},
				Scaling = {
					Strength = 0.005,
					Agility = 0.005
				}
			},
			["Heavy sword"] = 
			{
				Type = "Sword",
				Damage = 
				{
					Piercing = 0.01,
					Cutting = 3,
					Slashing = 1,
					Bludgeoning = 1
				},
				Desc = "Heavy iron sword",
				MaxCount = 1,
				Weight = 6,
				Required = {
					Strength = 7
				},
				Scaling = {
					Strength = 0.01,
				}
			},
			["Broken sword"] = 
			{
				Type = "Sword",
				Damage = 
				{
					Piercing = 0.01,
					Cutting = 1,
					Slashing = 0.05,
					Bludgeoning = 0.01
				},
				Desc = "A broken sword",
				MaxCount = 1,
				Weight = 2,
				Required = {
					Strength = 1,
					Agility = 1
				},
				Scaling = {
					Strength = 0.001,
					Agility = 0.001
				}
			},
			["Long sword"] = 
			{
				Type = "Sword",
				Damage = 
				{
					Piercing = 2,
					Cutting = 3,
					Slashing = 1,
					Bludgeoning = 0.25
				},
				Desc = "Is it katama? No. Just a long sword",
				MaxCount = 1,
				Weight = 4.5,
				Required = {
					Agility = 7
				},
				Scaling = {
					Agility = 0.01
				}
			},
			["Fang"] = 
			{
				Type = "Sword",
				Damage = 
				{
					Piercing = 0.5,
					Cutting = 3,
					Slashing = 5,
					Bludgeoning = 0.5
				},
				Desc = "What i beast must be using this?",
				MaxCount = 1,
				Weight = 5.5,
				Required = {
					Agility = 5,
					Strength = 7
				},
				Scaling = {
					Agility = 0.01,
					Strength = 0.015
				}
			},
			["Great sword"] = 
			{
				Type = "Great sword",
				Damage = 
				{
					Piercing = 1,
					Cutting = 8,
					Slashing = 5,
					Bludgeoning = 5
				},
				Desc = "Very heavy and big iron sword",
				MaxCount = 1,
				Weight = 14,
				Required = {
					Agility = 2,
					Strength = 10
				},
				Scaling = {
					Agility = 0.005,
					Strength = 0.02
				}
			},
			["Knife"] = 
			{
				Type = "Dagger",
				Damage = 
				{
					Piercing = 1,
					Cutting = 3,
					Slashing = 0.05,
					Bludgeoning = 0.01
				},
				Desc = "Stolen from kitchen",
				MaxCount = 1,
				Weight = 1,
				Required = {
					Agility = 4,
				},
				Scaling = {
					Agility = 0.015,
				}
			},
			["Bandit axe"] = 
			{
				Type = "Axe",
				Damage = 
				{
					Piercing = 0.05,
					Cutting = 1,
					Slashing = 7,
					Bludgeoning = 3
				},
				Desc = "Bad for trees",
				MaxCount = 1,
				Weight = 7,
				Required = {
					Strength = 6,
					Agility = 4,
				},
				Scaling = {
					Strength = 0.015,
					Agility = 0.01,
				}
			}
		},
		Scroll = 
		{
			["Test teleport scroll"] =
			{
				Type = "Teleport scroll",
				Desc = "Teleportation scroll",
				MaxCount = 10,
				Target = Vector3.new(-64.561, 0.5, -27.975)
			}
		},
		Potion = 
		{
			["Small stamina potion"] = 
			{
				Type = "HStat potion",
				Desc = "Test stamina potion",
				MaxCount = 10,
				Power = 0.1,
				Time = 2
			}
		},
		Armor = 
		{
			["Bronze helmet"] =
			{
				Type = "Helmet",
				Desc = "Test helmet",
				MaxCount = 1,
				Weight = 5,
				Armor = {
					Piercing = 1,
					Cutting = 3,
					Slashing = 2,
					Bludgeoning = 1
				}
			},
			["Bronze chessplate"] =
			{
				Type = "Chessplate",
				Desc = "Test chessplate",
				MaxCount = 1,
				Weight = 9,
				Armor = {
					Piercing = 1,
					Cutting = 6,
					Slashing = 3,
					Bludgeoning = 1
				}

			},
			["Bronze left shauldron"] =
			{
				Type = "Left shauldron",
				Desc = "Test left shauldron",
				MaxCount = 1,
				Weight = 3,
				Armor = {
					Piercing = 0.25,
					Cutting = 2,
					Slashing = 1,
					Bludgeoning = 0.25
				}

			},
			["Bronze right shauldron"] =
			{
				Type = "Right shauldron",
				Desc = "Test right shauldron",
				MaxCount = 1,
				Weight = 3,
				Armor = {
					Piercing = 0.25,
					Cutting = 2,
					Slashing = 1,
					Bludgeoning = 0.25
				}

			},
			["Bronze left shoe"] =
			{
				Type = "Left shoe",
				Desc = "Test left shoe",
				MaxCount = 1,
				Weight = 4,
				Armor = {
					Piercing = 0.25,
					Cutting = 2,
					Slashing = 1,
					Bludgeoning = 0.25

				}
			},
			["Bronze right shoe"] =
			{
				Type = "Right shoe",
				Desc = "Test right shoe",
				MaxCount = 1,
				Weight = 4,
				Armor = {
					Piercing = 0.25,
					Cutting = 2,
					Slashing = 1,
					Bludgeoning = 0.25
				}

			},
			["Bronze pants"] =
			{
				Type = "Pants",
				Desc = "Test bronze pants",
				MaxCount = 1,
				Weight = 8,
				Armor = {
					Piercing = 1,
					Cutting = 4,
					Slashing = 2,
					Bludgeoning = 1
				}

			},
			["Bronze left glove"] =
			{
				Type = "Left glove",
				Desc = "Test left glove",
				MaxCount = 1,
				Weight = 3,
				Armor = {
					Piercing = 0.25,
					Cutting = 2,
					Slashing = 1,
					Bludgeoning = 0.25
				}

			},
			["Bronze right glove"] =
			{
				Type = "Right glove",
				Desc = "Test right glove",
				MaxCount = 1,
				Weight = 3,
				Armor = {
					Piercing = 0.25,
					Cutting = 2,
					Slashing = 1,
					Bludgeoning = 0.25
				}

			},
			["Demon helmet"] =
			{
				Type = "Helmet",
				Desc = "Ancient helmet",
				MaxCount = 1,
				Weight = 15,
				Armor = {
					Piercing = 4,
					Cutting = 8,
					Slashing = 8,
					Bludgeoning = 4
				}

			},
			["Horned helmet"] =
			{
				Type = "Helmet",
				Desc = "Vikings?",
				MaxCount = 1,
				Weight = 10,
				Armor = {
					Piercing = 3,
					Cutting = 4,
					Slashing = 7,
					Bludgeoning = 5
				}

			},
			["Yorks chessplate"] =
			{
				Type = "Chessplate",
				Desc = "Vikings?",
				MaxCount = 1,
				Weight = 14,
				Armor = {
					Piercing = 4,
					Cutting = 3,
					Slashing = 5,
					Bludgeoning = 3
				}

			},
			["Steel helmet"] =
			{
				Type = "Helmet",
				Desc = "Cool",
				MaxCount = 1,
				Weight = 11,
				Armor = {
					Piercing = 6,
					Cutting = 3,
					Slashing = 2,
					Bludgeoning = 1
				}

			},
			["Dragonscale right glove"] =
			{
				Type = "Right glove",
				Desc = "FOOSRODAH",
				MaxCount = 1,
				Weight = 17,
				Armor = {
					Piercing = 7,
					Cutting = 17,
					Slashing = 7,
					Bludgeoning = 6
				}
			}
		}
	}

function module.GetThing(Name,Type)
	return TableOfAll[Type][Name]
end
return module
