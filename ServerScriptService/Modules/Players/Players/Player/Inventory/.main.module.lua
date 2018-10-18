--[[
	Module for controlling a player's inventory.
	
	Constructor takes two arguments (player : Player, options : Dictionary)
		player: The player who the inventory is referencing
		options: Any of the following
			inventoryId  string  The ID to use for the inventory with DataStores.
			                     Defaults to "", having no specific ID.
	
	Has the following methods:
		getItems() : Array of Item
			Returns all the items that have been added to the inventory.
		addItem (item : Item)
			Adds the item to the player's inventory.
		owns (item : Item)
			Returns true if the player owns the given item.
		save ()
			Saves the player's inventory to a DataStore so that it may be reloaded later.
	
	Has as well the following metamethods:
		Inventory + Array of Item
			Returns a new array containing the combination of the inventory with
			 the given items.
		tostring (Inventory)
			Returns a stringified version of all Item names in the Inventory.
--]]

local I         = { };

-- ** Game Services ** --
local CollectionService = game:GetService ("CollectionService");
local ServerScriptService = game:GetService ("ServerScriptService");

-- ** Game Structure ** --
local modules = ServerScriptService.Modules;
local classes = modules.ParentClasses;

-- ** Dependencies ** --
local Module = require (classes.Module);
local PlayerStore = require (modules.DataStore.PlayerStore);

-- ** Constants ** --
local STORE_NAME = "Player-Inventories";

local Characters = require (CollectionService:GetTagged (_G.GameTags.Characters) [1]);
local DEFAULT_CHARACTERS = {
	Characters.Default
};

-- ** Constructor ** --
local Inventory = PlayerStore.new(STORE_NAME);
function I.new (player, options)
	assert (player, "The player is a required argument.");
	if (not options) then options = { }; end
	
	local inventory = setmetatable ({
		_moduleName = "Inventory",
		
		_items  = { },
		_owned  = { },
		_player = player,
		
		_id = options.inventoryId or ""
	}, Inventory);
	
	inventory:_setPlayer (player);
	inventory:_applyDefaults();
	inventory:_load ();
	
	return inventory;
end

-- ** Public Methods ** --
function Inventory:getItems ()
	return self._items;
end

function Inventory:addItem (item)
	table.insert (self._items, item);
	self._owned [item] = true;
end

function Inventory:owns (item)
	return self._owned [item] or false;
end

-- ** Private Methods ** --
function Inventory:_init ()
	self:_load ();
end

-- Data Store
function Inventory:_update (inventory)
	self:_setInventory (inventory);
	self:_applyDefaults ();
end
function Inventory:_getNewValue (inventory)
	if (not inventory) then return self._items; end
	return self:_mergeInventories (inventory)
end

-- Defaults
function Inventory:_applyDefaults ()
	for _,default in pairs (DEFAULT_CHARACTERS) do
		self:_log ("Add default character: ", default)
		if (not self._owned [default]) then
			self:addItem (default)
		end
	end
end
-- Set Inventory Contents
function Inventory:_setInventory (inventory)
	self._owned = { };
	
	for key,_ in pairs (self._owned) do table.remove (self._owned, key); end
	
	for _,item in pairs (inventory) do
		self._owned [item] = true;
	end
	self._items = inventory;
end

-- Merging Inventories
function Inventory:_mergeInventories (other)
	local newInventory = { };
	local added = { };
	
	self:_append (newInventory, self._items, added);
	self:_append (newInventory, other, added);
	
	return newInventory;
end
function Inventory:_append (resultTab, items, contentsDict)
	-- Interesting note here: contentsDict is used to ensure that there are no duplicate
	--   items. If the item is in contentsDict, we skip it; otherwise, it's not in the
	--   results table, so add it.
	for _,item in pairs (items) do
		if (not contentsDict [item]) then
			table.insert (resultTab, item);
			contentsDict [item] = true;
		end
	end
end

-- ** Metamethods ** --
function Inventory:__concat (otherInventory)
	return self:_merge (otherInventory);
end
function Inventory:__tostring ()
	local s = "Inventory containing:\n";
	for _,item in pairs (self._items) do
		s = s .. "\t" .. item.Name .. "\n";
	end
	return s;
end

Inventory.__index = Inventory;
return I;