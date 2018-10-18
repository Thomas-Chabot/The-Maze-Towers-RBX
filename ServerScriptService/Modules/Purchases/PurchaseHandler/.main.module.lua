--[[
	The module for controlling player purchases.
	
	Constructor takes no arguments;
	
	Has a single BindableFunction which must be bound to:
		Purchase (player : Player, value : Integer) : Boolean
			Called when a product has been made to validate the purchase.
			Arguments:
				player  The player who made the purchase
				value   The value of the purchase, eg. number of coins
			Expects: Boolean. Must be true if the purchase was added, false if failed.
			
	Notes:
		This is a singleton - will have unknown side effects if created multiple times
--]]
local P         = { };

-- ** Game Services ** --
local ServerScriptService = game:GetService ("ServerScriptService");
local MarketplaceService = game:GetService ("MarketplaceService");
local DataStoreService   = game:GetService ("DataStoreService");

-- ** Game Structure ** --
local modules = ServerScriptService.Modules;
local classes = modules.ParentClasses;

-- ** Game Services ** --
local Module = require (classes.Module);

-- ** Constants ** --
local PurchasesStore = DataStoreService:GetDataStore("PurchaseHistory");

-- ** Constructor ** --
local Purchases = Module.new();
function P.new ()
	local purchases = setmetatable ({
		Purchased = Instance.new ("BindableFunction")
	}, Purchases);
	
	purchases:_init ();
	return purchases;
end

-- ** Private Methods ** --
-- Initialization
function Purchases:_init ()
	self:_initReceiptHandler ();
end
function Purchases:_initReceiptHandler ()
	MarketplaceService.ProcessReceipt = function (...)
		return self:_process (...);
	end
end

-- Main processing event
function Purchases:_process (receiptInfo)
	local playerId = receiptInfo.PlayerId;
	local key      = self:_getProductKey (receiptInfo);
	
	if (self:_hasProcessed (key)) then
		return Enum.ProductPurchaseDecision.PurchaseGranted;
	end
	
	local player   = game.Players:GetPlayerByUserId(playerId);
	local value = self:_getProductValue (receiptInfo.ProductId);
	local valid = self:_addPurchase (player, value);
	
	if (not valid) then
		return Enum.ProductPurchaseDecision.NotProcessedYet;
	end
	
	self:_setProcessed (key);
	return Enum.ProductPurchaseDecision.PurchaseGranted;
end

-- Add the purchase, if valid
function Purchases:_addPurchase (player, value)
	if (not player or not value) then return false end
	return self.Purchased:Invoke (player, value);
end

-- Processed?
function Purchases:_setProcessed (productKey)
	PurchasesStore:SetAsync(productKey, true)
end
function Purchases:_hasProcessed (productKey)
	return PurchasesStore:GetAsync (productKey);
end

-- Main getters
function Purchases:_getProductValue (productId)
	return productId;
end
function Purchases:_getProductKey (receiptInfo)
	return receiptInfo.PlayerId .. ":" .. receiptInfo.PurchaseId
end


Purchases.__index = Purchases;
return P;