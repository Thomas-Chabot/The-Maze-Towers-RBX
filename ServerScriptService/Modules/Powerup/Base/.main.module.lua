local PB          = { };

-- ** Game Services ** --
local ReplicatedStorage = game:GetService ("ReplicatedStorage");
local CollectionService = game:GetService ("CollectionService");
local ServerScriptService = game:GetService ("ServerScriptService");

-- ** Game Structure ** --
local data = ReplicatedStorage:WaitForChild ("Data");
local uiRemote = CollectionService:GetTagged (_G.GameTags.UIRemote) [1];

local modules = ServerScriptService.Modules;
local classes = modules.ParentClasses;

-- ** Dependencies ** --
local PowerupTypes = require (data.PowerupTypes);
local UIRemote = require (uiRemote);

local Module = require (classes.Module);

-- ** Constructor ** --
local PowerupBase = Module.new()
function PB.new (name, powerType, length)
	return setmetatable ({
		_moduleName = "PowerupBase",
		
		_name = name,
		_powerType = powerType,
		_length = length
	}, PowerupBase);
end

-- ** Public Methods ** --
-- Main method - activates the powerup
function PowerupBase:activate (character, orb)
	self:_signal (character);
	
	-- Run the effect. If it returns any data, pass that to the removal
	local data = self:_effect (character, orb);
	
	wait (self._length);
	self:_removeEffect (character, orb, data);
end

-- ** Private Methods ** --
-- Signalling the player
function PowerupBase:_signal (character)
	local player = self:_playerFromCharacter (character)
	if (not player) then return end
	
	UIRemote.PowerupActivated:Fire (player, self._name, self._powerType);
end

-- Effect Control
function PowerupBase:_effect (character, orb)
	-- Must be overloaded
end
function PowerupBase:_removeEffect (character, orb)
	-- Must be overloaded
end

-- Helpers
function PowerupBase:_playerFromCharacter (character)
	return game.Players:GetPlayerFromCharacter (character);
end
function PowerupBase:_humanoid (character)
	return character:FindFirstChild ("Humanoid");
end

PowerupBase.__index = PowerupBase;
PB.Types = PowerupTypes;
return PB;