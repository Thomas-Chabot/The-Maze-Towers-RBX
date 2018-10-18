local TextAnim = { };
local TA       = { };

-- ** Constants ** --
local DEF_SPEED = 0.06;

-- ** Constructor ** --
function TA.new (label, speed)
	return setmetatable ({
		_label = label,
		_speed = speed or DEF_SPEED,
		
		_animating = false
	}, TextAnim);
end

-- ** Public Methods ** --
function TextAnim:start (text)
	if (self._animating) then return false end
	self:_setScaled (false)
	self:_animate (text)
end
function TextAnim:stop ()
	self._animating = false
end
function TextAnim:setSpeed (speed)
	self._speed = speed;
end

function TextAnim:isAnimating ()
	return self._animating;
end

-- ** Private Methods ** --
-- Main animation
function TextAnim:_animate (text)
	assert (text, "Text must be provided")
	self._animating = true;
	
	local i = 1;
	while self._animating and i <= #text do
		self:_setText (text:sub (1, i))
		self:_checkShouldScale ();
		
		wait (self._speed);
		i = i + 1;
	end
	
	self._animating = false;
end

-- Text label helpers
function TextAnim:_setText (text)
	self._label.Text = text;
end
function TextAnim:_setScaled (isScaled)
	self._label.TextScaled = isScaled;
end
function TextAnim:_doesTextFit()
	return self._label.TextFits;
end

-- Checks if text should be scaled
function TextAnim:_checkShouldScale ()
	if (self:_doesTextFit()) then return end
	self:_setScaled (true);
end


TextAnim.__index = TextAnim;
return TA;