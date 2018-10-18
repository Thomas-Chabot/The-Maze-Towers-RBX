local ReplicatedStorage = game:GetService ("ReplicatedStorage");
local ContentProvider   = game:GetService ("ContentProvider");

-- ** Game Structure ** --
-- Gui
local guiFrame      = script.Parent.BGFrame;

-- Remotes - Main folders
local remoteFunctions   = ReplicatedStorage:WaitForChild ("RemoteFunctions");
local remoteEvents      = ReplicatedStorage:WaitForChild ("RemoteEvents");

-- Remote Functions
local getAssetsRemote   = remoteFunctions.GetAssets;
local numAssetsRemote   = remoteFunctions.NumAssets;
local assetsReady       = remoteFunctions.AssetsReady;

-- Remote Events
local assetsAdded       = remoteEvents.AssetsAdded;
local gameLoaded        = remoteEvents.GameLoaded;

-- ** Dependencies ** --
local Loader = require (script.Loader);
local GuiController = require (script.Controller);
local CoreGui = require (script.CoreGui);

-- ** Object Instantiations ** --
local loader = Loader.new ();
local control = GuiController.new (guiFrame);

-- ** Global Data ** --
local totalAssets = 0;
local isLoading = false;

-- ** Main Functions ** --
function loadSetup ()
	if (not assetsReady:InvokeServer()) then
		return
	end
	
	startLoading()
end

function startLoading ()
	if (isLoading) then return end
	isLoading = true;
	
	-- Load assets in a new thread, so we don't freeze the game
	-- for loads
	spawn (loadAssets);
end

function loadAssets ()
	local assets, isFinished = getAssetsRemote:InvokeServer();
	totalAssets = numAssetsRemote:InvokeServer();
		
	loader:load (assets);
	
	if (#assets ~= totalAssets) then
		wait(1)
		loadAssets()
	else
		control:hide();
		CoreGui:Enable();
		gameLoaded:FireServer()
	end
end

-- Events
-- Remote Events
assetsAdded.OnClientEvent:connect (function ()
	startLoading()
end)

-- Object Events
loader.Updated.Event:connect (function (numAssetsReady)
	control:update (numAssetsReady, totalAssets);
end)

-- Main
CoreGui:Disable();
control:show();
	
loadSetup()