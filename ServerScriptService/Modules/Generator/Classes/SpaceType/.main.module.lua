--[[
	Represents a single type at a given space in the grid.
	  The type can be either:
	    Floor   - This is a space players may walk on;
	    Wall    - This is a barrier in the maze;
	    Deadend - Same as a floor, but may be used for extra features in the maze
	                (walk to a dead end & something happens, for example)
	
	Also has a single metamethod. This converts a SpaceType into a stringified version.
--]]

local SpaceType = {
	None = 0,
	
	Floor   = 1,
	Wall    = 2,
	Deadend = 3,
	
	Spawn   = 4,
	Start   = 5,
	End     = 6,
	
	Roof    = 7
};

local spawnable = {
	[SpaceType.Floor] = true,
	[SpaceType.Spawn] = true,
	[SpaceType.Start] = true,
	[SpaceType.Deadend] = true
};

local strings = {
	[SpaceType.None] = "",
	[SpaceType.Floor] = "_",
	[SpaceType.Wall] = "#",
	[SpaceType.Spawn] = "S",
	[SpaceType.Start] = "S",
	[SpaceType.End] = "E",
	[SpaceType.Deadend] = "D",
	[SpaceType.Roof] = "R"
}

SpaceType.Default = SpaceType.Wall; -- Spaces that have not been specified

function SpaceType.string (t)
	local typ = strings [t];
	if (typ ~= "") then
		typ = pad (typ);
	end
	
	return typ;
end

-- Returns true if the spot is valid for player spwaning
function SpaceType.spawnable (t)
	return spawnable [t] ~= nil;
end

function SpaceType.__tostring (self)
	return SpaceType.string (self);
end

-- pads a string
function pad (str)
	return " " .. str .. " ";
end

return SpaceType;