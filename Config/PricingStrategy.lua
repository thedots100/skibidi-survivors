--[[
	PricingStrategy.lua

	Pricing optimization and A/B testing configuration.
	Manages dynamic pricing, promotions, and price testing.

	Features:
	- Price optimization strategies
	- A/B test configurations
	- Promotional discounts
	- Seasonal pricing
	- Regional pricing adjustments
	- Dynamic pricing based on player behavior

	Usage:
		local PricingStrategy = require(path.to.PricingStrategy)
		local price = PricingStrategy.GetPrice(productId, player)
		local discount = PricingStrategy.GetActiveDiscount(productId)
--]]

local PricingStrategy = {}

-- ============================================================================
-- A/B TESTING CONFIGURATION
-- ============================================================================

PricingStrategy.ABTests = {
	-- Test different price points for entry-level products
	EntryPricing = {
		Enabled = false, -- Enable when ready to test
		TestId = "entry_price_test_v1",

		Groups = {
			Control = {
				Weight = 50, -- 50% of players
				PriceMultiplier = 1.0, -- Standard pricing
			},
			TestA = {
				Weight = 25, -- 25% of players
				PriceMultiplier = 0.85, -- 15% discount
			},
			TestB = {
				Weight = 25, -- 25% of players
				PriceMultiplier = 1.15, -- 15% premium
			}
		},

		-- Products to test
		AffectedProducts = {
			"Small Coin Pack",
			"2X XP Boost",
			"Instant Revive"
		}
	},

	-- Test bundle pricing
	BundlePricing = {
		Enabled = false,
		TestId = "bundle_price_test_v1",

		Groups = {
			Control = {
				Weight = 50,
				BundleDiscount = 0.3, -- 30% off bundles
			},
			TestA = {
				Weight = 50,
				BundleDiscount = 0.4, -- 40% off bundles (better value)
			}
		},

		AffectedProducts = {
			"Starter Bundle",
			"Pro Player Bundle",
			"All Characters Bundle"
		}
	}
}

-- ============================================================================
-- PROMOTIONAL CAMPAIGNS
-- ============================================================================

PricingStrategy.Promotions = {
	-- Weekend sale
	WeekendSale = {
		Enabled = false, -- Enable manually
		Name = "Weekend Special",
		Discount = 0.25, -- 25% off

		-- Time-based activation
		Schedule = {
			DayOfWeek = {6, 7}, -- Saturday, Sunday (1 = Sunday, 7 = Saturday)
			StartHour = 0,
			EndHour = 23
		},

		AffectedCategories = {"Currency", "Bundle"},
		ExcludedProducts = {"Ultimate Pack"}, -- Don't discount ultimate pack
	},

	-- First purchase bonus
	FirstPurchaseBonus = {
		Enabled = true,
		Name = "First Time Buyer Bonus",
		BonusMultiplier = 1.5, -- 50% extra rewards

		-- Only applies to player's first purchase ever
		OneTimeOnly = true,
		AffectedCategories = {"Currency"},
	},

	-- New player discount
	NewPlayerDiscount = {
		Enabled = true,
		Name = "New Player Welcome",
		Discount = 0.15, -- 15% off

		-- Only for players under certain account age
		MaxAccountAge = 30, -- 30 days
		AffectedCategories = {"Currency", "Bundle"},
	},

	-- Comeback discount
	ComebackDiscount = {
		Enabled = true,
		Name = "Welcome Back!",
		Discount = 0.20, -- 20% off

		-- For returning players
		MinDaysAway = 14, -- Must be away for 14+ days
		ValidFor = 86400, -- Valid for 24 hours after return

		AffectedCategories = {"Currency", "Temporary"},
	},

	-- Flash sale
	FlashSale = {
		Enabled = false, -- Enable manually for limited time
		Name = "⚡ FLASH SALE ⚡",
		Discount = 0.5, -- 50% off!

		-- Time window
		StartTime = 0, -- Set manually (os.time())
		EndTime = 0, -- Set manually

		AffectedProducts = {
			"Mega Coin Pack",
			"Premium Starter Pack",
			"Triple Booster (30 Minutes)"
		},

		Announcement = true, -- Send in-game announcement
	},

	-- Holiday events
	HolidaySale = {
		Enabled = false,
		Name = "Holiday Celebration",
		Discount = 0.35, -- 35% off

		-- Date range
		StartDate = "2024-12-20",
		EndDate = "2025-01-05",

		AffectedCategories = {"Currency", "Bundle", "Temporary"},
		BonusRewards = true, -- Give extra items with purchases
	}
}

