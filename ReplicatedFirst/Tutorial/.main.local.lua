-- ** Game Services ** --
local ReplicatedStorage = game:GetService ("ReplicatedStorage");

-- ** Game Structure ** --
-- Modules
local modules = ReplicatedStorage:WaitForChild("Modules");

-- Events
local events = ReplicatedStorage:WaitForChild("RemoteEvents");

-- ** Remote Events ** --
local TutorialRequested = events:WaitForChild("GuideUpdated");
local TutorialCompleted = events:WaitForChild("GuideCompleted");

-- ** Dependencies ** --
local Dialog = require (modules.Dialog.Main);

-- ** Main Code ** --
local dialog = Dialog.new ();
function addNewGuide (messages)
	dialog:say (messages);
end
function tutorialCompleted ()
	TutorialCompleted:FireServer();
end

-- ** Event Connections ** --
TutorialRequested.OnClientEvent:connect (addNewGuide);
dialog.Completed.Event:connect(tutorialCompleted);