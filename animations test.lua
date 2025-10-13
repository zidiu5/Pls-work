--[[
ChatGPT-style GUI (schwarz + dunkelrot)
- Draggable MainFrame über gesamte Fläche
- Draggable OpenButton immer vorne
- Open/Close Animation mit Position Memory
- Tabs mit Slide-Animation
- Dropdowns, Buttons, Toggles, Inputs intakt
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- helper tween function
local function tween(inst, props, time, style, dir)
	style = style or Enum.EasingStyle.Quint
	dir = dir or Enum.EasingDirection.Out
	return TweenService:Create(inst, TweenInfo.new(time or 0.35, style, dir), props)
end

-- ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ChatGPTStyleGUI"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

-- OpenButton
local OpenButton = Instance.new("TextButton")
OpenButton.Name = "OpenButton"
OpenButton.Parent = ScreenGui
OpenButton.Size = UDim2.new(0,40,0,40)
OpenButton.Position = UDim2.new(1,-70,1,-70)
OpenButton.AnchorPoint = Vector2.new(0,0)
OpenButton.BackgroundColor3 = Color3.fromRGB(40,0,0)
OpenButton.BorderSizePixel = 0
OpenButton.Text = "☰"
OpenButton.Font = Enum.Font.GothamBold
OpenButton.TextSize = 22
OpenButton.TextColor3 = Color3.new(1,1,1)
OpenButton.AutoButtonColor = false
Instance.new("UICorner", OpenButton).CornerRadius = UDim.new(1,0)
OpenButton.ZIndex = 999

-- MainFrame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0,640,0,420)
MainFrame.Position = UDim2.new(0.5,-320,0.5,-210)
MainFrame.AnchorPoint = Vector2.new(0.5,0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0,12)
MainFrame.ZIndex = 1

-- Shadow
local Shadow = Instance.new("ImageLabel")
Shadow.Parent = MainFrame
Shadow.AnchorPoint = Vector2.new(0.5,0.5)
Shadow.Position = UDim2.new(0.5,0,0.5,6)
Shadow.Size = UDim2.new(1,40,1,40)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://1316045217"
Shadow.ImageTransparency = 0.8
Shadow.ZIndex = 0

-- Sidebar + Content
local Sidebar = Instance.new("Frame")
Sidebar.Parent = MainFrame
Sidebar.Size = UDim2.new(0,180,1,0)
Sidebar.Position = UDim2.new(0,0,0,0)
Sidebar.BackgroundColor3 = Color3.fromRGB(15,15,15)
Sidebar.BorderSizePixel = 0
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0,10)

local Content = Instance.new("Frame")
Content.Parent = MainFrame
Content.Size = UDim2.new(1,-180,1,0)
Content.Position = UDim2.new(0,180,0,0)
Content.BackgroundColor3 = Color3.fromRGB(10,10,10)
Content.BorderSizePixel = 0
Instance.new("UICorner", Content).CornerRadius = UDim.new(0,10)

-- Padding helper
local function addPadding(parent, l,t,r,b)
	local pad = Instance.new("UIPadding", parent)
	pad.PaddingLeft = UDim.new(0,l or 12)
	pad.PaddingTop = UDim.new(0,t or 12)
	pad.PaddingRight = UDim.new(0,r or 12)
	pad.PaddingBottom = UDim.new(0,b or 12)
	return pad
end
addPadding(Sidebar,12,12,12,12)
addPadding(Content,14,14,14,14)

