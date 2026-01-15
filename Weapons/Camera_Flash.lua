--[[
	Camera_Flash.lua

	Starting ranged weapon for Cameraman character.
	Shoots fast projectiles at enemies.

	Features:
	- Ranged projectile attack
	- Fast fire rate
	- Good for kiting
	- Upgradeable for multi-shot
--]]

local Camera_Flash = {
	-- Weapon Information
	Name = "Camera_Flash",
	DisplayName = "Camera Flash",
	Description = "Shoots bright flash projectiles at enemies. Quick and reliable.",

	-- Weapon Type
	WeaponType = "PROJECTILE",
	FirePattern = "SINGLE",

	-- Base Stats
	Stats = {
		BaseDamage = 12,
		BaseFireRate = 3.0, -- 3 shots per second
		BaseRange = 40, -- Studs
		BaseProjectileSpeed = 50, -- Studs per second
		BaseProjectileCount = 1,
		BaseProjectileSize = 1.0,
	},

	-- Special Properties
	Special = {
		PierceCount = 0,
		HomingStrength = 0.1, -- Slight homing
		KnockbackForce = 5,
		CritChance = 0.10, -- 10% crit chance (higher than melee)
		CritMultiplier = 2.0,
	},

	-- Visual Settings
	Visual = {
		ModelId = nil,
		ProjectileColor = Color3.fromRGB(255, 255, 220), -- Bright yellow-white
		ProjectileShape = "Ball",
		TrailEnabled = true,
		TrailColor = Color3.fromRGB(255, 255, 150),
		GlowEffect = true,
	},

	-- Audio
	Audio = {
		AttackSound = "rbxassetid://0", -- Camera flash sound
		HitSound = "rbxassetid://0",
		Volume = 0.3,
		Pitch = 1.2,
	},

	-- Unlock Requirements
	Unlock = {
		UnlockType = "STARTING", -- Given to Cameraman
		UnlockCost = 0,
		RequiredLevel = 1,
	},

	-- Upgrade Path
	Upgrades = {
		MaxLevel = 5,
		LevelBonuses = {
			{Level = 2, DamageBonus = 3, FireRateBonus = 0.3},
			{Level = 3, DamageBonus = 6, FireRateBonus = 0.6, ProjectileCount = 2},
			{Level = 4, DamageBonus = 10, FireRateBonus = 1.0, HomingBonus = 0.1, PierceCount = 1},
			{Level = 5, DamageBonus = 15, FireRateBonus = 1.5, ProjectileCount = 3, HomingBonus = 0.2},
		}
	},

	-- Metadata
	Rarity = "COMMON",
	Category = "Ranged",
	Tags = {"Ranged", "Projectile", "Fast"},
}

