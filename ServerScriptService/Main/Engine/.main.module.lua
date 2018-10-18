-- ** Game Services ** --
local servScriptService = game:GetService ("ServerScriptService");
local replStorage       = game:GetService ("ReplicatedStorage");
local servStorage       = game:GetService ("ServerStorage")
local collectionService = game:GetService ("CollectionService");

-- ** Game Structure ** --
local modules     = servScriptService:WaitForChild("Modules");

local Grid        = modules:WaitForChild("Generator");
local Characters  = modules:WaitForChild("Characters");
local Classes     = modules:WaitForChild("ParentClasses");

local Globals      = require (modules.Globals.Init) ();
local UIRemote     = require (modules.UIRemote.Main);
local ServerEvents = require (modules.ServerEvents.Main);
local Remotes      = require (modules.Remote.Remotes);
local Generator    = require (Grid.Main);
local Direction    = require (Grid.Classes.Direction);
local Lava         = require (modules.LavaTimer);
local AttackSystem = require (modules.AttackSystem.Main);
local Characters   = require (Characters.Main).new ();
local Players      = require (modules.Players.Players);
local Coins        = require (modules.Coins.Main).new ();
local CurrentFloor = require (modules.CurrentFloor.Main);
local Tutorial     = require (modules.Tutorial.Main);
local AIPlayers    = require (modules.AISystem.Main);
local Purchases    = require (modules.Purchases.PurchaseHandler).new ();
local Assets       = require (modules.Asset);
local spawnPlayer  = require (modules.Spawning.Spawn);

local Module       = require (Classes.Module);

local players      = Players.new();
local attackSystem = AttackSystem.new ();

-- ** Events ** --
local PowerupEvt  = ServerEvents.PowerupActivated
local NegPowerEvt = ServerEvents.NegativePowerupActivated;

local DEFAULT_ID = Characters.Default;

-- ** Constants ** --
local DEF_GRID_SIZE = Vector2.new (20, 20);
local DEF_NUM_FLOORS = 5;
local DEF_PARENT = workspace.MazeMain;

-- Fog
local DEF_FOG_END = 1500;
local DEF_FOG_COLOR = Color3.fromRGB (87, 130, 130)

-- Build settings
local DEF_SPACE_SIZE = Vector3.new (25, 25, 25);
local DEF_BUILD_SETTINGS = {
	SpaceSize = Vector3.new (25, 15, 25),
	Grid = {
		Material = Enum.Material.Ice,
		BrickColor = BrickColor.new ("Really black"),
		Friction = 0.3
	},
	--[[Deadend = {
		Model = script.Powerup,
		Offset = Vector3.new (0, 2, 0)
	},]]
	Parent = DEF_PARENT
}

-- Settings for the rising lava
local DEF_LAVA_SETTINGS = {
	NumFloors = 5,
	TimeLimit = {
		150,
		0,
		0,
		0,
		0
	},
	RisingTime = {
		60,
		45,
		30,
		25,
		20
	},
	GridSize = DEF_SPACE_SIZE * Vector3.new (DEF_GRID_SIZE.X, 1, DEF_GRID_SIZE.Y),
	Offset = Vector3.new (0, 0, 0),
	Parent = DEF_PARENT
}

-- AI settings
local DEF_AI_SETTINGS = {
	numEnemies = {
		3,
		5,
		8
	}
}

-- Minigame prizes
local DEF_GAME_WINNINGS = 20; -- Number of coins for each win

-- ** Globals ** --
local activeGrid, activeLava;
local currentFloors = { };
local tutorials = { };

local aiPlayers    = AIPlayers.new (DEF_AI_SETTINGS);


-- ** Engine Functions ** --
local GameEngine = Module.new("GameEngine");

-- [ Game Setup ] --

-- Game Engine Functions
function GameEngine.generate (numRows, numColumns, numFloors)
	activeGrid = Generator.generate (numRows, numColumns, {NumFloors = numFloors})
end

function GameEngine.build (settings)
	if (not settings) then settings = { }; end
	local buildSettings = applySettings (settings, DEF_BUILD_SETTINGS);
	
	activeGrid:build (buildSettings)
