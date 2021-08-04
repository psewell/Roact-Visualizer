--[[
	Used to select a RootModule by prompting the user to import a file.
]]

local fileBrowserText = [[Use the file browser dialog to select a module.]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local Roact = require(main.Packages.Roact)
local RoactRodux = require(main.Packages.RoactRodux)
local SetMessage = require(main.Src.Reducers.Message.Actions.SetMessage)
local Message = require(main.Src.Components.Message)
local getModuleFromFile = require(main.Src.Util.getModuleFromFile)

local SetRootModule = require(main.Src.Reducers.PluginState.Actions.SetRootModule)
local SetSelectingModule = require(main.Src.Reducers.PluginState.Actions.SetSelectingModule)

local ModuleFromFileSelector = Roact.PureComponent:extend("ModuleFromFileSelector")

function ModuleFromFileSelector:init()
	self.dragArea = Roact.createRef()
	self.state = {
		selectedObject = nil,
	}

	self.setModule = function(item)
		self.props.SetRootModule(item)
		self.props.StopSelecting()
	end

	self.setSelectedModule = function()
		local selectedObject = self.state.selectedObject
		self.setModule(selectedObject)
		self:setState({
			selectedObject = Roact.None,
		})
	end

	self.stopSelecting = function()
		self.props.StopSelecting()
		if self.state.selectedObject then
			self.props.SetMessage({
				Type = "SelectionCancelled",
				Text = "Selection cancelled.",
				Time = 2,
			})
			self:setState({
				selectedObject = Roact.None,
			})
		end
	end

	self.startSelecting = function()
		getModuleFromFile():andThen(function(module, matchedSource)
			if matchedSource then
				self.setModule(module)
			elseif module then
				self.props.SetMessage({
					Type = "ImperfectMatch",
					Text = "Source did not match, but ModuleScript with matching name was found.",
					Time = -1,
				})
				self:setState({
					selectedObject = module,
				})
			else
				self.props.SetMessage({
					Type = "NoMatch",
					Text = "No matching ModuleScripts found.",
					Time = 3,
				})
				self.setModule(nil)
			end
		end):catch(function(err)
			warn(err)
			self.props.SetMessage({
				Type = "SelectionError",
				Text = "File select dialog encountered an error.",
				Time = 3,
			})
			self.setModule(nil)
		end)
	end
end

function ModuleFromFileSelector:didUpdate(lastProps)
	if self.props.SelectingModule == "FromFile" and not lastProps.SelectingModule then
		self:setState({
			selectedObject = Roact.None,
		})
		self.startSelecting()
	end
end

function ModuleFromFileSelector:render()
	local state = self.state
	local selectedObject = state.selectedObject
	local validSelectText = selectedObject and selectedObject:GetFullName() or nil

	local props = self.props
	local selecting = props.SelectingModule == "FromFile"

	return Roact.createFragment({
		Selecting = selecting and Roact.createFragment({
			Cover = Roact.createElement("ImageButton", {
				ZIndex = 4,
				Size = UDim2.fromScale(1, 1),
				ImageTransparency = 1,
				BackgroundTransparency = 0.5,
				BackgroundColor3 = Color3.new(),
				AutoButtonColor = false,
				[Roact.Event.Activated] = self.stopSelecting,
			}),
		}),

		UseFileBrowserToast = selectedObject == nil and Roact.createElement(Message, {
			ZIndex = 5,
			Visible = selecting,
			Text = fileBrowserText,
			Icon = "rbxassetid://5428232036",
		}),

		ValidSelectToast = selectedObject and Roact.createElement(Message, {
			ZIndex = 5,
			Visible = selecting,
			Text = validSelectText,
			Icon = "rbxassetid://2254538897",
			Buttons = {
				{
					Text = "Select",
					Default = true,
					OnActivated = self.setSelectedModule,
				},
			},
		}),
	})
end

ModuleFromFileSelector = RoactRodux.connect(function(state)
	return {
		SelectingModule = state.PluginState.SelectingModule,
	}
end, function(dispatch)
	return {
		SetMessage = function(message)
			dispatch(SetMessage(message))
		end,

		SetRootModule = function(module)
			dispatch(SetRootModule({
				RootModule = module,
			}))
		end,

		StopSelecting = function()
			dispatch(SetSelectingModule({}))
		end,
	}
end)(ModuleFromFileSelector)

return ModuleFromFileSelector
