local Loader = { };
local L      = { };

-- ** Game Services ** --
local ContentProvider = game:GetService("ContentProvider");

-- ** Constructor ** --
function L.new ()
	return setmetatable ({
		_loading = false,
		_prevNumAssets = 0,
		
		Updated = Instance.new ("BindableEvent"),
	}, Loader);
end

-- ** Public Methods ** --
function Loader:load (assets)
	if (self._loading) then return end
	self._loading = true;
	
	self:_loadAssets (assets, self._prevNumAssets);
	self._prevNumAssets = #assets;
	
	self._loading = false;
end


-- ** Private Methods ** --
function Loader:_loadAssets (assets, startingIndex)
	for index = startingIndex, #assets do
		local asset = assets [index];
		ContentProvider:PreloadAsync({asset});
		
		self.Updated:Fire (index);
	end
end

Loader.__index = Loader;
return L;