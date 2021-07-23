--[[
	A wrapper for a PluginToolbar.
]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local Roact = require(main.Packages.Roact)

local PluginButton = Roact.PureComponent:extend("PluginButton")
local t = require(main.Packages.t)
local typecheck = t.interface({
	Title = t.string,
	Toolbar = t.instanceIsA("PluginToolbar"),
	OnClick = t.callback,
	Icon = t.optional(t.string),
	Tooltip = t.optional(t.string),
	Active = t.optional(t.boolean),
})

PluginButton.defaultProps = {
	Icon = "",
	Tooltip = "",
	Active = false,
}

function PluginButton:init(props)
	assert(typecheck(props))
end

function PluginButton:createButton()
	local props = self.props
	local toolbar = props.Toolbar
	local title = props.Title
	local tooltip = props.Tooltip
	local icon = props.Icon
	local onClick = props.OnClick
	self.button = toolbar:CreateButton(title, tooltip, icon)
	self.button.Click:Connect(onClick)
end

function PluginButton:updateButton()
	local props = self.props
	local active = props.Active
	self.button:SetActive(active)
end

function PluginButton:didMount()
	self:updateButton()
end

function PluginButton:didUpdate()
	self:updateButton()
end

function PluginButton:render()
	if not self.button then
		self:createButton()
	end
end

function PluginButton:willUnmount()
	if self.button then
		self.button:Destroy()
	end
end

return PluginButton
