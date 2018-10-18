local AttackEffect = { };

-- ** Constants / Data ** --
local effects = {
	["DOT"] = script.DamageOverTime
}

-- ** Helper Functions ** --
-- Retrieves the effect by type
function getEffect (effectType)
	local effect = effects [effectType];
	return effect and effect:Clone();
end
-- Initializes effect stats
function initEffect (effect, stats)
	-- Clones all the stats into the effect
	for _,stat in pairs (stats) do
		effect [stat] = stats [stat];
	end
end
-- Adds the effect into a parent object
function addEffect (effect, parent)
	if (parent:FindFirstChild("Effect")) then parent.Effect:Destroy() end
	
	effect.Name = "Effect";
	effect.Parent = parent;
end

-- ** Main Functions ** --
-- Initializes a new effect into an object
function AttackEffect.init (object, effectStats)
	if (not effectStats) then return false end
	
	local effectType = effectStats.EffectType;
	local effect = getEffect (effectType);
	if (not effect) then return false end
	
	-- Initialize the effect stats
	local module = require (effect);
	initEffect (module, effectStats);
	
	-- Clone the effect into the object
	-- Note: This removes any old effect script, if htere is one
	addEffect (effect, object);
	
	return true;
end

return AttackEffect;