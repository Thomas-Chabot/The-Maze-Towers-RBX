local Health = { };

-- ** Constants ** --
local HEALTH_BOOST = 30;

-- ** Effect ** --
function Health.increase (character)
	return applySpeedBoost (character, HEALTH_BOOST)
end
function Health.decrease (character)
	return applySpeedBoost (character, -HEALTH_BOOST)
end

function applySpeedBoost (character, boost)
	local humanoid = character and character:FindFirstChild("Humanoid");
	if (not humanoid) then return false end
	
	humanoid.Health = math.min (humanoid.MaxHealth, humanoid.Health + boost);
	return true;
end

Health.length = 0;

return Health;