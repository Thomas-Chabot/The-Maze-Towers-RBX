local AssetService  = game:GetService ("AssetService");
local InsertService = game:GetService ("InsertService")

function insertInto (assets, parent)
	for _,asset in pairs (assets) do
		if (typeof (parent) == "Instance") then
			asset.Parent = parent;
		elseif (typeof (parent) == "table") then
			table.insert (parent, asset);
		end
	end
end

function loadInAsset (assetId, main, assets)
	local newAsset = InsertService:LoadAsset (assetId);
	if (newAsset:FindFirstChild ("R15")) then
		insertInto (newAsset.R15:GetChildren(), main)
	else
		insertInto (newAsset:GetChildren(), assets);
	end
end

function loadPackage (packageId, assets)
	if (typeof (packageId) == "Instance") then
		return packageId;
	end
	
	local package = Instance.new ("Folder");
	local R15     = Instance.new ("Folder");
	R15.Name = "R15";
	R15.Parent = package;

	local contents = AssetService:GetAssetIdsForPackage(packageId);
	for _,id in pairs (contents) do
		loadInAsset (id, R15, assets)
	end
	
	return package;
end

return loadPackage;