-- This rotates the detector part so that it can be correctly applied
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
	[Direction.Right] = 90,
	[Direction.Left] = 270,
	[Direction.Up] = 0,
	[Direction.Down] = 180
}

-- ** Main Function ** --
function getDetectorRotation (grid, space)
	local startSpace = grid:getStartSpace();
	
	if (startSpace:isLeftOf (space)) then
		return rotations [Direction.Right];
	elseif (startSpace:isRightOf (space)) then
		return rotations [Direction.Left];
	elseif (startSpace:isBelow (space)) then
		return rotations [Direction.Up];
	elseif (startSpace:isAbove (space)) then
		return rotations [Direction.Down];
	else
		warn ("Could not find rotation for start space");
		return 0;
	end	
end

return getDetectorRotation;