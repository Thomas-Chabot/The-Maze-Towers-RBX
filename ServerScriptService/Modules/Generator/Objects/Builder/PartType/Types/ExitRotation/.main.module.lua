-- This rotates the exit wedge so that it can be correctly applied
--  to the main maze.

-- ** Structure ** --
local types = script.Parent;
local partType = types.Parent;
local builder = partType.Parent;
local objects = builder.Parent;
local main    = objects.Parent;
local classes = main.Classes;

-- ** Dependencies ** --
local Direction = require (classes.Direction);

-- ** Global Variables ** --

-- The table of rotations to apply. These depend on the position of the exit
--  along with the corresponding entry point.
local rotations = {
	[Direction.Right] = 0,
	[Direction.Left] = 180,
	[Direction.Up] = 90,
	[Direction.Down] = 270
}

-- ** Main Function ** --
function getWedgeRotation (grid)
	local direction = grid:getExitDirection ();
	local rotation = getRotation (direction);
	return rotation;
end

-- ** Helper Functions ** --
function getRotation (direction)
	return rotations [direction] or rotations [Direction.Right];
end

return getWedgeRotation;