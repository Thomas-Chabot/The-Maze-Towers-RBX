-- Main
local GE         = { };

-- ** Structore ** --
local replicatedStorage = game:GetService ("ReplicatedStorage");
local modules = replicatedStorage:FindFirstChild ("Modules");
local classes = modules:WaitForChild("Classes")

-- ** Dependencies ** --
local ButtonStyles = require (modules.ButtonStyles);
local EventSystem = require (classes.EventSystem);

-- ** Constants ** --
local BUTTON_STYLE_PRESSED = "Pressed";
local BUTTON_STYLE_HOVER   = "Hover";
local BUTTON_STYLE_DEFAULT = "Default";
local BUTTON_STYLE_DISABLED = "Disabled";

-- ** Constructor ** --
local GuiElement = EventSystem.new();
function GE.new ()
	return setmetatable ({
		_mainFrame = nil, -- Constructor must specify
		
		_styling = { },
		_disabled = { }
	}, GuiElement);
end

-- ** Public Methods ** --
function GuiElement:show ()
	self:_show ();
end
function GuiElement:hide ()
	self:_hide ();
end
function GuiElement:update ()
	
end

function GuiElement:disable ()
	self:_applyStylingEffects (false);
end
function GuiElement:enable ()
	self:_applyStylingEffects (true);
end

-- ** Private Methods ** --
-- Getters
function GuiElement:_getMainFrame ()
	return self._mainFrame;
end

-- Disable
function GuiElement:_disable (button)
	self._disabled [button] = true;
	self._styling [button]:disable ();
end
function GuiElement:_enable (button)
	self._disabled [button] = false;
	self._styling [button]:enable ();
end
function GuiElement:_setEnabled (button, isEnabled)
	if (isEnabled) then
		self:_enable (button);
	else
		self:_disable (button);
	end
end

-- Apply & Remove Effects
function GuiElement:_applyStylingEffects (isApplied)
	for btn,style in pairs (self._styling) do
		if (not self._disabled [btn]) then
			if (isApplied) then
				style:enableEffect ();
			else
				style:disableEffect ();
			end
		end
	end
end
-- Buttons

-- Adds a button, initializing styling & firing event on click
function GuiElement:_addButton (button, event, ...)
	local args = {...};
	
	-- Add button styling
	self:_initButtonStyling (button);
	
	-- Add the event
	if (not event) then return end
	button.MouseButton1Click:connect (function ()
		if (self._disabled [button]) then return end
		self:_fireEvent (event, unpack (args));
	end)
end

-- Adds styling for hover & pressed on buttons
function GuiElement:_initButtonStyling (button, styles)
	if (not styles) then
		styles = self:_findButtonStyles (button);
	end
	
	self._styling [button] = ButtonStyles.new (button, styles);
end
function GuiElement:_findButtonStyles (button)
	if (not button) then return { }; end
	
	local pressed = button:FindFirstChild (BUTTON_STYLE_PRESSED);
	local hover   = button:FindFirstChild (BUTTON_STYLE_HOVER);
	local def     = button:FindFirstChild (BUTTON_STYLE_DEFAULT);
	local disabled = button:FindFirstChild (BUTTON_STYLE_DISABLED);
	
	return {
		mouseDown = pressed and pressed.Texture,
		mouseHover = hover and hover.Texture,
		default = def and def.Texture,
		disabled = disabled and disabled.Texture
	}
	
end

-- Fires an event when button clicked
function GuiElement:_fireEvent (event, ...)
	if (typeof (event) == "function") then
		-- If it's a function, just fire the function
		event (...);
	else
		-- Otherwise, it's a BindableEvent, so fire it off
		event:Fire (...);
	end
end

-- Timed Display
function GuiElement:_startDisplayTimer (length)
	spawn (function ()
		wait (length);
		self:hide ();
	end)
end

-- Frame Visibility
function GuiElement:_show ()
	self:_setVisibility (true);
end
function GuiElement:_hide ()
	self:_setVisibility (false);
end
function GuiElement:_setVisibility (isVis)
	self._mainFrame.Visible = isVis;
end
function GuiElement:_isVisible ()
	return self._mainFrame.Visible;
end

GuiElement.__index = GuiElement;
return GE;