--[[
	SpawnConfig.lua

	Enemy spawn patterns and wave configurations for Skibidi Toilet game.
	Defines how and where enemies spawn during waves.

	Features:
	- Spawn point management
	- Wave composition generation
	- Spawn timing and patterns
	- Boss spawn handling
--]]

local SpawnConfig = {}

-- Import dependencies
local EnemyStats = require(script.Parent.Parent.Config.EnemyStats)
local BalanceData = require(script.Parent.Parent.Config.BalanceData)

-- ============================================================================
-- SPAWN POINTS
-- ============================================================================

SpawnConfig.SpawnPoints = {
	-- Spawn points are positioned around the map perimeter
	-- Format: {Position = Vector3, Rotation = CFrame.Angles()}

	-- Will be populated when map is loaded
	Points = {},

	-- Spawn point configuration
	MinDistanceFromPlayer = 40, -- Minimum studs from player
	MaxDistanceFromPlayer = 80, -- Maximum studs from player
	SpawnRadius = 5, -- Random offset within radius

	-- Spawn patterns
	Patterns = {
		RANDOM = "Random", -- Random spawn points
		CIRCLE = "Circle", -- Spawn in circle around player
		WAVE = "Wave", -- Spawn in wave formation
		SIDES = "Sides", -- Spawn from sides
		AMBUSH = "Ambush", -- Spawn close to player
	}
}

--[[
	Initialize spawn points for a map
	@param mapCenter: Vector3 - Center of the map
	@param mapRadius: number - Radius of the playable area
	@param pointCount: number - Number of spawn points to create
--]]
function SpawnConfig.InitializeSpawnPoints(mapCenter, mapRadius, pointCount)
	SpawnConfig.SpawnPoints.Points = {}
	pointCount = pointCount or 12

	-- Create evenly distributed spawn points around perimeter
	local angleStep = (2 * math.pi) / pointCount

	for i = 1, pointCount do
		local angle = (i - 1) * angleStep
		local spawnDistance = mapRadius * 0.9 -- 90% of map radius

		local position = mapCenter + Vector3.new(
			math.cos(angle) * spawnDistance,
			5, -- Y offset
			math.sin(angle) * spawnDistance
		)

		table.insert(SpawnConfig.SpawnPoints.Points, {
			Position = position,
			Angle = angle,
			Index = i
		})
	end

	print(string.format("[SpawnConfig] Initialized %d spawn points", pointCount))
end