-- ============================================================================
-- DYNAMIC PRICING
-- ============================================================================

PricingStrategy.DynamicPricing = {
	-- Enabled only for A/B testing
	Enabled = false,

	-- Price based on player lifetime value
	LTVBased = {
		Enabled = false,

		Tiers = {
			-- High value players (spent 1000+ Robux)
			High = {
				MinSpent = 1000,
				PriceMultiplier = 1.1, -- Slight premium (they'll pay it)
				ExclusiveOffers = true,
			},

			-- Medium value players (spent 100-999 Robux)
			Medium = {
				MinSpent = 100,
				MaxSpent = 999,
				PriceMultiplier = 1.0, -- Standard pricing
			},

			-- Low value players (spent 0-99 Robux)
			Low = {
				MaxSpent = 99,
				PriceMultiplier = 0.9, -- 10% discount to encourage conversion
			}
		}
	},

	-- Urgency pricing (time-limited discounts shown to specific players)
	UrgencyPricing = {
		Enabled = false,

		Triggers = {
			-- Player viewed shop but didn't purchase
			AbandonedCart = {
				WaitTime = 300, -- 5 minutes after viewing
				Discount = 0.10, -- 10% discount
				ValidFor = 600, -- Valid for 10 minutes
			},

			-- Player nearing end of session
			EndOfSession = {
				SessionDuration = 1200, -- After 20 minutes
				Discount = 0.15, -- 15% discount
				ValidFor = 300, -- Valid for 5 minutes
			}
		}
	}
}

-- ============================================================================
-- SEASONAL PRICING
-- ============================================================================

PricingStrategy.Seasonal = {
	-- Summer event
	Summer = {
		StartMonth = 6, -- June
		EndMonth = 8, -- August
		Theme = "Summer Blast",
		BonusRewards = {
			Coins = 1.2, -- 20% extra coins in packs
		}
	},

	-- Back to school
	BackToSchool = {
		StartMonth = 8, -- August
		EndMonth = 9, -- September
		Theme = "Back to School",
		Discount = 0.15,
		AffectedCategories = {"Bundle"}
	},

	-- Halloween
	Halloween = {
		StartMonth = 10,
		EndMonth = 10,
		Theme = "Spooky Season",
		SpecialItems = true,
		BonusRewards = {
			Coins = 1.5, -- 50% extra coins
			SpecialCurrency = "Candy"
		}
	},

	-- Black Friday
	BlackFriday = {
		StartMonth = 11,
		StartDay = 25,
		EndDay = 30,
		Theme = "Black Friday Deals",
		Discount = 0.4, -- 40% off
		AffectedCategories = {"Currency", "Bundle", "Temporary"}
	},

	-- Winter/Christmas
	Winter = {
		StartMonth = 12,
		EndMonth = 1,
		Theme = "Winter Wonderland",
		BonusRewards = {
			Coins = 1.3,
			SpecialItems = true
		}
	}
}

-- ============================================================================
-- PRICING HELPERS
-- ============================================================================

--[[
	Get the effective price for a product for a specific player
	@param productConfig: table - Product configuration
	@param player: Player - The player
	@param abTestGroup: string - Player's A/B test group
	@return number, string - Effective price, reason for adjustment
--]]
function PricingStrategy.GetEffectivePrice(productConfig, player, abTestGroup)
	local basePrice = productConfig.Price
	local finalPrice = basePrice
	local adjustmentReason = "Base price"

	-- Check A/B tests
	if PricingStrategy.ABTests.EntryPricing.Enabled then
		local test = PricingStrategy.ABTests.EntryPricing
		if table.find(test.AffectedProducts, productConfig.Name) then
			local group = test.Groups[abTestGroup]
			if group then
				finalPrice = math.floor(basePrice * group.PriceMultiplier)
				adjustmentReason = "A/B test: " .. abTestGroup
			end
		end
	end

	-- Check promotions (highest discount wins)
	local highestDiscount = 0
	local discountSource = nil

	-- Weekend sale
	if PricingStrategy.Promotions.WeekendSale.Enabled then
		if PricingStrategy.IsWeekend() then
			local promo = PricingStrategy.Promotions.WeekendSale
			if table.find(promo.AffectedCategories, productConfig.Category) and
			   not table.find(promo.ExcludedProducts or {}, productConfig.Name) then
				if promo.Discount > highestDiscount then
					highestDiscount = promo.Discount
					discountSource = promo.Name
				end
			end
		end
	end

	-- New player discount
	if PricingStrategy.Promotions.NewPlayerDiscount.Enabled then
		local promo = PricingStrategy.Promotions.NewPlayerDiscount
		if player.AccountAge <= promo.MaxAccountAge then
			if table.find(promo.AffectedCategories, productConfig.Category) then
				if promo.Discount > highestDiscount then
					highestDiscount = promo.Discount
					discountSource = promo.Name
				end
			end
		end
	end

	-- Flash sale
	if PricingStrategy.Promotions.FlashSale.Enabled then
		local promo = PricingStrategy.Promotions.FlashSale
		local currentTime = os.time()
		if currentTime >= promo.StartTime and currentTime <= promo.EndTime then
			if table.find(promo.AffectedProducts, productConfig.Name) then
				if promo.Discount > highestDiscount then
					highestDiscount = promo.Discount
					discountSource = promo.Name
				end
			end
		end
	end

	-- Apply highest discount
	if highestDiscount > 0 then
		finalPrice = math.floor(finalPrice * (1 - highestDiscount))
		adjustmentReason = discountSource .. string.format(" (-%d%%)", highestDiscount * 100)
	end

	return finalPrice, adjustmentReason
end

--[[
	Check if it's currently weekend
	@return boolean
--]]
function PricingStrategy.IsWeekend()
	local dateTable = os.date("*t")
	local dayOfWeek = dateTable.wday -- 1 = Sunday, 7 = Saturday

	return dayOfWeek == 1 or dayOfWeek == 7
end

--[[
	Get active promotions for a product
	@param productConfig: table - Product configuration
	@param player: Player - The player
	@return table - List of active promotions
--]]
function PricingStrategy.GetActivePromotions(productConfig, player)
	local activePromotions = {}

	-- Check each promotion
	for promoName, promo in pairs(PricingStrategy.Promotions) do
		if promo.Enabled then
			local isActive = false

			-- Check conditions based on promotion type
			if promoName == "WeekendSale" and PricingStrategy.IsWeekend() then
				if table.find(promo.AffectedCategories, productConfig.Category) then
					isActive = true
				end
			elseif promoName == "NewPlayerDiscount" then
				if player.AccountAge <= promo.MaxAccountAge then
					if table.find(promo.AffectedCategories, productConfig.Category) then
						isActive = true
					end
				end
			elseif promoName == "FlashSale" then
				local currentTime = os.time()
				if currentTime >= promo.StartTime and currentTime <= promo.EndTime then
					if table.find(promo.AffectedProducts, productConfig.Name) then
						isActive = true
					end
				end
			end

			if isActive then
				table.insert(activePromotions, {
					Name = promo.Name,
					Discount = promo.Discount,
					Type = promoName
				})
			end
		end
	end

	return activePromotions
end

--[[
	Get current seasonal event
	@return table - Active seasonal event or nil
--]]
function PricingStrategy.GetActiveSeason()
	local currentMonth = os.date("*t").month
	local currentDay = os.date("*t").day

	for seasonName, season in pairs(PricingStrategy.Seasonal) do
		-- Check if current date is within season
		if season.StartMonth and season.EndMonth then
			if currentMonth >= season.StartMonth and currentMonth <= season.EndMonth then
				-- Check specific days if defined
				if season.StartDay and season.EndDay then
					if currentDay >= season.StartDay and currentDay <= season.EndDay then
						return season
					end
				else
					return season
				end
			end
		end
	end

	return nil
end

--[[
	Calculate bundle savings
	@param bundleConfig: table - Bundle configuration
	@param individualPrices: table - Individual product prices
	@return number - Percentage saved
--]]
function PricingStrategy.CalculateBundleSavings(bundleConfig, individualPrices)
	local bundlePrice = bundleConfig.Price
	local individualTotal = 0

	for _, price in ipairs(individualPrices) do
		individualTotal = individualTotal + price
	end

	if individualTotal == 0 then
		return 0
	end

	local savingsPercent = ((individualTotal - bundlePrice) / individualTotal) * 100
	return math.floor(savingsPercent)
end

return PricingStrategy
