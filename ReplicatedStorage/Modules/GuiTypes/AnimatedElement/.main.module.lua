local AGE = { };

-- ** Game Services ** --
local TweenService = game:GetService ("TweenService");

-- ** Game Structure ** --
local guiTypes = script.Parent;

-- ** Dependencies ** --
local GuiElement = require (guiTypes.Element);

-- ** Constructor ** --
local AnimatedGuiElement = GuiElement.new ();
function AGE.new ()
	return setmetatable ({
		
	}, AnimatedGuiElement);
end

-- ** Protected Methods ** --
-- Fading
function AnimatedGuiElement:_applyFadeEffect (frame, fadeTime, effectLength)
	self:_setVisibility (true);
	
	self:_fadeIn (frame, fadeTime);
	wait (effectLength);
	self:_fadeOut (frame, fadeTime);
	
	self:_setVisibility (false);
end
function AnimatedGuiElement:_fadeIn (frame, length)
	self:_fadeEffect (frame, length, {startTrans = 1, endTrans = 0})
end
function AnimatedGuiElement:_fadeOut (frame, length)
	self:_fadeEffect (frame, length, {startTrans = 0, endTrans = 1});
end
function AnimatedGuiElement:_fadeEffect (frame, length, transparencies)
	frame.BackgroundTransparency = transparencies.startTrans;
	local tween = TweenService:Create (frame, TweenInfo.new(length), {
		BackgroundTransparency = transparencies.endTrans
	});
	
	tween:Play ();
	tween.Completed:wait ();
end

-- Slide effect
function AnimatedGuiElement:_slide (frame, effectLength, startPosition, endPosition, tweenLength)
	self:_setVisibility (true);
	self:_tweenPosition (frame, startPosition, endPosition, tweenLength, function ()
		wait (effectLength);
		self:_tweenPosition (frame, endPosition, startPosition, tweenLength, function ()
			self:_setVisibility (false);
		end);
	end);
end

-- Position Tweening
function AnimatedGuiElement:_tweenPosition (frame, startPosition, endPosition, length, onSuccess)
	frame.Position = startPosition;
	frame.Visible = true;
	
	frame:TweenPosition (endPosition, nil, Enum.EasingStyle.Linear, length, nil, function (status)
		if (status == Enum.TweenStatus.Canceled) then return end
		if (onSuccess) then
			onSuccess ();
		end
	end);
end

AnimatedGuiElement.__index = AnimatedGuiElement;
return AGE;