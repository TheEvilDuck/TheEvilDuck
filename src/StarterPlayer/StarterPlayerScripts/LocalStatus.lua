local module = {}
local TableOfLoot = {}

function module.AddToLootTable(Model,Name,Type,Count,Type2)
	local Thing = {}
	Thing.Model = Model
	Thing.Name = Name
	Thing.Type = Type
	Thing.Type2 = Type2
	Thing.Count = Count
	table.insert(TableOfLoot,Thing)
end

function module.RemoveFromLootTable(Model)
	table.remove(TableOfLoot,1)
end

function module.GetLoot()
	if #TableOfLoot>0 then
		return TableOfLoot[1]
	end
	return nil
end

module.BattleMode = false
module.TwoHanded = false
module.Rolling = false
module.Running = false
module.Jumping = false
module.FreeFalling = false
module.Attacking = false
module.Shifting = false
module.RunningWithShift = false
module.AfterRollAttack = false
module.Swinging = false

module.ComboTimerMax = 10
module.ComboTimer = 0


function module.ChangeBattleMode()
	module.BattleMode = not module.BattleMode
	game.ReplicatedStorage.Events.BattleModeChanged:Fire(module.BattleMode)
	--game.ReplicatedStorage.Events.MouseLockForBattleMod:Fire(module.BattleMode)
	game.ReplicatedStorage.Events.BattleModeServerUpdate:FireServer(module.BattleMode)
	if not module.BattleMode then
		if module.TwoHanded then
			module.TwoHanded = false
			game.ReplicatedStorage.Events.TwoHandedChanged:Fire(false)
		end
	end
end

function module.ChangeTwoHanded()
	if module.BattleMode then
		module.TwoHanded = game.ReplicatedStorage.Events.TwoHanded:InvokeServer(module.TwoHanded)
		game.ReplicatedStorage.Events.TwoHandedChanged:Fire(true)
	end	
end

local MoveVector = Vector3.new(0,0,0)


function module.SetMoveVector(VectorValue)
	MoveVector = VectorValue
end

function module.GetMoveVector()
	return MoveVector
end

function module.ShakeCamera(Force)
	coroutine.resume(coroutine.create(function()
		local Camera = game.Workspace.CurrentCamera
		local View = Camera.FieldOfView
		local T = Force
		while T>0 do
			T-=Force*0.6
			Camera.FieldOfView = View+T
			game.Lighting.Blur.Size = T*3
			wait()
			T+=Force*0.2
			Camera.FieldOfView = View-T
			game.Lighting.Blur.Size = T*3
			wait()
		end
		Camera.FieldOfView = View
		game.Lighting.Blur.Size = 0
	end))
end

return module
