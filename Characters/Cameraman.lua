--[[
	Cameraman.lua

	Fast, high-mobility character for skilled players.
	Unlockable via GamePass or 500 coins.

	Features:
	- Lower HP but higher speed (90 HP, 20 speed)
	- "Flash Bang" ability - Blinds and stuns enemies
	- Starting weapon: Camera Flash (ranged)
	- High risk, high reward playstyle
--]]

local Cameraman = {
	-- Character Information
	Name = "Cameraman",
	DisplayName = "Cameraman",
	Description = "A speedy fighter wielding the power of the camera. Flash your enemies to stun them, but watch your health!",

	-- Unlock Requirements
	UnlockType = "COINS_OR_GAMEPASS", -- Can be unlocked with coins OR gamepass
	UnlockCost = 500, -- Coins
	UnlockGamePassId = 0, -- Set to actual GamePass ID
	IsStartingCharacter = false,

	-- Base Stats
	Stats = {
		MaxHealth = 90, -- Lower than basic (glass cannon)
		MoveSpeed = 20, -- Much faster than basic
		HealthRegen = 0.5, -- Small health regen (0.5 HP per second)
		PickupRange = 12, -- Slightly better pickup range
		CritChance = 0.10, -- 10% crit chance (doubled from basic)
		CritMultiplier = 2.5, -- 2.5x damage on crit
		DamageMultiplier = 1.0,
		FireRateMultiplier = 1.1, -- 10% faster fire rate
	},

	-- Starting Weapon
	StartingWeapon = "Camera_Flash",

	-- Character Ability
	Ability = {
		Name = "Flash Bang",
		Description = "Emit a blinding flash that stuns all nearby enemies",

		-- Ability Properties
		Type = "DEBUFF", -- AOE debuff
		Cooldown = 8.0, -- Seconds
		Duration = 2.0, -- Stun duration

		-- Ability Stats
		Radius = 15, -- Studs (AOE range)
		StunDuration = 2.0, -- Seconds enemies are stunned
		BlindDuration = 3.0, -- Seconds of reduced accuracy/vision
		SlowAmount = 0.5, -- Enemies move at 50% speed while blinded

		-- Visual Settings
		FlashColor = Color3.fromRGB(255, 255, 255), -- Bright white
		FlashBrightness = 10,
		ExpansionSpeed = 40, -- How fast the flash expands
		EffectSize = Vector3.new(30, 30, 30), -- Final size

		-- Audio
		SoundId = "rbxassetid://0", -- Flash sound effect
		SoundVolume = 0.7,
	},

	-- Visual Settings
	Visual = {
		-- Character model appearance
		ModelId = nil, -- Set to actual model ID
		PrimaryColor = Color3.fromRGB(80, 80, 80), -- Dark grey
		SecondaryColor = Color3.fromRGB(200, 200, 200), -- Light grey (camera)
		Scale = 0.95, -- Slightly smaller than basic

		-- UI Display
		ThumbnailId = "rbxassetid://0",

		-- Effects
		TrailColor = Color3.fromRGB(255, 255, 255), -- White trail
		TrailEnabled = true,
	},

	-- Character Lore
	Lore = "The Cameraman uses advanced flash technology to blind and disorient enemies. Fast and agile, but requires skill to survive with lower health.",

	-- Metadata
	Rarity = "UNCOMMON",
	Category = "Speed",
	Tags = {"Fast", "Ranged", "Crowd Control", "Advanced"},
	ReleaseDate = "2024-01-01",
}

