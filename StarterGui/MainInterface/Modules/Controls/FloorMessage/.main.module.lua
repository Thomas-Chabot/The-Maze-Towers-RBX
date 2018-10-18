local FM = { };

-- ** Game Services ** --
local ReplicatedStorage = game:GetService ("ReplicatedStorage");

-- ** Game Structure ** --
local modules = ReplicatedStorage:WaitForChild("Modules");
local guiTypes = modules:WaitForChild("GuiTypes");

-- ** Dependencies ** --
local AnimatedGuiElement = require (guiTypes.AnimatedElement);

-- ** Constants ** --
local DEF_MSG_LENGTH = 3;
local DEF_START_POS = UDim2.new (1, -200, 1, 0);
local DEF_END_POS   = UDim2.new (1, -200, 1, -30);
local DEF_EFFECT_LENGTH = 0.2

-- ** Contsructor ** --
local FloorMessage = AnimatedGuiElement.new ();
function FM.new (mainFrame)
	local message = setmetatable ({
		_mainFrame = mainFrame,
		_floorLabel = nil
	}, FloorMessage);
	
	message:_init();
	return message;
end

-- ** Public Methods ** --=
function FloorMessage:show (floorNum, maxFloor)
	local text;
	if (floorNum > maxFloor) then
		text = "Roof";
	else
		text = "Floor " .. floorNum;
	end
	
	self._floorLabel.Text = text;
	self:_slide (self._mainFrame, DEF_MSG_LENGTH, DEF_START_POS, DEF_END_POS, DEF_EFFECT_LENGTH);
end

-- ** Private Message ** --
function FloorMessage:_init ()
	self:_initProperties ();
end
function FloorMessage:_initProperties ()
	local textsFrame = self._mainFrame.TextsFrame;
	local floorLabel = textsFrame.FloorLabel;
	
	self._floorLabel = floorLabel;
end

FloorMessage.__index = FloorMessage;
return FM;