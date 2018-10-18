local engine = require (script.Engine);
local minigames = require (script.MinigamesController).new ();

-- ** Services ** --
local ServerStorage = game:GetService ("ServerStorage");
local ServerScriptService = game:GetService ("ServerScriptService");

-- ** Game Structure ** --
local modules = ServerScriptService.Modules;
local classes = modules.ParentClasses;

-- ** Dependencies ** --
local Module = require (classes.Module);

-- ** Game Data ** --
local data = ServerStorage:FindFirstChild ("Data");
local maps = require (data.Maps);

-- ** Engine Setup ** --
local logger = Module.new ("MainGame");

function generateMap ()
	return maps [math.random (1, #maps)];
end

function generateGame ()
	local map = generateMap ();
	
	local numFloors = 3;
	local gridSize = 13; --math.random (10, 18);
	
	engine.generate (gridSize, gridSize, numFloors);
	engine.build (map.BuildSettings);
	engine.addTraps (map.NegativePowerup);
	engine.addLava (map.LavaSettings);
	engine.setFog (map.FogSettings.Color);
	engine.setAISettings (map.AISettings);
end

function removeGame ()
	engine.clear ();
end

function startGame ()
	local players = minigames:getPlayers();
	
	generateGame ();
	local players = engine.spawnPlayers (players);
	
	-- Add the AI players in - do this after the human player, so it doesn't
	--  slow down human players getting added
	engine.addAI ();
	
	return players;
end
function endGame ()
	local winners = minigames:getWinners ();
	logger:_log (unpack (winners), "have won!")
	for _,winner in pairs (winners) do
		local winnings = engine.getGameWinnings (winner);

		sendWinMessage (winner, winnings);
		logger:_log ("Player", winner, "has won", winnings, "coins");
		
		engine.addCoins (winner, winnings);
	end
	
	removeGame ();
end

-- Shows a player the "Congratulations, you won!" message
function sendWinMessage (player, amountWon)
	local message = "Congratulations! You won " .. amountWon .. " coins!";
	engine.sendMessage (player, {message});
end

-- ** Game Events ** --
minigames.GameStarted.Event:connect (function ()
	local activePlayers = startGame ();
	print ("ACTIVE PLAYERS: ", unpack (activePlayers))
	minigames:setActive (activePlayers);
end)
minigames.GameEnded.Event:connect (function ()
	endGame ();
end)
minigames.PlayerDied.Event:connect (function (player)
	engine.removePlayer (player);
end)

engine.ready()

local runService = game:GetService ("RunService");
if (runService:IsClient() and runService:IsServer() and game.Players.NumPlayers < 1) then
	startGame()
end