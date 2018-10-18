local AIM = { };

-- ** Game Services ** --
local ServerScriptService = game:GetService ("ServerScriptService");
local CollectionService   = game:GetService ("CollectionService");

-- ** Game Structure ** --
local modules = ServerScriptService.Modules;
local classes = modules.ParentClasses;

-- ** Dependencies ** --
local Module = require (classes.Module);

-- ** Constants ** --
local Directions = {
	Vector2.new (1, 0),
	Vector2.new (-1, 0),
	Vector2.new (0, 1),
	Vector2.new (0, -1)
};

-- ** Constructor ** --
local Movements = Module.new ();
function AIM.new (floorLayout)
	local attacking = setmetatable ({
		_moduleName = "AI-Movements",
		_layout     = floorLayout,
		
		_currentPath = { },
		_currentPathIndex = 1,
		
		_lastDirection = Vector2.new (0, 0)
	}, Movements);
	
	return attacking;
end

-- ** Public Methods ** --
function Movements:calculateNextMove (space)
	if (self._currentPathIndex <= #self._currentPath) then
		-- If we have a precomputed path, follow that
		return self:_followPath ();
	end
	
	local path, direction = self:_calculatePaths (space);
	if (not path) then
		self:_log ("No path found");
		return;
	end
	
	self._lastDirection = direction;
	return self:_createPath (path);
end

-- ** Private Methods ** --
-- Stores Paths
function Movements:_followPath ()
	local move = self._currentPath [self._currentPathIndex];
	self._currentPathIndex = self._currentPathIndex + 1;
	
	return self.getTarget (move);
end
function Movements:_createPath (path)
	wait(0.1);
	
	self._currentPath = path;
	self._currentPathIndex = 1;
	
	return self:_followPath ();
end

-- Given a start space, calculate all possible paths from the space
function Movements:_calculatePaths (startSpace)
	local directionIndex = 0;
	local path = nil;
	local directions = {unpack (Directions)};
	
	while (not path) do
		local direction = self:_pickRandDirection (directions);
		local hasPath, path = self:_findPath (startSpace, direction)
		
		if (hasPath) then
			return path, direction;
		end
	end
	
	return nil, nil;
end

-- Given a space & direction, try to find a path in that direction
function Movements:_findPath (space, direction)
	local endSpace = space + direction;
	local path     = { };
	
	-- Keep moving in that direction until a wall of some kind
	while (self:_isValid (endSpace)) do
		table.insert (path, endSpace);
		
		-- If this is a part where there's many paths to choose from, end here
		if (endSpace ~= space and self:_isCrossroads (endSpace)) then
			break;
		end
		
		-- Otherwise, move forward to the next space
		endSpace = endSpace + direction;
	end
	
	-- Valid if we have some kind of path - i.e. not empty
	return #path > 0, path;
end

-- Checks if a move is valid
function Movements:_isValid (space)
	return self._layout:isOpenSpace (space);
end

-- Check if a space has several paths to choose from
function Movements:_isCrossroads (space)
	local paths = self._layout:getOpenPaths (space);
	return #paths > 2;
end

-- Pick a random direction from a table of directions
function Movements:_pickRandDirection (directions)
	local index = math.random (1, #directions);
	local value = directions [index];
	
	table.remove (directions, index);
	return value;
end

-- local nextPos = self._movement:calculateNextMove (space);
--   Returns Vector3
--   Passed in a Space


Movements.__index = Movements;
return AIM;