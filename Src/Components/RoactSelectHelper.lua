--[[
	Used to find the local Roact install.
]]

local Selection = game:GetService("Selection")
local SEARCH_LOCATIONS = {
	game.ReplicatedStorage,
	game.Workspace,
	game.StarterPlayer,
	game.StarterGui,
	game.StarterPack,
	game.ServerScriptService,
	game.ServerStorage,
	game.PluginGuiService,
	game.PluginDebugService,
}

local locateMessage = [[Locate your local Roact install
to start using Roact Visualizer:]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local Roact = require(main.Packages.Roact)
local RoactRodux = require(main.Packages.RoactRodux)
local Message = require(main.Src.Components.Message)
local SetMessage = require(main.Src.Reducers.Message.Actions.SetMessage)

local SetRoactInstall = require(main.Src.Reducers.PluginState.Actions.SetRoactInstall)
local SetSelectingRoact = require(main.Src.Reducers.PluginState.Actions.SetSelectingRoact)
local RoactSelector = require(main.Src.Components.RoactSelector)

local RoactSelectHelper = Roact.PureComponent:extend("RoactSelectHelper")

function RoactSelectHelper:init()
	self.autoDetectRoact = function()
		local props = self.props
		local roact
		for _, location in ipairs(SEARCH_LOCATIONS) do
			roact = location:FindFirstChild("Roact", true)
			if roact and roact:IsA("ModuleScript") then
				Selection:Set({roact})
				props.StartSelecting()
				break
			end
		end
		if roact == nil then
			props.SetMessage({
				Type = "AutoDetectFailed",
				Text = "Auto Detect failed to locate Roact. Use manual select instead.",
				Time = 3,
			})
		end
	end
end

function RoactSelectHelper:render()
	local props = self.props
	if props.RoactInstall == nil then
		return Roact.createFragment({
			Cover = Roact.createElement("ImageButton", {
				ZIndex = 4,
				Size = UDim2.fromScale(1, 1),
				ImageTransparency = 1,
				BackgroundTransparency = 0.5,
				BackgroundColor3 = Color3.new(),
				AutoButtonColor = false,
				[Roact.Event.Activated] = props.StopSelecting,
			}),

			Message = Roact.createElement(Message, {
				ZIndex = 5,
				Visible = not props.SelectingRoact,
				Text = locateMessage,
				Buttons = {
					{
						Text = "Auto Detect",
						Default = true,
						OnActivated = self.autoDetectRoact,
					},
					{
						Text = "Select",
						OnActivated = props.StartSelecting,
					},
				},
			}),

			RoactSelector = props.SelectingRoact and Roact.createElement(RoactSelector),
		})
	else
		return nil
	end
end

RoactSelectHelper = RoactRodux.connect(function(state)
	return {
		RoactInstall = state.PluginState.RoactInstall,
		SelectingRoact = state.PluginState.SelectingRoact,
	}
end, function(dispatch)
	return {
		StartSelecting = function()
			dispatch(SetSelectingRoact({
				SelectingRoact = true,
			}))
		end,

		StopSelecting = function()
			dispatch(SetSelectingRoact({
				SelectingRoact = false,
			}))
		end,

		SetRoactInstall = function(roactInstall)
			dispatch(SetRoactInstall({
				RoactInstall = roactInstall,
			}))
		end,

		SetMessage = function(message)
			dispatch(SetMessage(message))
		end,
	}
end)(RoactSelectHelper)

return RoactSelectHelper
