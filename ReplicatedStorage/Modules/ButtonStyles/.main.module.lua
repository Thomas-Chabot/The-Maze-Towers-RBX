--[[
	Allows a button to easily swap image based on Mouse Hover & Mouse Down
	By supplying a button and the various images to use.
	
	To apply these effects, simply create a new ButtonStyles object:
		Constructor  (button : ImageButton, options : Table) : ButtonStyles
			Purpose: Creates & adds effects for the given button based on given options.
			Arguments:
				button  : ImageButton : The button to apply the effects to
				options : Table       : Table of settings to apply. See OPTIONS below
			Returns:
				A ButtonStyles object. Currently, the object will have no further
				  purpose.
		
		OPTIONS:
			Options can take on three properties:
				mouseHover  String  Image to be applied for hovering
				mouseDown   String  Image to be applied when mouse is pressed
				default     String  Image to be applied as default (i.e., not hovered, not pressed)
			Note that each option is optional; if not provided, will not apply that effect
--]]

local BS           = { };
local ButtonStyles = { };

local effects = {
	MouseDown = {
		priority = 2,
		image    = "downImg",
		id       = 1
	},
	MouseHover = {
		priority = 1,
		image    = "hoverImg",
		id       = 2
	},
	Default = {
		priority = 0,
		image    = "default",
		id       = 3
	}
};

-- constructor
function BS.new (button, options)
	assert(button, " button argument must be provided ");
	if (not options) then options = { }; end
	
	local t = setmetatable({
		button = button,
		
		hoverImg = "",
		downImg  = "",
		default  = "",
		disabled = "",
		
		applied  = { },
		
		_events = { },
		_disabled = false,
		
		_imgColor3 = nil
	}, ButtonStyles);
	
	t:init(options);
	return t;
end

-- public methods
-- disabling
function ButtonStyles:disableEffect ()
	self._disabled = true;
end
function ButtonStyles:enableEffect ()
	self._disabled = false;
end

-- disabling w/ special styles
function ButtonStyles:disable ()
	self:disableEffect ();
	self:_applyDisabled ();
end
function ButtonStyles:enable ()
	self:enableEffect ();
	self:_removeDisabled ();
end

-- initialization
function ButtonStyles:init (options)
	local btn = self.button;
	if (not btn) then return end;
	
	self:_setImages (options);
	self:_storeColor ();
	self:_addEventHandling ();
end

function ButtonStyles:_setImages (images)
	self.hoverImg = images.mouseHover;	
	self.downImg  = images.mouseDown;
	self.default  = images.default or self.button.Image;
	self.disabled = images.disabled;
end
function ButtonStyles:_storeColor ()
	self._imgColor3 = self.button.ImageColor3;
end

-- *** Public Methods *** --
function ButtonStyles:setImages (images)
	self:_setImages (images);
end
function ButtonStyles:resetToDefault ()
	self:_removeMouseDown();
	self:_removeHover();
end

function ButtonStyles:remove ()
	self:_removeEventHandling ();
end

-- *** Private Methods *** --
-- effects
-- [ should be protected methods ]
function ButtonStyles:_applyMouseDown ()
	self:_apply (effects.MouseDown);
end
function ButtonStyles:_removeMouseDown ()
	self:_unapply (effects.MouseDown);
end
function ButtonStyles:_applyHover ()
	self:_apply (effects.MouseHover);
end
function ButtonStyles:_removeHover ()
	self:_unapply (effects.MouseHover);
	
	-- note, error case: may not have unpressed mouse down, but should.
	-- worst case, will not do anything...
	self:_removeMouseDown();
end
function ButtonStyles:_applyDisabled ()
	if (self.disabled) then
		self:_updateImage (self.disabled)
	else
		self:_darken ();
	end
end
function ButtonStyles:_removeDisabled ()
	self._disabled = false;
	self:_brighten ();
	self:_update ();
end

-- applying & removing effect
-- this will follow a chain of importance ...
function ButtonStyles:_apply (effect)
	if (self:_hasApplied (effect)) then return false end
	self:_addApplied (effect);
	self:_update ();
end
function ButtonStyles:_unapply (effect)
	self:_removeApplied (effect);
	self:_update ();
end

-- storing applied features
function ButtonStyles:_indexOf (effect)
	for index,e in pairs(self.applied) do
		if (e.id == effect.id) then
			return index
		end
	end
	return -1	
end
function ButtonStyles:_hasApplied (effect)
	return self:_indexOf (effect) ~= -1;
end
function ButtonStyles:_addApplied (effect)
	table.insert (self.applied, effect);
end
function ButtonStyles:_removeApplied (effect)
	local index = self:_indexOf (effect);
	if (index ~= -1) then
		table.remove (self.applied, index);
	end
end

-- returns the image to apply based on effects,
--   which will be highest priority or default
function ButtonStyles:_getCurrentImage ()
	local effect = self:_getHighestPriority ()
	if (not effect) then effect = effects.Default end
	
	return effect.image
end

-- returns the effect to apply with highest priority
-- returns nil if no effects being applied
function ButtonStyles:_getHighestPriority ()
	local index = 1
	local applied = self.applied;
	
	if (#self.applied == 0) then return nil end
	
	local index = self:_getHighestPriorityIndex();
	
	return applied[index];
end
function ButtonStyles:_getHighestPriorityIndex ()
	local index = 1;
	local applied = self.applied;
	
	for i,e in pairs (applied) do
		if (e.priority > applied[index].priority) then
			index = i;
		end
	end
	
	return index;
end

-- darkening
function ButtonStyles:_darken ()
	local imgColor = self._imgColor3;
	local dark     = Color3.new (imgColor.r * 60/255, imgColor.g * 60/255, imgColor.b * 60/255);
	self.button.ImageColor3 = dark;
end
function ButtonStyles:_brighten ()
	self.button.ImageColor3 = self._imgColor3;
end

-- apply effects
function ButtonStyles:_update ()
	if (self._disabled) then return end
	local imageName = self:_getCurrentImage ();
	
	-- use default if no effect to apply ...
	if (not imageName) then
		imageName = "default";
	end
	
	local image = self[imageName];
	if (not image) then return end;
	
	self:_updateImage (image);
end
function ButtonStyles:_updateImage (image)
	self.button.Image = image;
end

-- event handling
function ButtonStyles:_addEventHandling ()
	local btn = self.button;
	local e1 = btn.MouseButton1Down:connect(function()
		self:_applyMouseDown();
	end)
	local e2 = btn.MouseButton1Up:connect(function()
		self:_removeMouseDown();
	end)
	
	local e3 = btn.MouseEnter:connect(function()
		self:_applyHover();
	end)
	local e4 = btn.MouseLeave:connect(function()
		self:_removeHover();
	end)
	
	-- add the events	
	table.insert (self._events, e1);
	table.insert (self._events, e2);
	table.insert (self._events, e3);
	table.insert (self._events, e4);
end

function ButtonStyles:_removeEventHandling ()
	for _,event in pairs (self._events) do
		event:disconnect ();
	end
end
ButtonStyles.__index = ButtonStyles;
return BS;