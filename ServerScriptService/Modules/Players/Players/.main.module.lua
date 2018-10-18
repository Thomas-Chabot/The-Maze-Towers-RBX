--[[
	The main module for controlling players, with access to Characters and Coins.
	Players are automatically added & coins can be purchased through Developer Products.
	
	Constructor takes no arguments;
	
	Available getters:
		getBalance (player : Player) : Integer
			Returns the given player's coin balance
		getCharacters (player : Player) : Array of Character
			Returns all characters purchased by the player (in the player's inventory)
		getActiveCharacter (player : Player) : CharacterId
			Returns the active character ID for the player.
		ownsCharacter (player : Player, characterId : CharacterId)
			Returns true if the player owns the given character.
		
	Available setters:
		setActiveCharacter (player : Player, active : CharacterId)
			Sets the active character ID for the player.
	
	Available methods:
		buy (player : Player, character : Character) : boolean
			Purchases the character for the specified price (from the Character object);
			  adds the character to the player's inventory, if they have enough coins.
			Returns true if the character purchase was successful; otherwise returns false.
	
	Side Effects:
		1. All purchases made through MarketplaceService will be handled by this module;
		     further purchases can not be added
		2. Players will automatically be added when they join the game, removed when they
		     leave
	
	Notes:
		1. This is a singleton - the object can only be created once				
--]]

local P       = { };

-- ** Game Services ** --
local ServerScriptService = game:GetService ("ServerScriptService");

-- ** Game Structure ** --
local modules = ServerScriptService.Modules;
local classes = modules.ParentClasses;

-- ** Dependencies ** --
local Player   = require (script.Player);
local Module   = require (classes.Module);

-- ** Constants ** --
local DELAY_SLOW = 10;
local DELAY_FAST = 1;

-- ** Globals ** --
local activePlayersObject;

-- ** Constructor ** --
local Players = Module.new();
function P.new ()
	if (activePlayersObject) then return activePlayersObject; end
	
	local players = setmetatable ({
		_moduleName = "Players",
		
		_players = { },
		
		_saving = { }
	}, Players);
	
	players:_init ();
	
	activePlayersObject = players;
	return players;
end

-- ** Public Methods ** --
-- Getters
function Players:getBalance (player)
	return self:_run (player, "getBalance");
end
function Players:getCharacters (player)
	return self:_run (player, "getCharacters");
end
function Players:getActiveCharacter (player)
	return self:_run (player, "getActiveCharacter");
end
function Players:ownsCharacter (player, character)
	return self:_run (player, "owns", character);
end
function Players:get (player)
	return self:_get (player);
end
function Players:getGameWinnings (player)
	return self:_run (player, "getGameWinnings");
end

-- Setters
function Players:setActiveCharacter (player, character)
	return self:_performSavedAction (player, DELAY_SLOW, "setActiveCharacter", character);
end
function Players:setWinnings (player, numCoins)
	self:_run (player, "setWinnings", numCoins);
end

-- Purchase
function Players:buy (player, item)
	return self:_performSavedAction (player, DELAY_FAST, "buy", item);
end
function Players:addCoins (player, numCoins)
	return self:_performSavedAction (player, DELAY_FAST, "addCoins", numCoins)
end

-- Game winnings
function Players:addToGameWinnings (player, numCoins)
	return self:_run (player, "addToGameWinnings", numCoins);
end

-- Resetting
function Players:reset ()
	for _,player in pairs (self._players) do
		player:reset ();
	end
end

-- ** Private Methods ** --
-- Initialization
function Players:_init ()
	self:_initPlayerAdding ();
end
function Players:_initPlayerAdding ()
	game.Players.PlayerAdded:connect (function (player)
		self:_addPlayer (player);
	end)
	game.Players.PlayerRemoving:connect (function (player)
		self:_removePlayer (player);
	end)
end

-- Players table altering
function Players:_addPlayer (player)
	if (self._players [player]) then return self._players [player] end
	
	local pObj = Player.new (player);
	self._players [player] = pObj;
	
	return pObj;
end
function Players:_removePlayer (player)
	local pObj = self:_get (player);
	pObj:save ();
	
	self._players [player] = nil;
end

-- Player saving
function Players:_savePlayer (player, delayTime)
	if (self._saving [player]) then return end
	self._saving [player] = true;
	
	spawn (function ()
		-- If the game is ending, just save here - don't bother with waiting
		if (#game.Players:GetPlayers() > 0) then
			wait (delayTime);
		end
		
		self:_log ("Saving", player);
		self:_run (player, "save");
		
		self._saving [player] = false;
	end)
end

-- Get a player
function Players:_get (player)
	-- In case this is the character, convert to their Player object
	player = self:_toPlayerObject (player);
	
	-- In case not added yet
	return self:_addPlayer (player);
end
function Players:_toPlayerObject (player)
	local playerObj = game.Players:GetPlayerFromCharacter(player);
	return playerObj or player;
end

-- Run a method on a specific player
function Players:_run (player, methodName, ...)
	local pObj = self:_get (player);
	local method = pObj and pObj [methodName];
	
	if (not method) then return false end
	return method (pObj, ...);
end

-- Perform an action & save
function Players:_performSavedAction (player, delayTime, ...)
	local valid, addArg1 = self:_run (player, ...);
	if (valid ~= false) then
		self:_savePlayer (player, delayTime);
	end
	
	return (valid ~= false), addArg1;
end



Players.__index = Players;
return P;