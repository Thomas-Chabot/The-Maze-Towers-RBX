-- NOTE TO SELF: This doesn't play well with the unions & has been turned off

local TrapDoor = { };

-- ** Constants ** --
local EFFECT_LENGTH = 10;

local EFFECT_TRANSPARENCY = {
	[false] = 0,
	[true]  = 1
}

-- ** Effect ** --
function TrapDoor.activate (mainObject)
	applyEffect (mainObject, true);
end
function TrapDoor.deactivate (mainObject)
	applyEffect (mainObject, false);
end

-- ** Main Apply ** --
function applyEffect (mainObject, isActive)
	apply (mainObject, function (floor)
		floor.CanCollide = not isActive;
		floor.Transparency = EFFECT_TRANSPARENCY [isActive];
	end)
end

function apply (object, f)
	if (not object) then return end
	if (object:IsA("Part")) then return f(object); end
	
	local main = object:FindFirstChild ("MainParts");
	if (not main) then warn("Could not find floor"); return end
	
	for _,obj in pairs (main:GetDescendants()) do
		if (obj:IsA("BasePart")) then
			f (obj);
		end
	end
end

TrapDoor.length = EFFECT_LENGTH;
return TrapDoor;