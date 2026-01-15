--[[
	Skibidi_Basic.lua

	Basic starter character for Skibidi Toilet game.
	Free character available to all players from the start.

	Features:
	- Balanced stats (100 HP, 16 speed)
	- "Toilet Spin" ability - AOE spin attack
	- Starting weapon: Toilet Plunger (melee)
	- Good for beginners learning the game
--]]

local Skibidi_Basic = {
	-- Character Information
	Name = "Skibidi Toilet",
	DisplayName = "Skibidi Toilet",
	Description = "The iconic Skibidi Toilet. Balanced stats and a spinning AOE attack make this character perfect for beginners.",

	-- Unlock Requirements
	UnlockType = "FREE", -- FREE, GAMEPASS, COINS
	UnlockCost = 0,
	UnlockGamePassId = nil,
	IsStartingCharacter = true,

	-- Base Stats
	Stats = {
		MaxHealth = 100,
		MoveSpeed = 16, -- Studs per second
		HealthRegen = 0, -- HP per second (0 = no regen)
		PickupRange = 10, -- Studs (XP orb collection range)
		CritChance = 0.05, -- 5% crit chance
		CritMultiplier = 2.0, -- 2x damage on crit
		DamageMultiplier = 1.0, -- Overall damage multiplier
		FireRateMultiplier = 1.0, -- Overall fire rate multiplier
	},

	-- Starting Weapon
	StartingWeapon = "Toilet_Plunger",

	-- Character Ability
	Ability = {
		Name = "Toilet Spin",
		Description = "Spin rapidly dealing damage to all nearby enemies",

		-- Ability Properties
		Type = "AOE", -- AOE, BUFF, PROJECTILE, SPECIAL
		Cooldown = 5.0, -- Seconds
		Duration = 1.5, -- How long the spin lasts

		-- Ability Stats
		Damage = 30, -- Damage per tick
		DamageInterval = 0.3, -- Damage every 0.3 seconds during spin
		Radius = 12, -- Studs (AOE range)
		KnockbackForce = 20, -- Knockback applied to enemies

		-- Visual Settings
		SpinSpeed = 720, -- Degrees per second (2 full rotations per second)
		EffectColor = Color3.fromRGB(150, 200, 255),
		EffectSize = Vector3.new(24, 3, 24), -- Visual effect size

		-- Audio
		SoundId = "rbxassetid://0", -- Spin sound effect ID
		SoundVolume = 0.5,
	},

	-- Visual Settings
	Visual = {
		-- Character model appearance
		ModelId = nil, -- Set to actual model ID when assets are created
		PrimaryColor = Color3.fromRGB(200, 200, 200), -- Silver/grey
		SecondaryColor = Color3.fromRGB(150, 200, 255), -- Light blue
		Scale = 1.0, -- Model scale multiplier

		-- UI Display
		ThumbnailId = "rbxassetid://0", -- Character icon for UI

		-- Effects
		TrailColor = Color3.fromRGB(150, 200, 255),
		TrailEnabled = true,
	},

	-- Character Lore (for fun)
	Lore = "The original Skibidi Toilet has arrived to defend against the invading hordes. With its signature spin attack, it clears enemies in a wide radius.",

	-- Metadata
	Rarity = "COMMON", -- COMMON, UNCOMMON, RARE, EPIC, LEGENDARY
	Category = "Starter",
	Tags = {"Beginner", "Balanced", "AOE"},
	ReleaseDate = "2024-01-01",
}

--[[
	Ability activation function
	Called when player uses their ability
	@param character: Model - The player's character
	@param enemies: table - Array of nearby enemies
	@return boolean - Whether ability activated successfully
--]]
function Skibidi_Basic:ActivateAbility(character, enemies)
	if not character or not character:FindFirstChild("HumanoidRootPart") then
		return false
	end

	local rootPart = character.HumanoidRootPart
	local ability = self.Ability

	print(string.format("[Skibidi_Basic] Activating ability: %s", ability.Name))

	-- Create visual effect (spinning particle)
	local spinEffect = Instance.new("Part")
	spinEffect.Name = "ToiletSpinEffect"
	spinEffect.Shape = Enum.PartType.Cylinder
	spinEffect.Size = ability.EffectSize
	spinEffect.CFrame = rootPart.CFrame * CFrame.Angles(0, 0, math.rad(90))
	spinEffect.Anchored = true
	spinEffect.CanCollide = false
	spinEffect.Material = Enum.Material.Neon
	spinEffect.Color = ability.EffectColor
	spinEffect.Transparency = 0.5
	spinEffect.Parent = workspace

	-- Damage application loop
	local startTime = tick()
	local lastDamageTime = 0

	-- Spin animation
	task.spawn(function()
		while (tick() - startTime) < ability.Duration do
			-- Rotate effect
			spinEffect.CFrame = rootPart.CFrame * CFrame.Angles(0, 0, math.rad(90)) * CFrame.Angles(0, math.rad((tick() - startTime) * ability.SpinSpeed), 0)

			-- Apply damage at intervals
			if (tick() - lastDamageTime) >= ability.DamageInterval then
				lastDamageTime = tick()

				-- Find and damage enemies in range
				for _, enemy in ipairs(enemies) do
					if enemy and enemy:IsA("Model") and enemy:FindFirstChild("HumanoidRootPart") then
						local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
						local distance = (enemyRoot.Position - rootPart.Position).Magnitude

						if distance <= ability.Radius then
							-- Apply damage (external system will handle this)
							local direction = (enemyRoot.Position - rootPart.Position).Unit

							-- Fire damage event
							local damageEvent = {
								Enemy = enemy,
								Damage = ability.Damage,
								Source = character,
								DamageType = "Ability",
								KnockbackDirection = direction,
								KnockbackForce = ability.KnockbackForce
							}

							-- This would be handled by the game's damage system
							print(string.format("[Skibidi_Basic] Hit enemy at distance %.1f", distance))
						end
					end
				end
			end

			task.wait()
		end

		-- Clean up effect
		spinEffect:Destroy()
	end)

	return true
end

--[[
	Get character stats with any passive bonuses applied
	@return table - Final stats
--]]
function Skibidi_Basic:GetFinalStats()
	-- For this character, no passive bonuses, just return base stats
	return self.Stats
end

--[[
	Check if player can unlock this character
	@param playerData: table - Player's save data
	@return boolean, string - Can unlock, reason if not
--]]
function Skibidi_Basic:CanUnlock(playerData)
	-- Skibidi_Basic is free and always available
	return true, "Always available"
end

--[[
	Unlock this character for a player
	@param playerData: table - Player's save data
	@return boolean - Whether unlock was successful
--]]
function Skibidi_Basic:UnlockForPlayer(playerData)
	-- Add to owned characters if not already owned
	if not table.find(playerData.Characters.Owned, self.Name) then
		table.insert(playerData.Characters.Owned, self.Name)
		print(string.format("[Skibidi_Basic] Unlocked for player"))
		return true
	end

	return false -- Already owned
end

return Skibidi_Basic
