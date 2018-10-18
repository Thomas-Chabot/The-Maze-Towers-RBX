-- ** Game Services ** --
local ServerScriptService = game:GetService ("ServerScriptService");

-- ** Game Structure ** --
local powerups = script.Parent;
local modules  = ServerScriptService.Modules;

-- ** Dependencies ** --
local Selection = require (modules.Selection);

local JailCell = require (powerups.JailCell);
local Speed    = require (powerups.Speed);
local TrapDoor = require (powerups.TrapDoor);
local Health   = require (powerups.Health);

-- ** Constants ** --
local ODDS_TABLE = {
	{
		module = Speed,
		odds   = 0.5
	},
	{
		module = Health,
		odds   = 0.5
	},
	--[[{
		module = JailCell,
		odds   = 0.2
	},
	{
		module = TrapDoor,
		odds   = 0.1
	}]]
}

-- ** Selection Module ** --
return Selection.new (ODDS_TABLE, {
	selector = function(result) return result.module; end
});