-- GameSense Lib V14 (The Final Masterpiece)
-- True Skeet Visuals, Draggable Constraints, Functional Config Listbox, Rainbow Colors.

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Anti-Duplication
pcall(function()
	if getgenv().GameSense_UI then getgenv().GameSense_UI:Destroy() end
	if getgenv().GameSense_Input then getgenv().GameSense_Input:Disconnect() end
	for _, v in pairs(CoreGui:GetChildren()) do if v.Name == "GameSenseUI" then v:Destroy() end end
	if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") then
		for _, v in pairs(LocalPlayer.PlayerGui:GetChildren()) do if v.Name == "GameSenseUI" then v:Destroy() end end
	end
end)

local GameSenseLib = {
	Flags = {}, Elements = {}, Binds = {}, AccentObjects = {},
	MenuKey = Enum.KeyCode.Insert,
	ConfigFolder = "GameSense",
	WatermarkText = "gamesense",
	AutoSaveEnabled = false,
	Theme = {
		Background = Color3.fromRGB(17, 17, 17),
		GroupboxBg = Color3.fromRGB(23, 23, 23),
		Outline1 = Color3.fromRGB(0, 0, 0),
		Outline2 = Color3.fromRGB(45, 45, 45),
		Accent = Color3.fromRGB(149, 194, 43),
		Text = Color3.fromRGB(200, 200, 200),
		DarkText = Color3.fromRGB(100, 100, 100),
		Font = Enum.Font.Code
	}
}

local makefolder = makefolder or function() end
local isfolder = isfolder or function() return false end
local isfile = isfile or function() return false end
local writefile = writefile or function() end
local readfile = readfile or function() return "{}" end
local listfiles = listfiles or function() return {} end