--[[
	Get spawn positions for a pattern
	@param pattern: string - Spawn pattern type
	@param count: number - Number of spawn positions needed
	@param playerPosition: Vector3 - Current player position
	@return table - Array of spawn positions
--]]
function SpawnConfig.GetSpawnPositions(pattern, count, playerPosition)
	local positions = {}

	if pattern == SpawnConfig.SpawnPoints.Patterns.RANDOM then
		-- Random spawn points
		for i = 1, count do
			local randomPoint = SpawnConfig.SpawnPoints.Points[math.random(1, #SpawnConfig.SpawnPoints.Points)]

			-- Add random offset
			local offset = Vector3.new(
				math.random(-SpawnConfig.SpawnPoints.SpawnRadius, SpawnConfig.SpawnPoints.SpawnRadius),
				0,
				math.random(-SpawnConfig.SpawnPoints.SpawnRadius, SpawnConfig.SpawnPoints.SpawnRadius)
			)

			table.insert(positions, randomPoint.Position + offset)
		end

	elseif pattern == SpawnConfig.SpawnPoints.Patterns.CIRCLE then
		-- Spawn in circle around player
		local angleStep = (2 * math.pi) / count
		local spawnDistance = SpawnConfig.SpawnPoints.MinDistanceFromPlayer + 10

		for i = 1, count do
			local angle = (i - 1) * angleStep
			local position = playerPosition + Vector3.new(
				math.cos(angle) * spawnDistance,
				5,
				math.sin(angle) * spawnDistance
			)

			table.insert(positions, position)
		end

	elseif pattern == SpawnConfig.SpawnPoints.Patterns.WAVE then
		-- Spawn in wave formation
		local waveWidth = 30
		local stepX = waveWidth / count
		local spawnDistance = SpawnConfig.SpawnPoints.MinDistanceFromPlayer + 20

		-- Get direction player is facing
		local spawnZ = playerPosition.Z - spawnDistance

		for i = 1, count do
			local x = playerPosition.X - (waveWidth / 2) + (i * stepX)
			table.insert(positions, Vector3.new(x, 5, spawnZ))
		end

	elseif pattern == SpawnConfig.SpawnPoints.Patterns.SIDES then
		-- Spawn from left and right sides
		local halfCount = math.ceil(count / 2)
		local spawnDistance = SpawnConfig.SpawnPoints.MinDistanceFromPlayer + 15

		for i = 1, halfCount do
			-- Left side
			table.insert(positions, playerPosition + Vector3.new(-spawnDistance, 5, math.random(-20, 20)))

			-- Right side
			if i <= count - halfCount then
				table.insert(positions, playerPosition + Vector3.new(spawnDistance, 5, math.random(-20, 20)))
			end
		end

	elseif pattern == SpawnConfig.SpawnPoints.Patterns.AMBUSH then
		-- Spawn closer to player (dangerous!)
		local angleStep = (2 * math.pi) / count
		local spawnDistance = SpawnConfig.SpawnPoints.MinDistanceFromPlayer

		for i = 1, count do
			local angle = (i - 1) * angleStep
			local position = playerPosition + Vector3.new(
				math.cos(angle) * spawnDistance,
				5,
				math.sin(angle) * spawnDistance
			)

			table.insert(positions, position)
		end
	end

	return positions
end

-- ============================================================================
-- WAVE GENERATION
-- ============================================================================

SpawnConfig.Waves = {
	-- Default spawn pattern progression
	DefaultPattern = SpawnConfig.SpawnPoints.Patterns.RANDOM,

	-- Pattern overrides for specific waves
	PatternOverrides = {
		[1] = SpawnConfig.SpawnPoints.Patterns.CIRCLE, -- First wave: easy circle spawn
		[5] = SpawnConfig.SpawnPoints.Patterns.WAVE, -- Wave 5: wave formation
		[10] = SpawnConfig.SpawnPoints.Patterns.SIDES, -- Wave 10: side ambush
		[15] = SpawnConfig.SpawnPoints.Patterns.AMBUSH, -- Wave 15: close spawn
	},

	-- Spawn timing
	SpawnDelay = 0.5, -- Seconds between enemy spawns
	GroupSpawnDelay = 0.2, -- Seconds between enemies in a group
	BossSpawnDelay = 2.0, -- Dramatic pause before boss
}

--[[
	Generate wave composition
	@param waveNumber: number - Current wave number
	@return table - Wave data with enemy types and counts
--]]
function SpawnConfig.GenerateWave(waveNumber)
	-- Calculate total enemies for this wave
	local totalEnemies = math.floor(
		BalanceData.Waves.BaseEnemyCount *
		(BalanceData.Waves.EnemyScalingRate ^ (waveNumber - 1))
	)

	-- Get difficulty multiplier
	local difficultyMultiplier = BalanceData.Waves.BaseDifficulty +
		(BalanceData.Waves.DifficultyIncrement * (waveNumber - 1))

	-- Generate enemy composition
	local composition = EnemyStats.GenerateWaveComposition(waveNumber, totalEnemies)

	-- Get spawn pattern
	local spawnPattern = SpawnConfig.Waves.PatternOverrides[waveNumber] or
		SpawnConfig.Waves.DefaultPattern

	-- Check for boss wave
	local isBossWave, bossName = EnemyStats.ShouldSpawnBoss(waveNumber)

	return {
		WaveNumber = waveNumber,
		TotalEnemies = totalEnemies,
		DifficultyMultiplier = difficultyMultiplier,
		Composition = composition,
		SpawnPattern = spawnPattern,
		IsBossWave = isBossWave,
		BossName = bossName,
	}
end

--[[
	Generate spawn sequence for a wave
	@param waveData: table - Wave data from GenerateWave()
	@param playerPosition: Vector3 - Current player position
	@return table - Array of spawn events {time, enemyName, position}
--]]
function SpawnConfig.GenerateSpawnSequence(waveData, playerPosition)
	local sequence = {}
	local currentTime = 0

	-- Spawn regular enemies
	for _, entry in ipairs(waveData.Composition) do
		local enemyName = entry.EnemyName
		local count = entry.Count

		-- Get group size for this enemy type
		local enemy = EnemyStats.GetEnemy(enemyName)
		local groupSize = enemy:GetGroupSize()

		-- Spawn in groups
		local groupCount = math.ceil(count / groupSize)

		for group = 1, groupCount do
			local enemiesInGroup = math.min(groupSize, count - ((group - 1) * groupSize))

			-- Get spawn positions for this group
			local positions = SpawnConfig.GetSpawnPositions(
				waveData.SpawnPattern,
				enemiesInGroup,
				playerPosition
			)

			-- Add spawn events for each enemy in group
			for i = 1, enemiesInGroup do
				table.insert(sequence, {
					Time = currentTime,
					EnemyName = enemyName,
					Position = positions[i] or positions[1],
					WaveNumber = waveData.WaveNumber,
					DifficultyMultiplier = waveData.DifficultyMultiplier,
				})

				currentTime = currentTime + SpawnConfig.Waves.GroupSpawnDelay
			end

			-- Delay between groups
			currentTime = currentTime + SpawnConfig.Waves.SpawnDelay
		end
	end

	-- Spawn boss if boss wave
	if waveData.IsBossWave and waveData.BossName then
		-- Dramatic pause before boss
		currentTime = currentTime + SpawnConfig.Waves.BossSpawnDelay

		-- Boss spawns at center or random point
		local bossPosition = playerPosition + Vector3.new(0, 5, 50)

		table.insert(sequence, {
			Time = currentTime,
			EnemyName = waveData.BossName,
			Position = bossPosition,
			WaveNumber = waveData.WaveNumber,
			DifficultyMultiplier = waveData.DifficultyMultiplier,
			IsBoss = true,
		})
	end

	return sequence
end

--[[
	Get spawn information for display
	@param waveNumber: number - Wave number
	@return table - Spawn info
--]]
function SpawnConfig.GetSpawnInfo(waveNumber)
	local waveData = SpawnConfig.GenerateWave(waveNumber)

	local info = {
		WaveNumber = waveNumber,
		TotalEnemies = waveData.TotalEnemies,
		Difficulty = string.format("%.1fx", waveData.DifficultyMultiplier),
		SpawnPattern = waveData.SpawnPattern,
		IsBossWave = waveData.IsBossWave,
		EnemyTypes = {},
	}

	for _, entry in ipairs(waveData.Composition) do
		table.insert(info.EnemyTypes, {
			Name = entry.EnemyName,
			Count = entry.Count,
		})
	end

	if waveData.IsBossWave then
		table.insert(info.EnemyTypes, {
			Name = waveData.BossName,
			Count = 1,
			IsBoss = true,
		})
	end

	return info
end

return SpawnConfig
