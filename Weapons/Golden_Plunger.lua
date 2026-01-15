--[[
	Golden_Plunger.lua

	Premium melee weapon unlocked via GamePass.
	Enhanced version of Toilet Plunger with bonus stats and critical hits.

	Features:
	- Higher damage than basic plunger
	- Built-in +10% crit chance
	- Golden visual effects
	- Premium weapon
--]]

local Golden_Plunger = {
	-- Weapon Information
	Name = "Golden_Plunger",
	DisplayName = "Golden Plunger",
	Description = "A legendary golden plunger. Deals massive damage with increased critical hit chance!",

	-- Weapon Type
	WeaponType = "MELEE",
	FirePattern = "SINGLE",

	-- Base Stats (better than Toilet_Plunger)
	Stats = {
		BaseDamage = 25, -- Much higher base damage
		BaseFireRate = 2.5, -- Slightly faster
		BaseRange = 10, -- Longer range
		BaseProjectileSpeed = 0,
		BaseProjectileCount = 1,
		BaseProjectileSize = 2.0, -- Larger hit area
	},

	-- Special Properties
	Special = {
		PierceCount = 1, -- Starts with pierce
		HomingStrength = 0,
		KnockbackForce = 20, -- Higher knockback
		CritChance = 0.15, -- 15% crit chance (3x normal)
		CritMultiplier = 2.5, -- 2.5x damage on crit
		LifeSteal = 0.05, -- 5% lifesteal
		GoldBonus = 1.1, -- 10% more coins from enemies
	},

	-- Visual Settings
	Visual = {
		ModelId = nil,
		ProjectileColor = Color3.fromRGB(255, 215, 0), -- Gold
		ProjectileShape = "Block",
		TrailEnabled = true,
		TrailColor = Color3.fromRGB(255, 215, 0),

		-- Attack animation
		SwipeEffect = true,
		SwipeColor = Color3.fromRGB(255, 230, 100),
		SwipeSize = Vector3.new(10, 1.5, 10),
		GoldenGlow = true,
	},

	-- Audio
	Audio = {
		AttackSound = "rbxassetid://0", -- Epic whoosh
		HitSound = "rbxassetid://0", -- Satisfying impact
		CritSound = "rbxassetid://0", -- Special crit sound
		Volume = 0.5,
	},

	-- Unlock Requirements
	Unlock = {
		UnlockType = "GAMEPASS",
		GamePassId = 0, -- Set to actual GamePass ID
		UnlockCost = 0,
		RequiredLevel = 1,
	},

	-- Upgrade Path
	Upgrades = {
		MaxLevel = 5,
		LevelBonuses = {
			{Level = 2, DamageBonus = 8, FireRateBonus = 0.3, CritChanceBonus = 0.02},
			{Level = 3, DamageBonus = 16, FireRateBonus = 0.6, RangeBonus = 1, PierceCount = 2},
			{Level = 4, DamageBonus = 25, FireRateBonus = 1.0, CritChanceBonus = 0.05, LifeSteal = 0.02},
			{Level = 5, DamageBonus = 40, FireRateBonus = 1.5, RangeBonus = 2, PierceCount = 3, CritMultiplier = 0.5},
		}
	},

	-- Metadata
	Rarity = "LEGENDARY",
	Category = "Melee",
	Tags = {"Melee", "Premium", "Critical", "Lifesteal"},
}

--[[
	Create weapon configuration for WeaponFramework
--]]
function Golden_Plunger:GetWeaponConfig(player, upgradeSystem, weaponLevel)
	weaponLevel = weaponLevel or 1
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
		KnockbackForce = self.Special.KnockbackForce,
		CritChance = self.Special.CritChance + bonuses.CritChanceBonus,
		CritMultiplier = self.Special.CritMultiplier + bonuses.CritMultiplierBonus,
		LifeSteal = self.Special.LifeSteal + bonuses.LifeStealBonus,

		-- Visual
		ProjectileColor = self.Visual.ProjectileColor,
		ProjectileShape = self.Visual.ProjectileShape,
		TrailEnabled = self.Visual.TrailEnabled,

		-- Auto-attack
		AutoAttackEnabled = true,
		TargetingMode = "Nearest",

		-- Premium bonuses
		GoldBonus = self.Special.GoldBonus,
	}
