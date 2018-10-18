local AIC = { };

-- ** Game Services ** --
local ServerScriptService = game:GetService ("ServerScriptService");
local CollectionService   = game:GetService ("CollectionService");

-- ** Game Structure ** --
local modules = ServerScriptService.Modules;
local classes = modules.ParentClasses;

-- ** Dependencies ** --
local Vision = require (script.Vision);
local getCharacter = require (modules.GetCharacter);
local DamageEffect = require (modules.DamageEffect.Main);
local EventSystem = require (classes.EventSystem);
local Characters = require (CollectionService:GetTagged (_G.GameTags.Characters) [1]).get();

-- ** Constants ** --
local REQD_PLYR_SCRIPTS = script.CharacterScripts:GetChildren()

-- ** Constructor ** --
local AICharacter = EventSystem.new ();
function AIC.new (layout, character, characterId, parent)
	local char = setmetatable ({
		_characterId = characterId,
		_characterModel = character,
		_layout = layout,
		_parent = parent,
		
		_vision = nil,
		
		_character = nil,
		_humanoid = nil,
		_root = nil,
		
		hasTakenDamage = false, -- set from the main controller
		
		MoveToFinished = Instance.new ("BindableEvent"),
		Died = Instance.new ("BindableEvent"),
		Damaged = nil
	}, AICharacter);
	
	char:_init ();
	return char;
end

-- ** Public Getters ** --
function AICharacter:getCharacter ()
	return self._character;
end

-- ** Public Methods ** --

-- Spawning
function AICharacter:applyCharacterStats (characterId)
	Characters:apply (self._character, characterId);
end
function AICharacter:spawn ()
	local floorLayout = self._layout;
	
	local spawnPoint = self:_findSpawnPoint (floorLayout);
	local targetPosition = self.getTarget (spawnPoint);
	
	self:_teleportTo (targetPosition);
	
	-- Reparent the character, adding him to the game
	self._character.Parent = self._parent;
end

-- Move to some point
function AICharacter:moveTo (position)
	self._humanoid:MoveTo (position);
end

-- Get the current space of the player
function AICharacter:getSpace ()
	local position = self:_getPosition ();
	return self._layout:spaceOfPosition (position, self._floor);
end

-- Gets the position of the character
function AICharacter:getPosition ()
	return self:_getPosition();
end

-- Check if the character is within range of a given player
function AICharacter:playerWithinRange (player, floorNum, hasSpottedPlayer)
	-- First check - The player isn't within range if they're on a different floor
	local playerFloor = player:FindFirstChild ("FloorNumber") and player.FloorNumber.Value;
	if (floorNum > playerFloor) then return false end
	
	-- Otherwise, compare the distances between the character & the player
	local character = getCharacter (player);
	return self._vision:canSee (character, hasSpottedPlayer or self.hasTakenDamage);
end

-- Humanoid methods
function AICharacter:jump ()
	self._humanoid.Jump = true;
end
function AICharacter:reset ()
	self._humanoid.Health = 0;
end

-- Removal
function AICharacter:remove ()
	self._character:Destroy ()
end

-- ** Private Methods ** --
function AICharacter:_init ()
	self:_initProperties ();
	self:_initEvents ();
	self:_initVision ();
	
	self:_initDamageEffect();
end

-- Property initialization
function AICharacter:_initProperties ()
	self._character = self:_initCharacter ();
	self._humanoid = self._character:FindFirstChildOfClass("Humanoid")
	self._root = self._character.PrimaryPart;
	
	self._lastHealth = self._humanoid.Health;
end
function AICharacter:_initCharacter ()
	local char = self._characterModel:Clone ();
	self:_addCharacterScripts (char);
	self:_addCharacterId (char);
	
	char.Parent = workspace;
	return char;
end
function AICharacter:_addCharacterScripts (character)
	for _,scr in pairs (REQD_PLYR_SCRIPTS) do
		local newScript = scr:Clone();
		newScript.Disabled = false;
		newScript.Parent = character;
	end
end
function AICharacter:_addCharacterId (character)
	local charId = Instance.new ("StringValue", character);
	charId.Name = "CharacterId";
	charId.Value = self._characterId;
end

-- Event initialization
function AICharacter:_initEvents ()
	self:_connect (self._humanoid.MoveToFinished, self.MoveToFinished);
	self:_connect (self._humanoid.Died, self.Died);
	self:_connect (self._root.Touched, self._checkJump);
end

-- Vision module initialization
function AICharacter:_initVision ()
	local sight = Characters:getSightDistance (self._characterId);
	self._vision = Vision.new (self._character, sight);
end

-- Damage effect
function AICharacter:_initDamageEffect ()
	local damageEffect = DamageEffect.new (self._character);
	self.Damaged = damageEffect.Damaged;
end

-- Checks if the player should jump after touching something
function AICharacter:_checkJump (hit)
	local isFloor = hit and hit:FindFirstChild("PartType") and hit.PartType.Value == "floor";
	if (isFloor) then
		self:jump()
	end
end

-- Find a spawn point from the grid layout
function AICharacter:_findSpawnPoint (gridLayout)
	local spawns = gridLayout:getSpawnPoints ();
	return spawns [math.random (1, #spawns)];
end

-- Teleport to a position
function AICharacter:_teleportTo (position)
	self._character:SetPrimaryPartCFrame (CFrame.new (position) + Vector3.new (0, 3, 0))
	self:_log ("After moving, the character is at ", self:_getPosition())
end

-- Get the current position of the player
function AICharacter:_getPosition ()
	return self._humanoid.RootPart.Position;
end

-- Uses the getTarget functionality to find target position
function AICharacter:_getTargetPosition (part, position, isSpawning)
	return self.getTarget (self._character, part, position, isSpawning);
end

AICharacter.__index = AICharacter;
return AIC;