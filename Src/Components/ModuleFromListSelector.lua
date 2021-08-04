--[[
	Used to select a RootModule by showing a searchable list of all modules.
]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local Roact = require(main.Packages.Roact)
local RoactRodux = require(main.Packages.RoactRodux)
local GetTextSize = require(main.Packages.GetTextSize)
local Cryo = require(main.Packages.Cryo)
local SetMessage = require(main.Src.Reducers.Message.Actions.SetMessage)
local getAllModules = require(main.Src.Util.getAllModules)
local GroupTweenJob = require(main.Src.Components.Base.GroupTweenJob)
local TextBox = require(main.Src.Components.TextBox)
local TextButton = require(main.Src.Components.TextButton)
local getColor = require(main.Src.Util.getColor)

local SetRootModule = require(main.Src.Reducers.PluginState.Actions.SetRootModule)
local SetSelectingModule = require(main.Src.Reducers.PluginState.Actions.SetSelectingModule)

local ModuleFromListSelector = Roact.PureComponent:extend("ModuleFromListSelector")

function ModuleFromListSelector:init()
	self.guiSize, self.setGuiSize = Roact.createBinding(Vector2.new())
	self.itemSize, self.setItemSize = Roact.createBinding(Vector2.new())
	self.maxWidth, self.setMaxWidth = Roact.createBinding(0)

	self.state = {
		modules = {},
		searchText = "",
	}

	self.setModule = function(item)
		self.props.SetRootModule(item)
		self.props.StopSelecting()
	end

	self.filterModules = function(modules, searchText)
		searchText = string.lower(searchText):gsub("([^%w])", "%%%1")
		return Cryo.List.filter(modules, function(item)
			return searchText == "" or (string.find(string.lower(item.Name), searchText)) ~= nil
		end)
	end

	self.validateText = function(searchText)
		local modules = self.filterModules(self.state.modules, searchText)
		return #modules > 0
	end

	self.setSearchText = function(searchText)
		self:setState({
			searchText = searchText,
		})
	end

	self.onCoverSizeChanged = function(rbx)
		self.setGuiSize(rbx.AbsoluteSize)
	end

	self.itemSizeChanged = function(rbx)
		self.setItemSize(rbx.AbsoluteContentSize)
	end

	self.getModules = function()
		local state = self.state
		local searchText = string.lower(state.searchText)
		local modules = self.filterModules(state.modules, searchText)
		table.sort(modules, function(first, second)
			if first.Name == second.Name then
				return first:GetFullName() < second:GetFullName()
			elseif first.Name == searchText then
				return true
			elseif second.Name == searchText then
				return false
			end
			return first.Name < second.Name
		end)
		return modules
	end

	self.onTextSubmitted = function(searchText)
		if searchText ~= "" then
			local modules = self.getModules()
			if #modules > 0 then
				self.setModule(modules[1])
			end
		end
	end
end

function ModuleFromListSelector:renderItems()
	local items = {}
	local maxWidth = 0
	local modules = self.getModules()
	local searchText = self.state.searchText
	local theme = self.props.Theme
	if #modules == 0 then
		local textSize = GetTextSize({
			Font = Enum.Font.SourceSans,
			TextSize = 18,
			Text = "No Matches",
		})
		local width = textSize.X
		maxWidth = math.max(maxWidth, width)
		items.Empty = Roact.createElement(TextButton, {
			Text = "No Matches",
			LayoutOrder = 1,
			Enabled = false,
			OnActivated = function()
			end,
			FitWidth = true,
		})
	else
		for index, item in ipairs(modules) do
			local textSize = GetTextSize({
				Font = Enum.Font.SourceSans,
				TextSize = 18,
				Text = item.Name,
			})
			local width = textSize.X + 32
			maxWidth = math.max(maxWidth, width)

			items[item:GetDebugId()] = Roact.createElement(TextButton, {
				Text = item.Name,
				Icon = "rbxassetid://5428232036",
				LayoutOrder = index,
				OnActivated = function()
					self.setModule(item)
				end,
				FitWidth = true,
				Tooltip = item:GetFullName(),
			}, {
				Stroke = searchText ~= "" and index == 1 and Roact.createElement("UIStroke", {
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
					Color = getColor(function(c, m)
						return theme:GetColor(c.InputFieldBorder, m.Selected)
					end),
				}),
			})
		end
	end
	self.setMaxWidth(maxWidth)
	return Roact.createFragment(items)
end

function ModuleFromListSelector:renderList()
	local props = self.props
	local theme = props.Theme
	return Roact.createElement("ImageButton", {
		AutoButtonColor = false,
		ImageTransparency = 1,
		Size = Roact.joinBindings({self.maxWidth, self.itemSize, self.guiSize}):map(function(values)
			local textWidth = values[1]
			local itemSize = values[2]
			local guiSize = values[3]
			local maxWidth = math.max(144, guiSize.X - 20)
			local width = math.clamp(textWidth + 18, 144, maxWidth)
			local maxHeight = math.max(0, guiSize.Y - 20)
			local height = math.clamp(itemSize.Y + 72, 0, maxHeight)
			return UDim2.fromOffset(width, height)
		end),
		Position = UDim2.new(0, 10, 1, -10),
		AnchorPoint = Vector2.new(0, 1),
		BackgroundColor3 = getColor(function(c)
			return theme:GetColor(c.MainBackground)
		end),
		BorderSizePixel = 0,
		[Roact.Ref] = self.targetRef,
	}, {
		Corner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 4),
		}),

		Padding = Roact.createElement("UIPadding", {
			PaddingTop = UDim.new(0, 8),
			PaddingBottom = UDim.new(0, 8),
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8),
		}),

		Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0, 4),
		}),

		Header = Roact.createElement("TextLabel", {
			LayoutOrder = 1,
			Size = UDim2.new(1, 0, 0, 20),
			BackgroundTransparency = 1,
			Text = "Select a Module",
			Font = Enum.Font.SourceSansSemibold,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextSize = 18,
			TextColor3 = getColor(function(c)
				return theme:GetColor(c.MainText)
			end),
		}),

		Container = Roact.createElement("ScrollingFrame", {
			LayoutOrder = 2,
			BackgroundColor3 = getColor(function(c)
				return theme:GetColor(c.Midlight)
			end),
			BorderSizePixel = 0,
			ClipsDescendants = true,
			Size = UDim2.new(1, 0, 1, -54),
			CanvasSize = self.itemSize:map(function(value)
				return UDim2.new(0, 0, 0, value.Y)
			end),
			CanvasPosition = self.itemSize:map(function()
				return Vector2.new()
			end),
			ScrollBarThickness = 6,
			ScrollBarImageColor3 = getColor(function(c)
				return theme:GetColor(c.DimmedText)
			end),
		}, {
			Layout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Vertical,
				Padding = UDim.new(0, 1),
				[Roact.Change.AbsoluteContentSize] = self.itemSizeChanged,
			}),

			Padding = Roact.createElement("UIPadding", {
				PaddingTop = UDim.new(0, 1),
				PaddingBottom = UDim.new(0, 1),
				PaddingLeft = UDim.new(0, 1),
				PaddingRight = UDim.new(0, 1),
			}),

			Items = self:renderItems(),
		}),

		SearchBar = Roact.createElement(TextBox, {
			PlaceholderText = "Search...",
			LayoutOrder = 3,
			CaptureFocus = true,
			OnTextChanged = self.setSearchText,
			OnTextSubmitted = self.onTextSubmitted,
			Validate = self.validateText,
		}),
	})
