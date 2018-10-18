local Events = { 
	Fired = Instance.new("BindableEvent"),
};

-- ** Game Services ** --
local ReplicatedStorage = game:GetService ("ReplicatedStorage");

-- ** Game Structure ** --
local attackSystem = ReplicatedStorage:WaitForChild("AttackSystem");
local attackEvents = attackSystem:WaitForChild ("Events");

-- ** Events ** --
local inputBegan = attackEvents:WaitForChild ("InputBegan");

-- ** Main Setup Function ** --
function setupEventListener (bindable, remote)
	remote.OnServerEvent:connect (function (...)
		bindable:Fire (...);
	end)
end

-- ** Event Connections ** --
setupEventListener (Events.Fired, inputBegan);

return Events;