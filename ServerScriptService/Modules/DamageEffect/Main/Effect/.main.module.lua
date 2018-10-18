local Effect = { };
local E      = { };

-- ** Game Services ** --
local Debris = game:GetService ("Debris");

-- ** Dependencies ** --
local damageColor = require (script.Color);

-- ** Constants ** --
local DEF_START_TIME = 0.5;
local DEF_RISING_TIME = 2;
local DEF_RISE_VELOCITY = 10;

local DAMAGE_PART = script.Damage;
local BODY_VELOCITY = script.BodyVelocity;

-- ** Constructor ** --
function E.new (options)
	if (not options) then options = { }; end
	
	local effect = setmetatable ({
		_startTime = options.startTime or DEF_START_TIME,
		
		_riseVelocity = options.riseVelocity or DEF_RISE_VELOCITY,
		_risingTime = options.risingTime or DEF_RISING_TIME,
		
		_dmgPart = nil,
		_bodyVel = nil,
		
		_effects = { },
	}, Effect);
	
	effect:_init();
	return effect;
end

-- ** Public Methods ** --
function Effect:activate (character, damage)
	local head = character and character:FindFirstChild("Head");
	if (not head) then return false end
	
	local dmgPart = self:_newDamage (head, damage);
	
	wait (self._startTime);
	self:_rise (dmgPart);
	self:_startRemovalCountdown (dmgPart);
end


-- ** Private Methods ** --
-- Initial Creation
function Effect:_init ()
	self._dmgPart = self:_createDamagePart();
	self._bodyVel = self:_createBodyVelocity();
end

-- Part Creation
function Effect:_createDamagePart()
	local dmgPart = DAMAGE_PART:Clone()
	return dmgPart;
end
function Effect:_createBodyVelocity()
	local bodyVel = BODY_VELOCITY:Clone()
	bodyVel.Velocity = Vector3.new (0, self._riseVelocity, 0)
	return bodyVel;
end

-- Main Helpers
function Effect:_newDamage (target, damage)
	local color = damageColor (damage);	
	
	self:_incrementEffects();
	local dmgPart = self:_addDamagePart (target, damage, color);
	self:_addEffect (dmgPart);
	
	return dmgPart;
end
function Effect:_rise (part)
	self:_addBodyVelocity (part);
end

-- Removal - Removes the effect after risingTime
function Effect:_startRemovalCountdown (part)
	Debris:AddItem (part, self._risingTime);
	part.AncestryChanged:connect (function ()
		self:_remove (part);
	end)
end
function Effect:_remove (part)
	self:_removeEffect (part)
end

-- Effect Incrementing - if previous effects are running, increase their heights
function Effect:_incrementEffects()
	for _,effect in pairs (self._effects) do
		if (effect and effect:IsA("BasePart")) then
			effect.Position = effect.Position + Vector3.new (0, 1, 0);
		end
	end
end
function Effect:_addEffect (p)
	table.insert (self._effects, p);
end
function Effect:_removeEffect (p)
	for index,effect in pairs (self._effects) do
		if (effect == p) then
			table.remove (self._effects, index);
			break;
		end
	end
end

-- Effect activation
function Effect:_addDamagePart (target, dmg, color)
	local dmgPart = self:_getDamagePart (dmg, color);
	dmgPart.Position = target.Position + Vector3.new (0, 2, 0);
	dmgPart.Parent = workspace;
	return dmgPart;
end
function Effect:_addBodyVelocity (parent)
	parent.Anchored = false
	self._bodyVel:Clone().Parent = parent;
end

-- Getters for new damage part & new body vel
function Effect:_getDamagePart (damage, colorData)
	local dmg = self._dmgPart:Clone()
	local textLbl = dmg.BillboardGui.DamageText;
	
	local damagePrefix = damage >= 0 and "+" or "-";
	damage = math.abs (damage);
	
	textLbl.Text = damagePrefix .. damage;
	textLbl.TextColor3 = colorData.color;
	textLbl.TextStrokeColor3 = colorData.strokeColor;
	
	return dmg;
end
function Effect:_getBodyVel ()
	return self._bodyVel:Clone()
end

Effect.__index = Effect;
return E;