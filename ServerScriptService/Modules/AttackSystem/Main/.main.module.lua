local AS           = { };

-- ** Services ** --
local ServerScriptService = game:GetService ("ServerScriptService");
local CollectionService = game:GetService ("CollectionService");

-- ** Game Structure ** --
local modules = ServerScriptService.Modules;
local parents = modules.ParentClasses;

-- ** Dependencies ** --
local events = require (script.Events);
local Player = require (script.Player);
local Attack = require (script.Attack);

local EventSystem = require (parents.EventSystem);
local getCharacter = require (modules.GetCharacter);

-- ** Constants ** --
local DEF_ATTACK_TIMEOUT = 0.1;

-- ** Globals ** --
local mainAttackingSystem;

-- ** Collection Service ** --
CollectionService:AddTag (script, _G.GameTags.AttackSystem);

-- ** Constructor ** --
local AttackSystem = EventSystem.new();
function AS.new ()
	if (mainAttackingSystem) then return mainAttackingSystem; end
	
	local attackSystem = setmetatable ({
		_moduleName = "AttackSystem",
		
		_players = { },
		_attacks = { },
		
		_enabled = false
	}, AttackSystem);
	
	attackSystem:_init ();
	mainAttackingSystem = attackSystem;
	
	return attackSystem;
end
function AS:get ()
	-- If we have one already, it'll just return that;
	-- If we don't, we want the new one. Either way, use new()
	return AS.new();
end

-- ** Public Methods ** --
function AttackSystem:addPlayer (player, attackStats)
	local attackTimeout = attackStats and attackStats.Timeout or DEF_ATTACK_TIMEOUT;
	self:_initPlayer (player, attackTimeout, attackStats);
end
function AttackSystem:clear ()
	self:_delete (self._players);
	self:_delete (self._attacks);
end
function AttackSystem:removePlayer (player)
	self:_log ("Removing ", player);
	self:_removePlayer (player);
end

-- Fire method - for AI use of the AttackSystem
function AttackSystem:fire (player, target)
	local ray = self:_createRay (player, target);
	self:_onFired (player, ray);
end

-- ** Private Methods ** --
-- Initialization
function AttackSystem:_init ()
	-- Input events
	self:_connect (events.Fired.Event, self._onFired);
end

-- Player creation & deletion
function AttackSystem:_initPlayer (player, timeout, attackStats)
	self._players [player] = self:_createPlayerObject (player, timeout);
	self._attacks [player] = self:_createAttackObject (player, attackStats);
end
function AttackSystem:_removePlayer (player)
	local player, attack = self._players [player], self._attacks [player];
	
	player:remove ();
	attack:remove ();
	
	self._players [player] = nil;
	self._attacks [player] = nil;
end

-- Delete entire contents of a dictionary
function AttackSystem:_delete (dictionary)
	for player,object in pairs (dictionary) do
		object:remove ();
		dictionary [player] = nil;
	end
end

-- Create a ray from player, target data
function AttackSystem:_createRay (player, target)
	local character = getCharacter (player);
	local primary = character and character.PrimaryPart;
	local origin = primary and primary.Position;
	
	if (not origin) then
		self:_warn ("Origin position not found");
		return nil;
	end
	
	local direction = (target - origin).unit;
	return Ray.new (origin, direction);
end

-- Input Changes
function AttackSystem:_onFired (player, targetRay)
	self:_setCoordinates (player, targetRay);
	self:_fire (player)
end

-- Player fires
function AttackSystem:_playerFired (player, target)
	local attack = self:_getAttack (player);
	if (not attack) then return end
	
	attack:fire (target);
	
	self:_log (player, " has fired off towards ", target);
end

-- Main player interactions
function AttackSystem:_getPlayerObject (player)
	return self._players [player];
end
function AttackSystem:_fire (player)
	local playerObj = self:_getPlayerObject (player);
	if (not playerObj) then return end
	
	playerObj:fire ();
end
function AttackSystem:_setCoordinates (player, position)
	local playerObj = self:_getPlayerObject (player);
	if (not playerObj) then return end
	
	playerObj:move (position);
end

-- Player objects
function AttackSystem:_createPlayerObject (...)
	local player = Player.new (...);
	self:_connect (player.Fired.Event, self._playerFired);
	
	return player;
end

-- Attacks
function AttackSystem:_createAttackObject (...)
	return Attack.new (...);
end
function AttackSystem:_getAttack (player)
	return self._attacks [player];
end

AttackSystem.__index = AttackSystem;
return AS;