--[[
	BalanceData.lua

	Game balance configuration for Skibidi Toilet game.
	Centralizes all balance-related constants and formulas.

	Features:
	- Wave scaling parameters
	- XP and leveling formulas
	- Drop rates
	- Damage calculations
	- Game duration tuning

	Target: 15-20 minute gameplay sessions
--]]

local BalanceData = {}

-- ============================================================================
-- WAVE SCALING
-- ============================================================================

BalanceData.Waves = {
	-- Base enemy count per wave
	BaseEnemyCount = 10,

	-- Enemy count multiplier per wave (exponential scaling)
	EnemyScalingRate = 1.3, -- 30% more enemies each wave

	-- Difficulty multiplier (affects enemy HP, damage)
	BaseDifficulty = 1.0,
	DifficultyIncrement = 0.15, -- 15% harder each wave

	-- Wave timing
	WaveBreakDuration = 10, -- Seconds between waves
	FirstWaveDelay = 3, -- Seconds before first wave starts

	-- Boss waves
	BossWaveInterval = 5, -- Boss every 5 waves
	BossWarningTime = 5, -- Warning before boss spawns

	-- Target waves for session length (15-20 minutes)
	-- At 30-60 seconds per wave + 10s break = ~40-70s per wave
	-- 15 min = ~13-22 waves, 20 min = ~17-30 waves
	TargetWavesEasy = 15,
	TargetWavesMedium = 20,
	TargetWavesHard = 25,
}

-- ============================================================================
-- EXPERIENCE AND LEVELING
-- ============================================================================

BalanceData.Experience = {
	-- XP required for next level (formula: baseXP * (level ^ exponent))
	BaseXPForLevel = 100,
	LevelExponent = 1.5,

	-- XP gain multipliers
	BaseXPMultiplier = 1.0,
	BossXPMultiplier = 2.0, -- Bosses give 2x XP

	-- Level cap
	MaxLevel = 50,

	-- XP from enemies (scaled by wave)
	EnemyXPBase = 5,
	WaveXPBonus = 0.5, -- +0.5 XP per wave number

	-- Level rewards
	CoinsPerLevel = 10, -- Coins awarded on level up
	HealthPerLevel = 5, -- Max HP increase per level
}

--[[
	Calculate XP required for a level
	@param level: number - Target level
	@return number - XP required
--]]
function BalanceData.Experience.GetXPForLevel(level)
	if level >= BalanceData.Experience.MaxLevel then
		return math.huge -- Max level
	end

	return math.floor(
		BalanceData.Experience.BaseXPForLevel *
		(level ^ BalanceData.Experience.LevelExponent)
	)
end

--[[
	Calculate total XP needed to reach a level from level 1
	@param targetLevel: number - Target level
	@return number - Total XP needed
--]]
function BalanceData.Experience.GetTotalXPForLevel(targetLevel)
	local totalXP = 0
	for level = 1, targetLevel - 1 do
		totalXP = totalXP + BalanceData.Experience.GetXPForLevel(level)
	end
	return totalXP
end

-- ============================================================================
-- DROP RATES
-- ============================================================================

BalanceData.Drops = {
	-- XP Orb drops
	XPOrbDropChance = 1.0, -- 100% (always drop)
	XPOrbPickupRange = 10, -- Studs

	-- Coin drops
	CoinDropChance = {
		Basic = 0.05, -- 5% for basic enemies
		Fast = 0.08, -- 8% for fast enemies
		Tank = 0.15, -- 15% for tanks
		Ranged = 0.10, -- 10% for ranged
		Boss = 1.0, -- 100% for bosses
	},

	CoinAmount = {
		Basic = 1,
		Fast = 2,
		Tank = 5,
		Ranged = 3,
		Boss = {Min = 20, Max = 50},
	},

	-- Magnet effect (auto-collect XP orbs)
	MagnetRange = 15, -- Studs
	MagnetDuration = 10, -- Seconds (if pickup item)
}

-- ============================================================================
-- DAMAGE CALCULATIONS
-- ============================================================================

BalanceData.Combat = {
	-- Critical hit
	BaseCritChance = 0.05, -- 5% base crit chance
	BaseCritMultiplier = 2.0, -- 2x damage on crit

	-- Knockback
	BaseKnockbackForce = 10,
	KnockbackDecay = 0.9, -- Velocity decay per frame

	-- Invincibility frames
	PlayerHitInvincibilityTime = 0.5, -- Seconds of invincibility after taking damage
	EnemyHitInvincibilityTime = 0.1, -- Brief invincibility to prevent multi-hits

	-- Damage scaling
	PlayerDamageScaling = 1.0, -- Overall player damage multiplier
	EnemyDamageScaling = 1.0, -- Overall enemy damage multiplier

	-- Armor calculation
	ArmorReductionFormula = function(damage, armor)
		-- Flat reduction
		return math.max(1, damage - armor)
	end,

	-- Lifesteal
	LifestealEffectiveness = 1.0, -- 100% of stated lifesteal works
}

-- ============================================================================
-- UPGRADE COSTS
-- ============================================================================

