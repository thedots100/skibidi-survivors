--[[
	GamePassConfig.lua

	GamePass catalog configuration for the Skibidi Toilet vampire survivors game.
	Defines all available GamePasses with prices, benefits, and descriptions.

	IMPORTANT: Setting up GamePasses
	================================
	1. Go to https://create.roblox.com/dashboard/creations
	2. Select your experience
	3. Navigate to "Monetization" > "Passes"
	4. Click "CREATE A PASS"
	5. Configure the pass:
	   - Upload an icon image (512x512 recommended)
	   - Set the name (match the Name field below)
	   - Write a description (match the Description field below)
	   - Set the price (match the Price field below)
	6. Click "CREATE PASS"
	7. Copy the Pass ID from the URL or pass details
	8. Paste the ID in the Id field below (replace nil)
	9. Repeat for all GamePasses

	Price Tiers:
	- Entry: 99-299 Robux (impulse purchases)
	- Value: 300-599 Robux (best value proposition)
	- Premium: 600-999 Robux (exclusive/luxury)
	- Ultimate: 1000+ Robux (bundles/lifetime benefits)

	Features:
	- XP/Coin boosters
	- Exclusive characters
	- Premium weapons
	- VIP benefits
	- Cosmetic items
--]]

local GamePassConfig = {
	-- ========================================================================
	-- ENTRY TIER (99-299 Robux)
	-- ========================================================================

	{
		Id = nil, -- REPLACE WITH YOUR GAMEPASS ID (e.g., 123456789)
		Name = "2X XP Boost",
		Description = "Earn 2x XP from all sources! Level up twice as fast.",
		Price = 199,
		Tier = "Entry",
		Icon = "rbxassetid://0", -- Replace with your icon asset ID

		Benefits = {
			XPBoost = 2.0, -- 2x XP multiplier
		},

		-- Display info
		DisplayOrder = 1,
		Featured = true,
		Badge = "POPULAR",
	},

	{
		Id = nil, -- REPLACE WITH YOUR GAMEPASS ID
		Name = "Coin Magnet",
		Description = "Automatically collect coins and XP from a larger distance!",
		Price = 149,
		Tier = "Entry",
		Icon = "rbxassetid://0",

		Benefits = {
			MagnetRange = 25, -- Increased pickup range
			AutoCollect = true,
		},

		DisplayOrder = 2,
		Featured = false,
	},

	{
		Id = nil, -- REPLACE WITH YOUR GAMEPASS ID
		Name = "Fast Revive",
		Description = "Instantly revive once per game! Get a second chance.",
		Price = 249,
		Tier = "Entry",
		Icon = "rbxassetid://0",

		Benefits = {
			Revive = 1, -- One revive per game
			InstantRevive = true,
		},

		DisplayOrder = 3,
		Featured = false,
	},

	-- ========================================================================
	-- VALUE TIER (300-599 Robux)
	-- ========================================================================

	{
		Id = nil, -- REPLACE WITH YOUR GAMEPASS ID
		Name = "Character Pack - Cameraman",
		Description = "Unlock the powerful Cameraman character with unique abilities!",
		Price = 299,
		Tier = "Value",
		Icon = "rbxassetid://0",

		Benefits = {
			UnlockCharacter = "Cameraman",
		},

		DisplayOrder = 4,
		Featured = true,
		Badge = "NEW",
	},

	{
		Id = nil, -- REPLACE WITH YOUR GAMEPASS ID
		Name = "Character Pack - Speakerman",
		Description = "Unlock the devastating Speakerman character with sonic attacks!",
		Price = 299,
		Tier = "Value",
		Icon = "rbxassetid://0",

		Benefits = {
			UnlockCharacter = "Speakerman",
		},

		DisplayOrder = 5,
		Featured = true,
		Badge = "NEW",
	},

	{
		Id = nil, -- REPLACE WITH YOUR GAMEPASS ID
		Name = "Premium Starter Pack",
		Description = "Get 1000 coins + exclusive Golden Camera weapon + 2x XP for 1 hour!",
		Price = 399,
		Tier = "Value",
		Icon = "rbxassetid://0",

		Benefits = {
			Coins = 1000,
			UnlockWeapon = "Golden_Camera",
			TempXPBoost = {
				Multiplier = 2.0,
				Duration = 3600 -- 1 hour
			}
		},

		DisplayOrder = 6,
		Featured = true,
		Badge = "BEST VALUE",
	},

	{
		Id = nil, -- REPLACE WITH YOUR GAMEPASS ID
		Name = "Double Coins",
		Description = "Earn 2x coins from all sources! Get rich faster.",
		Price = 349,
		Tier = "Value",
		Icon = "rbxassetid://0",

		Benefits = {
			CoinBoost = 2.0, -- 2x coin multiplier
		},

		DisplayOrder = 7,
		Featured = true,
		Badge = "POPULAR",
	},

	-- ========================================================================
	-- PREMIUM TIER (600-999 Robux)
	-- ========================================================================

	{
		Id = nil, -- REPLACE WITH YOUR GAMEPASS ID
		Name = "Golden Weapons Pack",
		Description = "Unlock exclusive golden variants of all weapons with +20% damage!",
		Price = 499,
		Tier = "Premium",
		Icon = "rbxassetid://0",

		Benefits = {
			UnlockWeapon = "Golden_Pack",
			DamageBoost = 1.2, -- +20% damage with golden weapons
		},

		DisplayOrder = 8,
		Featured = true,
		Badge = "EXCLUSIVE",
	},

	{
		Id = nil, -- REPLACE WITH YOUR GAMEPASS ID
		Name = "VIP Membership",
		Description = "Become a VIP! Get daily rewards, special name color, chat badge, and priority server access.",
		Price = 799,
		Tier = "Premium",
		Icon = "rbxassetid://0",

		Benefits = {
			VIP = true,
			DailyReward = 200, -- 200 coins daily
			NameColor = true,
			ChatBadge = "[VIP]",
			JoinFullServers = true,
		},

		DisplayOrder = 9,
		Featured = true,
		Badge = "VIP",
	},

	{
		Id = nil, -- REPLACE WITH YOUR GAMEPASS ID
		Name = "All Characters Bundle",
		Description = "Unlock ALL current and future characters! Never pay for characters again.",
		Price = 699,
		Tier = "Premium",
		Icon = "rbxassetid://0",

		Benefits = {
			UnlockAllCharacters = true,
			FutureCharacters = true, -- Includes future releases
		},

		DisplayOrder = 10,
		Featured = true,
		Badge = "BUNDLE",
	},

	-- ========================================================================
	-- ULTIMATE TIER (1000+ Robux)
	-- ========================================================================

	{
		Id = nil, -- REPLACE WITH YOUR GAMEPASS ID
		Name = "Ultimate Pack",
		Description = "Get EVERYTHING! VIP + All Characters + Golden Weapons + 2X XP & Coins + 5000 bonus coins!",
		Price = 1499,
		Tier = "Ultimate",
		Icon = "rbxassetid://0",

		Benefits = {
			VIP = true,
			UnlockAllCharacters = true,
			FutureCharacters = true,
			UnlockWeapon = "Golden_Pack",
			XPBoost = 2.0,
			CoinBoost = 2.0,
			DamageBoost = 1.2,
			Coins = 5000,
			DailyReward = 500,
			NameColor = true,
			ChatBadge = "[ULTIMATE]",
			JoinFullServers = true,
			ExclusiveEmotes = true,
			PrioritySupport = true,
		},

		DisplayOrder = 11,
		Featured = true,
		Badge = "ULTIMATE",
		Savings = "Save 60%!", -- Compared to buying individually
	},

	-- ========================================================================
	-- SEASONAL / LIMITED TIME (Configure as needed)
	-- ========================================================================

	{
		Id = nil, -- REPLACE WITH YOUR GAMEPASS ID
		Name = "Holiday Special Pack",
		Description = "Limited time! Festive character skin + 2000 coins + XP boost!",
		Price = 599,
		Tier = "Premium",
		Icon = "rbxassetid://0",

		Benefits = {
			UnlockSkin = "Holiday_Special",
			Coins = 2000,
			XPBoost = 1.5,
		},

		DisplayOrder = 12,
		Featured = true,
		Badge = "LIMITED",

		-- Limited time configuration
		LimitedTime = {
			Enabled = false, -- Set to true when active
			StartDate = "2024-12-01",
			EndDate = "2024-12-31",
		}
	},
}

