local DOT = { };

-- ** Game Structure ** --
local TimedEffect = require (script.Parent.Base);

-- ** Constants ** --
local DAMAGE_PER_SEC = 0.1;
local MAX_STACK      = 5;

-- ** Constructor ** --
local DamageOverTime = TimedEffect.new("DamageOverTime", {
	stack = MAX_STACK
});

function DOT.new (length, timeout, damagePerSec, effectParticle)
	local dot = setmetatable ({
		_damage = damagePerSec or DAMAGE_PER_SEC
	}, DamageOverTime);
	
	dot:_resetProperties ({
		length = length,
		timeout = timeout,
		particle = effectParticle,
		stack = MAX_STACK
	});
	
	return dot;
end

-- ** Private Methods ** --
function DamageOverTime:_effect (target)
	local human = target and target:FindFirstChildOfClass("Humanoid");
	if (not human) then return end
	
	self:_log ("Dealing ", self._damage, " damage to ", target)
	human:TakeDamage (self._damage);
end

DamageOverTime.__index = DamageOverTime;
return DOT;