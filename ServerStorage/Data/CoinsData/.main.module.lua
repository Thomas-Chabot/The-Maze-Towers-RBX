local ServerScriptService = game:GetService("ServerScriptService");
local AssetMain           = require (ServerScriptService.Modules.Asset);
local Model               = AssetMain.Model;

-- All the coin textures are stored in the script; just add the script as a model
Model (script);

local coinsData = {
	{
		coinImage = script.Coins10.Texture,
		amount    = 250,
		title     = "Coins",
		price     = 80,
		id        = 1,
		
		ProductId = 336805468
	},
	{
		coinImage = script.Coins50.Texture,
		amount    = 500,
		title     = "Coins",
		price     = 160,
		id        = 2,
		
		deal = {
			text = "Most Popular",
			color = Color3.fromRGB(115, 76, 57)
		},
		
		ProductId = 336805640
	},
	{
		coinImage = script.Coins100.Texture,
		amount    = 1000,
		title     = "Coins",
		price     = 320,
		id        = 3,
		
		ProductId = 336805850
	},
	{
		coinImage = script.Coins500.Texture,
		amount    = 2500,
		title     = "Coins",
		price     = 750,
		id        = 4,
		
		deal = {
			text = "6% Off!",
			color = Color3.fromRGB(113, 113, 84)
		},
		
		
		ProductId = 336806172
	},
	{
		coinImage = script.Coins1000.Texture,
		amount    = 5000,
		title     = "Coins",
		price     = 1400,
		id        = 5,
		
		deal = {
			text = "12.5% off!",
			color = Color3.fromRGB(0, 85, 127)
		},
		
		ProductId = 336806328
	},
	{
		coinImage = script.MoneyBag.Texture,
		amount    = 12500,
		title     = "Bag o' Coins",
		price     = 3000,
		id        = 6,
		
		deal = {
			text = "25% off!",
			color = Color3.new (0, 124, 0)
		},
		
		ProductId = 336806643
	},
};

return coinsData;