local D = { };

-- ** Services ** --
local ServerScriptService = game:GetService ("ServerScriptService");
local CollectionService = game:GetService ("CollectionService");

-- ** Game Structure ** --
local modules = ServerScriptService.Modules;
local parents = modules.ParentClasses;

-- ** Dependencies ** --
local Module = require (parents.Module);
local getCharacter = require (modules.GetCharacter);

-- ** Constants ** --
local COIN_TEMPLATE = script.Coin:Clone ();
local DROP_AMOUNTS  = 2;

-- ** Constructor ** --
local Drops = Module.new ("PlayerDrops");
function D.new ()
	return setmetatable ({
		_coins = COIN_TEMPLATE:Clone()
	}, Drops);
end

-- ** Public Methods ** --
-- Drops a coin from a given player, with a given value
function Drops:drop (player, numCoins)
	local position = self:_positionOf (player);
	if (not position) then return false end
	
	self:_dropCoins (numCoins, position);
end

-- ** Private Methods ** --
-- [ Main Methods ] --
-- Main drop method
function Drops:_dropCoins (numCoins, position)
	local coinValue = DROP_AMOUNTS;
	numCoins = self:_round (numCoins, coinValue);
	
	for i = 1,numCoins,coinValue do
		self:_drop (coinValue, position);
	end
end

-- Drop a single coin, with a given value & position
function Drops:_drop (coinValue, position)
	local coin = self:_createCoinsObj(coinValue);
	coin.Position = position + Vector3.new (0, 5, 0);
	coin.Parent = workspace;
end

-- Create the coin object
function Drops:_createCoinsObj (amount)
	local coin = self._coins:Clone ();
	coin.Amount.Value = amount;
	return coin;
end

-- [ Helper Methods ] --
-- Determine the position of a player
function Drops:_positionOf (player)
	-- Returns the positino of their root
	local character = getCharacter (player);
	local rootPart = character and character.PrimaryPart;
	if (not rootPart) then return end
	
	return rootPart.Position;
end

-- Round the number of coins up to be a multiple of the given value
function Drops:_round (numCoins, coinValue)
	-- Determine the multiple of the coins value - eg. if we have 9 coins & each has
	--   value of 2, that's 4.5 * the coin value - rounded up, 5 coins;
	local multVal = math.ceil (numCoins / coinValue);
	
	-- Once we have that multiple, we can give each the coinValue again for the final
	--  amount.
	return multVal * coinValue;
end


Drops.__index = Drops;
return D;