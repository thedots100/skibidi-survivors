--[[
	Ranged_Camera.lua

	Ranged enemy that shoots projectiles from a distance.
	Forces players to be aggressive or dodge projectiles.

	Features:
	- Moderate health
	- Shoots projectiles from range
	- Tries to maintain distance from player
	- Spawns in small groups
--]]

local Ranged_Camera = {
	-- Enemy Information
	Name = "Ranged Camera",
	DisplayName = "Ranged Camera",
	Description = "A camera unit that shoots flash projectiles from a distance. Keep moving!",

	-- Enemy Type
	EnemyType = "RANGED",

	-- Base Stats
	Stats = {
		MaxHealth = 40,
		MoveSpeed = 10, -- Moderate speed
		Damage = 12, -- Projectile damage
		AttackRange = 30, -- Long range
		AttackCooldown = 2.0, -- Time between shots
		DetectionRange = 100,
	},

	-- Projectile Properties
	Projectile = {
		Speed = 40, -- Studs per second
		Size = 2, -- Projectile size
		Color = Color3.fromRGB(255, 255, 200), -- Yellowish flash
		Lifetime = 2.0, -- Seconds before despawn
		HomingStrength = 0.2, -- Slight homing
		PierceCount = 0, -- Doesn't pierce
	},

	-- Rewards
	Rewards = {
		XPDropAmount = 10,
		XPDropChance = 1.0,
		CoinsDropChance = 0.10, -- 10% chance
		CoinsDropAmount = 3,
	},

	-- Combat Properties
	Combat = {
		KnockbackResistance = 0.3, -- Some resistance
		AttackWindup = 0.5, -- Time to charge shot
		AttackType = "RANGED_PROJECTILE",
		StatusEffectResistance = 0,
		PreferredDistance = 20, -- Tries to stay 20 studs away
	},

	-- Visual Settings
	Visual = {
		ModelId = nil,
		PrimaryColor = Color3.fromRGB(100, 100, 100), -- Grey
		SecondaryColor = Color3.fromRGB(200, 200, 255), -- Light blue (lens)
		Scale = 1.0,
		Size = Vector3.new(3.5, 5, 2),

		-- Effects
		TrailEnabled = false,
		DeathEffectColor = Color3.fromRGB(200, 200, 255),
		HitEffectColor = Color3.fromRGB(255, 100, 100),
		ChargeEffect = true, -- Shows charging before firing
	},

	-- Audio
	Audio = {
		SpawnSound = "rbxassetid://0",
		AttackSound = "rbxassetid://0", -- Laser/camera sound
		HitSound = "rbxassetid://0",
		DeathSound = "rbxassetid://0",
		Volume = 0.4,
		Pitch = 1.2,
	},

	-- Spawning
	Spawn = {
		Weight = 50,
		MinWave = 4, -- Starts appearing from wave 4
		MaxWave = 999,
		GroupSize = {Min = 2, Max = 4}, -- Small groups
		SpawnAnimation = "Teleport",
	},

	-- Behavior
	Behavior = {
		AggroRange = 100,
		WanderWhenIdle = true,
		PreferredDistance = 20, -- Kites player
		FleeAtHealthPercent = 0.2, -- Flees below 20% health
		KitingBehavior = true, -- Moves away when player gets close
	},

	-- Metadata
	Difficulty = "MEDIUM",
	Category = "Ranged",
	Tags = {"Ranged", "Projectile", "Kiting"},
}

--[[
	Create enemy configuration for EnemyAI system
--]]
function Ranged_Camera:GetEnemyConfig(waveNumber, difficultyMultiplier)
	waveNumber = waveNumber or 1
	difficultyMultiplier = difficultyMultiplier or 1.0

	return {
		Name = self.Name,
		EnemyType = self.EnemyType,

		-- Scaled stats
		MaxHealth = math.floor(self.Stats.MaxHealth * difficultyMultiplier),
		MoveSpeed = self.Stats.MoveSpeed + (waveNumber * 0.15),
		Damage = math.floor(self.Stats.Damage * difficultyMultiplier),
		AttackRange = self.Stats.AttackRange,
		AttackCooldown = math.max(1.0, self.Stats.AttackCooldown - (waveNumber * 0.02)), -- Faster shooting
		DetectionRange = self.Stats.DetectionRange,

		-- Rewards
		XPDropAmount = self.Rewards.XPDropAmount + math.floor(waveNumber),
		XPDropChance = self.Rewards.XPDropChance,

		-- Visual
		Color = self.Visual.PrimaryColor,
		Size = self.Visual.Size,

		-- Special properties
		KnockbackResistance = self.Combat.KnockbackResistance,
		CanFly = false,
		AggroRange = self.Behavior.AggroRange,

		-- Custom properties for ranged behavior
		PreferredDistance = self.Combat.PreferredDistance,
		ProjectileSpeed = self.Projectile.Speed,
		ProjectileSize = self.Projectile.Size,
		ProjectileColor = self.Projectile.Color,
	}