end

function GameEngine.addTraps (...)
	activeGrid:addTraps (...);
end

function GameEngine.addLava (settings)
	DEF_LAVA_SETTINGS.GridSize = activeGrid:getFloorSize();
	
	local lavaSettings = applySettings (settings, DEF_LAVA_SETTINGS);
	activeLava = Lava.create (lavaSettings);
end

function GameEngine.setFog (fogColor)
	setFog (DEF_FOG_END, fogColor)
end

-- [ Game Ending ] --
function GameEngine.getGameWinnings (player)
	local gameWinnings = players:getGameWinnings (player);
	return gameWinnings;
end

function GameEngine.clear (parent)
	if (not parent) then parent = DEF_PARENT; end
	parent:ClearAllChildren();
	
	if (activeLava) then
		activeLava:remove ();
	end
	
	activeGrid:remove();
	aiPlayers:remove ();
	attackSystem:clear ();
	clearFog();
	
	players:reset ();
	
	activeGrid = nil;
	activeLava = nil;
	currentFloors = { };
end

-- [ Players Control ] --
function GameEngine.spawnPlayers (players)
	local added = { };
	for _,player in pairs (players) do
		if (addToGame (player)) then
			table.insert (added, player);
		end;
	end
	return added;
end
function GameEngine.removePlayer (player)
	attackSystem:removePlayer (player);
end

-- [ AI Players ] --
function GameEngine.setAISettings (settings)
	aiPlayers:updateSettings (settings);
end
function GameEngine.addAI ()
	aiPlayers:spawn (activeGrid);
end

-- [ Various Other Functions ] --
function GameEngine.addCoins (player, coins)
	addCoins (player, coins)
end
function GameEngine.sendMessage (player, message)
	local tutorial = tutorials[player];
	if (not tutorial) then return false end
	
	tutorial:sendMessage (message);
end

-- [ Game Ready ] --
function GameEngine.ready()
	Assets.Ready()
end

-- ** Helper Functions ** --
-- Add a new player to the game
function addToGame (player)
	local active = getActiveCharacterId(player);
	if (not Characters:apply (player, active)) then
		return false
	end;
	
	-- Add the player for attacking
	local attackStats = Characters:getAttackStats (active);
	attackSystem:addPlayer (player, attackStats);
	
	-- Set up the current floor
	initCurrentFloor (player);
	
	-- Set up player winnings
	setWinnings (player, DEF_GAME_WINNINGS);
	
	wait ()
	
	return placeInMaze (player);
end
function initCurrentFloor (player)
	currentFloors [player] = CurrentFloor.new (player, activeGrid:numFloors ());
