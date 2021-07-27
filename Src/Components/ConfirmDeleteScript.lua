--[[
	Used to confirm whether or not a script should be deleted.
]]

local deleteMessage = [[Delete %s script "%s"?]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local Roact = require(main.Packages.Roact)
local RoactRodux = require(main.Packages.RoactRodux)
local Message = require(main.Src.Components.Message)
local SetMessage = require(main.Src.Reducers.Message.Actions.SetMessage)

local DeleteScript = require(main.Src.Reducers.SavedScripts.Actions.DeleteScript)
local SetDeletingScript = require(main.Src.Reducers.PluginState.Actions.SetDeletingScript)

local ConfirmDeleteScript = Roact.PureComponent:extend("ConfirmDeleteScript")
local displayStrings = {
	RootScripts = "Tree",
	PropsScripts = "Props",
}

function ConfirmDeleteScript:init()
	self.deleteScript = function()
		local props = self.props
		props.StopInput()
		props.DeleteScript({
			Name = props.DeletingScript.Name,
			Container = props.DeletingScript.Type,
		})
		props.SetMessage({
			Type = "DeletedScript",
			Text = string.format([[Deleted %s script "%s".]],
				displayStrings[props.DeletingScript.Type], props.DeletingScript.Name),
			Time = 2,
		})
	end
end

function ConfirmDeleteScript:render()
	local props = self.props
	if props.DeletingScript ~= nil then
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
				Text = string.format(deleteMessage,
					displayStrings[props.DeletingScript.Type], props.DeletingScript.Name),
				Buttons = {
					{
						Text = "Delete",
						OnActivated = self.deleteScript,
					},
					{
						Text = "Cancel",
						OnActivated = props.StopInput,
					},
				},
			}),
		})
	else
		return nil
	end
end

ConfirmDeleteScript = RoactRodux.connect(function(state)
	return {
		DeletingScript = state.PluginState.DeletingScript,
	}
end, function(dispatch)
	return {
		DeleteScript = function(props)
			dispatch(DeleteScript(props))
		end,

		StopInput = function()
			dispatch(SetDeletingScript({}))
		end,

		SetMessage = function(message)
			dispatch(SetMessage(message))
		end,
	}
end)(ConfirmDeleteScript)

return ConfirmDeleteScript
