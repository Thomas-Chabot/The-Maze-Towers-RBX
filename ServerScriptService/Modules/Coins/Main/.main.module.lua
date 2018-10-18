local C     = { };

-- ** Game Services ** --
local ServerStorage = game:GetService ("ServerStorage");
local ServerScriptService = game:GetService ("ServerScriptService");
local MarketplaceService = game:GetService ("MarketplaceService");

-- ** Game Structure ** --
local modules = ServerScriptService.Modules;
local classes = modules.ParentClasses;

-- ** Game Dependencies ** --
local Module = require (classes.Module);

-- ** Data ** --
local data          = ServerStorage.Data;
local coinsData     = require (data.CoinsData);

-- ** Constructor ** --
local Coins = Module.new();
function C.new ()
	local coins = setmetatable ({
		_moduleName = "Coins",
		
		_data = coinsData,
		
		_coinsById = { },
		_coinsByProdId = { }
	}, Coins);
	
	coins:_init ();
	return coins;
end

-- ** Public Methods ** --
function Coins:get ()
	return self._data;
end
function Coins:getValueFromProductId (productId)
	local coins = self:_getByProdId (productId);
	return coins and coins.amount;
end


function Coins:purchase (player, id)
	self:_log ("Attempt to purchase ", id);
	local data = self:_getById (id);
	self:_purchase (player, data);
end

-- ** Private Methods ** --
-- Initialization
function Coins:_init ()
	for _,coins in pairs (self._data) do
		self._coinsById [coins.id] = coins;
		self._coinsByProdId [coins.ProductId] = coins;
	end
end

-- 
function Coins:_getById (id)
	return self._coinsById [id];
end
function Coins:_getByProdId (prodId)
	return self._coinsByProdId [prodId];
end

function Coins:_purchase (player, coinData)
	MarketplaceService:PromptProductPurchase(player, coinData.ProductId);
end

Coins.__index = Coins;
return C;