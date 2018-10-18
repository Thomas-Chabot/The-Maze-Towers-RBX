local A = { };

-- ** Game Services ** --
local ServerScriptService = game:GetService ("ServerScriptService");
local CollectionService   = game:GetService ("CollectionService");

-- ** Game Structure ** --
local modules = ServerScriptService.Modules;
local classes = modules.ParentClasses;

-- ** Dependencies ** --
local Module = require (classes.Module);
local getCharacter = require (modules.GetCharacter);
local AttackSystem = require (CollectionService:GetTagged (_G.GameTags.AttackSystem) [1]);

-- ** Globals ** --
local attackSystem = AttackSystem:get();

-- ** Constants ** --
local MIN_ATTACK_EXTRA_TIMEOUT = 0.8;
local MAX_ATTACK_EXTRA_TIMEOUT = 1.2;

-- ** Constructor ** --
local Attacking = Module.new ();
function A.new (character, attackStats)
	local attacking = setmetatable ({
		_moduleName = "AI-Attacking",
		
		_character = character,
		_attackStats = attackStats,
		_attackTimeout = attackStats.Timeout,
		
		_isAttacking = false,
		_target = nil,
		_targetPart = nil,
		
		PlayerKilled = Instance.new ("BindableEvent")
	}, Attacking);
	
	attacking:_init ();
	
	return attacking
end

-- ** Public Methods ** --
function Attacking:startAttacking (player)
	if (self._isAttacking) then return end
	self._isAttacking = true;
	self._target = player;
	
	self:_setupTarget (player);
	
	self:_start ();
end
function Attacking:stop ()
	if (not self._isAttacking) then return end
	self._isAttacking = false;
end

function Attacking:getTargetPos ()
	return self._targetPart and self._targetPart.Position;
end

-- ** Private Methods ** --
function Attacking:_init ()
	attackSystem:addPlayer (self._character, self._attackStats);
end

-- set up the target
function Attacking:_setupTarget (player)
	-- Returns the position to chase after
	local character = getCharacter (player);
	local primary = character.PrimaryPart;
	
	self._targetPart = primary;
end

-- starts attacking, which handles firing off attacks
function Attacking:_start ()
	spawn (function ()
		while self._isAttacking do
			local targPos = self._targetPart and self._targetPart.Position;
			if (not targPos) then
				self:_warn ("Could not find position for ", self._target);
			else
				attackSystem:fire (self._character, targPos);	
			end
			
			self:_wait ();
		end
	end)
end

-- wait for next attack
function Attacking:_wait ()
	local extraTime = math.random (MIN_ATTACK_EXTRA_TIMEOUT, MAX_ATTACK_EXTRA_TIMEOUT);
	self:_log ("Wait time for next attack is", self._attackTimeout + extraTime); 
	wait (self._attackTimeout + extraTime);
end

Attacking.__index = Attacking;
return A;