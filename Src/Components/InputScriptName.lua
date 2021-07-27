--[[
	Used to input the name of a script being saved.
]]

local inputMessage = [[Save current %s as:]]
local overwriteMessage = [[Overwrite %s "%s"?]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local Roact = require(main.Packages.Roact)
local RoactRodux = require(main.Packages.RoactRodux)
local Message = require(main.Src.Components.Message)
local SetMessage = require(main.Src.Reducers.Message.Actions.SetMessage)

local SaveScript = require(main.Src.Reducers.SavedScripts.Actions.SaveScript)
local SetSavingScript = require(main.Src.Reducers.PluginState.Actions.SetSavingScript)

local InputScriptName = Roact.PureComponent:extend("InputScriptName")
local scriptTemplates = {
	RootScripts = "Root",
	PropsScripts = "Props",
}
local displayNames = {
	RootScripts = "Tree",
	PropsScripts = "Props",
}

function InputScriptName:init()
	self.state = {
		isOverriding = false,
		currentText = nil,
		checkOverwrite = false,
	}
	self.validateText = function(text)
		local isOverriding = false
		local scriptType = self.props.SavingScript
		for name, _ in pairs(self.props[scriptType]) do
			if name == text then
				isOverriding = true
				break
			end
		end

		if isOverriding ~= self.state.isOverriding then
			self:setState({
				isOverriding = isOverriding,
			})
		end

		return text ~= ""
	end

	self.saveScript = function(text)
		local props = self.props
		text = text or self.state.currentText
		self.props.StopInput()
		props.SaveScript({
			Name = text,
			Container = props.SavingScript,
			Script = props.ScriptTemplates[scriptTemplates[props.SavingScript]],
		})
		props.SetMessage({
			Type = "SavedScript",
			Text = string.format([[Saved %s "%s".]], displayNames[props.SavingScript], text),
			Time = 2,
		})
		self:setState({
			isOverriding = false,
			currentText = Roact.None,
			checkOverwrite = false,
		})
	end

	self.overwriteScript = function()
		self.saveScript()
	end

	self.onTextSubmitted = function(text)
		if text then
			if not self.state.isOverriding then
				self.saveScript(text)
			else
				self:setState({
					currentText = text,
					checkOverwrite = true,
				})
			end
		else
			self.props.StopInput()
		end
	end
end

function InputScriptName:render()
	local props = self.props
	if props.SavingScript ~= nil then
		local state = self.state
		local checkOverwrite = state.checkOverwrite
		local currentText = state.currentText

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

			InputMessage = not checkOverwrite and Roact.createElement(Message, {
				ZIndex = 5,
				Visible = true,
				Text = string.format(inputMessage, displayNames[props.SavingScript]),
				TextBox = {
					PlaceholderText = "New" .. displayNames[props.SavingScript],
					Validate = self.validateText,
					OnTextSubmitted = self.onTextSubmitted,
				},
			}),

			OverrideMessage = checkOverwrite and Roact.createElement(Message, {
				ZIndex = 5,
				Visible = true,
				Text = string.format(overwriteMessage, displayNames[props.SavingScript], currentText),
				Buttons = {
					{
						Text = "Save",
						OnActivated = self.overwriteScript,
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

InputScriptName = RoactRodux.connect(function(state)
	return {
		ScriptTemplates = state.ScriptTemplates,
		RootScripts = state.SavedScripts.RootScripts,
		PropsScripts = state.SavedScripts.PropsScripts,
		SavingScript = state.PluginState.SavingScript,
	}
end, function(dispatch)
	return {
		SaveScript = function(props)
			dispatch(SaveScript(props))
		end,

		StopInput = function()
			dispatch(SetSavingScript({}))
		end,

		SetMessage = function(message)
			dispatch(SetMessage(message))
		end,
	}
end)(InputScriptName)

return InputScriptName
