--[[
	This module controls the Arrow interface to spectating.
	
	Constructor:
		Takes no arguments
	
	Methods:
		show ()
			Shows the arrows, allowing the user to provide input.
		hide ()
			Hides the arrows, which stops user input.
		
	Events:
		Next ()
			Fires when the user clicks on the next arrow.
		Back ()
			Fires when the user clicks on the previous arrow.
--]]

local Arrows = { };
local A      = { };

-- ** Dependencies ** --
local ReplicatedStorage = game:GetService ("ReplicatedStorage");
local modules           = ReplicatedStorage:WaitForChild ("Modules");

local ArrowsGui = script.ArrowsGui:Clone ();
local ButtonStyles = require(modules:WaitForChild ("ButtonStyles"));

-- ** Constants ** --
local ARROW_IMGS = {
	mouseDown = "rbxassetid://2014923402",
	mouseHover  = "rbxassetid://2014923403",
	default    = "rbxassetid://2014912605"
}

-- ** Constructor ** --
function A.new ()
	local arrows = setmetatable ({
		_player = game.Players.LocalPlayer,
		_gui = ArrowsGui:Clone (),
		
		_nextBtn = nil,
		_prevBtn = nil,
		
		Next = Instance.new ("BindableEvent"),
		Back = Instance.new ("BindableEvent")
	}, Arrows);
	
	arrows:_init ();
	return arrows;
end

-- ** Public Methods ** --
function Arrows:show ()
	self:_setVisible (true);
end
function Arrows:hide ()
	self:_setVisible (false);
end

-- ** Private Methods ** --
-- Initialization
function Arrows:_init ()
	self:_initVariables ();
	self:_initEvents ();
	self:_initParent ();
end
function Arrows:_initVariables ()
	self._nextBtn = self._gui.NextButton;
	self._prevBtn = self._gui.PrevButton;
	
	ButtonStyles.new (self._nextBtn, ARROW_IMGS);
	ButtonStyles.new (self._prevBtn, ARROW_IMGS);
end
function Arrows:_initEvents ()
	self:_triggerOnClick (self._nextBtn, self.Next);
	self:_triggerOnClick (self._prevBtn, self.Back);
end
function Arrows:_initParent ()
	local pGui = self._player:WaitForChild ("PlayerGui");
	self._gui.Parent = pGui;
end

-- Events
function Arrows:_triggerOnClick (button, event)
	button.MouseButton1Click:connect (function ()
		event:Fire ();
	end)
end

-- Visibility
function Arrows:_setVisible (isVis)
	self._nextBtn.Visible = isVis;
	self._prevBtn.Visible = isVis;
end


Arrows.__index = Arrows;
return A;