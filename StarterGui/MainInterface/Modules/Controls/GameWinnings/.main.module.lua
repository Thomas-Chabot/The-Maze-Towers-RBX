local GW = { };

-- ** Game Services ** --
local ReplicatedStorage = game:GetService ("ReplicatedStorage");

-- ** Game Structure ** --
local modules = ReplicatedStorage:WaitForChild("Modules");
local guiTypes = modules:WaitForChild("GuiTypes");

-- ** Dependencies ** --
local GuiElement = require (guiTypes.Element);

-- ** Constructor ** --
local GameWinnings = GuiElement.new ();
function GW.new (mainFrame)
	local winnings = setmetatable ({
		_mainFrame = mainFrame,
		_coinsLbl = nil
	}, GameWinnings);
	
	winnings:_init ();
	return winnings;
end

-- ** Public Methods ** --
function GameWinnings:update (value)
	self._coinsLbl.Text = value;
end

-- ** Private Methods ** --
function GameWinnings:_init ()
	self:_initProperties();
end
function GameWinnings:_initProperties ()
	self._coinsLbl = self._mainFrame.ValueLabel;
end


GameWinnings.__index = GameWinnings;
return GW;