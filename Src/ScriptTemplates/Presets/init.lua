local main = script:FindFirstAncestor("Roact-Visualizer")
local t = require(main.Packages.t)

local presets = {
	RootScripts = {
		{
			Name = "Default",
			Module = script.Parent.Root,
		},
		"SEPARATOR",
		{
			Name = "Send to 3D View",
			Module = script.SendTo3DView,
		},
		{
			Name = "Send to New Window",
			Module = script.SendToNewWindow,
		},
		"SEPARATOR",
		{
			Name = "Story (Horsecat)",
			Module = script.HorsecatStory,
		},
		{
			Name = "Story (Hoarcekat)",
			Module = script.HoarcekatStory,
		},
	},
	PropsScripts = {
		{
			Name = "Default",
			Module = script.Parent.Props,
		},
	},
}

local function getPresets(category)
	return presets[category]
end

local function getPresetByName(category, name)
	for _, item in ipairs(presets[category]) do
		if t.table(item) and item.Name == name then
			return item.Module
		end
	end
	return nil
end

return {
	GetPresets = getPresets,
	GetPreset = getPresetByName,
}