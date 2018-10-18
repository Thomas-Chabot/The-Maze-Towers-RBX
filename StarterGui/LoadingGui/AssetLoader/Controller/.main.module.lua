local C          = { };

-- ** Game Services ** --
local ReplicatedStorage = game:GetService ("ReplicatedStorage");

-- ** Game Structure ** --
local modules = ReplicatedStorage:WaitForChild("Modules");
local guiTypes = modules:WaitForChild("GuiTypes");

-- ** Dependencies ** --
local GuiElement = require (guiTypes.Element);

-- ** Constructor ** --
local Controller = GuiElement.new();
function C.new (mainFrame)
	local controller = setmetatable ({
		_mainFrame = mainFrame,

		_loadingBar = { }
	}, Controller);
	
	controller:_init();
	return controller;
end

-- ** Public Methods ** --
function Controller:update (loadedAssets, totalAssets)
	self:_updateScrollBar (loadedAssets, totalAssets);
end

-- ** Private Methods ** --
-- Initialization
function Controller:_init()
	self:_initProperties();
end
function Controller:_initProperties()
	local contentsFrame = self._mainFrame.ContentsFrame;
	local loadingBarFrame = contentsFrame.LoadingBarFrame;
	
	self._loadingBar = {
		Background = loadingBarFrame,
		Loaded = loadingBarFrame.LoadedFrame
	};
	
	print (self._loadingBar.Loaded, loadingBarFrame, loadingBarFrame.LoadedFrame)
end

-- Update the scroll bar size
function Controller:_updateScrollBar (loaded, total)
	local amountLoaded = loaded / total;
	self._loadingBar.Loaded.Size = UDim2.new (amountLoaded, 0, 1, 0);
end

Controller.__index = Controller;
return C;