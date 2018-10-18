local InsertService = game:GetService ("InsertService");

return function (id)
	local asset = InsertService:LoadAsset (id);
	return asset and asset:GetChildren () [1];
end