--[[
	DropTables.lua

	Loot drop configuration for Skibidi Toilet game.
	Defines what items enemies can drop and their probabilities.

	Features:
	- XP orb drops
	- Coin drops
	- Power-up drops (future expansion)
	- Weighted random selection
	- Wave-based scaling
--]]

local DropTables = {}

-- ============================================================================
-- XP ORB DROPS
-- ============================================================================

DropTables.XPOrbs = {
	-- Always drop XP orbs on death
	AlwaysDrop = true,

	-- XP amount calculation
	BaseAmount = 5,
	WaveScaling = 0.5, -- +0.5 XP per wave

	-- Visual settings
	OrbColor = Color3.fromRGB(100, 255, 100), -- Green
	OrbSize = 1.5,
	OrbLifetime = 30, -- Despawn after 30 seconds if not collected

	-- Collection
	PickupRange = 2, -- Must be within 2 studs to pick up
	MagnetRange = 15, -- Auto-collect within 15 studs (with magnet)
	CollectionSpeed = 20, -- Speed orbs move toward player (studs/sec)
}

--[[
	Calculate XP drop amount for an enemy
	@param enemyName: string - Name of the enemy
	@param waveNumber: number - Current wave number
	@return number - XP amount
--]]
function DropTables.XPOrbs.CalculateDrop(enemyName, waveNumber)
	local baseXP = DropTables.XPOrbs.BaseAmount
	local waveBonus = math.floor(waveNumber * DropTables.XPOrbs.WaveScaling)

	-- Boss multiplier
	if enemyName == "Boss_Titan" then
		return (baseXP + waveBonus) * 10 -- Bosses give 10x XP
	end

	return baseXP + waveBonus
end

-- ============================================================================
-- COIN DROPS
-- ============================================================================

DropTables.Coins = {
	-- Drop chances by enemy type
	DropChances = {
		["Zombie_Toilet"] = 0.05, -- 5%
		["FastRunner"] = 0.08, -- 8%
		["Tank_Toilet"] = 0.15, -- 15%
		["Ranged_Camera"] = 0.10, -- 10%
		["Boss_Titan"] = 1.0, -- 100%
	},

	-- Coin amounts
	Amounts = {
		["Zombie_Toilet"] = {Min = 1, Max = 2},
		["FastRunner"] = {Min = 2, Max = 3},
		["Tank_Toilet"] = {Min = 5, Max = 8},
		["Ranged_Camera"] = {Min = 3, Max = 5},
		["Boss_Titan"] = {Min = 20, Max = 50},
	},

	-- Visual settings
	CoinColor = Color3.fromRGB(255, 215, 0), -- Gold
	CoinSize = 1.5,
	CoinLifetime = 60, -- Despawn after 60 seconds

	-- Collection
	PickupRange = 3,
	MagnetRange = 15,
	CollectionSpeed = 25,

	-- GamePass bonus
	DoubleCoinsMultiplier = 2.0, -- For players with double coins GamePass
}

--[[
	Check if enemy should drop coins
	@param enemyName: string - Name of the enemy
	@return boolean - Should drop
--]]
function DropTables.Coins.ShouldDrop(enemyName)
	local dropChance = DropTables.Coins.DropChances[enemyName] or 0.05
	return math.random() <= dropChance
end

--[[
	Calculate coin drop amount
	@param enemyName: string - Name of the enemy
	@param hasDoubleCoins: boolean - Player has double coins GamePass
	@return number - Coin amount
--]]
function DropTables.Coins.CalculateDrop(enemyName, hasDoubleCoins)
	local amounts = DropTables.Coins.Amounts[enemyName]

	if not amounts then
		amounts = {Min = 1, Max = 2}
	end

	local coinAmount = math.random(amounts.Min, amounts.Max)

	-- Apply GamePass bonus
	if hasDoubleCoins then
		coinAmount = coinAmount * DropTables.Coins.DoubleCoinsMultiplier
	end

	return math.floor(coinAmount)
end

-- ============================================================================
-- POWER-UP DROPS (Future Expansion)
-- ============================================================================

DropTables.PowerUps = {
	-- Enabled flag
	Enabled = false, -- Not implemented yet

	-- Drop chances
	DropChance = 0.02, -- 2% chance from any enemy

	-- Power-up types
	Types = {
		Health = {
			Name = "Health Pack",
			Effect = "Heal",
			Amount = 25, -- Heal 25 HP
			Duration = 0, -- Instant
			Color = Color3.fromRGB(255, 100, 100),
			Weight = 40, -- 40% of power-up drops
		},

		Speed = {
			Name = "Speed Boost",
			Effect = "SpeedBoost",
			Amount = 1.5, -- 1.5x speed
			Duration = 10, -- 10 seconds
			Color = Color3.fromRGB(100, 255, 255),
			Weight = 25,
		},

		Damage = {
			Name = "Damage Boost",
			Effect = "DamageBoost",
			Amount = 1.5, -- 1.5x damage
			Duration = 10,
			Color = Color3.fromRGB(255, 100, 255),
			Weight = 25,
		},

		Magnet = {
			Name = "Magnet",
			Effect = "Magnet",
			Amount = 1, -- Enable magnet
			Duration = 10,
			Color = Color3.fromRGB(255, 255, 100),
			Weight = 10,
		},
	},

	-- Visual settings
	PowerUpSize = 2.0,
	PowerUpLifetime = 45,
	PickupRange = 3,
}

