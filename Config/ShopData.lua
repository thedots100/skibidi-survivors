--[[
	ShopData.lua

	Developer Products catalog configuration for the Skibidi Toilet game.
	Defines all purchasable consumables, bundles, and boosters.

	IMPORTANT: Setting up Developer Products
	=========================================
	1. Go to https://create.roblox.com/dashboard/creations
	2. Select your experience
	3. Navigate to "Monetization" > "Developer Products"
	4. Click "CREATE DEVELOPER PRODUCT"
	5. Configure the product:
	   - Upload an icon image (512x512 recommended)
	   - Set the name (match the Name field below)
	   - Write a description (match the Description field below)
	   - Set the price (match the Price field below)
	6. Click "CREATE PRODUCT"
	7. Copy the Product ID from the URL or product details
	8. Paste the ID in the Id field below (replace nil)
	9. Repeat for all Developer Products

	Product Categories:
	- Currency: Coin packs
	- Consumables: Single-use items (revives, boosters)
	- Bundles: Multi-item packages
	- Temporary: Time-limited buffs

	Features:
	- Fair pricing structure
	- Bundle discounts
	- Limited-time offers
	- Best value indicators
--]]

local ShopData = {
	-- ========================================================================
	-- CURRENCY PACKS (Coins)
	-- ========================================================================

	{
		Id = nil, -- REPLACE WITH YOUR DEVELOPER PRODUCT ID (e.g., 123456789)
		Name = "Small Coin Pack",
		Description = "100 coins for quick purchases!",
		Price = 49,
		Category = "Currency",
		Icon = "rbxassetid://0",

		Reward = {
			Coins = 100,
		},

		DisplayOrder = 1,
	},

	{
		Id = nil, -- REPLACE WITH YOUR DEVELOPER PRODUCT ID
		Name = "Medium Coin Pack",
		Description = "300 coins - more value for your Robux!",
		Price = 99,
		Category = "Currency",
		Icon = "rbxassetid://0",

		Reward = {
			Coins = 300,
		},

		DisplayOrder = 2,
		Badge = "POPULAR",
	},

	{
		Id = nil, -- REPLACE WITH YOUR DEVELOPER PRODUCT ID
		Name = "Large Coin Pack",
		Description = "750 coins - great value!",
		Price = 199,
		Category = "Currency",
		Icon = "rbxassetid://0",

		Reward = {
			Coins = 750,
		},

		DisplayOrder = 3,
	},

	{
		Id = nil, -- REPLACE WITH YOUR DEVELOPER PRODUCT ID
		Name = "Mega Coin Pack",
		Description = "2000 coins - best value! Save 25%!",
		Price = 499,
		Category = "Currency",
		Icon = "rbxassetid://0",

		Reward = {
			Coins = 2000,
		},

		DisplayOrder = 4,
		Badge = "BEST VALUE",
		Savings = "25% Bonus",
	},

	{
		Id = nil, -- REPLACE WITH YOUR DEVELOPER PRODUCT ID
		Name = "Ultimate Coin Pack",
		Description = "5000 coins - maximum value! Save 35%!",
		Price = 999,
		Category = "Currency",
		Icon = "rbxassetid://0",

		Reward = {
			Coins = 5000,
		},

		DisplayOrder = 5,
		Badge = "ULTIMATE",
		Savings = "35% Bonus",
	},

	-- ========================================================================
	-- CONSUMABLES (Single-use items)
	-- ========================================================================

	{
		Id = nil, -- REPLACE WITH YOUR DEVELOPER PRODUCT ID
		Name = "Instant Revive",
		Description = "Revive instantly with full health! One-time use.",
		Price = 25,
		Category = "Consumable",
		Icon = "rbxassetid://0",

		Reward = {
			Revive = 1,
			RestoreHealth = 100,
		},

		DisplayOrder = 10,
		InGamePurchase = true, -- Can be purchased during gameplay
	},

	{
		Id = nil, -- REPLACE WITH YOUR DEVELOPER PRODUCT ID
		Name = "Wave Skip",
		Description = "Skip the current wave and get rewards instantly!",
		Price = 49,
		Category = "Consumable",
		Icon = "rbxassetid://0",

		Reward = {
			SkipWave = true,
			WaveRewards = true, -- Still get wave completion rewards
		},

		DisplayOrder = 11,
		InGamePurchase = true,
	},

	{
		Id = nil, -- REPLACE WITH YOUR DEVELOPER PRODUCT ID
		Name = "Full Health Restore",
		Description = "Instantly restore all health! Perfect for tough situations.",
		Price = 19,
		Category = "Consumable",
		Icon = "rbxassetid://0",

		Reward = {
			RestoreHealth = 100, -- 100%
		},

		DisplayOrder = 12,
		InGamePurchase = true,
	},

	-- ========================================================================
	-- TEMPORARY BOOSTERS
	-- ========================================================================

	{
		Id = nil, -- REPLACE WITH YOUR DEVELOPER PRODUCT ID
		Name = "2X Coin Booster (1 Hour)",
		Description = "Earn 2x coins for 1 hour! Works across all game modes.",
		Price = 99,
		Category = "Temporary",
		Icon = "rbxassetid://0",

		Reward = {
			Booster = {
				Type = "CoinBoost",
				Multiplier = 2.0,
				Duration = 3600, -- 1 hour in seconds
			}
		},

		DisplayOrder = 20,
		Badge = "POPULAR",
	},

	{
		Id = nil, -- REPLACE WITH YOUR DEVELOPER PRODUCT ID
		Name = "2X XP Booster (1 Hour)",
		Description = "Earn 2x XP for 1 hour! Level up faster.",
		Price = 99,
		Category = "Temporary",
		Icon = "rbxassetid://0",

		Reward = {
			Booster = {
				Type = "XPBoost",
				Multiplier = 2.0,
				Duration = 3600, -- 1 hour
			}
		},

		DisplayOrder = 21,
		Badge = "POPULAR",
	},

	{
		Id = nil, -- REPLACE WITH YOUR DEVELOPER PRODUCT ID
		Name = "Triple Booster (30 Minutes)",
		Description = "3x XP AND 3x Coins for 30 minutes! Ultimate grinding power!",
		Price = 199,
		Category = "Temporary",
		Icon = "rbxassetid://0",

		Reward = {
			Booster = {
				Type = "SuperBoost",
				XPMultiplier = 3.0,
				CoinMultiplier = 3.0,
				Duration = 1800, -- 30 minutes
			}
		},

		DisplayOrder = 22,
		Badge = "BEST VALUE",
	},

	{
		Id = nil, -- REPLACE WITH YOUR DEVELOPER PRODUCT ID
		Name = "Damage Booster (1 Game)",
		Description = "Deal +50% damage for your next game! Destroy enemies faster!",
		Price = 79,
		Category = "Temporary",
		Icon = "rbxassetid://0",

		Reward = {
			Booster = {
				Type = "DamageBoost",
				Multiplier = 1.5,
				Duration = "one_game", -- Lasts for one game session
			}
		},

		DisplayOrder = 23,
	},

	-- ========================================================================
	-- BUNDLES (Multi-item packages)
	-- ========================================================================

	{
		Id = nil, -- REPLACE WITH YOUR DEVELOPER PRODUCT ID
		Name = "Starter Bundle",
		Description = "Perfect for new players! 500 coins + 2x XP for 1 hour + 1 revive!",
		Price = 149,
		Category = "Bundle",
		Icon = "rbxassetid://0",

		Reward = {
			Coins = 500,
			Revive = 1,
			Booster = {
				Type = "XPBoost",
				Multiplier = 2.0,
				Duration = 3600,
			}
		},

		DisplayOrder = 30,
		Badge = "BEST VALUE",
		Savings = "Save 40%",
	},

	{
		Id = nil, -- REPLACE WITH YOUR DEVELOPER PRODUCT ID
		Name = "Pro Player Bundle",
		Description = "For serious players! 1500 coins + Triple booster (30 min) + 3 revives!",
		Price = 399,
		Category = "Bundle",
		Icon = "rbxassetid://0",

		Reward = {
			Coins = 1500,
			Revive = 3,
			Booster = {
				Type = "SuperBoost",
				XPMultiplier = 3.0,
				CoinMultiplier = 3.0,
				Duration = 1800,
			}
		},

		DisplayOrder = 31,
		Badge = "POPULAR",
		Savings = "Save 50%",
	},

	-- ========================================================================
	-- LOOT BOXES / RANDOM REWARDS
	-- ========================================================================

	{
		Id = nil, -- REPLACE WITH YOUR DEVELOPER PRODUCT ID
		Name = "Mystery Box",
		Description = "Get a random reward! Could be coins, weapons, or rare items!",
		Price = 99,
		Category = "LootBox",
		Icon = "rbxassetid://0",

		Reward = {
			LootBox = {
				Type = "Mystery",
				PossibleRewards = {
					{Type = "Coins", Min = 100, Max = 500, Weight = 40},
					{Type = "XPBoost", Duration = 3600, Weight = 25},
					{Type = "Revive", Amount = 1, Weight = 20},
					{Type = "RareWeapon", Weight = 10},
					{Type = "LegendaryWeapon", Weight = 5},
				}
			}
		},

		DisplayOrder = 40,
		Badge = "LUCK",
	},

	{
		Id = nil, -- REPLACE WITH YOUR DEVELOPER PRODUCT ID
		Name = "Premium Loot Box",
		Description = "Better odds for rare items! Guaranteed at least Epic rarity!",
		Price = 199,
		Category = "LootBox",
		Icon = "rbxassetid://0",

		Reward = {
			LootBox = {
				Type = "Premium",
				MinRarity = "Epic",
				PossibleRewards = {
					{Type = "Coins", Min = 500, Max = 1500, Weight = 30},
					{Type = "RareWeapon", Weight = 35},
					{Type = "LegendaryWeapon", Weight = 25},
					{Type = "MythicWeapon", Weight = 10},
				}
			}
		},

		DisplayOrder = 41,
		Badge = "PREMIUM",
	},

	-- ========================================================================
	-- LIMITED TIME OFFERS (Configure as needed)
	-- ========================================================================

	{
		Id = nil, -- REPLACE WITH YOUR DEVELOPER PRODUCT ID
		Name = "Flash Sale Bundle",
		Description = "LIMITED TIME! Triple the value - 3000 coins + boosters + rewards!",
		Price = 499,
		Category = "Bundle",
		Icon = "rbxassetid://0",

		Reward = {
			Coins = 3000,
			Revive = 5,
			Booster = {
				Type = "SuperBoost",
				XPMultiplier = 3.0,
				CoinMultiplier = 3.0,
				Duration = 7200, -- 2 hours
			}
		},

		DisplayOrder = 50,
		Badge = "LIMITED",
		Savings = "70% OFF",

		LimitedTime = {
			Enabled = false, -- Set to true when active
			StartTime = 0,
			EndTime = 0,
		}
	},
}

