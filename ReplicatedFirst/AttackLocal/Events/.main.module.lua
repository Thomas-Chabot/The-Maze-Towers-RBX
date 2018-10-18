local Events = { 
	Fired = Instance.new("BindableEvent")
};

-- ** Game Services ** --
local ReplicatedStorage = game:GetService ("ReplicatedStorage");

-- ** Game Structure ** --
local attackSystem = ReplicatedStorage:WaitForChild("AttackSystem");
local attackEvents = attackSystem:WaitForChild ("Events");

-- ** Events ** --
local inputBegan = attackEvents:WaitForChild ("InputBegan");

-- ** Main Setup Function ** --
function setupEvent (bindable, remote)
	bindable.Event:connect (function (...)
		remote:FireServer (...);
	end)
end

-- ** Event Connections ** --
setupEvent (Events.Fired, inputBegan);

return Events;