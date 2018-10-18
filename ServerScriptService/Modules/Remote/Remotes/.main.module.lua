local Remotes = {
	WaitForStreamed = Instance.new ("BindableFunction"),
	
	AssetsReady     = Instance.new ("BindableFunction"),
	GetAssets       = Instance.new ("BindableFunction"),
	NumAssets       = Instance.new ("BindableFunction"),
	
	Loaded = Instance.new ("BindableEvent"),
	AssetsAdded = Instance.new ("BindableEvent"),
	
	TrapPlaced = Instance.new ("BindableEvent"),
	
	GuideUpdated = Instance.new ("BindableEvent"),
	GuideCompleted = Instance.new ("BindableEvent")
};

-- ** Game Services ** --
local ReplicatedStorage = game:GetService ("ReplicatedStorage");
local CollectionService = game:GetService ("CollectionService");

-- ** Game Structure ** --
local remoteFunctions = ReplicatedStorage:WaitForChild ("RemoteFunctions");
local remoteEvents    = ReplicatedStorage:WaitForChild ("RemoteEvents");

-- ** Dependencies ** --
local remote = script.Parent;
local main   = require (remote.Main);

-- ** Remote Events ** --
local playerLoaded = remoteEvents.GameLoaded;
local assetsAdded  = remoteEvents.AssetsAdded;
local trapPlaced   = remoteEvents.TrapPlaced;

local guideUpdated = remoteEvents.GuideUpdated;
local guideCompleted = remoteEvents.GuideCompleted;

-- ** Remote Functions ** --
local waitForStreamed = remoteFunctions.WaitForStreamed;
local assetsReady     = remoteFunctions.AssetsReady;
local getAssets       = remoteFunctions.GetAssets;
local numAssets       = remoteFunctions.NumAssets;

-- Setup
-- Remote Events
-- Client -> Server
main.redirect (trapPlaced, Remotes.TrapPlaced);
main.redirect (playerLoaded, Remotes.Loaded);
main.redirect (guideCompleted, Remotes.GuideCompleted);

-- Server -> Client
main.redirectToClient (Remotes.AssetsAdded, assetsAdded);
main.redirectToClient (Remotes.GuideUpdated, guideUpdated)

-- Remote Functions
-- Server -> Client
main.setupClientFunction (Remotes.WaitForStreamed, waitForStreamed);

-- Client -> Server
main.setupFunction (getAssets, Remotes.GetAssets);
main.setupFunction (numAssets, Remotes.NumAssets);
main.setupFunction (assetsReady, Remotes.AssetsReady);

-- ** Tags ** --
CollectionService:AddTag (script, _G.GameTags.Remotes);

return Remotes;