--[[
	Grids are made up of SpaceTypes (1 to N x 1 to M). 
	They have an indication of start & end given by the 
	  StartSpace and EndSpace attributes, respectively.
	
	Grids will be generated by the Generator and built from the Builder classes.
	
	The constructor takes two arguments:
		numRows - Integer - The number of rows in the grid;
		numCols - Integer - The number of columns in the grid.
		
	A Grid instance has the following methods:
		getExitDirection () : Direction
			Purpose: Calculates & Returns the direction of the exit,
			           where the direction is which side the exit is to its
					   nearest empty space.
			Arguments: None
			Returns: Direction; Indicates the position of the exit. That is:
				Left = The exit is in the previous column from the floor;
				Right = The exit is in the next column from the floor;
				Up    = The exit is in the previous row of the floor;
				Down  = The exit is in the next row from the floor;
				nil   = The exit is completely surrounded by walls.
		reset ()
			Purpose: Resets the grid, replacing all spaces with walls.
		setResettable (space : Space, canReset : Boolean)
			Purpose: Sets whether or not a space will be reset by the reset () method.
			Arguments:
				space    Space     The space to set resettable / not resettable
				canReset  Boolean  Whether or not the space can be set to a wall.
			Returns: None
		
		getOpenPositions() : Array of Space
			Returns all possible points in the grid that could be used for spawning;
			  i.e. all floors
		
		getSpacePosition (space : Space) : Vector3
			Returns the space's position in the world.
		
		getOpenPaths (space : Space) : Array of Space
			Returns every possible move from the given space.
		
	The following getters:
		numColumns () : Integer
		numRows () : Integer
		getStartSpace () : Space
		getEndSpace () : Space
		getSpaceType (position : Space) : SpaceType
		getSpaceTypeRC (row : Integer, col : Integer) : SpaceType
		isResettable (space : Space) : Boolean
		
	And the following setters:
		setStartSpace (s : Space)
		setEndSpace (s : Space)
		setSpaceType (position : Space, spaceType : SpaceType)
	
	Note that getEndSpace & getStartSpace will return nil if no end/start space has been set
--]]

local Grid = { };
local G    = { };

local classes = script.Parent;

-- Dependencies
local Space = require (classes.Space);
local SpaceType = require (classes.SpaceType);
local Space3D = require (classes.Space3D);
local Direction = require (classes.Direction);

-- ** Constructor ** --
function G.new (numRows, numColumns)
	return setmetatable({
		_numColumns = numColumns,
		_numRows    = numRows,
		_endSpace   = Space.new (),
		_startSpace = Space.new (),
		_grid       = { },
		
		_parts = { },
		
		_floorNum = nil,
		_spaceSize = nil,
		
		_resettable = { }
	}, Grid);
end

function G.roof (numRows, numColumns)
	local grid = G.new (numRows, numColumns);
	grid:each (function (r, c)
		grid:setSpaceType (Space.new (r, c), SpaceType.Roof);
	end)
	return grid;
end

-- ** Public Methods ** --
-- Determines the direction the player will be moving from the exit
function Grid:getExitDirection (position)
	local exitPosition = position or self:getEndSpace ();
	
	-- Check each direction individually to find the floor
	-- Once floor is found, we can return the direction
	if (self:_isFloor (exitPosition + Direction.Up)) then
		return Direction.Down;
	elseif (self:_isFloor (exitPosition + Direction.Down)) then
		return Direction.Up;
	elseif (self:_isFloor (exitPosition + Direction.Left)) then
		return Direction.Right;
	elseif (self:_isFloor (exitPosition + Direction.Right)) then
		return Direction.Left;
	else
		return nil;
	end
end

-- Reset the Grid, returning everything to walls
function Grid:reset ()
	local start = self:getStartSpace ();
	self:_each (function (row, col)
		local space = Space.new (row, col);
		if (self:isResettable (space)) then
			self:setSpaceType (space, SpaceType.Wall);
		end
	end)
	self:setSpaceType (start, SpaceType.Floor);
end

-- Resettable
function Grid:setResettable (space, canReset)
	self._resettable [space] = canReset;
end

-- 3D Methods
function Grid:addPart (space, part)
	local row, col = space:getRow(), space:getCol();
	if (not self._parts [row]) then
		self._parts [row] = { };
	end
	
	self._parts [row] [col] = part;
end

-- ** Public Getters ** --
-- get floor num
function Grid:getFloor () return self._floorNum; end

-- Number of columns, rows in the maze
function Grid:numColumns() return self._numColumns; end
function Grid:numRows() return self._numRows; end

-- Spaces
-- Get the start, end spaces
function Grid:getStartSpace() return self._startSpace; end
function Grid:getEndSpace() return self._endSpace; end

-- SpaceType
-- Get the space type from Row, Column
function Grid:getSpaceTypeRC (row, column)
	local space = Space.new (row, column);
	return self:getSpaceType (space);
end