--[[
	Create weapon configuration for WeaponFramework
--]]
function Camera_Flash:GetWeaponConfig(player, upgradeSystem, weaponLevel)
	weaponLevel = weaponLevel or 1
	local bonuses = self:GetLevelBonuses(weaponLevel)

	return {
		Name = self.Name,
		WeaponType = self.WeaponType,
		FirePattern = self.FirePattern,

		-- Base stats with level bonuses
		BaseDamage = self.Stats.BaseDamage + bonuses.DamageBonus,
		BaseFireRate = self.Stats.BaseFireRate + bonuses.FireRateBonus,
		BaseRange = self.Stats.BaseRange,
		BaseProjectileSpeed = self.Stats.BaseProjectileSpeed,
		BaseProjectileCount = bonuses.ProjectileCount,
		BaseProjectileSize = self.Stats.BaseProjectileSize,

		-- Special properties
		PierceCount = bonuses.PierceCount,
		HomingStrength = self.Special.HomingStrength + bonuses.HomingBonus,
		KnockbackForce = self.Special.KnockbackForce,

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
--]]
function Camera_Flash:GetLevelBonuses(level)
	local bonuses = {
		DamageBonus = 0,
		FireRateBonus = 0,
		ProjectileCount = self.Stats.BaseProjectileCount,
		HomingBonus = 0,
		PierceCount = self.Special.PierceCount,
	}

	for i = 2, level do
		for _, upgrade in ipairs(self.Upgrades.LevelBonuses) do
			if upgrade.Level == i then
				bonuses.DamageBonus = bonuses.DamageBonus + (upgrade.DamageBonus or 0)
				bonuses.FireRateBonus = bonuses.FireRateBonus + (upgrade.FireRateBonus or 0)
				bonuses.HomingBonus = bonuses.HomingBonus + (upgrade.HomingBonus or 0)

				if upgrade.ProjectileCount then
					bonuses.ProjectileCount = upgrade.ProjectileCount
				end
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
function Camera_Flash:OnFire(weaponInstance, targetPosition)
	print(string.format("[Camera_Flash] Shot fired!"))

	-- Add muzzle flash effect
	if weaponInstance.Player.Character then
		local character = weaponInstance.Player.Character
		local rootPart = character:FindFirstChild("HumanoidRootPart")

		if rootPart then
			-- Create flash effect at firing position
			local flash = Instance.new("Part")
			flash.Name = "MuzzleFlash"
			flash.Shape = Enum.PartType.Ball
			flash.Size = Vector3.new(2, 2, 2)
			flash.CFrame = rootPart.CFrame * CFrame.new(0, 2, -3)
			flash.Anchored = true
			flash.CanCollide = false
			flash.Material = Enum.Material.Neon
			flash.Color = self.Visual.ProjectileColor
			flash.Transparency = 0.3
			flash.Parent = workspace

			-- Add point light
			local light = Instance.new("PointLight")
			light.Brightness = 5
			light.Color = self.Visual.ProjectileColor
			light.Range = 15
			light.Parent = flash

			-- Quick fade out
			task.spawn(function()
				for i = 1, 5 do
					flash.Size = flash.Size * 1.2
					flash.Transparency = 0.3 + (i * 0.14)
					light.Brightness = 5 - i
					task.wait(0.02)
				end
				flash:Destroy()
			end)
		end
	end
end

--[[
	Called when projectile hits an enemy
--]]
function Camera_Flash:OnHit(weaponInstance, enemy, damage)
	print(string.format("[Camera_Flash] Hit enemy for %d damage", damage))

	-- Create hit flash effect
	if enemy and enemy:FindFirstChild("HumanoidRootPart") then
		local hitFlash = Instance.new("Part")
		hitFlash.Name = "HitFlash"
		hitFlash.Shape = Enum.PartType.Ball
		hitFlash.Size = Vector3.new(3, 3, 3)
		hitFlash.CFrame = enemy.HumanoidRootPart.CFrame
		hitFlash.Anchored = true
		hitFlash.CanCollide = false
		hitFlash.Material = Enum.Material.Neon
		hitFlash.Color = Color3.fromRGB(255, 255, 100)
		hitFlash.Transparency = 0.4
		hitFlash.Parent = workspace

		-- Fade out
		task.spawn(function()
			for i = 1, 8 do
				hitFlash.Transparency = 0.4 + (i * 0.075)
				task.wait(0.02)
			end
			hitFlash:Destroy()
		end)
	end
end

--[[
	Get weapon stats display info
--]]
function Camera_Flash:GetStatsDisplay(level)
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
		Range = self.Stats.BaseRange,
		ProjectileCount = bonuses.ProjectileCount,
		Homing = math.floor((self.Special.HomingStrength + bonuses.HomingBonus) * 100),
		Pierce = bonuses.PierceCount,

		-- Next level preview
		NextLevelBonuses = self:GetNextLevelInfo(level),
	}
end

--[[
	Get info about next level upgrade
--]]
function Camera_Flash:GetNextLevelInfo(currentLevel)
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
				ProjectileCount = upgrade.ProjectileCount,
				HomingBonus = upgrade.HomingBonus,
				PierceCount = upgrade.PierceCount,
			}
		end
	end

	return nil
end

return Camera_Flash
