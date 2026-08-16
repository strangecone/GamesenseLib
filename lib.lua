-- GameSense Lib V12 (The Final Perfected Orion/Skeet Parity)
-- Dynamic Accent Colors, Perfected Keybinds, Smooth Notifications, Config Manager.

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Extremely Safe Anti-Duplication
pcall(function()
	if getgenv().GameSense_UI then getgenv().GameSense_UI:Destroy() end
	if getgenv().GameSense_Input then getgenv().GameSense_Input:Disconnect() end
	for _, v in pairs(CoreGui:GetChildren()) do if v.Name == "GameSenseUI" then v:Destroy() end end
end)

local GameSenseLib = {
	Flags = {},
	Elements = {},
	Binds = {},
	AccentObjects = {}, -- Registry for dynamic accent color updates
	MenuKey = Enum.KeyCode.Insert,
	ConfigFolder = "GameSense",
	AutoSaveEnabled = false,
	Theme = {
		Background = Color3.fromRGB(23, 23, 23),
		MenuBg = Color3.fromRGB(17, 17, 17),
		Outline = Color3.fromRGB(45, 45, 45),
		DarkOutline = Color3.fromRGB(10, 10, 10),
		Accent = Color3.fromRGB(149, 194, 43),
		Text = Color3.fromRGB(200, 200, 200),
		DarkText = Color3.fromRGB(130, 130, 130),
		Font = Enum.Font.Code
	}
}

-- Executor File System Fallbacks
local makefolder = makefolder or function() end
local isfolder = isfolder or function() return false end
local isfile = isfile or function() return false end
local writefile = writefile or function() end
local readfile = readfile or function() return "{}" end
local listfiles = listfiles or function() return {} end

local function MakeDraggable(topbar, object)
	local Dragging, DragInput, DragStart, StartPos
	topbar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			Dragging = true DragStart = input.Position StartPos = object.Position
			input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then Dragging = false end end)
		end
	end)
	topbar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then DragInput = input end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == DragInput and Dragging then
			local delta = input.Position - DragStart
			object.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + delta.X, StartPos.Y.Scale, StartPos.Y.Offset + delta.Y)
		end
	end)
end

-- Function to dynamically update the accent color everywhere
function GameSenseLib:UpdateAccent(color)
	self.Theme.Accent = color
	for obj, prop in pairs(self.AccentObjects) do
		if obj and obj.Parent then obj[prop] = color else self.AccentObjects[obj] = nil end
	end
end

function GameSenseLib:SetWatermarkVisibility(state) if self.Watermark then self.Watermark.Visible = state end end
function GameSenseLib:SetKeybindsVisibility(state) if self.KeybindsFrame then self.KeybindsFrame.Visible = state end end

