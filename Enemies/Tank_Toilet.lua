--[[
	Tank_Toilet.lua

	Tanky, slow, hard-hitting enemy for Skibidi Toilet game.
	High health enemy that soaks damage.

	Features:
	- Very high health
	- Slow movement
	- High damage per hit
	- Resistant to knockback
	- Spawns individually or in pairs
--]]

local Tank_Toilet = {
	-- Enemy Information
	Name = "Tank Toilet",
	DisplayName = "Tank Toilet",
	Description = "A heavily armored toilet. Slow but incredibly tough and dangerous.",

	-- Enemy Type
	EnemyType = "TANK",

	-- Base Stats
	Stats = {
		MaxHealth = 150, -- Much higher health
		MoveSpeed = 8, -- Very slow
		Damage = 20, -- High damage
		AttackRange = 6, -- Slightly longer reach
		AttackCooldown = 2.5, -- Slower attacks
		DetectionRange = 90, -- Shorter detection range
	},

	-- Rewards
	Rewards = {
		XPDropAmount = 15, -- High XP reward
		XPDropChance = 1.0,
		CoinsDropChance = 0.15, -- 15% chance to drop coins
		CoinsDropAmount = 5, -- More coins
	},

	-- Combat Properties
	Combat = {
		KnockbackResistance = 0.7, -- 70% knockback resistance
		AttackWindup = 0.8, -- Slow, telegraphed attack
		AttackType = "HEAVY_MELEE",
		StatusEffectResistance = 0.5, -- 50% resistance to debuffs
		Armor = 5, -- Reduces damage taken by 5
	},

	-- Visual Settings
	Visual = {
		ModelId = nil,
		PrimaryColor = Color3.fromRGB(80, 80, 80), -- Dark grey
		SecondaryColor = Color3.fromRGB(200, 50, 50), -- Red accents
		Scale = 1.3, -- Much larger than basic
		Size = Vector3.new(6, 7, 3),

		-- Effects
		TrailEnabled = false,
		DeathEffectColor = Color3.fromRGB(200, 50, 50),
		HitEffectColor = Color3.fromRGB(255, 200, 100), -- Sparks
		ArmorEffect = true, -- Visual armor plates
	},

	-- Audio
	Audio = {
		SpawnSound = "rbxassetid://0", -- Heavy stomp
		AttackSound = "rbxassetid://0", -- Heavy slam
		HitSound = "rbxassetid://0", -- Metal clang
		DeathSound = "rbxassetid://0", -- Explosion
		Volume = 0.6,
		Pitch = 0.7, -- Lower pitch
	},

	-- Spawning
	Spawn = {
		Weight = 30, -- Less common
		MinWave = 5, -- Starts appearing from wave 5
		MaxWave = 999,
		GroupSize = {Min = 1, Max = 2}, -- Spawns alone or in pairs
		SpawnAnimation = "Crash", -- Crashes down
	},

	-- Behavior
	Behavior = {
		AggroRange = 90,
		WanderWhenIdle = false,
		PreferredDistance = 0,
		FleeAtHealthPercent = 0, -- Never flees
		EnrageAtHealthPercent = 0.3, -- Enrages below 30% health
	},

	-- Metadata
	Difficulty = "HARD",
	Category = "Tank",
	Tags = {"Tank", "Heavy", "Slow", "Armored"},
}

--[[
	Create enemy configuration for EnemyAI system
--]]
function Tank_Toilet:GetEnemyConfig(waveNumber, difficultyMultiplier)
	waveNumber = waveNumber or 1
	difficultyMultiplier = difficultyMultiplier or 1.0

	-- Tanks scale heavily with health
	local healthScaling = difficultyMultiplier * (1 + (waveNumber * 0.1))

	return {
		Name = self.Name,
		EnemyType = self.EnemyType,

		-- Scaled stats
		MaxHealth = math.floor(self.Stats.MaxHealth * healthScaling),
		MoveSpeed = math.min(12, self.Stats.MoveSpeed + (waveNumber * 0.1)), -- Slow speed scaling, max 12
		Damage = math.floor(self.Stats.Damage * difficultyMultiplier),
		AttackRange = self.Stats.AttackRange,
		AttackCooldown = self.Stats.AttackCooldown,
		DetectionRange = self.Stats.DetectionRange,

		-- Rewards
		XPDropAmount = self.Rewards.XPDropAmount + math.floor(waveNumber * 1.5),
		XPDropChance = self.Rewards.XPDropChance,

		-- Visual
		Color = self.Visual.PrimaryColor,
		Size = self.Visual.Size,

		-- Special properties
		KnockbackResistance = self.Combat.KnockbackResistance,
		CanFly = false,
		AggroRange = self.Behavior.AggroRange,
		Armor = self.Combat.Armor, -- Custom property
	}
