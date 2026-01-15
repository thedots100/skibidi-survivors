--[[
	Boss_Titan.lua

	Boss enemy that spawns every 5 waves.
	Challenging fight with multiple phases and abilities.

	Features:
	- Very high health
	- Multiple attack patterns
	- Spawns minions
	- Phase changes at health thresholds
	- Big rewards
--]]

local Boss_Titan = {
	-- Enemy Information
	Name = "Titan Skibidi",
	DisplayName = "Titan Skibidi",
	Description = "A massive boss toilet. Extremely dangerous with devastating attacks and the ability to spawn minions.",

	-- Enemy Type
	EnemyType = "TANK", -- Boss is tank-type

	-- Base Stats
	Stats = {
		MaxHealth = 500, -- Very high health
		MoveSpeed = 14, -- Moderate speed for a boss
		Damage = 30, -- High damage
		AttackRange = 10, -- Large reach
		AttackCooldown = 3.0, -- Time between attacks
		DetectionRange = 150, -- Large detection range
	},

	-- Boss Properties
	Boss = {
		IsBoss = true,
		SpawnInterval = 5, -- Spawns every 5 waves
		MinionSpawnCooldown = 15.0, -- Spawns minions every 15 seconds
		MinionTypes = {"Zombie_Toilet", "FastRunner"}, -- Types of minions to spawn
		MinionCount = {Min = 3, Max = 5}, -- Number of minions per spawn

		-- Phase system
		Phases = {
			{HealthPercent = 1.0, Name = "Phase 1", SpeedMultiplier = 1.0, DamageMultiplier = 1.0},
			{HealthPercent = 0.66, Name = "Phase 2", SpeedMultiplier = 1.2, DamageMultiplier = 1.3},
			{HealthPercent = 0.33, Name = "Phase 3", SpeedMultiplier = 1.4, DamageMultiplier = 1.6},
		},
		CurrentPhase = 1,
	},

	-- Special Attacks
	SpecialAttacks = {
		-- Ground Slam
		GroundSlam = {
			Name = "Ground Slam",
			Cooldown = 10.0,
			Damage = 40,
			Radius = 20,
			KnockbackForce = 60,
			StunDuration = 1.5,
			WindupTime = 1.0,
		},

		-- Spin Attack
		SpinAttack = {
			Name = "Titan Spin",
			Cooldown = 12.0,
			Damage = 25,
			Radius = 15,
			Duration = 3.0,
			TickInterval = 0.5,
		},

		-- Charge Attack
		Charge = {
			Name = "Devastating Charge",
			Cooldown = 15.0,
			Damage = 50,
			Speed = 30,
			Duration = 2.0,
			Width = 8,
		},
	},

	-- Rewards
	Rewards = {
		XPDropAmount = 100, -- Massive XP
		XPDropChance = 1.0,
		CoinsDropChance = 1.0, -- Always drops coins
		CoinsDropAmount = {Min = 20, Max = 50},
	},

	-- Combat Properties
	Combat = {
		KnockbackResistance = 0.9, -- Very resistant to knockback
		AttackWindup = 0.6,
		AttackType = "BOSS_MELEE",
		StatusEffectResistance = 0.7, -- 70% resistance to debuffs
		Armor = 10, -- Reduces damage by 10
		SuperArmor = true, -- Cannot be stunned during attacks
	},

	-- Visual Settings
	Visual = {
		ModelId = nil,
		PrimaryColor = Color3.fromRGB(50, 50, 50), -- Very dark grey
		SecondaryColor = Color3.fromRGB(255, 50, 50), -- Red (boss color)
		Scale = 2.0, -- Twice the size of basic enemies
		Size = Vector3.new(10, 14, 5),

		-- Effects
		TrailEnabled = true,
		TrailColor = Color3.fromRGB(255, 50, 50),
		DeathEffectColor = Color3.fromRGB(255, 50, 50),
		HitEffectColor = Color3.fromRGB(255, 200, 100),
		BossAura = true, -- Glowing aura effect
	},

	-- Audio
	Audio = {
		SpawnSound = "rbxassetid://0", -- Epic boss spawn sound
		AttackSound = "rbxassetid://0",
		HitSound = "rbxassetid://0",
		DeathSound = "rbxassetid://0", -- Epic explosion
		BossMusic = "rbxassetid://0", -- Boss battle music
		Volume = 0.8,
		Pitch = 0.6, -- Very low pitch
	},

	-- Spawning
	Spawn = {
		Weight = 0, -- Doesn't use normal spawn system
		MinWave = 5, -- First boss at wave 5
		SpawnAnimation = "BossDrop", -- Epic entrance
		SpawnMessage = "BOSS: TITAN SKIBIDI HAS APPEARED!",
	},

	-- Behavior
	Behavior = {
		AggroRange = 150,
		WanderWhenIdle = false,
		PreferredDistance = 0,
		FleeAtHealthPercent = 0, -- Never flees
		EnrageAtHealthPercent = 0.2, -- Enrages at 20% health
		AlwaysAggro = true, -- Always aggressive
	},

	-- Metadata
	Difficulty = "BOSS",
	Category = "Boss",
	Tags = {"Boss", "Tank", "Summoner", "Multi-Phase"},
}

