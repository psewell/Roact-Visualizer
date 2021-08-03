--[[
	Horsecat-style Story Support
	A Horsecat story is a ModuleScript named <YourComponentName>.story,
	which returns a Roact component that mounts the UI.

	Horsecat is an unreleased internal Roblox project,
	but its story format can still be used here.

	Note: Although Roact Visualizer supports passing props to the story,
	Horsecat does not innately support passing props to its stories.
	Stories that take props will not be backwards-compatible with Horsecat.
]]

local Roact = script.Roact
local noStoryError = "Could not find a story for module %s"
local storyNameFormat = "%s.story"

local function getStory()
	local module = script.module
	local storyName = string.format(storyNameFormat, module.Name)
	local story = module:FindFirstChild(storyName) or module.Parent:FindFirstChild(storyName)
	if story and story:IsA("ModuleScript") then
		return require(story)
	else
		error(string.format(noStoryError, module.Name))
	end
end

return function(props)
	local story = getStory()
	return Roact.createElement(story, props)
end