--[[
	A wrapper for a PluginToolbar.
]]

local main = script.Parent.Parent.Parent.Parent
local Roact = require(main.Packages.Roact)
local PluginContext = require(main.Src.Contexts.PluginContext)

local PluginToolbar = Roact.PureComponent:extend("PluginToolbar")
local t = require(main.Packages.t)
local typecheck = t.interface({
	Title = t.string,
	RenderButtons = t.callback,
})

function PluginToolbar:init(props)
	assert(typecheck(props))
end

function PluginToolbar:createToolbar()
	local props = self.props
	local plugin = PluginContext:get(self)
	local title = props.Title
	self.toolbar = plugin:CreateToolbar(title)
end

function PluginToolbar:render()
	if not self.toolbar then
		self:createToolbar()
	end

	local props = self.props
	local renderButtons = props.RenderButtons

	local children = renderButtons(self.toolbar)
	if children then
		return Roact.createFragment(children)
	end
end

function PluginToolbar:willUnmount()
	if self.toolbar then
		self.toolbar:Destroy()
	end
end

return PluginToolbar
