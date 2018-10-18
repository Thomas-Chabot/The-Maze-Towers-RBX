local Attack = { };
local A      = { };

-- ** Services ** --
local debris = game:GetService("Debris");
local serverScriptService = game:GetService ("ServerScriptService");

-- ** Structure ** --
local modules = serverScriptService:FindFirstChild ("Modules");

-- ** Dependencies ** --
local getCharacter = require (modules.GetCharacter);
local attackEffect = require (script.AttackEffect);

-- ** Default Values ** --
local DEF_ATTACK_LENGTH = 3;
local DEF_ATTACK_DAMAGE = 15;

local DEF_TEMPLATE_PART = script:WaitForChild("AttackPart");

-- ** Constants ** --
local damageScript = script.DamageScript:Clone();
damageScript.Disabled = false;

-- ** Constructor ** --
function A.new (player, attackStats)
	if (not attackStats) then attackStats = { }; end
	
	local directional = (attackStats.Directional == nil) or attackStats.Directional;
	
	local attack = setmetatable ({
		_player = player,
		_character = nil,
		_root = nil,
		
		_isDirectional = directional,
		_templatePart = attackStats.TemplatePart or DEF_TEMPLATE_PART,
		_length = attackStats.Length or DEF_ATTACK_LENGTH,
		_damage = attackStats.Damage or DEF_ATTACK_DAMAGE,
		
		_effectStats = attackStats.EffectStats,
		
		_size = 0,
		
		_attackPart = nil,
		_multiplicationFactor = attackStats.Distance
	}, Attack);
	
	attack:_init ();
	return attack;
end

-- ** Public Methods ** --
function Attack:fire (targetRay)
	self:_setTarget (targetRay);
	self:_fire ();
end
function Attack:remove ()
	self._attackPart:Destroy();
end

-- ** Private Methods ** --
-- Initialization
function Attack:_init ()
	self:_initPlayer ();
	self:_initPart ();
	self:_initVelocityMult ();
end
function Attack:_initPlayer ()
	self._character = getCharacter (self._player);
	self:_initRoot ();
end
function Attack:_initRoot ()
	self._root = self._character.Head;
end
function Attack:_initPart ()
	local attackPart = self._templatePart:Clone ();
	
	-- Set the required stats
	attackPart.Anchored = false;
	attackPart.CanCollide = false;
	
	self:_initDamage (attackPart);
	self:_initFiredBy (attackPart);
	self:_initAttackIndicator (attackPart);
	self:_initEffect (attackPart);
	self:_addDamageScript (attackPart);
	
	attackPart.Damage.Value = self._damage;
	attackPart.FiredBy.Value = self._character;
	
	self._attackPart = attackPart;
end
function Attack:_initVelocityMult ()
	if (self._multiplicationFactor) then return end
	self._multiplicationFactor = 130;
end

-- Part setup
function Attack:_initValue (valueType, valueName, parent)
	local value = Instance.new (valueType);
	value.Name = valueName;
	value.Parent = parent;
	
	return value;
end
function Attack:_initDamage (part)
	local dmgVal = self:_initValue ("IntValue", "Damage", part);
	dmgVal.Value = self._damage;
end
function Attack:_initFiredBy (part)
	local firedBy = self:_initValue ("ObjectValue", "FiredBy", part);
	firedBy.Value = self._character;
end
function Attack:_initAttackIndicator (part)
	self:_initValue ("BoolValue", "IsAttackPart", part);
end
function Attack:_initEffect (part)
	attackEffect.init (part, self._effectStats)
end
function Attack:_addDamageScript (part)
	damageScript:Clone().Parent = part;
end

-- Setting target
function Attack:_setTarget (targRay)
	local character = getCharacter (self._player);
	
	self._character = character;
	local target = self:_getTarget (targRay);
	
	self._attackPart.Velocity = target.unit * self._multiplicationFactor;
end
function Attack:_getTarget (targetRay)
	if (targetRay and self._isDirectional) then
		return targetRay.Direction;
	end
	
	return self._root.CFrame.lookVector;
end
function Attack:_fire ()
	local attack = self._attackPart:Clone ();
	attack.Position = self._root.Position;
	attack.Parent = workspace;
	
	debris:AddItem (attack, self._length);
end

Attack.__index = Attack;
return A;