--[[
	Check if enemy should drop a power-up
	@return boolean - Should drop
--]]
function DropTables.PowerUps.ShouldDrop()
	if not DropTables.PowerUps.Enabled then
		return false
	end

	return math.random() <= DropTables.PowerUps.DropChance
end

--[[
	Get random power-up type (weighted)
	@return table - Power-up data
--]]
function DropTables.PowerUps.GetRandomPowerUp()
	-- Calculate total weight
	local totalWeight = 0
	for _, powerUp in pairs(DropTables.PowerUps.Types) do
		totalWeight = totalWeight + powerUp.Weight
	end

	-- Random selection
	local randomValue = math.random() * totalWeight
	local currentWeight = 0

	for name, powerUp in pairs(DropTables.PowerUps.Types) do
		currentWeight = currentWeight + powerUp.Weight
		if randomValue <= currentWeight then
			return powerUp
		end
	end

	-- Fallback
	return DropTables.PowerUps.Types.Health
end

-- ============================================================================
-- DROP GENERATION
-- ============================================================================

--[[
	Generate all drops for an enemy death
	@param enemyName: string - Name of the enemy
	@param waveNumber: number - Current wave number
	@param playerHasDoubleCoins: boolean - Player has double coins GamePass
	@param position: Vector3 - Enemy death position
	@return table - Array of drop data
--]]
function DropTables.GenerateDrops(enemyName, waveNumber, playerHasDoubleCoins, position)
	local drops = {}

	-- Always drop XP
	if DropTables.XPOrbs.AlwaysDrop then
		local xpAmount = DropTables.XPOrbs.CalculateDrop(enemyName, waveNumber)

		table.insert(drops, {
			Type = "XP",
			Amount = xpAmount,
			Position = position,
			Color = DropTables.XPOrbs.OrbColor,
			Size = DropTables.XPOrbs.OrbSize,
			Lifetime = DropTables.XPOrbs.OrbLifetime,
		})
	end

	-- Check for coin drop
	if DropTables.Coins.ShouldDrop(enemyName) then
		local coinAmount = DropTables.Coins.CalculateDrop(enemyName, playerHasDoubleCoins)

		table.insert(drops, {
			Type = "Coin",
			Amount = coinAmount,
			Position = position + Vector3.new(math.random(-2, 2), 1, math.random(-2, 2)),
			Color = DropTables.Coins.CoinColor,
			Size = DropTables.Coins.CoinSize,
			Lifetime = DropTables.Coins.CoinLifetime,
		})
	end

	-- Check for power-up drop
	if DropTables.PowerUps.ShouldDrop() then
		local powerUp = DropTables.PowerUps.GetRandomPowerUp()

		table.insert(drops, {
			Type = "PowerUp",
			PowerUpType = powerUp.Effect,
			Amount = powerUp.Amount,
			Duration = powerUp.Duration,
			Position = position + Vector3.new(math.random(-3, 3), 2, math.random(-3, 3)),
			Color = powerUp.Color,
			Size = DropTables.PowerUps.PowerUpSize,
			Lifetime = DropTables.PowerUps.PowerUpLifetime,
			Name = powerUp.Name,
		})
	end

	return drops
end

--[[
	Calculate total expected value from drops over time
	@param enemyName: string - Name of the enemy
	@param waveNumber: number - Current wave number
	@param killsPerMinute: number - Expected kills per minute
	@return table - Expected rewards per minute
--]]
function DropTables.CalculateExpectedValue(enemyName, waveNumber, killsPerMinute)
	local dropChance = DropTables.Coins.DropChances[enemyName] or 0.05
	local amounts = DropTables.Coins.Amounts[enemyName] or {Min = 1, Max = 2}
	local avgCoins = (amounts.Min + amounts.Max) / 2

	local xpAmount = DropTables.XPOrbs.CalculateDrop(enemyName, waveNumber)

	return {
		XPPerMinute = xpAmount * killsPerMinute,
		CoinsPerMinute = avgCoins * dropChance * killsPerMinute,
		EnemyName = enemyName,
		Wave = waveNumber,
	}
end

--[[
	Get drop information for UI display
	@param enemyName: string - Name of the enemy
	@return table - Drop info for display
--]]
function DropTables.GetDropInfo(enemyName)
	local dropChance = DropTables.Coins.DropChances[enemyName] or 0.05
	local amounts = DropTables.Coins.Amounts[enemyName] or {Min = 1, Max = 2}

	return {
		EnemyName = enemyName,
		XPDrop = "Always",
		CoinDropChance = string.format("%.1f%%", dropChance * 100),
		CoinAmount = string.format("%d-%d", amounts.Min, amounts.Max),
		PowerUpChance = DropTables.PowerUps.Enabled and
			string.format("%.1f%%", DropTables.PowerUps.DropChance * 100) or "Disabled",
	}
end

return DropTables
