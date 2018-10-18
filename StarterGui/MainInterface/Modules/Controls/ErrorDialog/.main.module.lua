local ED = { };

-- ** Game Services ** --
local ReplicatedStorage = game:GetService ("ReplicatedStorage");

-- ** Game Structure ** --
local modules = ReplicatedStorage:WaitForChild("Modules");
local guiTypes = modules:WaitForChild("GuiTypes");

-- ** Dependencies ** --
local GuiElement = require (guiTypes.Element);

-- ** Constants ** --
local DEF_TITLE = "Error";
local DEF_BUTTON_TEXT = "Ok";

-- ** Constructor ** --
local ErrorDialog = GuiElement.new ();
function ED.new (mainFrame)
	local errorDialog = setmetatable ({
		_mainFrame = mainFrame,
		
		_titleTextLbl = nil,
		_msgTextLbl = nil,
		_btnTextLbl = nil,
		
		ButtonPressed = Instance.new ("BindableEvent")
	}, ErrorDialog);
	
	errorDialog:_init ();
	return errorDialog;
end

-- ** Public Methods ** --
function ErrorDialog:show (message, options)
	if (not options) then options = { }; end
	local title = options.title or DEF_TITLE;
	local btnText = options.button or DEF_BUTTON_TEXT;	
	
	-- Set the texts
	self._titleTextLbl.Text = title;
	self._msgTextLbl.Text = message;
	self._btnTextLbl.Text = btnText;
	
	-- Show the error popup
	self:_setVisibility (true);
end

-- ** Private Methods ** --
-- Initialization
function ErrorDialog:_init ()
	self:_initProperties ();
end
function ErrorDialog:_initProperties ()
	local mainFrame = self._mainFrame;
	local errorFrame = mainFrame.ErrorFrame;
	local textsFrame = errorFrame.TextsFrame;
	local buttonsFrame = errorFrame.ButtonsFrame;
	local okBtnFrame = buttonsFrame.OkButtonFrame;
	
	self._titleTextLbl = textsFrame.TitleText;
	self._msgTextLbl   = textsFrame.MessageText;
	
	self._btnTextLbl = okBtnFrame.OkButtonText;
	
	self:_addButton (okBtnFrame.OkButton, self.ButtonPressed);
end


ErrorDialog.__index = ErrorDialog;
return ED;