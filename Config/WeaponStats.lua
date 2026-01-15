--[[
	WeaponStats.lua

	Central configuration for all weapon stats in Skibidi Toilet game.
	Manages weapon data, upgrades, and stat calculations.

	Usage:
		local WeaponStats = require(game.ReplicatedStorage.WeaponStats)
		local weapon = WeaponStats.GetWeapon("Toilet_Plunger")
		local config = WeaponStats.GetWeaponConfig("Camera_Flash", player, upgradeSystem, 3)
--]]

local WeaponStats = {}

-- Import weapon modules
local Weapons = script.Parent.Parent.Weapons
local Toilet_Plunger = require(Weapons.Toilet_Plunger)
local Camera_Flash = require(Weapons.Camera_Flash)
local Speaker_Blast = require(Weapons.Speaker_Blast)
local Golden_Plunger = require(Weapons.Golden_Plunger)

-- Weapon registry
WeaponStats.Weapons = {
	["Toilet_Plunger"] = Toilet_Plunger,
	["Camera_Flash"] = Camera_Flash,
	["Speaker_Blast"] = Speaker_Blast,
	["Golden_Plunger"] = Golden_Plunger,
}

-- Weapon list by category
WeaponStats.WeaponsByCategory = {
	Melee = {"Toilet_Plunger", "Golden_Plunger"},
	Ranged = {"Camera_Flash"},
	AOE = {"Speaker_Blast"},
}

-- Starting weapons for each character
WeaponStats.CharacterStartingWeapons = {
	["Skibidi_Basic"] = "Toilet_Plunger",
	["Cameraman"] = "Camera_Flash",
	["Speakerman"] = "Speaker_Blast",
}

--[[
	Get a weapon by name
	@param weaponName: string - Name of the weapon
	@return table or nil - Weapon data
--]]
function WeaponStats.GetWeapon(weaponName)
	return WeaponStats.Weapons[weaponName]
end

--[[
	Get weapon configuration for WeaponFramework
	@param weaponName: string - Name of the weapon
	@param player: Player - The player who owns this weapon
	@param upgradeSystem: UpgradeSystem - Reference to upgrade system
	@param weaponLevel: number - Current weapon level
	@return table - Weapon config for WeaponFramework.new()
--]]
function WeaponStats.GetWeaponConfig(weaponName, player, upgradeSystem, weaponLevel)
	local weapon = WeaponStats.GetWeapon(weaponName)
	if not weapon then
		warn(string.format("[WeaponStats] Weapon '%s' not found", weaponName))
		return nil
	end

	return weapon:GetWeaponConfig(player, upgradeSystem, weaponLevel or 1)
end

--[[
	Get all weapons
	@return table - Array of weapon data
--]]
function WeaponStats.GetAllWeapons()
	local weapons = {}
	for weaponName, weaponData in pairs(WeaponStats.Weapons) do
		table.insert(weapons, weaponData)
	end
	return weapons
end

--[[
	Get weapons by category
	@param category: string - Category (Melee, Ranged, AOE)
	@return table - Array of weapon names
--]]
function WeaponStats.GetWeaponsByCategory(category)
	return WeaponStats.WeaponsByCategory[category] or {}
end

--[[
	Get starting weapon for a character
	@param characterName: string - Name of the character
	@return string - Starting weapon name
--]]
function WeaponStats.GetStartingWeapon(characterName)
	return WeaponStats.CharacterStartingWeapons[characterName] or "Toilet_Plunger"
end

--[[
	Get weapon display information
	@param weaponName: string - Name of the weapon
	@param weaponLevel: number - Current weapon level
	@return table - Display information
--]]
function WeaponStats.GetDisplayInfo(weaponName, weaponLevel)
	local weapon = WeaponStats.GetWeapon(weaponName)
	if not weapon then
		return nil
	end

	weaponLevel = weaponLevel or 1

	return weapon:GetStatsDisplay(weaponLevel)
end

--[[
	Check if weapon can be upgraded
	@param weaponName: string - Name of the weapon
	@param currentLevel: number - Current weapon level
	@return boolean - Can upgrade
--]]
function WeaponStats.CanUpgrade(weaponName, currentLevel)
	local weapon = WeaponStats.GetWeapon(weaponName)
	if not weapon then
		return false
	end

	return currentLevel < weapon.Upgrades.MaxLevel
end

--[[
	Get upgrade cost for a weapon
	@param weaponName: string - Name of the weapon
	@param currentLevel: number - Current weapon level
	@return number or nil - Cost to upgrade, nil if max level
--]]
function WeaponStats.GetUpgradeCost(weaponName, currentLevel)
	local weapon = WeaponStats.GetWeapon(weaponName)
	if not weapon or not WeaponStats.CanUpgrade(weaponName, currentLevel) then
		return nil
	end

	-- Base upgrade cost formula: 100 * level^1.5
	return math.floor(100 * (currentLevel ^ 1.5))
end

--[[
	Get next level bonuses for a weapon
	@param weaponName: string - Name of the weapon
	@param currentLevel: number - Current weapon level
	@return table or nil - Next level info
--]]
function WeaponStats.GetNextLevelInfo(weaponName, currentLevel)
	local weapon = WeaponStats.GetWeapon(weaponName)
	if not weapon then
		return nil
	end

	return weapon:GetNextLevelInfo(currentLevel)
end

