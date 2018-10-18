local AIC = { };

-- ** Game Services ** --
local ServerScriptService = game:GetService ("ServerScriptService");
local CollectionService   = game:GetService ("CollectionService");

-- ** Game Structure ** --
local modules = ServerScriptService.Modules;
local classes = modules.ParentClasses;

-- ** Dependencies ** --
local EventSystem = require (classes.EventSystem);

local Character = require (script.Character);
local Attacking = require (script.Attacking);
local Movements = require (script.Movements);

local Characters = require (CollectionService:GetTagged (_G.GameTags.Characters) [1]).get();

-- ** Defaults ** --
-- Once the player gets attacked, determines how long they'll check for
--  the attacker
local DAMAGE_SENSE_LENGTH = 5; 

-- Default parent
local DEF_PARENT = workspace;

-- ** Constructor ** --
local AIControl = EventSystem.new ();
function AIC.new (floorPlan, character, characterId, floorNum, settings)
	local aiControl = setmetatable ({
		_moduleName = "AIController",
		
		_details = {
			floorPlan = floorPlan,
			character = character,
			characterId = characterId,
			
			floorNum = floorNum
		},
		
		_parent = settings.parent or DEF_PARENT,
		
		_movementLogic = settings.movementLogic,
		
		_character = nil,
		_movement = nil,
		_attacking = nil,
		
		_characterObj = nil,
		
		_isAttacking = false,
		
		_removed = false,
		
		Died = Instance.new ("BindableEvent")
	}, AIControl);
	
	aiControl:_init ();
	return aiControl;
end

-- ** Public Getters ** --
function AIControl:getCharacter ()
	return self._characterObj;
end

-- ** Public Methods ** --
function AIControl:remove ()
	self._removed = true;
	self._character:remove ()
	self._attacking:stop();
end

-- ** Private Methods ** --
-- Initialization
function AIControl:_init ()
	self:_initCharacter ();
	self:_initMovements ();
	self:_initAttacking ();
	
	self:_move ();
end
function AIControl:_initCharacter ()
	local details = self._details;	
	
	local character = Character.new (details.floorPlan, details.character, details.characterId, self._parent);
	self._character = character;
	
	self:_addHelper (character)
	
	character:applyCharacterStats (details.characterId);
	character:spawn ();
	
	-- event connections
	self:_connect (character.MoveToFinished.Event, self._characterFinishedMoving);
	self:_connect (character.Died.Event, self._characterDied);
	self:_connect (character.Damaged.Event, self._characterDamaged);
	
	self._character = character;
	self._characterObj = character:getCharacter();
end
function AIControl:_initMovements ()
	local movements = Movements.new (self._details.floorPlan);
	self:_addHelper (movements);
	
	self._movement = movements;
end
function AIControl:_initAttacking ()
	local characterStats = Characters:getById (self._details.characterId);
	local attackStats = characterStats.AttackStats;
	
	self._attacking = Attacking.new(self._characterObj, attackStats);
end

-- Adds the helper function
function AIControl:_addHelper (object)
	local function getTarget (space, position)
		local char = self._character:getCharacter();
		local part = self._details.floorPlan:getPart (space);
		if (not position) then
			position = self._details.floorPlan:getSpacePosition (space);
		end
		
		return self:getTarget (char, part, position);
	end
	
	local function getPosition ()
		return self._character:getPosition();
	end
	
	object.getTarget = getTarget;
	if (not object.getPosition) then
		object.getPosition = getPosition;
	end
end

-- Character events
function AIControl:_characterFinishedMoving ()
	self:_proceed ();
end
function AIControl:_characterDied ()
	self.Died:Fire();
end
function AIControl:_characterDamaged ()
	self._character.hasTakenDamage = true;
	wait (DAMAGE_SENSE_LENGTH);
	self._character.hasTakenDamage = false;
end

-- Proceed - Determines the next course of action & proceeds
function AIControl:_proceed ()
	local playerWithinRange, player = self:_hasPlayerWithinRange ();
	
	if (playerWithinRange) then
		self:_attack (player);
	else
		self:_move ();
	end
	
	self._isAttacking = playerWithinRange;	
end

-- Main movement function
function AIControl:_move ()
	if (self._removed) then return end
	
	if (not self._movement) then
		self:_warn ("Movement not found");
		return;
	end

	-- Don't want to attack at this point	
	self._attacking:stop ();
	
	-- Find the next space to go after
	local space = self._character:getSpace();
	local nextPos, moveAction = self._movement:calculateNextMove (space);
	if (not nextPos and not moveAction) then
		self._character:reset();
		return
	end
	
	if (moveAction == Enum.PathWaypointAction.Jump) then
		self._character:jump();
		self:_move()
	else
		self._character:moveTo (nextPos);
	end
end

-- Main attack function
function AIControl:_attack (player)
	self._target = player;
	
	-- Start attacking
	if (not self._isAttacking) then
		self._attacking:startAttacking (player);
	end
	
	-- Move towards the attack's target
	local targetPos = self._attacking:getTargetPos();
	self._character:moveTo (targetPos)
end

function AIControl:_isAttackingPlayer (player)
	return self._isAttacking and self._target == player;
end

-- Check if a player is within range of the AI
function AIControl:_hasPlayerWithinRange ()
	for _,player in pairs(game.Players:GetPlayers()) do
		local isAttacking = self:_isAttackingPlayer (player);
		if (self._character:playerWithinRange (player, self._details.floorNum, isAttacking)) then
			return true, player;
		end
	end
	return false, nil;
end

-- Helper function for smaller modules
-- From a given space, find the target position
function AIControl:getTarget (...)
	return self._movementLogic (...);
end

AIControl.__index = AIControl;
return AIC;