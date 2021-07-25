--[[
	Used to select a RootModule.
]]

local StudioService = game:GetService("StudioService")

local selectMessage = [[Select or drag a component's ModuleScript
from the Explorer]]

local Selection = game:GetService("Selection")

local main = script:FindFirstAncestor("Roact-Visualizer")
local Roact = require(main.Packages.Roact)
local RoactRodux = require(main.Packages.RoactRodux)
local PluginContext = require(main.Src.Contexts.PluginContext)
local Connection = require(main.Src.Components.Signal.Connection)
local HeartbeatConnection = require(main.Src.Components.Signal.HeartbeatConnection)
local Message = require(main.Src.Components.Message)

local SetRootModule = require(main.Src.Reducers.PluginState.Actions.SetRootModule)
local SetSelectingModule = require(main.Src.Reducers.PluginState.Actions.SetSelectingModule)

local ModuleSelector = Roact.PureComponent:extend("ModuleSelector")

function ModuleSelector:init()
	self.dragArea = Roact.createRef()
	self.state = {
		pluginGui = nil,
		dragObject = nil,
		selectedObject = nil,
	}

	self.setModule = function()
		local items = Selection:Get()
		local item = items[1]
		if items[1] and items[1]:IsA("ModuleScript") and #items == 1 then
			self.props.SetRootModule(item)
		elseif StudioService.ActiveScript and StudioService.ActiveScript:IsA("ModuleScript") then
			self.props.SetRootModule(StudioService.ActiveScript)
		else
			self.props.SetRootModule(nil)
		end
		Selection:Set({})
		self.props.StopSelecting()
	end

	self.onDragDropped = function(dragData)
		if dragData.Sender == "Explorer" then
			local items = Selection:Get()
			if items[1] and items[1]:IsA("ModuleScript") and #items == 1 then
				local item = items[1]
				if item.Name == dragData.Data then
					self.setModule()
				end
			else
				self.props.StopSelecting()
			end
		end
	end

	self.onDragEntered = function(dragData)
		if dragData.Sender == "Explorer" then
			local items = Selection:Get()
			if items[1] and items[1]:IsA("ModuleScript") and #items == 1 then
				local item = items[1]
				if item.Name == dragData.Data then
					self:setState({
						dragObject = item,
					})
				end
			end
		end
	end

	self.onDragLeft = function(dragData)
		if dragData.Sender == "Explorer" then
			self:setState({
				dragObject = Roact.None,
			})
		end
	end

	self.onSelectionChanged = function()
		local items = Selection:Get()
		if items[1] and items[1]:IsA("ModuleScript") and #items == 1 then
			self:setState({
				selectedObject = items[1],
			})
			local plugin = PluginContext:get(self)
			plugin:StartDrag({
				Sender = "Explorer",
				MimeType = "text/plain",
				Data = items[1].Name,
				MouseIcon = "",
				DragIcon = "rbxassetid://2254538897",
				HotSpot = Vector2.new(-20, -20),
			})
		elseif StudioService.ActiveScript and StudioService.ActiveScript:IsA("ModuleScript") then
			self:setState({
				selectedObject = StudioService.ActiveScript,
			})
		else
			self:setState({
				selectedObject = Roact.None,
			})
		end
	end

	self.updateActiveScript = function()
		if StudioService.ActiveScript == nil then
			self.onSelectionChanged()
		end
	end
end

function ModuleSelector:didMount()
	local dragArea = self.dragArea:getValue()
	self:setState({
		pluginGui = dragArea:FindFirstAncestorWhichIsA("PluginGui"),
	})
end

function ModuleSelector:didUpdate(lastProps)
	if self.props.SelectingModule and not lastProps.SelectingModule then
		self:setState({
			dragObject = Roact.None,
			selectedObject = Roact.None,
		})
		self.onSelectionChanged()
	end
end

function ModuleSelector:render()
	local state = self.state
	local pluginGui = state.pluginGui
	local dragObject = state.dragObject
	local selectedObject = state.selectedObject
	local props = self.props
	local selecting = props.SelectingModule

	local activeScript = StudioService.ActiveScript
	local validSelectText
	if selectedObject then
		if activeScript == selectedObject then
			validSelectText = string.format("Active Script:\n%s", selectedObject:GetFullName())
		else
			validSelectText = string.format("Current Selection:\n%s", selectedObject:GetFullName())
		end
	else
		validSelectText = ""
	end

	return Roact.createFragment({
		DragArea = Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			ZIndex = 3,
			BackgroundTransparency = 1,
			[Roact.Ref] = self.dragArea,
		}),

		Selecting = selecting and Roact.createFragment({
			DragDropped = pluginGui and selecting and Roact.createElement(Connection, {
				Signal = pluginGui.PluginDragDropped,
				Callback = self.onDragDropped,
			}) or nil,

			DragEntered = pluginGui and selecting and Roact.createElement(Connection, {
				Signal = pluginGui.PluginDragEntered,
				Callback = self.onDragEntered,
			}) or nil,

			DragLeft = pluginGui and selecting and Roact.createElement(Connection, {
				Signal = pluginGui.PluginDragLeft,
				Callback = self.onDragLeft,
			}) or nil,

			SelectionConnection = selecting and Roact.createElement(Connection, {
				Signal = Selection.SelectionChanged,
				Callback = self.onSelectionChanged,
			}),

			ActiveScriptConnection = selecting and Roact.createElement(Connection, {
				Signal = StudioService:GetPropertyChangedSignal("ActiveScript"),
				Callback = self.onSelectionChanged,
			}),

			UpdateActiveScript = selecting and activeScript and Roact.createElement(HeartbeatConnection, {
				Update = self.updateActiveScript,
			}),

			Cover = Roact.createElement("ImageButton", {
				ZIndex = 4,
				Size = UDim2.fromScale(1, 1),
				ImageTransparency = 1,
				BackgroundTransparency = 0.5,
				BackgroundColor3 = Color3.new(),
				AutoButtonColor = false,
				[Roact.Event.Activated] = props.StopSelecting,
			}),
		}),

		SelectingMessage = not dragObject and not selectedObject and Roact.createElement(Message, {
			ZIndex = 5,
			Visible = selecting,
			Text = selectMessage,
			Icon = "rbxasset://textures/AssetManager/explorer.png",
		}),

		DragObjectMessage = dragObject and Roact.createElement(Message, {
			ZIndex = 5,
			Visible = selecting,
			Text = dragObject and string.format("%s\nDrop to select", dragObject:GetFullName()) or "",
			Icon = "rbxassetid://2254538897",
		}),

		ValidSelectToast = selectedObject and not dragObject and Roact.createElement(Message, {
			ZIndex = 5,
			Visible = selecting,
			Text = validSelectText,
			Icon = "rbxassetid://2254538897",
			Buttons = {
				{
					Text = "Select",
					Default = true,
					OnActivated = self.setModule,
				},
			}
		}),
	})
end

ModuleSelector = RoactRodux.connect(function(state)
	return {
		SelectingModule = state.PluginState.SelectingModule,
	}
end, function(dispatch)
	return {
		SetRootModule = function(module)
			dispatch(SetRootModule({
				RootModule = module,
			}))
		end,

		StopSelecting = function()
			dispatch(SetSelectingModule({
				SelectingModule = false,
			}))
		end,
	}
end)(ModuleSelector)

return ModuleSelector
