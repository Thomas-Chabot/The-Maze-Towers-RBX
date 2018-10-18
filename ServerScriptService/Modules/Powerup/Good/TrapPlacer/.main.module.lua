-- Lets the player place a trap for other players.

-- ** Structure ** --
local powers   = script.Parent;
local powerups = powers.Parent;
local effects  = powerups.EffectTypes;

-- ** Dependencies ** --
local Powerup = require (powerups.Base);

-- ** Constants ** --
local EFFECT_NAME = "Fake Orb!";
local EFFECT_TYPE = Powerup.Types.good;
local TRAP_TOOL = script.Trap;

-- ** Self ** --
local Effect = Powerup.new (EFFECT_NAME, EFFECT_TYPE, 0);

function Effect:_effect (character)
	local player   = game.Players:GetPlayerFromCharacter(character);
	local backpack = player and player:FindFirstChild("Backpack");
	if (not backpack) then return end
	
	local tool = TRAP_TOOL:Clone ();
	tool.Parent = backpack;
end
function Effect:_removeEffect ()
	-- nothing here
end

return Effect;