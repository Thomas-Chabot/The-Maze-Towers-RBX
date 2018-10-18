local ServerScriptService = game:GetService("ServerScriptService");
local AssetMain           = require (ServerScriptService.Modules.Asset);
local Asset               = AssetMain.Asset;
local Url                 = AssetMain.Url;
local Package             = AssetMain.Package;
local Model               = AssetMain.Model;

-- Map base models
local sewer = Model(script.SewerMap);

-- Map details
local SewerMap = {
	BuildSettings = {
		Grid = { },
		
		SpaceSize = Vector3.new (25, 25, 25),
		
		Wall = sewer.Wall,
		Exit = sewer.Exit,
		Roof = sewer.Roof,
		None = sewer.None,
		
		-- Floor types
		Deadend = sewer.Deadend,
		Straight = sewer.Straight,
		LeftTurn = sewer.LeftTurn,
		FourWayTurn = sewer.FourWayTurn,
		ThreeWayTurn = sewer.ThreeWayTurn,
		
	},
	NegativePowerup = sewer.NegativePowerup,
	LavaSettings = {
		Color = BrickColor.new ("Earth green"),
		Material = Enum.Material.Sand,
		Transparency = 0.3
	},
	FogSettings = {
		Color = Color3.fromRGB (130, 130, 130)
	},
	AISettings = {
		MovementLogic = require (sewer.AIMovementLogic)
	}
}

local MapData = {
	SewerMap
}

return MapData;