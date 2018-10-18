local DS = { };

-- ** Game Services ** --
local ServerScriptService = game:GetService ("ServerScriptService");
local DataStoreService = game:GetService ("DataStoreService");

-- ** Game Structure ** --
local modules = ServerScriptService.Modules;
local classes = modules.ParentClasses;

-- ** Dependencies ** --
local Module = require (classes.Module);

-- ** Constructor ** --
local DataStore = Module.new ();
function DS.new (storeName)
	local store = setmetatable ({
		_storeName = storeName,
		_store = nil
	}, DataStore);
	
	store:_init ();
	return store;
end

-- ** Public Methods ** --

-- ** Private Methods ** --

-- Can be called to reset the store name, after initial constructor
-- Needed for anything inheriting from this class
function DataStore:_setStoreName (storeName)
	self._storeName = storeName;
	self:_init ();
end

-- Initialization
function DataStore:_init ()
	if (not self._storeName) then return end
	self._store = DataStoreService:GetDataStore(self._storeName);
end

-- Saving
function DataStore:_save (getNewValueFunc, ...)
	local key = self:_getKey (...);
	print (key)
	
	-- Uses UpdateAsync in case of an error on load;
	-- Adds the amount spent / added to the value saved in the store
	local val = self._store:UpdateAsync (key, function (originalValue)
		local newVal = getNewValueFunc (originalValue);
		
		self:_log ("Updating value to ", newVal);
		return newVal;
	end);

	return val;
end

-- Loading
function DataStore:_load (...)
	local key = self:_getKey (...);
	local value = self._store:GetAsync (key);
	print (key)
	
	return value;
end

-- Getters
function DataStore:_getKey (...)
	return "Key_" .. table.concat ({...}, "_");
end

DataStore.__index = DataStore;
return DS;