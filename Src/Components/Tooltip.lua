--[[
	An element which can be added to a component to give that component a tooltip.
	When the user hovers the mouse over the component, the tooltip will appear
	after a short delay.
]]

local PADDING = 3
local SHADOW_OFFSET = Vector2.new(3, 3)
local OFFSET = Vector2.new(10, 5)

local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

local main = script:FindFirstAncestor("Roact-Visualizer")
local Roact = require(main.Packages.Roact)
local RoactRodux = require(main.Packages.RoactRodux)
local DropShadow = require(main.Src.Components.DropShadow)
local getColor = require(main.Src.Util.getColor)

local Tooltip = Roact.PureComponent:extend("Tooltip")
local t = require(main.Packages.t)
local typecheck = t.interface({
	Text = t.string,
	ShowDelay = t.optional(t.number),
	Enabled = t.optional(t.boolean),
	ZIndex = t.optional(t.integer),
	MaxWidth = t.optional(t.integer),
})

Tooltip.defaultProps = {
	MaxWidth = 164,
	ShowDelay = 0.25,
	Enabled = true,
	ZIndex = 10,
}

function Tooltip:init(props)
	assert(typecheck(props))
	self.target = Roact.createRef()
	self.state = {
		showToolTip = false,
		pluginGui = nil,
	}

	self.isHovered = false
	self.mousePos = nil
	local showDelay = props.ShowDelay

	self.connectHover = function()
		self.hoverConnection = RunService.Heartbeat:Connect(function()
			if self.isHovered then
				if tick() >= self.targetTime then
					self.disconnectHover()
					self:setState({
						showToolTip = true,
					})
				end
			end
		end)
	end

	self.disconnectHover = function()
		if self.hoverConnection then
			self.hoverConnection:Disconnect()
		end
	end

	self.mouseEnter = function(rbx, xpos, ypos)
		self.isHovered = true
		self.targetTime = tick() + showDelay
		self.mousePos = Vector2.new(xpos, ypos)
		self.connectHover()
	end

	self.mouseMoved = function(rbx, xpos, ypos)
		self.mousePos = Vector2.new(xpos, ypos)
		self.targetTime = tick() + showDelay
	end

	self.mouseLeave = function()
		self.isHovered = false
		self.targetTime = 0
		self.mousePos = nil
		self.disconnectHover()
		self:setState({
			showToolTip = false,
		})
	end
end

function Tooltip:didMount()
	task.defer(function()
		local target = self.target:getValue()
		local pluginGui = target:FindFirstAncestorWhichIsA("PluginGui")
		self:setState({
			pluginGui = pluginGui,
		})
	end)
end

function Tooltip:willUnmount()
	self.disconnectHover()
end

function Tooltip:render()
	local props = self.props
	local state = self.state
	local textSize = 14

	local text = props.Text
	local enabled = props.Enabled
	local theme = props.Theme
	local pluginGui = state.pluginGui

	local mousePos = self.mousePos
	local content = {}

	if state.showToolTip and mousePos and enabled and pluginGui then
		local targetX = mousePos.X + OFFSET.X
		local targetY = mousePos.Y + OFFSET.Y

		local targetWidth = pluginGui.AbsoluteSize.X
		local targetHeight = pluginGui.AbsoluteSize.Y

		local textBound = TextService:GetTextSize(text,
			textSize, Enum.Font.SourceSans, Vector2.new(props.MaxWidth, 9000))

		local tooltipTargetWidth = textBound.X + 2 * PADDING
		local tooltipTargetHeight = textBound.Y + 2 * PADDING

		if targetX + tooltipTargetWidth >= targetWidth then
			targetX = targetWidth - tooltipTargetWidth
		end

		if targetY + tooltipTargetHeight >= targetHeight then
			targetY = targetHeight - tooltipTargetHeight
		end

		content.TooltipContainer = Roact.createElement(Roact.Portal, {
			target = pluginGui,
		}, {
			Frame = Roact.createElement("Frame", {
				Size = UDim2.fromScale(1, 1),
				ZIndex = props.ZIndex,
				BackgroundTransparency = 1,
			}, {
				Tooltip = Roact.createElement("Frame", {
					Position = UDim2.new(0, targetX, 0, targetY),
					Size = UDim2.new(0, tooltipTargetWidth, 0, tooltipTargetHeight),
					BackgroundTransparency = 1,
				}, {
					DropShadow = Roact.createElement(DropShadow, {
						Transparency = 0.5,
						Color = getColor(function(c)
							return theme:GetColor(c.Shadow)
						end),
						Offset = SHADOW_OFFSET,
						ZIndex = 1,
					}),

					ContentFrame = Roact.createElement("Frame", {
						Size = UDim2.new(1, 0, 1, 0),
						ZIndex = 2,

						BackgroundColor3 = getColor(function(c)
							return theme:GetColor(c.Item)
						end),
						BorderColor3 = getColor(function(c)
							return theme:GetColor(c.Border)
						end),
					}, {
						UIPadding = Roact.createElement("UIPadding", {
							PaddingBottom = UDim.new(0, PADDING),
							PaddingLeft = UDim.new(0, PADDING),
							PaddingRight = UDim.new(0, PADDING),
							PaddingTop = UDim.new(0, PADDING),
						}),

						Label = Roact.createElement("TextLabel", {
							Size = UDim2.new(1, 0, 1, 0),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							Text = text,

							TextColor3 = getColor(function(c)
								return theme:GetColor(c.MainText)
							end),

							Font = Enum.Font.SourceSans,
							TextSize = textSize,
							TextXAlignment = Enum.TextXAlignment.Left,
							TextYAlignment = Enum.TextYAlignment.Top,
							TextWrapped = true,
							ZIndex = 3,
						}),
					}),
				}),
			}),
		})
	end

	return Roact.createElement("Frame",{
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		[Roact.Ref] = self.target,
		[Roact.Event.MouseEnter] = self.mouseEnter,
		[Roact.Event.MouseMoved] = self.mouseMoved,
		[Roact.Event.MouseLeave] = self.mouseLeave,
	}, content)
end

Tooltip = RoactRodux.connect(function(state)
	return {
		Theme = state.PluginState.Theme,
	}
end)(Tooltip)

return Tooltip
