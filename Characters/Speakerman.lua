--[[
	Speakerman.lua

	Tanky support character with crowd control abilities.
	Unlockable for 1000 coins (no GamePass option).

	Features:
	- Higher HP, moderate speed (110 HP, 18 speed)
	- "Sound Wave" ability - Pushes and damages enemies in a cone
	- Starting weapon: Speaker Blast (cone AOE)
	- Great for defensive playstyles
--]]

local Speakerman = {
	-- Character Information
	Name = "Speakerman",
	DisplayName = "Speakerman",
	Description = "Master of sound waves. Push back enemies with powerful audio blasts while maintaining solid defenses.",

	-- Unlock Requirements
	UnlockType = "COINS", -- Only coins, no gamepass
	UnlockCost = 1000, -- Coins
	UnlockGamePassId = nil,
	IsStartingCharacter = false,

	-- Base Stats
	Stats = {
		MaxHealth = 110, -- Higher than basic (tank)
		MoveSpeed = 18, -- Moderate speed
		HealthRegen = 1.0, -- Good health regen (1 HP per second)
		PickupRange = 11, -- Standard pickup range
		CritChance = 0.05, -- 5% crit chance (same as basic)
		CritMultiplier = 2.0,
		DamageMultiplier = 1.15, -- 15% bonus damage
		FireRateMultiplier = 0.95, -- 5% slower fire rate (trade-off)
	},

	-- Starting Weapon
	StartingWeapon = "Speaker_Blast",

	-- Character Ability
	Ability = {
		Name = "Sound Wave",
		Description = "Blast enemies in front with a powerful sound wave that pushes and damages",

		-- Ability Properties
		Type = "CONE_AOE", -- Cone-shaped AOE attack
		Cooldown = 6.0, -- Seconds
		Duration = 0.5, -- How long the wave lasts

		-- Ability Stats
		Damage = 40, -- Base damage
		Range = 25, -- Studs (cone length)
		ConeAngle = 60, -- Degrees (total cone angle)
		KnockbackForce = 50, -- Strong knockback
		SlowDuration = 2.0, -- Enemies are slowed after being hit
		SlowAmount = 0.4, -- 60% speed reduction

		-- Visual Settings
		WaveColor = Color3.fromRGB(100, 255, 255), -- Cyan
		WaveTransparency = 0.4,
		WaveSpeed = 50, -- How fast the wave travels
		PulseEffect = true, -- Visual pulse effect

		-- Audio
		SoundId = "rbxassetid://0", -- Bass boost sound
		SoundVolume = 0.8,
		SoundPitch = 0.8, -- Lower pitch for bass
	},

	-- Visual Settings
	Visual = {
		-- Character model appearance
		ModelId = nil, -- Set to actual model ID
		PrimaryColor = Color3.fromRGB(50, 50, 50), -- Dark grey/black
		SecondaryColor = Color3.fromRGB(100, 255, 255), -- Cyan (speakers)
		Scale = 1.05, -- Slightly larger than basic

		-- UI Display
		ThumbnailId = "rbxassetid://0",

		-- Effects
		TrailColor = Color3.fromRGB(100, 255, 255), -- Cyan trail
		TrailEnabled = true,
	},

	-- Character Lore
	Lore = "The Speakerman harnesses sonic energy to devastate enemies. His powerful speakers can knock back entire groups and his reinforced body can withstand heavy damage.",

	-- Metadata
	Rarity = "RARE",
	Category = "Tank",
	Tags = {"Tank", "AOE", "Knockback", "Support"},
	ReleaseDate = "2024-01-01",
}

