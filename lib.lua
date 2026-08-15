-- GameSense Lib V8 - Final Polish
-- Fixed API Crash, Restored Tracker Functions, Full Orion Parity.

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- 100% Crash-Proof Anti-Duplicate System
pcall(function()
	if getgenv().GameSense_UI_Instance then
		getgenv().GameSense_UI_Instance:Destroy()
		getgenv().GameSense_UI_Instance = nil
	end
	for _, v in pairs(CoreGui:GetChildren()) do
		if v.Name == "GameSenseUI" then v:Destroy() end
	end
	if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") then
		for _, v in pairs(LocalPlayer.PlayerGui:GetChildren()) do
			if v.Name == "GameSenseUI" then v:Destroy() end
		end
	end
end)

local GameSenseLib = {
	Flags = {},
	Elements = {},
	Binds = {},
	MenuKey = Enum.KeyCode.Insert,
	ConfigFolder = "GameSense",
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

local makefolder = makefolder or function() end
local isfolder = isfolder or function() return false end
local isfile = isfile or function() return false end
local writefile = writefile or function() end
local readfile = readfile or function() return "{}" end

local function MakeDraggable(topbarobject, object)
	local Dragging, DragInput, DragStart, StartPosition
	topbarobject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			Dragging = true DragStart = input.Position StartPosition = object.Position
			input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then Dragging = false end end)
		end
	end)
	topbarobject.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then DragInput = input end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == DragInput and Dragging then
			local delta = input.Position - DragStart
			object.Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + delta.Y)
		end
	end)
end

-- Global Visibility Functions API (Fixes the crash!)
function GameSenseLib:SetWatermarkVisibility(state)
	if self.Watermark then self.Watermark.Visible = state end
end

function GameSenseLib:SetKeybindsVisibility(state)
	if self.KeybindsFrame then self.KeybindsFrame.Visible = state end
end