--[[
	Upgrade a weapon
	@param weaponName: string - Name of the weapon
	@param playerData: table - Player's save data
	@return boolean, string - Success, message
--]]
function WeaponStats.UpgradeWeapon(weaponName, playerData)
	local weapon = WeaponStats.GetWeapon(weaponName)
	if not weapon then
		return false, "Weapon not found"
	end

	-- Get current weapon level from player data
	if not playerData.Weapons then
		playerData.Weapons = {Owned = {}, Levels = {}}
	end

	local currentLevel = playerData.Weapons.Levels[weaponName] or 1

	-- Check if can upgrade
	if not WeaponStats.CanUpgrade(weaponName, currentLevel) then
		return false, "Weapon is max level"
	end

	-- Check upgrade cost
	local cost = WeaponStats.GetUpgradeCost(weaponName, currentLevel)
	if playerData.Coins < cost then
		return false, string.format("Need %d coins", cost)
	end

	-- Perform upgrade
	playerData.Coins = playerData.Coins - cost
	playerData.Weapons.Levels[weaponName] = currentLevel + 1

	return true, string.format("Upgraded to level %d!", currentLevel + 1)
end

--[[
	Get weapon level from player data
	@param weaponName: string - Name of the weapon
	@param playerData: table - Player's save data
	@return number - Weapon level
--]]
function WeaponStats.GetWeaponLevel(weaponName, playerData)
	if not playerData or not playerData.Weapons or not playerData.Weapons.Levels then
		return 1
	end

	return playerData.Weapons.Levels[weaponName] or 1
end

--[[
	Check if player owns a weapon
	@param weaponName: string - Name of the weapon
	@param playerData: table - Player's save data
	@return boolean - Owns weapon
--]]
function WeaponStats.OwnsWeapon(weaponName, playerData)
	if not playerData or not playerData.Weapons or not playerData.Weapons.Owned then
		-- Check if it's a starting weapon
		for _, startingWeapon in pairs(WeaponStats.CharacterStartingWeapons) do
			if startingWeapon == weaponName then
				return true
			end
		end
		return false
	end

	return table.find(playerData.Weapons.Owned, weaponName) ~= nil
end

--[[
	Unlock a weapon for a player
	@param weaponName: string - Name of the weapon
	@param playerData: table - Player's save data
	@return boolean - Success
--]]
function WeaponStats.UnlockWeapon(weaponName, playerData)
	local weapon = WeaponStats.GetWeapon(weaponName)
	if not weapon then
		return false
	end

	if not playerData.Weapons then
		playerData.Weapons = {Owned = {}, Levels = {}}
	end

	-- Add to owned weapons if not already owned
	if not table.find(playerData.Weapons.Owned, weaponName) then
		table.insert(playerData.Weapons.Owned, weaponName)
		playerData.Weapons.Levels[weaponName] = 1
		return true
	end

	return false -- Already owned
end

--[[
	Compare two weapons
	@param weapon1Name: string - First weapon
	@param weapon2Name: string - Second weapon
	@param level1: number - First weapon level
	@param level2: number - Second weapon level
	@return table - Comparison data
--]]
function WeaponStats.CompareWeapons(weapon1Name, weapon2Name, level1, level2)
	local weapon1 = WeaponStats.GetWeapon(weapon1Name)
	local weapon2 = WeaponStats.GetWeapon(weapon2Name)

	if not weapon1 or not weapon2 then
		return nil
	end

	level1 = level1 or 1
	level2 = level2 or 1

	local stats1 = weapon1:GetStatsDisplay(level1)
	local stats2 = weapon2:GetStatsDisplay(level2)

	return {
		Weapon1 = {
			Name = stats1.Name,
			Level = level1,
			Damage = stats1.Damage,
			FireRate = stats1.FireRate,
			Range = stats1.Range,
		},
		Weapon2 = {
			Name = stats2.Name,
			Level = level2,
			Damage = stats2.Damage,
			FireRate = stats2.FireRate,
			Range = stats2.Range,
		},
		Comparison = {
			DamageDiff = stats1.Damage - stats2.Damage,
			FireRateDiff = stats1.FireRate - stats2.FireRate,
			RangeDiff = stats1.Range - stats2.Range,
		}
	}
end

--[[
	Get all weapons owned by player
	@param playerData: table - Player's save data
	@return table - Array of {weaponName, level}
--]]
function WeaponStats.GetOwnedWeapons(playerData)
	local owned = {}

	-- Add starting weapons based on owned characters
	if playerData and playerData.Characters and playerData.Characters.Owned then
		for _, characterName in ipairs(playerData.Characters.Owned) do
			local startingWeapon = WeaponStats.GetStartingWeapon(characterName)
			if not table.find(owned, startingWeapon) then
				table.insert(owned, {
					WeaponName = startingWeapon,
					Level = WeaponStats.GetWeaponLevel(startingWeapon, playerData)
				})
			end
		end
	end

	-- Add explicitly owned weapons
	if playerData and playerData.Weapons and playerData.Weapons.Owned then
		for _, weaponName in ipairs(playerData.Weapons.Owned) do
			-- Check if already added
			local alreadyAdded = false
			for _, entry in ipairs(owned) do
				if entry.WeaponName == weaponName then
					alreadyAdded = true
					break
				end
			end

			if not alreadyAdded then
				table.insert(owned, {
					WeaponName = weaponName,
					Level = WeaponStats.GetWeaponLevel(weaponName, playerData)
				})
			end
		end
	end

	return owned
end

return WeaponStats