BalanceData.Upgrades = {
	-- Weapon upgrade costs (coins)
	WeaponUpgradeCost = function(currentLevel)
		return math.floor(100 * (currentLevel ^ 1.5))
	end,

	-- Character unlock costs
	CharacterUnlockCosts = {
		Cameraman = 500,
		Speakerman = 1000,
	},

	-- Stat upgrade costs (permanent upgrades)
	StatUpgradeCost = function(currentLevel)
		return math.floor(50 * (currentLevel ^ 1.6))
	end,

	-- Max upgrade levels
	MaxWeaponLevel = 5,
	MaxStatUpgradeLevel = 10,
}

-- ============================================================================
-- PLAYER STATS
-- ============================================================================

BalanceData.Player = {
	-- Starting stats (before character bonuses)
	BaseMaxHealth = 100,
	BaseMoveSpeed = 16,
	BasePickupRange = 10,

	-- Regeneration
	HealthRegenPerSecond = 0, -- No base regen
	HealthRegenDelay = 5, -- Seconds without damage before regen starts

	-- Revival
	ReviveEnabled = false, -- No revives in base game
	RevivesPerGame = 0,
}

-- ============================================================================
-- ECONOMY
-- ============================================================================

BalanceData.Economy = {
	-- Starting resources
	StartingCoins = 0,

	-- Coin gain
	CoinsPerWave = 5, -- Bonus coins for completing a wave
	CoinsPerBoss = 25, -- Bonus coins for defeating a boss

	-- Daily rewards
	DailyLoginCoins = 50,

	-- GamePass bonuses
	GamePassBonuses = {
		DoubleCo ins = 2.0, -- 2x coins from all sources
		ExtraXP = 1.5, -- 1.5x XP from all sources
	},
}

-- ============================================================================
-- GAME DURATION TUNING
-- ============================================================================

BalanceData.Duration = {
	-- Target session length: 15-20 minutes
	TargetMinutes = {Min = 15, Max = 20},

	-- Difficulty curve
	-- Easy start (waves 1-5): 30-45 seconds per wave
	-- Medium (waves 6-15): 45-60 seconds per wave
	-- Hard (waves 16+): 60-90 seconds per wave

	-- Wave duration estimates
	AverageWaveDuration = {
		Early = 40, -- Seconds (waves 1-5)
		Mid = 55, -- Seconds (waves 6-15)
		Late = 75, -- Seconds (waves 16+)
	},

	-- Break time between waves
	BreakDuration = 10, -- Seconds

	-- Calculated max waves for 20 minute session
	-- Early: 5 waves * 40s = 200s
	-- Mid: 10 waves * 55s = 550s
	-- Late: 5 waves * 75s = 375s
	-- Breaks: 19 * 10s = 190s
	-- Total: ~1315s = ~22 minutes
	RecommendedMaxWaves = 20,
}

-- ============================================================================
-- DIFFICULTY PRESETS
-- ============================================================================

BalanceData.DifficultyPresets = {
	Easy = {
		EnemyHealthMultiplier = 0.8,
		EnemyDamageMultiplier = 0.7,
		EnemySpeedMultiplier = 0.9,
		XPMultiplier = 1.2,
		CoinMultiplier = 1.2,
	},

	Normal = {
		EnemyHealthMultiplier = 1.0,
		EnemyDamageMultiplier = 1.0,
		EnemySpeedMultiplier = 1.0,
		XPMultiplier = 1.0,
		CoinMultiplier = 1.0,
	},

	Hard = {
		EnemyHealthMultiplier = 1.3,
		EnemyDamageMultiplier = 1.2,
		EnemySpeedMultiplier = 1.1,
		XPMultiplier = 1.5,
		CoinMultiplier = 1.5,
	},

	Nightmare = {
		EnemyHealthMultiplier = 1.8,
		EnemyDamageMultiplier = 1.5,
		EnemySpeedMultiplier = 1.2,
		XPMultiplier = 2.0,
		CoinMultiplier = 2.0,
	},
}

-- ============================================================================
-- BALANCE TESTING TOOLS
-- ============================================================================

--[[
	Calculate expected damage per second for a weapon
	@param damage: number - Base damage
	@param fireRate: number - Attacks per second
	@param critChance: number - Critical hit chance (0-1)
	@param critMultiplier: number - Critical hit multiplier
	@return number - Average DPS
--]]
function BalanceData.CalculateDPS(damage, fireRate, critChance, critMultiplier)
	critChance = critChance or 0.05
	critMultiplier = critMultiplier or 2.0

	local avgDamage = damage * (1 + (critChance * (critMultiplier - 1)))
	return avgDamage * fireRate
end

--[[
	Calculate time to kill an enemy
	@param enemyHealth: number - Enemy max health
	@param playerDPS: number - Player damage per second
	@return number - Seconds to kill
--]]
function BalanceData.CalculateTTK(enemyHealth, playerDPS)
	return enemyHealth / playerDPS
end

--[[
	Calculate wave difficulty score
	@param waveNumber: number - Wave number
	@return number - Difficulty score (higher = harder)
--]]
function BalanceData.GetWaveDifficulty(waveNumber)
	local enemyCount = math.floor(
		BalanceData.Waves.BaseEnemyCount *
		(BalanceData.Waves.EnemyScalingRate ^ (waveNumber - 1))
	)

	local difficultyMult = BalanceData.Waves.BaseDifficulty +
		(BalanceData.Waves.DifficultyIncrement * (waveNumber - 1))

	return enemyCount * difficultyMult
end

return BalanceData
