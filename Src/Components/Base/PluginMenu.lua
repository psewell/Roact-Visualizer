--[[
	A wrapper for a PluginMenu.
]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local generateId = require(main.Packages.generateId)
local Roact = require(main.Packages.Roact)
local PluginContext = require(main.Src.Contexts.PluginContext)

local PluginMenu = Roact.PureComponent:extend("PluginMenu")
local t = require(main.Packages.t)
local typecheck = t.interface({
	CreateMenu = t.callback,
	OnItemSelected = t.callback,
	Name = t.optional(t.string),
})

PluginMenu.defaultProps = {
	Name = "Menu",
}

function PluginMenu:init(props)
	assert(typecheck(props))
end

function PluginMenu:didMount()
	local props = self.props
	local plugin = PluginContext:get(self)
	local pluginMenu = plugin:CreatePluginMenu(generateId(), props.Name)
	self.menu = props.CreateMenu(pluginMenu)
	task.defer(function()
		if not self.unmounted then
			local result = self.menu:ShowAsync()
			if not self.unmounted then
				self.props.OnItemSelected(result)
			end
		end
	end)
end

function PluginMenu:render()
	return nil
end

function PluginMenu:willUnmount()
	self.unmounted = true
	if self.menu then
		self.menu:Destroy()
	end
end

return PluginMenu