end

--[[
	Get bonuses for a specific level
--]]
function Golden_Plunger:GetLevelBonuses(level)
	local bonuses = {
		DamageBonus = 0,
		FireRateBonus = 0,
		RangeBonus = 0,
		PierceCount = self.Special.PierceCount,
		CritChanceBonus = 0,
		CritMultiplierBonus = 0,
		LifeStealBonus = 0,
	}

	for i = 2, level do
		for _, upgrade in ipairs(self.Upgrades.LevelBonuses) do
			if upgrade.Level == i then
				bonuses.DamageBonus = bonuses.DamageBonus + (upgrade.DamageBonus or 0)
				bonuses.FireRateBonus = bonuses.FireRateBonus + (upgrade.FireRateBonus or 0)
				bonuses.RangeBonus = bonuses.RangeBonus + (upgrade.RangeBonus or 0)
				bonuses.CritChanceBonus = bonuses.CritChanceBonus + (upgrade.CritChanceBonus or 0)
				bonuses.CritMultiplierBonus = bonuses.CritMultiplierBonus + (upgrade.CritMultiplier or 0)
				bonuses.LifeStealBonus = bonuses.LifeStealBonus + (upgrade.LifeSteal or 0)

				if upgrade.PierceCount then
					bonuses.PierceCount = upgrade.PierceCount
				end
			end
		end
	end

	return bonuses
end

--[[
	Called when weapon is fired
--]]
function Golden_Plunger:OnFire(weaponInstance, targetPosition)
	print(string.format("[Golden_Plunger] Golden strike!"))

	-- Create enhanced golden swipe effect
	if self.Visual.SwipeEffect and weaponInstance.Player.Character then
		local character = weaponInstance.Player.Character
		local rootPart = character:FindFirstChild("HumanoidRootPart")

		if rootPart then
			local swipe = Instance.new("Part")
			swipe.Name = "GoldenSwipe"
			swipe.Size = self.Visual.SwipeSize
			swipe.CFrame = rootPart.CFrame * CFrame.new(0, 0, -5)
			swipe.Anchored = true
			swipe.CanCollide = false
			swipe.Material = Enum.Material.Neon
			swipe.Color = self.Visual.SwipeColor
			swipe.Transparency = 0.3
			swipe.Parent = workspace

			-- Add golden glow
			if self.Visual.GoldenGlow then
				local light = Instance.new("PointLight")
				light.Brightness = 3
				light.Color = self.Visual.ProjectileColor
				light.Range = 15
				light.Parent = swipe
			end

			-- Animate swipe with particles
			task.spawn(function()
				for i = 1, 12 do
					swipe.Transparency = 0.3 + (i * 0.06)
					swipe.Size = self.Visual.SwipeSize * (1 + i * 0.05)
					task.wait(0.02)
				end
				swipe:Destroy()
			end)
		end
	end
end

