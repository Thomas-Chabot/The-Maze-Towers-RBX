local replStorage = game:GetService ("ReplicatedStorage");
local remoteFuncs = replStorage:WaitForChild ("RemoteFunctions");
local waitForStreamed = remoteFuncs:WaitForChild ("WaitForStreamed");

function waitForStreamed.OnClientInvoke (parent, name, maxWait)
	if (not parent) then return nil end
	return parent:WaitForChild (name, maxWait);
end