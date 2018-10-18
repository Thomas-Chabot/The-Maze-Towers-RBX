local Stack = { };
local S     = { };

-- ** Constructor ** --
function S.new (name, maxVal)
	if (not name) then name = ""; end
	if (not maxVal) then maxVal = 0; end
	
	return setmetatable ({
		_name = name,
		_stackName = name .. "_stack",
		
		_maxVal = maxVal
	}, Stack);
end

-- ** Public Methods ** --
-- Reset the properties of the stack
function Stack:reset (name)
	self._name = name;
	self._stackName = name .. "_stack";
end
function Stack:setMax (max)
	self._maxVal = max;
end

-- Get the value of a stack
function Stack:get (part)
	local stackVal = part and part:FindFirstChild (self._stackName);
	if (not stackVal) then return 0; end
	
	return stackVal.Value;
end

-- Add & Remove from the stack
function Stack:inc (part)
	local value = self:_getValue (part);
	if (value + 1 > self._maxVal) then return false end
	
	self:_addToStack (part, 1);
	return true;
end
function Stack:dec (part)
	self:_addToStack (part, -1);
end

-- ** Private Methods ** --
-- Get the value of the stack
function Stack:_getValue (part)
	return self:_getStackVal (part).Value;
end

-- Increment the stack
function Stack:_addToStack (part, amount)
	local stackVal = self:_getStackVal(part);
	
	-- Cannot drop below 0
	stackVal.Value = math.max (0, stackVal.Value + amount);
end

-- Get the stack's IntValue
function Stack:_getStackVal (part)
	local stackVal = part:FindFirstChild (self._stackName);
	if (stackVal) then return stackVal; end
	
	return self:_createStackValue (part);
end
function Stack:_createStackValue (part)
	local newVal = Instance.new ("IntValue");
	newVal.Name = self._stackName;
	newVal.Parent = part;
	
	return newVal;
end


Stack.__index = Stack;
return S;