--[[
	Helper function to get product by ID
	@param productId: number - The Developer Product ID
	@return table - Product configuration or nil
--]]
function ShopData.GetById(productId)
	for _, product in ipairs(ShopData) do
		if product.Id == productId then
			return product
		end
	end
	return nil
end

--[[
	Helper function to get products by category
	@param category: string - Category name
	@return table - List of product configurations
--]]
function ShopData.GetByCategory(category)
	local result = {}
	for _, product in ipairs(ShopData) do
		if product.Category == category then
			table.insert(result, product)
		end
	end

	-- Sort by display order
	table.sort(result, function(a, b)
		return a.DisplayOrder < b.DisplayOrder
	end)

	return result
end

--[[
	Helper function to get in-game purchasable products
	@return table - List of products that can be bought during gameplay
--]]
function ShopData.GetInGameProducts()
	local result = {}
	for _, product in ipairs(ShopData) do
		if product.InGamePurchase then
			table.insert(result, product)
		end
	end
	return result
end

--[[
	Helper function to check if all product IDs are configured
	@return boolean, table - All configured, list of missing products
--]]
function ShopData.ValidateConfiguration()
	local missing = {}

	for _, product in ipairs(ShopData) do
		if not product.Id or product.Id == 0 then
			table.insert(missing, product.Name)
		end
	end

	return #missing == 0, missing