--[[
	Ability activation function
	Called when player uses their ability
	@param character: Model - The player's character
	@param enemies: table - Array of nearby enemies
	@return boolean - Whether ability activated successfully
--]]
function Speakerman:ActivateAbility(character, enemies)
	if not character or not character:FindFirstChild("HumanoidRootPart") then
		return false
	end

	local rootPart = character.HumanoidRootPart
	local ability = self.Ability

	print(string.format("[Speakerman] Activating ability: %s", ability.Name))

	-- Get forward direction
	local forwardDirection = rootPart.CFrame.LookVector
	local startPosition = rootPart.Position

	-- Create cone visual effect
	local cone = Instance.new("Part")
	cone.Name = "SoundWaveCone"
	cone.Shape = Enum.PartType.Block
	cone.Size = Vector3.new(ability.Range * math.tan(math.rad(ability.ConeAngle / 2)) * 2, 6, ability.Range)
	cone.CFrame = CFrame.new(
		startPosition + forwardDirection * (ability.Range / 2) + Vector3.new(0, 3, 0),
		startPosition + forwardDirection * ability.Range + Vector3.new(0, 3, 0)
	)
	cone.Anchored = true
	cone.CanCollide = false
	cone.Material = Enum.Material.Neon
	cone.Color = ability.WaveColor
	cone.Transparency = ability.WaveTransparency
	cone.Parent = workspace

	-- Add ripple effect
	if ability.PulseEffect then
		local attachment = Instance.new("Attachment")
		attachment.Parent = cone

		-- You would add particle emitters here for visual effects
	end

	-- Track affected enemies
	local affectedEnemies = {}

	-- Wave travel animation
	local startTime = tick()
	local travelDuration = ability.Range / ability.WaveSpeed

	task.spawn(function()
		while (tick() - startTime) < travelDuration do
			local progress = (tick() - startTime) / travelDuration
			local currentDistance = ability.Range * progress

			-- Update cone position (travel forward)
			cone.CFrame = CFrame.new(
				startPosition + forwardDirection * (currentDistance / 2) + Vector3.new(0, 3, 0),
				startPosition + forwardDirection * currentDistance + Vector3.new(0, 3, 0)
			)

			-- Check for enemies in cone
			for _, enemy in ipairs(enemies) do
				if enemy and enemy:IsA("Model") and enemy:FindFirstChild("HumanoidRootPart") then
					local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
					local enemyPosition = enemyRoot.Position

					-- Check if enemy is in cone
					local toEnemy = enemyPosition - startPosition
					local distance = toEnemy.Magnitude
					local angleToEnemy = math.deg(math.acos(forwardDirection:Dot(toEnemy.Unit)))

					-- Enemy is in cone if within distance, angle, and not already hit
					if distance <= currentDistance and
					   angleToEnemy <= (ability.ConeAngle / 2) and
					   not affectedEnemies[enemy] then

						affectedEnemies[enemy] = true

						-- Calculate knockback direction
						local knockbackDir = (enemyPosition - startPosition).Unit

						-- Apply damage and knockback
						local damageData = {
							Enemy = enemy,
							Damage = ability.Damage,
							Source = character,
							Type = "Ability",
							KnockbackDirection = knockbackDir,
							KnockbackForce = ability.KnockbackForce,
							SlowDuration = ability.SlowDuration,
							SlowAmount = ability.SlowAmount
						}

						print(string.format("[Speakerman] Hit enemy in cone (distance: %.1f, angle: %.1f)",
							distance, angleToEnemy))

						-- This would be handled by the game's damage system
					end
				end
			end

			task.wait()
		end

		-- Fade out and clean up
		for i = 1, 10 do
			cone.Transparency = cone.Transparency + 0.06
			task.wait(0.02)
		end

		cone:Destroy()
	end)

	return true
end

--[[
	Get character stats with any passive bonuses applied
	@return table - Final stats
--]]
function Speakerman:GetFinalStats()
	local stats = {}
	for key, value in pairs(self.Stats) do
		stats[key] = value
	end

	-- Passive: Reduce incoming knockback by 30%
	stats.KnockbackResistance = 0.3

	-- Passive: Deal 20% more damage to slowed enemies
	stats.BonusDamageToSlowed = 1.2

	return stats
end

--[[
	Check if player can unlock this character
	@param playerData: table - Player's save data
	@return boolean, string - Can unlock, reason if not
--]]
function Speakerman:CanUnlock(playerData)
	-- Check if already owned
	if table.find(playerData.Characters.Owned, self.Name) then
		return false, "Already owned"
	end

	-- Check if player has enough coins
	if playerData.Coins >= self.UnlockCost then
		return true, "Can purchase with coins"
	end

	return false, string.format("Need %d coins", self.UnlockCost)
end

--[[
	Unlock this character for a player
	@param playerData: table - Player's save data
	@return boolean, string - Success, message
--]]
function Speakerman:UnlockForPlayer(playerData)
	-- Check if can unlock
	local canUnlock, reason = self:CanUnlock(playerData)
	if not canUnlock then
		return false, reason
	end

	-- Add to owned characters
	table.insert(playerData.Characters.Owned, self.Name)

	-- Deduct coins
	playerData.Coins = playerData.Coins - self.UnlockCost

	print(string.format("[Speakerman] Unlocked for %d coins", self.UnlockCost))
	return true, string.format("Unlocked for %d coins!", self.UnlockCost)
end

return Speakerman
