local Effect = { };

-- ** Game Structure ** --
local partType = script.Parent;
local builder = partType.Parent;
local objects = builder.Parent;
local main    = objects.Parent;
local classes = main.Classes;

-- ** Dependencies ** --
local SpaceType = require (classes.SpaceType);

-- ** Constants ** --
local TYPE_EFFECTS = {
	[SpaceType.None] = script.SensorScript,
	[SpaceType.Deadend] = require (script.Powerup),
	[SpaceType.Spawn] = require (script.Spawn)
}

-- ** Main Functions ** --
function Effect.apply (part, spaceType)
	local effect = TYPE_EFFECTS [spaceType];
	if (not effect) then return end
	
	if (typeof (effect) == "Instance") then
		addScript (effect, part);
	else
		run (effect, part);
	end
end

-- Helper Functions
-- Apply a script to the given part
function addScript (effect, part)
	effect:Clone().Parent = part;
end

-- Run a function
function run (effect, ...)
	effect (...);
end

return Effect;