-- Get the space type at a given position
function Grid:getSpaceType (space)
	-- Special Cases
	if (space == self:getStartSpace()) then return SpaceType.Start; end
	if (space == self:getEndSpace()) then return SpaceType.End; end
	
	
	local colNum = space:getCol ();
	local rowNum = space:getRow ();
	
	if (not self:_withinBorder (colNum, rowNum)) then return SpaceType.None end
	
	local spaceType = self._grid [colNum] and self._grid [colNum] [rowNum];
	return spaceType or SpaceType.Default;
end

-- Resettable
function Grid:isResettable (space)
	local spaceType = self:getSpaceType (space);
	
	if (spaceType == SpaceType.None or spaceType == SpaceType.Start) then
		return false;
	end
	
	return self._resettable [space] ~= false;
end

-- Is the spot valid as an entry point - i.e. spawnable
function Grid:isOpen (row, column)
	-- The grid point is spawnable if the space type is in spawnable_points
	return self:isOpenSpace (Space.new (row, column));
end
function Grid:isOpenSpace (space)
	local spaceType = self:getSpaceType (space);
	return SpaceType.spawnable(spaceType);
end

-- 3D Spaces
function Grid:getPart (space)
	local row, col = space:getRow(), space:getCol();
	return self._parts[row] and  self._parts [row] [col];
end

-- ** Public Setters ** --
-- Set floor num
function Grid:setFloor (floor)
	self._floorNum = floor;
end

-- Set the start, end spaces
function Grid:setStartSpace (space)
	self._startSpace = space;
end
function Grid:setEndSpace (space)
	self._endSpace = space;
end

-- Set the spacetype at a given position
function Grid:setSpaceType (space, spaceType)
	local colNum = space:getCol ();
	local rowNum = space:getRow ();
	
	if (not self:_withinBorder (colNum, rowNum)) then return false end
	
	if (not self._grid [colNum]) then self._grid [colNum] = { }; end
	self._grid [colNum] [rowNum] = spaceType;
end

-- Set the space size of the grid
function Grid:setSpaceSize (size)
	self._spaceSize = size;
end

-- Total grid size
function Grid:getTotalSize ()
	return self * self._spaceSize;
end

-- ** Less Specific Helper Methods ** --

-- Find all valid entry points in a grid (i.e. can spawn on the point)
function Grid:getSpawnPoints ()
	local spawnPoints = { };
	self:_each (function (r, c)
		if (self:isOpen (r, c)) then
			table.insert (spawnPoints, Space.new (r, c));
		end
	end);
	return spawnPoints;
end

-- Find the number of paths traversable from a space
function Grid:getOpenPaths (startSpace)
	local paths = { };
	for _,dirVec in pairs (Direction) do
		local nextSpace = startSpace + dirVec;
		if (self:isOpenSpace (nextSpace)) then
			table.insert (paths, nextSpace);
		end 
	end
	return paths;
end

-- Run a method on every row & column of the grid
function Grid:each (f)
	return self:_each (f);
end

-- ** Methods w/ 3D Space ** --

-- Get the 3D position of a space
function Grid:getSpacePosition (space)
	self:_check3DReady ();	
	return Space3D.position (space:getRow(), space:getCol(), self._floorNum, self._spaceSize);
end

-- Get the space from a 3D Position
function Grid:spaceOfPosition (position)
	self:_check3DReady ();
	return Space3D.spaceOf (position, self._spaceSize);
end

-- Check if 3D is ready - has to have the space size
function Grid:_check3DReady ()
	assert (self._spaceSize, "The space size of the grid must be set before this method may be called.");
end


-- ** Private Methods ** --
-- Check if position is a floor
function Grid:_isFloor (position)
	return self:getSpaceType (position) == SpaceType.Floor;
end

-- Check if a given column & row are within the borders of the grid
function Grid:_withinBorder (column, row)
	if (self:_outside (column, self._numColumns)) then return false end
	return (not self:_outside (row, self._numRows))
end

-- Check if a given value is within the range 0 < value < max
function Grid:_outside (value, maxVal)
	return (value < 1 or value > maxVal);
end

-- String type at a given index
function Grid:_posToStr (position)
	if (position == self:getEndSpace()) then
		return SpaceType.string (SpaceType.End);
	elseif (position == self:getStartSpace()) then
		return SpaceType.string (SpaceType.Start);
	end
	return SpaceType.string (self:getSpaceType (position));
end

-- Run a function on every row & column in the grid
function Grid:_each (f)
	for row = 1,self._numRows do
		for col = 1,self._numColumns do
			f (row, col);
		end
	end
end

-- ** Metamethods ** --
function Grid:__tostring ()
	local str = "";
	self:_each (function (row, col)
		str = str .. self:_posToStr (Space.new (row, col));
		if (col == self._numColumns) then
			str = str .. "\n";
		end
	end)
	return str;
end

-- When multiplied by a Vector3, returns the size of the grid * grid size
function Grid:__mul (value)
	local numRows = self:numRows();
	local numCols = self:numColumns();
	
	return Vector3.new (numCols, 1, numRows) * value;
end

Grid.__index = Grid;
return G;