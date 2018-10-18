-- ** Game Services ** --
local ServerScriptService = game:GetService ("ServerScriptService");

-- ** Game Structure ** --
local powerups = script.Parent;
local modules  = ServerScriptService.Modules;

-- ** Dependencies ** --
local Selection = require (modules.Selection);

local Speed      = require (powerups.Speed);
local TrapPlacer = require (powerups.TrapPlacer);
local Health     = require (powerups.Health);

-- ** Constants ** --
local ODDS_TABLE = {
	{
		module = Speed,
		odds   = 0.4
	},
	{
		module = Health,
		odds   = 0.4
	},
	{
		module = TrapPlacer,
		odds   = 0.2
	}
};

-- ** Selection Module ** --
return Selection.new (ODDS_TABLE, {
	selector = function(result) return result.module; end
});