--[[
	Create enemy configuration for EnemyAI system
--]]
function Boss_Titan:GetEnemyConfig(waveNumber, difficultyMultiplier)
	waveNumber = waveNumber or 5
	difficultyMultiplier = difficultyMultiplier or 1.0

	-- Boss scaling is more dramatic
	local bossScaling = difficultyMultiplier * (1 + (waveNumber * 0.15))

	return {
		Name = self.Name,
		EnemyType = self.EnemyType,

		-- Scaled stats
		MaxHealth = math.floor(self.Stats.MaxHealth * bossScaling),
		MoveSpeed = self.Stats.MoveSpeed * self.Boss.Phases[self.Boss.CurrentPhase].SpeedMultiplier,
		Damage = math.floor(self.Stats.Damage * difficultyMultiplier * self.Boss.Phases[self.Boss.CurrentPhase].DamageMultiplier),
		AttackRange = self.Stats.AttackRange,
		AttackCooldown = self.Stats.AttackCooldown,
		DetectionRange = self.Stats.DetectionRange,

		-- Rewards
		XPDropAmount = self.Rewards.XPDropAmount + math.floor(waveNumber * 10),
		XPDropChance = self.Rewards.XPDropChance,

		-- Visual
		Color = self.Visual.PrimaryColor,
		Size = self.Visual.Size,

		-- Special properties
		KnockbackResistance = self.Combat.KnockbackResistance,
		CanFly = false,
		AggroRange = self.Behavior.AggroRange,
		Armor = self.Combat.Armor,
		IsBoss = true,
	}
end

--[[
	Check if boss should spawn this wave
--]]
function Boss_Titan:ShouldSpawnThisWave(waveNumber)
	return waveNumber >= self.Spawn.MinWave and (waveNumber % self.Boss.SpawnInterval == 0)
end

