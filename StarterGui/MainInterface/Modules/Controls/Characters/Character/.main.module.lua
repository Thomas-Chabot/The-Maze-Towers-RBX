--[[
	Main module for initializing a single Character inside the Characters frame.
	
	Constructor takes two arguments:
		character - Character - The character's stats
		parent    - GUI       - The gui to put the new character into. Any GUI type
		
	Methods:
		remove ()
			Removes the character frame.
--]]

local Character = { };
local C         = { };

-- ** Game Services ** --
local replicatedStorage = game:GetService ("ReplicatedStorage");

-- ** Game Structure ** --
local modules = replicatedStorage:WaitForChild ("Modules");

-- ** Dependencies ** --
local Currency = require (modules.Currencies);
local ButtonStyling = require (modules.ButtonStyles);

-- ** Constants / Globals ** --
local charFrame = script.CharacterFrame:Clone ();
local DEF_LAYOUT_ORDER = 1;
local DEF_FRAME_SIZE = UDim2.new (0.4, 0, 0.83, 0)

local MAX_STAT_VAL = 99; -- Displays better than with 100

-- ** Constructor ** --
function C.add (characterInfo, parent, options)
	if (not options) then options = { }; end
	
	local character = setmetatable ({
		_charInfo = characterInfo,
		_parent   = parent,
		_layout   = options.layoutOrder or DEF_LAYOUT_ORDER,
		_size     = options.size or DEF_FRAME_SIZE,
		_isOwned  = options.isOwned,
		
		_charButton = nil,
		_charFrame = nil,
		
		Selected = Instance.new ("BindableEvent")
	}, Character);
	
	character:_init ();
	return character;
end

-- ** Public Methods ** --
function Character:getButton ()
	return self._charButton;
end
function Character:remove ()
	self._charFrame:Destroy ();
end
function Character:updateSize (size)
	self._charFrame.Size = size;
end

-- ** Private Methods ** --
-- Initialization
function Character:_init ()
	local char = charFrame:Clone ();
	char.Size = self._size;
	
	self:_populate (char);
	self:_initEvents (char);
	
	char.Parent = self._parent;
	self._charFrame = char;
end
function Character:_initEvents (charFrame)
	local mainButton = charFrame.CharButton;
	mainButton.MouseButton1Click:connect (function ()
		self.Selected:Fire ();
	end)
end

-- Populating
function Character:_populate (frame)
	local topFrame   = frame.TopFrame;
	local statsFrame = frame.StatsFrame;
	
	local charImgLbl = frame.CharacterImg;
	
	local visionStat = self:_getStatLabel (statsFrame.VisionFrame);
	local speedStat  = self:_getStatLabel (statsFrame.SpeedFrame);
	local heightStat = self:_getStatLabel (statsFrame.HeightFrame);
	local luckStat   = self:_getStatLabel (statsFrame.LuckFrame);
	
	local priceLbl   = topFrame.PriceLabel;
	local nameLbl    = topFrame.TitleLabel;
	
	charImgLbl.Image = self._charInfo.Image;

	self:_setStat (visionStat, self._charInfo.Vision);
	self:_setStat (speedStat, self._charInfo.Speed);
	self:_setStat (heightStat, self._charInfo.Height);
	self:_setStat (luckStat, self._charInfo.Luck);
	
	priceLbl.Text = self._charInfo.Price .. " " .. Currency.coin;
	nameLbl.Text  = self._charInfo.Name;
	
	priceLbl.Visible = not self._isOwned;
	
	frame.LayoutOrder = self._layout;
	self._charButton = frame.CharButton;
end

-- Stats Control
function Character:_getStatLabel (mainFrame)
	return mainFrame.StatValueFrame.ValueLabel;
end
function Character:_setStat (label, statValue)
	label.Text = math.min (math.floor (statValue * 100), MAX_STAT_VAL);
end

Character.__index = Character;
return C;