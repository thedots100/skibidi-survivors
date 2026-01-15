--[[
	Zombie_Toilet.lua

	Basic melee enemy for Skibidi Toilet game.
	The most common enemy type - slow but numerous.

	Features:
	- Low health, moderate speed
	- Simple chase and melee attack AI
	- Spawns in large groups
	- Good for early waves
--]]

local Zombie_Toilet = {
	-- Enemy Information
	Name = "Zombie Toilet",
	DisplayName = "Zombie Toilet",
	Description = "A basic infected toilet. Slow but relentless.",

	-- Enemy Type (uses EnemyAI system)
	EnemyType = "MELEE", -- MELEE, RANGED, TANK, FAST

	-- Base Stats
	Stats = {
		MaxHealth = 50,
		MoveSpeed = 12, -- Studs per second
		Damage = 10,
		AttackRange = 5, -- Studs
		AttackCooldown = 1.5, -- Seconds between attacks
		DetectionRange = 100, -- Studs (how far they can detect player)
	},

	-- Rewards
	Rewards = {
		XPDropAmount = 5,
		XPDropChance = 1.0, -- 100% chance to drop XP
		CoinsDropChance = 0.05, -- 5% chance to drop coins
		CoinsDropAmount = 1, -- 1 coin if dropped
	},

	-- Combat Properties
	Combat = {
		KnockbackResistance = 0, -- 0 = full knockback, 1 = no knockback
		AttackWindup = 0.3, -- Seconds before attack lands
		AttackType = "MELEE",
		StatusEffectResistance = 0, -- No resistance to debuffs
	},

	-- Visual Settings
	Visual = {
		ModelId = nil, -- Set to actual model ID
		PrimaryColor = Color3.fromRGB(180, 180, 180), -- Grey
		SecondaryColor = Color3.fromRGB(100, 200, 100), -- Sickly green
		Scale = 1.0,
		Size = Vector3.new(4, 5, 2), -- Width, height, depth

		-- Effects
		TrailEnabled = false,
		DeathEffectColor = Color3.fromRGB(100, 200, 100),
		HitEffectColor = Color3.fromRGB(255, 100, 100),
	},

	-- Audio
	Audio = {
		SpawnSound = "rbxassetid://0",
		AttackSound = "rbxassetid://0",
		HitSound = "rbxassetid://0",
		DeathSound = "rbxassetid://0",
		Volume = 0.4,
	},

	-- Spawning
	Spawn = {
		Weight = 100, -- Higher weight = more common (relative to other enemies)
		MinWave = 1, -- Can spawn starting from wave 1
		MaxWave = 999, -- No max wave
		GroupSize = {Min = 3, Max = 8}, -- Spawns in groups of 3-8
		SpawnAnimation = "Rise", -- Rise from ground
	},

	-- Behavior
	Behavior = {
		AggroRange = 100, -- How far they chase player
		WanderWhenIdle = false, -- Don't wander, just idle
		PreferredDistance = 0, -- Tries to get as close as possible
		FleeAtHealthPercent = 0, -- Never flees
	},

	-- Metadata
	Difficulty = "EASY",
	Category = "Basic",
	Tags = {"Melee", "Common", "Swarm"},
}

--[[
	Create enemy configuration for EnemyAI system
	@param waveNumber: number - Current wave (for scaling)
	@param difficultyMultiplier: number - Difficulty scaling multiplier
	@return table - Configuration for EnemyAI.new()
--]]
function Zombie_Toilet:GetEnemyConfig(waveNumber, difficultyMultiplier)
	waveNumber = waveNumber or 1
	difficultyMultiplier = difficultyMultiplier or 1.0

	-- Scale stats based on wave and difficulty
	return {
		Name = self.Name,
		EnemyType = self.EnemyType,

		-- Scaled stats
		MaxHealth = math.floor(self.Stats.MaxHealth * difficultyMultiplier),
		MoveSpeed = self.Stats.MoveSpeed + (waveNumber * 0.2), -- Slight speed increase per wave
		Damage = math.floor(self.Stats.Damage * difficultyMultiplier),
		AttackRange = self.Stats.AttackRange,
		AttackCooldown = self.Stats.AttackCooldown,
		DetectionRange = self.Stats.DetectionRange,

		-- Rewards
		XPDropAmount = self.Rewards.XPDropAmount + math.floor(waveNumber * 0.5),
		XPDropChance = self.Rewards.XPDropChance,

		-- Visual
		Color = self.Visual.PrimaryColor,
		Size = self.Visual.Size,

		-- Special properties
		KnockbackResistance = self.Combat.KnockbackResistance,
		CanFly = false,
		AggroRange = self.Behavior.AggroRange,
	}
end

--[[
	Get spawn weight for this enemy at a given wave
	@param waveNumber: number - Current wave number
	@return number - Spawn weight (0 = don't spawn)
--]]
function Zombie_Toilet:GetSpawnWeight(waveNumber)
	-- Check if this enemy can spawn on this wave
	if waveNumber < self.Spawn.MinWave or waveNumber > self.Spawn.MaxWave then
		return 0
	end

	-- Reduce spawn weight in later waves (becomes less common)
	local weight = self.Spawn.Weight

	if waveNumber > 10 then
		weight = weight * 0.7 -- 30% less common after wave 10
	end

	if waveNumber > 20 then
		weight = weight * 0.5 -- 50% less common after wave 20
	end

	return weight
end

--[[
	Get random group size for spawning
	@return number - Number of enemies to spawn in this group
--]]
function Zombie_Toilet:GetGroupSize()
	local min = self.Spawn.GroupSize.Min
	local max = self.Spawn.GroupSize.Max
	return math.random(min, max)
end

--[[
	Called when this enemy is spawned
	@param enemyModel: Model - The spawned enemy model
	@param enemyAI: EnemyAI - The AI controller instance
--]]
function Zombie_Toilet:OnSpawn(enemyModel, enemyAI)
	print(string.format("[Zombie_Toilet] Spawned at %s", tostring(enemyModel.PrimaryPart.Position)))

	-- Could add spawn effects, sounds, etc. here
end

--[[
	Called when this enemy attacks
	@param enemyAI: EnemyAI - The AI controller instance
	@param target: Model - The target being attacked
--]]
function Zombie_Toilet:OnAttack(enemyAI, target)
	-- Play attack animation/sound
	print(string.format("[Zombie_Toilet] %s attacking target", self.Name))

	-- Simple melee attack - damage is handled by combat system
	return {
		Damage = enemyAI.Config.Damage,
		KnockbackForce = 10,
		Type = "Melee"
	}
end

--[[
	Called when this enemy takes damage
	@param enemyAI: EnemyAI - The AI controller instance
	@param damage: number - Damage taken
	@param damageSource: any - Source of damage
--]]
function Zombie_Toilet:OnDamage(enemyAI, damage, damageSource)
	-- Could add hit effects, sounds, etc. here
	-- Simple enemies don't have special damage reactions
end

--[[
	Called when this enemy dies
	@param enemyAI: EnemyAI - The AI controller instance
	@param killer: any - What killed this enemy
	@return table - Loot drops
--]]
function Zombie_Toilet:OnDeath(enemyAI, killer)
	print(string.format("[Zombie_Toilet] %s died", self.Name))

	-- Determine loot drops
	local drops = {
		XP = self.Rewards.XPDropAmount,
		Coins = 0
	}

	-- Chance to drop coins
	if math.random() <= self.Rewards.CoinsDropChance then
		drops.Coins = self.Rewards.CoinsDropAmount
	end

	return drops
end

return Zombie_Toilet
