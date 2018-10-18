local SP        = { };

-- ** Game Services ** --
local ReplicatedStorage = game:GetService ("ReplicatedStorage");

-- ** Game Structure ** --
local modules = ReplicatedStorage:WaitForChild("Modules");
local guiTypes = modules:WaitForChild("GuiTypes");

-- ** Dependencies ** --
local GuiElement   = require (guiTypes.Element);
local Currencies    = require (modules.Currencies);
local ActiveCharacter = require (modules.ActiveCharacter);

-- ** Self ** --
local StatsPage = GuiElement.new ();

-- ** Constructor ** --
function SP.new (frame)
	assert (frame, "The main frame is a required argument");
	
	local statsPage = setmetatable ({
		_mainFrame = frame,
		_charImageLbl = nil,
		_charNameLbl = nil,
		
		_buyButton   = nil,
		_priceLbl    = nil,
		
		_equipButton = nil,
		_equippedLbl = nil,
		
		_heightPercent = nil,
		_luckPercent   = nil,
		_speedPercent  = nil,
		_visionPercent = nil,
		
		_buyBtnFrame = nil,
		_equipBtnFrame = nil,
		
		_charStats = nil,
		
		BuyButtonPressed = Instance.new("BindableEvent"),
		EquipButtonPressed = Instance.new("BindableEvent")
	}, StatsPage);
	
	statsPage:_init ();
	return statsPage;
end

-- ** Public Methods ** --
function StatsPage:show (itemStats, isOwned)
	self:_setVisibility (true);
	self:_update (itemStats, isOwned);
end

-- ** Private Methods ** --
-- Initialization
function StatsPage:_init ()
	self:_initVariables ();
end
function StatsPage:_initVariables ()
	local mainFrame = self._mainFrame;
	local charInfoFrame = self._mainFrame:FindFirstChild ("CharacterInfo");
	local charStatsFrame = self._mainFrame:FindFirstChild ("CharacterStats");
	local buttonsFrame = charStatsFrame:FindFirstChild ("ButtonsFrame");
	local buyBtnFrame = buttonsFrame:FindFirstChild ("BuyButtonFrame");
	local equipBtnFrame = buttonsFrame:FindFirstChild ("EquipButtonFrame")
	local statsFrame = charStatsFrame:FindFirstChild ("StatsFrame");
	
	self._charImageLbl = charInfoFrame.CharacterImage;
	self._charNameLbl = charInfoFrame.CharacterName;
	
	self._priceLbl = buyBtnFrame.PriceLabel;
	
	self._heightPercent = self:_percentageLabel (statsFrame.HeightFrame);
	self._luckPercent = self:_percentageLabel (statsFrame.LuckFrame);
	self._speedPercent = self:_percentageLabel (statsFrame.SpeedFrame);
	self._visionPercent = self:_percentageLabel (statsFrame.VisionFrame);
	
	-- Add the button
	self._buyButton = buyBtnFrame.BgImgBtn;
	self:_addButton (self._buyButton, function ()
		self.BuyButtonPressed:Fire (self._charStats);
	end);
	self:_addButton (equipBtnFrame.BgImgBtn, function ()
		self.EquipButtonPressed:Fire (self._charStats);
	end);
	
	-- Equip Label & Button
	self._equippedLbl = equipBtnFrame.EquippedLabel;
	self._equipButton = equipBtnFrame.BgImgBtn;
	
	-- Store the Buy & Equip frames to be toggled between
	self._buyBtnFrame = buyBtnFrame;
	self._equipBtnFrame = equipBtnFrame;
end

-- Button Input
function StatsPage:_isButtonPress (input)
	
end

-- Gui Structure
function StatsPage:_percentageLabel (frame)
	return frame.PercentBar.Percentage;
end

-- Update
function StatsPage:_update (itemStats, isOwned)
	self._charImageLbl.Image = itemStats.Image;
	self._charNameLbl.Text = itemStats.Name;
	self._priceLbl.Text = itemStats.Price .. " " .. Currencies.coin;
	
	self:_updatePercentageBar (self._heightPercent, itemStats.Height);
	self:_updatePercentageBar (self._luckPercent, itemStats.Luck);
	self:_updatePercentageBar (self._speedPercent, itemStats.Speed);
	self:_updatePercentageBar (self._visionPercent, itemStats.Vision);
	
	if (isOwned) then
		self:_setEquipFrameVisible ();
	else
		self:_setBuyFrameVisible ();
	end
	
	local equippedId = ActiveCharacter:get();
	local isEquipped = (itemStats.Id == equippedId);
	
	if (isEquipped) then
		self._equippedLbl.Text = "Equipped";
	else
		self._equippedLbl.Text = "Equip";
	end
	
	self:_setEnabled (self._equipButton, not isEquipped);
	
	self._charStats = itemStats;
end

-- Button Frames
function StatsPage:_setEquipFrameVisible ()
	self:_setFramesVisible ({buy = false, equip = true});
end
function StatsPage:_setBuyFrameVisible ()
	self:_setFramesVisible ({buy = true, equip = false});
end
function StatsPage:_setFramesVisible (visible)
	self._buyBtnFrame.Visible = visible.buy;
	self._equipBtnFrame.Visible = visible.equip;
end

-- Percentages
function StatsPage:_updatePercentageBar (percentBar, percentage)
	percentBar.Size = UDim2.new (percentage, 0, percentBar.Size.Y.Scale, 0)
end

StatsPage.__index = StatsPage;
return SP;