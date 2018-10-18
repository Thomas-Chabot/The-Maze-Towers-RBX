local AIM    = { };

-- ** Game Services ** --
local ServerScriptService = game:GetService ("ServerScriptService");
local CollectionService   = game:GetService ("CollectionService");

-- ** Game Structure ** --
local modules = ServerScriptService.Modules;
local classes = modules.ParentClasses;

-- ** Dependencies ** --
local Module = require (classes.Module);
local CoinDrops = require (modules.Drops.Main);

local Characters = require (CollectionService:GetTagged (_G.GameTags.Characters) [1]).get();

local AI = require (script.AIControl);

-- ** Constants ** --
local DEF_NUM_ENEMIES = 2;

local MIN_COIN_DROP = 5;
local MAX_COIN_DROP = 10;

local DEF_MOVEMENT_LOGIC = function (part, pos)
	return pos;
end

local MAIN_PARENT = workspace.AI;

-- ** Constructor ** --
local AIMain = Module.new ();
function AIM.new (settings)
	if (not settings) then settings = { }; end
	
	local main = setmetatable ({
		_moduleName = "AI-Main",
		_grid       = nil,
		
		_numEnemies = settings.numEnemies,
		_numEnemiesDefault = DEF_NUM_ENEMIES,
		
		_coinDrop = CoinDrops.new(),
		
		_aiMovementLogic = settings.MovementLogic or DEF_MOVEMENT_LOGIC,
		
		_aiCharacters = { }
	}, AIMain);
	
	return main;
end

-- ** Public Methods ** --
function AIMain:updateSettings (settings)
	-- Changes value on settings for a new game
	if (not settings) then settings = { }; end
	
	if (settings.MovementLogic) then self._aiMovementLogic = settings.MovementLogic; end
	if (settings.numEnemies) then self._numEnemies = settings.numEnemies; end
end
function AIMain:spawn (grid, settings)
	self._grid = grid;
	self:_init ();
end
function AIMain:remove ()
	for _,ai in pairs (self._aiCharacters) do
		ai:remove ();
	end
end

-- ** Private Methods ** --
function AIMain:_init ()
	local numFloors = self._grid:numFloors ();
	for floorNum = 1,numFloors do
		self:_initFloor (floorNum);
	end
end
function AIMain:_initFloor (floorNum)
	local floorPlan = self._grid:getLayout (floorNum);
	local numEnemies = self:_getNumEnemiesOnFloor (floorNum);
	
	self:_spawnEnemies (floorPlan, numEnemies, floorNum);
end

-- The number of enemies to be placed on a given floor
function AIMain:_getNumEnemiesOnFloor (floorNum)
	-- If we've been given a value for that floor, just use that;
	-- Otherwise, return our default
	
	local ne = self._numEnemies and self._numEnemies [floorNum];
	return ne or self._numEnemiesDefault;
end

-- Enemy spawning - spawns the enemies into each floor
function AIMain:_spawnEnemies (floorPlan, numEnemies, floorNum)
	local mainParent = self:_getParent (floorNum);
	for _ = 1,numEnemies do
		self:_addEnemy (floorPlan, floorNum, {
			movementLogic = self._aiMovementLogic,
			parent = mainParent
		});
	end
end
function AIMain:_addEnemy (floorPlan, ...)
	local extraArgs = {...};
	
	-- Enemy needs to be given the character & the floor plan;
	-- We have the floor plan, so get the character
	local randCharId = Characters:random ();
	local randChar   = Characters:getCharacterModel (randCharId);
	
	local newAI    = AI.new (floorPlan, randChar, randCharId, ...);
	
	-- When the player dies, spawn a new one
	newAI.Died.Event:connect (function ()
		self:_log ("AI character died.");
		self:_dropCoins (newAI);
		
		wait (6)
		newAI:remove ();
		self:_addEnemy (floorPlan, unpack (extraArgs));
	end)
	
	-- Place it into our table of characters, for use later
	table.insert (self._aiCharacters, newAI);
end

-- Coin dropping
function AIMain:_dropCoins (ai)
	local numCoins = self:_getNumCoins ();
	local character = ai:getCharacter ();
	
	self._coinDrop:drop (character, numCoins);
end
function AIMain:_getNumCoins ()
	return math.random (MIN_COIN_DROP, MAX_COIN_DROP);
end

-- The parent object
function AIMain:_getParent (floorNum)
	local mainName = "Floor" .. floorNum;
	local main = MAIN_PARENT;
	
	-- If we have created the model before, return that
	if (main:FindFirstChild (mainName)) then
		return main[mainName];
	end
	
	-- If not, it's new, so add the model
	local model = Instance.new ("Model");
	model.Name = mainName;
	model.Parent = main;
	
	return model;
end

AIMain.__index = AIMain;
return AIM;