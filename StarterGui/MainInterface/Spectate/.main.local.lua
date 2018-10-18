-- ** Services ** --
local ReplicatedStorage = game:GetService ("ReplicatedStorage");

-- ** Structure ** --
local modules = ReplicatedStorage.Modules;
local minigames = ReplicatedStorage.Minigames;
local minigameEvents = minigames.Events;
local minigameFuncs = minigames.Functions;

local guiMain = script.Parent;
local guiModules = guiMain.Modules;
local guiControls = guiModules.Controls;

local spectateFrame = guiMain.SpectateFrame;

-- ** Dependencies ** --
local Spectate = require (modules.Spectate);
local SpectateGui = require (guiControls.Spectate);
local contains = require (modules.Contains);

-- ** Events ** --
local playerDied = minigameEvents.PlayerDied;
local gameStarted = minigameEvents.GameStarted;
local gameEnded = minigameEvents.GameEnded;

-- ** Functions ** --
local getActivePlayers = minigameFuncs.GetActivePlayers;
local getSpectateActive = minigameFuncs.GetSpectateActive;

-- ** Variables ** --
local localPlayer = game.Players.LocalPlayer;
local spectate = Spectate.new ();
local spectatingGui = SpectateGui.new (spectateFrame);

local isSpectating = false;

-- ** Main Functions ** --
function setupSpectating (players)
	spectate:setup (players)
end
function removePlayer (player)
	spectate:removePlayer (player)
end

function startSpectating ()
	spectate:activate ()
end
function stopSpectating ()
	spectate:deactivate ()
end
function toggleSpectating ()
	if (isSpectating) then
		stopSpectating ();
	else
		startSpectating ();
	end
	
	isSpectating = not isSpectating;
end

function allowSpectating ()
	spectatingGui:show ();
end
function hideSpectating ()
	stopSpectating();
	spectatingGui:hide ();
end
function setSpectatingActive (isActive)
	if (isActive) then
		allowSpectating ();
	else
		hideSpectating ();
	end
end

-- Event setup
gameStarted.OnClientEvent:connect (function (players)
	setupSpectating (players);
	
	local isPlaying = contains (players, localPlayer);
	setSpectatingActive(not isPlaying);
end)

gameEnded.OnClientEvent:connect (function ()
	hideSpectating ()
end)
playerDied.OnClientEvent:connect (function (_, player)
	if (player == localPlayer) then
		allowSpectating ()
	else
		removePlayer (player)
	end
end)

spectatingGui.ButtonPressed.Event:connect (toggleSpectating);

-- Just-In-Case event checking - If the player dies, stop spectating
localPlayer.CharacterRemoving:connect (function ()
	stopSpectating()
end)

-- Call the functions for startup
local activePlayers = getActivePlayers:InvokeServer ();
local isSpectateActive = getSpectateActive:InvokeServer ();

setupSpectating(activePlayers);
setSpectatingActive(isSpectateActive);