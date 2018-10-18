local TB = { };

-- ** Game Services ** --
local ReplicatedStorage = game:GetService ("ReplicatedStorage");

-- ** Game Structure ** --
local modules = ReplicatedStorage:WaitForChild("Modules");
local guiTypes = modules:WaitForChild("GuiTypes");

-- ** Dependencies ** --
local GuiElement   = require (guiTypes.Element);
local Currency   = require (modules.Currencies);

-- ** Self ** --
local TopBar = GuiElement.new ();

-- ** Constructor ** --
function TB.new (frame)
	local controller = setmetatable ({
		_mainFrame = frame,
		_coinsTxt  = nil,
		
		_nextArrow = nil,
		_backArrow = nil,
		
		Close = Instance.new ("BindableEvent"),
		Home  = Instance.new ("BindableEvent"),
		Back  = Instance.new ("BindableEvent"),
		Forward = Instance.new ("BindableEvent"),
		BuyCoins = Instance.new ("BindableEvent")
	}, TopBar);

	controller:_init ();
	return controller;
end

-- ** Public Methods ** --
function TopBar:setBackEnabled (isF)
	self:_setEnabled (self._backArrow, isF);
end
function TopBar:setForwardEnabled (isL)
	self:_setEnabled (self._nextArrow, isL);
end
function TopBar:updateBalance (numCoins)
	self._coinsTxt.Text = numCoins .. " " .. Currency.coin;
end

-- ** Private Methods ** --
function TopBar:_init ()
	self:_initProps ();
end
function TopBar:_initProps ()
	local arrows  = self._mainFrame:FindFirstChild ("ArrowButtons");
	local coins   = self._mainFrame:FindFirstChild ("CoinsFrame");
	local endBtns = self._mainFrame:FindFirstChild ("EndButtonsPanel");
	
	-- Text labels
	self._coinsTxt = coins.CoinsText;
	
	-- Buttons
	self._nextArrow = arrows.ForwardButton;
	self._backArrow = arrows.BackButton;
	
	self:_addButton (arrows.HomeButton, self.Home);
	self:_addButton (self._nextArrow, self.Forward);
	self:_addButton (self._backArrow, self.Back);
	self:_addButton (coins.CoinsBtn, self.BuyCoins);
	self:_addButton (endBtns.CloseButton, self.Close);
end

TopBar.__index = TopBar;
return TB;