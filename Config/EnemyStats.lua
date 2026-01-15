--[[
	EnemyStats.lua

	Central configuration for all enemy stats in Skibidi Toilet game.
	Manages enemy spawning, scaling, and stat calculations.

	Usage:
		local EnemyStats = require(game.ReplicatedStorage.EnemyStats)
		local enemy = EnemyStats.GetEnemy("Zombie_Toilet")
		local config = EnemyStats.GetScaledConfig("Tank_Toilet", 10, 1.5)
--]]

local EnemyStats = {}

-- Import enemy modules
local Enemies = script.Parent.Parent.Enemies
local Zombie_Toilet = require(Enemies.Zombie_Toilet)
local FastRunner = require(Enemies.FastRunner)
local Tank_Toilet = require(Enemies.Tank_Toilet)
local Ranged_Camera = require(Enemies.Ranged_Camera)
local Boss_Titan = require(Enemies.Boss_Titan)

-- Enemy registry
EnemyStats.Enemies = {
	["Zombie_Toilet"] = Zombie_Toilet,
	["FastRunner"] = FastRunner,
	["Tank_Toilet"] = Tank_Toilet,
	["Ranged_Camera"] = Ranged_Camera,
	["Boss_Titan"] = Boss_Titan,
}

-- Enemy spawn list (for normal waves)
EnemyStats.SpawnableEnemies = {
	"Zombie_Toilet",
	"FastRunner",
	"Tank_Toilet",
	"Ranged_Camera",
}

-- Boss enemy list
EnemyStats.BossEnemies = {
	"Boss_Titan",
}

--[[
	Get an enemy by name
	@param enemyName: string - Name of the enemy
	@return table or nil - Enemy data
--]]
function EnemyStats.GetEnemy(enemyName)
	return EnemyStats.Enemies[enemyName]
end

--[[
	Get all spawnable enemies for a wave
	@param waveNumber: number - Current wave number
	@return table - Array of enemy names that can spawn
--]]
function EnemyStats.GetSpawnableForWave(waveNumber)
	local spawnable = {}

	for _, enemyName in ipairs(EnemyStats.SpawnableEnemies) do
		local enemy = EnemyStats.GetEnemy(enemyName)

		-- Check if enemy can spawn this wave
		if enemy and enemy:GetSpawnWeight(waveNumber) > 0 then
			table.insert(spawnable, enemyName)
		end
	end

	return spawnable
end

--[[
	Get scaled enemy configuration for current wave
	@param enemyName: string - Name of the enemy
	@param waveNumber: number - Current wave number
	@param difficultyMultiplier: number - Difficulty scaling multiplier
	@return table - Scaled enemy config for EnemyAI
--]]
function EnemyStats.GetScaledConfig(enemyName, waveNumber, difficultyMultiplier)
	local enemy = EnemyStats.GetEnemy(enemyName)
	if not enemy then
		warn(string.format("[EnemyStats] Enemy '%s' not found", enemyName))
		return nil
	end

	return enemy:GetEnemyConfig(waveNumber, difficultyMultiplier)
end

--[[
	Calculate weighted random enemy selection for spawning
	@param waveNumber: number - Current wave number
	@return string - Selected enemy name
--]]
function EnemyStats.GetRandomEnemy(waveNumber)
	local spawnableEnemies = EnemyStats.GetSpawnableForWave(waveNumber)

	if #spawnableEnemies == 0 then
		warn("[EnemyStats] No spawnable enemies for wave " .. waveNumber)
		return "Zombie_Toilet" -- Fallback
	end

	-- Calculate total weight
	local totalWeight = 0
	local weights = {}

	for _, enemyName in ipairs(spawnableEnemies) do
		local enemy = EnemyStats.GetEnemy(enemyName)
		local weight = enemy:GetSpawnWeight(waveNumber)
		weights[enemyName] = weight
		totalWeight = totalWeight + weight
	end

	-- Random selection based on weight
	local randomValue = math.random() * totalWeight
	local currentWeight = 0

	for _, enemyName in ipairs(spawnableEnemies) do
		currentWeight = currentWeight + weights[enemyName]
		if randomValue <= currentWeight then
			return enemyName
		end
	end

	-- Fallback
	return spawnableEnemies[1]
end

--[[
	Get group size for an enemy
	@param enemyName: string - Name of the enemy
	@return number - How many to spawn in a group
--]]
function EnemyStats.GetGroupSize(enemyName)
	local enemy = EnemyStats.GetEnemy(enemyName)
	if not enemy then
		return 1
	end

	return enemy:GetGroupSize()
end

--[[
	Check if a boss should spawn this wave
	@param waveNumber: number - Current wave number
	@return boolean, string - Should spawn, boss name
--]]
function EnemyStats.ShouldSpawnBoss(waveNumber)
	for _, bossName in ipairs(EnemyStats.BossEnemies) do
		local boss = EnemyStats.GetEnemy(bossName)

		if boss and boss:ShouldSpawnThisWave(waveNumber) then
			return true, bossName
		end
	end

	return false, nil