end

--[[
	Get spawn weight for this enemy at a given wave
--]]
function Tank_Toilet:GetSpawnWeight(waveNumber)
	if waveNumber < self.Spawn.MinWave or waveNumber > self.Spawn.MaxWave then
		return 0
	end

	local weight = self.Spawn.Weight

	-- Become more common in late game
	if waveNumber >= 10 then
		weight = weight * 1.5 -- 50% more common after wave 10
	end

	if waveNumber >= 20 then
		weight = weight * 2.0 -- Double weight after wave 20
	end

	return weight
end

--[[
	Get random group size for spawning
--]]
function Tank_Toilet:GetGroupSize()
	local min = self.Spawn.GroupSize.Min
	local max = self.Spawn.GroupSize.Max
	return math.random(min, max)
end

--[[
	Called when this enemy is spawned
--]]
function Tank_Toilet:OnSpawn(enemyModel, enemyAI)
	print(string.format("[Tank_Toilet] Spawned at %s", tostring(enemyModel.PrimaryPart.Position)))

	-- Add armor visual effect
	if self.Visual.ArmorEffect and enemyModel.PrimaryPart then
		-- Create armor glow
		local pointLight = Instance.new("PointLight")
		pointLight.Color = self.Visual.SecondaryColor
		pointLight.Brightness = 1
		pointLight.Range = 8
		pointLight.Parent = enemyModel.PrimaryPart
	end

	-- Store enrage state
	enemyAI.IsEnraged = false
end

--[[
	Called when this enemy attacks
--]]
function Tank_Toilet:OnAttack(enemyAI, target)
	local damage = enemyAI.Config.Damage

	-- Enraged tanks do more damage
	if enemyAI.IsEnraged then
		damage = damage * 1.5
		print(string.format("[Tank_Toilet] %s attacking with ENRAGED strike!", self.Name))
	else
		print(string.format("[Tank_Toilet] %s attacking with heavy strike", self.Name))
	end

	-- Heavy attack with high knockback
	return {
		Damage = damage,
		KnockbackForce = 30, -- High knockback
		Type = "HeavyMelee",
		Stun = 0.5, -- Stuns player for 0.5 seconds
	}
end

--[[
	Called when this enemy takes damage
--]]
function Tank_Toilet:OnDamage(enemyAI, damage, damageSource)
	-- Reduce damage by armor
	local actualDamage = math.max(1, damage - self.Combat.Armor)

	-- Check for enrage
	local healthPercent = enemyAI:GetHealthPercent()
	if healthPercent <= self.Behavior.EnrageAtHealthPercent and not enemyAI.IsEnraged then
		enemyAI.IsEnraged = true
		enemyAI.Config.MoveSpeed = enemyAI.Config.MoveSpeed * 1.3 -- 30% faster when enraged

		print(string.format("[Tank_Toilet] %s is now ENRAGED!", self.Name))

		-- Visual effect for enrage
		if enemyAI.Model and enemyAI.Model.PrimaryPart then
			local smoke = Instance.new("Smoke")
			smoke.Color = Color3.fromRGB(100, 0, 0)
			smoke.Opacity = 0.5
			smoke.Size = 5
			smoke.Parent = enemyAI.Model.PrimaryPart
		end
	end

	return actualDamage
end

--[[
	Called when this enemy dies
--]]
function Tank_Toilet:OnDeath(enemyAI, killer)
	print(string.format("[Tank_Toilet] %s died with heavy impact", self.Name))

	-- Tank death causes area damage
	local deathDamage = {
		Radius = 10,
		Damage = 15,
		Type = "DeathExplosion"
	}

	local drops = {
		XP = self.Rewards.XPDropAmount,
		Coins = 0,
		DeathEffect = deathDamage
	}

	if math.random() <= self.Rewards.CoinsDropChance then
		drops.Coins = self.Rewards.CoinsDropAmount
	end

	return drops
end

return Tank_Toilet
