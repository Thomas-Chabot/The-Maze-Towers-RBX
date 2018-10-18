local CF = { };

-- ** Game Services ** --
local CollectionService = game:GetService ("CollectionService");
local ServerScriptService = game:GetService ("ServerScriptService");

-- ** Game Structure ** --
local modules = ServerScriptService.Modules;
local classes = modules.ParentClasses;

-- ** Dependencies ** --
local UIRemote = require (CollectionService:GetTagged (_G.GameTags.UIRemote) [1]);
local ServerEvents = require (CollectionService:GetTagged (_G.GameTags.ServerEvents) [1]);
local Module = require (classes.Module);

-- ** Constructor ** --
local CurrentFloor = Module.new();
function CF.new (player, numFloors)
	local curFloor = setmetatable ({
		_moduleName = "CurrentFloor",
		
		_curFloor = 1,
		_numFloors = numFloors,
		_player = player,
		
		_floorValue = nil
	}, CurrentFloor);
	
	curFloor:_init ();
	return curFloor;
end

-- ** Public Methods ** --
function CurrentFloor:update (floorNum)
	if (floorNum <= self._curFloor) then return end
	
	self:_setFloorNum (floorNum);
	self:_update ();
end

-- ** Private Methods ** --
-- Initialization
function CurrentFloor:_init ()
	self:_initFloorVal();
end
function CurrentFloor:_initFloorVal ()
	local floorValue;
	
	if (self._player:FindFirstChild("FloorNumber")) then
		floorValue = self._player.FloorNumber;
	else
		floorValue = Instance.new ("IntValue", self._player);
		floorValue.Name = "FloorNumber";
	end	
	
	floorValue.Value = 1;
	self._floorValue = floorValue;
end

-- Set the floor number
function CurrentFloor:_setFloorNum (floorNum)
	self._curFloor = floorNum;
	self:_updateFloorValue ()
end

-- Performs updating of floor number
function CurrentFloor:_update ()
	self:_log (self._player, "reached floor", self._curFloor, "out of", self._numFloors);
	
	self:_updateFloorValue ();	
	self:_fireEvents ();
end
function CurrentFloor:_updateFloorValue ()
	self:_log ("Updating the floorValue", self._floorValue);
	self:_log ("Located within ", self._floorValue:GetFullName());
	self:_log ("Now on floor ", self._curFloor);
	
	self._floorValue.Value = self._curFloor;
end

-- Main event triggering
function CurrentFloor:_fireEvents ()
	UIRemote.FloorReached:Fire (self._player, self._curFloor, self._numFloors);
	
	wait ()
	ServerEvents.AfterFloorReached:Fire (self._player, self._curFloor, self._numFloors);
end

CurrentFloor.__index = CurrentFloor;
return CF;