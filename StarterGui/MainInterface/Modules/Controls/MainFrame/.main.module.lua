local MF = { };

-- ** Game Services ** --
local ReplicatedStorage = game:GetService ("ReplicatedStorage");

-- ** Game Structure ** --
local modules = ReplicatedStorage:WaitForChild("Modules");
local guiTypes = modules:WaitForChild("GuiTypes");

-- ** Dependencies ** --
local GuiElement   = require (guiTypes.Element);

-- ** Constructor ** --
local MainFrame = GuiElement.new ();
function MF.new (mainFrame)
	return setmetatable ({
		_mainFrame = mainFrame
	}, MainFrame);
end

MainFrame.__index = MainFrame;
return MF;