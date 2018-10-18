-- ** Structure ** --
local badPowers = script.Parent;
local powerups   = badPowers.Parent;
local effects    = powerups.EffectTypes;

-- ** Dependencies ** --
local Powerup = require (powerups.Base);
local Health  = require (effects.Health);

-- ** Constants ** --
local EFFECT_NAME = "Health Drop";
local EFFECT_TYPE = Powerup.Types.bad;

-- ** Self ** --
local Effect = Powerup.new (EFFECT_NAME, EFFECT_TYPE, Health.length);

function Effect:_effect (character)
	Health.decrease (character);
end
function Effect:_removeEffect (character)
	-- no effect
end

return Effect;