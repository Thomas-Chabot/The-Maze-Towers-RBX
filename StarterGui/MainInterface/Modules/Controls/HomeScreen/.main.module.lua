local HS = { };

-- ** Game Services ** --
local ReplicatedStorage = game:GetService ("ReplicatedStorage");

-- ** Game Structure ** --
local modules = ReplicatedStorage:WaitForChild("Modules");
local guiTypes = modules:WaitForChild("GuiTypes");

-- ** Dependencies ** --
local GuiElement   = require (guiTypes.Element);

-- ** Constructor ** --
local HomeScreen = GuiElement.new ();
function HS.new (mainFrame)
	local homeScreen = setmetatable ({
		_mainFrame = mainFrame,
		
		_coinsFrame = nil,
		_charsFrame = nil,
		_inventoryFrame = nil,
		
		CoinsSelected = Instance.new ("BindableEvent"),
		CharactersSelected = Instance.new ("BindableEvent"),
		InventorySelected = Instance.new ("BindableEvent")
	}, HomeScreen);
	
	homeScreen:_init ();
	return homeScreen;
end

function HomeScreen:_init ()
	self:_initProps ();
	self:_initButtons ();
end
function HomeScreen:_initProps ()
	self._coinsFrame = self._mainFrame.GotoCoinsFrame;
	self._charsFrame = self._mainFrame.GotoCharactersFrame;
	self._inventoryFrame = self._mainFrame.GotoInventoryFrame;
end
function HomeScreen:_initButtons ()
	self:_addButton (self._coinsFrame.BgButton, self.CoinsSelected);
	self:_addButton (self._charsFrame.BgButton, self.CharactersSelected);
	self:_addButton (self._inventoryFrame.BgButton, self.InventorySelected);
end

HomeScreen.__index = HomeScreen;
return HS;