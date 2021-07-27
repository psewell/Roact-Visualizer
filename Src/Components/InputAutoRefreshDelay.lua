--[[
	Used to input a custom AutoRefreshDelay.
]]

local inputMessage = [[Input a new Auto Update delay (in seconds):]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local Roact = require(main.Packages.Roact)
local RoactRodux = require(main.Packages.RoactRodux)
local Message = require(main.Src.Components.Message)
local SetMessage = require(main.Src.Reducers.Message.Actions.SetMessage)

local SetSetting = require(main.Src.Reducers.Settings.Actions.SetSetting)
local SetInputAutoRefreshDelay = require(main.Src.Reducers.PluginState.Actions.SetInputAutoRefreshDelay)

local InputAutoRefreshDelay = Roact.PureComponent:extend("InputAutoRefreshDelay")

function InputAutoRefreshDelay:init()
	self.validateText = function(text)
		return tonumber(text) ~= nil
	end

	self.onTextSubmitted = function(text)
		self.props.StopInput()
		if text then
			self.props.SetDelay(tonumber(text))
			self.props.SetMessage({
				Type = "SetAutoUpdateDelay",
				Text = string.format("Auto Update delay set to %s second%s.", text, text == "1" and "" or "s"),
				Time = 3,
			})
		end
	end
end

function InputAutoRefreshDelay:render()
	local props = self.props
	if props.InputAutoRefreshDelay then
		return Roact.createFragment({
			Cover = Roact.createElement("ImageButton", {
				ZIndex = 4,
				Size = UDim2.fromScale(1, 1),
				ImageTransparency = 1,
				BackgroundTransparency = 0.5,
				BackgroundColor3 = Color3.new(),
				AutoButtonColor = false,
				[Roact.Event.Activated] = props.StopInput,
			}),

			Message = Roact.createElement(Message, {
				ZIndex = 5,
				Visible = true,
				Text = inputMessage,
				TextBox = {
					InitialText = tostring(props.AutoRefreshDelay),
					Validate = self.validateText,
					OnTextSubmitted = self.onTextSubmitted,
				},
			}),
		})
	else
		return nil
	end
end

InputAutoRefreshDelay = RoactRodux.connect(function(state)
	return {
		InputAutoRefreshDelay = state.PluginState.InputAutoRefreshDelay,
		AutoRefreshDelay = state.Settings.AutoRefreshDelay,
	}
end, function(dispatch)
	return {
		SetDelay = function(delay)
			dispatch(SetSetting({
				AutoRefreshDelay = delay,
			}))
		end,

		StopInput = function()
			dispatch(SetInputAutoRefreshDelay({
				InputAutoRefreshDelay = false,
			}))
		end,

		SetMessage = function(message)
			dispatch(SetMessage(message))
		end,
	}
end)(InputAutoRefreshDelay)

return InputAutoRefreshDelay
