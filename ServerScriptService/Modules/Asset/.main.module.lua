local modules = script.Parent;

local Remote = require (modules.Remote.Remotes);
local Module = require (modules.ParentClasses.Module);

local storage = require (script.AssetStorage);
local logger  = Module.new ("Asset");

local assets = { 
	-- Anything here is included by default	
	game:GetService("StarterGui").MainInterface
};

local isGameReady = false;

local Asset = { };

function Asset.Package (packageId)
	storage.Package (packageId);
	return packageId;
end
function Asset.Model (model)
	storage.Model (model);
	return model;
end
function Asset.Url (url)
	storage.Url (url);
	return url;
end
function Asset.Asset (assetId)
	storage.Asset (assetId);
	return assetId;
end

function Asset.Ready ()
	isGameReady = true;
	Remote.AssetsAdded:Fire()
end

-- Remote Handler
Remote.GetAssets.OnInvoke = function ()
	return storage.get();
end
Remote.NumAssets.OnInvoke = function ()
	return storage.count();
end
Remote.AssetsReady.OnInvoke = function (player)
	local isReady = isGameReady;
	
	logger:_log (player, " is requesting if the game is ready: ", isReady)
	return isReady;
end

return Asset;