-- Dragging only works if a condition (like menu being open) is met
local function MakeDraggable(topbar, object, condition)
	local Dragging, DragInput, DragStart, StartPos
	topbar.InputBegan:Connect(function(input)
		if condition and not condition() then return end
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

function GameSenseLib:UpdateAccent(color)
	self.Theme.Accent = color
	for obj, prop in pairs(self.AccentObjects) do
		if obj and obj.Parent then obj[prop] = color else self.AccentObjects[obj] = nil end
	end
end

-- Skeet Double Border Generator
local function CreateDoubleBorder(parent, size, pos, bgColor)
	local Outer = Instance.new("Frame", parent)
	Outer.Size = size
	Outer.Position = pos
	Outer.BackgroundColor3 = GameSenseLib.Theme.Outline1
	Outer.BorderSizePixel = 0

	local Inner = Instance.new("Frame", Outer)
	Inner.Size = UDim2.new(1, -2, 1, -2)
	Inner.Position = UDim2.new(0, 1, 0, 1)
	Inner.BackgroundColor3 = GameSenseLib.Theme.Outline2
	Inner.BorderSizePixel = 0

	local Main = Instance.new("Frame", Inner)
	Main.Size = UDim2.new(1, -2, 1, -2)
	Main.Position = UDim2.new(0, 1, 0, 1)
	Main.BackgroundColor3 = bgColor or GameSenseLib.Theme.Background
	Main.BorderSizePixel = 0
	
	return Outer, Main
end

function GameSenseLib:MakeWindow(options)
	options = options or {}
	self.ConfigFolder = options.ConfigFolder or "GameSense"
	self.WatermarkText = options.WatermarkText or "gamesense"
	
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

	local MainOuter, MainInnerBg = CreateDoubleBorder(ScreenGui, UDim2.new(0, 660, 0, 560), UDim2.new(0.5, -330, 0.5, -280), self.Theme.Background)
	MainOuter.Visible = true
	MakeDraggable(MainOuter, MainOuter, function() return true end)
	local uiScale = Instance.new("UIScale", MainOuter)

	-- POPUPS
	local PopupContainer = Instance.new("Frame", MainOuter)
	PopupContainer.Size = UDim2.new(1, 0, 1, 0)
	PopupContainer.BackgroundTransparency = 1
	PopupContainer.ZIndex = 1000

	local PopupCatcher = Instance.new("TextButton", PopupContainer)
	PopupCatcher.Size = UDim2.new(1, 0, 1, 0)
	PopupCatcher.BackgroundTransparency = 1
	PopupCatcher.Text = ""
	PopupCatcher.ZIndex = 999
	PopupCatcher.Visible = false

	local function ClosePopups()
		for _, v in pairs(PopupContainer:GetChildren()) do if v ~= PopupCatcher then v:Destroy() end end
		PopupCatcher.Visible = false
	end
	PopupCatcher.MouseButton1Click:Connect(ClosePopups)

	-- WATERMARK
	local WMOuter, WMInner = CreateDoubleBorder(ScreenGui, UDim2.new(0, 200, 0, 20), UDim2.new(1, -10, 0, 10), self.Theme.Background)
	WMOuter.AnchorPoint = Vector2.new(1, 0)
	WMOuter.Visible = false
	self.Watermark = WMOuter
	MakeDraggable(WMOuter, WMOuter, function() return MainOuter.Visible end)

	local WMGradient = Instance.new("Frame", WMInner)
	WMGradient.Size = UDim2.new(1, 0, 0, 2)
	WMGradient.BackgroundColor3 = Color3.new(1,1,1)
	WMGradient.BorderSizePixel = 0
	local uiGrad = Instance.new("UIGradient", WMGradient)
	uiGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(59, 175, 222)), ColorSequenceKeypoint.new(0.3, Color3.fromRGB(202, 105, 235)),
		ColorSequenceKeypoint.new(0.6, Color3.fromRGB(235, 198, 105)), ColorSequenceKeypoint.new(1, Color3.fromRGB(168, 235, 105))
	})

	local WMText = Instance.new("TextLabel", WMInner)
	WMText.Size = UDim2.new(1, 0, 1, 0)
	WMText.BackgroundTransparency = 1
	WMText.TextColor3 = self.Theme.Text
	WMText.Font = self.Theme.Font
	WMText.TextSize = 12
	WMText.TextXAlignment = Enum.TextXAlignment.Center

	-- KEYBINDS FRAME
	local KBOuter, KBInner = CreateDoubleBorder(ScreenGui, UDim2.new(0, 180, 0, 20), UDim2.new(0, 10, 0.4, 0), self.Theme.Background)
	KBOuter.Visible = false
	self.KeybindsFrame = KBOuter
	MakeDraggable(KBOuter, KBOuter, function() return MainOuter.Visible end)
	
	local KBGrad = WMGradient:Clone()
	KBGrad.Parent = KBInner
	KBGrad.Size = UDim2.new(1, 0, 0, 2)
	
	local KBTitle = Instance.new("TextLabel", KBInner)
	KBTitle.Size = UDim2.new(1, 0, 0, 18)
	KBTitle.BackgroundTransparency = 1
	KBTitle.Text = "keybinds"
	KBTitle.TextColor3 = self.Theme.Text
	KBTitle.Font = self.Theme.Font
	KBTitle.TextSize = 12
	KBTitle.TextXAlignment = Enum.TextXAlignment.Center

	local KBSeparator = Instance.new("Frame", KBInner)
	KBSeparator.Size = UDim2.new(1, -10, 0, 1)
	KBSeparator.Position = UDim2.new(0, 5, 0, 18)
	KBSeparator.BackgroundColor3 = self.Theme.Outline2
	KBSeparator.BorderSizePixel = 0

	local KBContainer = Instance.new("Frame", KBInner)
	KBContainer.Size = UDim2.new(1, 0, 0, 0)
	KBContainer.Position = UDim2.new(0, 0, 0, 22)
	KBContainer.BackgroundTransparency = 1
	local KBLayout = Instance.new("UIListLayout", KBContainer)

	RunService.RenderStepped:Connect(function()
		if WMOuter.Visible then 
			WMText.Text = string.format(" %s | %s | %s ", self.WatermarkText, LocalPlayer.Name, os.date("%H:%M:%S"))
			local bounds = WMText.TextBounds.X + 16
			WMOuter.Size = UDim2.new(0, bounds, 0, 20)
		end
		if KBOuter.Visible then
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
			KBContainer.Size = UDim2.new(1, 0, 0, count * 16)
			KBOuter.Size = UDim2.new(0, 180, 0, 25 + (count * 16))
		end
	end)

	local TopBar = Instance.new("Frame", MainInnerBg)
	TopBar.Size = UDim2.new(1, 0, 0, 2)
	TopBar.BackgroundColor3 = Color3.fromRGB(255,255,255)
	TopBar.BorderSizePixel = 0
	uiGrad:Clone().Parent = TopBar

	local Sidebar = Instance.new("Frame", MainInnerBg)
	Sidebar.Size = UDim2.new(0, 60, 1, -2)
	Sidebar.Position = UDim2.new(0, 0, 0, 2)
	Sidebar.BackgroundTransparency = 1
	local SidebarLayout = Instance.new("UIListLayout", Sidebar)
	SidebarLayout.Padding = UDim.new(0, 5)
	SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder 
	Instance.new("UIPadding", Sidebar).PaddingTop = UDim.new(0, 15) 

	local ContentContainer = Instance.new("Frame", MainInnerBg)
	ContentContainer.Size = UDim2.new(1, -65, 1, -10)
	ContentContainer.Position = UDim2.new(0, 60, 0, 5)
	ContentContainer.BackgroundTransparency = 1
	ContentContainer.ClipsDescendants = true 

	getgenv().GameSense_Input = UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if input.KeyCode == GameSenseLib.MenuKey then
			MainOuter.Visible = not MainOuter.Visible
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
		IconImg.ImageColor3 = GameSenseLib.Theme.DarkText -- Dim inactive color

		local TabContent = Instance.new("Frame", ContentContainer)
		TabContent.Size = UDim2.new(1, 0, 1, 0)
		TabContent.BackgroundTransparency = 1
		TabContent.Visible = false

		local LeftCol = Instance.new("ScrollingFrame", TabContent)
		LeftCol.Size = UDim2.new(0.5, -5, 1, 0)
		LeftCol.Position = UDim2.new(0, 0, 0, 0)
		LeftCol.BackgroundTransparency = 1
		LeftCol.ScrollBarThickness = 0
		local LeftLayout = Instance.new("UIListLayout", LeftCol)
		LeftLayout.Padding = UDim.new(0, 15)
		local LPad = Instance.new("UIPadding", LeftCol)
		LPad.PaddingTop = UDim.new(0, 10) LPad.PaddingBottom = UDim.new(0, 10)

		local RightCol = Instance.new("ScrollingFrame", TabContent)
		RightCol.Size = UDim2.new(0.5, -5, 1, 0)
		RightCol.Position = UDim2.new(0.5, 5, 0, 0)
		RightCol.BackgroundTransparency = 1
		RightCol.ScrollBarThickness = 0
		local RightLayout = Instance.new("UIListLayout", RightCol)
		RightLayout.Padding = UDim.new(0, 15)
		local RPad = Instance.new("UIPadding", RightCol)
		RPad.PaddingTop = UDim.new(0, 10) RPad.PaddingBottom = UDim.new(0, 10)

		LeftCol:GetPropertyChangedSignal("CanvasPosition"):Connect(ClosePopups)
		RightCol:GetPropertyChangedSignal("CanvasPosition"):Connect(ClosePopups)

		TabBtn.MouseButton1Click:Connect(function()
			for _, tab in pairs(WindowObj.Tabs) do
				tab.Content.Visible = false
				tab.Icon.ImageColor3 = GameSenseLib.Theme.DarkText
			end
			TabContent.Visible = true
			IconImg.ImageColor3 = Color3.fromRGB(220, 220, 220) -- Bright active color
			ClosePopups()
		end)

		if WindowObj.TabCount == 1 then
			TabContent.Visible = true
			IconImg.ImageColor3 = Color3.fromRGB(220, 220, 220)
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

			local GbOuter, GbInner = CreateDoubleBorder(ParentCol, UDim2.new(1, 0, 0, 20), UDim2.new(0,0,0,0), GameSenseLib.Theme.GroupboxBg)

			local TitleLabel = Instance.new("TextLabel", GbOuter)
			TitleLabel.Position = UDim2.new(0, 15, 0, -6)
			TitleLabel.Size = UDim2.new(0, 0, 0, 12)
			TitleLabel.BackgroundColor3 = GameSenseLib.Theme.Background 
			TitleLabel.BorderSizePixel = 0
			TitleLabel.Text = "  " .. (secOptions.Name or "Section") .. "  "
			TitleLabel.TextColor3 = GameSenseLib.Theme.Text
			TitleLabel.Font = GameSenseLib.Theme.Font
			TitleLabel.TextSize = 12
			TitleLabel.ZIndex = 5
			TitleLabel.AutomaticSize = Enum.AutomaticSize.X

			local ItemContainer = Instance.new("Frame", GbInner)
			ItemContainer.Size = UDim2.new(1, -20, 1, -15)
			ItemContainer.Position = UDim2.new(0, 10, 0, 10)
			ItemContainer.BackgroundTransparency = 1
			local ItemLayout = Instance.new("UIListLayout", ItemContainer)
			ItemLayout.Padding = UDim.new(0, 8)

			local function UpdateSize()
				GbOuter.Size = UDim2.new(1, 0, 0, ItemLayout.AbsoluteContentSize.Y + 20)
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

				local BoxOut, BoxIn = CreateDoubleBorder(Frame, UDim2.new(0, 10, 0, 10), UDim2.new(0, 0, 0.5, -5), GameSenseLib.Theme.Outline2)
				GameSenseLib.AccentObjects[BoxIn] = "BackgroundColor3"

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
					BoxIn.BackgroundColor3 = state and GameSenseLib.Theme.Accent or GameSenseLib.Theme.Outline2
					if not state then GameSenseLib.AccentObjects[BoxIn] = nil else GameSenseLib.AccentObjects[BoxIn] = "BackgroundColor3" end
					
					if opt.Flag then 
						if not GameSenseLib.Flags[opt.Flag] then GameSenseLib.Flags[opt.Flag] = {} end
						GameSenseLib.Flags[opt.Flag].Value = state 
					end
					if opt.Callback then pcall(opt.Callback, state) end
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

				local TrackOut, TrackIn = CreateDoubleBorder(Frame, UDim2.new(1, 0, 0, 10), UDim2.new(0, 0, 0, 18), GameSenseLib.Theme.Outline2)

				local Fill = Instance.new("Frame", TrackIn)
				Fill.Size = UDim2.new((val - opt.Min) / (opt.Max - opt.Min), 0, 1, 0)
				Fill.BackgroundColor3 = GameSenseLib.Theme.Accent
				Fill.BorderSizePixel = 0
				GameSenseLib.AccentObjects[Fill] = "BackgroundColor3"

				local ValLabel = Instance.new("TextLabel", TrackOut)
				ValLabel.Size = UDim2.new(1, -2, 1, 0)
				ValLabel.BackgroundTransparency = 1
				ValLabel.Text = tostring(val) .. (opt.ValueName or "")
				ValLabel.TextColor3 = Color3.new(1,1,1)
				ValLabel.Font = GameSenseLib.Theme.Font
				ValLabel.TextSize = 10
				ValLabel.TextXAlignment = Enum.TextXAlignment.Right
				ValLabel.ZIndex = 5

				local function Set(newVal)
					val = math.clamp(newVal, opt.Min, opt.Max)
					Fill.Size = UDim2.new((val - opt.Min) / (opt.Max - opt.Min), 0, 1, 0)
					ValLabel.Text = tostring(val) .. (opt.ValueName or "")
					
					if opt.Flag then 
						if not GameSenseLib.Flags[opt.Flag] then GameSenseLib.Flags[opt.Flag] = {} end
						GameSenseLib.Flags[opt.Flag].Value = val 
					end
					if opt.Callback then pcall(opt.Callback, val) end
				end

				local dragging = false
				local function Update(input)
					local perc = math.clamp((input.Position.X - TrackOut.AbsolutePosition.X) / TrackOut.AbsoluteSize.X, 0, 1)
					Set(math.floor(opt.Min + (opt.Max - opt.Min) * perc))
				end
				TrackOut.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true Update(inp) end end)
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

				local MainOut, MainIn = CreateDoubleBorder(Frame, UDim2.new(1, 0, 0, 18), UDim2.new(0, 0, 0, 15), GameSenseLib.Theme.GroupboxBg)
				local MainBtn = Instance.new("TextButton", MainIn)
				MainBtn.Size = UDim2.new(1, 0, 1, 0)
				MainBtn.BackgroundTransparency = 1
				MainBtn.Text = " " .. tostring(selected)
				MainBtn.TextColor3 = GameSenseLib.Theme.Text
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
				end

				local function Refresh(newList) opt.Options = newList or {} end

				MainBtn.MouseButton1Click:Connect(function()
					ClosePopups()
					PopupCatcher.Visible = true

					local relX = (MainOut.AbsolutePosition.X - MainOuter.AbsolutePosition.X) / uiScale.Scale
					local relY = (MainOut.AbsolutePosition.Y - MainOuter.AbsolutePosition.Y) / uiScale.Scale

					local DropOut, DropIn = CreateDoubleBorder(PopupContainer, UDim2.new(0, MainOut.AbsoluteSize.X / uiScale.Scale, 0, #(opt.Options or {}) * 16), UDim2.new(0, relX, 0, relY + 20), GameSenseLib.Theme.Outline2)
					local DropLayout = Instance.new("UIListLayout", DropIn)

					for _, item in ipairs(opt.Options or {}) do
						local Btn = Instance.new("TextButton", DropIn)
						Btn.Size = UDim2.new(1, 0, 0, 16)
						Btn.BackgroundTransparency = 1
						Btn.Text = " " .. tostring(item)
						Btn.TextColor3 = GameSenseLib.Theme.Text
						Btn.Font = GameSenseLib.Theme.Font
						Btn.TextSize = 12
						Btn.TextXAlignment = Enum.TextXAlignment.Left
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

				local BtnOut, BtnIn = CreateDoubleBorder(Frame, UDim2.new(0, 45, 0, 15), UDim2.new(1, -45, 0, 0), GameSenseLib.Theme.GroupboxBg)
				local Btn = Instance.new("TextButton", BtnIn)
				Btn.Size = UDim2.new(1, 0, 1, 0)
				Btn.BackgroundTransparency = 1
				Btn.Text = "[" .. (key == Enum.KeyCode.Unknown and "None" or key.Name) .. "]"
				Btn.TextColor3 = GameSenseLib.Theme.DarkText
				Btn.Font = GameSenseLib.Theme.Font
				Btn.TextSize = 11
				
				local KBFrame = Instance.new("Frame", KBContainer)
				KBFrame.Size = UDim2.new(1, 0, 0, 16)
				KBFrame.BackgroundTransparency = 1
				KBFrame.Visible = false
				
				local KBName = Instance.new("TextLabel", KBFrame)
				KBName.Size = UDim2.new(0.5, 0, 1, 0)
				KBName.Position = UDim2.new(0, 5, 0, 0)
				KBName.BackgroundTransparency = 1
				KBName.TextColor3 = GameSenseLib.Theme.Text
				KBName.Font = GameSenseLib.Theme.Font
				KBName.TextSize = 12
				KBName.TextXAlignment = Enum.TextXAlignment.Left
				
				local KBState = Instance.new("TextLabel", KBFrame)
				KBState.Size = UDim2.new(0.5, -5, 1, 0)
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
				end

				local listening = false
				Btn.MouseButton2Click:Connect(function()
					ClosePopups()
					PopupCatcher.Visible = true

					local relX = (BtnOut.AbsolutePosition.X - MainOuter.AbsolutePosition.X) / uiScale.Scale
					local relY = (BtnOut.AbsolutePosition.Y - MainOuter.AbsolutePosition.Y) / uiScale.Scale

					local Modes = {"Always", "Hold", "Toggle"}
					local DropOut, DropIn = CreateDoubleBorder(PopupContainer, UDim2.new(0, 60, 0, #Modes * 16), UDim2.new(0, relX, 0, relY + 18), GameSenseLib.Theme.Outline2)
					Instance.new("UIListLayout", DropIn)

					for _, m in ipairs(Modes) do
						local MBtn = Instance.new("TextButton", DropIn)
						MBtn.Size = UDim2.new(1, 0, 0, 16)
						MBtn.BackgroundTransparency = 1
						MBtn.Text = (bindData.Mode == m and "> " or "  ") .. m
						MBtn.TextColor3 = bindData.Mode == m and GameSenseLib.Theme.Accent or GameSenseLib.Theme.Text
						if bindData.Mode == m then GameSenseLib.AccentObjects[MBtn] = "TextColor3" end
						MBtn.Font = GameSenseLib.Theme.Font
						MBtn.TextSize = 11
						MBtn.TextXAlignment = Enum.TextXAlignment.Left
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

				local BtnOut, BtnIn = CreateDoubleBorder(Frame, UDim2.new(0, 25, 0, 12), UDim2.new(1, -25, 0.5, -6), Color3.fromHSV(h,s,v))
				local Btn = Instance.new("TextButton", BtnIn)
				Btn.Size = UDim2.new(1, 0, 1, 0)
				Btn.BackgroundTransparency = 1
				Btn.Text = ""
				
				local function Set(clr)
					if type(clr) == "table" then h,s,v = clr[1],clr[2],clr[3] else h,s,v = Color3.toHSV(clr) end
					local c = Color3.fromHSV(h, s, v)
					BtnIn.BackgroundColor3 = c
					if opt.Flag then 
						if not GameSenseLib.Flags[opt.Flag] then GameSenseLib.Flags[opt.Flag] = {} end
						GameSenseLib.Flags[opt.Flag].Value = {h, s, v} 
					end
					if opt.Callback then pcall(opt.Callback, c) end
				end

				local rainbow = false
				local rbConn = nil
				local activeSVMap = nil

				local function ToggleRainbow(state)
					rainbow = state
					if rainbow then
						if not rbConn then
							rbConn = RunService.RenderStepped:Connect(function()
								h = (tick() % 5) / 5
								Set({h,s,v})
								if activeSVMap then activeSVMap.BackgroundColor3 = Color3.fromHSV(h, 1, 1) end
							end)
						end
					else
						if rbConn then rbConn:Disconnect(); rbConn = nil end
					end
				end

				Btn.MouseButton1Click:Connect(function()
					ClosePopups()
					PopupCatcher.Visible = true

					local relX = (BtnOut.AbsolutePosition.X - MainOuter.AbsolutePosition.X) / uiScale.Scale
					local relY = (BtnOut.AbsolutePosition.Y - MainOuter.AbsolutePosition.Y) / uiScale.Scale

					local PickOut, PickIn = CreateDoubleBorder(PopupContainer, UDim2.new(0, 150, 0, 170), UDim2.new(0, relX - 125, 0, relY + 15), GameSenseLib.Theme.GroupboxBg)

					local SVOut, SVIn = CreateDoubleBorder(PickIn, UDim2.new(0, 130, 0, 120), UDim2.new(0, 8, 0, 8), Color3.fromHSV(h, 1, 1))
					local SVMap = Instance.new("TextButton", SVIn)
					SVMap.Size = UDim2.new(1, 0, 1, 0)
					SVMap.BackgroundTransparency = 1
					SVMap.Text = ""
					activeSVMap = SVIn

					local WGrad = Instance.new("UIGradient", Instance.new("Frame", SVMap))
					WGrad.Parent.Size = UDim2.new(1,0,1,0) WGrad.Parent.BackgroundColor3 = Color3.new(1,1,1) WGrad.Parent.BorderSizePixel = 0 
					WGrad.Color = ColorSequence.new(Color3.new(1,1,1), Color3.new(1,1,1)) WGrad.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0), NumberSequenceKeypoint.new(1,1)})
					
					local BGrad = Instance.new("UIGradient", Instance.new("Frame", SVMap))
					BGrad.Parent.Size = UDim2.new(1,0,1,0) BGrad.Parent.BackgroundColor3 = Color3.new(1,1,1) BGrad.Parent.BorderSizePixel = 0 
					BGrad.Color = ColorSequence.new(Color3.new(0,0,0), Color3.new(0,0,0)) BGrad.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(1,0)}) BGrad.Rotation = 90

					local HueOut, HueIn = CreateDoubleBorder(PickIn, UDim2.new(0, 130, 0, 12), UDim2.new(0, 8, 0, 132), Color3.new(1,1,1))
					local HueMap = Instance.new("TextButton", HueIn)
					HueMap.Size = UDim2.new(1, 0, 1, 0)
					HueMap.BackgroundTransparency = 1
					HueMap.Text = ""
					local HGrad = Instance.new("UIGradient", HueIn)
					HGrad.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)), ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255, 255, 0)),
						ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
						ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0, 0, 255)), ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
					})

					local RbToggleOut, RbToggleIn = CreateDoubleBorder(PickIn, UDim2.new(0, 130, 0, 14), UDim2.new(0, 8, 0, 148), GameSenseLib.Theme.GroupboxBg)
					local RbBtn = Instance.new("TextButton", RbToggleIn)
					RbBtn.Size = UDim2.new(1, 0, 1, 0)
					RbBtn.BackgroundTransparency = 1
					RbBtn.Text = rainbow and "Rainbow: ON" or "Rainbow: OFF"
					RbBtn.TextColor3 = rainbow and GameSenseLib.Theme.Accent or GameSenseLib.Theme.Text
					RbBtn.Font = GameSenseLib.Theme.Font
					RbBtn.TextSize = 11
					
					RbBtn.MouseButton1Click:Connect(function()
						rainbow = not rainbow
						RbBtn.Text = rainbow and "Rainbow: ON" or "Rainbow: OFF"
						RbBtn.TextColor3 = rainbow and GameSenseLib.Theme.Accent or GameSenseLib.Theme.Text
						ToggleRainbow(rainbow)
					end)

					local draggingSV, draggingH = false, false
					local function UpdateSV(input)
						s = math.clamp((input.Position.X - SVOut.AbsolutePosition.X) / SVOut.AbsoluteSize.X, 0, 1)
						v = 1 - math.clamp((input.Position.Y - SVOut.AbsolutePosition.Y) / SVOut.AbsoluteSize.Y, 0, 1)
						Set({h,s,v})
					end
					local function UpdateH(input)
						if rainbow then ToggleRainbow(false); RbBtn.Text = "Rainbow: OFF"; RbBtn.TextColor3 = GameSenseLib.Theme.Text end
						h = math.clamp((input.Position.X - HueOut.AbsolutePosition.X) / HueOut.AbsoluteSize.X, 0, 1)
						SVIn.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
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

				local BoxOut, BoxIn = CreateDoubleBorder(Frame, UDim2.new(1, 0, 0, 18), UDim2.new(0, 0, 0, 15), GameSenseLib.Theme.GroupboxBg)
				local Box = Instance.new("TextBox", BoxIn)
				Box.Size = UDim2.new(1, -10, 1, 0)
				Box.Position = UDim2.new(0, 5, 0, 0)
				Box.BackgroundTransparency = 1
				Box.Text = val
				Box.TextColor3 = GameSenseLib.Theme.Text
				Box.Font = GameSenseLib.Theme.Font
				Box.TextSize = 12
				Box.TextXAlignment = Enum.TextXAlignment.Left
				Box.ClearTextOnFocus = false
				
				local function Set(newVal)
					Box.Text = newVal
					if opt.Flag then 
						if not GameSenseLib.Flags[opt.Flag] then GameSenseLib.Flags[opt.Flag] = {} end
						GameSenseLib.Flags[opt.Flag].Value = newVal 
					end
					if opt.Callback then pcall(opt.Callback, newVal) end
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
				local BtnOut, BtnIn = CreateDoubleBorder(ItemContainer, UDim2.new(1, 0, 0, 20), UDim2.new(0,0,0,0), GameSenseLib.Theme.GroupboxBg)
				local Btn = Instance.new("TextButton", BtnIn)
				Btn.Size = UDim2.new(1, 0, 1, 0)
				Btn.BackgroundTransparency = 1
				Btn.Text = opt.Name or "Button"
				Btn.TextColor3 = GameSenseLib.Theme.Text
				Btn.Font = GameSenseLib.Theme.Font
				Btn.TextSize = 12
				Btn.MouseButton1Click:Connect(function() if opt.Callback then pcall(opt.Callback) end end)
			end
			
			function SectionObj:AddListbox(opt)
				local ListOut, ListIn = CreateDoubleBorder(ItemContainer, UDim2.new(1, 0, 0, opt.Height or 150), UDim2.new(0,0,0,0), GameSenseLib.Theme.MenuBg)
				local Scroll = Instance.new("ScrollingFrame", ListIn)
				Scroll.Size = UDim2.new(1, 0, 1, 0)
				Scroll.BackgroundTransparency = 1
				Scroll.ScrollBarThickness = 2
				local ListLayout = Instance.new("UIListLayout", Scroll)

				local selected = ""
				local buttons = {}

				local function Refresh(newList)
					for _, b in pairs(buttons) do b:Destroy() end
					buttons = {}
					for i, v in ipairs(newList) do
						local Btn = Instance.new("TextButton", Scroll)
						Btn.Size = UDim2.new(1, 0, 0, 16)
						Btn.BackgroundTransparency = 1
						Btn.Text = "  " .. tostring(v)
						Btn.TextColor3 = GameSenseLib.Theme.Text
						Btn.TextXAlignment = Enum.TextXAlignment.Left
						Btn.Font = GameSenseLib.Theme.Font
						Btn.TextSize = 12

						Btn.MouseButton1Click:Connect(function()
							selected = v
							for _, b in pairs(buttons) do 
								b.TextColor3 = GameSenseLib.Theme.Text 
								GameSenseLib.AccentObjects[b] = nil 
							end
							Btn.TextColor3 = GameSenseLib.Theme.Accent
							GameSenseLib.AccentObjects[Btn] = "TextColor3"
							if opt.Callback then pcall(opt.Callback, v) end
						end)
						table.insert(buttons, Btn)
					end
					Scroll.CanvasSize = UDim2.new(0, 0, 0, #newList * 16)
				end

				Refresh(opt.Options or {})
				return { Refresh = Refresh, GetSelected = function() return selected end }
			end

			return SectionObj
		end
		return TabObj
	end

	-- BUILT-IN SETTINGS & CONFIG TAB
	local SettingsTab = WindowObj:MakeTab({ Name = "Settings", Icon = "rbxassetid://7734053495", IsSettingsTab = true })
	local ConfigListboxSec = SettingsTab:AddSection({ Name = "Configs", Side = "Left" })
	local MainSettings = SettingsTab:AddSection({ Name = "Main", Side = "Right" })

	local SelectedConfig = "default"
	
	local function GetConfigs()
		local files = listfiles(GameSenseLib.ConfigFolder) or {}
		local valid = {}
		for _, f in ipairs(files) do
			local name = f:match("([^/\\]+)%.json$")
			if name then table.insert(valid, name) end
		end
		return valid
	end

	local CfgBox = ConfigListboxSec:AddListbox({
		Options = GetConfigs(),
		Height = 160,
		Callback = function(val) SelectedConfig = val end
	})

	local CfgInput = ConfigListboxSec:AddTextbox({ Name = "Type config name...", Default = "", TextDisappear = false, Callback = function(v) SelectedConfig = v end })
	
	ConfigListboxSec:AddButton({ Name = "Load", Callback = function() GameSenseLib:LoadConfig(SelectedConfig) end })
	ConfigListboxSec:AddButton({ Name = "Save/Update", Callback = function() GameSenseLib:SaveConfig(SelectedConfig, false); CfgBox:Refresh(GetConfigs()) end })
	ConfigListboxSec:AddButton({ Name = "Refresh", Callback = function() CfgBox:Refresh(GetConfigs()) end })
	
	MainSettings:AddBind({ Name = "Menu Bind", Default = Enum.KeyCode.Insert, OnKeyChange = function(key) GameSenseLib.MenuKey = key end })
	MainSettings:AddColorpicker({ 
		Name = "Menu Accent Color", 
		Default = GameSenseLib.Theme.Accent,
		Callback = function(c) GameSenseLib:UpdateAccent(c) end
	})
	MainSettings:AddToggle({ Name = "Show Watermark", Default = false, Callback = function(v) GameSenseLib:SetWatermarkVisibility(v) end })
	MainSettings:AddToggle({ Name = "Show Keybinds", Default = false, Callback = function(v) GameSenseLib:SetKeybindsVisibility(v) end })

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
			writefile(self.ConfigFolder .. "/" .. filename .. ".json", encoded)
			if not isAuto then self:MakeNotification({Name = "Config Saved", Content = "Saved " .. filename, Time = 3}) end
		end
	end

	function GameSenseLib:LoadConfig(filename)
		local path = self.ConfigFolder .. "/" .. filename .. ".json"
		if isfile(path) then
			local success, decoded = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
			if success then
				for flag, val in pairs(decoded) do
					if self.Elements[flag] then pcall(function() self.Elements[flag].Set(val) end) end
				end
				self:MakeNotification({Name = "Config Loaded", Content = "Loaded " .. filename, Time = 3})
			end
		else
			self:MakeNotification({Name = "Error", Content = "Config not found.", Time = 3})
		end
	end

	function GameSenseLib:Destroy() 
		if self.Gui then self.Gui:Destroy() end 
		if getgenv().GameSense_Input then getgenv().GameSense_Input:Disconnect() end
	end

	function GameSenseLib:Init() 
		if self.AutoSaveEnabled then self:LoadConfig("auto_config") end
	end

	return WindowObj
end

return GameSenseLib
