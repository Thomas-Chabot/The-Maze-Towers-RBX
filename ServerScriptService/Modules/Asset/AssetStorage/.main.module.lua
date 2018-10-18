local Storage = { };

local Loader = require (script.Loader);

function Storage.Model (model)
	Loader.add (model, Loader.AssetTypes.Model);
end
function Storage.Package (packageId)
	Loader.add (packageId, Loader.AssetTypes.Package);
end
function Storage.Asset (assetId)
	Loader.add (assetId, Loader.AssetTypes.Asset);
end
function Storage.Url (url)
	Loader.add (url, Loader.AssetTypes.Url);
end

function Storage.get ()
	return Loader.get()
end
function Storage.count()
	return Loader.count()
end

return Storage;