local UIRemote = {
	-- UI events
	CharacterPurchaseRequest = Instance.new ("BindableEvent"),
	CoinsPurchaseRequest = Instance.new ("BindableEvent"),
	CharacterEquipRequest = Instance.new ("BindableEvent"),
	
	-- Game getters
	GetInventory = Instance.new ("BindableFunction"),
	GetCharacters = Instance.new ("BindableFunction"),
	GetCoins = Instance.new ("BindableFunction"),
	GetBalance = Instance.new ("BindableFunction"),
	
	-- Minigame getters
	GetActivePlayers = Instance.new ("BindableFunction"),
	CanSpectate = Instance.new ("BindableFunction"),
	
	-- Game events
	BalanceUpdated = Instance.new ("BindableEvent"),
	InventoryUpdated = Instance.new ("BindableEvent"),
	UpdateCharacter = Instance.new ("BindableEvent"),
	UpdateEquipped  = Instance.new ("BindableEvent"),
	CharactersUpdated = Instance.new ("BindableEvent"),
	Errored = Instance.new ("BindableEvent"),
	PowerupActivated = Instance.new ("BindableEvent"),
	FloorReached = Instance.new ("BindableEvent"),
	WinningsUpdated = Instance.new ("BindableEvent"),
	
	-- Minigame events
	TimerUpdated = Instance.new ("BindableEvent"),
	TimerEnded = Instance.new ("BindableEvent"),
	GameStarted = Instance.new ("BindableEvent"),
	GameEnded = Instance.new ("BindableEvent"),
	PlayerDied = Instance.new ("BindableEvent")
};

-- ** Services ** --
local serverScriptService = game:GetService ("ServerScriptService");
local serverStorage = game:GetService ("ServerStorage");
local replicatedStorage = game:GetService ("ReplicatedStorage");
local collectionService = game:GetService ("CollectionService");

-- ** Game Structure ** --
-- UI Structure
local uiRemote = replicatedStorage:WaitForChild ("UIRemote");
local remoteEvts = uiRemote:WaitForChild ("Events");
local remoteFuncs = uiRemote:WaitForChild ("Functions");

local serverUpdates = remoteEvts.ServerUpdates;
local clientRequests = remoteEvts.ClientRequests;

-- Minigames Structure
local minigames = replicatedStorage:WaitForChild ("Minigames");
local minigameEvents = minigames:WaitForChild ("Events");
local minigameFuncs = minigames:WaitForChild ("Functions");

-- Data
local data = serverStorage:WaitForChild ("Data");

-- Remote Event module
local modules = serverScriptService.Modules;
local remote  = modules.Remote;


-- ** Remote Events & Functions ** --
-- Game getters
local inventoryRequest = remoteFuncs.RequestInventory;
local characterRequest = remoteFuncs.RequestCharacters;
local coinsRequest     = remoteFuncs.RequestCoins;
local balanceRequest   = remoteFuncs.RequestCoinsBalance;

-- Minigame getters
local getActivePlayers = minigameFuncs.GetActivePlayers;
local canSpectate      = minigameFuncs.GetSpectateActive;

-- Game events
local balanceUpdated = serverUpdates.BalanceUpdated;
local inventoryUpdated = serverUpdates.InventoryUpdated;
local characterUpdated = serverUpdates.CharacterUpdated;
local equippedUpdated = serverUpdates.EquippedUpdated;
local charactersUpdated = serverUpdates.CharactersUpdated;
local serverError = serverUpdates.ServerErrored;
local powerupActivated = serverUpdates.PowerupActivated;
local floorReached = serverUpdates.FloorReached;
local winningsUpdated = serverUpdates.WinningsUpdated;

-- UI events
local characterEquip = clientRequests.CharacterEquipRequested;
local charPurchaseRequest = clientRequests.CharacterPurchaseRequested;
local coinsPurchaseRequest = clientRequests.CoinsPurchaseRequested;

-- Minigame events
local timerUpdated = minigameEvents.TimerUpdated;
local timerEnded = minigameEvents.TimerEnded;
local gameStarted = minigameEvents.GameStarted;
local gameEnded = minigameEvents.GameEnded;
local playerDied = minigameEvents.PlayerDied;

-- ** Data Dependencies ** --
local Remote = require (remote.Main);
local coinsData = require (data.CoinsData);
local characters = require (data.Characters);

Remote.redirect (characterEquip, UIRemote.CharacterEquipRequest);
Remote.redirect (charPurchaseRequest, UIRemote.CharacterPurchaseRequest);
Remote.redirect (coinsPurchaseRequest, UIRemote.CoinsPurchaseRequest);

-- ** UIRemote Functions ** --
-- Game functions
Remote.setupFunction (inventoryRequest, UIRemote.GetInventory);
Remote.setupFunction (characterRequest, UIRemote.GetCharacters);
Remote.setupFunction (coinsRequest, UIRemote.GetCoins);
Remote.setupFunction (balanceRequest, UIRemote.GetBalance);

-- Minigame functions
Remote.setupFunction (getActivePlayers, UIRemote.GetActivePlayers);
Remote.setupFunction (canSpectate, UIRemote.CanSpectate);

-- ** UIRemote Events ** --
-- Game events
Remote.redirectToClient (UIRemote.BalanceUpdated, balanceUpdated);
Remote.redirectToClient (UIRemote.UpdateCharacter, characterUpdated);
Remote.redirectToClient (UIRemote.UpdateEquipped, equippedUpdated);
Remote.redirectToClient (UIRemote.CharactersUpdated, charactersUpdated);
Remote.redirectToClient (UIRemote.InventoryUpdated, inventoryUpdated);
Remote.redirectToClient (UIRemote.Errored, serverError);
Remote.redirectToClient (UIRemote.PowerupActivated, powerupActivated);
Remote.redirectToClient (UIRemote.FloorReached, floorReached);
Remote.redirectToClient (UIRemote.WinningsUpdated, winningsUpdated);

-- Minigame events
Remote.redirectToClient (UIRemote.TimerUpdated, timerUpdated);
Remote.redirectToClient (UIRemote.TimerEnded, timerEnded);
Remote.redirectToClient (UIRemote.GameStarted, gameStarted);
Remote.redirectToClient (UIRemote.GameEnded, gameEnded);
Remote.redirectToClient (UIRemote.PlayerDied, playerDied);

-- ** Tags ** --
collectionService:AddTag (script, _G.GameTags.UIRemote)

return UIRemote;