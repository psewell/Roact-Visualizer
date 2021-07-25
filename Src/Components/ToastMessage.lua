--[[
	Toast message handler.
]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local Roact = require(main.Packages.Roact)
local RoactRodux = require(main.Packages.RoactRodux)
local Message = require(main.Src.Components.Message)
local Timer = require(main.Src.Components.Signal.Timer)

local ToastMessage = Roact.Component:extend("ToastMessage")

function ToastMessage:init()
	self.state = {
		showMessage = false,
		MessageCode = nil,
	}

	self.hide = function()
		self:setState({
			showMessage = false,
		})
	end
end

function ToastMessage:shouldUpdate(nextProps, nextState)
	return nextState.showMessage ~= self.state.showMessage
		or nextProps.MessageCode ~= self.props.MessageCode
end

function ToastMessage.getDerivedStateFromProps(nextProps, lastState)
	if nextProps.MessageCode ~= lastState.MessageCode
		and nextProps.MessageCode ~= nil then
		return {
			MessageCode = nextProps.MessageCode,
			showMessage = true,
		}
	end
end

function ToastMessage:render()
	local state = self.state
	local props = self.props
	local showMessage = state.showMessage
	if props.MessageCode and props.Type then
		return Roact.createFragment({
			[props.Type] = props.Text and Roact.createElement(Message, {
				VerticalAlignment = Enum.VerticalAlignment.Bottom,
				Text = props.Text,
				Visible = showMessage,
				Buttons = props.Buttons,
			}),

			[props.MessageCode .. "Timer"] = showMessage and Roact.createElement(Timer, {
				Time = props.Time,
				Callback = self.hide,
			}),
		})
	else
		return nil
	end
end

ToastMessage = RoactRodux.connect(function(state)
	return {
		Type = state.Message.Type,
		Text = state.Message.Text,
		Time = state.Message.Time,
		Buttons = state.Message.Buttons,
		MessageCode = state.Message.MessageCode,
	}
end)(ToastMessage)

return ToastMessage
