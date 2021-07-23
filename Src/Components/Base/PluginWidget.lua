--[[
	A wrapper for a PluginWidget.
	OnWidgetRestored: A callback for when the widget
		is restored to its previous position and enabled state. Passes the
		new enabled state as a parameter.
]]

local main = script.Parent.Parent.Parent.Parent
local generateId = require(main.Packages.generateId)
local Roact = require(main.Packages.Roact)
local PluginContext = require(main.Src.Contexts.PluginContext)

local PluginWidget = Roact.PureComponent:extend("PluginWidget")
local t = require(main.Packages.t)
local typecheck = t.interface({
	Title = t.string,
	Enabled = t.boolean,
	Size = t.Vector2,
	InitialDockState = t.enum(Enum.InitialDockState),
	OnClose = t.callback,

	MinSize = t.optional(t.Vector2),
	ZIndexBehavior = t.enum(Enum.ZIndexBehavior),
	ShouldRestore = t.optional(t.boolean),
	OnWidgetRestored = t.optional(t.callback),
	UseUniqueId = t.optional(t.boolean),
})

PluginWidget.defaultProps = {
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	ShouldRestore = false,
	UseUniqueId = false,
	MinSize = Vector2.new(),
}

function PluginWidget:pluginWidgetFunc(props)
	local plugin = PluginContext:get(self)
	local minSize = props.MinSize or props.Size
	local shouldRestore = props.ShouldRestore
	local disregardRestoredEnabledState = not shouldRestore

	local info = DockWidgetPluginGuiInfo.new(
		props.InitialDockState,
		props.Enabled,
		disregardRestoredEnabledState,
		props.Size.X,
		props.Size.Y,
		minSize.X,
		minSize.Y)

	local id = props.UseUniqueId and generateId() or props.Title
	return plugin:CreateDockWidgetPluginGui(id, info)
end

function PluginWidget:init(props)
	assert(typecheck(props))
	if props.ShouldRestore then
		assert(props.OnWidgetRestored, "Requires an OnWidgetRestored function.")
	end
end

function PluginWidget:createWidget()
	local props = self.props
	local widget = self:pluginWidgetFunc(props)
	widget.Name = props.Title
	widget.ZIndexBehavior = props.ZIndexBehavior
	widget:BindToClose(props.OnClose)

	if props.OnWidgetRestored then
		if widget.HostWidgetWasRestored then
			props.OnWidgetRestored(widget.Enabled)
		else
			widget:GetPropertyChangedSignal("HostWidgetWasRestored"):Connect(function()
				task.defer(function()
					props.OnWidgetRestored(widget.Enabled)
				end)
			end)
		end
	end

	self.widget = widget
end

function PluginWidget:updateWidget()
	local props = self.props
	local enabled = props.Enabled
	local title = props.Title

	local widget = self.widget
	if widget then
		if enabled ~= nil then
			widget.Enabled = enabled
		end

		if title ~= nil then
			widget.Title = title
		end
	end
end

function PluginWidget:didMount()
	self:updateWidget()
end

function PluginWidget:didUpdate()
	self:updateWidget()
end

function PluginWidget:render()
	if not self.widget then
		self:createWidget()
	end

	return Roact.createElement(Roact.Portal, {
		target = self.widget,
	}, self.props[Roact.Children])
end

function PluginWidget:willUnmount()
	if self.widget then
		self.widget:Destroy()
	end
end

return PluginWidget