-- TitleBar (optional for visual title)
local TitleBar = Instance.new("Frame")
TitleBar.Parent = MainFrame
TitleBar.Size = UDim2.new(1,0,0,36)
TitleBar.Position = UDim2.new(0,0,0,0)
TitleBar.BackgroundTransparency = 1
local Title = Instance.new("TextLabel", TitleBar)
Title.Size = UDim2.new(1,-12,1,0)
Title.Position = UDim2.new(0,12,0,0)
Title.BackgroundTransparency = 1
Title.Text = "Animated Test GUI"
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.new(1,1,1)
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Sidebar Scroll
local SidebarScroll = Instance.new("ScrollingFrame")
SidebarScroll.Parent = Sidebar
SidebarScroll.Size = UDim2.new(1,0,1,0)
SidebarScroll.Position = UDim2.new(0,0,0,36)
SidebarScroll.BackgroundTransparency = 1
SidebarScroll.BorderSizePixel = 0
SidebarScroll.ScrollBarThickness = 8
SidebarScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
SidebarScroll.VerticalScrollBarInset = Enum.ScrollBarInset.Always
local SBList = Instance.new("UIListLayout", SidebarScroll)
SBList.SortOrder = Enum.SortOrder.LayoutOrder
SBList.Padding = UDim.new(0,8)
SBList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function refreshSidebarCanvas()
	SidebarScroll.CanvasSize = UDim2.new(0,0,0,SBList.AbsoluteContentSize.Y + 12)
end
SBList.Changed:Connect(function(prop) if prop=="AbsoluteContentSize" then refreshSidebarCanvas() end end)
refreshSidebarCanvas()

-- Content Holder
local ContentHolder = Instance.new("Frame")
ContentHolder.Parent = Content
ContentHolder.Size = UDim2.new(1,0,1,0)
ContentHolder.BackgroundTransparency = 1
ContentHolder.ClipsDescendants = true

-- Tabs
local Tabs = {}
local TabOrder = {"Test Buttons","Toggles","Inputs","Extras","More1","More2","More3","More4","More5","More6"}
for index, name in ipairs(TabOrder) do
	local TabBtn = Instance.new("TextButton")
	TabBtn.Parent = SidebarScroll
	TabBtn.Size = UDim2.new(1,-24,0,40)
	TabBtn.BackgroundColor3 = Color3.fromRGB(25,25,25)
	TabBtn.BorderSizePixel = 0
	TabBtn.Text = name
	TabBtn.Font = Enum.Font.Gotham
	TabBtn.TextSize = 14
	TabBtn.TextColor3 = Color3.fromRGB(200,50,50)
	TabBtn.AutoButtonColor = false
	Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0,8)
	TabBtn.MouseEnter:Connect(function() tween(TabBtn,{BackgroundColor3=Color3.fromRGB(40,0,0)},0.18):Play() end)
	TabBtn.MouseLeave:Connect(function() tween(TabBtn,{BackgroundColor3=Color3.fromRGB(25,25,25)},0.18):Play() end)

	local TabFrame = Instance.new("Frame")
	TabFrame.Parent = ContentHolder
	TabFrame.Size = UDim2.new(1,0,1,0)
	TabFrame.Position = UDim2.new((index-1),0,0,0)
	TabFrame.BackgroundTransparency = 1
	TabFrame.ClipsDescendants = true

	local InnerScroll = Instance.new("ScrollingFrame")
	InnerScroll.Parent = TabFrame
	InnerScroll.Size = UDim2.new(1,0,1,0)
	InnerScroll.BackgroundTransparency = 1
	InnerScroll.BorderSizePixel = 0
	InnerScroll.ScrollBarThickness = 8
	InnerScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	InnerScroll.VerticalScrollBarInset = Enum.ScrollBarInset.Always
	local InnerList = Instance.new("UIListLayout", InnerScroll)
	InnerList.SortOrder = Enum.SortOrder.LayoutOrder
	InnerList.Padding = UDim.new(0,10)
	InnerList.HorizontalAlignment = Enum.HorizontalAlignment.Center

	Tabs[index] = {Name=name, Button=TabBtn, Frame=TabFrame, InnerScroll=InnerScroll}
end

