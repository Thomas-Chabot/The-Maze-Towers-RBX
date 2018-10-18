local TE         = { };

-- ** Game Services ** --
local ServerScriptService = game:GetService ("ServerScriptService");

-- ** Game Structure ** --
local modules = ServerScriptService:WaitForChild("Modules");
local effects = modules:WaitForChild("AttackEffects");

-- ** Dependencies ** --
local Particle = require (effects.Particle);
local Stack    = require (effects.Stack);

-- ** Constructor ** --
local TimedEffect = Particle.new ("TimedEffect");
function TE.new (name, settings)
	if (not settings) then settings = { }; end
	
	local timedEffect = setmetatable ({
		_length = settings.length,
		_timeout = settings.timeout,
		_stack = Stack.new (name, settings.stack);
	}, TimedEffect);
	
	timedEffect:_setParticle (settings.particle);
	timedEffect:_setName (name);
	
	return timedEffect;
end

-- ** Public Methods ** --
-- Activates the timed effect on the given target
function TimedEffect:activate (target)
	if (not self._stack:inc (target)) then
		self:_log ("Stack has reached limit")
		return false;
	end
	
	self:_addParticle (target, self._length);
	
	for i = 1,self._length do
		if (not target) then break end
		
		self:_effect (target);
		wait (self._timeout);
	end
	
	self._stack:dec(target);
end

-- ** Private Methods ** --
-- Resets the properties - necessary for inheritance
function TimedEffect:_resetProperties (props)
	self:_setProp ("_length", props.length);
	self:_setProp ("_timeout", props.timeout);
	
	if (props.stack) then
		self._stack:setMax (props.stack);
	end
	
	self:_setParticle (props.particle);
end

TimedEffect.__index = TimedEffect;
return TE;