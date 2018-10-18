local replStorage = game:GetService ("ReplicatedStorage");
local events      = replStorage:FindFirstChild ("RemoteEvents");
local trapPlaced  = events:FindFirstChild ("TrapPlaced");

local negOrb = script.NegativePowerup:Clone ();

function isFloor (target)
end
function placeOrb (target, position)
end

trapPlaced.OnServerEvent:connect (function (player, target)
end)