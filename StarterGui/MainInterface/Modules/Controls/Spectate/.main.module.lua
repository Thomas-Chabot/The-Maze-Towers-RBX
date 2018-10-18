local S = { };

-- ** Game Services ** --
local ReplicatedStorage = game:GetService ("ReplicatedStorage");

-- ** Game Structure ** --
local modules = ReplicatedStorage:WaitForChild("Modules");
local guiTypes = modules:WaitForChild("GuiTypes");

-- ** Dependencies ** --
local GuiElement   = require (guiTypes.Element);

-- ** Self ** --
local Spectate = GuiElement.new ();
function S.new (mainFrame)
	local spectate = setmetatable ({
		_mainFrame = mainFrame,
		
		ButtonPressed = Instance.new ("BindableEvent")
	}, Spectate);
	
	spectate:_init ();
	return spectate;
end

-- ** Private Methods ** --
function Spectate:_init ()
	self:_initButtons ();
end
function Spectate:_initButtons ()
	local spectateButton = self._mainFrame.HeaderBtn;
	self:_addButton (spectateButton, self.ButtonPressed);
end

Spectate.__index = Spectate;
return S;