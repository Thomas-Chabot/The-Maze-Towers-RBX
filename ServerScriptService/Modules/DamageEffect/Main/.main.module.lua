local DE           = { };

-- ** Game Services ** --
local serverScriptService = game:GetService ("ServerScriptService");

-- ** Game Structure ** --
local modules = serverScriptService.Modules;
local classes = modules.ParentClasses;

-- ** Dependencies ** --
local EventSystem = require (classes.EventSystem);
local Effect = require (script.Effect);

-- ** Constructor ** --
local DamageEffect = EventSystem.new();
function DE.new (character, options)
	if (not options) then options = { }; end
	assert (character, "Character must be specified");
	
	local effect = setmetatable ({
		_moduleName = "DamageEffect",
		
		_char = character,
		_human = character:FindFirstChildOfClass("Humanoid"),
		
		_lastHealth = 0,
		
		_effect = Effect.new (options),
		
		Healed = Instance.new ("BindableEvent"),
		Damaged = Instance.new ("BindableEvent")
	}, DamageEffect);

	effect:_init ();	
	return effect;
end

-- ** Public Methods ** --

-- ** Private Methods ** --
-- Initialization
function DamageEffect:_init ()
	if (not self._human) then
		error ("Could not find humanoid");
		return;
	end
	
	self._lastHealth = self._human.Health;
	self:_connect (self._human.HealthChanged, self._healthChanged);
	self:_connect (self._human.Died, self.remove);
	
	self:_log ("Installed on ", self._char)	
end

-- Event Handlers
function DamageEffect:_healthChanged (newHealth)
	local lastHealth = self._lastHealth;
	self._lastHealth = newHealth;
	
	local diff = newHealth - lastHealth;
	
	if (newHealth < lastHealth) then
		self:_log (self._char, "damaged; health now ", newHealth);
		
		self.Damaged:Fire();
		self._effect:activate (self._char, diff);
	else
		self:_log (self._char, "healed; health now ", newHealth);
		self.Healed:Fire();
		
		-- Ignore effect on the default healing - anything under 3
		if (diff < 3) then return end
		self._effect:activate (self._char, diff);
	end
end

DamageEffect.__index = DamageEffect;
return DE;