end
function placeInMaze (player)
	local character = player and player.Character;
	if (not character) then return false end
	
	local spawns = collectionService:GetTagged (_G.GameTags.MazeSpawn);
	local spawner = spawns [math.random (1, #spawns)];
	
	GameEngine:_log ("Moving to ", spawner:GetFullName());
	spawnPlayer (player, spawner);
	
	-- Fire the event
	ServerEvents.PlayerAdded:Fire (player)
	
	return true;
end

-- Convert a Character object into the corresponding Player
function getPlayerFromCharacter (character)
	return game.Players:GetPlayerFromCharacter(character) or character;
end

-- Clear the fog from the game
function clearFog ()
	setFog (DEF_FOG_END, DEF_FOG_COLOR)
end
function setFog (fogEnd, color)
	game.Lighting.FogEnd = fogEnd;
	game.Lighting.FogColor = color;
end

-- Combine default settings w/ user specified settings
function applySettings (settings, defaults)
	if (not settings) then return defaults; end
	
	local newSettings = { };
	for key,value in pairs (defaults) do
		newSettings [key] = value;
	end
	for key,value in pairs (settings) do
		newSettings [key] = value; 
	end
	return newSettings;
end

-- Game engine utils
function getActiveCharacterId (player)
	-- If it's an AI
	if (player:FindFirstChild("CharacterId")) then
		return player.CharacterId.Value;
	end
	
	return players:getActiveCharacter (player);
end
function getUnownedCharacters (player)
	return Characters:getOwned (players:get (player), false)
end
function getInventory (player)
	return Characters:getOwned (players:get (player));
end
function getBalance (player)
	return players:getBalance (player)
end
function addCoins (player, value)
	players:addCoins (player, value);
end
function addTutorial (player)
	tutorials[player] = Tutorial.new (player);
end

-- Game winnings
function setWinnings (player, numCoins)
	players:setWinnings (player, numCoins);
	updateWinnings (numCoins);
end
function addToWinnings (player, numCoins)
	local newWinnings = players:addToGameWinnings (player, numCoins);
	updateWinnings (newWinnings);
end

-- Remove event updating
function updateBalance (player)
	UIRemote.BalanceUpdated:Fire (player, getBalance (player))	
end
function updateCharacter (player, ...)
	UIRemote.UpdateCharacter:Fire (player, ...);
end
function updateCharacters (player)
	UIRemote.CharactersUpdated:Fire (player, getUnownedCharacters (player));
end
function updateInventory (player)
	UIRemote.InventoryUpdated:Fire (player, getInventory (player));
end
function updateWinnings (player, winnings)
	UIRemote.WinningsUpdated:Fire (player, winnings);
end
function updateEquippedCharacter (player, id)
	if (not id) then id = getActiveCharacterId (player); end
	UIRemote.UpdateEquipped:Fire (player, id);
end
function fireError (player, errMsg)
	UIRemote.Errored:Fire (player, errMsg);
end

-- ** Server Events ** --
-- Powerups
PowerupEvt.Event:connect (function (character, orb)
	Characters:activatePowerup (getActiveCharacterId(character), character, orb);
end)
NegPowerEvt.Event:connect (function (character, orb)
	Characters:activateNegativePowerup (getActiveCharacterId(character), character, orb);
end)

-- Floor Reached
ServerEvents.FloorReached.Event:connect (function (character, floor, numFloors)
	local player = getPlayerFromCharacter (character);
	local curFloor = currentFloors [player];
	if (not curFloor) then return end
	
	curFloor:update (floor);
end)

-- Coin drops
ServerEvents.CoinsReceived.Event:connect (function (player, numCoins)
	GameEngine:_log (player, "has received", numCoins, "coins");
	addToWinnings (player, numCoins);
end)

-- ** Remote Events ** --
UIRemote.CharacterPurchaseRequest.Event:connect (function (player, character)
	local character = Characters:getById (character.Id);
	local valid, errMsg = players:buy (player, character);
	
	if (not valid) then
		GameEngine:_log ("Purchase failed with error message: ", errMsg);
		fireError (player, errMsg);
	else
		wait ()
		
		-- Fire off all the various updating events
		updateBalance (player);
		updateCharacter (player, character, true);
		updateInventory (player);
		updateCharacters (player);
	end
end)
UIRemote.CoinsPurchaseRequest.Event:connect (function (player, id)
	GameEngine:_log (player, " requests to purchase coins: ID ", id);
	Coins:purchase (player, id);
end)
UIRemote.CharacterEquipRequest.Event:connect (function (player, character)
	players:setActiveCharacter (player, character.Id);
	updateEquippedCharacter (player, character.Id);
end)

function UIRemote.GetBalance.OnInvoke (player)
	return getBalance (player);
end
function UIRemote.GetCoins.OnInvoke ()
	return Coins:get();
end
function UIRemote.GetCharacters.OnInvoke (player)
	return Characters:getOwned (players:get (player), false)
end
function UIRemote.GetInventory.OnInvoke (player)
	local ownedCharacters = getInventory (player);
	local equippedId = getActiveCharacterId(player);
	
	return {inventory = ownedCharacters, active = equippedId};
end

function Purchases.Purchased.OnInvoke (player, prodId)
	local value = Coins:getValueFromProductId (prodId);
	GameEngine:_log (player, " completed purchase for ", value, " coins");
	
	addCoins (player, value)
	return true;
end

-- ** Game Events ** --
game.Players.PlayerAdded:connect (addTutorial);
for _,player in pairs(game.Players:GetPlayers()) do addTutorial(player); end

return GameEngine;