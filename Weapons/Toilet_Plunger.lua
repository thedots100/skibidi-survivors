--[[
	Toilet_Plunger.lua

	Starting melee weapon for Skibidi_Basic character.
	Simple, reliable close-range weapon.

	Features:
	- Melee range attack
	- Moderate damage and fire rate
	- Easy to use for beginners
	- Upgradeable stats
--]]

local Toilet_Plunger = {
	-- Weapon Information
	Name = "Toilet_Plunger",
	DisplayName = "Toilet Plunger",
	Description = "A trusty plunger for close combat. Simple but effective.",

	-- Weapon Type (uses WeaponFramework system)
	WeaponType = "MELEE",
	FirePattern = "SINGLE",

	-- Base Stats
	Stats = {
		BaseDamage = 15,
		BaseFireRate = 2.0, -- 2 attacks per second
		BaseRange = 8, -- Studs (melee range)
		BaseProjectileSpeed = 0, -- N/A for melee
		BaseProjectileCount = 1,
		BaseProjectileSize = 1.5,
	},

	-- Special Properties
	Special = {
		PierceCount = 0, -- Doesn't pierce
		HomingStrength = 0,
		KnockbackForce = 15, -- Moderate knockback
		CritChance = 0.05, -- 5% crit chance
		CritMultiplier = 2.0,
		LifeSteal = 0, -- No lifesteal
	},

	-- Visual Settings
	Visual = {
		ModelId = nil, -- Set to actual model ID
		ProjectileColor = Color3.fromRGB(150, 100, 50), -- Brown
		ProjectileShape = "Block", -- Block shape for melee swipe
		TrailEnabled = true,
		TrailColor = Color3.fromRGB(150, 100, 50),

		-- Attack animation
		SwipeEffect = true,
		SwipeColor = Color3.fromRGB(200, 200, 200),
		SwipeSize = Vector3.new(8, 1, 8),
	},

	-- Audio
	Audio = {
		AttackSound = "rbxassetid://0", -- Whoosh sound
		HitSound = "rbxassetid://0", -- Thump sound
		Volume = 0.4,
	},

	-- Unlock Requirements
	Unlock = {
		UnlockType = "STARTING", -- Given to Skibidi_Basic
		UnlockCost = 0,
		RequiredLevel = 1,
	},

	-- Upgrade Path
	Upgrades = {
		MaxLevel = 5,
		-- Each level improves stats
		LevelBonuses = {
			{Level = 2, DamageBonus = 5, FireRateBonus = 0.2},
			{Level = 3, DamageBonus = 10, FireRateBonus = 0.4, RangeBonus = 1},
			{Level = 4, DamageBonus = 15, FireRateBonus = 0.6, KnockbackBonus = 5},
			{Level = 5, DamageBonus = 25, FireRateBonus = 1.0, RangeBonus = 2, PierceCount = 1},
		}
	},

	-- Metadata
	Rarity = "COMMON",
	Category = "Melee",
	Tags = {"Melee", "Starter", "Physical"},
}

--[[
	Create weapon configuration for WeaponFramework
	@param player: Player - The player who owns this weapon
	@param upgradeSystem: UpgradeSystem - Reference to upgrade system
	@param weaponLevel: number - Current weapon level (1-5)
	@return table - Configuration for WeaponFramework.new()
--]]
function Toilet_Plunger:GetWeaponConfig(player, upgradeSystem, weaponLevel)
	weaponLevel = weaponLevel or 1

	-- Get level bonuses
	local bonuses = self:GetLevelBonuses(weaponLevel)

	return {
		Name = self.Name,
		WeaponType = self.WeaponType,
		FirePattern = self.FirePattern,

		-- Base stats with level bonuses
		BaseDamage = self.Stats.BaseDamage + bonuses.DamageBonus,
		BaseFireRate = self.Stats.BaseFireRate + bonuses.FireRateBonus,
		BaseRange = self.Stats.BaseRange + bonuses.RangeBonus,
		BaseProjectileSpeed = self.Stats.BaseProjectileSpeed,
		BaseProjectileCount = self.Stats.BaseProjectileCount,
		BaseProjectileSize = self.Stats.BaseProjectileSize,

		-- Special properties
		PierceCount = bonuses.PierceCount,
		HomingStrength = self.Special.HomingStrength,
		KnockbackForce = self.Special.KnockbackForce + bonuses.KnockbackBonus,

		-- Visual
		ProjectileColor = self.Visual.ProjectileColor,
		ProjectileShape = self.Visual.ProjectileShape,
		TrailEnabled = self.Visual.TrailEnabled,

		-- Auto-attack
		AutoAttackEnabled = true,
		TargetingMode = "Nearest",
	}