--[[
	Called when boss is spawned
--]]
function Boss_Titan:OnSpawn(enemyModel, enemyAI)
	print(string.format("[Boss_Titan] BOSS SPAWNED at wave %d!", enemyAI.WaveNumber or 0))

	-- Store boss-specific data
	enemyAI.IsBoss = true
	enemyAI.LastMinionSpawn = 0
	enemyAI.LastGroundSlam = 0
	enemyAI.LastSpinAttack = 0
	enemyAI.LastCharge = 0
	enemyAI.CurrentPhase = 1
	enemyAI.IsEnraged = false

	-- Add boss aura effect
	if self.Visual.BossAura and enemyModel.PrimaryPart then
		local aura = Instance.new("Part")
		aura.Name = "BossAura"
		aura.Shape = Enum.PartType.Ball
		aura.Size = Vector3.new(20, 20, 20)
		aura.CFrame = enemyModel.PrimaryPart.CFrame
		aura.Anchored = true
		aura.CanCollide = false
		aura.Material = Enum.Material.Neon
		aura.Color = self.Visual.SecondaryColor
		aura.Transparency = 0.8
		aura.Parent = enemyModel

		-- Pulse animation
		task.spawn(function()
			while aura.Parent do
				for i = 1, 20 do
					aura.Size = Vector3.new(20 + i, 20 + i, 20 + i)
					aura.Transparency = 0.8 + (i * 0.01)
					task.wait(0.05)
				end
				aura.Size = Vector3.new(20, 20, 20)
				aura.Transparency = 0.8
				task.wait(0.5)
			end
		end)
	end

	-- Display boss spawn message
	-- This would integrate with the game's UI system
end

