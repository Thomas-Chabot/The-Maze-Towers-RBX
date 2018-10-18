local EB         = { };

-- ** Game Services ** --
local serverScriptService = game:GetService ("ServerScriptService");

-- ** Game Structure ** --
local modules = serverScriptService.Modules;
local classes = modules.ParentClasses;

-- ** Dependencies ** --
local Module = require (classes.Module);

-- ** Constructor ** --
local EffectBase = Module.new ("EffectBase")
function EB.new (name)
	return setmetatable ({
		_moduleName = name
	}, EffectBase);
end

-- ** Public Methods ** --
function EffectBase:activate (target)
	error ("This must be overloaded");
end

-- ** Protected Getters ** --
function EffectBase:_getName ()
	return self._moduleName;
end

-- ** Protected Setters ** --
function EffectBase:_setName (name)
	self._moduleName = name;
end

-- ** Protected Methods ** --
function EffectBase:_setProp (name, value)
	if (not value) then return end
	self [name] = value;
end

EffectBase.__index = EffectBase;
return EB;