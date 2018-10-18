local InsertService = game:GetService ("InsertService");
local AssetService  = game:GetService ("AssetService");
local ServerScriptService = game:GetService ("ServerScriptService");
local ReplicatedStorage = game:GetService ("ReplicatedStorage");

local Module = require (ServerScriptService.Modules.ParentClasses.Module);

local assetsParent = ReplicatedStorage.Assets;

local assets  = { };
local loading = { };
local loadingIndex = 1;

local isRunning = false;

local ASSET_TYPE_LOADERS;

local AssetLoader = Module.new ("AssetLoader");
AssetLoader.AssetTypes = {
	Package = "Package",
	Asset   = "Asset",
	Url     = "Url",
	Model   = "Model"
};

-- Main AssetLoader functions
-- Add a new item to load
function AssetLoader.add (item, assetType)
	AssetLoader:_log ("Adding new asset: ", item, " of type ", assetType);
	
	table.insert (loading, {
		item = item,
		assetType = assetType
	});
	
	-- Start loading items
	start();
end

-- Get the list of loaded items
function AssetLoader.get ()
	if (not loaded()) then
		AssetLoader:_log ("Not yet loaded; returning what is ready")
	end
	
	return assets, loaded();
end

-- Count of the number of assets
function AssetLoader.count()
	return #loading;
end

-- Assets are ready
function AssetLoader.isReady ()
	return loaded()
end

-- ** Helper Functions ** --
-- Starts up the loading process
function start()
	if (isRunning) then return end
	isRunning = true;
	
	spawn (function ()
		loadNext();
		isRunning = false;
	end)
end

-- Loading 
function loaded ()
	return loadingIndex > #loading;
end

function loadNext ()
	if (loaded()) then
		AssetLoader:_log ("Completed loading assets")
		return
	end
	
	local nextAsset = loading [loadingIndex];
	AssetLoader:_log ("Adding asset ", loadingIndex)
	
	loadingIndex = loadingIndex + 1;	
	
	table.insert (assets, loadItem (nextAsset));
	loadNext();
end

-- Main loading method
function loadItem (asset)
	local loader = ASSET_TYPE_LOADERS[asset.assetType];
	if (not loader) then return nil end
	
	local result = loader (asset.item);
	result.Parent = assetsParent;
	
	AssetLoader:_log ("Loaded asset ", asset.item);
	return result;
end

-- The various loading helper methods
function loadPackage (package)
	local assets = AssetService:GetAssetIdsForPackage(package);
	local main = Instance.new ("Folder");
	
	for _,asset in pairs (assets) do
		local newAsset = insertAsset (asset);
		if (newAsset) then
			newAsset.Parent = main;
		end
	end
	
	return main;
end
function loadAsset (asset)
	return insertAsset (asset);
end
function loadUrl (url)
	local decal = Instance.new ("Decal");
	decal.Texture = url;
	
	return decal;
end
function loadModel (model)
	return model:Clone();
end

-- Set up the loaders
ASSET_TYPE_LOADERS = {
	Package = loadPackage,
	Asset   = loadAsset,
	Url     = loadUrl,
	Model   = loadModel
};

-- Main asset inserter funtion
function insertAsset (id)
	local result;
	pcall (function ()
		result = InsertService:LoadAsset(id);
	end)
	return result;
end

return AssetLoader;