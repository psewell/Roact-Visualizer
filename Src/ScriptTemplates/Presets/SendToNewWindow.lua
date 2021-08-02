local Roact = script.Roact
local component = script.component

local Root = Roact.Component:extend("Root")

function Root:init()
	self.state = {
		widget = nil,
	}

	self.createWidget = function()
		local info = DockWidgetPluginGuiInfo.new(
			Enum.InitialDockState.Float,
			true, true, -- Start enabled
			640, 480, -- Start size
			0, 0) -- Min size

		local widget = plugin:CreateDockWidgetPluginGui("RoactVisualizerPreview", info)
		widget.Name = "RoactVisualizerPreview"
		widget.Title = "Roact Visualizer Preview"
		widget.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		widget.Enabled = true
		self:setState({
			widget = widget,
		})
	end
end

function Root:didMount()
	task.defer(self.createWidget)
end

function Root:didUpdate()
	if self.state.widget then
		self.state.widget.Enabled = true
	end
end

function Root:render()
	local props = self.props
	if self.state.widget ~= nil then
		return Roact.createElement(Roact.Portal, {
			target = self.state.widget,
		}, Roact.createElement(component, props))
	else
		return nil
	end
end

function Root:willUnmount()
	if self.state.widget then
		self.state.widget:Destroy()
	end
end

return Root