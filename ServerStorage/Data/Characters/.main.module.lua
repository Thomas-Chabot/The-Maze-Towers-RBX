local ServerScriptService = game:GetService("ServerScriptService");
local AssetMain           = require (ServerScriptService.Modules.Asset);
local Asset               = AssetMain.Asset;
local Url                 = AssetMain.Url;
local Package             = AssetMain.Package;
local Model               = AssetMain.Model;

local attacks = Model(script.Attacks);
local particles = Model(script.AttackParticles);

local characters = {
	["Default"] = {
		Name = "Default",
		
		-- Character attributes
		Luck = 0.5,
		Speed = 0.3,
		Vision = 0.07,
		Height = 0.47,
		ResetAppearance = true,
		
		Assets = {
			Asset(144076358),
			Asset(144076760),
			Asset(7074786),
			Asset(607702162)
		},
		
		-- Attack stats
		AttackStats = {
			Timeout = 0.1,
			Damage = 10
		},
		
		-- AI Stats
		RandomOdds = 0.7,
		CharacterModel = Model(script.Characters.Default),
		
		-- Client stats
		Price = 0,
		Id = "Default",
		Image = Url("http://www.roblox.com/asset/?id=2095900445"),
		
		IsForSale = false,
		
		LayoutOrder = 1
	},
	
	["Leprechaun"] = {
		Name = "Leprechaun",
		
		-- Character stats
		Luck = 0.9,
		Speed = 0.7,
		Vision = 0.23,
		Height = 0.37,
		ResetAppearance = true,
		
		Assets = {
		    Asset(7074661),
		    Asset(8798578),
		    Asset(12824320),
		    Asset(111358439)
		},
		
		BodyColors = {
			["Torso"] = BrickColor.new ("Bright green")
		},
		
		-- Attack stats
		AttackStats = {
			Timeout = 0.1,
			TemplatePart = Model(attacks.LeprechaunAttack),
		--[[	EffectStats = {
				EffectType = "DOT",
				
				Particle = particles.Leprechaun:Clone(),
				DamagePerSec = 0.5,
				Length = 5,
				Timeout = 1
			}]]
		},
		
		-- AI Stats
		RandomOdds = 0.1,
		CharacterModel = Model(script.Characters.Leprechaun),
		
		-- Client stats
		Price = 1500,
		Id = "Leprechaun",
		Image = Url("http://www.roblox.com/asset/?id=2095661137"),
		
		IsForSale = true,
		
		LayoutOrder = 4
	},
	
	["Cat"] = {
		Name = "Cat",
		
		-- Character stats
		Luck = 0.2,
		Speed = 0.35,
		Vision = 0.69,
		Height = 0.26,
		ResetAppearance = true,
		
		JumpPower = 75,
		
		Assets = {
			Asset(170892848),
			Asset(136758455),
			Asset(144968417),
			Asset(19978515)
		},
		
		BodyColors = {
			["Left Arm"] = BrickColor.new ("White"),
			["Right Arm"] = BrickColor.new ("White")
		},
		
		-- Attack Stats
		AttackStats = {
			Timeout = 0.1,
			TemplatePart = Model(attacks.CatAttack);
		},
		
		-- AI Stats
		RandomOdds = 0.1,
		CharacterModel = Model(script.Characters.Cat),
		
		-- Client stats
		Price = 500,
		Id = "Cat",
		Image = Url("http://www.roblox.com/asset/?id=2095954707"),
		
		IsForSale = true,
		
		LayoutOrder = 2
	},
	
	["Dog"] = {
		Name = "Dog",
		
		-- Character stats
		Luck = 0.5,
		Speed = 0.35,
		Vision = 0.08,
		Height = 0.26,
		
		JumpPower = 75,
		
		-- Appearance
		ResetAppearance = true,
		Assets = { },
		Package = Package(1796153559),
		
		-- Attack stats
		AttackStats = {
			Timeout = 0.1,
			TemplatePart = Model(attacks.DogAttack)
		},
		
		-- AI Stats
		RandomOdds = 0.1,
		CharacterModel = Model(script.Characters.Dog),
		
		-- Client stats
		Price = 500,
		Id = "Dog",
		Image = Url("http://www.roblox.com/asset/?id=2097610209"),
		
		IsForSale = true,
		
		LayoutOrder = 3
	},
	
	["SML"] = {
		Name = "StickMasterLuke",
		
		-- Character stats
		Luck = 0.5,
		Speed = 0.69,
		Vision = 0.69,
		Height = 0.47,
		
		-- Appearance		
		ApplyDefaultPackage = false,
		ResetAppearance = true,
		Assets = {
		    Asset(1272714), Asset(17539101), Asset(21070012), Asset(24378840), 
		    Asset(27112025), Asset(27112039), Asset(27112052), Asset(46359655),
		    Asset(46359706), Asset(192557913), Asset(658831143), Asset(658831500), 
		    Asset(658832070), Asset(658832807), Asset(658833139), Asset(1772578399)
		},
		Package = Model(script.Packages.SML),
		
		-- Attack stats
		AttackStats = {
			Timeout = 0.1,
			Damage = 20,
			TemplatePart = Model(attacks.SMLAttack)
		},
		
		-- AI Stats
		RandomOdds = 0,
		
		-- Client stats
		Price = 7500,
		Id = "SML",
		Image = Url(script.SML.Texture),
		
		LayoutOrder = 5
	},
	
	--[[["Dragon"] = {
		
		AttackStats = {
			Length = 2, 
			Distance = 60, 
			Directional = false, 
			TemplatePart = script.Attacks.DragonBreath,
			
			Timeout = 0.1
		},
	}]]
}

return characters;