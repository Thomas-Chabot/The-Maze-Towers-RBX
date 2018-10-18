-- ** Structure ** --
local powers     = script.Parent;
local powerups   = powers.Parent;
local effects    = powerups.EffectTypes;

-- ** Dependencies ** --
local Powerup  = require (powerups.Base);
local TrapDoor = require (effects.TrapDoor);

-- ** Constants ** --
local EFFECT_NAME = "Trap Door";
local EFFECT_TYPE = Powerup.Types.bad;

-- ** Self ** --
local Effect = Powerup.new (EFFECT_NAME, EFFECT_TYPE, TrapDoor.length);

function Effect:_effect (_, object)
	TrapDoor.activate (object);
end
function Effect:_removeEffect (_, object)
	TrapDoor.deactivate (object);
end

return Effect;