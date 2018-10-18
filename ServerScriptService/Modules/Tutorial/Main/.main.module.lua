local T        = { };

-- ** Game Structure ** --
local ServerScriptService = game:GetService ("ServerScriptService");

-- ** Game Structure ** --
local modules = ServerScriptService.Modules;
local classes = modules.ParentClasses;

-- ** Dependencies ** --
local Events = require (script.Events);
local Storage = require (script.Storage);
local GuideText = require (script.GuideText);

local RemoteEvents = require (modules.Remote.Remotes);

local EventSystem = require (classes.EventSystem);

-- ** Constructor ** --
local Tutorial = EventSystem.new ("Tutorial-Main")
function T.new (player)
	local tutorial = setmetatable ({
		_player = player,
		
		_events = Events.new (player),
		_storage = Storage.new (player),
		
		_lastFloor = nil
	}, Tutorial);
	
	tutorial:_init ();
	return tutorial;
end

-- ** Public Methods ** --
function Tutorial:sendMessage (message)
	self:_send (message)
end

-- ** Private Methods ** --
-- Initialization
function Tutorial:_init ()
	self:_connect (self._events.FloorUpdated.Event, self._reachedFloor);
	self:_connect (RemoteEvents.GuideCompleted.Event, self._finished);
end

-- Floor updated
function Tutorial:_reachedFloor (floorNumber)
	-- If the player has not yet reached that floor, present them w/ the tutorial
	-- For that floor
	if (self._storage:hasSeenTutorial (floorNumber)) then return end
	print ("Has not seen tutorial")
	
	local text = GuideText [floorNumber];
	if (not text) then return end
	
	self:_send (floorNumber, text);
end

-- Main sending method
function Tutorial:_send (floorNumber, message)
	self._lastFloor = floorNumber;
	RemoteEvents.GuideUpdated:Fire (self._player, message);
end

-- Seen tutorial
function Tutorial:_finished ()
	print ("Finished tutorial for ", self._lastFloor)
	self._storage:setSeen (self._lastFloor);
end

Tutorial.__index = Tutorial;
return T;