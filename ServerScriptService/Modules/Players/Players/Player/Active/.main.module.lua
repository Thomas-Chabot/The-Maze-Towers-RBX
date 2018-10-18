local AC              = { };

-- ** Game Services ** --
local DataStoreService = game:GetService ("DataStoreService");
local CollectionService = game:GetService ("CollectionService");
local ServerScriptService = game:GetService ("ServerScriptService");

-- ** Game Structure ** --
local modules = ServerScriptService.Modules;
local classes = modules.ParentClasses;

-- ** Dependencies ** --
local characters = require (CollectionService:GetTagged (_G.GameTags.Characters) [1]).new();
local PlayerStore = require (modules.DataStore.PlayerStore);

-- ** Constants ** --
local STORE_NAME = "ActiveCharacter";

-- ** Constructor ** --
local ActiveCharacter = PlayerStore.new(STORE_NAME);
function AC.new (player, default)
	local activeChar = setmetatable ({
		_moduleName = "ActiveCharacter",
		
		_active = default
	}, ActiveCharacter);
	
	activeChar:_setPlayer (player);
	activeChar:_load ();
	return activeChar;
end

-- ** Public Methods ** --
function ActiveCharacter:get ()
	return self._active;
end

function ActiveCharacter:set (character)
	self._active = character;
end

-- ** Private Methods ** --
function ActiveCharacter:_getNewValue()
	return self._active;
end
function ActiveCharacter:_update (active)
	if (not characters:exists (active)) then return end
	
	self:_log ("Active character is ", active);
	self._active = active;
end

ActiveCharacter.__index = ActiveCharacter;
return AC;