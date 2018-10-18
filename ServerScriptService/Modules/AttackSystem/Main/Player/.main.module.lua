local Player = { };
local P      = { };

-- ** Game Services ** --
local serverScriptService = game:GetService ("ServerScriptService");

-- ** Game Structure ** --
local modules = serverScriptService:FindFirstChild("Modules");

-- ** Dependencies ** --
local getCharacter = require (modules.GetCharacter);

-- ** Constructor ** --
function P.new (player, attackTimeout)
	local player = setmetatable ({
		_player = player,
		_attackTimeout = attackTimeout,
		
		_lastPosition = nil,
		_isFiring = false,
		_nextAttack = 0,
		
		Fired = Instance.new ("BindableEvent")
	}, Player);
	
	player:_init ();
	return player;
end

-- ** Public Methods ** --
function Player:fire ()
	self:_update ();
end
function Player:move (newPosition)
	self:_setAttackPosition (newPosition);
end
function Player:remove ()
	
end

-- ** Private Methods ** --
-- Initialization
function Player:_init ()
	self:_initProperties ();
end
function Player:_initProperties ()
	self._character = getCharacter (self._player);
	self._human = self._character and self._character:FindFirstChild ("Humanoid");
end

-- Main update
function Player:_update ()
	if (not self:_canFire()) then return end
	
	self:_fire ();
end

-- Firing
function Player:_fire ()
	if (self:_hasDied ()) then return end
	
	self.Fired:Fire (self._player, self:_getAttackPosition())
	self:_startWaitingTimeout (self._attackTimeout);
end

-- Attack timeout
function Player:_startWaitingTimeout (timeoutLength)
	local currentTime = tick ();
	local nextAttack = currentTime + timeoutLength;
	
	self._nextAttack = nextAttack;
end
function Player:_canFire ()
	local currentTime = tick ();
	local attackTime = self._nextAttack;
	
	return currentTime >= attackTime;
end

-- Attacking position
function Player:_getAttackPosition ()
	return self._lastPosition;
end
function Player:_setAttackPosition (p)
	self._lastPosition = p;
end

-- Player died?
function Player:_hasDied ()
	if (not self._human) then return true end
	return self._human.Health == 0;
end

Player.__index = Player;
return P;