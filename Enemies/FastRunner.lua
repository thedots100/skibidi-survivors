--[[
	FastRunner.lua

	Fast but fragile enemy for Skibidi Toilet game.
	Quick rushers that close distance rapidly.

	Features:
	- Low health, very high speed
	- Quick attacks
	- Hard to hit but easy to kill
	- Spawns in medium-sized groups
--]]

local FastRunner = {
	-- Enemy Information
	Name = "Fast Runner",
	DisplayName = "Fast Runner",
	Description = "A speedy enemy that rushes at the player. Fast but fragile.",

	-- Enemy Type
	EnemyType = "FAST",

	-- Base Stats
	Stats = {
		MaxHealth = 30, -- Much lower health
		MoveSpeed = 20, -- Very fast
		Damage = 8, -- Lower damage
		AttackRange = 4, -- Slightly shorter range
		AttackCooldown = 1.0, -- Faster attacks
		DetectionRange = 120, -- Detects player from farther away
	},

	-- Rewards
	Rewards = {
		XPDropAmount = 8, -- More XP since they're harder to hit
		XPDropChance = 1.0,
		CoinsDropChance = 0.08, -- 8% chance to drop coins
		CoinsDropAmount = 2,
	},

	-- Combat Properties
	Combat = {
		KnockbackResistance = 0, -- Full knockback (lightweight)
		AttackWindup = 0.1, -- Very fast attack
		AttackType = "MELEE",
		StatusEffectResistance = 0.2, -- 20% resistance to slows
	},

	-- Visual Settings
	Visual = {
		ModelId = nil,
		PrimaryColor = Color3.fromRGB(255, 150, 50), -- Orange
		SecondaryColor = Color3.fromRGB(255, 220, 0), -- Yellow
		Scale = 0.85, -- Smaller than basic
		Size = Vector3.new(3, 4.5, 1.5),

		-- Effects
		TrailEnabled = true,
		TrailColor = Color3.fromRGB(255, 200, 50),
		DeathEffectColor = Color3.fromRGB(255, 150, 50),
		HitEffectColor = Color3.fromRGB(255, 100, 100),
	},

	-- Audio
	Audio = {
		SpawnSound = "rbxassetid://0",
		AttackSound = "rbxassetid://0",
		HitSound = "rbxassetid://0",
		DeathSound = "rbxassetid://0",
		Volume = 0.3,
		Pitch = 1.3, -- Higher pitch for fast enemy
	},

	-- Spawning
	Spawn = {
		Weight = 60, -- Less common than basic
		MinWave = 3, -- Starts appearing from wave 3
		MaxWave = 999,
		GroupSize = {Min = 2, Max = 5}, -- Spawns in smaller groups
		SpawnAnimation = "Dash", -- Dashes in
	},

	-- Behavior
	Behavior = {
		AggroRange = 120,
		WanderWhenIdle = true, -- Moves around when idle
		PreferredDistance = 0, -- Gets as close as possible
		FleeAtHealthPercent = 0,
		DodgeChance = 0.15, -- 15% chance to dodge attacks
	},

	-- Metadata
	Difficulty = "MEDIUM",
	Category = "Speed",
	Tags = {"Fast", "Melee", "Rush"},
}

--[[
	Create enemy configuration for EnemyAI system
--]]
function FastRunner:GetEnemyConfig(waveNumber, difficultyMultiplier)
	waveNumber = waveNumber or 1
	difficultyMultiplier = difficultyMultiplier or 1.0

	return {
		Name = self.Name,
		EnemyType = self.EnemyType,

		-- Scaled stats
		MaxHealth = math.floor(self.Stats.MaxHealth * difficultyMultiplier),
		MoveSpeed = self.Stats.MoveSpeed + (waveNumber * 0.3), -- Scales faster with waves
		Damage = math.floor(self.Stats.Damage * difficultyMultiplier),
		AttackRange = self.Stats.AttackRange,
		AttackCooldown = math.max(0.5, self.Stats.AttackCooldown - (waveNumber * 0.02)), -- Faster over time
		DetectionRange = self.Stats.DetectionRange,

		-- Rewards
		XPDropAmount = self.Rewards.XPDropAmount + math.floor(waveNumber * 0.8),
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
--]]
function FastRunner:GetSpawnWeight(waveNumber)
	if waveNumber < self.Spawn.MinWave or waveNumber > self.Spawn.MaxWave then
		return 0
	end

	local weight = self.Spawn.Weight

	-- Become more common in mid-game
	if waveNumber >= 5 and waveNumber <= 15 then
		weight = weight * 1.3 -- 30% more common in waves 5-15
	end

	return weight
end

--[[
	Get random group size for spawning
--]]
function FastRunner:GetGroupSize()
	local min = self.Spawn.GroupSize.Min
	local max = self.Spawn.GroupSize.Max
	return math.random(min, max)
end

--[[
	Called when this enemy is spawned
--]]
function FastRunner:OnSpawn(enemyModel, enemyAI)
	print(string.format("[FastRunner] Spawned at %s", tostring(enemyModel.PrimaryPart.Position)))

	-- Add speed trail effect
	if self.Visual.TrailEnabled then
		local attachment0 = Instance.new("Attachment")
		attachment0.Parent = enemyModel.PrimaryPart

		local trail = Instance.new("Trail")
		trail.Attachment0 = attachment0
		trail.Attachment1 = attachment0
		trail.Color = ColorSequence.new(self.Visual.TrailColor)
		trail.Lifetime = 0.3
		trail.MinLength = 0
		trail.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.5),
			NumberSequenceKeypoint.new(1, 1)
		})
		trail.Parent = enemyModel.PrimaryPart
	end
end

--[[
	Called when this enemy attacks
--]]
function FastRunner:OnAttack(enemyAI, target)
	print(string.format("[FastRunner] %s attacking with quick strike", self.Name))

	-- Fast enemies do rapid strikes
	return {
		Damage = enemyAI.Config.Damage,
		KnockbackForce = 5, -- Low knockback
		Type = "Melee",
		AttackSpeed = "Fast"
	}
end

--[[
	Called when this enemy takes damage
--]]
function FastRunner:OnDamage(enemyAI, damage, damageSource)
	-- Chance to dodge (move quickly in random direction)
	if math.random() <= self.Behavior.DodgeChance then
		print(string.format("[FastRunner] Dodged attack!"))

		-- Apply quick dodge movement
		if enemyAI.HumanoidRootPart then
			local dodgeDirection = Vector3.new(
				math.random(-1, 1),
				0,
				math.random(-1, 1)
			).Unit

			enemyAI:ApplyKnockback(dodgeDirection, 30)
		end
	end
end

--[[
	Called when this enemy dies
--]]
function FastRunner:OnDeath(enemyAI, killer)
	print(string.format("[FastRunner] %s died", self.Name))

	local drops = {
		XP = self.Rewards.XPDropAmount,
		Coins = 0
	}

	if math.random() <= self.Rewards.CoinsDropChance then
		drops.Coins = self.Rewards.CoinsDropAmount
	end

	return drops
end

return FastRunner