--[[
	Helper function to get GamePass by ID
	@param gamePassId: number - The GamePass ID
	@return table - GamePass configuration or nil
--]]
function GamePassConfig.GetById(gamePassId)
	for _, gamePass in ipairs(GamePassConfig) do
		if gamePass.Id == gamePassId then
			return gamePass
		end
	end
	return nil
end

--[[
	Helper function to get GamePasses by tier
	@param tier: string - Tier name
	@return table - List of GamePass configurations
--]]
function GamePassConfig.GetByTier(tier)
	local result = {}
	for _, gamePass in ipairs(GamePassConfig) do
		if gamePass.Tier == tier then
			table.insert(result, gamePass)
		end
	end
	return result
end

--[[
	Helper function to get featured GamePasses
	@return table - List of featured GamePass configurations
--]]
function GamePassConfig.GetFeatured()
	local result = {}
	for _, gamePass in ipairs(GamePassConfig) do
		if gamePass.Featured then
			table.insert(result, gamePass)
		end
	end

	-- Sort by display order
	table.sort(result, function(a, b)
		return a.DisplayOrder < b.DisplayOrder
	end)

	return result
end

--[[
	Helper function to check if all GamePass IDs are configured
	@return boolean, table - All configured, list of missing GamePasses
--]]
function GamePassConfig.ValidateConfiguration()
	local missing = {}

	for _, gamePass in ipairs(GamePassConfig) do
		if not gamePass.Id or gamePass.Id == 0 then
			table.insert(missing, gamePass.Name)
		end
	end

	return #missing == 0, missing
end

-- Validation on load (in Studio)
local isStudio = game:GetService("RunService"):IsStudio()
if isStudio then
	local allConfigured, missing = GamePassConfig.ValidateConfiguration()

	if not allConfigured then
		warn("[GamePassConfig] ⚠️ Some GamePass IDs are not configured:")
		for _, name in ipairs(missing) do
			warn("  - " .. name)
		end
		warn("[GamePassConfig] Please create these GamePasses in the Roblox Creator Dashboard and add their IDs to this file.")
	else
		print("[GamePassConfig] ✓ All GamePass IDs are configured")
	end
end

return GamePassConfig
