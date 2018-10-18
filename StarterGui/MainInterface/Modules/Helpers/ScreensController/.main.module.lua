local ScreensControl = { };
local SC             = { };

-- ** Structure ** --
local helpers = script.Parent;

-- ** Dependencies ** --
local History = require (helpers.History);

-- ** Constructor ** --
function SC.new ()
	local screens = setmetatable ({
		_active = nil,
		_history = History.new ()
	}, ScreensControl);
	
	screens:_init ();
	return screens;
end

-- ** Public Methods ** --
function ScreensControl:goto (screenType, ...)
	local details = self:_createScreenDetails (screenType, ...)
	
	-- If this is the screen already being viewed, don't do anything
	if (self:_isCurrentScreen (details)) then return end
	
	self._history:add (details);
	self:_goto (details);
end
function ScreensControl:updateActiveScreen (screenType, ...)
	local details = self:_createScreenDetails (screenType, ...);
	self:_reload (screenType, details);
end
function ScreensControl:redrawScreen (screenType)
	self:_reload (screenType, self._active);
end

function ScreensControl:hide ()
	self:_hideActiveScreen()
end

function ScreensControl:update ()
	self:_updateActiveScreen ();
end

function ScreensControl:reset ()
	self._active = nil;
	self._history:clear ();
end

function ScreensControl:disable ()
	local screen = self:_getActiveScreenType ();
	screen:disable ();
end
function ScreensControl:enable ()
	local screen = self:_getActiveScreenType ();
	screen:enable ();
end

function ScreensControl:back ()
	local prev = self._history:back ();
	self:_goto (prev);
end

function ScreensControl:next ()
	local nxt = self._history:next ();
	self:_goto (nxt);
end

function ScreensControl:isLast() return self._history:isLast(); end
function ScreensControl:isFirst() return self._history:isFirst(); end

-- ** Private Methods ** --
-- initialization
function ScreensControl:_init ()
	
end

-- screen details
function ScreensControl:_createScreenDetails (screenType, ...)
	return {
		screenType = screenType,
		arguments  = {...}
	};
end

-- compare screen details to see if they match
function ScreensControl:_isActiveScreenType (screenType)
	return self:_getActiveScreenType() == screenType;
end
function ScreensControl:_isCurrentScreen (screenDetails)
	if (not self._active) then return false; end
	return self:_areEqual (screenDetails, self._active);
end
function ScreensControl:_areEqual (screen1Details, screen2Details)
	if (screen1Details.screenType ~= screen2Details.screenType) then return false end
	for index,screen1Arg in pairs (screen1Details.arguments) do
		if (screen2Details [index] ~= screen1Arg) then
			return false;
		end
	end
	return true;
end

-- reload current screen
function ScreensControl:_reload (screenType, details)
	-- If not the current screen, don't do anything
	if (not self:_isActiveScreenType (screenType)) then return end
	
	-- Otherwise -> Reload the screen
	self._history:replace (details);
	self:_goto (details);
end

-- go to a new screen
function ScreensControl:_goto (details)
	self:_hideActiveScreen ();
	self:_setActive (details);
	
	details.screenType:show (unpack (details.arguments));
end

-- active screen
function ScreensControl:_getActiveScreenType ()
	return self._active.screenType;
end
function ScreensControl:_setActive (details)
	self._active = details;
end
function ScreensControl:_hideActiveScreen ()
	if (not self._active) then return end
	self._active.screenType:hide ();
end
function ScreensControl:_updateActiveScreen ()
	if (not self._active) then return end
	self._active.screenType:update ();
	
end

ScreensControl.__index = ScreensControl;
return SC;