--[[
	Ability activation function
	Called when player uses their ability
	@param character: Model - The player's character
	@param enemies: table - Array of nearby enemies
	@return boolean - Whether ability activated successfully
--]]
function Cameraman:ActivateAbility(character, enemies)
	if not character or not character:FindFirstChild("HumanoidRootPart") then
		return false
	end

	local rootPart = character.HumanoidRootPart
	local ability = self.Ability

	print(string.format("[Cameraman] Activating ability: %s", ability.Name))

	-- Create expanding flash effect
	local flashSphere = Instance.new("Part")
	flashSphere.Name = "FlashBangEffect"
	flashSphere.Shape = Enum.PartType.Ball
	flashSphere.Size = Vector3.new(1, 1, 1)
	flashSphere.CFrame = rootPart.CFrame
	flashSphere.Anchored = true
	flashSphere.CanCollide = false
	flashSphere.Material = Enum.Material.Neon
	flashSphere.Color = ability.FlashColor
	flashSphere.Transparency = 0.3
	flashSphere.Parent = workspace

	-- Add point light for intense brightness
	local flashLight = Instance.new("PointLight")
	flashLight.Brightness = ability.FlashBrightness
	flashLight.Color = ability.FlashColor
	flashLight.Range = ability.Radius * 2
	flashLight.Parent = flashSphere

	-- Track affected enemies
	local affectedEnemies = {}

	-- Expansion animation
	local startTime = tick()
	local expansionDuration = ability.Radius / ability.ExpansionSpeed

	task.spawn(function()
		-- Expand flash
		while (tick() - startTime) < expansionDuration do
			local progress = (tick() - startTime) / expansionDuration
			local currentSize = 1 + (ability.Radius * 2 * progress)
			flashSphere.Size = Vector3.new(currentSize, currentSize, currentSize)
			flashSphere.Transparency = 0.3 + (0.7 * progress) -- Fade out

			-- Check for enemies in range
			for _, enemy in ipairs(enemies) do
				if enemy and enemy:IsA("Model") and enemy:FindFirstChild("HumanoidRootPart") then
					local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
					local distance = (enemyRoot.Position - rootPart.Position).Magnitude

					-- Stun enemy if in range and not already affected
					if distance <= (currentSize / 2) and not affectedEnemies[enemy] then
						affectedEnemies[enemy] = true

						-- Apply stun effect
						local stunData = {
							Enemy = enemy,
							Duration = ability.StunDuration,
							Source = character,
							Type = "Stun",
							SlowAmount = ability.SlowAmount
						}

						print(string.format("[Cameraman] Stunned enemy at distance %.1f", distance))

						-- This would be handled by the game's buff/debuff system
						-- For now, just log the effect
					end
				end
			end

			task.wait()
		end

		-- Clean up effect
		flashSphere:Destroy()
	end)

	return true
end

--[[
	Get character stats with any passive bonuses applied
	@return table - Final stats
--]]
function Cameraman:GetFinalStats()
	-- Return base stats with any passives
	local stats = {}
	for key, value in pairs(self.Stats) do
		stats[key] = value
	end

	-- Add passive: 10% bonus movement speed when below 50% HP
	stats.LowHealthSpeedBonus = 1.1

	return stats
end

--[[
	Check if player can unlock this character
	@param playerData: table - Player's save data
	@return boolean, string - Can unlock, reason if not
--]]
function Cameraman:CanUnlock(playerData)
	-- Check if already owned
	if table.find(playerData.Characters.Owned, self.Name) then
		return false, "Already owned"
	end

	-- Check if player has the gamepass
	if playerData.Gamepasses[self.UnlockGamePassId] then
		return true, "Unlocked via GamePass"
	end

	-- Check if player has enough coins
	if playerData.Coins >= self.UnlockCost then
		return true, "Can purchase with coins"
	end

	return false, string.format("Need %d coins or GamePass", self.UnlockCost)
end

--[[
	Unlock this character for a player
	@param playerData: table - Player's save data
	@param useGamePass: boolean - Whether to use GamePass instead of coins
	@return boolean, string - Success, message
--]]
function Cameraman:UnlockForPlayer(playerData, useGamePass)
	-- Check if can unlock
	local canUnlock, reason = self:CanUnlock(playerData)
	if not canUnlock then
		return false, reason
	end

	-- Add to owned characters
	table.insert(playerData.Characters.Owned, self.Name)

	-- Deduct coins if not using gamepass
	if not useGamePass then
		playerData.Coins = playerData.Coins - self.UnlockCost
		print(string.format("[Cameraman] Unlocked for %d coins", self.UnlockCost))
		return true, string.format("Unlocked for %d coins!", self.UnlockCost)
	else
		print("[Cameraman] Unlocked via GamePass")
		return true, "Unlocked via GamePass!"
	end
end

return Cameraman
