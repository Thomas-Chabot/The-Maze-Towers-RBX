-- ** Structure ** --
local goodPowers = script.Parent;
local powerups   = goodPowers.Parent;
local effects    = powerups.EffectTypes;

-- ** Dependencies ** --
local Powerup = require (powerups.Base);
local Health  = require (effects.Health);

-- ** Constants ** --
local EFFECT_NAME = "Health Boost";
local EFFECT_TYPE = Powerup.Types.good;

-- ** Self ** --
local Effect = Powerup.new (EFFECT_NAME, EFFECT_TYPE, Health.length);

function Effect:_effect (character)
	Health.increase (character);
end
function Effect:_removeEffect (character)
	-- no effect
end

return Effect;