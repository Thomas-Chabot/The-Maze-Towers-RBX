-- ** Services ** --
local replicatedStorage = game:GetService ("ReplicatedStorage")

-- ** Game Structure ** --
-- Player
local player = game.Players.LocalPlayer;

-- Base
local minigames = replicatedStorage:WaitForChild ("Minigames")
local remote = replicatedStorage:WaitForChild("UIRemote");

local mainModules = replicatedStorage:WaitForChild ("Modules");

-- Minigames Events & Functions
local minigameEvents = minigames:WaitForChild ("Events");

-- UIRemote Events & Functions
local remoteEvents = remote:WaitForChild("Events");
local remoteFuncs  = remote:WaitForChild("Functions");

local clientRequests = remoteEvents:WaitForChild("ClientRequests");
local serverUpdates  = remoteEvents:WaitForChild("ServerUpdates");

-- Requests to server
local characterPurchaseRequested = clientRequests:WaitForChild("CharacterPurchaseRequested");
local coinsPurchaseRequested = clientRequests:WaitForChild("CoinsPurchaseRequested");
local characterEquipRequested = clientRequests:WaitForChild("CharacterEquipRequested");

-- Updates from server
local coinsUpdated = serverUpdates:WaitForChild("CoinsUpdated");
local charactersUpdated = serverUpdates:WaitForChild("CharactersUpdated");
local inventoryUpdated = serverUpdates:WaitForChild("InventoryUpdated");
local balanceUpdated = serverUpdates:WaitForChild("BalanceUpdated");
local characterUpdated = serverUpdates:WaitForChild("CharacterUpdated");
local equippedUpdated = serverUpdates:WaitForChild("EquippedUpdated");
local errored = serverUpdates:WaitForChild("ServerErrored");
local powerupActivated = serverUpdates:WaitForChild("PowerupActivated");
local floorReached = serverUpdates:WaitForChild("FloorReached");
local winningsUpdated = serverUpdates:WaitForChild("WinningsUpdated");

-- Minigame updates
local gameStarted = minigameEvents:WaitForChild("GameStarted");
local gameEnded = minigameEvents:WaitForChild("GameEnded");
local timerUpdated = minigameEvents:WaitForChild("TimerUpdated");
local timerEnded = minigameEvents:WaitForChild("TimerEnded");
local playerDied = minigameEvents:WaitForChild("PlayerDied");

-- Make request to server
local requestInventory = remoteFuncs:WaitForChild("RequestInventory");
local requestCharacters = remoteFuncs:WaitForChild("RequestCharacters");
local requestCoins = remoteFuncs:WaitForChild("RequestCoins");
local requestCoinsBalance = remoteFuncs:WaitForChild("RequestCoinsBalance");

-- ** GUI Structure ** --
local main = script.Parent;
local modules = main.Modules;
local helpers = modules.Helpers;
local controls = modules.Controls;

local mainHeader = main.GuiMainHeader;
local mainFrame  = main.MainFrame;
local errorFrame = main.ErrorDialogFrame;
local powerupMsgFrame = main.PowerupFrame;
local floorFrame = main.FloorFrame;
local winningsFrame = main.GameWinningsFrame;

local topBarFrame = mainFrame.TopBarFrame;
local screensFrame = mainFrame.ScreensFrame;

local timerFrame = main.TimerFrame;

-- ** Dependencies ** --
local Timer      = require (controls.Timer);
local FloorMessage = require (controls.FloorMessage);
local PowerupMessage = require (controls.PowerupMessage);
local GameWinnings = require (controls.GameWinnings);
local ErrorDialog = require (controls.ErrorDialog);
local Characters = require (controls.Characters);
local Coins      = require (controls.Coins);
local Header     = require (controls.Header);
local HomeScreen = require (controls.HomeScreen);
local StatsGui   = require (controls.StatsGui);
local TopBar     = require (controls.TopBar);
local MainFrame  = require (controls.MainFrame);

local ScreensController = require (helpers.ScreensController);
local ActiveCharacter   = require (mainModules.ActiveCharacter);

local contains = require (mainModules.Contains);

-- Resizable GUI module
local resizableGui = replicatedStorage:WaitForChild ("ResizableGui");
local ResizableGui = require (resizableGui:WaitForChild ("Resizable"));


-- ** Frame Controllers ** --
local control = ScreensController.new ();
local main   = MainFrame.new (mainFrame);
local header = Header.new (mainHeader);
local home   = HomeScreen.new (screensFrame.HomeScreenFrame);
local stats  = StatsGui.new (screensFrame.StatsFrame);
local coins  = Coins.new (screensFrame.BuyCoinsFrame);
local characters = Characters.new (screensFrame.CharactersFrame, {owned = false});
local inventory  = Characters.new (screensFrame.InventoryFrame, {owned = true});
local topBar = TopBar.new (topBarFrame);
local errorDialog = ErrorDialog.new (errorFrame);
local powerupMessage = PowerupMessage.new (powerupMsgFrame);
local floorMessage = FloorMessage.new (floorFrame);
local timer = Timer.new (timerFrame);
local winnings = GameWinnings.new (winningsFrame);