end

--[[
	Get spawn weight for this enemy at a given wave
--]]
function Ranged_Camera:GetSpawnWeight(waveNumber)
	if waveNumber < self.Spawn.MinWave or waveNumber > self.Spawn.MaxWave then
		return 0
	end

	local weight = self.Spawn.Weight

	-- More common in mid-late game
	if waveNumber >= 8 then
		weight = weight * 1.4 -- 40% more common
	end

	return weight
end

--[[
	Get random group size for spawning
--]]
function Ranged_Camera:GetGroupSize()
	local min = self.Spawn.GroupSize.Min
	local max = self.Spawn.GroupSize.Max
	return math.random(min, max)
end

--[[
	Called when this enemy is spawned
--]]
function Ranged_Camera:OnSpawn(enemyModel, enemyAI)
	print(string.format("[Ranged_Camera] Spawned at %s", tostring(enemyModel.PrimaryPart.Position)))

	-- Add lens glow effect
	if enemyModel.PrimaryPart then
		local lens = Instance.new("Part")
		lens.Name = "CameraLens"
		lens.Shape = Enum.PartType.Ball
		lens.Size = Vector3.new(1, 1, 1)
		lens.Material = Enum.Material.Neon
		lens.Color = self.Visual.SecondaryColor
		lens.CanCollide = false
		lens.CFrame = enemyModel.PrimaryPart.CFrame * CFrame.new(0, 2, -1)
		lens.Parent = enemyModel

		-- Weld to main part
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = lens
		weld.Part1 = enemyModel.PrimaryPart
		weld.Parent = lens
	end
end

--[[
	Called when this enemy attacks
--]]
function Ranged_Camera:OnAttack(enemyAI, target)
	print(string.format("[Ranged_Camera] %s firing projectile", self.Name))

	-- Get target position
	local targetPos = nil
	if target:IsA("Player") and target.Character then
		local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
		if targetRoot then
			targetPos = targetRoot.Position
		end
	elseif target:IsA("Model") then
		local targetRoot = target:FindFirstChild("HumanoidRootPart")
		if targetRoot then
			targetPos = targetRoot.Position
		end
	end

	if not targetPos or not enemyAI.HumanoidRootPart then
		return nil
	end

	-- Calculate direction with prediction
	local direction = (targetPos - enemyAI.HumanoidRootPart.Position).Unit
	local distance = (targetPos - enemyAI.HumanoidRootPart.Position).Magnitude

	-- Create projectile data
	local projectileData = {
		Type = "EnemyProjectile",
		StartPosition = enemyAI.HumanoidRootPart.Position + direction * 2 + Vector3.new(0, 2, 0),
		Direction = direction,
		Speed = self.Projectile.Speed,
		Damage = enemyAI.Config.Damage,
		Size = self.Projectile.Size,
		Color = self.Projectile.Color,
		Lifetime = self.Projectile.Lifetime,
		HomingStrength = self.Projectile.HomingStrength,
		PierceCount = self.Projectile.PierceCount,
		Owner = enemyAI,
		Target = target,
	}

	return projectileData
end

--[[
	Update enemy behavior (kiting logic)
--]]
function Ranged_Camera:UpdateBehavior(enemyAI, target, deltaTime)
	if not self.Behavior.KitingBehavior then
		return
	end

	-- Check distance to target
	local distance = enemyAI:GetDistanceToTarget()
	if not distance then
		return
	end

	-- If too close, move away
	if distance < self.Combat.PreferredDistance then
		local directionAway = -enemyAI:GetDirectionToTarget()
		enemyAI:MoveInDirection(directionAway, deltaTime)
	end
	-- If too far, move closer (but not too close)
	elseif distance > (self.Combat.PreferredDistance + 10) then
		local directionToward = enemyAI:GetDirectionToTarget()
		enemyAI:MoveInDirection(directionToward, deltaTime)
	end
end

--[[
	Called when this enemy takes damage
--]]
function Ranged_Camera:OnDamage(enemyAI, damage, damageSource)
	-- Check if should flee
	local healthPercent = enemyAI:GetHealthPercent()
	if healthPercent <= self.Behavior.FleeAtHealthPercent then
		-- Set flee behavior (increase preferred distance)
		self.Combat.PreferredDistance = 40
		print(string.format("[Ranged_Camera] %s is fleeing!", self.Name))
	end
end

--[[
	Called when this enemy dies
--]]
function Ranged_Camera:OnDeath(enemyAI, killer)
	print(string.format("[Ranged_Camera] %s destroyed", self.Name))

	local drops = {
		XP = self.Rewards.XPDropAmount,
		Coins = 0
	}

	if math.random() <= self.Rewards.CoinsDropChance then
		drops.Coins = self.Rewards.CoinsDropAmount
	end

	return drops
end

return Ranged_Camera
