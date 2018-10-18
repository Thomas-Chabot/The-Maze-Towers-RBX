local V     = { };

-- ** Game Services ** --
local ServerScriptService = game:GetService ("ServerScriptService");
local CollectionService   = game:GetService ("CollectionService");

-- ** Game Structure ** --
local modules = ServerScriptService.Modules;
local classes = modules.ParentClasses;

-- ** Dependencies ** --
local Module = require (classes.Module);

-- ** Constants ** --
local MAX_RAY_DIST = 10;

-- ** Constructor ** --
local Vision = Module.new();
function V.new (character, distance)
	return setmetatable ({
		_moduleName = "AI-VISION",
		
		_char = character,
		_root = character.PrimaryPart,
		
		_maxDist = distance
	}, Vision);
end

-- ** Public Methods ** --
function Vision:canSee (object, wasSpotted)
	self:_log ("Checking if AI can see ", object);
	
	-- Check one - Within the provided distance
	local dist = self:_computeDistanceTo (object);
	if (dist > self._maxDist) then return false end
	
	-- Check two - Is looking towards the object
	-- Note, this is only called if not previously spotted
	return wasSpotted or self:_isLookingTowards (object);
end

-- ** Private Methods ** --
-- Target position
function Vision:_findPosition (target)
	return target.PrimaryPart.Position;
end

-- Distance to a player
function Vision:_computeDistanceTo (object)
	local targetPos = self:_findPosition (object)
	return (self._root.Position - targetPos).magnitude;
end

-- Looking towards a player
function Vision:_isLookingTowards (object)
	local ray = self:_createLookingRay (object);
	local targetPos = self:_findPosition (object);
	
	local rayDistance = ray:Distance (targetPos);
	
	self:_log ("The distance to point is ", rayDistance);
	return rayDistance < MAX_RAY_DIST;
end
function Vision:_createLookingRay (object)
	local lookVector = self._root.CFrame.lookVector;
	local position   = self._root.Position;
	
	return Ray.new (position, lookVector);
end


Vision.__index = Vision;
return V;