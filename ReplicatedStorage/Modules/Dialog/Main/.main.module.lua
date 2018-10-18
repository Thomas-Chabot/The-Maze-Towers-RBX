--[[
	This module allows for showing a message to a player.
	 It is similar to that of Hints, without using hints (as they have been deprecated).
	
	The constructor takes no arguments, but will set up the gui interface for the player.
	
	It has a single method:
		send (messages : Array of string)
			Purpose: Begins a communication with the player from the provided messages.
			Arguments:
				messages: The messages to send the player. It will cycle through these
				            messages one by one (requiring user input after each to proceed).
			Returns: Nothing.
			Note: If the player is reading a message from an earlier send, then this will
				    add the new messages to the end (i.e. once they have completed the
				    previous send, the new one will begin).
	
	It also has a single BindableEvent:
		Completed ()
			Fired when the user has finished reading through all the text messages.
			
	Dependencies:
		This requires:
			ReplicatedStorage -> Modules -> Input -> Validity
			ReplicatedStorage -> Modules -> GuiTypes -> Element
--]]

local Dialog = { };
local D      = { };

-- ** Game Services ** --
local ReplicatedStorage = game:GetService ("ReplicatedStorage");

-- ** Game Structure ** --
local modules = ReplicatedStorage:WaitForChild("Modules");

-- ** Dependencies ** --
local Messages = require (script.Messages);
local debounce = require (modules.Debounce);

-- ** Constants ** --
local MAX_MESSAGE_LENGTH = 3;

-- ** Constructor ** --
function D.new ()
	local dialog = setmetatable ({
		_dialog = Messages.new (MAX_MESSAGE_LENGTH),
		
		_messages = { },
		_messageIndex = 1,
		
		_hasEnded = false,
		
		Completed = Instance.new ("BindableEvent")
	}, Dialog);
	
	dialog:_init ();
	return dialog;
end

-- ** Public Methods ** --
function Dialog:say (messages)
	local isSending = self:_isSending();
	self:_addMessages (messages);
	
	if (not isSending) then
		self:_next();
	end
end

-- ** Private Methods ** --
-- Initialization
function Dialog:_init ()
	self:_initEvents();
end
function Dialog:_initEvents ()
	self._dialog.ProceedRequested.Event:connect (function ()
		self:_next();
	end)
end

-- Proceed to next message
function Dialog:_next()
	if (not self:_hasMessage()) then
		return self:_ended();
	end
	
	local message = self:_getNextMessage();
	self._dialog:send (message);
end
function Dialog:_ended ()
	if (self._hasEnded) then return end
	self._hasEnded = true;
	
	self._dialog:hide();
	self.Completed:Fire();
end

-- Messages
function Dialog:_addMessages (messages)
	self._hasEnded = false;
	for _,msg in pairs (messages) do
		table.insert (self._messages, msg);
	end
end
function Dialog:_getNextMessage ()
	local message = self._messages [self._messageIndex];
	self._messageIndex = self._messageIndex + 1;
	
	return message;
end
function Dialog:_hasMessage ()
	return self._messageIndex <= #self._messages;
end

-- Checks if dialog is being sent
function Dialog:_isSending ()
	return self._dialog:isSendingMessage();
end

Dialog.__index = Dialog;
return D;