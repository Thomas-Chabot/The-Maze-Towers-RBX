local modules = script.Parent;
local PackageLoader = require (modules.PackageLoader);
local loader = PackageLoader.new (script.DefaultCharacter);

function applyDefaultPackage (player)
	loader:giveTo (player);
end

return applyDefaultPackage;