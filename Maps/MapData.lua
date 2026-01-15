--[[
	MapData.lua

	Map configuration and boundaries for Skibidi Toilet game.
	Defines playable areas, spawn zones, and map properties.

	Features:
	- Map dimensions and boundaries
	- Safe zones and spawn areas
	- Map obstacles/geometry
	- Environmental settings
--]]

local MapData = {}

-- ============================================================================
-- DEFAULT MAP CONFIGURATION
-- ============================================================================

MapData.DefaultMap = {
	-- Map Information
	Name = "Skibidi Arena",
	Description = "A circular arena perfect for survival combat",
	Theme = "Urban",

	-- Dimensions
	Center = Vector3.new(0, 0, 0), -- Map center point
	Radius = 150, -- Playable radius (studs)
	Height = 50, -- Maximum height limit

	-- Boundaries
	Boundaries = {
		Type = "Circle", -- Circle, Square, or Custom
		EnforcementType = "Push", -- Push (pushes player back), Kill (kills player), or Soft (just warns)
		PushForce = 50, -- Force applied when pushing player back
		WarningDistance = 10, -- Distance from boundary to show warning
	},

	-- Player Spawn
	PlayerSpawn = {
		Position = Vector3.new(0, 5, 0),
		Rotation = CFrame.Angles(0, 0, 0),
		SpawnRadius = 5, -- Random spawn within this radius
		SafeZoneRadius = 20, -- No enemies spawn in this radius at start
	},

	-- Environment
	Environment = {
		-- Lighting
		TimeOfDay = "12:00:00", -- Noon
		Ambient = Color3.fromRGB(150, 150, 150),
		OutdoorAmbient = Color3.fromRGB(127, 127, 127),
		Brightness = 2,

		-- Atmosphere
		FogEnabled = false,
		FogColor = Color3.fromRGB(192, 192, 192),
		FogEnd = 500,
		FogStart = 0,

		-- Sky
		SkyboxEnabled = true,
		SkyboxId = "rbxassetid://0", -- Set to actual skybox ID
	},

	-- Obstacles (structures that block movement)
	Obstacles = {
		-- Example obstacles (will be generated procedurally or placed manually)
		{
			Type = "Wall",
			Position = Vector3.new(30, 5, 0),
			Size = Vector3.new(20, 10, 2),
			Color = Color3.fromRGB(100, 100, 100),
		},
		{
			Type = "Pillar",
			Position = Vector3.new(-30, 5, 0),
			Size = Vector3.new(5, 15, 5),
			Color = Color3.fromRGB(150, 150, 150),
		},
		{
			Type = "Crate",
			Position = Vector3.new(0, 3, 30),
			Size = Vector3.new(6, 6, 6),
			Color = Color3.fromRGB(139, 90, 43),
		},
	},

	-- Zones
	Zones = {
		SafeZone = {
			Center = Vector3.new(0, 0, 0),
			Radius = 20,
			NoEnemySpawn = true,
			Description = "Starting safe zone",
		},

		DangerZone = {
			-- Areas with increased enemy spawn rates
			Enabled = false,
		},
	},
}

-- ============================================================================
-- MAP VARIANTS
-- ============================================================================

MapData.Maps = {
	["Skibidi_Arena"] = MapData.DefaultMap,

	["Toilet_Factory"] = {
		Name = "Toilet Factory",
		Description = "An abandoned factory filled with machinery",
		Theme = "Industrial",

		Center = Vector3.new(0, 0, 0),
		Radius = 180,
		Height = 60,

		Boundaries = {
			Type = "Square",
			EnforcementType = "Push",
			PushForce = 50,
			WarningDistance = 10,
		},

		PlayerSpawn = {
			Position = Vector3.new(0, 5, 0),
			Rotation = CFrame.Angles(0, 0, 0),
			SpawnRadius = 5,
			SafeZoneRadius = 25,
		},

		Environment = {
			TimeOfDay = "18:00:00", -- Dusk
			Ambient = Color3.fromRGB(100, 100, 120),
			OutdoorAmbient = Color3.fromRGB(80, 80, 100),
			Brightness = 1.5,
			FogEnabled = true,
			FogColor = Color3.fromRGB(150, 150, 160),
			FogEnd = 400,
			FogStart = 100,
			SkyboxEnabled = true,
		},

		Obstacles = {
			-- More obstacles for factory theme
		},
	},

	["Camera_Wasteland"] = {
		Name = "Camera Wasteland",
		Description = "A desolate wasteland littered with broken cameras",
		Theme = "Post-Apocalyptic",

		Center = Vector3.new(0, 0, 0),
		Radius = 200,
		Height = 50,

		Boundaries = {
			Type = "Circle",
			EnforcementType = "Soft",
			WarningDistance = 15,
		},

		PlayerSpawn = {
			Position = Vector3.new(0, 5, 0),
			Rotation = CFrame.Angles(0, 0, 0),
			SpawnRadius = 8,
			SafeZoneRadius = 15,
		},

		Environment = {
			TimeOfDay = "06:00:00", -- Dawn
			Ambient = Color3.fromRGB(180, 150, 120),
			OutdoorAmbient = Color3.fromRGB(150, 120, 90),
			Brightness = 1.8,
			FogEnabled = true,
			FogColor = Color3.fromRGB(200, 180, 150),
			FogEnd = 600,
			FogStart = 200,
			SkyboxEnabled = true,
		},

		Obstacles = {},
	},
}

-- ============================================================================
-- MAP FUNCTIONS
-- ============================================================================

--[[
	Get map configuration by name
	@param mapName: string - Name of the map
	@return table - Map configuration
--]]
function MapData.GetMap(mapName)
	return MapData.Maps[mapName] or MapData.DefaultMap
