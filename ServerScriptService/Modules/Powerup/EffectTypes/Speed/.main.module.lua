local Speed = { };

-- ** Constants ** --
local SPEED_BOOST   = 10;
local EFFECT_LENGTH = 10;

-- ** Effect ** --
function Speed.increase (character)
	return applySpeedBoost (character, SPEED_BOOST)
end
function Speed.decrease (character)
	return applySpeedBoost (character, -SPEED_BOOST)
end

function applySpeedBoost (character, boost)
	local humanoid = character and character:FindFirstChild("Humanoid");
	if (not humanoid) then return false end
	
	humanoid.WalkSpeed = humanoid.WalkSpeed + boost;
	return true;
end

Speed.length = EFFECT_LENGTH;

return Speed;