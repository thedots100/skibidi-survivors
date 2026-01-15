--[[
	Speaker_Blast.lua

	Starting weapon for Speakerman character.
	Fires a cone of sound wave projectiles.

	Features:
	- Cone AOE attack pattern
	- Medium damage, good coverage
	- Pushes enemies back
	- Upgrades to wider cone and more projectiles
--]]

local Speaker_Blast = {
	-- Weapon Information
	Name = "Speaker_Blast",
	DisplayName = "Speaker Blast",
	Description = "Fires a spread of sonic projectiles in a cone. Great for crowd control.",

	-- Weapon Type
	WeaponType = "AOE",
	FirePattern = "SPREAD",

	-- Base Stats
	Stats = {
		BaseDamage = 10,
		BaseFireRate = 1.5, -- 1.5 shots per second
		BaseRange = 20, -- Studs
		BaseProjectileSpeed = 35, -- Studs per second
		BaseProjectileCount = 3, -- 3 projectiles in spread
		BaseProjectileSize = 1.5,
	},

	-- Special Properties
	Special = {
		PierceCount = 1, -- Pierces 1 enemy
		HomingStrength = 0,
		SpreadAngle = 30, -- Degrees
		KnockbackForce = 20, -- Good knockback
		SlowAmount = 0.3, -- Slows enemies by 30% for 2 seconds
		SlowDuration = 2.0,
	},

	-- Visual Settings
	Visual = {
		ModelId = nil,
		ProjectileColor = Color3.fromRGB(100, 255, 255), -- Cyan
		ProjectileShape = "Cylinder", -- Sound wave shape
		TrailEnabled = true,
		TrailColor = Color3.fromRGB(100, 255, 255),
		WaveEffect = true,
	},

	-- Audio
	Audio = {
		AttackSound = "rbxassetid://0", -- Bass sound
		HitSound = "rbxassetid://0",
		Volume = 0.5,
		Pitch = 0.8, -- Lower pitch
	},

	-- Unlock Requirements
	Unlock = {
		UnlockType = "STARTING", -- Given to Speakerman
		UnlockCost = 0,
		RequiredLevel = 1,
	},

	-- Upgrade Path
	Upgrades = {
		MaxLevel = 5,
		LevelBonuses = {
			{Level = 2, DamageBonus = 3, ProjectileCount = 4, SpreadAngle = 35},
			{Level = 3, DamageBonus = 6, FireRateBonus = 0.3, ProjectileCount = 5, PierceCount = 2},
			{Level = 4, DamageBonus = 10, FireRateBonus = 0.5, SpreadAngle = 45, KnockbackBonus = 10},
			{Level = 5, DamageBonus = 15, FireRateBonus = 0.8, ProjectileCount = 7, PierceCount = 3, SpreadAngle = 60},
		}
	},

	-- Metadata
	Rarity = "UNCOMMON",
	Category = "AOE",
	Tags = {"AOE", "Spread", "Knockback", "Slow"},
}

--[[
	Create weapon configuration for WeaponFramework
--]]
function Speaker_Blast:GetWeaponConfig(player, upgradeSystem, weaponLevel)
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
		HomingStrength = self.Special.HomingStrength,
		SpreadAngle = bonuses.SpreadAngle,
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
--]]
function Speaker_Blast:GetLevelBonuses(level)
	local bonuses = {
		DamageBonus = 0,
		FireRateBonus = 0,
		ProjectileCount = self.Stats.BaseProjectileCount,
		PierceCount = self.Special.PierceCount,
		SpreadAngle = self.Special.SpreadAngle,
		KnockbackBonus = 0,
	}

	for i = 2, level do
		for _, upgrade in ipairs(self.Upgrades.LevelBonuses) do
			if upgrade.Level == i then
				bonuses.DamageBonus = bonuses.DamageBonus + (upgrade.DamageBonus or 0)
				bonuses.FireRateBonus = bonuses.FireRateBonus + (upgrade.FireRateBonus or 0)
				bonuses.KnockbackBonus = bonuses.KnockbackBonus + (upgrade.KnockbackBonus or 0)

				if upgrade.ProjectileCount then
					bonuses.ProjectileCount = upgrade.ProjectileCount
				end
				if upgrade.PierceCount then
					bonuses.PierceCount = upgrade.PierceCount
				end
				if upgrade.SpreadAngle then
					bonuses.SpreadAngle = upgrade.SpreadAngle
				end
			end
		end
	end

	return bonuses