end

--[[
	Get bonuses for a specific level
	@param level: number - Weapon level
	@return table - Bonuses for that level
--]]
function Toilet_Plunger:GetLevelBonuses(level)
	local bonuses = {
		DamageBonus = 0,
		FireRateBonus = 0,
		RangeBonus = 0,
		KnockbackBonus = 0,
		PierceCount = self.Special.PierceCount,
	}

	-- Apply bonuses for each level up to current level
	for i = 2, level do
		for _, upgrade in ipairs(self.Upgrades.LevelBonuses) do
			if upgrade.Level == i then
				bonuses.DamageBonus = bonuses.DamageBonus + (upgrade.DamageBonus or 0)
				bonuses.FireRateBonus = bonuses.FireRateBonus + (upgrade.FireRateBonus or 0)
				bonuses.RangeBonus = bonuses.RangeBonus + (upgrade.RangeBonus or 0)
				bonuses.KnockbackBonus = bonuses.KnockbackBonus + (upgrade.KnockbackBonus or 0)
				if upgrade.PierceCount then
					bonuses.PierceCount = upgrade.PierceCount
				end
			end
		end
	end

	return bonuses
end

--[[
	Called when weapon is fired (melee attack)
	@param weaponInstance: WeaponFramework - The weapon instance
	@param targetPosition: Vector3 - Target position
--]]
function Toilet_Plunger:OnFire(weaponInstance, targetPosition)
	print(string.format("[Toilet_Plunger] Melee attack!"))

	-- Create visual swipe effect
	if self.Visual.SwipeEffect and weaponInstance.Player.Character then
		local character = weaponInstance.Player.Character
		local rootPart = character:FindFirstChild("HumanoidRootPart")

		if rootPart then
			local swipe = Instance.new("Part")
			swipe.Name = "PlungerSwipe"
			swipe.Size = self.Visual.SwipeSize
			swipe.CFrame = rootPart.CFrame * CFrame.new(0, 0, -4)
			swipe.Anchored = true
			swipe.CanCollide = false
			swipe.Material = Enum.Material.Neon
			swipe.Color = self.Visual.SwipeColor
			swipe.Transparency = 0.5
			swipe.Parent = workspace

			-- Animate swipe
			task.spawn(function()
				for i = 1, 10 do
					swipe.Transparency = 0.5 + (i * 0.05)
					task.wait(0.02)
				end
				swipe:Destroy()
			end)
		end
	end
end

--[[
	Called when weapon hits an enemy
	@param weaponInstance: WeaponFramework - The weapon instance
	@param enemy: Model - The enemy that was hit
	@param damage: number - Damage dealt
--]]
function Toilet_Plunger:OnHit(weaponInstance, enemy, damage)
	-- Simple melee hit, no special effects
	print(string.format("[Toilet_Plunger] Hit enemy for %d damage", damage))
end

--[[
	Get weapon stats display info
	@param level: number - Current weapon level
	@return table - Stats for display
--]]
function Toilet_Plunger:GetStatsDisplay(level)
	level = level or 1
	local bonuses = self:GetLevelBonuses(level)

	return {
		Name = self.DisplayName,
		Description = self.Description,
		Type = self.WeaponType,
		Level = level,
		MaxLevel = self.Upgrades.MaxLevel,

		-- Stats
		Damage = self.Stats.BaseDamage + bonuses.DamageBonus,
		FireRate = self.Stats.BaseFireRate + bonuses.FireRateBonus,
		Range = self.Stats.BaseRange + bonuses.RangeBonus,
		Knockback = self.Special.KnockbackForce + bonuses.KnockbackBonus,
		Pierce = bonuses.PierceCount,

		-- Next level preview
		NextLevelBonuses = self:GetNextLevelInfo(level),
	}
end

--[[
	Get info about next level upgrade
	@param currentLevel: number - Current level
	@return table or nil - Next level info
--]]
function Toilet_Plunger:GetNextLevelInfo(currentLevel)
	if currentLevel >= self.Upgrades.MaxLevel then
		return nil -- Max level
	end

	local nextLevel = currentLevel + 1

	for _, upgrade in ipairs(self.Upgrades.LevelBonuses) do
		if upgrade.Level == nextLevel then
			return {
				Level = nextLevel,
				DamageBonus = upgrade.DamageBonus,
				FireRateBonus = upgrade.FireRateBonus,
				RangeBonus = upgrade.RangeBonus,
				KnockbackBonus = upgrade.KnockbackBonus,
				PierceCount = upgrade.PierceCount,
			}
		end
	end

	return nil
end

return Toilet_Plunger
