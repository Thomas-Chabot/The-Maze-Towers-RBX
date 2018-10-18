local P = { };

-- ** Game Services ** --
local Debris = game:GetService ("Debris");

-- ** Dependencies ** --
local Base = require (script.Parent.Base);

-- ** Constructor ** --
local Particle = Base.new ("Particle");
function P.new (name, particle)
	local particle = setmetatable ({
		_particle = particle
	}, Particle);
	
	particle:_setName (name);
	return particle;
end

-- ** Protected Methods ** --

-- Update the particle being used
function Particle:_setParticle (particle)
	self._particle = particle;
end

-- Particle adding
function Particle:_addParticle (target, length)
	-- If it already exists, we want to remove it - this clears the timer
	self:_removeParticle (target);
	
	-- Insert a new one
	self:_insertParticle (target, length);
end

-- Particle removal
function Particle:_removeParticle (target)
	local targetPart = self:_getTargetPart (target);
	if (not targetPart) then return end
	
	local particle = targetPart:FindFirstChild (self._particle.Name);
	if (particle) then particle:Destroy(); end
end


-- ** Private Methods ** --

-- Helpers for particle adding & removing

-- Main insertion
function Particle:_insertParticle (target, length)
	local targetPart = self:_getTargetPart (target);
	if (not targetPart) then return end
	
	local newParticle = self:_createParticle (length);
	newParticle.Parent = targetPart;
end

-- Main creation
function Particle:_createParticle (length)
	local newParticle = self._particle:Clone();
	Debris:AddItem (newParticle, length);
	return newParticle;
end

-- Helpers for dealing with the target
function Particle:_getTargetPart (target)
	return target and target:FindFirstChild("Head");
end


Particle.__index = Particle;
return P;