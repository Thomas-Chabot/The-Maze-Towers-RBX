local SL = { };

-- ** Game Structure ** --
local guiTypes = script.Parent;

-- ** Dependencies ** --
local GuiElement = require (guiTypes.Element);

-- ** Constructor ** --
local ScrollingLayout = GuiElement.new ();
function SL.new ()
	return setmetatable ({
		_mainFrame = nil,
		_layout = nil,
		
		_extra = Vector2.new (0, 0)
	}, ScrollingLayout);
end

-- ** Public Methods ** --
function ScrollingLayout:update ()
	print ("Updating the screen size")
	self:_reapplyLayout ();
end
function ScrollingLayout:show ()
	self:_show ();
	self:_reapplyLayout ();
end

-- ** Protected Methods ** --
function ScrollingLayout:_reapplyLayout ()
	self._layout:ApplyLayout ();
	self:_updateCanvasSize ();
end
function ScrollingLayout:_updateCanvasSize ()
	wait ()
	self._mainFrame.CanvasSize = self:_calculateCanvasSize ();
end
function ScrollingLayout:_calculateCanvasSize ()
	local absContentSize = self._layout.AbsoluteContentSize;
	local extra          = self._extra;
	
	return UDim2.new (0, absContentSize.X + extra.X, 0, absContentSize.Y + extra.Y);
end

ScrollingLayout.__index = ScrollingLayout;
return SL;