end

--[[
	Calculate price per coin for value comparison
	@param product: table - Product configuration
	@return number - Price per coin ratio (lower is better value)
--]]
function ShopData.CalculateValue(product)
	if not product.Reward or not product.Reward.Coins then
		return math.huge -- No coin value
	end

	return product.Price / product.Reward.Coins
end

--[[
	Get best value products
	@param category: string - Category to filter (optional)
	@return table - Products sorted by value
--]]
function ShopData.GetBestValue(category)
	local products = category and ShopData.GetByCategory(category) or ShopData

	-- Filter products with coin rewards
	local coinProducts = {}
	for _, product in ipairs(products) do
		if product.Reward and product.Reward.Coins then
			table.insert(coinProducts, product)
		end
	end

	-- Sort by value (price per coin)
	table.sort(coinProducts, function(a, b)
		return ShopData.CalculateValue(a) < ShopData.CalculateValue(b)
	end)

	return coinProducts
end

-- Validation on load (in Studio)
local isStudio = game:GetService("RunService"):IsStudio()
if isStudio then
	local allConfigured, missing = ShopData.ValidateConfiguration()

	if not allConfigured then
		warn("[ShopData] ⚠️ Some Developer Product IDs are not configured:")
		for _, name in ipairs(missing) do
			warn("  - " .. name)
		end
		warn("[ShopData] Please create these Developer Products in the Roblox Creator Dashboard and add their IDs to this file.")
	else
		print("[ShopData] ✓ All Developer Product IDs are configured")
	end

	-- Log value analysis
	print("[ShopData] Currency Pack Value Analysis:")
	local coinPacks = ShopData.GetByCategory("Currency")
	for _, pack in ipairs(coinPacks) do
		local valueRatio = ShopData.CalculateValue(pack)
		print(string.format("  %s: %.2f Robux per coin", pack.Name, valueRatio))
	end
end

return ShopData
