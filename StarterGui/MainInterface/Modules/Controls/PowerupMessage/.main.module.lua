local PM = { };

-- ** Game Services ** --
local ReplicatedStorage = game:GetService ("ReplicatedStorage");

-- ** Game Structure ** --
local modules = ReplicatedStorage:WaitForChild("Modules");
local guiTypes = modules:WaitForChild("GuiTypes");

local data = ReplicatedStorage:WaitForChild ("Data");
local powerupTypes = data:WaitForChild ("PowerupTypes");

-- ** Dependencies ** --
local AnimatedGuiElement = require (guiTypes.AnimatedElement);
local PowerupType = require (powerupTypes);

-- ** Constants ** --
local DEF_MESSAGE_TIME = 4;
local DEF_COLOR_BAD = Color3.fromRGB (170, 0, 0);
local DEF_COLOR_GOOD = Color3.fromRGB (0, 170, 0);

-- ** Contsructor ** --
local PowerupMessage = AnimatedGuiElement.new ();
function PM.new (mainFrame, options)
	if (not options) then options = { }; end
	if (not options.colors) then options.colors = { }; end
	
	local message = setmetatable ({
		_mainFrame = mainFrame,
		_mainParent = mainFrame.Parent,
		
		_length = options.messageLength or DEF_MESSAGE_TIME,
		_colors = {
			[PowerupType.good] = options.colors.good or DEF_COLOR_GOOD,
			[PowerupType.bad] = options.colors.bad or DEF_COLOR_BAD
		}
	}, PowerupMessage);
	
	return message;
end

-- ** Public Methods ** --
function PowerupMessage:show (message, powerupType)
	-- Clone the main frame - This will be used as a new flower to drop
	local flower = self:_createFlower ();
	local elements = self:_getGuiElements (flower);
	
	-- Set the stats on the flower
	self:_setColor (elements.bgImgLbl, self._colors [powerupType]);
	self:_setText (elements.powerupTextLbl, message);
	
	self:_drop (flower);
end

-- ** Private Methods ** --
-- Flowers
function PowerupMessage:_createFlower ()
	local flower = self._mainFrame:Clone();
	flower.Parent = self._mainParent;
	flower.Name = "PowerupFlower";
	
	return flower;
end

-- Find everything, given a flower
function PowerupMessage:_getGuiElements (main)
	local elements = { };
	
	local textsFrame = main.TextsFrame;
	
	elements.powerupTextLbl = textsFrame.PowerupText;
	elements.bgImgLbl = main.BgImage;
	
	return elements;
end

-- Set Values
function PowerupMessage:_setColor (bgImgLbl, color)
	assert (color, " Could not find color for powerup type");
	bgImgLbl.ImageColor3 = color;
end
function PowerupMessage:_setText (powerupTextLbl, text)
	powerupTextLbl.Text = text;
end

-- Drop animation
function PowerupMessage:_drop (main)
	local frameHeight = main.Size.Y.Scale;
	local frameWidth = main.Size.X.Scale;
	
	local randX = math.random (0, (1 - frameWidth) * 100) / 100;
	
	local startPos = UDim2.new (randX, 0, -frameHeight, 0);
	local endPos = UDim2.new (randX, 0, 1, 0);
	
	self:_tweenPosition (main, startPos, endPos, self._length);
end

PowerupMessage.__index = PowerupMessage;
return PM;