function GameSenseLib:MakeWindow(options)
	options = options or {}
	self.ConfigFolder = options.ConfigFolder or "GameSense"
	
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "GameSenseUI"
	ScreenGui.ResetOnSpawn = false
	pcall(function() ScreenGui.Parent = CoreGui end)
	if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
	
	self.Gui = ScreenGui
	getgenv().GameSense_UI_Instance = ScreenGui 

	local NotifContainer = Instance.new("Frame")
	NotifContainer.Size = UDim2.new(0, 250, 1, -20)
	NotifContainer.Position = UDim2.new(1, -260, 0, 10)
	NotifContainer.BackgroundTransparency = 1
	NotifContainer.ZIndex = 1000
	NotifContainer.Parent = ScreenGui
	
	local NotifLayout = Instance.new("UIListLayout")
	NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
	NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	NotifLayout.Padding = UDim.new(0, 10)
	NotifLayout.Parent = NotifContainer

	function GameSenseLib:MakeNotification(opt)
		local title = opt.Name or "Notification"
		local content = opt.Content or ""
		local time = opt.Time or 5

		local NotifFrame = Instance.new("Frame")
		NotifFrame.Size = UDim2.new(1, 0, 0, 50)
		NotifFrame.Position = UDim2.new(1, 300, 0, 0)
		NotifFrame.BackgroundColor3 = self.Theme.MenuBg
		NotifFrame.BorderColor3 = self.Theme.Outline
		NotifFrame.ZIndex = 1000
		NotifFrame.Parent = NotifContainer

		local NGrad = Instance.new("Frame")
		NGrad.Size = UDim2.new(1, 0, 0, 1)
		NGrad.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		NGrad.BorderSizePixel = 0
		NGrad.ZIndex = 1001
		NGrad.Parent = NotifFrame
		
		local UIG = Instance.new("UIGradient")
		UIG.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(59, 175, 222)), ColorSequenceKeypoint.new(0.3, Color3.fromRGB(202, 105, 235)),
			ColorSequenceKeypoint.new(0.6, Color3.fromRGB(235, 198, 105)), ColorSequenceKeypoint.new(1, Color3.fromRGB(168, 235, 105))
		})
		UIG.Parent = NGrad

		local NTitle = Instance.new("TextLabel")
		NTitle.Size = UDim2.new(1, -10, 0, 15)
		NTitle.Position = UDim2.new(0, 5, 0, 5)
		NTitle.BackgroundTransparency = 1
		NTitle.Text = title
		NTitle.TextColor3 = self.Theme.Text
		NTitle.Font = self.Theme.Font
		NTitle.TextSize = 13
		NTitle.TextXAlignment = Enum.TextXAlignment.Left
		NTitle.ZIndex = 1001
		NTitle.Parent = NotifFrame

		local NContent = Instance.new("TextLabel")
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
		NContent.ZIndex = 1001
		NContent.Parent = NotifFrame
		
		local tweenIn = TweenService:Create(NotifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)})
		tweenIn:Play()
		
		task.delay(time, function()
			local tweenOut = TweenService:Create(NotifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1, 300, 0, 0)})
			tweenOut:Play()
			tweenOut.Completed:Connect(function() NotifFrame:Destroy() end)
		end)
	end

	local PopupContainer = Instance.new("Frame")
	PopupContainer.Size = UDim2.new(1, 0, 1, 0)
	PopupContainer.BackgroundTransparency = 1
	PopupContainer.ZIndex = 100
	PopupContainer.Parent = ScreenGui

	local PopupCatcher = Instance.new("TextButton")
	PopupCatcher.Size = UDim2.new(1, 0, 1, 0)
	PopupCatcher.BackgroundTransparency = 1
	PopupCatcher.Text = ""
	PopupCatcher.ZIndex = 99
	PopupCatcher.Visible = false
	PopupCatcher.Parent = PopupContainer

	local function ClosePopups()
		for _, v in pairs(PopupContainer:GetChildren()) do if v ~= PopupCatcher then v:Destroy() end end
		PopupCatcher.Visible = false
	end
	PopupCatcher.MouseButton1Click:Connect(ClosePopups)

	-- WATERMARK
	local Watermark = Instance.new("TextLabel")
	Watermark.Size = UDim2.new(0, 250, 0, 20)
	Watermark.Position = UDim2.new(1, -260, 0, 10)
	Watermark.BackgroundColor3 = self.Theme.MenuBg
	Watermark.BorderColor3 = self.Theme.Outline
	Watermark.TextColor3 = self.Theme.Text
	Watermark.Font = self.Theme.Font
	Watermark.TextSize = 13
	Watermark.TextXAlignment = Enum.TextXAlignment.Left
	Watermark.Parent = ScreenGui
	Watermark.Visible = false
	self.Watermark = Watermark

	local WMGradient = Instance.new("Frame")
	WMGradient.Size = UDim2.new(1, 0, 0, 1)
	WMGradient.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	WMGradient.BorderSizePixel = 0
	WMGradient.Parent = Watermark
	
	local uiGrad = Instance.new("UIGradient")
	uiGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(59, 175, 222)), ColorSequenceKeypoint.new(0.3, Color3.fromRGB(202, 105, 235)),
		ColorSequenceKeypoint.new(0.6, Color3.fromRGB(235, 198, 105)), ColorSequenceKeypoint.new(1, Color3.fromRGB(168, 235, 105))
	})
	uiGrad.Parent = WMGradient

	-- KEYBINDS FRAME
	local KeybindsFrame = Instance.new("Frame")
	KeybindsFrame.Size = UDim2.new(0, 180, 0, 25)
	KeybindsFrame.Position = UDim2.new(0, 10, 0.5, 0)
	KeybindsFrame.BackgroundColor3 = self.Theme.MenuBg
	KeybindsFrame.BorderColor3 = self.Theme.Outline
	KeybindsFrame.Parent = ScreenGui
	KeybindsFrame.Visible = false
	self.KeybindsFrame = KeybindsFrame
	MakeDraggable(KeybindsFrame, KeybindsFrame)
	
	WMGradient:Clone().Parent = KeybindsFrame
	
	local KBTitle = Instance.new("TextLabel")
	KBTitle.Size = UDim2.new(1, 0, 1, 0)
	KBTitle.BackgroundTransparency = 1
	KBTitle.Text = " keybinds"
	KBTitle.TextColor3 = self.Theme.Text
	KBTitle.Font = self.Theme.Font
	KBTitle.TextSize = 13
	KBTitle.TextXAlignment = Enum.TextXAlignment.Left
	KBTitle.Parent = KeybindsFrame

	local KBContainer = Instance.new("Frame")
	KBContainer.Size = UDim2.new(1, 0, 0, 0)
	KBContainer.Position = UDim2.new(0, 0, 1, 2)
	KBContainer.BackgroundColor3 = self.Theme.MenuBg
	KBContainer.BorderColor3 = self.Theme.Outline
	KBContainer.Parent = KeybindsFrame
	local KBLayout = Instance.new("UIListLayout")
	KBLayout.Parent = KBContainer

	RunService.RenderStepped:Connect(function(dt)
		if Watermark.Visible then 
			Watermark.Text = string.format(" gamesense | %s | %d fps", LocalPlayer.Name, math.floor(1/dt)) 
		end
		
		if KeybindsFrame.Visible then
			local count = 0
			for _, bind in ipairs(GameSenseLib.Binds) do
				if bind.Key ~= Enum.KeyCode.Unknown then
					count = count + 1
					bind.Label.Visible = true
					local isActive = false
					if bind.Mode == "Always" then isActive = true
					elseif bind.Mode == "Hold" then 
						for _, k in pairs(UserInputService:GetKeysPressed()) do if k.KeyCode == bind.Key then isActive = true break end end
					elseif bind.Mode == "Toggle" then isActive = bind.Toggled end
					
					bind.Label.TextColor3 = isActive and GameSenseLib.Theme.Accent or GameSenseLib.Theme.Text
					bind.Label.Text = string.format(" %s [%s]", bind.Name, bind.Mode)
				else
					bind.Label.Visible = false
				end
			end
			KBContainer.Size = UDim2.new(1, 0, 0, count * 18)
		end
	end)

	local Main = Instance.new("Frame")
	Main.Size = UDim2.new(0, 600, 0, 450)
	Main.Position = UDim2.new(0.5, -300, 0.5, -225)
	Main.BackgroundColor3 = self.Theme.MenuBg
	Main.BorderColor3 = self.Theme.DarkOutline
	Main.BorderSizePixel = 2
	Main.Parent = ScreenGui
	MakeDraggable(Main, Main)

	local uiScale = Instance.new("UIScale")
	uiScale.Parent = Main

	local InnerMain = Instance.new("Frame")
	InnerMain.Size = UDim2.new(1, -2, 1, -2)
	InnerMain.Position = UDim2.new(0, 1, 0, 1)
	InnerMain.BackgroundColor3 = self.Theme.MenuBg
	InnerMain.BorderColor3 = self.Theme.Outline
	InnerMain.ClipsDescendants = true 
	InnerMain.Parent = Main

	local TopBar = Instance.new("Frame")
	TopBar.Size = UDim2.new(1, 0, 0, 2)
	TopBar.BackgroundColor3 = Color3.fromRGB(255,255,255)
	TopBar.BorderSizePixel = 0
	TopBar.ZIndex = 50
	TopBar.Parent = InnerMain
	local uiGradClone = Instance.new("UIGradient")
	uiGradClone.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(59, 175, 222)), ColorSequenceKeypoint.new(0.3, Color3.fromRGB(202, 105, 235)),
		ColorSequenceKeypoint.new(0.6, Color3.fromRGB(235, 198, 105)), ColorSequenceKeypoint.new(1, Color3.fromRGB(168, 235, 105))
	})
	uiGradClone.Parent = TopBar

	local Sidebar = Instance.new("Frame")
	Sidebar.Size = UDim2.new(0, 60, 1, -2)
	Sidebar.Position = UDim2.new(0, 0, 0, 2)
	Sidebar.BackgroundColor3 = self.Theme.MenuBg
	Sidebar.BorderColor3 = self.Theme.Outline
	Sidebar.Parent = InnerMain

	local SidebarLayout = Instance.new("UIListLayout")
	SidebarLayout.Padding = UDim.new(0, 5)
	SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder 
	SidebarLayout.Parent = Sidebar
	
	local SidebarPadding = Instance.new("UIPadding")
	SidebarPadding.PaddingTop = UDim.new(0, 15) 
	SidebarPadding.Parent = Sidebar

	local ContentContainer = Instance.new("Frame")
	ContentContainer.Size = UDim2.new(1, -61, 1, -2)
	ContentContainer.Position = UDim2.new(0, 61, 0, 2)
	ContentContainer.BackgroundColor3 = self.Theme.Background
	ContentContainer.BorderSizePixel = 0
	ContentContainer.ClipsDescendants = true 
	ContentContainer.Parent = InnerMain

	local keybindConnection = UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if input.KeyCode == GameSenseLib.MenuKey then
			Main.Visible = not Main.Visible
			ClosePopups()
		end
	end)

	local WindowObj = {Tabs = {}, TabCount = 0}

	function WindowObj:MakeTab(tabOptions)
		WindowObj.TabCount = WindowObj.TabCount + 1
		local TabBtn = Instance.new("TextButton")
		TabBtn.Size = UDim2.new(1, 0, 0, 50)
		TabBtn.BackgroundTransparency = 1
		TabBtn.LayoutOrder = WindowObj.TabCount
		TabBtn.Text = ""
		TabBtn.Parent = Sidebar

		local IconImg = Instance.new("ImageLabel")
		IconImg.Size = UDim2.new(0, 30, 0, 30)
		IconImg.Position = UDim2.new(0.5, -15, 0.5, -15)
		IconImg.BackgroundTransparency = 1
		IconImg.Image = tabOptions.Icon or ""
		IconImg.ImageColor3 = GameSenseLib.Theme.DarkText
		IconImg.Parent = TabBtn

		local TabContent = Instance.new("Frame")
		TabContent.Size = UDim2.new(1, 0, 1, 0)
		TabContent.BackgroundTransparency = 1
		TabContent.Visible = false
		TabContent.Parent = ContentContainer

		local LeftCol = Instance.new("ScrollingFrame")
		LeftCol.Size = UDim2.new(0.5, -15, 1, 0)
		LeftCol.Position = UDim2.new(0, 10, 0, 0)
		LeftCol.BackgroundTransparency = 1
		LeftCol.ScrollBarThickness = 0
		LeftCol.ClipsDescendants = true 
		LeftCol.Parent = TabContent
		local LeftLayout = Instance.new("UIListLayout")
		LeftLayout.Padding = UDim.new(0, 15)
		LeftLayout.Parent = LeftCol
		local LeftPad = Instance.new("UIPadding")
		LeftPad.PaddingTop = UDim.new(0, 12)
		LeftPad.PaddingBottom = UDim.new(0, 12)
		LeftPad.Parent = LeftCol

		local RightCol = Instance.new("ScrollingFrame")
		RightCol.Size = UDim2.new(0.5, -15, 1, 0)
		RightCol.Position = UDim2.new(0.5, 5, 0, 0)
		RightCol.BackgroundTransparency = 1
		RightCol.ScrollBarThickness = 0
		RightCol.ClipsDescendants = true 
		RightCol.Parent = TabContent
		local RightLayout = Instance.new("UIListLayout")
		RightLayout.Padding = UDim.new(0, 15)
		RightLayout.Parent = RightCol
		local RightPad = Instance.new("UIPadding")
		RightPad.PaddingTop = UDim.new(0, 12)
		RightPad.PaddingBottom = UDim.new(0, 12)
		RightPad.Parent = RightCol

		TabBtn.MouseButton1Click:Connect(function()
			for _, tab in pairs(WindowObj.Tabs) do
				tab.Content.Visible = false
				tab.Icon.ImageColor3 = GameSenseLib.Theme.DarkText
			end
			TabContent.Visible = true
			IconImg.ImageColor3 = GameSenseLib.Theme.Accent
			ClosePopups()
		end)

		if #WindowObj.Tabs == 0 then
			TabContent.Visible = true
			IconImg.ImageColor3 = GameSenseLib.Theme.Accent
		end

		table.insert(WindowObj.Tabs, {Content = TabContent, Icon = IconImg})

		local TabObj = {TabBtn = TabBtn}
		function TabObj:AddSection(secOptions)
			local side = secOptions.Side or "Left"
			local ParentCol = (side == "Right") and RightCol or LeftCol

			local Groupbox = Instance.new("Frame")
			Groupbox.Size = UDim2.new(1, 0, 0, 20)
			Groupbox.BackgroundColor3 = GameSenseLib.Theme.MenuBg
			Groupbox.BorderColor3 = GameSenseLib.Theme.Outline
			Groupbox.ZIndex = 1
			Groupbox.Parent = ParentCol

			local TitleBg = Instance.new("Frame")
			TitleBg.Position = UDim2.new(0, 15, 0, -6)
			TitleBg.Size = UDim2.new(0, 5, 0, 12)
			TitleBg.BackgroundColor3 = GameSenseLib.Theme.Background
			TitleBg.BorderSizePixel = 0
			TitleBg.ZIndex = 2
			TitleBg.Parent = Groupbox

			local TitleLabel = Instance.new("TextLabel")
			TitleLabel.Position = UDim2.new(0, 2, 0, -1)
			TitleLabel.Size = UDim2.new(0, 0, 1, 0)
			TitleLabel.BackgroundTransparency = 1
			TitleLabel.Text = secOptions.Name or "Section"
			TitleLabel.TextColor3 = GameSenseLib.Theme.Text
			TitleLabel.Font = GameSenseLib.Theme.Font
			TitleLabel.TextSize = 13
			TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
			TitleLabel.ZIndex = 3
			TitleLabel.Parent = TitleBg
			TitleBg.Size = UDim2.new(0, TitleLabel.TextBounds.X + 4, 0, 12)

			local ItemContainer = Instance.new("Frame")
			ItemContainer.Size = UDim2.new(1, -20, 1, -15)
			ItemContainer.Position = UDim2.new(0, 10, 0, 10)
			ItemContainer.BackgroundTransparency = 1
			ItemContainer.ZIndex = 2
			ItemContainer.Parent = Groupbox

			local ItemLayout = Instance.new("UIListLayout")
			ItemLayout.Padding = UDim.new(0, 8)
			ItemLayout.Parent = ItemContainer

			local function UpdateSize()
				Groupbox.Size = UDim2.new(1, 0, 0, ItemLayout.AbsoluteContentSize.Y + 20)
				local targetLayout = side == "Right" and RightLayout or LeftLayout
				ParentCol.CanvasSize = UDim2.new(0, 0, 0, targetLayout.AbsoluteContentSize.Y + 25)
			end
			ItemLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateSize)

			local SectionObj = {}

			function SectionObj:AddToggle(opt)
				local state = opt.Default or false
				local Frame = Instance.new("TextButton")
				Frame.Size = UDim2.new(1, 0, 0, 12)
				Frame.BackgroundTransparency = 1
				Frame.Text = ""
				Frame.Parent = ItemContainer

				local Box = Instance.new("Frame")
				Box.Size = UDim2.new(0, 10, 0, 10)
				Box.Position = UDim2.new(0, 0, 0.5, -5)
				Box.BackgroundColor3 = state and GameSenseLib.Theme.Accent or GameSenseLib.Theme.DarkOutline
				Box.BorderColor3 = GameSenseLib.Theme.Outline
				Box.Parent = Frame

				local Label = Instance.new("TextLabel")
				Label.Size = UDim2.new(1, -20, 1, 0)
				Label.Position = UDim2.new(0, 18, 0, 0)
				Label.BackgroundTransparency = 1
				Label.Text = opt.Name or "Toggle"
				Label.TextColor3 = GameSenseLib.Theme.Text
				Label.Font = GameSenseLib.Theme.Font
				Label.TextSize = 12
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.Parent = Frame

				local function Set(val)
					state = val
					Box.BackgroundColor3 = state and GameSenseLib.Theme.Accent or GameSenseLib.Theme.DarkOutline
					if opt.Flag then GameSenseLib.Flags[opt.Flag] = state end
					if opt.Callback then pcall(opt.Callback, state) end
				end
				Frame.MouseButton1Click:Connect(function() Set(not state) end)
				
				if opt.Flag then GameSenseLib.Elements[opt.Flag] = {Set = Set} end
				Set(state)
				return { Set = Set }
			end

			function SectionObj:AddSlider(opt)
				local val = opt.Default or opt.Min
				local Frame = Instance.new("Frame")
				Frame.Size = UDim2.new(1, 0, 0, 30)
				Frame.BackgroundTransparency = 1
				Frame.Parent = ItemContainer

				local Label = Instance.new("TextLabel")
				Label.Size = UDim2.new(1, 0, 0, 15)
				Label.BackgroundTransparency = 1
				Label.Text = opt.Name or "Slider"
				Label.TextColor3 = GameSenseLib.Theme.Text
				Label.Font = GameSenseLib.Theme.Font
				Label.TextSize = 12
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.Parent = Frame

				local Track = Instance.new("TextButton")
				Track.Size = UDim2.new(1, 0, 0, 10)
				Track.Position = UDim2.new(0, 0, 0, 18)
				Track.BackgroundColor3 = GameSenseLib.Theme.DarkOutline
				Track.BorderColor3 = GameSenseLib.Theme.Outline
				Track.Text = ""
				Track.Parent = Frame

				local Fill = Instance.new("Frame")
				Fill.Size = UDim2.new((val - opt.Min) / (opt.Max - opt.Min), 0, 1, 0)
				Fill.BackgroundColor3 = GameSenseLib.Theme.Accent
				Fill.BorderSizePixel = 0
				Fill.Parent = Track

				local ValLabel = Instance.new("TextLabel")
				ValLabel.Size = UDim2.new(1, -2, 1, 0)
				ValLabel.BackgroundTransparency = 1
				ValLabel.Text = tostring(val) .. (opt.ValueName or "")
				ValLabel.TextColor3 = Color3.new(1,1,1)
				ValLabel.Font = GameSenseLib.Theme.Font
				ValLabel.TextSize = 10
				ValLabel.TextXAlignment = Enum.TextXAlignment.Right
				ValLabel.Parent = Track

				local function Set(newVal)
					val = math.clamp(newVal, opt.Min, opt.Max)
					Fill.Size = UDim2.new((val - opt.Min) / (opt.Max - opt.Min), 0, 1, 0)
					ValLabel.Text = tostring(val) .. (opt.ValueName or "")
					if opt.Flag then GameSenseLib.Flags[opt.Flag] = val end
					if opt.Callback then pcall(opt.Callback, val) end
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
				local Frame = Instance.new("Frame")
				Frame.Size = UDim2.new(1, 0, 0, 35)
				Frame.BackgroundTransparency = 1
				Frame.Parent = ItemContainer

				local Label = Instance.new("TextLabel")
				Label.Size = UDim2.new(1, 0, 0, 15)
				Label.BackgroundTransparency = 1
				Label.Text = opt.Name or "Dropdown"
				Label.TextColor3 = GameSenseLib.Theme.Text
				Label.Font = GameSenseLib.Theme.Font
				Label.TextSize = 12
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.Parent = Frame

				local MainBtn = Instance.new("TextButton")
				MainBtn.Size = UDim2.new(1, 0, 0, 18)
				MainBtn.Position = UDim2.new(0, 0, 0, 15)
				MainBtn.BackgroundColor3 = GameSenseLib.Theme.DarkOutline
				MainBtn.BorderColor3 = GameSenseLib.Theme.Outline
				MainBtn.Text = " " .. tostring(selected)
				MainBtn.TextColor3 = GameSenseLib.Theme.DarkText
				MainBtn.Font = GameSenseLib.Theme.Font
				MainBtn.TextSize = 12
				MainBtn.TextXAlignment = Enum.TextXAlignment.Left
				MainBtn.Parent = Frame
				
				local function Set(val)
					selected = val
					MainBtn.Text = " " .. tostring(val)
					if opt.Flag then GameSenseLib.Flags[opt.Flag] = val end
					if opt.Callback then pcall(opt.Callback, val) end
				end

				local function Refresh(newList, preserve)
					opt.Options = newList or {}
					if not preserve and #opt.Options > 0 then Set(opt.Options[1]) end
				end

				MainBtn.MouseButton1Click:Connect(function()
					ClosePopups()
					PopupCatcher.Visible = true

					local relX = (MainBtn.AbsolutePosition.X - Main.AbsolutePosition.X) / uiScale.Scale
					local relY = (MainBtn.AbsolutePosition.Y - Main.AbsolutePosition.Y) / uiScale.Scale

					local DropContainer = Instance.new("Frame")
					DropContainer.Size = UDim2.new(0, MainBtn.AbsoluteSize.X / uiScale.Scale, 0, #(opt.Options or {}) * 18)
					DropContainer.Position = UDim2.new(0, relX, 0, relY + 20)
					DropContainer.BackgroundColor3 = GameSenseLib.Theme.MenuBg
					DropContainer.BorderColor3 = GameSenseLib.Theme.Outline
					DropContainer.ZIndex = 101
					DropContainer.Parent = PopupContainer

					local DropLayout = Instance.new("UIListLayout")
					DropLayout.Parent = DropContainer

					for _, item in ipairs(opt.Options or {}) do
						local Btn = Instance.new("TextButton")
						Btn.Size = UDim2.new(1, 0, 0, 18)
						Btn.BackgroundColor3 = GameSenseLib.Theme.MenuBg
						Btn.BorderSizePixel = 0
						Btn.Text = " " .. tostring(item)
						Btn.TextColor3 = GameSenseLib.Theme.Text
						Btn.Font = GameSenseLib.Theme.Font
						Btn.TextSize = 12
						Btn.TextXAlignment = Enum.TextXAlignment.Left
						Btn.ZIndex = 102
						Btn.Parent = DropContainer

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
				
				local Frame = Instance.new("Frame")
				Frame.Size = UDim2.new(1, 0, 0, 15)
				Frame.BackgroundTransparency = 1
				Frame.Parent = ItemContainer

				local Label = Instance.new("TextLabel")
				Label.Size = UDim2.new(1, -50, 1, 0)
				Label.BackgroundTransparency = 1
				Label.Text = opt.Name or "Bind"
				Label.TextColor3 = GameSenseLib.Theme.Text
				Label.Font = GameSenseLib.Theme.Font
				Label.TextSize = 12
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.Parent = Frame

				local Btn = Instance.new("TextButton")
				Btn.Size = UDim2.new(0, 45, 0, 15)
				Btn.Position = UDim2.new(1, -45, 0, 0)
				Btn.BackgroundColor3 = GameSenseLib.Theme.DarkOutline
				Btn.BorderColor3 = GameSenseLib.Theme.Outline
				Btn.Text = "[" .. (key == Enum.KeyCode.Unknown and "None" or key.Name) .. "]"
				Btn.TextColor3 = GameSenseLib.Theme.DarkText
				Btn.Font = GameSenseLib.Theme.Font
				Btn.TextSize = 11
				Btn.Parent = Frame
				
				local KBItem = Instance.new("TextLabel")
				KBItem.Size = UDim2.new(1, -10, 0, 18)
				KBItem.BackgroundTransparency = 1
				KBItem.Font = GameSenseLib.Theme.Font
				KBItem.TextSize = 12
				KBItem.TextXAlignment = Enum.TextXAlignment.Left
				KBItem.Visible = false
				KBItem.Parent = KBContainer
				
				local bindData = {Name = opt.Name, Key = key, Mode = mode, Toggled = false, Label = KBItem}
				table.insert(GameSenseLib.Binds, bindData)
				
				local function Set(newKey)
					key = newKey
					bindData.Key = newKey
					Btn.Text = "[" .. (key == Enum.KeyCode.Unknown and "None" or key.Name) .. "]"
				end

				local listening = false
				
				Btn.MouseButton2Click:Connect(function()
					ClosePopups()
					PopupCatcher.Visible = true

					local relX = (Btn.AbsolutePosition.X - Main.AbsolutePosition.X) / uiScale.Scale
					local relY = (Btn.AbsolutePosition.Y - Main.AbsolutePosition.Y) / uiScale.Scale

					local Modes = {"Always", "Hold", "Toggle"}
					local DropContainer = Instance.new("Frame")
					DropContainer.Size = UDim2.new(0, 60, 0, #Modes * 18)
					DropContainer.Position = UDim2.new(0, relX, 0, relY + 18)
					DropContainer.BackgroundColor3 = GameSenseLib.Theme.MenuBg
					DropContainer.BorderColor3 = GameSenseLib.Theme.Outline
					DropContainer.ZIndex = 101
					DropContainer.Parent = PopupContainer
					local DropLayout = Instance.new("UIListLayout")
					DropLayout.Parent = DropContainer

					for _, m in ipairs(Modes) do
						local MBtn = Instance.new("TextButton")
						MBtn.Size = UDim2.new(1, 0, 0, 18)
						MBtn.BackgroundColor3 = GameSenseLib.Theme.MenuBg
						MBtn.BorderSizePixel = 0
						MBtn.Text = (bindData.Mode == m and "> " or "  ") .. m
						MBtn.TextColor3 = bindData.Mode == m and GameSenseLib.Theme.Accent or GameSenseLib.Theme.Text
						MBtn.Font = GameSenseLib.Theme.Font
						MBtn.TextSize = 11
						MBtn.TextXAlignment = Enum.TextXAlignment.Left
						MBtn.ZIndex = 102
						MBtn.Parent = DropContainer
						MBtn.MouseButton1Click:Connect(function() bindData.Mode = m ClosePopups() end)
					end
				end)

				Btn.MouseButton1Click:Connect(function() listening = true Btn.Text = "[...]" end)
				UserInputService.InputBegan:Connect(function(input, gpe)
					if listening and input.UserInputType == Enum.UserInputType.Keyboard then
						Set(input.KeyCode)
						listening = false
						if opt.OnKeyChange then pcall(opt.OnKeyChange, key) end
					elseif not listening and input.KeyCode == key and not gpe then
						if bindData.Mode == "Toggle" then bindData.Toggled = not bindData.Toggled end
						if opt.Callback then pcall(opt.Callback) end
					end
				end)

				return { Set = Set }
			end
			
			function SectionObj:AddColorpicker(opt)
				local h, s, v = Color3.toHSV(opt.Default or Color3.fromRGB(255,0,0))
				local Frame = Instance.new("Frame")
				Frame.Size = UDim2.new(1, 0, 0, 15)
				Frame.BackgroundTransparency = 1
				Frame.Parent = ItemContainer

				local Label = Instance.new("TextLabel")
				Label.Size = UDim2.new(1, -30, 1, 0)
				Label.BackgroundTransparency = 1
				Label.Text = opt.Name or "Color"
				Label.TextColor3 = GameSenseLib.Theme.Text
				Label.Font = GameSenseLib.Theme.Font
				Label.TextSize = 12
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.Parent = Frame

				local Btn = Instance.new("TextButton")
				Btn.Size = UDim2.new(0, 25, 0, 12)
				Btn.Position = UDim2.new(1, -25, 0.5, -6)
				Btn.BackgroundColor3 = Color3.fromHSV(h, s, v)
				Btn.BorderColor3 = GameSenseLib.Theme.Outline
				Btn.Text = ""
				Btn.Parent = Frame
				
				local function Set(clr)
					if type(clr) == "table" then h,s,v = clr[1],clr[2],clr[3] else h,s,v = Color3.toHSV(clr) end
					local c = Color3.fromHSV(h, s, v)
					Btn.BackgroundColor3 = c
					if opt.Flag then GameSenseLib.Flags[opt.Flag] = {h, s, v} end
					if opt.Callback then pcall(opt.Callback, c) end
				end

				Btn.MouseButton1Click:Connect(function()
					ClosePopups()
					PopupCatcher.Visible = true
					
					local relX = (Btn.AbsolutePosition.X - Main.AbsolutePosition.X) / uiScale.Scale
					local relY = (Btn.AbsolutePosition.Y - Main.AbsolutePosition.Y) / uiScale.Scale

					local Picker = Instance.new("Frame")
					Picker.Size = UDim2.new(0, 150, 0, 150)
					Picker.Position = UDim2.new(0, relX - 125, 0, relY + 15)
					Picker.BackgroundColor3 = GameSenseLib.Theme.MenuBg
					Picker.BorderColor3 = GameSenseLib.Theme.Outline
					Picker.ZIndex = 101
					Picker.Parent = PopupContainer

					local SVMap = Instance.new("TextButton")
					SVMap.Size = UDim2.new(0, 130, 0, 120)
					SVMap.Position = UDim2.new(0, 5, 0, 5)
					SVMap.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
					SVMap.BorderSizePixel = 0
					SVMap.Text = ""
					SVMap.AutoButtonColor = false
					SVMap.ZIndex = 102
					SVMap.Parent = Picker

					local WGrad = Instance.new("UIGradient", Instance.new("Frame", SVMap))
					WGrad.Parent.Size = UDim2.new(1,0,1,0) WGrad.Parent.BackgroundColor3 = Color3.new(1,1,1) WGrad.Parent.BorderSizePixel = 0 WGrad.Parent.ZIndex = 103
					WGrad.Color = ColorSequence.new(Color3.new(1,1,1), Color3.new(1,1,1)) WGrad.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0), NumberSequenceKeypoint.new(1,1)})
					
					local BGrad = Instance.new("UIGradient", Instance.new("Frame", SVMap))
					BGrad.Parent.Size = UDim2.new(1,0,1,0) BGrad.Parent.BackgroundColor3 = Color3.new(1,1,1) BGrad.Parent.BorderSizePixel = 0 BGrad.Parent.ZIndex = 104
					BGrad.Color = ColorSequence.new(Color3.new(0,0,0), Color3.new(0,0,0)) BGrad.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(1,0)}) BGrad.Rotation = 90

					local HueMap = Instance.new("TextButton")
					HueMap.Size = UDim2.new(0, 130, 0, 15)
					HueMap.Position = UDim2.new(0, 5, 0, 130)
					HueMap.BackgroundColor3 = Color3.new(1,1,1)
					HueMap.BorderSizePixel = 0
					HueMap.Text = ""
					HueMap.ZIndex = 102
					HueMap.Parent = Picker

					local HGrad = Instance.new("UIGradient")
					HGrad.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)), ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255, 255, 0)),
						ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
						ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0, 0, 255)), ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
					})
					HGrad.Parent = HueMap

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
				local Frame = Instance.new("Frame")
				Frame.Size = UDim2.new(1, 0, 0, 35)
				Frame.BackgroundTransparency = 1
				Frame.Parent = ItemContainer

				local Label = Instance.new("TextLabel")
				Label.Size = UDim2.new(1, 0, 0, 15)
				Label.BackgroundTransparency = 1
				Label.Text = opt.Name or "Textbox"
				Label.TextColor3 = GameSenseLib.Theme.Text
				Label.Font = GameSenseLib.Theme.Font
				Label.TextSize = 12
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.Parent = Frame

				local Box = Instance.new("TextBox")
				Box.Size = UDim2.new(1, 0, 0, 18)
				Box.Position = UDim2.new(0, 0, 0, 15)
				Box.BackgroundColor3 = GameSenseLib.Theme.DarkOutline
				Box.BorderColor3 = GameSenseLib.Theme.Outline
				Box.Text = val
				Box.TextColor3 = GameSenseLib.Theme.Text
				Box.Font = GameSenseLib.Theme.Font
				Box.TextSize = 12
				Box.ClearTextOnFocus = false
				Box.Parent = Frame
				
				local function Set(newVal)
					Box.Text = newVal
					if opt.Flag then GameSenseLib.Flags[opt.Flag] = newVal end
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
				local Btn = Instance.new("TextButton")
				Btn.Size = UDim2.new(1, 0, 0, 20)
				Btn.BackgroundColor3 = GameSenseLib.Theme.DarkOutline
				Btn.BorderColor3 = GameSenseLib.Theme.Outline
				Btn.Text = opt.Name or "Button"
				Btn.TextColor3 = GameSenseLib.Theme.Text
				Btn.Font = GameSenseLib.Theme.Font
				Btn.TextSize = 12
				Btn.Parent = ItemContainer
				Btn.MouseButton1Click:Connect(function() if opt.Callback then pcall(opt.Callback) end end)
			end

			function SectionObj:AddLabel(text)
				local Label = Instance.new("TextLabel")
				Label.Size = UDim2.new(1, 0, 0, 15)
				Label.BackgroundTransparency = 1
				Label.Text = text
				Label.TextColor3 = GameSenseLib.Theme.DarkText
				Label.Font = GameSenseLib.Theme.Font
				Label.TextSize = 12
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.Parent = ItemContainer
				return { Set = function(val) Label.Text = val end }
			end
			
			function SectionObj:AddParagraph(title, content)
				local Frame = Instance.new("Frame")
				Frame.Size = UDim2.new(1, 0, 0, 30)
				Frame.BackgroundTransparency = 1
				Frame.Parent = ItemContainer
				
				local T = Instance.new("TextLabel")
				T.Size = UDim2.new(1, 0, 0, 15)
				T.BackgroundTransparency = 1
				T.Text = title
				T.TextColor3 = GameSenseLib.Theme.Text
				T.Font = GameSenseLib.Theme.Font
				T.TextSize = 12
				T.TextXAlignment = Enum.TextXAlignment.Left
				T.Parent = Frame
				
				local C = Instance.new("TextLabel")
				C.Size = UDim2.new(1, 0, 0, 15)
				C.Position = UDim2.new(0, 0, 0, 15)
				C.BackgroundTransparency = 1
				C.Text = content
				C.TextColor3 = GameSenseLib.Theme.DarkText
				C.Font = GameSenseLib.Theme.Font
				C.TextSize = 12
				C.TextXAlignment = Enum.TextXAlignment.Left
				C.Parent = Frame

				return { Set = function(newTitle, newContent) T.Text = newTitle; C.Text = newContent end }
			end

			return SectionObj
		end
		return TabObj
	end

	-- BUILT-IN SETTINGS TAB
	local BuiltInSettings = WindowObj:MakeTab({ Name = "Settings", Icon = "rbxassetid://7734053495" })
	BuiltInSettings.TabBtn.LayoutOrder = 99999

	local UISec = BuiltInSettings:AddSection({ Name = "UI Settings", Side = "Left" })
	UISec:AddBind({ Name = "Menu Keybind", Default = Enum.KeyCode.Insert, OnKeyChange = function(key) GameSenseLib.MenuKey = key end })
	UISec:AddSlider({ Name = "UI Scale", Min = 50, Max = 150, Default = 100, ValueName = "%", Callback = function(val) uiScale.Scale = val / 100 end })

	local TrackerSec = BuiltInSettings:AddSection({ Name = "HUD Tracking", Side = "Right" })
	
	-- Connects to the Global Visibility Functions!
	TrackerSec:AddToggle({ 
		Name = "Watermark", 
		Default = true, 
		Callback = function(v) GameSenseLib:SetWatermarkVisibility(v) end 
	})
	
	TrackerSec:AddToggle({ 
		Name = "Keybinds List", 
		Default = true, 
		Callback = function(v) GameSenseLib:SetKeybindsVisibility(v) end 
	})

	function GameSenseLib:SaveConfig(filename)
		if not isfolder(self.ConfigFolder) then makefolder(self.ConfigFolder) end
		local saveTable = {}
		for flagName, flagValue in pairs(self.Flags) do
			if type(flagValue) == "boolean" or type(flagValue) == "number" or type(flagValue) == "string" or type(flagValue) == "table" then
				saveTable[flagName] = flagValue
			end
		end
		local success, encoded = pcall(function() return HttpService:JSONEncode(saveTable) end)
		if success then 
			writefile(self.ConfigFolder .. "/" .. tostring(game.PlaceId) .. "_" .. filename .. ".json", encoded)
			GameSenseLib:MakeNotification({Name = "Config Saved", Content = "Saved " .. filename .. " for this game.", Time = 3})
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
				GameSenseLib:MakeNotification({Name = "Config Loaded", Content = "Loaded " .. filename, Time = 3})
			end
		else
			GameSenseLib:MakeNotification({Name = "Error", Content = "Config not found for this game.", Time = 3})
		end
	end

	function GameSenseLib:Destroy() 
		if self.Gui then self.Gui:Destroy() end 
		if keybindConnection then keybindConnection:Disconnect() end
	end
	
	function GameSenseLib:Init() end

	return WindowObj
end

return GameSenseLib
