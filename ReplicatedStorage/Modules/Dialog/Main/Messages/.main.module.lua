local GC         = { };

-- ** Game Services ** --
local ReplicatedStorage = game:GetService ("ReplicatedStorage");

-- ** Game Structure ** --
local modules = ReplicatedStorage:WaitForChild("Modules");
local guiTypes = modules:WaitForChild("GuiTypes");
local classes = modules:WaitForChild("Classes");

local dialogGui = script.DialogGui;

-- ** Dependencies ** --
local GuiElement = require (guiTypes.Element);
local Input = require (script.Input);
local TextAnim = require (script.TextAnimator);
local Timeout = require (script.Timeout);

-- ** Constants ** --
local DEF_SPEED = 0.06
local FAST_SPEED = 0.03

-- ** Constructor ** --
local GuiController = GuiElement.new();
function GC.new (messageTimeout)
	local gui = setmetatable ({
		_player = game.Players.LocalPlayer,
		
		_main = dialogGui:Clone(),
		_mainFrame = nil,
		_textLbl = nil,
		
		_input = Input.new(),
		_animator = nil,
		_timeout = Timeout.new(messageTimeout),
		
		_canProceed = true,
		ProceedRequested = Instance.new ("BindableEvent")
	}, GuiController);
	
	gui:_init ();
	return gui;
end

-- ** Public Methods ** --
-- Send a message
function GuiController:send (text)
	self:show();
	self:_animate (text);
end

-- Check if sending a message
function GuiController:isSendingMessage ()
	return self:_isVisible ();
end

-- ** Private Methods ** --
-- Main Initialization
function GuiController:_init ()
	self:_initParent ();
	self:_initProperties ();
	self:_initEvents();
end
function GuiController:_initParent ()
	local player = self._player;
	local pGui   = player and player:WaitForChild ("PlayerGui");
	assert (pGui, "PlayerGui not found. Breaking down.");
	
	self._main.Parent = pGui;
end
function GuiController:_initProperties ()
	self._mainFrame = self._main.DialogFrame;
	self._textLbl = self._mainFrame.DialogText;
	
	self._animator = TextAnim.new (self._textLbl, DEF_SPEED);
end
function GuiController:_initEvents ()
	self:_connect (self._timeout.TimedOut.Event, function ()
		print ("Timed out");
		self.ProceedRequested:Fire()
	end);
	
	self:_connect (self._input.InputBegan.Event, self._proceed);
	self:_connect (self._input.InputBegan.Event, self._speedUp);
	self:_connect (self._input.InputEnded.Event, self._slowDown);
end

-- Attempt to proceed
function GuiController:_proceed ()
	if (self:_isAnimating()) then return end
	
	self._timeout:stop()
	self.ProceedRequested:Fire()
end

-- Text animation speed controls
function GuiController:_speedUp ()
	self:_setSpeed (FAST_SPEED);
end
function GuiController:_slowDown ()
	self:_setSpeed (DEF_SPEED);
end

-- Main animation methods
function GuiController:_animate (text)
	self._animator:setSpeed (DEF_SPEED);
	self._animator:start (text);
	
	-- After the animation completes, start the timer
	self._timeout:start()
end
function GuiController:_isAnimating()
	return self._animator:isAnimating();
end

-- Animation speed
function GuiController:_setSpeed (speed)
	if (not self:_isAnimating()) then return end
	self._animator:setSpeed (speed)
end

GuiController.__index = GuiController;
return GC;