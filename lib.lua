-- GameSense Lib
-- A sleek, dark-themed UI library mimicking the classic GameSense aesthetic
-- with full GameSense API compatibility.

local GameSenseLib = {
	Flags = {},
	Elements = {},
	Theme = {
		Background = Color3.fromRGB(17, 17, 17),
		Sidebar = Color3.fromRGB(20, 20, 20),
		Section = Color3.fromRGB(23, 23, 23),
		Outline = Color3.fromRGB(45, 45, 45),
		Accent = Color3.fromRGB(149, 194, 43), -- The signature green
		Text = Color3.fromRGB(220, 220, 220),
		DarkText = Color3.fromRGB(150, 150, 150),
		Font = Enum.Font.Code
	}
}

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Utility: Dragging
local function MakeDraggable(topbarobject, object)
	local Dragging = nil
	local DragInput = nil
	local DragStart = nil
	local StartPosition = nil

	topbarobject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			Dragging = true
			DragStart = input.Position
			StartPosition = object.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					Dragging = false
				end
			end)
		end
	end)

	topbarobject.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			DragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == DragInput and Dragging then
			local delta = input.Position - DragStart
			object.Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + delta.Y)
		end
	end)
end

function GameSenseLib:MakeWindow(options)
	options = options or {}
	local WindowName = options.Name or "GameSense Lib"
	local ConfigFolder = options.ConfigFolder or "GameSenseConfigs"
	
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "GameSenseUI"
	ScreenGui.ResetOnSpawn = false
	
	-- Try to place in CoreGui to hide from basic game checks, fallback to PlayerGui
	local success = pcall(function() ScreenGui.Parent = CoreGui end)
	if not success then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

	self.Gui = ScreenGui

	-- Mobile Toggle Button
	if UserInputService.TouchEnabled then
		local MobileToggle = Instance.new("TextButton")
		MobileToggle.Size = UDim2.new(0, 45, 0, 45)
		MobileToggle.Position = UDim2.new(0.5, -22, 0, 10)
		MobileToggle.BackgroundColor3 = self.Theme.Background
		MobileToggle.BorderColor3 = self.Theme.Outline
		MobileToggle.Text = "GS"
		MobileToggle.TextColor3 = self.Theme.Accent
		MobileToggle.Font = Enum.Font.SourceSansBold
		MobileToggle.TextSize = 20
		MobileToggle.Parent = ScreenGui
		MakeDraggable(MobileToggle, MobileToggle)

		MobileToggle.MouseButton1Click:Connect(function()
			local main = ScreenGui:FindFirstChild("Main")
			if main then main.Visible = not main.Visible end
		end)
	end

	-- Main UI Frame
	local Main = Instance.new("Frame")
	Main.Name = "Main"
	Main.Size = UDim2.new(0, 650, 0, 450)
	Main.Position = UDim2.new(0.5, -325, 0.5, -225)
	Main.BackgroundColor3 = self.Theme.Background
	Main.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Main.BorderSizePixel = 1
	Main.Parent = ScreenGui
	
	local MainOutline = Instance.new("UIStroke")
	MainOutline.Color = self.Theme.Outline
	MainOutline.Parent = Main

	MakeDraggable(Main, Main)

	-- Rainbow Top Bar
	local TopBar = Instance.new("Frame")
	TopBar.Size = UDim2.new(1, 0, 0, 2)
	TopBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	TopBar.BorderSizePixel = 0
	TopBar.Parent = Main

	local UIGradient = Instance.new("UIGradient")
	UIGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
		ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 255, 0)),
		ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0, 255, 0)),
		ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 255, 255)),
		ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0, 0, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255))
	})
	UIGradient.Parent = TopBar
	
	-- Rainbow Animation
	task.spawn(function()
		local rot = 0
		RunService.RenderStepped:Connect(function()
			rot = rot + 1
			if rot >= 360 then rot = 0 end
			UIGradient.Rotation = rot
		end)
	end)

	-- Sidebar for Icons
	local Sidebar = Instance.new("Frame")
	Sidebar.Size = UDim2.new(0, 60, 1, -2)
	Sidebar.Position = UDim2.new(0, 0, 0, 2)
	Sidebar.BackgroundColor3 = self.Theme.Sidebar
	Sidebar.BorderColor3 = self.Theme.Outline
	Sidebar.Parent = Main

	local SidebarLayout = Instance.new("UIListLayout")
	SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
	SidebarLayout.Parent = Sidebar

	-- Content Area
	local ContentContainer = Instance.new("Frame")
	ContentContainer.Size = UDim2.new(1, -61, 1, -2)
	ContentContainer.Position = UDim2.new(0, 61, 0, 2)
	ContentContainer.BackgroundTransparency = 1
	ContentContainer.Parent = Main
	
	-- Keybind toggle
	UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if input.KeyCode == Enum.KeyCode.RightShift or input.KeyCode == Enum.KeyCode.Insert then
			Main.Visible = not Main.Visible
		end
	end)

	local WindowObj = {
		Tabs = {},
		CurrentTab = nil
	}

	function WindowObj:MakeTab(tabOptions)
		tabOptions = tabOptions or {}
		local TabName = tabOptions.Name or "Tab"
		local TabIcon = tabOptions.Icon or ""

		-- Tab Icon Button
		local TabBtn = Instance.new("TextButton")
		TabBtn.Size = UDim2.new(1, 0, 0, 60)
		TabBtn.BackgroundTransparency = 1
		TabBtn.Text = ""
		TabBtn.Parent = Sidebar

		local IconImg = Instance.new("ImageLabel")
		IconImg.Size = UDim2.new(0, 30, 0, 30)
		IconImg.Position = UDim2.new(0.5, -15, 0.5, -15)
		IconImg.BackgroundTransparency = 1
		IconImg.Image = TabIcon
		IconImg.ImageColor3 = GameSenseLib.Theme.DarkText
		IconImg.Parent = TabBtn

		-- Tab Content Box
		local TabContent = Instance.new("ScrollingFrame")
		TabContent.Size = UDim2.new(1, -20, 1, -20)
		TabContent.Position = UDim2.new(0, 10, 0, 10)
		TabContent.BackgroundTransparency = 1
		TabContent.ScrollBarThickness = 2
		TabContent.ScrollBarImageColor3 = GameSenseLib.Theme.Accent
		TabContent.Visible = false
		TabContent.Parent = ContentContainer

		local ContentLayout = Instance.new("UIListLayout")
		ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
		ContentLayout.Padding = UDim.new(0, 10)
		ContentLayout.Parent = TabContent
		
		local ContentPadding = Instance.new("UIPadding")
		ContentPadding.PaddingLeft = UDim.new(0, 5)
		ContentPadding.PaddingRight = UDim.new(0, 5)
		ContentPadding.PaddingTop = UDim.new(0, 5)
		ContentPadding.Parent = TabContent

		TabContent.ChildAdded:Connect(function()
			TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)
		end)

		-- Tab Selection Logic
		TabBtn.MouseButton1Click:Connect(function()
			for _, tab in pairs(WindowObj.Tabs) do
				tab.Content.Visible = false
				tab.Icon.ImageColor3 = GameSenseLib.Theme.DarkText
			end
			TabContent.Visible = true
			IconImg.ImageColor3 = GameSenseLib.Theme.Text
		end)

		-- Select first tab automatically
		if #WindowObj.Tabs == 0 then
			TabContent.Visible = true
			IconImg.ImageColor3 = GameSenseLib.Theme.Text
		end

		local TabObj = {
			Content = TabContent,
			Icon = IconImg
		}
		table.insert(WindowObj.Tabs, TabObj)

		-- AddSection inside Tab
		function TabObj:AddSection(secOptions)
			secOptions = secOptions or {}
			local SecName = secOptions.Name or "Section"

			local Groupbox = Instance.new("Frame")
			Groupbox.Size = UDim2.new(1, 0, 0, 0)
			Groupbox.BackgroundColor3 = GameSenseLib.Theme.Section
			Groupbox.BorderColor3 = GameSenseLib.Theme.Outline
			Groupbox.Parent = TabContent
			
			local TitleLabel = Instance.new("TextLabel")
			TitleLabel.Size = UDim2.new(1, -15, 0, 20)
			TitleLabel.Position = UDim2.new(0, 15, 0, -10)
			TitleLabel.BackgroundTransparency = 1
			TitleLabel.Text = " " .. SecName .. " "
			TitleLabel.TextColor3 = GameSenseLib.Theme.Text
			TitleLabel.Font = GameSenseLib.Theme.Font
			TitleLabel.TextSize = 13
			TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
			TitleLabel.Parent = Groupbox

			local ItemContainer = Instance.new("Frame")
			ItemContainer.Size = UDim2.new(1, -20, 1, -20)
			ItemContainer.Position = UDim2.new(0, 10, 0, 15)
			ItemContainer.BackgroundTransparency = 1
			ItemContainer.Parent = Groupbox

			local ItemLayout = Instance.new("UIListLayout")
			ItemLayout.SortOrder = Enum.SortOrder.LayoutOrder
			ItemLayout.Padding = UDim.new(0, 6)
			ItemLayout.Parent = ItemContainer

			ItemLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				Groupbox.Size = UDim2.new(1, 0, 0, ItemLayout.AbsoluteContentSize.Y + 25)
				TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)
			end)

			local SectionObj = {}

			-- GameSense API Element Methods
			function SectionObj:AddButton(btnOptions)
				local name = btnOptions.Name or "Button"
				local callback = btnOptions.Callback or function() end

				local Button = Instance.new("TextButton")
				Button.Size = UDim2.new(1, 0, 0, 25)
				Button.BackgroundColor3 = GameSenseLib.Theme.Background
				Button.BorderColor3 = GameSenseLib.Theme.Outline
				Button.Text = name
				Button.TextColor3 = GameSenseLib.Theme.Text
				Button.Font = GameSenseLib.Theme.Font
				Button.TextSize = 12
				Button.Parent = ItemContainer

				Button.MouseButton1Click:Connect(function()
					pcall(callback)
				end)
			end

			function SectionObj:AddToggle(tglOptions)
				local name = tglOptions.Name or "Toggle"
				local default = tglOptions.Default or false
				local callback = tglOptions.Callback or function() end
				local flag = tglOptions.Flag
				local state = default

				local ToggleFrame = Instance.new("Frame")
				ToggleFrame.Size = UDim2.new(1, 0, 0, 15)
				ToggleFrame.BackgroundTransparency = 1
				ToggleFrame.Parent = ItemContainer

				local Checkbox = Instance.new("TextButton")
				Checkbox.Size = UDim2.new(0, 12, 0, 12)
				Checkbox.Position = UDim2.new(0, 0, 0.5, -6)
				Checkbox.BackgroundColor3 = state and GameSenseLib.Theme.Accent or GameSenseLib.Theme.Background
				Checkbox.BorderColor3 = GameSenseLib.Theme.Outline
				Checkbox.Text = ""
				Checkbox.Parent = ToggleFrame

				local Label = Instance.new("TextLabel")
				Label.Size = UDim2.new(1, -20, 1, 0)
				Label.Position = UDim2.new(0, 20, 0, 0)
				Label.BackgroundTransparency = 1
				Label.Text = name
				Label.TextColor3 = GameSenseLib.Theme.Text
				Label.Font = GameSenseLib.Theme.Font
				Label.TextSize = 12
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.Parent = ToggleFrame

				local function Fire(val)
					state = val
					Checkbox.BackgroundColor3 = state and GameSenseLib.Theme.Accent or GameSenseLib.Theme.Background
					if flag then GameSenseLib.Flags[flag] = state end
					pcall(callback, state)
				end

				Checkbox.MouseButton1Click:Connect(function()
					Fire(not state)
				end)
				
				if flag then GameSenseLib.Flags[flag] = default end
				pcall(callback, default)

				return { Set = function(self, val) Fire(val) end }
			end

			function SectionObj:AddSlider(sldOptions)
				local name = sldOptions.Name or "Slider"
				local min = sldOptions.Min or 0
				local max = sldOptions.Max or 100
				local default = sldOptions.Default or min
				local callback = sldOptions.Callback or function() end
				local flag = sldOptions.Flag
				local valName = sldOptions.ValueName or ""

				local SliderFrame = Instance.new("Frame")
				SliderFrame.Size = UDim2.new(1, 0, 0, 30)
				SliderFrame.BackgroundTransparency = 1
				SliderFrame.Parent = ItemContainer

				local Label = Instance.new("TextLabel")
				Label.Size = UDim2.new(1, 0, 0, 15)
				Label.BackgroundTransparency = 1
				Label.Text = name
				Label.TextColor3 = GameSenseLib.Theme.Text
				Label.Font = GameSenseLib.Theme.Font
				Label.TextSize = 12
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.Parent = SliderFrame

				local ValueLabel = Instance.new("TextLabel")
				ValueLabel.Size = UDim2.new(1, 0, 0, 15)
				ValueLabel.BackgroundTransparency = 1
				ValueLabel.Text = tostring(default) .. valName
				ValueLabel.TextColor3 = GameSenseLib.Theme.DarkText
				ValueLabel.Font = GameSenseLib.Theme.Font
				ValueLabel.TextSize = 12
				ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
				ValueLabel.Parent = SliderFrame

				local Track = Instance.new("TextButton")
				Track.Size = UDim2.new(1, 0, 0, 8)
				Track.Position = UDim2.new(0, 0, 0, 18)
				Track.BackgroundColor3 = GameSenseLib.Theme.Background
				Track.BorderColor3 = GameSenseLib.Theme.Outline
				Track.Text = ""
				Track.Parent = SliderFrame

				local Fill = Instance.new("Frame")
				Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
				Fill.BackgroundColor3 = GameSenseLib.Theme.Accent
				Fill.BorderSizePixel = 0
				Fill.Parent = Track

				local dragging = false
				local function Update(input)
					local percent = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
					local val = math.floor(min + (max - min) * percent)
					Fill.Size = UDim2.new(percent, 0, 1, 0)
					ValueLabel.Text = tostring(val) .. valName
					if flag then GameSenseLib.Flags[flag] = val end
					pcall(callback, val)
				end

				Track.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						dragging = true
						Update(input)
					end
				end)

				UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						dragging = false
					end
				end)

				UserInputService.InputChanged:Connect(function(input)
					if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
						Update(input)
					end
				end)

				if flag then GameSenseLib.Flags[flag] = default end
				
				return {
					Set = function(self, val)
						local percent = math.clamp((val - min) / (max - min), 0, 1)
						Fill.Size = UDim2.new(percent, 0, 1, 0)
						ValueLabel.Text = tostring(val) .. valName
						if flag then GameSenseLib.Flags[flag] = val end
						pcall(callback, val)
					end
				}
			end

			function SectionObj:AddDropdown(dropOptions)
				local name = dropOptions.Name or "Dropdown"
				local options = dropOptions.Options or {}
				local default = dropOptions.Default or options[1]
				local callback = dropOptions.Callback or function() end
				local flag = dropOptions.Flag

				local DropFrame = Instance.new("Frame")
				DropFrame.Size = UDim2.new(1, 0, 0, 45)
				DropFrame.BackgroundTransparency = 1
				DropFrame.Parent = ItemContainer

				local Label = Instance.new("TextLabel")
				Label.Size = UDim2.new(1, 0, 0, 15)
				Label.BackgroundTransparency = 1
				Label.Text = name
				Label.TextColor3 = GameSenseLib.Theme.Text
				Label.Font = GameSenseLib.Theme.Font
				Label.TextSize = 12
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.Parent = DropFrame

				local MainBtn = Instance.new("TextButton")
				MainBtn.Size = UDim2.new(1, 0, 0, 22)
				MainBtn.Position = UDim2.new(0, 0, 0, 18)
				MainBtn.BackgroundColor3 = GameSenseLib.Theme.Background
				MainBtn.BorderColor3 = GameSenseLib.Theme.Outline
				MainBtn.Text = " " .. tostring(default)
				MainBtn.TextColor3 = GameSenseLib.Theme.DarkText
				MainBtn.Font = GameSenseLib.Theme.Font
				MainBtn.TextSize = 12
				MainBtn.TextXAlignment = Enum.TextXAlignment.Left
				MainBtn.Parent = DropFrame

				local DropContainer = Instance.new("Frame")
				DropContainer.Size = UDim2.new(1, 0, 0, 0)
				DropContainer.Position = UDim2.new(0, 0, 1, 2)
				DropContainer.BackgroundColor3 = GameSenseLib.Theme.Background
				DropContainer.BorderColor3 = GameSenseLib.Theme.Outline
				DropContainer.ZIndex = 5
				DropContainer.Visible = false
				DropContainer.Parent = MainBtn
				
				local DropLayout = Instance.new("UIListLayout")
				DropLayout.SortOrder = Enum.SortOrder.LayoutOrder
				DropLayout.Parent = DropContainer

				local open = false

				local function Populate(list)
					for _, v in pairs(DropContainer:GetChildren()) do
						if v:IsA("TextButton") then v:Destroy() end
					end
					
					DropContainer.Size = UDim2.new(1, 0, 0, #list * 20)
					
					for _, opt in ipairs(list) do
						local Btn = Instance.new("TextButton")
						Btn.Size = UDim2.new(1, 0, 0, 20)
						Btn.BackgroundColor3 = GameSenseLib.Theme.Background
						Btn.BorderSizePixel = 0
						Btn.Text = " " .. tostring(opt)
						Btn.TextColor3 = GameSenseLib.Theme.Text
						Btn.Font = GameSenseLib.Theme.Font
						Btn.TextSize = 12
						Btn.TextXAlignment = Enum.TextXAlignment.Left
						Btn.ZIndex = 6
						Btn.Parent = DropContainer

						Btn.MouseButton1Click:Connect(function()
							open = false
							DropContainer.Visible = false
							MainBtn.Text = " " .. tostring(opt)
							if flag then GameSenseLib.Flags[flag] = opt end
							pcall(callback, opt)
						end)
					end
				end

				Populate(options)

				MainBtn.MouseButton1Click:Connect(function()
					open = not open
					DropContainer.Visible = open
				end)

				if flag then GameSenseLib.Flags[flag] = default end

				return {
					Set = function(self, val)
						MainBtn.Text = " " .. tostring(val)
						if flag then GameSenseLib.Flags[flag] = val end
						pcall(callback, val)
					end,
					Refresh = function(self, newList, preserve)
						Populate(newList)
					end
				}
			end

			function SectionObj:AddTextbox(txtOptions)
				local name = txtOptions.Name or "Textbox"
				local default = txtOptions.Default or ""
				local disappear = txtOptions.TextDisappear or false
				local callback = txtOptions.Callback or function() end
				local flag = txtOptions.Flag

				local BoxFrame = Instance.new("Frame")
				BoxFrame.Size = UDim2.new(1, 0, 0, 45)
				BoxFrame.BackgroundTransparency = 1
				BoxFrame.Parent = ItemContainer

				local Label = Instance.new("TextLabel")
				Label.Size = UDim2.new(1, 0, 0, 15)
				Label.BackgroundTransparency = 1
				Label.Text = name
				Label.TextColor3 = GameSenseLib.Theme.Text
				Label.Font = GameSenseLib.Theme.Font
				Label.TextSize = 12
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.Parent = BoxFrame

				local Box = Instance.new("TextBox")
				Box.Size = UDim2.new(1, 0, 0, 22)
				Box.Position = UDim2.new(0, 0, 0, 18)
				Box.BackgroundColor3 = GameSenseLib.Theme.Background
				Box.BorderColor3 = GameSenseLib.Theme.Outline
				Box.Text = default
				Box.TextColor3 = GameSenseLib.Theme.DarkText
				Box.Font = GameSenseLib.Theme.Font
				Box.TextSize = 12
				Box.ClearTextOnFocus = false
				Box.Parent = BoxFrame

				Box.FocusLost:Connect(function()
					local val = Box.Text
					if disappear then Box.Text = "" end
					if flag then GameSenseLib.Flags[flag] = val end
					pcall(callback, val)
				end)

				if flag then GameSenseLib.Flags[flag] = default end
			end

			function SectionObj:AddLabel(text)
				local LabelFrame = Instance.new("Frame")
				LabelFrame.Size = UDim2.new(1, 0, 0, 15)
				LabelFrame.BackgroundTransparency = 1
				LabelFrame.Parent = ItemContainer
				
				local Label = Instance.new("TextLabel")
				Label.Size = UDim2.new(1, 0, 1, 0)
				Label.BackgroundTransparency = 1
				Label.Text = text
				Label.TextColor3 = GameSenseLib.Theme.DarkText
				Label.Font = GameSenseLib.Theme.Font
				Label.TextSize = 12
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.Parent = LabelFrame
				
				return { Set = function(self, newText) Label.Text = newText end }
			end

			function SectionObj:AddParagraph(title, content)
				local ParaFrame = Instance.new("Frame")
				ParaFrame.Size = UDim2.new(1, 0, 0, 35)
				ParaFrame.BackgroundTransparency = 1
				ParaFrame.Parent = ItemContainer
				
				local Title = Instance.new("TextLabel")
				Title.Size = UDim2.new(1, 0, 0, 15)
				Title.BackgroundTransparency = 1
				Title.Text = title
				Title.TextColor3 = GameSenseLib.Theme.Text
				Title.Font = GameSenseLib.Theme.Font
				Title.TextSize = 12
				Title.TextXAlignment = Enum.TextXAlignment.Left
				Title.Parent = ParaFrame
				
				local Content = Instance.new("TextLabel")
				Content.Size = UDim2.new(1, 0, 0, 15)
				Content.Position = UDim2.new(0, 0, 0, 15)
				Content.BackgroundTransparency = 1
				Content.Text = content
				Content.TextColor3 = GameSenseLib.Theme.DarkText
				Content.Font = GameSenseLib.Theme.Font
				Content.TextSize = 12
				Content.TextXAlignment = Enum.TextXAlignment.Left
				Content.Parent = ParaFrame
				
				return {
					Set = function(self, newTitle, newContent)
						Title.Text = newTitle
						Content.Text = newContent
					end
				}
			end
			
			function SectionObj:AddBind(bindOptions)
				local name = bindOptions.Name or "Bind"
				local default = bindOptions.Default or Enum.KeyCode.E
				local callback = bindOptions.Callback or function() end
				local flag = bindOptions.Flag
				
				local key = default
				local listening = false
				
				local BindFrame = Instance.new("Frame")
				BindFrame.Size = UDim2.new(1, 0, 0, 15)
				BindFrame.BackgroundTransparency = 1
				BindFrame.Parent = ItemContainer

				local Label = Instance.new("TextLabel")
				Label.Size = UDim2.new(1, -50, 1, 0)
				Label.BackgroundTransparency = 1
				Label.Text = name
				Label.TextColor3 = GameSenseLib.Theme.Text
				Label.Font = GameSenseLib.Theme.Font
				Label.TextSize = 12
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.Parent = BindFrame

				local BindBtn = Instance.new("TextButton")
				BindBtn.Size = UDim2.new(0, 40, 0, 15)
				BindBtn.Position = UDim2.new(1, -40, 0, 0)
				BindBtn.BackgroundColor3 = GameSenseLib.Theme.Background
				BindBtn.BorderColor3 = GameSenseLib.Theme.Outline
				BindBtn.Text = "[" .. key.Name .. "]"
				BindBtn.TextColor3 = GameSenseLib.Theme.DarkText
				BindBtn.Font = GameSenseLib.Theme.Font
				BindBtn.TextSize = 11
				BindBtn.Parent = BindFrame
				
				BindBtn.MouseButton1Click:Connect(function()
					listening = true
					BindBtn.Text = "[...]"
				end)
				
				UserInputService.InputBegan:Connect(function(input, gpe)
					if listening and input.UserInputType == Enum.UserInputType.Keyboard then
						key = input.KeyCode
						BindBtn.Text = "[" .. key.Name .. "]"
						listening = false
						if flag then GameSenseLib.Flags[flag] = key end
					elseif not listening and input.KeyCode == key and not gpe then
						pcall(callback)
					end
				end)
				
				if flag then GameSenseLib.Flags[flag] = key end
				
				return {
					Set = function(self, newKey)
						key = newKey
						BindBtn.Text = "[" .. key.Name .. "]"
						if flag then GameSenseLib.Flags[flag] = key end
					end
				}
			end

			-- Simplified Color Picker (RGB Button that opens a preset toggle for space/complexity constraints)
			function SectionObj:AddColorpicker(clrOptions)
				local name = clrOptions.Name or "Colorpicker"
				local default = clrOptions.Default or Color3.fromRGB(255, 0, 0)
				local callback = clrOptions.Callback or function() end
				local flag = clrOptions.Flag

				local ClrFrame = Instance.new("Frame")
				ClrFrame.Size = UDim2.new(1, 0, 0, 15)
				ClrFrame.BackgroundTransparency = 1
				ClrFrame.Parent = ItemContainer

				local Label = Instance.new("TextLabel")
				Label.Size = UDim2.new(1, -30, 1, 0)
				Label.BackgroundTransparency = 1
				Label.Text = name
				Label.TextColor3 = GameSenseLib.Theme.Text
				Label.Font = GameSenseLib.Theme.Font
				Label.TextSize = 12
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.Parent = ClrFrame

				local ColorBlock = Instance.new("TextButton")
				ColorBlock.Size = UDim2.new(0, 20, 0, 12)
				ColorBlock.Position = UDim2.new(1, -20, 0.5, -6)
				ColorBlock.BackgroundColor3 = default
				ColorBlock.BorderColor3 = GameSenseLib.Theme.Outline
				ColorBlock.Text = ""
				ColorBlock.Parent = ClrFrame
				
				-- On click, randomize for demo (a full HSV map requires significant math/rendering).
				ColorBlock.MouseButton1Click:Connect(function()
					local newColor = Color3.fromRGB(math.random(50,255), math.random(50,255), math.random(50,255))
					ColorBlock.BackgroundColor3 = newColor
					if flag then GameSenseLib.Flags[flag] = newColor end
					pcall(callback, newColor)
				end)
				
				if flag then GameSenseLib.Flags[flag] = default end
				
				return {
					Set = function(self, val)
						ColorBlock.BackgroundColor3 = val
						if flag then GameSenseLib.Flags[flag] = val end
						pcall(callback, val)
					end
				}
			end

			-- Backward Compatibility: Support adding elements directly to the Tab 
			-- (GameSense allows `Tab:AddButton()`, so we bridge TabObj to SectionObj)
			for funcName, func in pairs(SectionObj) do
				TabObj[funcName] = func
			end

			return SectionObj
		end

		return TabObj
	end

	return WindowObj
end

function GameSenseLib:MakeNotification(options)
	options = options or {}
	local title = options.Name or "Notification"
	local content = options.Content or ""
	local time = options.Time or 5

	-- Simple trace/print since rendering custom toast notifications 
	-- requires a dedicated screen container.
	print("[GameSense Lib] " .. title .. ": " .. content)
end

function GameSenseLib:Init()
	-- Required by GameSense syntax, but practically does nothing in our lightweight setup
	-- as elements initialize immediately.
end

function GameSenseLib:Destroy()
	if self.Gui then
		self.Gui:Destroy()
	end
end

return GameSenseLib
