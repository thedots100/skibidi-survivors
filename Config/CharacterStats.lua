--[[
	CharacterStats.lua

	Central configuration for all character stats in Skibidi Toilet game.
	Provides easy access to character data and stat calculations.

	Usage:
		local CharacterStats = require(game.ReplicatedStorage.CharacterStats)
		local character = CharacterStats.GetCharacter("Skibidi_Basic")
		local stats = CharacterStats.GetFinalStats("Cameraman", playerData)
--]]

local CharacterStats = {}

-- Import character modules
local Characters = script.Parent.Parent.Characters
local Skibidi_Basic = require(Characters.Skibidi_Basic)
local Cameraman = require(Characters.Cameraman)
local Speakerman = require(Characters.Speakerman)

-- Character registry
CharacterStats.Characters = {
	["Skibidi_Basic"] = Skibidi_Basic,
	["Cameraman"] = Cameraman,
	["Speakerman"] = Speakerman,
}

-- List of all character names
CharacterStats.CharacterList = {
	"Skibidi_Basic",
	"Cameraman",
	"Speakerman",
}

-- Starting character
CharacterStats.DefaultCharacter = "Skibidi_Basic"

--[[
	Get a character by name
	@param characterName: string - Name of the character
	@return table or nil - Character data
--]]
function CharacterStats.GetCharacter(characterName)
	return CharacterStats.Characters[characterName]
end

--[[
	Get all available characters
	@return table - Array of character data
--]]
function CharacterStats.GetAllCharacters()
	local characters = {}
	for _, name in ipairs(CharacterStats.CharacterList) do
		table.insert(characters, CharacterStats.Characters[name])
	end
	return characters
end

--[[
	Get final stats for a character with bonuses applied
	@param characterName: string - Name of the character
	@param playerData: table - Player's save data (for upgrades/bonuses)
	@return table - Final calculated stats
--]]
function CharacterStats.GetFinalStats(characterName, playerData)
	local character = CharacterStats.GetCharacter(characterName)
	if not character then
		warn(string.format("[CharacterStats] Character '%s' not found", characterName))
		return nil
	end

	-- Get base stats
	local finalStats = {}
	for key, value in pairs(character.Stats) do
		finalStats[key] = value
	end

	-- Apply any global bonuses from player data
	if playerData then
		-- Apply level-based bonuses
		local playerLevel = playerData.Level or 1
		finalStats.MaxHealth = finalStats.MaxHealth + (playerLevel * 2) -- +2 HP per level
		finalStats.MoveSpeed = finalStats.MoveSpeed + (playerLevel * 0.1) -- +0.1 speed per level

		-- Apply any permanent upgrades
		-- This would integrate with the UpgradeSystem
	end

	return finalStats
end

--[[
	Check if a player can unlock a character
	@param characterName: string - Name of the character
	@param playerData: table - Player's save data
	@return boolean, string - Can unlock, reason
--]]
function CharacterStats.CanUnlock(characterName, playerData)
	local character = CharacterStats.GetCharacter(characterName)
	if not character then
		return false, "Character not found"
	end

	return character:CanUnlock(playerData)
end

--[[
	Unlock a character for a player
	@param characterName: string - Name of the character
	@param playerData: table - Player's save data
	@param useGamePass: boolean - Whether unlocking via GamePass
	@return boolean, string - Success, message
--]]
function CharacterStats.UnlockCharacter(characterName, playerData, useGamePass)
	local character = CharacterStats.GetCharacter(characterName)
	if not character then
		return false, "Character not found"
	end

	return character:UnlockForPlayer(playerData, useGamePass)
end

--[[
	Get all characters the player owns
	@param playerData: table - Player's save data
	@return table - Array of owned character names
--]]
function CharacterStats.GetOwnedCharacters(playerData)
	if not playerData or not playerData.Characters then
		return {CharacterStats.DefaultCharacter}
	end

	return playerData.Characters.Owned or {CharacterStats.DefaultCharacter}
end

--[[
	Get all characters the player can unlock (but doesn't own)
	@param playerData: table - Player's save data
	@return table - Array of {name, character, canUnlock, reason}
--]]
function CharacterStats.GetAvailableCharacters(playerData)
	local available = {}

	for _, name in ipairs(CharacterStats.CharacterList) do
		local character = CharacterStats.GetCharacter(name)

		-- Skip if already owned
		if not table.find(playerData.Characters.Owned, name) then
			local canUnlock, reason = character:CanUnlock(playerData)

			table.insert(available, {
				Name = name,
				Character = character,
				CanUnlock = canUnlock,
				Reason = reason,
			})
		end
	end

	return available
end

--[[
	Get character UI display data
	@param characterName: string - Name of the character
	@param playerData: table - Player's save data
	@return table - Display information
--]]
function CharacterStats.GetDisplayInfo(characterName, playerData)
	local character = CharacterStats.GetCharacter(characterName)
	if not character then
		return nil
	end

	local stats = CharacterStats.GetFinalStats(characterName, playerData)
	local isOwned = table.find(CharacterStats.GetOwnedCharacters(playerData), characterName) ~= nil
	local canUnlock, unlockReason = character:CanUnlock(playerData)

	return {
		Name = character.Name,
		DisplayName = character.DisplayName,
		Description = character.Description,
		Rarity = character.Rarity,
		Category = character.Category,
		Tags = character.Tags,

		-- Stats
		Stats = stats,

		-- Ability info
		Ability = {
			Name = character.Ability.Name,
			Description = character.Ability.Description,
			Cooldown = character.Ability.Cooldown,
			Type = character.Ability.Type,
		},

		-- Unlock status
		IsOwned = isOwned,
		CanUnlock = canUnlock,
		UnlockReason = unlockReason,
		UnlockType = character.UnlockType,
		UnlockCost = character.UnlockCost,

		-- Visual
		ThumbnailId = character.Visual.ThumbnailId,
		PrimaryColor = character.Visual.PrimaryColor,
		SecondaryColor = character.Visual.SecondaryColor,
	}
end

--[[
	Validate character selection
	@param characterName: string - Name of the character
	@param playerData: table - Player's save data
	@return boolean - Whether character can be selected
--]]
function CharacterStats.CanSelectCharacter(characterName, playerData)
	-- Check if character exists
	local character = CharacterStats.GetCharacter(characterName)
	if not character then
		return false
	end

	-- Check if player owns the character
	local owned = CharacterStats.GetOwnedCharacters(playerData)
	return table.find(owned, characterName) ~= nil
end

--[[
	Get comparison between two characters
	@param character1Name: string - First character
	@param character2Name: string - Second character
	@return table - Comparison data
--]]
function CharacterStats.CompareCharacters(character1Name, character2Name)
	local char1 = CharacterStats.GetCharacter(character1Name)
	local char2 = CharacterStats.GetCharacter(character2Name)

	if not char1 or not char2 then
		return nil
	end

	return {
		Character1 = {
			Name = char1.DisplayName,
			Health = char1.Stats.MaxHealth,
			Speed = char1.Stats.MoveSpeed,
			Ability = char1.Ability.Name,
		},
		Character2 = {
			Name = char2.DisplayName,
			Health = char2.Stats.MaxHealth,
			Speed = char2.Stats.MoveSpeed,
			Ability = char2.Ability.Name,
		},
		Comparison = {
			HealthDiff = char1.Stats.MaxHealth - char2.Stats.MaxHealth,
			SpeedDiff = char1.Stats.MoveSpeed - char2.Stats.MoveSpeed,
		}
	}
end

return CharacterStats