end

--[[
	Get all available maps
	@return table - Array of map names
--]]
function MapData.GetMapList()
	local maps = {}
	for mapName, _ in pairs(MapData.Maps) do
		table.insert(maps, mapName)
	end
	return maps
end

--[[
	Check if a position is within map boundaries
	@param position: Vector3 - Position to check
	@param mapConfig: table - Map configuration
	@return boolean, number - Is valid, distance from boundary (negative = outside)
--]]
function MapData.IsPositionValid(position, mapConfig)
	mapConfig = mapConfig or MapData.DefaultMap

	if mapConfig.Boundaries.Type == "Circle" then
		-- Check circular boundary
		local distance = (position - mapConfig.Center).Magnitude
		local distanceFromBoundary = mapConfig.Radius - distance

		return distance <= mapConfig.Radius, distanceFromBoundary

	elseif mapConfig.Boundaries.Type == "Square" then
		-- Check square boundary
		local halfSize = mapConfig.Radius
		local dx = math.abs(position.X - mapConfig.Center.X)
		local dz = math.abs(position.Z - mapConfig.Center.Z)

		local valid = dx <= halfSize and dz <= halfSize
		local distanceFromBoundary = math.min(halfSize - dx, halfSize - dz)

		return valid, distanceFromBoundary
	end

	return true, 0
end

--[[
	Get push vector to keep entity within boundaries
	@param position: Vector3 - Current position
	@param mapConfig: table - Map configuration
	@return Vector3 - Push direction (normalized), or zero if inside
--]]
function MapData.GetBoundaryPushVector(position, mapConfig)
	mapConfig = mapConfig or MapData.DefaultMap

	local isValid, distanceFromBoundary = MapData.IsPositionValid(position, mapConfig)

	if isValid and distanceFromBoundary > 0 then
		return Vector3.new(0, 0, 0) -- Inside boundary, no push
	end

	if mapConfig.Boundaries.Type == "Circle" then
		-- Push toward center
		local direction = (mapConfig.Center - position).Unit
		return direction

	elseif mapConfig.Boundaries.Type == "Square" then
		-- Push toward nearest boundary
		local toCenter = mapConfig.Center - position
		local pushX = toCenter.X / math.abs(toCenter.X)
		local pushZ = toCenter.Z / math.abs(toCenter.Z)

		return Vector3.new(pushX, 0, pushZ).Unit
	end

	return Vector3.new(0, 0, 0)
end

--[[
	Clamp position to map boundaries
	@param position: Vector3 - Position to clamp
	@param mapConfig: table - Map configuration
	@return Vector3 - Clamped position
--]]
function MapData.ClampPosition(position, mapConfig)
	mapConfig = mapConfig or MapData.DefaultMap

	if mapConfig.Boundaries.Type == "Circle" then
		local toPosition = position - mapConfig.Center
		local distance = toPosition.Magnitude

		if distance > mapConfig.Radius then
			-- Clamp to boundary
			return mapConfig.Center + (toPosition.Unit * mapConfig.Radius)
		end

	elseif mapConfig.Boundaries.Type == "Square" then
		local halfSize = mapConfig.Radius

		return Vector3.new(
			math.clamp(position.X, mapConfig.Center.X - halfSize, mapConfig.Center.X + halfSize),
			position.Y,
			math.clamp(position.Z, mapConfig.Center.Z - halfSize, mapConfig.Center.Z + halfSize)
		)
	end

	return position
end

--[[
	Check if position is in safe zone
	@param position: Vector3 - Position to check
	@param mapConfig: table - Map configuration
	@return boolean - Is in safe zone
--]]
function MapData.IsInSafeZone(position, mapConfig)
	mapConfig = mapConfig or MapData.DefaultMap

	if not mapConfig.Zones or not mapConfig.Zones.SafeZone then
		return false
	end

	local safeZone = mapConfig.Zones.SafeZone
	local distance = (position - safeZone.Center).Magnitude

	return distance <= safeZone.Radius
end

--[[
	Get random spawn position within map
	@param mapConfig: table - Map configuration
	@param minDistanceFromCenter: number - Minimum distance from center
	@return Vector3 - Random position
--]]
function MapData.GetRandomPosition(mapConfig, minDistanceFromCenter)
	mapConfig = mapConfig or MapData.DefaultMap
	minDistanceFromCenter = minDistanceFromCenter or 0

	if mapConfig.Boundaries.Type == "Circle" then
		-- Random position in circle
		local angle = math.random() * 2 * math.pi
		local distance = math.random() * (mapConfig.Radius - minDistanceFromCenter) + minDistanceFromCenter

		return mapConfig.Center + Vector3.new(
			math.cos(angle) * distance,
			5,
			math.sin(angle) * distance
		)

	elseif mapConfig.Boundaries.Type == "Square" then
		-- Random position in square
		local halfSize = mapConfig.Radius - minDistanceFromCenter

		return mapConfig.Center + Vector3.new(
			math.random(-halfSize, halfSize),
			5,
			math.random(-halfSize, halfSize)
		)
	end

	return mapConfig.Center + Vector3.new(0, 5, 0)
end

--[[
	Get map info for display
	@param mapName: string - Name of the map
	@return table - Display info
--]]
function MapData.GetMapInfo(mapName)
	local map = MapData.GetMap(mapName)

	return {
		Name = map.Name,
		Description = map.Description,
		Theme = map.Theme,
		Size = map.Radius * 2, -- Diameter
		BoundaryType = map.Boundaries.Type,
		HasObstacles = #map.Obstacles > 0,
	}
end

return MapData
