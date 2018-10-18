local replStorage = game:GetService ("ReplicatedStorage");
local remoteEvents = replStorage:WaitForChild ("RemoteEvents");
local visionEvent  = remoteEvents:WaitForChild ("Vision");

visionEvent.OnClientEvent:connect (function (maxVision)
	game.Lighting.FogEnd = maxVision;
end)