--[[
	Called when weapon hits an enemy
--]]
function Golden_Plunger:OnHit(weaponInstance, enemy, damage, isCrit)
	-- Check if this was a critical hit
	local wasCrit = isCrit or (math.random() <= (self.Special.CritChance + self:GetLevelBonuses(weaponInstance.Level or 1).CritChanceBonus))

	if wasCrit then
		print(string.format("[Golden_Plunger] CRITICAL HIT for %d damage!", damage))

		-- Enhanced crit effect
		if enemy and enemy:FindFirstChild("HumanoidRootPart") then
			local critEffect = Instance.new("Part")
			critEffect.Name = "CritEffect"
			critEffect.Shape = Enum.PartType.Ball
			critEffect.Size = Vector3.new(5, 5, 5)
			critEffect.CFrame = enemy.HumanoidRootPart.CFrame
			critEffect.Anchored = true
			critEffect.CanCollide = false
			critEffect.Material = Enum.Material.Neon
			critEffect.Color = Color3.fromRGB(255, 100, 100)
			critEffect.Transparency = 0.2
			critEffect.Parent = workspace

			-- Add sparkles
			local sparkles = Instance.new("Sparkles")
			sparkles.SparkleColor = Color3.fromRGB(255, 215, 0)
			sparkles.Parent = critEffect

			-- Explode effect
			task.spawn(function()
				for i = 1, 10 do
					critEffect.Size = Vector3.new(5 + i * 2, 5 + i * 2, 5 + i * 2)
					critEffect.Transparency = 0.2 + (i * 0.08)
					task.wait(0.03)
				end
				critEffect:Destroy()
			end)
		end
	else
		print(string.format("[Golden_Plunger] Hit enemy for %d damage", damage))

		-- Normal golden hit effect
		if enemy and enemy:FindFirstChild("HumanoidRootPart") then
			local hitEffect = Instance.new("Part")
			hitEffect.Name = "GoldenHit"
			hitEffect.Shape = Enum.PartType.Ball
			hitEffect.Size = Vector3.new(3, 3, 3)
			hitEffect.CFrame = enemy.HumanoidRootPart.CFrame
			hitEffect.Anchored = true
			hitEffect.CanCollide = false
			hitEffect.Material = Enum.Material.Neon
			hitEffect.Color = self.Visual.ProjectileColor
			hitEffect.Transparency = 0.4
			hitEffect.Parent = workspace

			task.spawn(function()
				for i = 1, 8 do
					hitEffect.Transparency = 0.4 + (i * 0.075)
					task.wait(0.02)
				end
				hitEffect:Destroy()
			end)
		end
	end

	-- Apply lifesteal (would be handled by combat system)
	local lifesteal = self.Special.LifeSteal + self:GetLevelBonuses(weaponInstance.Level or 1).LifeStealBonus
	if lifesteal > 0 then
		local healAmount = damage * lifesteal
		-- Heal player (handled externally)
		print(string.format("[Golden_Plunger] Lifesteal: +%.1f HP", healAmount))
	end
end

--[[
	Get weapon stats display info
--]]
function Golden_Plunger:GetStatsDisplay(level)
	level = level or 1
	local bonuses = self:GetLevelBonuses(level)

	return {
		Name = self.DisplayName,
		Description = self.Description,
		Type = self.WeaponType,
		Level = level,
		MaxLevel = self.Upgrades.MaxLevel,
		Rarity = self.Rarity,

		-- Stats
		Damage = self.Stats.BaseDamage + bonuses.DamageBonus,
		FireRate = self.Stats.BaseFireRate + bonuses.FireRateBonus,
		Range = self.Stats.BaseRange + bonuses.RangeBonus,
		Pierce = bonuses.PierceCount,
		CritChance = math.floor((self.Special.CritChance + bonuses.CritChanceBonus) * 100) .. "%",
		CritMultiplier = string.format("%.1fx", self.Special.CritMultiplier + bonuses.CritMultiplierBonus),
		LifeSteal = math.floor((self.Special.LifeSteal + bonuses.LifeStealBonus) * 100) .. "%",
		GoldBonus = "+10%",

		-- Next level preview
		NextLevelBonuses = self:GetNextLevelInfo(level),
	}
end

--[[
	Get info about next level upgrade
--]]
function Golden_Plunger:GetNextLevelInfo(currentLevel)
	if currentLevel >= self.Upgrades.MaxLevel then
		return nil
	end

	local nextLevel = currentLevel + 1

	for _, upgrade in ipairs(self.Upgrades.LevelBonuses) do
		if upgrade.Level == nextLevel then
			return {
				Level = nextLevel,
				DamageBonus = upgrade.DamageBonus,
				FireRateBonus = upgrade.FireRateBonus,
				RangeBonus = upgrade.RangeBonus,
				PierceCount = upgrade.PierceCount,
				CritChanceBonus = upgrade.CritChanceBonus,
				CritMultiplier = upgrade.CritMultiplier,
				LifeSteal = upgrade.LifeSteal,
			}
		end
	end

	return nil
end

return Golden_Plunger
