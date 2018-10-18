--[[
	PUBLIC DOCUMENTATION:
		This module returns a single function which can be used to
		  get the Part Type & Rotation of a floor, given its surroundings.
		
		The function takes the following arguments:
		  topType    - SpaceType - SpaceType of the space above this one;
		  leftType   - SpaceType - The SpaceType of the space to the left;
		  rightType  - SpaceType - SpaceType of space to right;
		  bottomType - SpaceType - Type of space below this one.
		
		Returns a dictionary, containing two key-value pairs:
			Type     - FloorType - The type of floor to use for the part;
			Rotation - Integer   - The rotation for the part.
			                        This is either 0, 90, 180 or 270.
	
	
	MODULE EXPLANATION:
		
		This is very, very tricky to understand. It comes in steps.
		
		First, this is the logic for the part types:
				TOP  LEFT  RIGHT  BOTTOM     TYPE             ROTATION
				---  ----  -----  ------   ---------------    --------
				 0    0      0       1     DEADEND                0
				 0    0      1       0     DEADEND               90
				 0    0      1       1     LEFT TURN             90
				 0    1      0       0     DEADEND              270
				 0    1      0       1     LEFT TURN              0
				 0    1      1       0     STRAIGHT              90
				 0    1      1       1     THREE-WAY TURN         0
				 1    0      0       0     DEADEND              180
				 1    0      0       1     STRAIGHT               0
				 1    0      1       0     LEFT TURN            180
				 1    0      1       1     THREE-WAY TURN        90
				 1    1      0       0     LEFT TURN            270
				 1    1      0       1     THREE-WAY TURN       270
				 1    1      1       0     THREE-WAY TURN       180
				 1    1      1       1     FOUR-WAY STOP          0
				
		Where 0 indicates a wall & 1 indicates a floor.
		For example, when only the bottom is open, the position is a deadend.
		
		The rotation is based on where the openings are. It starts from assuming that
		  everything is based off being open at the bottom; when this isn't the case,
		  it will be rotated by the given amount.
		
		Then, the last step is to store everything. To do so, I will be taking these
		  values as binary digits - for example, 0001 is 1. 0010 is 2. Etc.
		This is all stored in the PART_TYPES array, and the conversions are performed
		  based on the given values.
--]]

--------------------------
-- ** Game Structure ** --
--------------------------
local partType = script.Parent;
local builder = partType.Parent;
local objects = builder.Parent;
local main    = objects.Parent;
local classes = main.Classes;

--------------------------
-- **  Dependencies  ** --
--------------------------
local FloorType = require (classes.FloorType)
local SpaceType = require (classes.SpaceType)
local exitRotation = require (script.ExitRotation)
local detectorRotation = require (script.DetectorRotation)

--------------------------
-- **   Constants    ** --
--------------------------
-- The different part types & rotations
local PART_TYPES = {
	{ -- 0001
		Type = FloorType.Deadend,
		Rotation = 0 
	},
	{ -- 0010
		Type = FloorType.Deadend,
		Rotation = 90
	},
	{ -- 0011
		Type = FloorType.LeftTurn,
		Rotation = 90
	},
	{ -- 0100
		Type = FloorType.Deadend,
		Rotation = 270
	},
	{ -- 0101
		Type = FloorType.LeftTurn,
		Rotation = 0
	},
	{ -- 0110
		Type = FloorType.Straight,
		Rotation = 90
	},
	{ -- 0111
		Type = FloorType.ThreeWayTurn,
		Rotation = 0
	},
	{ -- 1000
		Type = FloorType.Deadend,
		Rotation = 180
	},
	{ -- 1001
		Type = FloorType.Straight,
		Rotation = 0
	},
	{ -- 1010
		Type = FloorType.LeftTurn,
		Rotation = 180
	},
	{ -- 1011
		Type = FloorType.ThreeWayTurn,
		Rotation = 90
	},
	{ -- 1100
		Type = FloorType.LeftTurn,
		Rotation = 270
	},
	{ -- 1101
		Type = FloorType.ThreeWayTurn,
		Rotation = 270
	},
	{ -- 1110
		Type = FloorType.ThreeWayTurn,
		Rotation = 180
	},
	{ -- 1111
		Type = FloorType.FourWayTurn,
		Rotation = 0
	}
};

-- Spaces that are walls
local WALL_TYPES = {
	[SpaceType.Wall] = true
}

-- Spaces that are exits
local EXIT_TYPES = {
	[SpaceType.End] = true
}

-- The binary values of each direction
local TOP_BINARY = 8;
local LEFT_BINARY = 4;
local RIGHT_BINARY = 2;
local BOTTOM_BINARY = 1;


--------------------------
-- ** Main Functions ** --
--------------------------

-- Type Checkers
function checkIsWall (spaceType)
	return WALL_TYPES [spaceType] ~= nil;
end
function checkIsExit (spaceType)
	return EXIT_TYPES [spaceType] ~= nil;
end
function checkIsRoof (spaceType)
	return spaceType == SpaceType.Roof;
end
function checkIsNone (spaceType)
	return spaceType == SpaceType.None;
end

-- Floor type from surroundings table
function floorTypeFromSurroundings (surroundings)
	return getFloorType (surroundings.Top, surroundings.Left, 
		surroundings.Right, surroundings.Bottom);
end

-- Conversion function
function getFloorType (topType, leftType, rightType, bottomType)
	local topVal = getFloorValue (topType);
	local leftVal = getFloorValue (leftType);
	local rightVal = getFloorValue (rightType);
	local bottomVal = getFloorValue (bottomType);
	
	return typeFromValues (topVal, leftVal, rightVal, bottomVal)
end

-- The value of a space type - if it's a wall, it's 0; otherwise 1
function getFloorValue (spaceType)
	if (checkIsWall (spaceType)) then
		return 0;
	end
	
	return 1;
end

-- Get the part type from the given values
function typeFromValues (topVal, leftVal, rightVal, bottomVal)
	local arrayIndex = convertToArrayIndex (topVal, leftVal, rightVal, bottomVal);
	return PART_TYPES [arrayIndex];
end

-- Convert the binary digits into their decimal result
function convertToArrayIndex (top, left, right, bottom)
	-- Note: Lua has no simple way of binary conversion; has to be done manually
	return top * TOP_BINARY + left * LEFT_BINARY
	         + right * RIGHT_BINARY + bottom * BOTTOM_BINARY;
end


return {
	isWall = checkIsWall,
	isExit = checkIsExit,
	isNone = checkIsNone,
	isRoof = checkIsRoof,
	
	exitRotation = exitRotation,
	detectorRotation = detectorRotation,
	
	floorType = floorTypeFromSurroundings
};