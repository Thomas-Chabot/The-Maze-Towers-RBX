local H      = { };

-- ** Game Services ** --
local ReplicatedStorage = game:GetService ("ReplicatedStorage");

-- ** Game Structure ** --
local modules = ReplicatedStorage:WaitForChild("Modules");
local guiTypes = modules:WaitForChild("GuiTypes");

-- ** Dependencies ** --
local GuiElement   = require (guiTypes.Element);

-- ** Self ** --
local Header = GuiElement.new ();

-- ** Constructor ** --
function H.new (mainFrame)
	assert (mainFrame, " Main frame is a required argument");
	
	local header = setmetatable ({
		_mainFrame = mainFrame,
		
		Pressed = Instance.new ("BindableEvent");
	}, Header)
	
	header:_init ();	
	return header;
end

-- ** Public Methods ** --

-- ** Private Methods ** --
-- Initialization
function Header:_init ()
	self:_initProps ();
end
function Header:_initProps ()
	self:_addButton (self._mainFrame.HeaderBtn, function ()
		self:hide ();
		self.Pressed:Fire ();
	end)
end

Header.__index = Header;
return H;