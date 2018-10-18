-- Handles the Damage Over Time effect
local stats = {
	Particle = script.Particle:Clone(),
	DamagePerSec = 0.5,
	Length = 5,
	Timeout = 1
};

-- ** Game Services ** --
local serverScriptService = game:GetService ("ServerScriptService");

-- ** Game Structure ** --
local modules = serverScriptService.Modules;
local effects = modules.AttackEffects;

-- ** Dependencies ** --
local DamageOverTime = require (effects.TimedEffects.DamageOverTime);

-- ** Constants ** --

-- ** Object Instantiation ** --
local dot;
function init ()
	local particle = stats.Particle:Clone()
	local length, timeout, damage = stats.Length, stats.Timeout, stats.DamagePerSec;
	
	return DamageOverTime.new (length, timeout, damage, particle);
end

-- ** The Effect Call ** --
function effect (character)
	if (not dot) then dot = init() end	
	dot:activate (character);
end

stats.effect = effect;
return stats;