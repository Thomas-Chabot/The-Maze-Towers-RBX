local Homing = { };
local H      = { };

-- ** Constants ** --
local DEF_LIFETIME = 5;
local DEF_MOVE_LOGIC = function(targ) return targ; end

-- ** Constructor ** --
function H.new (attack, target, options)
	if (not options) then options = { }; end
	
	local homing = setmetatable ({
		_attack = attack,
		_target = target,
		
		_lifetime = options.lifetime or DEF_LIFETIME,
		_moveLogic = options.moveLogic or DEF_MOVE_LOGIC
	}, Homing);
	
	homing:_fire();
	return homing;
end

-- ** Private Methods ** --
function Homing:_fire ()
	local targPos = self:_getTargetPos();
	self:_moveTo (targPos);
end

function Homing:_getTargetPos ()
	-- Probably improve this for standard parts
	-- Just for models as it is
	local targ = self._target:GetPrimaryPartCFrame ().p;
	return self._moveLogic (targ);
end

function Homing:_moveTo (targPos)
	-- TODO
end

Homing.__index = Homing;
return H;