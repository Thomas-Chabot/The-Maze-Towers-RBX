local ActiveCharacter = { };

local activeId;

function ActiveCharacter:set (charId)
	activeId = charId;
end
function ActiveCharacter:get ()
	return activeId;
end

return ActiveCharacter;