end

function ModuleFromListSelector.getDerivedStateFromProps(nextProps, lastState)
	if nextProps.SelectingModule == "FromList" and next(lastState.modules) == nil then
		return {
			modules = getAllModules(),
			searchText = "",
		}
	elseif not nextProps.SelectingModule then
		return {
			modules = {},
			searchText = "",
		}
	end
end

function ModuleFromListSelector:render()
	local props = self.props
	local selecting = props.SelectingModule == "FromList"

	return Roact.createFragment({
		Selecting = selecting and Roact.createFragment({
			Cover = Roact.createElement("ImageButton", {
				ZIndex = 4,
				Size = UDim2.fromScale(1, 1),
				ImageTransparency = 1,
				BackgroundTransparency = 0.5,
				BackgroundColor3 = Color3.new(),
				AutoButtonColor = false,
				[Roact.Event.Activated] = props.StopSelecting,
				[Roact.Change.AbsoluteSize] = self.onCoverSizeChanged,
			}),
		}),

		ListMain = selecting and Roact.createElement(GroupTweenJob, {
			ZIndex = 5,
			Visible = true,
			TweenIn = true,
			Offset = UDim2.fromOffset(-20, 0),
			Time = 0.3,
			MinimalAnimations = props.MinimalAnimations,
		}, {
			List = self:renderList(),
		}),
	})
end

ModuleFromListSelector = RoactRodux.connect(function(state)
	return {
		SelectingModule = state.PluginState.SelectingModule,
		MinimalAnimations = state.Settings.MinimalAnimations,
		Theme = state.PluginState.Theme,
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
end)(ModuleFromListSelector)

return ModuleFromListSelector
