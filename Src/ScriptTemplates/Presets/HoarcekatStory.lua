--[[
	Hoarcekat-style Story Support
	A Hoarcekat story is a ModuleScript named <YourComponentName>.story,
	which returns a function that mounts the UI and returns a destroy function.

	Hoarcekat is maintained by @Kampfkarren.
	Learn more: https://www.roblox.com/library/4621580428/Hoarcekat

	Note: Although Roact Visualizer supports passing props to the story,
	Hoarcekat does not innately support passing props to its stories.
	Stories that take props will not be backwards-compatible with Hoarcekat.
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

local Root = Roact.Component:extend("Root")

function Root:init()
	self.captureRef = Roact.createRef()
	self.destroyHandle = nil
end

function Root:destroyOldStory()
	if self.destroyHandle then
		self.destroyHandle()
		self.destroyHandle = nil
	end
end

function Root:render()
	return Roact.createElement("Folder", {
		[Roact.Ref] = self.captureRef,
	})
end

function Root:renderStory()
	self:destroyOldStory()
	local story = getStory()
	local capture = self.captureRef:getValue()
	self.destroyHandle = story(capture.Parent, self.props)
end

function Root:didMount()
	self:renderStory()
end

function Root:didUpdate()
	self:renderStory()
end

function Root:willUnmount()
	self:destroyOldStory()
end

return Root