-- ** Structure ** --
local goodPowers = script.Parent;
local powerups   = goodPowers.Parent;
local effects    = powerups.EffectTypes;

-- ** Dependencies ** --
local Powerup = require (powerups.Base);
local Speed   = require (effects.Speed);

-- ** Constants ** --
local EFFECT_NAME = "Speed Up!";
local EFFECT_TYPE = Powerup.Types.good;

-- ** Self ** --
local Effect = Powerup.new (EFFECT_NAME, EFFECT_TYPE, Speed.length);

function Effect:_effect (character)
	Speed.increase (character);
end
function Effect:_removeEffect (character)
	Speed.decrease (character);
end

return Effect;