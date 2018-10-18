--[[
	This is the main module for converting a Space into a single Part Type.
	
	The constructor takes two arguments, grid & settings:
		grid: The grid used for the build.
		settings: Dictionary. Any of the following parts (BasePart or Model):
			Wall
			Exit

			Deadend
			Straight
			RightTurn
			LeftTurn
			ThreeWayTurn
			FourWayTurn
		
			Note, for each of the floor types above, they should be assumed to be
			  coming from the bottom (i.e. would be directed up).
	
	Then has a single method:
		PartTypes:get (space : Space) : Part : PVInstance, Rotation : Integer
			Retrieves & Returns the part for the space along with its rotation.
--]]

local PT = { };
local PartTypes = { };

-- ** Game Structure ** --
local builder = script.Parent;
local objects = builder.Parent;
local main    = objects.Parent;
local classes = main.Classes;

-- ** Dependencies ** --
local Direction = require (classes.Direction);
local Model     = require (builder.Model)
local PartType  = require (script.Types);
local TypeEffects = require (script.Effects);

-- ** Constants ** --
local parts = script.Parts;
local floor = parts.Floor;

local DEF_PARTS = {
	Wall = parts.Wall,
	Exit = parts.ExitWedge,
	None = parts.Detector,
	Start = parts.Floor,
	
	-- Floor Types
	Deadend = floor,
	Straight = floor,
	RightTurn = floor,
	LeftTurn = floor,
	ThreeWayTurn = floor,
	FourWayTurn = floor,
	
	Roof = floor
}

local SURROUNDINGS = {
	Top = Direction.Up,
	Bottom = Direction.Down,
	Left = Direction.Left,
	Right = Direction.Right
}

-- ** Constructor ** --
function PT.new (grid, settings)
	local parts = PartTypes._getParts (settings);
	PartTypes._resizeParts (parts, settings);
	
	return setmetatable ({
		_grid = grid,
		_parts = parts,
		
		_floor = settings.FloorNumber
	}, PartTypes);
end

-- ** Public Methods ** --
function PartTypes:get (space)
	local spaceType = self:_getTypeOf (space)
	local part, rotation = self:_get (space, spaceType)
	part = part:Clone()
	
	-- Apply the effect, if any
	TypeEffects.apply (part, spaceType);
	
	-- Return the result
	return part, rotation;
end

-- ** Private Methods ** --
-- Get part from a given space type
function PartTypes:_get (space, spaceType)
	if (PartType.isWall (spaceType)) then
		return self._parts.Wall, 0;
	elseif (PartType.isExit (spaceType)) then
		return self._parts.Exit, PartType.exitRotation(self._grid);
	elseif (PartType.isNone (spaceType)) then
		return self._parts.None, PartType.detectorRotation(self._grid, space);
	elseif (PartType.isRoof (spaceType)) then
		return self._parts.Roof, 0;
	else
		return self:_getFloor (space, spaceType);		
	end
end
-- Given a space & SpaceType that's a floor, return the floor part
function PartTypes:_getFloor (space, spaceType)
	local surroundings = self:_getSurroundings (space);
	local floor = PartType.floorType (surroundings);
	
	local floorPart = self:_getFromFloorType (floor.Type, spaceType);
	return floorPart, floor.Rotation;
end

-- Given FloorType & SpaceType, return the floor w/ any added effects
function PartTypes:_getFromFloorType (floorType, spaceType)
	return self._parts[floorType];
end

-- Surrounding space types
function PartTypes:_getSurroundings (space)
	local surroundings = { };
	for name,direction in pairs (SURROUNDINGS) do
		surroundings [name] = self:_getTypeOf (space + direction);
	end
	return surroundings;
end

-- Get the space type
function PartTypes:_getTypeOf (space)
	return self._grid:getSpaceType (space);
end

-- ** Static Methods ** --
function PartTypes._getParts (parts)
	local results = { };
	for name,part in pairs (DEF_PARTS) do
		results [name] = parts[name] or part;
	end
	return results;
end
function PartTypes._resizeParts (parts, settings)
	local partSize = settings.SpaceSize;
	if (not partSize) then return end
	
	for index,part in pairs (parts) do
		if (part:IsA("BasePart") and not part:IsA("UnionOperation")) then
			if (part.Size.X == part.Size.Y) then
				part.Size = partSize;
			else
				part.Size = Vector3.new (partSize.X, 1, partSize.Z);
			end
		end
	end
end

PartTypes.__index = PartTypes;
return PT;