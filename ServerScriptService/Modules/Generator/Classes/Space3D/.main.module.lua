-- Represents a Space in the 3D environment.
local Space3D = { };

-- Dependencies
local Space = require (script.Parent.Space);

-- Static Variables
Space3D.Offset = Vector3.new (0, 0, 0);

-- Calculate the position of a space
function Space3D.position (row, column, floorNum, spaceSize)
	if (not spaceSize) then
		spaceSize = floorNum;
		floorNum = 1;
	end
	
	assert (row, "Row is a required argument");
	assert (column, "Column is a required argument");
	assert (spaceSize, "SpaceSize is a required argument");
	
	return calculatePosition (row, column, floorNum, spaceSize, Space3D.Offset);
end

-- Calculate the space from a position
function Space3D.spaceOf (position, spaceSize)
	return calculateSpace (position, spaceSize, Space3D.Offset);
end


-- Helper Functions
-- Calculate the position of a row & column
function calculatePosition (row, column, floorNum, spaceSize, offset)
	local posX = (column - 1) * spaceSize.X;
	local posZ = (row - 1) * spaceSize.Z;
	
	return Vector3.new (posX, (floorNum - 1) * spaceSize.Y, posZ) + offset;
end

-- Calculate the row & column of a position
function calculateSpace (position, spaceSize, offset)
	position = position - offset;
	position = position + spaceSize/2;
	
	local rowNum = math.floor(position.Z / spaceSize.Z) + 1;
	local colNum = math.floor(position.X / spaceSize.X) + 1;
	
	return Space.new (rowNum, colNum);
end

return Space3D;