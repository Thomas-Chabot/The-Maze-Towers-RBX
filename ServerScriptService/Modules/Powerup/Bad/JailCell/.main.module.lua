-- ** Structure ** --
local powers     = script.Parent;
local powerups   = powers.Parent;
local effects    = powerups.EffectTypes;

-- ** Dependencies ** --
local Powerup  = require (powerups.Base);
local JailCell = require (effects.JailCell);

-- ** Constants ** --
local EFFECT_NAME = "Jail Cell";
local EFFECT_TYPE = Powerup.Types.bad;
local EFFECT_LENGTH = 4;

-- ** Self ** --
local Effect = Powerup.new (EFFECT_NAME, EFFECT_TYPE, EFFECT_LENGTH);
function Effect:_effect (character)
	return JailCell.trap (character);
end
function Effect:_removeEffect (character, orb, jailCell)
	jailCell:remove ();
end

return Effect;