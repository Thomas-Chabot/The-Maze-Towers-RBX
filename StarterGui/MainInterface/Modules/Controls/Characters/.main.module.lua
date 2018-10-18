local CG = { };

-- ** Game Services ** --
local ReplicatedStorage = game:GetService ("ReplicatedStorage");

-- ** Game Structure ** --
local modules = ReplicatedStorage:WaitForChild("Modules");
local guiTypes = modules:WaitForChild("GuiTypes");

-- ** Dependencies ** --
local ScrollingLayout = require (guiTypes.ScrollingLayout);
local Character       = require (script.Character);

-- ** Self ** --
local CharactersGui = ScrollingLayout.new ();
function CG.new (mainFrame, settings)
	if (not settings) then settings = { } end
	
	local charsGui = setmetatable ({
		_mainFrame  = mainFrame,
		_layout     = mainFrame.UIListLayout,
		_characters = { },
		_isOwned    = settings.owned,
		
		CharacterSelected = Instance.new ("BindableEvent")
	}, CharactersGui);
	
	return charsGui;
end

-- ** Public Methods ** --
function CharactersGui:update ()
	--self:_updateCharactersSize ();
	self:_reapplyLayout ();
end
function CharactersGui:setup (characters)
	self:_init (characters);
end

-- ** Private Methods ** --
-- Initialization
function CharactersGui:_init (characters)
	self:_clearCharacters ();
	self:_initCharacters (characters);
	self:_updateCanvasSize ();
end
function CharactersGui:_initCharacters (characters)
	local charFrames = { };	
	for index,characterData in pairs (characters) do
		if (not self:_shouldSkip (characterData)) then
			table.insert (charFrames, self:_createCharacterFrame (characterData, characterData.LayoutOrder or index));
		end
	end
	self._characters = charFrames;
end

-- Add a new character frame
function CharactersGui:_createCharacterFrame (characterData, layoutOrder)
	local character = Character.add (characterData, self._mainFrame, {layoutOrder = layoutOrder, isOwned = self._isOwned});
	
	self:_addEventListener (character, characterData, self._isOwned);
	self:_addStyling (character);
	
	return character;
end
function CharactersGui:_addEventListener (character, ...)
	local args = {...};
	character.Selected.Event:connect (function ()
		self.CharacterSelected:Fire (unpack (args))
	end)
end
function CharactersGui:_addStyling (character)
	local button = character:getButton ()
	self:_addButton (button);
end

-- Remove the character frames
function CharactersGui:_clearCharacters ()
	for _,character in pairs (self._characters) do
		character:remove ();
	end
end

-- Update the size of the characer frames
function CharactersGui:_updateCharactersSize ()
	local frameSize = self:_calculateFrameSize ();
	local charsSize = UDim2.new (0, frameSize * 0.4, 0, frameSize * 0.83);
	
	for _,character in pairs (self._characters) do
		character:updateSize (charsSize);
	end
end
function CharactersGui:_calculateFrameSize ()
	return self._mainFrame.AbsoluteSize;
end

-- Should skip - Rules for characters that should not be shown
function CharactersGui:_shouldSkip (characterData)
	local isBuyable = self:_isBuyable (characterData);
	
	-- First rule: Not buyable & this is the catalog
	if (not self._isOwned and not isBuyable) then return true end
	
	return false;
end
function CharactersGui:_isBuyable (characterData)
	-- By default, a character should be buyable.
	-- This is only false if explicitly set to false
	return characterData.IsForSale ~= false;
end

CharactersGui.__index = CharactersGui;
return CG;