local E = { };

-- ** Game Services ** --
local ServerScriptService = game:GetService ("ServerScriptService");

-- ** Game Structure ** --
local modules = ServerScriptService.Modules;
local classes = modules.ParentClasses;

-- ** Dependencies ** --
local ServerEvents = require (modules.ServerEvents.Main);
local EventSystem = require (classes.EventSystem);

-- ** Constructor ** --
local Events = EventSystem.new ("Tutorial_Events");
function E.new (player)
	local evts = setmetatable ({
		_player = player,
		
		FloorUpdated = Instance.new ("BindableEvent")
	}, Events);
	
	evts:_init ();
	return evts;
end

-- ** Private Methods ** --
-- Initialization
function Events:_init ()
	self:_connect (ServerEvents.AfterFloorReached.Event, self._floorUpdated);
	self:_connect (ServerEvents.PlayerAdded.Event, self._floorUpdated, 1);
end

-- Floor updated
function Events:_floorUpdated (player, ...)
	if (player ~= self._player) then return end
	self.FloorUpdated:Fire (...);
end

Events.__index = Events;
return E;