-- ** Structure ** --
local badPowers = script.Parent;
local powerups   = badPowers.Parent;
local effects    = powerups.EffectTypes;

-- ** Dependencies ** --
local Powerup = require (powerups.Base);
local Speed   = require (effects.Speed);

-- ** Constants ** --
local EFFECT_NAME = "Speed Down";
local EFFECT_TYPE = Powerup.Types.bad;

-- ** Self ** --
local Effect = Powerup.new (EFFECT_NAME, EFFECT_TYPE, Speed.length);

function Effect:_effect (character)
	Speed.decrease (character);
end
function Effect:_removeEffect (character)
	Speed.increase (character);
end

return Effect;