-- ** Main Functions ** --
function gotoScreen (screen, ...)
	control:goto (screen, ...);
	update ();
end
function update ()
	local isFirstScreen = control:isFirst ();
	local isLastScreen  = control:isLast ();
	
	topBar:setBackEnabled (not isFirstScreen);
	topBar:setForwardEnabled (not isLastScreen);
end
function close ()
	main:hide ();
	
	control:hide ();
	control:reset ();
	
	header:show ();	
end

function showAll ()
	timer:setInGame (false);
	header:show();
end
function hideAll ()
	close();
	header:hide();
	timer:hide();
	
	timer:setInGame (true);
end

function resetWinnings ()
	winnings:hide ();
	winnings:update (0);
end

-- ** Frame Events ** --
-- Top Bar
topBar.Close.Event:connect (close)
topBar.Home.Event:connect (function ()
	gotoScreen (home);
end)
topBar.Back.Event:connect (function ()
	control:back ();
	update ();
end)
topBar.Forward.Event:connect (function ()
	control:next ();
	update ();
end)
topBar.BuyCoins.Event:connect (function ()
	gotoScreen (coins);
end)

-- Home Screen
home.CoinsSelected.Event:connect (function ()
	gotoScreen (coins);
end)
home.CharactersSelected.Event:connect (function ()
	gotoScreen (characters);
end)
home.InventorySelected.Event:connect (function ()
	gotoScreen (inventory);
end)

-- Coins
coins.PurchaseRequested.Event:connect (function (id)
	coinsPurchaseRequested:FireServer (id);
end)

-- Characters
characters.CharacterSelected.Event:connect (function (characterData, ...)
	gotoScreen (stats, characterData, ...);
end)

-- Inventory
inventory.CharacterSelected.Event:connect (function (characterData, ...)
	gotoScreen (stats, characterData, ...);
end)

-- Stats Screen
stats.BuyButtonPressed.Event:connect (function(character)
	characterPurchaseRequested:FireServer (character);
end)
stats.EquipButtonPressed.Event:connect (function (character)
	characterEquipRequested:FireServer (character);
end)

-- Main Header
header.Pressed.Event:connect (function ()
	gotoScreen (home);
	
	header:hide ();
	main:show ();
end)

-- Error Dialog
errorDialog.ButtonPressed.Event:connect (function ()
	errorDialog:hide ();
	control:enable ();
	topBar:enable ();
end)

-- GUI Resizing
local resizing = ResizableGui.new (script.Parent.MainFrame, {
	uniqId = "MazeInterface",
	size = 1,
	minimumSize = UDim2.new (0, 200, 0, 200)
});

resizing.Updated.Event:connect (function ()
	control:update ();
end)



-- Server Updates
coinsUpdated.OnClientEvent:connect (function (coinsData)
	coins:setup (coinsData);
end)
charactersUpdated.OnClientEvent:connect (function (charactersData, details)
	characters:setup (charactersData);
end)
inventoryUpdated.OnClientEvent:connect (function (inventoryData)
	inventory:setup (inventoryData);
end)
balanceUpdated.OnClientEvent:connect (function (balance)
	topBar:updateBalance (balance);
end)
characterUpdated.OnClientEvent:connect (function (characterStats, isOwned)
	control:updateActiveScreen (stats, characterStats, isOwned);
end)
equippedUpdated.OnClientEvent:connect (function (activeId)
	ActiveCharacter:set (activeId);
	control:redrawScreen (stats);
end)
errored.OnClientEvent:connect (function (errorMessage)
	errorDialog:show (errorMessage);
	control:disable ();
	topBar:disable ();
end)

powerupActivated.OnClientEvent:connect (function (powerupName, powerupType)
	powerupMessage:show (powerupName, powerupType);
end)

floorReached.OnClientEvent:connect (function (floorNum, maxFloor)
	floorMessage:show (floorNum, maxFloor);
end)

winningsUpdated.OnClientEvent:connect (function (totalWinnings)
	winnings:update (totalWinnings);
end)

gameStarted.OnClientEvent:connect (function (players)
	if (not contains (players, player)) then return end	
	hideAll ()
	winnings:show ();
end)
gameEnded.OnClientEvent:connect (function ()
	showAll ();
	resetWinnings();
end)
playerDied.OnClientEvent:connect (function (_, plyr)
	if (plyr ~= player) then return end
	showAll ();
end)

timerUpdated.OnClientEvent:connect (function (timeLeft)
	timer:show (timeLeft);
end);
timerEnded.OnClientEvent:connect (function ()
	timer:hide();
end)

-- Initial Setup
local inventoryData = requestInventory:InvokeServer ();
local charactersData = requestCharacters:InvokeServer ();
local coinsData = requestCoins:InvokeServer ();
local coinsBalance = requestCoinsBalance:InvokeServer ();

local active  = inventoryData.active;
inventoryData = inventoryData.inventory;

ActiveCharacter:set (active);
coins:setup (coinsData);
inventory:setup (inventoryData);
characters:setup (charactersData);
topBar:updateBalance (coinsBalance);