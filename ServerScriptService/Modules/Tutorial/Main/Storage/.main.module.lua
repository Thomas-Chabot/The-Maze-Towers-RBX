local S = { };

-- ** Game Services ** --
local ServerScriptService = game:GetService ("ServerScriptService");

-- ** Game Structure ** --
local modules = ServerScriptService.Modules;

-- ** Dependencies ** --
local PlayerStore = require (modules.DataStore.PlayerStore);

-- ** Constants ** --
local STORE_NAME = "Tutorial_Storage";

-- ** Constructor ** --
local Storage = PlayerStore.new (STORE_NAME);
function S.new (player)
	assert (player, "player not found");
	
	local storage = setmetatable ({
		
	}, Storage);
	
	storage:_setPlayer (player);
	return storage;
end

-- ** Public Methods ** --
function Storage:hasSeenTutorial (floorNumber)
	return self:_load (floorNumber) ~= nil;
end
function Storage:setSeen (floorNumber)
	self:_save (floorNumber)
end

-- ** Private Methods ** --
function Storage:_getNewValue ()
	return true;
end

Storage.__index = Storage;
return S;