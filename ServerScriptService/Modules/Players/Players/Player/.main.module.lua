--[[
	The main module for interacting with Players.
	This controls the player's Coin balance as well as their character inventories.
	
	The constructor takes a single argument, player, the player the object is being
	  created for.
	
	Has the following getters:
		getCharacters() : Array of Item
			Returns the player's Character inventory.
		getBalance() : Integer
			Returns the player's Coin balance.
		getActiveCharacter () : Integer
			Returns the active character ID.
		owns (item : Item) : Boolean
			Returns true if the player owns the given item.
	
	The following setters:
		setActiveCharacter (characterId : Integer)
			Sets the active character ID.
		
	As well as the following methods:
		addCoins (amount : Integer)
			Adds the specified number of coins to the player's coin balance.
		buy (item : Item) : Boolean
			Purchases the given item, adding it to the player's inventory, if they have
			  enough coins.
			Returns a boolean indicating if the purchase was successful.
		save ()
			Saves the player's characters inventory & coins balance to data stores.
			Should be called on player removing.
--]]

local P      = { };

-- ** Structure ** --
local sss = game:GetService ("ServerScriptService");
local collService = game:GetService ("CollectionService");
local modules = sss:FindFirstChild ("Modules");
local classes = modules.ParentClasses;

-- ** Dependencies ** --
local Coins = require (script.Coins);
local Inventory = require (script.Inventory);
local Active = require (script.Active);
local Winnings = require (script.GameWinnings);

local Characters = require (collService:GetTagged (_G.GameTags.Characters) [1]);

local Module = require (classes.Module);

-- ** Constants ** --
local DEFAULT_CHARACTER = Characters.Default;

local ERR_MSG_OWNED = "You already own this character.";
local ERR_MSG_NOT_ENOUGH_COINS = "You do not have enough coins to purchase this character.";
local ERR_MSG_SERVER_ERROR = "Server Error";

local START_COINS = 200;

-- ** Constructor ** --
local Player = Module.new();
function P.new (player)
	local player = setmetatable ({
		_moduleName = "Player",
		
		_player = player,
		
		_inventory = Inventory.new (player, {inventoryId = "Characters"}),
		_coins     = Coins.new (player, START_COINS),
		_winnings  = Winnings.new (),
		
		_activeCharacter = Active.new (player, DEFAULT_CHARACTER)
	}, Player);
	player:_init ()
	
	return player;
end

-- ** Public Methods ** --

-- Data Saving
function Player:save ()
	self._inventory:save ();
	self._coins:save ();
	self._activeCharacter:save ();
end

-- Getters, Setters
function Player:getCharacters ()
	return self._inventory:getItems ();
end
function Player:getBalance ()
	return self._coins:balance ();
end
function Player:owns (item)
	return self._inventory:owns (item);
end
function Player:getActiveCharacter ()
	return self._activeCharacter:get ();
end
function Player:setActiveCharacter (character)
	self._activeCharacter:set (character);
end
function Player:getGameWinnings ()
	return self._winnings:get ();
end
function Player:setWinnings (numCoins)
	self._winnings:set (numCoins);
end

-- Coins purchasing
function Player:addCoins (amount)
	self._coins:add (amount);
end

-- Buy an item
function Player:buy (item)
	-- Check one: If player already owns the character, can't buy again
	if (self:owns (item.Id)) then return false, ERR_MSG_OWNED; end
	
	local canBuyItem = self._coins:canSpend (item.Price);
	if (not canBuyItem) then self:_log("Not enough coins"); return false, ERR_MSG_NOT_ENOUGH_COINS; end
	
	if (not self._coins:spend (item.Price)) then
		self:_log ("Error occured during spend");
		return false, ERR_MSG_SERVER_ERROR; 
	end
	
	self._inventory:addItem (item.Id);
	return true;
end

-- Game winnings
function Player:addToGameWinnings (amount)
	self._winnings:add (amount);
	
	-- returns the new total
	return self._winnings:get ();
end

-- Reset
function Player:reset ()
	self._winnings:reset ();
end

-- ** Private Methods ** --
function Player:_init ()
	self._inventory:addItem (DEFAULT_CHARACTER);
end

Player.__index = Player;
return P;