end

--[[
	Called when weapon is fired
--]]
function Speaker_Blast:OnFire(weaponInstance, targetPosition)
	print(string.format("[Speaker_Blast] Sonic blast fired!"))

	-- Create visual wave effect at origin
	if weaponInstance.Player.Character then
		local character = weaponInstance.Player.Character
		local rootPart = character:FindFirstChild("HumanoidRootPart")

		if rootPart then
			-- Create expanding ring effect
			local wave = Instance.new("Part")
			wave.Name = "SonicWave"
			wave.Shape = Enum.PartType.Cylinder
			wave.Size = Vector3.new(0.5, 10, 10)
			wave.CFrame = rootPart.CFrame * CFrame.Angles(0, 0, math.rad(90))
			wave.Anchored = true
			wave.CanCollide = false
			wave.Material = Enum.Material.Neon
			wave.Color = self.Visual.ProjectileColor
			wave.Transparency = 0.5
			wave.Parent = workspace

			-- Expand and fade
			task.spawn(function()
				for i = 1, 10 do
					wave.Size = Vector3.new(0.5, 10 + i * 2, 10 + i * 2)
					wave.Transparency = 0.5 + (i * 0.05)
					task.wait(0.03)
				end
				wave:Destroy()
			end)
		end
	end
end

--[[
	Called when projectile hits an enemy
--]]
function Speaker_Blast:OnHit(weaponInstance, enemy, damage)
	print(string.format("[Speaker_Blast] Hit enemy for %d damage with sonic blast", damage))

	-- Apply slow effect
	if enemy and enemy:FindFirstChild("HumanoidRootPart") then
		-- Create hit effect
		local hitWave = Instance.new("Part")
		hitWave.Name = "HitWave"
		hitWave.Shape = Enum.PartType.Ball
		hitWave.Size = Vector3.new(2, 2, 2)
		hitWave.CFrame = enemy.HumanoidRootPart.CFrame
		hitWave.Anchored = true
		hitWave.CanCollide = false
		hitWave.Material = Enum.Material.Neon
		hitWave.Color = self.Visual.ProjectileColor
		hitWave.Transparency = 0.3
		hitWave.Parent = workspace

		-- Expand and fade
		task.spawn(function()
			for i = 1, 8 do
				hitWave.Size = Vector3.new(2 + i, 2 + i, 2 + i)
				hitWave.Transparency = 0.3 + (i * 0.085)
				task.wait(0.02)
			end
			hitWave:Destroy()
		end)

		-- Apply slow debuff (handled by game's buff system)
		local slowData = {
			Enemy = enemy,
			SlowAmount = self.Special.SlowAmount,
			Duration = self.Special.SlowDuration,
			Source = weaponInstance
		}
	end
end

--[[
	Get weapon stats display info
--]]
function Speaker_Blast:GetStatsDisplay(level)
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
		SpreadAngle = bonuses.SpreadAngle,
		Pierce = bonuses.PierceCount,
		Knockback = self.Special.KnockbackForce + bonuses.KnockbackBonus,
		Slow = math.floor(self.Special.SlowAmount * 100) .. "%",

		-- Next level preview
		NextLevelBonuses = self:GetNextLevelInfo(level),
	}
end

--[[
	Get info about next level upgrade
--]]
function Speaker_Blast:GetNextLevelInfo(currentLevel)
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
				SpreadAngle = upgrade.SpreadAngle,
				PierceCount = upgrade.PierceCount,
				KnockbackBonus = upgrade.KnockbackBonus,
			}
		end
	end

	return nil
end

return Speaker_Blast
