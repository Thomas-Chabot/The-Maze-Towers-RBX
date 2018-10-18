local PS = { };

-- ** Game Services ** --
local ServerScriptService = game:GetService ("ServerScriptService");

-- ** Game Structure ** --
local modules = ServerScriptService.Modules;

-- ** Dependencies ** --
local DataStore = require (modules.DataStore.Base);
local Module = require (modules.ParentClasses.Module);

-- ** Constructor ** --
local PlayerStore = Module.new ("PlayerStore");
function PS.new (storeName, player)
	local playerStore = setmetatable ({
		_dataStore = DataStore.new (storeName),
		_player = player
	}, PlayerStore);
	
	return playerStore;
end

-- ** Public Methods ** --
function PlayerStore:save (...)
	self:_save (...);
end
function PlayerStore:load (...)
	self:_load (...);
end

-- ** Private Methods ** --
-- Set the player after initial constructor
function PlayerStore:_setPlayer (player)
	self._player = player;
end

-- Overloads - saving & loading
function PlayerStore:_save (...)
	-- NOTE: Needs to be called as a method, which can't be done from the data store.
	-- We can redirect this through a new helper function, declared locally
	local function getNewValue (...) return self:_getNewValue (...) end
	
	local newValue = self._dataStore:_save (getNewValue, self._player.UserId, ...);
	return self:_onValue (newValue);
end
function PlayerStore:_load (...)
	local value = self._dataStore:_load (self._player.UserId, ...);
	return self:_onValue (value);
end

-- Main method for reacting to a new value
function PlayerStore:_update (value)
	-- Should overload, if used
end

-- Reacts to an updated value
function PlayerStore:_onValue (value)
	if (not value) then return end
	
	self:_update (value);
	return value;
end


PlayerStore.__index = PlayerStore;
return PS;