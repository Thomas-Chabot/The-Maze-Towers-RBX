-- Game Structure
local ServerStorage = game:GetService ("ServerStorage");
local data          = ServerStorage.Data;

local charactersMain = script.Parent;
local characterModules = charactersMain.Parent;

-- Dependencies
local charactersData = require (data.Characters);
local Character = require (characterModules.Base);

-- Main loading function
function loadCharacters ()
	local characters = { };
	
	for _,characterData in pairs (charactersData) do
		characters [characterData.Id] = createCharacter (characterData);
	end
	
	return characters;
end

function createCharacter (data)
	return Character.new (data);
end

return loadCharacters;