--[[
	Called when boss attacks
--]]
function Boss_Titan:OnAttack(enemyAI, target)
	local currentTime = tick()

	-- Randomly choose special attack if off cooldown
	local attacks = {}

	-- Check Ground Slam cooldown
	if (currentTime - enemyAI.LastGroundSlam) >= self.SpecialAttacks.GroundSlam.Cooldown then
		table.insert(attacks, "GroundSlam")
	end

	-- Check Spin Attack cooldown
	if (currentTime - enemyAI.LastSpinAttack) >= self.SpecialAttacks.SpinAttack.Cooldown then
		table.insert(attacks, "SpinAttack")
	end

	-- Check Charge cooldown (only in phase 2+)
	if enemyAI.CurrentPhase >= 2 and (currentTime - enemyAI.LastCharge) >= self.SpecialAttacks.Charge.Cooldown then
		table.insert(attacks, "Charge")
	end

	-- Use special attack if available, otherwise normal attack
	if #attacks > 0 and math.random() <= 0.6 then -- 60% chance to use special
		local chosenAttack = attacks[math.random(1, #attacks)]

		if chosenAttack == "GroundSlam" then
			enemyAI.LastGroundSlam = currentTime
			return self:GroundSlam(enemyAI, target)
		elseif chosenAttack == "SpinAttack" then
			enemyAI.LastSpinAttack = currentTime
			return self:SpinAttack(enemyAI, target)
		elseif chosenAttack == "Charge" then
			enemyAI.LastCharge = currentTime
			return self:ChargeAttack(enemyAI, target)
		end
	end

	-- Normal attack
	print(string.format("[Boss_Titan] Normal attack"))
	return {
		Damage = enemyAI.Config.Damage,
		KnockbackForce = 40,
		Type = "BossMelee"
	}
end

--[[
	Ground Slam special attack
--]]
function Boss_Titan:GroundSlam(enemyAI, target)
	print(string.format("[Boss_Titan] GROUND SLAM!"))

	local attack = self.SpecialAttacks.GroundSlam

	-- Return attack data for combat system
	return {
		Damage = attack.Damage,
		Type = "GroundSlam",
		Radius = attack.Radius,
		KnockbackForce = attack.KnockbackForce,
		StunDuration = attack.StunDuration,
		WindupTime = attack.WindupTime,
		AOE = true,
	}
end

--[[
	Spin Attack special attack
--]]
function Boss_Titan:SpinAttack(enemyAI, target)
	print(string.format("[Boss_Titan] SPIN ATTACK!"))

	local attack = self.SpecialAttacks.SpinAttack

	return {
		Damage = attack.Damage,
		Type = "SpinAttack",
		Radius = attack.Radius,
		Duration = attack.Duration,
		TickInterval = attack.TickInterval,
		AOE = true,
	}
end

--[[
	Charge Attack special attack
--]]
function Boss_Titan:ChargeAttack(enemyAI, target)
	print(string.format("[Boss_Titan] CHARGE ATTACK!"))

	local attack = self.SpecialAttacks.Charge

	return {
		Damage = attack.Damage,
		Type = "Charge",
		Speed = attack.Speed,
		Duration = attack.Duration,
		Width = attack.Width,
		Charge = true,
	}
end

--[[
	Update boss behavior (minion spawning, phase changes)
--]]
function Boss_Titan:UpdateBehavior(enemyAI, deltaTime)
	local currentTime = tick()

	-- Spawn minions
	if (currentTime - enemyAI.LastMinionSpawn) >= self.Boss.MinionSpawnCooldown then
		enemyAI.LastMinionSpawn = currentTime
		self:SpawnMinions(enemyAI)
	end

	-- Check phase changes
	local healthPercent = enemyAI:GetHealthPercent()
	for i = #self.Boss.Phases, 1, -1 do
		local phase = self.Boss.Phases[i]
		if healthPercent <= phase.HealthPercent and enemyAI.CurrentPhase < i then
			self:ChangePhase(enemyAI, i)
			break
		end
	end

	-- Check enrage
	if healthPercent <= self.Behavior.EnrageAtHealthPercent and not enemyAI.IsEnraged then
		self:Enrage(enemyAI)
	end
end

--[[
	Spawn minions around the boss
--]]
function Boss_Titan:SpawnMinions(enemyAI)
	local count = math.random(self.Boss.MinionCount.Min, self.Boss.MinionCount.Max)
	print(string.format("[Boss_Titan] Spawning %d minions!", count))

	-- This would integrate with the game's spawning system
	-- Return minion spawn data
	return {
		Count = count,
		Types = self.Boss.MinionTypes,
		Position = enemyAI.HumanoidRootPart.Position,
		SpawnRadius = 15,
	}
end

--[[
	Change to a new phase
--]]
function Boss_Titan:ChangePhase(enemyAI, phaseIndex)
	enemyAI.CurrentPhase = phaseIndex
	local phase = self.Boss.Phases[phaseIndex]

	print(string.format("[Boss_Titan] Entering %s!", phase.Name))

	-- Update stats for new phase
	enemyAI.Config.MoveSpeed = self.Stats.MoveSpeed * phase.SpeedMultiplier
	enemyAI.Config.Damage = math.floor(self.Stats.Damage * phase.DamageMultiplier)

	-- Visual effect for phase change
	-- This would integrate with effects system
end

--[[
	Enrage the boss
--]]
function Boss_Titan:Enrage(enemyAI)
	enemyAI.IsEnraged = true
	print(string.format("[Boss_Titan] BOSS ENRAGED!"))

	-- Boost stats when enraged
	enemyAI.Config.MoveSpeed = enemyAI.Config.MoveSpeed * 1.3
	enemyAI.Config.Damage = enemyAI.Config.Damage * 1.5
	enemyAI.Config.AttackCooldown = enemyAI.Config.AttackCooldown * 0.7
end

--[[
	Called when boss takes damage
--]]
function Boss_Titan:OnDamage(enemyAI, damage, damageSource)
	-- Reduce damage by armor
	local actualDamage = math.max(1, damage - self.Combat.Armor)
	return actualDamage
end

--[[
	Called when boss dies
--]]
function Boss_Titan:OnDeath(enemyAI, killer)
	print(string.format("[Boss_Titan] BOSS DEFEATED!"))

	-- Boss death gives huge rewards
	local coinAmount = math.random(self.Rewards.CoinsDropAmount.Min, self.Rewards.CoinsDropAmount.Max)

	local drops = {
		XP = self.Rewards.XPDropAmount,
		Coins = coinAmount,
		BossDeath = true,
		DeathEffect = {
			Type = "BossExplosion",
			Radius = 30,
			Damage = 0, -- Doesn't damage player
		}
	}

	return drops
end

return Boss_Titan
