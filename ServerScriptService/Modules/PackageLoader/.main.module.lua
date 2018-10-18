local PackageLoader = { };
local PL            = { };

local load = require (script.PackageLoader);

-- ** Constructor ** --
function PL.new (package)
	return setmetatable ({
		_package = package
	}, PackageLoader);
end

-- ** Public Methods ** --
function PackageLoader:giveTo (player)
	local character = player.Character;
	local human     = character and character:FindFirstChildOfClass("Humanoid");
	if (not human) then return false end
	
	load (character, self._package)
end

-- ** Private Methods ** --

PackageLoader.__index = PackageLoader;
return PL;