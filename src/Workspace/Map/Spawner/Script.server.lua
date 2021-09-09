local Module = require(game.ServerScriptService.Spawners)
local Mobs = 
	{ 
		{
			Name = "Bandit",
			Chance = 1,
			HP = 555,
			HPDiff = 34,
			DistanceToAttack = 6.5,
			CD = 1,
			AttackTime = 0.5,
			ViewRadius = 30,
			Exp = 333,
			Speed = 16,
			Weapons = {
				{
					Name = "BanditSword",
					Chance = 0.6,
					Damage = 1
				},
				{
					Name = "BanditSword2",
					Chance = 0.4,
					Damage = 2
				}
			},
			LootTable = {
				{
					Name = "Broken sword",
					Type = "Weapon",
					Chance = 1
				}
			}
		}
	}

Module.Spawner(script.Parent,1,Mobs)