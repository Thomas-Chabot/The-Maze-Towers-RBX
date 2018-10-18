-- In order to save a lot of extra work, just retursn the ReplicatedStorage version
local ReplicatedStorage = game:GetService ("ReplicatedStorage");
local classes = ReplicatedStorage.Modules.Classes;

return require (classes.Module);