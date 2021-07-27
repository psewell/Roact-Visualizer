--[[
	Used to confirm whether or not the user wants to load the startup state.
]]

local function NOOP() end

local startupMessage = [[Load autosaved state?]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local Roact = require(main.Packages.Roact)
local RoactRodux = require(main.Packages.RoactRodux)
local Message = require(main.Src.Components.Message)

local AcceptStartupState = require(main.Src.Reducers.PluginState.Thunks.AcceptStartupState)
local RejectStartupState = require(main.Src.Reducers.PluginState.Thunks.RejectStartupState)

local ConfirmStartupState = Roact.PureComponent:extend("ConfirmStartupState")

function ConfirmStartupState:render()
	local props = self.props
	local startupState = props.StartupState
	if startupState ~= nil then
		return Roact.createFragment({
			Cover = Roact.createElement("ImageButton", {
				ZIndex = 4,
				Size = UDim2.fromScale(1, 1),
				ImageTransparency = 1,
				BackgroundTransparency = 0.5,
				BackgroundColor3 = Color3.new(),
				AutoButtonColor = false,
				[Roact.Event.Activated] = NOOP,
			}),

			Message = Roact.createElement(Message, {
				ZIndex = 5,
				Visible = true,
				Text = startupMessage,
				Buttons = {
					{
						Text = "Load",
						Default = true,
						OnActivated = props.AcceptStartupState,
					},
					{
						Text = "Delete",
						OnActivated = props.RejectStartupState,
					},
				},
			}),
		})
	else
		return nil
	end
end

ConfirmStartupState = RoactRodux.connect(function(state)
	return {
		StartupState = state.PluginState.StartupState,
	}
end, function(dispatch)
	return {
		AcceptStartupState = function()
			dispatch(AcceptStartupState())
		end,

		RejectStartupState = function()
			dispatch(RejectStartupState())
		end,
	}
end)(ConfirmStartupState)

return ConfirmStartupState
