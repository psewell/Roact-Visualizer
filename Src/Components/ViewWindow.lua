--[[
	Viewing window for Roact-Visualizer.
]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local Roact = require(main.Packages.Roact)
local RoactRodux = require(main.Packages.RoactRodux)
local DynamicRequire = require(main.Src.Util.DynamicRequire)
local getColor = require(main.Src.Util.getColor)

local ViewWindow = Roact.PureComponent:extend("ViewWindow")

function ViewWindow:init()
	self.targetRef = Roact.createRef()
	self.handle = nil

	self.state = {
		target = nil,
	}
end

function ViewWindow:didMount()
	self:setState({
		target = self.targetRef:getValue(),
	})
end

function ViewWindow:render()
	local state = self.state
	local target = state.target
	local props = self.props
	local theme = props.Theme

	local ThirdPartyRoact = DynamicRequire.Require(props.RoactInstall)

	if target then
		local name, component
		if props.RootModule then
			local rootModule = props.RootModule
			name = rootModule:GetDebugId()
			component = DynamicRequire.Require(rootModule)
		end

		if name and component then
			local tree = ThirdPartyRoact.createElement(ThirdPartyRoact.Portal, {
				target = target,
			}, {
				[name] = component and ThirdPartyRoact.createElement(component) or nil,
			})
			if self.handle then
				self.handle = ThirdPartyRoact.update(self.handle, tree)
			else
				self.handle = ThirdPartyRoact.mount(tree)
			end
		elseif self.handle then
			ThirdPartyRoact.unmount(self.handle)
			self.handle = nil
		end
	end

	return Roact.createFragment({
		Target = Roact.createElement("Frame", {
			ZIndex = 2,
			BackgroundColor3 = getColor(function(c)
				return theme:GetColor(c.Midlight)
			end),
			BorderSizePixel = 0,
			ClipsDescendants = true,
			Size = UDim2.new(1, -8, 1, -38),
			Position = UDim2.new(0, 4, 1, -4),
			AnchorPoint = Vector2.new(0, 1),
			[Roact.Ref] = self.targetRef,
		}),
	})
end

function ViewWindow:willUnmount()
	if self.handle then
		local props = self.props
		local ThirdPartyRoact = DynamicRequire.Require(props.RoactInstall)
		ThirdPartyRoact.unmount(self.handle)
		self.handle = nil
	end
end

ViewWindow = RoactRodux.connect(function(state)
	return {
		RootModule = state.PluginState.RootModule,
		RoactInstall = state.PluginState.RoactInstall,
		Theme = state.PluginState.Theme,
	}
end)(ViewWindow)

return ViewWindow
