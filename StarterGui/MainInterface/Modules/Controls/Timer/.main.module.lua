local T = { };

-- ** Game Services ** --
local ReplicatedStorage = game:GetService ("ReplicatedStorage");

-- ** Game Structure ** --
local modules = ReplicatedStorage:WaitForChild("Modules");
local guiTypes = modules:WaitForChild("GuiTypes");

-- ** Dependencies ** --
local GuiElement   = require (guiTypes.Element);

-- ** Self ** --
local Timer = GuiElement.new ();
function T.new (mainFrame)
	local timer = setmetatable ({
		_mainFrame = mainFrame,
		_timerTxt = nil,
		
		_isInGame = false
	}, Timer);
	
	timer:_init ();
	return timer;
end

function Timer:setInGame (isInGame)
	self._isInGame = isInGame;
end

function Timer:show (timeLeft)
	if (self._isInGame) then return end
	
	self._timerTxt.Text = timeLeft;
	self:_setVisibility (true);
end

function Timer:_init ()
	self._timerTxt = self._mainFrame.TimerText;
end

Timer.__index = Timer;
return T;