function GameSenseLib:MakeWindow(options)
	options = options or {}
	self.ConfigFolder = options.ConfigFolder or "GameSense"
	self.AutoSaveEnabled = options.SaveConfig or false
	
	if not isfolder(self.ConfigFolder) then makefolder(self.ConfigFolder) end

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "GameSenseUI"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.IgnoreGuiInset = true 
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
	pcall(function() ScreenGui.Parent = CoreGui end)
	if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
	
	self.Gui = ScreenGui
	getgenv().GameSense_UI = ScreenGui 

	-- SMOOTH NOTIFICATION SYSTEM
	local NotifContainer = Instance.new("Frame", ScreenGui)
	NotifContainer.Size = UDim2.new(0, 250, 1, -20)
	NotifContainer.Position = UDim2.new(1, -260, 0, 10)
	NotifContainer.BackgroundTransparency = 1
	local NotifLayout = Instance.new("UIListLayout", NotifContainer)
	NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
	NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	NotifLayout.Padding = UDim.new(0, 10)

	function GameSenseLib:MakeNotification(opt)
		local title = opt.Name or "Notification"
		local content = opt.Content or ""
		local time = opt.Time or 5

		local NotifFrame = Instance.new("Frame", NotifContainer)
		NotifFrame.Size = UDim2.new(1, 0, 0, 50)
		NotifFrame.Position = UDim2.new(1, 300, 0, 0)
		NotifFrame.BackgroundColor3 = self.Theme.MenuBg
		NotifFrame.BorderColor3 = self.Theme.Outline
		NotifFrame.BackgroundTransparency = 1
		
		local NGrad = Instance.new("Frame", NotifFrame)
		NGrad.Size = UDim2.new(1, 0, 0, 1)
		NGrad.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		NGrad.BorderSizePixel = 0
		NGrad.BackgroundTransparency = 1
		
		local UIG = Instance.new("UIGradient", NGrad)
		UIG.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(59, 175, 222)), ColorSequenceKeypoint.new(0.3, Color3.fromRGB(202, 105, 235)),
			ColorSequenceKeypoint.new(0.6, Color3.fromRGB(235, 198, 105)), ColorSequenceKeypoint.new(1, Color3.fromRGB(168, 235, 105))
		})

		local NTitle = Instance.new("TextLabel", NotifFrame)
		NTitle.Size = UDim2.new(1, -10, 0, 15)
		NTitle.Position = UDim2.new(0, 5, 0, 5)
		NTitle.BackgroundTransparency = 1
		NTitle.Text = title
		NTitle.TextColor3 = self.Theme.Text
		NTitle.Font = self.Theme.Font
		NTitle.TextSize = 13
		NTitle.TextXAlignment = Enum.TextXAlignment.Left
		NTitle.TextTransparency = 1

		local NContent = Instance.new("TextLabel", NotifFrame)
		NContent.Size = UDim2.new(1, -10, 1, -25)
		NContent.Position = UDim2.new(0, 5, 0, 20)
		NContent.BackgroundTransparency = 1
		NContent.Text = content
		NContent.TextColor3 = self.Theme.DarkText
		NContent.Font = self.Theme.Font
		NContent.TextSize = 12
		NContent.TextXAlignment = Enum.TextXAlignment.Left
		NContent.TextYAlignment = Enum.TextYAlignment.Top
		NContent.TextWrapped = true
		NContent.TextTransparency = 1
		
		local TI = TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
		TweenService:Create(NotifFrame, TI, {Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0}):Play()
		TweenService:Create(NGrad, TI, {BackgroundTransparency = 0}):Play()
		TweenService:Create(NTitle, TI, {TextTransparency = 0}):Play()
		TweenService:Create(NContent, TI, {TextTransparency = 0}):Play()
		
		task.delay(time, function()
			local TO = TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.In)
			TweenService:Create(NotifFrame, TO, {Position = UDim2.new(1, 300, 0, 0), BackgroundTransparency = 1}):Play()
			TweenService:Create(NGrad, TO, {BackgroundTransparency = 1}):Play()
			TweenService:Create(NTitle, TO, {TextTransparency = 1}):Play()
			local out = TweenService:Create(NContent, TO, {TextTransparency = 1})
			out:Play()
			out.Completed:Connect(function() NotifFrame:Destroy() end)
		end)
	end

	local PopupContainer = Instance.new("Frame", ScreenGui)
	PopupContainer.Size = UDim2.new(1, 0, 1, 0)
	PopupContainer.BackgroundTransparency = 1
	PopupContainer.ZIndex = 100

	local PopupCatcher = Instance.new("TextButton", PopupContainer)
	PopupCatcher.Size = UDim2.new(1, 0, 1, 0)
	PopupCatcher.BackgroundTransparency = 1
	PopupCatcher.Text = ""
	PopupCatcher.ZIndex = 99
	PopupCatcher.Visible = false

	local function ClosePopups()
		for _, v in pairs(PopupContainer:GetChildren()) do if v ~= PopupCatcher then v:Destroy() end end
		PopupCatcher.Visible = false
	end
	PopupCatcher.MouseButton1Click:Connect(ClosePopups)

	-- WATERMARK
	local Watermark = Instance.new("TextLabel", ScreenGui)
	Watermark.Size = UDim2.new(0, 260, 0, 20)
	Watermark.Position = UDim2.new(1, -270, 0, 10)
	Watermark.BackgroundColor3 = self.Theme.MenuBg
	Watermark.BorderColor3 = self.Theme.Outline
	Watermark.TextColor3 = self.Theme.Text
	Watermark.Font = self.Theme.Font
	Watermark.TextSize = 12
	Watermark.TextXAlignment = Enum.TextXAlignment.Left
	Watermark.Visible = false
	self.Watermark = Watermark

	local WMGradient = Instance.new("Frame", Watermark)
	WMGradient.Size = UDim2.new(1, 0, 0, 1)
	WMGradient.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	WMGradient.BorderSizePixel = 0
	local uiGrad = Instance.new("UIGradient", WMGradient)
	uiGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(59, 175, 222)), ColorSequenceKeypoint.new(0.3, Color3.fromRGB(202, 105, 235)),
		ColorSequenceKeypoint.new(0.6, Color3.fromRGB(235, 198, 105)), ColorSequenceKeypoint.new(1, Color3.fromRGB(168, 235, 105))
	})

	-- KEYBINDS FRAME (PERFECTED ALIGNMENT)
	local KeybindsFrame = Instance.new("Frame", ScreenGui)
	KeybindsFrame.Size = UDim2.new(0, 180, 0, 25)
	KeybindsFrame.Position = UDim2.new(0, 10, 0.5, 0)
	KeybindsFrame.BackgroundColor3 = self.Theme.MenuBg
	KeybindsFrame.BorderColor3 = self.Theme.Outline
	KeybindsFrame.Visible = false
	self.KeybindsFrame = KeybindsFrame
	MakeDraggable(KeybindsFrame, KeybindsFrame)
	WMGradient:Clone().Parent = KeybindsFrame
	
	local KBTitle = Instance.new("TextLabel", KeybindsFrame)
	KBTitle.Size = UDim2.new(1, 0, 1, 0)
	KBTitle.BackgroundTransparency = 1
	KBTitle.Text = "keybinds"
	KBTitle.TextColor3 = self.Theme.Text
	KBTitle.Font = self.Theme.Font
	KBTitle.TextSize = 13
	KBTitle.TextXAlignment = Enum.TextXAlignment.Center -- CENTERED!

	local KBContainer = Instance.new("Frame", KeybindsFrame)
	KBContainer.Size = UDim2.new(1, 0, 0, 0)
	KBContainer.Position = UDim2.new(0, 0, 1, 2)
	KBContainer.BackgroundColor3 = self.Theme.MenuBg
	KBContainer.BorderColor3 = self.Theme.Outline
	local KBLayout = Instance.new("UIListLayout", KBContainer)

	RunService.RenderStepped:Connect(function()
		if Watermark.Visible then 
			Watermark.Text = string.format(" gamesense [beta] | %s | %s", LocalPlayer.Name, os.date("%H:%M:%S"))
		end
		if KeybindsFrame.Visible then
			local count = 0
			for _, bind in ipairs(GameSenseLib.Binds) do
				if bind.Key ~= Enum.KeyCode.Unknown then
					local isActive = false
					if bind.Mode == "Always" then isActive = true
					elseif bind.Mode == "Hold" then 
						for _, k in pairs(UserInputService:GetKeysPressed()) do if k.KeyCode == bind.Key then isActive = true break end end
					elseif bind.Mode == "Toggle" then isActive = bind.Toggled end
					
					if isActive then
						count = count + 1
						bind.UIFrame.Visible = true
						bind.UIName.Text = " " .. bind.Name
						bind.UIState.Text = "[" .. string.lower(bind.Mode) .. "] "
					else
						bind.UIFrame.Visible = false
					end
				else
					bind.UIFrame.Visible = false
				end
			end
			KBContainer.Size = UDim2.new(1, 0, 0, count * 18)
		end
	end)

	local Main = Instance.new("Frame", ScreenGui)
	Main.Size = UDim2.new(0, 600, 0, 450)
	Main.Position = UDim2.new(0.5, -300, 0.5, -225)
	Main.BackgroundColor3 = self.Theme.MenuBg
	Main.BorderColor3 = self.Theme.DarkOutline
	Main.BorderSizePixel = 2
	MakeDraggable(Main, Main)
	local uiScale = Instance.new("UIScale", Main)

	local InnerMain = Instance.new("Frame", Main)
	InnerMain.Size = UDim2.new(1, -2, 1, -2)
	InnerMain.Position = UDim2.new(0, 1, 0, 1)
	InnerMain.BackgroundColor3 = self.Theme.MenuBg
	InnerMain.BorderColor3 = self.Theme.Outline
	InnerMain.ClipsDescendants = true 

	local TopBar = Instance.new("Frame", InnerMain)
	TopBar.Size = UDim2.new(1, 0, 0, 2)
	TopBar.BackgroundColor3 = Color3.fromRGB(255,255,255)
	TopBar.BorderSizePixel = 0
	TopBar.ZIndex = 50
	uiGrad:Clone().Parent = TopBar

	local Sidebar = Instance.new("Frame", InnerMain)
	Sidebar.Size = UDim2.new(0, 60, 1, -2)
	Sidebar.Position = UDim2.new(0, 0, 0, 2)
	Sidebar.BackgroundColor3 = self.Theme.MenuBg
	Sidebar.BorderColor3 = self.Theme.Outline
	local SidebarLayout = Instance.new("UIListLayout", Sidebar)
	SidebarLayout.Padding = UDim.new(0, 5)
	SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder 
	Instance.new("UIPadding", Sidebar).PaddingTop = UDim.new(0, 15) 

	local ContentContainer = Instance.new("Frame", InnerMain)
	ContentContainer.Size = UDim2.new(1, -61, 1, -2)
	ContentContainer.Position = UDim2.new(0, 61, 0, 2)
	ContentContainer.BackgroundColor3 = self.Theme.Background
	ContentContainer.BorderSizePixel = 0
	ContentContainer.ClipsDescendants = true 

	getgenv().GameSense_Input = UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if input.KeyCode == GameSenseLib.MenuKey then
			Main.Visible = not Main.Visible
			ClosePopups()
		end
	end)

	local WindowObj = {Tabs = {}, TabCount = 0}

	function WindowObj:MakeTab(tabOptions)
		WindowObj.TabCount = WindowObj.TabCount + 1
		local isSettings = tabOptions.IsSettingsTab or false
		
		local TabBtn = Instance.new("TextButton", Sidebar)
		TabBtn.Size = UDim2.new(1, 0, 0, 50)
		TabBtn.BackgroundTransparency = 1
		TabBtn.LayoutOrder = isSettings and 99999 or WindowObj.TabCount
		TabBtn.Text = ""

		local IconImg = Instance.new("ImageLabel", TabBtn)
		IconImg.Size = UDim2.new(0, 30, 0, 30)
		IconImg.Position = UDim2.new(0.5, -15, 0.5, -15)
		IconImg.BackgroundTransparency = 1
		IconImg.Image = tabOptions.Icon or ""
		IconImg.ImageColor3 = GameSenseLib.Theme.DarkText

		local TabContent = Instance.new("Frame", ContentContainer)
		TabContent.Size = UDim2.new(1, 0, 1, 0)
		TabContent.BackgroundTransparency = 1
		TabContent.Visible = false

		local LeftCol = Instance.new("ScrollingFrame", TabContent)
		LeftCol.Size = UDim2.new(0.5, -15, 1, 0)
		LeftCol.Position = UDim2.new(0, 10, 0, 0)
		LeftCol.BackgroundTransparency = 1
		LeftCol.ScrollBarThickness = 0
		LeftCol.ClipsDescendants = true 
		local LeftLayout = Instance.new("UIListLayout", LeftCol)
		LeftLayout.Padding = UDim.new(0, 15)
		local LPad = Instance.new("UIPadding", LeftCol)
		LPad.PaddingTop = UDim.new(0, 12) LPad.PaddingBottom = UDim.new(0, 12)

		local RightCol = Instance.new("ScrollingFrame", TabContent)
		RightCol.Size = UDim2.new(0.5, -15, 1, 0)
		RightCol.Position = UDim2.new(0.5, 5, 0, 0)
		RightCol.BackgroundTransparency = 1
		RightCol.ScrollBarThickness = 0
		RightCol.ClipsDescendants = true 
		local RightLayout = Instance.new("UIListLayout", RightCol)
		RightLayout.Padding = UDim.new(0, 15)
		local RPad = Instance.new("UIPadding", RightCol)
		RPad.PaddingTop = UDim.new(0, 12) RPad.PaddingBottom = UDim.new(0, 12)

		TabBtn.MouseButton1Click:Connect(function()
			for _, tab in pairs(WindowObj.Tabs) do
				tab.Content.Visible = false
				tab.Icon.ImageColor3 = GameSenseLib.Theme.DarkText
			end
			TabContent.Visible = true
			IconImg.ImageColor3 = GameSenseLib.Theme.Accent
			ClosePopups()
		end)

		if WindowObj.TabCount == 1 then
			TabContent.Visible = true
			IconImg.ImageColor3 = GameSenseLib.Theme.Accent
		end

		table.insert(WindowObj.Tabs, {Content = TabContent, Icon = IconImg})

		local TabObj = {}
		local DefaultSection = nil
		local function GetDefaultSection()
			if not DefaultSection then DefaultSection = TabObj:AddSection({ Name = "General", Side = "Left" }) end
			return DefaultSection
		end
		
		function TabObj:AddToggle(opt) return GetDefaultSection():AddToggle(opt) end
		function TabObj:AddSlider(opt) return GetDefaultSection():AddSlider(opt) end
		function TabObj:AddDropdown(opt) return GetDefaultSection():AddDropdown(opt) end
		function TabObj:AddBind(opt) return GetDefaultSection():AddBind(opt) end
		function TabObj:AddColorpicker(opt) return GetDefaultSection():AddColorpicker(opt) end
		function TabObj:AddTextbox(opt) return GetDefaultSection():AddTextbox(opt) end
		function TabObj:AddButton(opt) return GetDefaultSection():AddButton(opt) end

		function TabObj:AddSection(secOptions)
			local side = secOptions.Side or "Left"
			local ParentCol = (side == "Right") and RightCol or LeftCol

			local Groupbox = Instance.new("Frame", ParentCol)
			Groupbox.Size = UDim2.new(1, 0, 0, 20)
			Groupbox.BackgroundColor3 = GameSenseLib.Theme.MenuBg
			Groupbox.BorderColor3 = GameSenseLib.Theme.Outline
			Groupbox.ZIndex = 1

			local TitleBg = Instance.new("Frame", Groupbox)
			TitleBg.Position = UDim2.new(0, 15, 0, -6)
			TitleBg.Size = UDim2.new(0, 5, 0, 12)
			TitleBg.BackgroundColor3 = GameSenseLib.Theme.Background
			TitleBg.BorderSizePixel = 0
			TitleBg.ZIndex = 2

			local TitleLabel = Instance.new("TextLabel", TitleBg)
			TitleLabel.Position = UDim2.new(0, 2, 0, -1)
			TitleLabel.Size = UDim2.new(0, 0, 1, 0)
			TitleLabel.BackgroundTransparency = 1
			TitleLabel.Text = secOptions.Name or "Section"
			TitleLabel.TextColor3 = GameSenseLib.Theme.Text
			TitleLabel.Font = GameSenseLib.Theme.Font
			TitleLabel.TextSize = 13
			TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
			TitleLabel.ZIndex = 3
			TitleBg.Size = UDim2.new(0, TitleLabel.TextBounds.X + 4, 0, 12)

			local ItemContainer = Instance.new("Frame", Groupbox)
			ItemContainer.Size = UDim2.new(1, -20, 1, -15)
			ItemContainer.Position = UDim2.new(0, 10, 0, 10)
			ItemContainer.BackgroundTransparency = 1
			ItemContainer.ZIndex = 2
			local ItemLayout = Instance.new("UIListLayout", ItemContainer)
			ItemLayout.Padding = UDim.new(0, 8)

			local function UpdateSize()
				Groupbox.Size = UDim2.new(1, 0, 0, ItemLayout.AbsoluteContentSize.Y + 20)
				ParentCol.CanvasSize = UDim2.new(0, 0, 0, (side == "Right" and RightLayout or LeftLayout).AbsoluteContentSize.Y + 25)
			end
			ItemLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateSize)

			local SectionObj = {}

			function SectionObj:AddToggle(opt)
				local state = opt.Default or false
				local Frame = Instance.new("TextButton", ItemContainer)
				Frame.Size = UDim2.new(1, 0, 0, 12)
				Frame.BackgroundTransparency = 1
				Frame.Text = ""

				local Box = Instance.new("Frame", Frame)
				Box.Size = UDim2.new(0, 10, 0, 10)
				Box.Position = UDim2.new(0, 0, 0.5, -5)
				Box.BackgroundColor3 = state and GameSenseLib.Theme.Accent or GameSenseLib.Theme.DarkOutline
				Box.BorderColor3 = GameSenseLib.Theme.Outline
				GameSenseLib.AccentObjects[Box] = "BackgroundColor3" -- ACCENT REGISTRY

				local Label = Instance.new("TextLabel", Frame)
				Label.Size = UDim2.new(1, -20, 1, 0)
				Label.Position = UDim2.new(0, 18, 0, 0)
				Label.BackgroundTransparency = 1
				Label.Text = opt.Name or "Toggle"
				Label.TextColor3 = GameSenseLib.Theme.Text
				Label.Font = GameSenseLib.Theme.Font
				Label.TextSize = 12
				Label.TextXAlignment = Enum.TextXAlignment.Left

				local function Set(val)
					state = val
					Box.BackgroundColor3 = state and GameSenseLib.Theme.Accent or GameSenseLib.Theme.DarkOutline
					if not state then GameSenseLib.AccentObjects[Box] = nil else GameSenseLib.AccentObjects[Box] = "BackgroundColor3" end
					
					if opt.Flag then 
						if not GameSenseLib.Flags[opt.Flag] then GameSenseLib.Flags[opt.Flag] = {} end
						GameSenseLib.Flags[opt.Flag].Value = state 
					end
					if opt.Callback then pcall(opt.Callback, state) end
					if opt.Save and GameSenseLib.AutoSaveEnabled then GameSenseLib:SaveConfig("auto_config", true) end
				end
				Frame.MouseButton1Click:Connect(function() Set(not state) end)
				if opt.Flag then GameSenseLib.Elements[opt.Flag] = {Set = Set} end
				Set(state)
				return { Set = Set }
			end

			function SectionObj:AddSlider(opt)
				local val = opt.Default or opt.Min
				local Frame = Instance.new("Frame", ItemContainer)
				Frame.Size = UDim2.new(1, 0, 0, 30)
				Frame.BackgroundTransparency = 1

				local Label = Instance.new("TextLabel", Frame)
				Label.Size = UDim2.new(1, 0, 0, 15)
				Label.BackgroundTransparency = 1
				Label.Text = opt.Name or "Slider"
				Label.TextColor3 = GameSenseLib.Theme.Text
				Label.Font = GameSenseLib.Theme.Font
				Label.TextSize = 12
				Label.TextXAlignment = Enum.TextXAlignment.Left

				local Track = Instance.new("TextButton", Frame)
				Track.Size = UDim2.new(1, 0, 0, 10)
				Track.Position = UDim2.new(0, 0, 0, 18)
				Track.BackgroundColor3 = GameSenseLib.Theme.DarkOutline
				Track.BorderColor3 = GameSenseLib.Theme.Outline
				Track.Text = ""

				local Fill = Instance.new("Frame", Track)
				Fill.Size = UDim2.new((val - opt.Min) / (opt.Max - opt.Min), 0, 1, 0)
				Fill.BackgroundColor3 = GameSenseLib.Theme.Accent
				Fill.BorderSizePixel = 0
				GameSenseLib.AccentObjects[Fill] = "BackgroundColor3"

				local ValLabel = Instance.new("TextLabel", Track)
				ValLabel.Size = UDim2.new(1, -2, 1, 0)
				ValLabel.BackgroundTransparency = 1
				ValLabel.Text = tostring(val) .. (opt.ValueName or "")
				ValLabel.TextColor3 = Color3.new(1,1,1)
				ValLabel.Font = GameSenseLib.Theme.Font
				ValLabel.TextSize = 10
				ValLabel.TextXAlignment = Enum.TextXAlignment.Right

				local function Set(newVal)
					val = math.clamp(newVal, opt.Min, opt.Max)
					Fill.Size = UDim2.new((val - opt.Min) / (opt.Max - opt.Min), 0, 1, 0)
					ValLabel.Text = tostring(val) .. (opt.ValueName or "")
					
					if opt.Flag then 
						if not GameSenseLib.Flags[opt.Flag] then GameSenseLib.Flags[opt.Flag] = {} end
						GameSenseLib.Flags[opt.Flag].Value = val 
					end
					if opt.Callback then pcall(opt.Callback, val) end
					if opt.Save and GameSenseLib.AutoSaveEnabled then GameSenseLib:SaveConfig("auto_config", true) end
				end

				local dragging = false
				local function Update(input)
					local perc = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
					Set(math.floor(opt.Min + (opt.Max - opt.Min) * perc))
				end
				Track.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true Update(inp) end end)
				UserInputService.InputEnded:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
				UserInputService.InputChanged:Connect(function(inp) if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then Update(inp) end end)
				
				if opt.Flag then GameSenseLib.Elements[opt.Flag] = {Set = Set} end
				Set(val)
				return { Set = Set }
			end

			function SectionObj:AddDropdown(opt)
				local selected = opt.Default or (opt.Options and opt.Options[1] or "")
				local Frame = Instance.new("Frame", ItemContainer)
				Frame.Size = UDim2.new(1, 0, 0, 35)
				Frame.BackgroundTransparency = 1

				local Label = Instance.new("TextLabel", Frame)
				Label.Size = UDim2.new(1, 0, 0, 15)
				Label.BackgroundTransparency = 1
				Label.Text = opt.Name or "Dropdown"
				Label.TextColor3 = GameSenseLib.Theme.Text
				Label.Font = GameSenseLib.Theme.Font
				Label.TextSize = 12
				Label.TextXAlignment = Enum.TextXAlignment.Left

				local MainBtn = Instance.new("TextButton", Frame)
				MainBtn.Size = UDim2.new(1, 0, 0, 18)
				MainBtn.Position = UDim2.new(0, 0, 0, 15)
				MainBtn.BackgroundColor3 = GameSenseLib.Theme.DarkOutline
				MainBtn.BorderColor3 = GameSenseLib.Theme.Outline
				MainBtn.Text = " " .. tostring(selected)
				MainBtn.TextColor3 = GameSenseLib.Theme.DarkText
				MainBtn.Font = GameSenseLib.Theme.Font
				MainBtn.TextSize = 12
				MainBtn.TextXAlignment = Enum.TextXAlignment.Left
				
				local function Set(val)
					selected = val
					MainBtn.Text = " " .. tostring(val)
					if opt.Flag then 
						if not GameSenseLib.Flags[opt.Flag] then GameSenseLib.Flags[opt.Flag] = {} end
						GameSenseLib.Flags[opt.Flag].Value = val 
					end
					if opt.Callback then pcall(opt.Callback, val) end
					if opt.Save and GameSenseLib.AutoSaveEnabled then GameSenseLib:SaveConfig("auto_config", true) end
				end

				local function Refresh(newList) opt.Options = newList or {} end

				MainBtn.MouseButton1Click:Connect(function()
					ClosePopups()
					PopupCatcher.Visible = true

					local DropContainer = Instance.new("Frame", PopupContainer)
					DropContainer.Size = UDim2.new(0, MainBtn.AbsoluteSize.X, 0, #(opt.Options or {}) * 18)
					DropContainer.Position = UDim2.new(0, MainBtn.AbsolutePosition.X, 0, MainBtn.AbsolutePosition.Y + 20)
					DropContainer.BackgroundColor3 = GameSenseLib.Theme.MenuBg
					DropContainer.BorderColor3 = GameSenseLib.Theme.Outline
					DropContainer.ZIndex = 101

					local DropLayout = Instance.new("UIListLayout", DropContainer)

					for _, item in ipairs(opt.Options or {}) do
						local Btn = Instance.new("TextButton", DropContainer)
						Btn.Size = UDim2.new(1, 0, 0, 18)
						Btn.BackgroundColor3 = GameSenseLib.Theme.MenuBg
						Btn.BorderSizePixel = 0
						Btn.Text = " " .. tostring(item)
						Btn.TextColor3 = GameSenseLib.Theme.Text
						Btn.Font = GameSenseLib.Theme.Font
						Btn.TextSize = 12
						Btn.TextXAlignment = Enum.TextXAlignment.Left
						Btn.ZIndex = 102
						Btn.MouseButton1Click:Connect(function() Set(item) ClosePopups() end)
					end
				end)

				if opt.Flag then GameSenseLib.Elements[opt.Flag] = {Set = Set} end
				Set(selected)
				return { Set = Set, Refresh = Refresh }
			end

			function SectionObj:AddBind(opt)
				local key = opt.Default or Enum.KeyCode.Unknown
				local mode = "Toggle"
				
				local Frame = Instance.new("Frame", ItemContainer)
				Frame.Size = UDim2.new(1, 0, 0, 15)
				Frame.BackgroundTransparency = 1

				local Label = Instance.new("TextLabel", Frame)
				Label.Size = UDim2.new(1, -50, 1, 0)
				Label.BackgroundTransparency = 1
				Label.Text = opt.Name or "Bind"
				Label.TextColor3 = GameSenseLib.Theme.Text
				Label.Font = GameSenseLib.Theme.Font
				Label.TextSize = 12
				Label.TextXAlignment = Enum.TextXAlignment.Left

				local Btn = Instance.new("TextButton", Frame)
				Btn.Size = UDim2.new(0, 45, 0, 15)
				Btn.Position = UDim2.new(1, -45, 0, 0)
				Btn.BackgroundColor3 = GameSenseLib.Theme.DarkOutline
				Btn.BorderColor3 = GameSenseLib.Theme.Outline
				Btn.Text = "[" .. (key == Enum.KeyCode.Unknown and "None" or key.Name) .. "]"
				Btn.TextColor3 = GameSenseLib.Theme.DarkText
				Btn.Font = GameSenseLib.Theme.Font
				Btn.TextSize = 11
				
				-- KEYBINDS LIST UI
				local KBFrame = Instance.new("Frame", KBContainer)
				KBFrame.Size = UDim2.new(1, 0, 0, 18)
				KBFrame.BackgroundTransparency = 1
				KBFrame.Visible = false
				
				local KBName = Instance.new("TextLabel", KBFrame)
				KBName.Size = UDim2.new(0.5, 0, 1, 0)
				KBName.BackgroundTransparency = 1
				KBName.TextColor3 = GameSenseLib.Theme.Text
				KBName.Font = GameSenseLib.Theme.Font
				KBName.TextSize = 12
				KBName.TextXAlignment = Enum.TextXAlignment.Left
				
				local KBState = Instance.new("TextLabel", KBFrame)
				KBState.Size = UDim2.new(0.5, 0, 1, 0)
				KBState.Position = UDim2.new(0.5, 0, 0, 0)
				KBState.BackgroundTransparency = 1
				KBState.TextColor3 = GameSenseLib.Theme.Text
				KBState.Font = GameSenseLib.Theme.Font
				KBState.TextSize = 12
				KBState.TextXAlignment = Enum.TextXAlignment.Right
				
				local bindData = {Name = opt.Name, Key = key, Mode = mode, Toggled = false, UIFrame = KBFrame, UIName = KBName, UIState = KBState}
				table.insert(GameSenseLib.Binds, bindData)
				
				local function Set(newKey)
					key = newKey
					bindData.Key = newKey
					Btn.Text = "[" .. (key == Enum.KeyCode.Unknown and "None" or key.Name) .. "]"
					
					if opt.Flag then 
						if not GameSenseLib.Flags[opt.Flag] then GameSenseLib.Flags[opt.Flag] = {} end
						GameSenseLib.Flags[opt.Flag].Value = newKey 
					end
					if opt.Save and GameSenseLib.AutoSaveEnabled then GameSenseLib:SaveConfig("auto_config", true) end
				end

				local listening = false
				Btn.MouseButton2Click:Connect(function()
					ClosePopups()
					PopupCatcher.Visible = true

					local Modes = {"Always", "Hold", "Toggle"}
					local DropContainer = Instance.new("Frame", PopupContainer)
					DropContainer.Size = UDim2.new(0, 60, 0, #Modes * 18)
					DropContainer.Position = UDim2.new(0, Btn.AbsolutePosition.X, 0, Btn.AbsolutePosition.Y + 18)
					DropContainer.BackgroundColor3 = GameSenseLib.Theme.MenuBg
					DropContainer.BorderColor3 = GameSenseLib.Theme.Outline
					DropContainer.ZIndex = 101
					Instance.new("UIListLayout", DropContainer)

					for _, m in ipairs(Modes) do
						local MBtn = Instance.new("TextButton", DropContainer)
						MBtn.Size = UDim2.new(1, 0, 0, 18)
						MBtn.BackgroundColor3 = GameSenseLib.Theme.MenuBg
						MBtn.BorderSizePixel = 0
						MBtn.Text = (bindData.Mode == m and "> " or "  ") .. m
						MBtn.TextColor3 = bindData.Mode == m and GameSenseLib.Theme.Accent or GameSenseLib.Theme.Text
						if bindData.Mode == m then GameSenseLib.AccentObjects[MBtn] = "TextColor3" end
						MBtn.Font = GameSenseLib.Theme.Font
						MBtn.TextSize = 11
						MBtn.TextXAlignment = Enum.TextXAlignment.Left
						MBtn.ZIndex = 102
						MBtn.MouseButton1Click:Connect(function() 
							GameSenseLib.AccentObjects[MBtn] = nil 
							bindData.Mode = m 
							ClosePopups() 
						end)
					end
				end)

				Btn.MouseButton1Click:Connect(function() listening = true Btn.Text = "[...]" end)
				UserInputService.InputBegan:Connect(function(input, gpe)
					if listening and input.UserInputType == Enum.UserInputType.Keyboard then
						Set(input.KeyCode)
						listening = false
					elseif not listening and input.KeyCode == key and not gpe then
						if bindData.Mode == "Toggle" then bindData.Toggled = not bindData.Toggled end
						if opt.Callback then pcall(opt.Callback) end
					end
				end)
				if opt.Flag then GameSenseLib.Elements[opt.Flag] = {Set = Set} end
				Set(key)
				return { Set = Set }
			end
			
			function SectionObj:AddColorpicker(opt)
				local h, s, v = Color3.toHSV(opt.Default or Color3.fromRGB(255,0,0))
				local Frame = Instance.new("Frame", ItemContainer)
				Frame.Size = UDim2.new(1, 0, 0, 15)
				Frame.BackgroundTransparency = 1

				local Label = Instance.new("TextLabel", Frame)
				Label.Size = UDim2.new(1, -30, 1, 0)
				Label.BackgroundTransparency = 1
				Label.Text = opt.Name or "Color"
				Label.TextColor3 = GameSenseLib.Theme.Text
				Label.Font = GameSenseLib.Theme.Font
				Label.TextSize = 12
				Label.TextXAlignment = Enum.TextXAlignment.Left

				local Btn = Instance.new("TextButton", Frame)
				Btn.Size = UDim2.new(0, 25, 0, 12)
				Btn.Position = UDim2.new(1, -25, 0.5, -6)
				Btn.BackgroundColor3 = Color3.fromHSV(h, s, v)
				Btn.BorderColor3 = GameSenseLib.Theme.Outline
				Btn.Text = ""
				
				local function Set(clr)
					if type(clr) == "table" then h,s,v = clr[1],clr[2],clr[3] else h,s,v = Color3.toHSV(clr) end
					local c = Color3.fromHSV(h, s, v)
					Btn.BackgroundColor3 = c
					if opt.Flag then 
						if not GameSenseLib.Flags[opt.Flag] then GameSenseLib.Flags[opt.Flag] = {} end
						GameSenseLib.Flags[opt.Flag].Value = {h, s, v} 
					end
					if opt.Callback then pcall(opt.Callback, c) end
					if opt.Save and GameSenseLib.AutoSaveEnabled then GameSenseLib:SaveConfig("auto_config", true) end
				end

				Btn.MouseButton1Click:Connect(function()
					ClosePopups()
					PopupCatcher.Visible = true

					local Picker = Instance.new("Frame", PopupContainer)
					Picker.Size = UDim2.new(0, 150, 0, 150)
					Picker.Position = UDim2.new(0, Btn.AbsolutePosition.X - 125, 0, Btn.AbsolutePosition.Y + 15)
					Picker.BackgroundColor3 = GameSenseLib.Theme.MenuBg
					Picker.BorderColor3 = GameSenseLib.Theme.Outline
					Picker.ZIndex = 101

					local SVMap = Instance.new("TextButton", Picker)
					SVMap.Size = UDim2.new(0, 130, 0, 120)
					SVMap.Position = UDim2.new(0, 5, 0, 5)
					SVMap.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
					SVMap.BorderSizePixel = 0
					SVMap.Text = ""
					SVMap.AutoButtonColor = false
					SVMap.ZIndex = 102

					local WGrad = Instance.new("UIGradient", Instance.new("Frame", SVMap))
					WGrad.Parent.Size = UDim2.new(1,0,1,0) WGrad.Parent.BackgroundColor3 = Color3.new(1,1,1) WGrad.Parent.BorderSizePixel = 0 WGrad.Parent.ZIndex = 103
					WGrad.Color = ColorSequence.new(Color3.new(1,1,1), Color3.new(1,1,1)) WGrad.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0), NumberSequenceKeypoint.new(1,1)})
					
					local BGrad = Instance.new("UIGradient", Instance.new("Frame", SVMap))
					BGrad.Parent.Size = UDim2.new(1,0,1,0) BGrad.Parent.BackgroundColor3 = Color3.new(1,1,1) BGrad.Parent.BorderSizePixel = 0 BGrad.Parent.ZIndex = 104
					BGrad.Color = ColorSequence.new(Color3.new(0,0,0), Color3.new(0,0,0)) BGrad.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(1,0)}) BGrad.Rotation = 90

					local HueMap = Instance.new("TextButton", Picker)
					HueMap.Size = UDim2.new(0, 130, 0, 15)
					HueMap.Position = UDim2.new(0, 5, 0, 130)
					HueMap.BackgroundColor3 = Color3.new(1,1,1)
					HueMap.BorderSizePixel = 0
					HueMap.Text = ""
					HueMap.ZIndex = 102
					local HGrad = Instance.new("UIGradient", HueMap)
					HGrad.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)), ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255, 255, 0)),
						ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
						ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0, 0, 255)), ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
					})

					local draggingSV, draggingH = false, false
					local function UpdateSV(input)
						s = math.clamp((input.Position.X - SVMap.AbsolutePosition.X) / SVMap.AbsoluteSize.X, 0, 1)
						v = 1 - math.clamp((input.Position.Y - SVMap.AbsolutePosition.Y) / SVMap.AbsoluteSize.Y, 0, 1)
						Set({h,s,v})
					end
					local function UpdateH(input)
						h = math.clamp((input.Position.X - HueMap.AbsolutePosition.X) / HueMap.AbsoluteSize.X, 0, 1)
						SVMap.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
						Set({h,s,v})
					end

					SVMap.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingSV = true UpdateSV(i) end end)
					HueMap.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingH = true UpdateH(i) end end)
					UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingSV = false draggingH = false end end)
					UserInputService.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement then if draggingSV then UpdateSV(i) elseif draggingH then UpdateH(i) end end end)
				end)

				if opt.Flag then GameSenseLib.Elements[opt.Flag] = {Set = Set} end
				Set({h,s,v})
				return { Set = Set }
			end

			function SectionObj:AddTextbox(opt)
				local val = opt.Default or ""
				local Frame = Instance.new("Frame", ItemContainer)
				Frame.Size = UDim2.new(1, 0, 0, 35)
				Frame.BackgroundTransparency = 1

				local Label = Instance.new("TextLabel", Frame)
				Label.Size = UDim2.new(1, 0, 0, 15)
				Label.BackgroundTransparency = 1
				Label.Text = opt.Name or "Textbox"
				Label.TextColor3 = GameSenseLib.Theme.Text
				Label.Font = GameSenseLib.Theme.Font
				Label.TextSize = 12
				Label.TextXAlignment = Enum.TextXAlignment.Left

				local Box = Instance.new("TextBox", Frame)
				Box.Size = UDim2.new(1, 0, 0, 18)
				Box.Position = UDim2.new(0, 0, 0, 15)
				Box.BackgroundColor3 = GameSenseLib.Theme.DarkOutline
				Box.BorderColor3 = GameSenseLib.Theme.Outline
				Box.Text = val
				Box.TextColor3 = GameSenseLib.Theme.Text
				Box.Font = GameSenseLib.Theme.Font
				Box.TextSize = 12
				Box.ClearTextOnFocus = false
				
				local function Set(newVal)
					Box.Text = newVal
					if opt.Flag then 
						if not GameSenseLib.Flags[opt.Flag] then GameSenseLib.Flags[opt.Flag] = {} end
						GameSenseLib.Flags[opt.Flag].Value = newVal 
					end
					if opt.Callback then pcall(opt.Callback, newVal) end
					if opt.Save and GameSenseLib.AutoSaveEnabled then GameSenseLib:SaveConfig("auto_config", true) end
				end

				Box.FocusLost:Connect(function()
					local t = Box.Text
					if opt.TextDisappear then Box.Text = "" end
					Set(t)
				end)
				
				if opt.Flag then GameSenseLib.Elements[opt.Flag] = {Set = Set} end
				Set(val)
				return { Set = Set }
			end

			function SectionObj:AddButton(opt)
				local Btn = Instance.new("TextButton", ItemContainer)
				Btn.Size = UDim2.new(1, 0, 0, 20)
				Btn.BackgroundColor3 = GameSenseLib.Theme.DarkOutline
				Btn.BorderColor3 = GameSenseLib.Theme.Outline
				Btn.Text = opt.Name or "Button"
				Btn.TextColor3 = GameSenseLib.Theme.Text
				Btn.Font = GameSenseLib.Theme.Font
				Btn.TextSize = 12
				Btn.MouseButton1Click:Connect(function() if opt.Callback then pcall(opt.Callback) end end)
			end

			function SectionObj:AddLabel(text)
				local Label = Instance.new("TextLabel", ItemContainer)
				Label.Size = UDim2.new(1, 0, 0, 15)
				Label.BackgroundTransparency = 1
				Label.Text = text
				Label.TextColor3 = GameSenseLib.Theme.DarkText
				Label.Font = GameSenseLib.Theme.Font
				Label.TextSize = 12
				Label.TextXAlignment = Enum.TextXAlignment.Left
				return { Set = function(v) Label.Text = v end }
			end

			return SectionObj
		end
		return TabObj
	end

	-- BUILT-IN SETTINGS/CONFIG TAB (Merged and Perfected to match Image)
	local SettingsTab = WindowObj:MakeTab({ Name = "Settings", Icon = "rbxassetid://7734053495", IsSettingsTab = true })
	local ConfigListbox = SettingsTab:AddSection({ Name = "Configs", Side = "Left" })
	local MainSettings = SettingsTab:AddSection({ Name = "Main", Side = "Right" })

	-- Config Listbox Setup
	local ConfigName = "default"
	local ConfigBox = ConfigListbox:AddTextbox({ Name = "Type config name...", Default = "default", Callback = function(v) ConfigName = v end })
	ConfigListbox:AddButton({ Name = "Load", Callback = function() GameSenseLib:LoadConfig(ConfigName) end })
	ConfigListbox:AddButton({ Name = "Save/Update", Callback = function() GameSenseLib:SaveConfig(ConfigName, false) end })
	
	-- Main Settings Setup
	MainSettings:AddBind({ Name = "Menu Bind", Default = Enum.KeyCode.Insert, OnKeyChange = function(key) GameSenseLib.MenuKey = key end })
	MainSettings:AddColorpicker({ 
		Name = "Menu Accent Color", 
		Default = GameSenseLib.Theme.Accent,
		Callback = function(c) GameSenseLib:UpdateAccent(c) end
	})
	MainSettings:AddToggle({ Name = "Show Watermark", Default = false, Callback = function(v) GameSenseLib:SetWatermarkVisibility(v) end })
	MainSettings:AddToggle({ Name = "Show Keybinds", Default = false, Callback = function(v) GameSenseLib:SetKeybindsVisibility(v) end })

	-- CONFIG SYSTEM LOGIC (With Silent AutoSaves)
	function GameSenseLib:SaveConfig(filename, isAuto)
		if not isfolder(self.ConfigFolder) then makefolder(self.ConfigFolder) end
		local saveTable = {}
		for flagName, flagObj in pairs(self.Flags) do
			if type(flagObj.Value) == "boolean" or type(flagObj.Value) == "number" or type(flagObj.Value) == "string" or type(flagObj.Value) == "table" then
				saveTable[flagName] = flagObj.Value
			end
		end
		local success, encoded = pcall(function() return HttpService:JSONEncode(saveTable) end)
		if success then 
			writefile(self.ConfigFolder .. "/" .. tostring(game.PlaceId) .. "_" .. filename .. ".json", encoded)
			if not isAuto then self:MakeNotification({Name = "Config", Content = "Saved " .. filename, Time = 3}) end
		end
	end

	function GameSenseLib:LoadConfig(filename)
		local path = self.ConfigFolder .. "/" .. tostring(game.PlaceId) .. "_" .. filename .. ".json"
		if isfile(path) then
			local success, decoded = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
			if success then
				for flag, val in pairs(decoded) do
					if self.Elements[flag] then pcall(function() self.Elements[flag].Set(val) end) end
				end
				self:MakeNotification({Name = "Config", Content = "Loaded " .. filename, Time = 3})
			end
		else
			self:MakeNotification({Name = "Error", Content = "Config not found.", Time = 3})
		end
	end

	function GameSenseLib:Init() 
		if self.AutoSaveEnabled then self:LoadConfig("auto_config") end
	end

	return WindowObj
end

return GameSenseLib