end

--[[
	Get enemy display information
	@param enemyName: string - Name of the enemy
	@param waveNumber: number - Current wave (for scaling)
	@return table - Display information
--]]
function EnemyStats.GetDisplayInfo(enemyName, waveNumber)
	local enemy = EnemyStats.GetEnemy(enemyName)
	if not enemy then
		return nil
	end

	waveNumber = waveNumber or 1
	local config = enemy:GetEnemyConfig(waveNumber, 1.0)

	return {
		Name = enemy.Name,
		DisplayName = enemy.DisplayName,
		Description = enemy.Description,
		EnemyType = enemy.EnemyType,
		Difficulty = enemy.Difficulty,
		Category = enemy.Category,
		Tags = enemy.Tags,

		-- Stats (at current wave)
		Stats = {
			Health = config.MaxHealth,
			Speed = config.MoveSpeed,
			Damage = config.Damage,
			AttackRange = config.AttackRange,
		},

		-- Rewards
		XPReward = config.XPDropAmount,
		CoinChance = enemy.Rewards.CoinsDropChance,

		-- Visual
		PrimaryColor = enemy.Visual.PrimaryColor,
		SecondaryColor = enemy.Visual.SecondaryColor,
		Size = enemy.Visual.Size,
	}
end

--[[
	Get spawn weights for all enemies at a wave
	@param waveNumber: number - Current wave number
	@return table - Map of enemy name to weight
--]]
function EnemyStats.GetAllSpawnWeights(waveNumber)
	local weights = {}

	for _, enemyName in ipairs(EnemyStats.SpawnableEnemies) do
		local enemy = EnemyStats.GetEnemy(enemyName)
		if enemy then
			weights[enemyName] = enemy:GetSpawnWeight(waveNumber)
		end
	end

	return weights
end

--[[
	Calculate total enemy count for a wave composition
	@param waveNumber: number - Current wave number
	@param totalEnemies: number - Total enemies to spawn
	@return table - Array of {enemyName, count}
--]]
function EnemyStats.GenerateWaveComposition(waveNumber, totalEnemies)
	local composition = {}
	local remainingEnemies = totalEnemies

	-- Get spawnable enemies and their weights
	local spawnableEnemies = EnemyStats.GetSpawnableForWave(waveNumber)
	local weights = EnemyStats.GetAllSpawnWeights(waveNumber)

	-- Calculate distribution based on weights
	local totalWeight = 0
	for _, weight in pairs(weights) do
		totalWeight = totalWeight + weight
	end

	-- Distribute enemies based on weight
	for _, enemyName in ipairs(spawnableEnemies) do
		if remainingEnemies > 0 then
			local weight = weights[enemyName]
			local proportion = weight / totalWeight
			local count = math.floor(totalEnemies * proportion)

			if count > 0 then
				table.insert(composition, {
					EnemyName = enemyName,
					Count = count
				})
				remainingEnemies = remainingEnemies - count
			end
		end
	end

	-- Distribute any remaining enemies randomly
	while remainingEnemies > 0 do
		local randomEnemy = EnemyStats.GetRandomEnemy(waveNumber)
		local found = false

		for _, entry in ipairs(composition) do
			if entry.EnemyName == randomEnemy then
				entry.Count = entry.Count + 1
				found = true
				break
			end
		end

		if not found then
			table.insert(composition, {
				EnemyName = randomEnemy,
				Count = 1
			})
		end

		remainingEnemies = remainingEnemies - 1
	end

	return composition
end

--[[
	Get enemy stat comparison
	@param enemyName1: string - First enemy
	@param enemyName2: string - Second enemy
	@param waveNumber: number - Wave for scaling
	@return table - Comparison data
--]]
function EnemyStats.CompareEnemies(enemyName1, enemyName2, waveNumber)
	local enemy1 = EnemyStats.GetEnemy(enemyName1)
	local enemy2 = EnemyStats.GetEnemy(enemyName2)

	if not enemy1 or not enemy2 then
		return nil
	end

	waveNumber = waveNumber or 1

	local config1 = enemy1:GetEnemyConfig(waveNumber, 1.0)
	local config2 = enemy2:GetEnemyConfig(waveNumber, 1.0)

	return {
		Enemy1 = {
			Name = enemy1.DisplayName,
			Health = config1.MaxHealth,
			Damage = config1.Damage,
			Speed = config1.MoveSpeed,
		},
		Enemy2 = {
			Name = enemy2.DisplayName,
			Health = config2.MaxHealth,
			Damage = config2.Damage,
			Speed = config2.MoveSpeed,
		},
		Comparison = {
			HealthDiff = config1.MaxHealth - config2.MaxHealth,
			DamageDiff = config1.Damage - config2.Damage,
			SpeedDiff = config1.MoveSpeed - config2.MoveSpeed,
		}
	}
end

return EnemyStats
