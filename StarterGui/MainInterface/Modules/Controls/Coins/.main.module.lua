--[[
	Coins amounts should have data:
		coinImage  ImageUrl
		amount     Integer
		title      String
		price      Integer
		deal       Table [ OPTIONAL ]
			color  Color3
			text   String
		
--]]
local C     = { };

-- ** Game Services ** --
local ReplicatedStorage = game:GetService ("ReplicatedStorage");

-- ** Game Structure ** --
local modules = ReplicatedStorage:WaitForChild("Modules");
local guiTypes = modules:WaitForChild("GuiTypes");

-- ** Dependencies ** --
local ScrollingLayout = require (guiTypes.ScrollingLayout);
local Currency        = require (modules.Currencies);

-- ** Constants ** --
local coinsFrame = script.CoinFrame;
local dealFrame  = script.DealFrame;

local EXTRA_SPACE = coinsFrame.Size.Y.Offset / 2;

-- ** Constructor ** --
local Coins = ScrollingLayout.new ();
function C.new (frame, amounts)
	local coins = setmetatable ({
		_mainFrame = frame,
		_displayFrame = nil,
		_amountFrames = { },
		_layout = nil,
		
		_extra = Vector2.new (0, EXTRA_SPACE),
		
		_amounts   = amounts,
		
		PurchaseRequested = Instance.new ("BindableEvent")
	}, Coins);
	
	coins:_init ();
	return coins;
end

-- ** Public Methods ** --
function Coins:setup (amounts)
	self:_initGuiSetup (amounts);
end

-- ** Private Methods ** --
-- initialization
function Coins:_init ()
	self:_initProps ();
	self:_initGuiSetup (self._amounts);
end
function Coins:_initProps ()
	self._displayFrame = self._mainFrame.CoinsDisplayFrame;
	self._layout = self._displayFrame.UIGridLayout;
end
function Coins:_initGuiSetup (amounts)
	if (not amounts) then return end
	
	for _,amntFrame in pairs (self._amountFrames) do
		amntFrame:Destroy ();
	end
	
	for id,details in pairs (amounts) do
		local amntFrame = self:_createAmountFrame (id, details);
		amntFrame.Parent = self._displayFrame;
		amntFrame.LayoutOrder = id;
		
		table.insert (self._amountFrames, amntFrame);
	end
	
	self:_reapplyLayout ();
end

-- Frame Creation
-- coins frame
function Coins:_createAmountFrame (id, details)
	local frame = coinsFrame:Clone ();
	
	-- Required children
	local coinsImg    = frame.CoinsImg;
	local costLbl     = frame.CostLabel;
	local titleTxt    = frame.TitleText;
	local buyBtnFrame = frame.BuyBtnFrame;
	local buyBtn      = buyBtnFrame.BuyButton;
	local priceTxt    = buyBtnFrame.BuyButtonTxt;
	
	-- Set up the details
	coinsImg.Image = details.coinImage;
	costLbl.Text   = details.amount .. " " .. Currency.coin;
	titleTxt.Text  = details.title;
	priceTxt.Text  = details.price .. " " .. Currency.robux;
	
	-- Add the button control
	self:_addButton (buyBtn, self.PurchaseRequested, id);
	
	-- Set up the deal, if there is one
	if (details.deal) then
		self:_setupDeal (frame, details.deal);
	end
	
	return frame;
end

-- deals frame
function Coins:_setupDeal (frame, deal)
	local dealFrame = self:_createDealFrame (deal);
	dealFrame.Parent = frame;
end
function Coins:_createDealFrame (dealDetails)
	local dealFrame = dealFrame:Clone ();
	if (dealDetails.color) then
		dealFrame.LabelBg.ImageColor3 = dealDetails.color;
	end
	
	dealFrame.LabelTxt.Text = dealDetails.text;
	return dealFrame;
end

Coins.__index = Coins;
return C;