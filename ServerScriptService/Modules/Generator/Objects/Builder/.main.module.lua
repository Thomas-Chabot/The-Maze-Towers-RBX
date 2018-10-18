--[[
	This is the improved Builder module, V2.
	
	Constructor takes the Grid and various settings.
		The settings may contain:
			Parent   -> Instance
			Name     -> String    Indicates Name of main model
			SpaceSize -> Vector3
			Offset   -> Vector3
			
			Along with a variety of parts:
				Wall
				Exit
				Roof
	
				Deadend
				Straight
				LeftTurn
				ThreeWayTurn
				FourWayTurn
		
				Note, for each of the floor types above, they should be assumed 
				  to be coming from the bottom (i.e. the panel to the bottom is open).
--]]

local B = { };

-- ** Game Services ** --
local ServerScriptService = game:GetService ("ServerScriptService");

-- ** Default Values ** --
local DEF_OFFSET = Vector3.new (0, 0, 0) -- Default to the origin
local DEF_PART_OFFSET = Vector3.new (0, 0, 0) -- Offset for a model vs. floor

-- ** Structure ** --
local objects = script.Parent;
local main    = objects.Parent;
local classes = main.Classes;

local modules = ServerScriptService.Modules;
local parentClasses = modules.ParentClasses;

-- ** Dependencies ** --
local Grid    = require (classes.Grid);
local Space3D = require (classes.Space3D);
local Space   = require (classes.Space);
local SpaceType = require (classes.SpaceType);

local PartType = require (script.PartType);
local Model    = require (script.Model);

local Module = require (parentClasses.Module);

-- ** Constructor ** --
local Builder = Module.new ("Builder");
function B.build (grid, settings)
	local mainModel = Builder:_createMainModel (settings);

	-- Apply the space size to the grid	& Space3D
	grid:setSpaceSize (settings.SpaceSize);
	
	-- Create the builder
	local builder = setmetatable ({
		_grid = grid,
		_parts = PartType.new(grid, settings),
		
		_isRoof = settings.isRoof,
		_floorNum = settings.FloorNumber,
		
		_size   = settings.SpaceSize,
		_offset = settings.Offset or DEF_OFFSET,
		_parent = mainModel,
	}, Builder);
	
	builder:_build();
	return builder;
end

-- ** Public Getters ** --
function Builder:getGridSize ()
	return self._grid:getTotalSize();
end

-- ** Private Methods ** --
-- Main build method
function Builder:_build ()
	self._grid:each (function (row, column)
		self:_place (row, column);
	end)
end

-- Place the part for a given space
function Builder:_place (row, column)
	local space = Space.new (row, column);
	local part, rotation = self._parts:get (space);
	
	self:_placePart (space, part, rotation);
end
function Builder:_placePart (space, part, rotation)
	local position = self:_getPosition (space);
	local newPart = part:Clone();
	
	Model.reposition (newPart, position);
	Model.rotate (newPart, rotation);
	
	-- add the part to the grid
	self._grid:addPart (space, newPart);
	
	-- finalize the part adding
	self:_addPart (newPart);
end

-- Add a new part
function Builder:_addPart (part)
	self:_setFloor (part, self._floorNum);
	part.Parent = self._parent;
end
function Builder:_setFloor (part, floorNumber)
	local floorVal = part:FindFirstChild("FloorNum");
	if (not floorVal) then
		floorVal = Instance.new ("IntValue");
		floorVal.Name = "FloorNum";
		floorVal.Parent = part;
	end
	
	floorVal.Value = floorNumber;
end

-- Position of a space
function Builder:_getPosition (space)
	return Space3D.position (space:getRow(), space:getCol(), self._floorNum, self._size);
end

-- Create the main model
function Builder:_createMainModel (settings)
	local name,parent,floor = settings.Name, settings.Parent, settings.FloorNumber;
	if (not parent) then parent = workspace; end
	
	local model = Instance.new ("Model");
	model.Name = name or "Maze_Floor" .. floor;
	model.Parent = parent;
	
	return model;
end


Builder.__index = Builder;
return B;