-- Tab Switching
local currentIndex = 1
local animating = false
local function switchToIndex(newIndex)
	if newIndex==currentIndex or animating then return end
	animating=true
	local oldTab = Tabs[currentIndex].Frame
	local newTab = Tabs[newIndex].Frame
	oldTab.Visible=true
	newTab.Visible=true
	oldTab.Position=UDim2.new(0,0,0,0)
	newTab.Position=UDim2.new(1,0,0,0)
	local tweenOut=TweenService:Create(oldTab,TweenInfo.new(0.35,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Position=UDim2.new(-1,0,0,0)})
	local tweenIn=TweenService:Create(newTab,TweenInfo.new(0.35,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Position=UDim2.new(0,0,0,0)})
	tweenOut:Play()
	tweenIn:Play()
	tweenIn.Completed:Connect(function()
		oldTab.Visible=false
		oldTab.Position=UDim2.new(0,0,0,0)
		animating=false
	end)
	tween(Tabs[currentIndex].Button,{BackgroundColor3=Color3.fromRGB(25,25,25)},0.18):Play()
	tween(Tabs[newIndex].Button,{BackgroundColor3=Color3.fromRGB(40,0,0)},0.18):Play()
	currentIndex=newIndex
end
for i,t in ipairs(Tabs) do
	t.Button.MouseButton1Click:Connect(function() switchToIndex(i) end)
end

-- OPEN/CLOSE LOGIC
local guiVisible = false
local lastPosition = MainFrame.Position
local function openGUI()
	if guiVisible then return end
	guiVisible=true
	MainFrame.Visible=true
	MainFrame.Position=lastPosition
	MainFrame.Size=UDim2.new(0,0,0,0)
	MainFrame.BackgroundTransparency=1
	tween(MainFrame,{Size=UDim2.new(0,640,0,420), BackgroundTransparency=0},0.4):Play()
end
local function closeGUI()
	if not guiVisible then return end
	guiVisible=false
	lastPosition=MainFrame.Position
	local tw=tween(MainFrame,{Size=UDim2.new(0,0,0,0),BackgroundTransparency=1},0.35)
	tw:Play()
	tw.Completed:Wait()
	MainFrame.Visible=false
end
OpenButton.MouseButton1Click:Connect(function()
	if guiVisible then closeGUI() else openGUI() end
end)

-- DRAG MAINFRAME (volle Fläche)
local dragging=false
local dragStartPos, dragStartFramePos
local function startDrag(input)
	dragging=true
	dragStartPos=input.Position
	dragStartFramePos=MainFrame.Position
	input.Changed:Connect(function()
		if input.UserInputState==Enum.UserInputState.End then
			dragging=false
			lastPosition=MainFrame.Position
		end
	end)
end
local function dragUpdate(input)
	if dragging then
		local delta=input.Position - dragStartPos
		MainFrame.Position=UDim2.new(
			dragStartFramePos.X.Scale, dragStartFramePos.X.Offset + delta.X,
			dragStartFramePos.Y.Scale, dragStartFramePos.Y.Offset + delta.Y
		)
	end
end
MainFrame.InputBegan:Connect(function(input)
	if input.UserInputType==Enum.UserInputType.MouseButton1 then startDrag(input) end
end)
MainFrame.InputChanged:Connect(dragUpdate)

-- DRAG OpenButton
local obDragging=false
local obStartPos, obStart
OpenButton.InputBegan:Connect(function(input)
	if input.UserInputType==Enum.UserInputType.MouseButton1 then
		obDragging=true
		obStart=input.Position
		obStartPos=OpenButton.Position
		input.Changed:Connect(function()
			if input.UserInputState==Enum.UserInputState.End then obDragging=false end
		end)
	end
end)
OpenButton.InputChanged:Connect(function(input)
	if obDragging then
		local delta=input.Position-obStart
		OpenButton.Position=UDim2.new(
			obStartPos.X.Scale, obStartPos.X.Offset + delta.X,
			obStartPos.Y.Scale, obStartPos.Y.Offset + delta.Y
		)
	end
end)

print("ChatGPT-style GUI fully loaded and draggable!")
