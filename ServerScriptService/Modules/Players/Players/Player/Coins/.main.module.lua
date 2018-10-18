--[[
	Controls the player's Coin balance in the game.
	
	Constructor takes two arguments (Player, [counter]):
		Player  - The player the Coins object will be used for;
		counter - The initial value of the player's coins balance. Defaults to 0,
		            but will be loaded from a data store.
	
	Has the following methods:
		balance () : Integer
			Returns the player's current coin balance.
		add (amount : Integer)
			Adds the specified number of coins to the player's balance.
		spend (amount : Integer) : Boolean
			Spends the specified number of coins, removing them from the player's balance,
			  assuming the player has at least that many coins.
			Returns a boolean indicating if the player was able to spend that much;
			  i.e. will return false if the player's balance was lower than the amount.
		canSpend (amount : Integer) : Boolean
			Determines if the player has enough balance to spend the given number of coins.
		save ()
			Saves the player's current balance to the data store so it may be reloaded later.
	
	Also has support for the following Metamethods:
		tostring (Coins)
			Returns a string matching the format
			  "Coins balance for #PLAYER with #COINS coins"
	
--]]

local C     = { };

-- ** Services ** --
local CollectionService = game:GetService ("CollectionService");
local ServerScriptService = game:GetService ("ServerScriptService");

-- ** Game Structure ** --
local modules = ServerScriptService.Modules;
local classes = modules.ParentClasses;

-- ** Dependencies ** --
local Module = require (classes.Module);
local PlayerStore = require (modules.DataStore.PlayerStore);

-- ** Constants ** --
local STORE_NAME = "Coins";

local UIRemote = require (CollectionService:GetTagged(_G.GameTags.UIRemote)[1]);

-- ** Constructor ** --
local Coins = PlayerStore.new(STORE_NAME);
function C.new (player, counter)
	assert (player, "Player is a required argument for the Coins object initialization");
	local coins = setmetatable ({
		_moduleName = "Player.Coins",
		
		_coins = counter,
		_coinsAdded = 0
	}, Coins);
	
	coins:_setPlayer (player);
	
	coins:_init ();
	return coins;
end

-- ** Public Methods ** --
function Coins:balance () return self._coins; end

function Coins:add (amnt)
	self:_add (amnt);

	self:_log ("Balance updated; sending to client");
	UIRemote.BalanceUpdated:Fire (self._player, self._coins)	
end
function Coins:spend (amnt)
	if (self._coins < amnt) then return false end
	self:_spend (amnt);
	
	return true;
end

function Coins:canSpend (amnt)
	return self._coins >= amnt;
end

-- ** Private Methods ** --
-- Initialization
function Coins:_init ()
	self:_load();
end

-- Coins Adding / Subtracting
function Coins:_add (amount)
	self._coins = self._coins + amount;
	self._coinsAdded = self._coinsAdded + amount;
end
function Coins:_spend (amount)
	-- Spending is just adding a negative amount
	-- Can use the same function, but with negative amount
	self:_add (amount * -1);
end

-- Data Store
function Coins:_getNewValue (originalValue)
	if (not originalValue) then return self._coins; end
	return originalValue + self._coinsAdded;
end
function Coins:_update (newValue)

	-- This is either going to be from a Save or a Load operation;
	-- In either case, we should have no added coins at this point
	self:_log ("Setting player's coin value to ", newValue);
	
	self._coins = newValue;
	self._coinsAdded = 0;
end

-- ** Metamethods ** --
function Coins:__tostring ()
	return "Coins balance for " .. self._player.Name .. " with " .. self._coins .. " coins";
end

Coins.__index = Coins;
return C;