local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Clean up existing Cyanide UI if re-executed
local ParentTarget = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
if ParentTarget:FindFirstChild("CyanideWin11UI") then
    ParentTarget.CyanideWin11UI:Destroy()
end

-- ==========================================
-- Lightweight Configuration State
-- ==========================================
local ColorPresets = {
    ["Win11 Blue"] = Color3.fromRGB(96, 205, 255),
    ["Crimson"]    = Color3.fromRGB(255, 85, 95),
    ["Emerald"]    = Color3.fromRGB(72, 225, 145),
    ["Amber"]      = Color3.fromRGB(255, 195, 75),
    ["Pure White"] = Color3.fromRGB(245, 245, 245),
}

local Config = {
    Combat = {
        LockOn = false,
        LockOnSmooth = 0.20,
        BlatantLockOn = false,
        BlatantSmooth = 0.05,
        AimMode = "Camera",       -- "Camera" or "Mouse"
        AimCurve = "Neutral",     -- "Linear", "Exponential", or "Neutral"
        BodyPart = "Head",
        TeamCheck = false,
        WallCheck = false,
        SpinYaw = false,
        SpinSpeed = 25,
    },
    ESP = {
        Boxes = true,
        FillBoxes = false,
        HealthBar = true,
        Tracers = false,
        Highlights = false,
        Tags = true,
        TeamCheck = false,
        UseTeamColor = false,
        AccentColor = ColorPresets["Win11 Blue"],
        MaxDistance = 500,
    },
    Visuals = {
        ShowFOV = false,
        FOVRadius = 140,
        CameraFOV = 70,
        Fullbright = false,
    },
    Misc = {
        WalkSpeed = 16,
        JumpPower = 50,
        FPSBoost = false,
    }
}

local Connections = {}
local ActiveDropdownClose = nil

-- Windows 11 Dark Mica & Fluent 2 Palette
local Theme = {
    MicaBase       = Color3.fromRGB(32, 32, 32),
    SidebarBg      = Color3.fromRGB(28, 28, 28),
    LayerBg        = Color3.fromRGB(39, 39, 39),
    CardBg         = Color3.fromRGB(45, 45, 45),
    CardHover      = Color3.fromRGB(54, 54, 54),
    InputBg        = Color3.fromRGB(33, 33, 33),
    PopupBg        = Color3.fromRGB(42, 42, 44),
    Border         = Color3.fromRGB(58, 58, 58),
    BorderTop      = Color3.fromRGB(76, 76, 76),
    WinBlue        = Color3.fromRGB(0, 120, 212),
    WinAccent      = Color3.fromRGB(96, 205, 255),
    WinAccentHover = Color3.fromRGB(76, 194, 245),
    CloseRed       = Color3.fromRGB(196, 43, 28),
    TextPrimary    = Color3.fromRGB(255, 255, 255),
    TextSecondary  = Color3.fromRGB(205, 205, 205),
    TextMuted      = Color3.fromRGB(140, 140, 140),
}

local FluentTween = TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local QuickTween  = TweenInfo.new(0.11, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function Create(className, props, children)
    local inst = Instance.new(className)
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    for _, child in ipairs(children or {}) do
        child.Parent = inst
    end
    return inst
end

-- Custom Vector Icon Builder
local function BuildTabIcon(parent, iconType)
    local Holder = Create("Frame", {
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(0, 13, 0.5, -9),
        BackgroundTransparency = 1,
        Parent = parent
    })

    local colorParts = {}

    if iconType == "SniperScope" then
        local Ring = Create("Frame", {
            Size = UDim2.new(0, 14, 0, 14),
            Position = UDim2.new(0.5, -7, 0.5, -7),
            BackgroundTransparency = 1,
            Parent = Holder
        }, { Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })
        local RingStroke = Create("UIStroke", { Color = Theme.TextSecondary, Thickness = 1.4, Parent = Ring })
        table.insert(colorParts, { obj = RingStroke, prop = "Color" })

        local Dot = Create("Frame", {
            Size = UDim2.new(0, 2, 0, 2),
            Position = UDim2.new(0.5, -1, 0.5, -1),
            BackgroundColor3 = Theme.TextSecondary,
            BorderSizePixel = 0,
            Parent = Holder
        }, { Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })
        table.insert(colorParts, { obj = Dot, prop = "BackgroundColor3" })

        local ticks = {
            { Size = UDim2.new(0, 1.5, 0, 4), Pos = UDim2.new(0.5, -0.75, 0, 0) },
            { Size = UDim2.new(0, 1.5, 0, 4), Pos = UDim2.new(0.5, -0.75, 1, -4) },
            { Size = UDim2.new(0, 4, 0, 1.5), Pos = UDim2.new(0, 0, 0.5, -0.75) },
            { Size = UDim2.new(0, 4, 0, 1.5), Pos = UDim2.new(1, -4, 0.5, -0.75) },
        }
        for _, t in ipairs(ticks) do
            local line = Create("Frame", {
                Size = t.Size,
                Position = t.Pos,
                BackgroundColor3 = Theme.TextSecondary,
                BorderSizePixel = 0,
                Parent = Holder
            })
            table.insert(colorParts, { obj = line, prop = "BackgroundColor3" })
        end

    elseif iconType == "RectangleBox" then
        local Box = Create("Frame", {
            Size = UDim2.new(0, 14, 0, 11),
            Position = UDim2.new(0.5, -7, 0.5, -5.5),
            BackgroundTransparency = 1,
            Parent = Holder
        }, { Create("UICorner", { CornerRadius = UDim.new(0, 2) }) })
        local BoxStroke = Create("UIStroke", { Color = Theme.TextSecondary, Thickness = 1.5, Parent = Box })
        table.insert(colorParts, { obj = BoxStroke, prop = "Color" })

    else
        local Glyph = Create("TextLabel", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = iconType or "•",
            TextColor3 = Theme.TextSecondary,
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            Parent = Holder
        })
        table.insert(colorParts, { obj = Glyph, prop = "TextColor3" })
    end

    return function(newColor)
        for _, item in ipairs(colorParts) do
            item.obj[item.prop] = newColor
        end
    end
end

-- ==========================================
-- Main ScreenGui & Overlay Layers
-- ==========================================
local ScreenGui = Create("ScreenGui", {
    Name = "CyanideWin11UI",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = ParentTarget
})

local OverlayLayer = Create("Frame", {
    Name = "OverlayLayer",
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    ZIndex = 1,
    Parent = ScreenGui
})

local FOVCircle = Create("Frame", {
    Name = "FOVCircle",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(0, Config.Visuals.FOVRadius * 2, 0, Config.Visuals.FOVRadius * 2),
    BackgroundTransparency = 1,
    Visible = false,
    Parent = OverlayLayer
}, {
    Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
    Create("UIStroke", { Color = Theme.WinAccent, Thickness = 1.2, Transparency = 0.25 })
})

local PopupLayer = Create("Frame", {
    Name = "PopupLayer",
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    ZIndex = 50,
    Parent = ScreenGui
})

local DefaultSize = UDim2.new(0, 760, 0, 500)
local ExpandedSize = UDim2.new(0, 880, 0, 560)

local MainWindow = Create("Frame", {
    Name = "CyanideWindow",
    Size = DefaultSize,
    Position = UDim2.new(0.5, -380, 0.5, -250),
    BackgroundColor3 = Theme.MicaBase,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    ZIndex = 10,
    Parent = ScreenGui
}, {
    Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
    Create("UIStroke", { Color = Theme.BorderTop, Thickness = 1, Transparency = 0.2 }),
    Create("UIGradient", {
        Rotation = 120,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(38, 40, 44)),
            ColorSequenceKeypoint.new(0.45, Color3.fromRGB(32, 32, 32)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(27, 27, 28))
        })
    })
})

-- ==========================================
-- Windows 11 Title Bar
-- ==========================================
local TitleBar = Create("Frame", {
    Name = "TitleBar",
    Size = UDim2.new(1, 0, 0, 38),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Parent = MainWindow
})

Create("Frame", {
    Size = UDim2.new(0, 18, 0, 18),
    Position = UDim2.new(0, 14, 0.5, -9),
    BackgroundColor3 = Theme.WinBlue,
    Parent = TitleBar
}, {
    Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
    Create("UIGradient", {
        Rotation = 45,
        Color = ColorSequence.new(Theme.WinAccent, Theme.WinBlue)
    }),
    Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "✦",
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold,
        TextSize = 11
    })
})

Create("TextLabel", {
    Size = UDim2.new(0, 200, 1, 0),
    Position = UDim2.new(0, 40, 0, 0),
    BackgroundTransparency = 1,
    Text = "Cyanide",
    TextColor3 = Theme.TextPrimary,
    Font = Enum.Font.GothamMedium,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = TitleBar
})

local Controls = Create("Frame", {
    Size = UDim2.new(0, 138, 1, 0),
    Position = UDim2.new(1, -138, 0, 0),
    BackgroundTransparency = 1,
    Parent = TitleBar
})

local function MakeCaptionBtn(xOffset, symbol, hoverBg, hoverText)
    local btn = Create("TextButton", {
        Size = UDim2.new(0, 46, 1, 0),
        Position = UDim2.new(0, xOffset, 0, 0),
        BackgroundColor3 = hoverBg,
        BackgroundTransparency = 1,
Text = symbol,
TextColor3 = Theme.TextSecondary,
Font = Enum.Font.Gotham,
TextSize = 12,
AutoButtonColor = false,
Parent = Controls
})
btn.MouseEnter:Connect(function()
TweenService:Create(btn, QuickTween, { BackgroundTransparency = 0, TextColor3 = hoverText }):Play()
end)
btn.MouseLeave:Connect(function()
TweenService:Create(btn, QuickTween, { BackgroundTransparency = 1, TextColor3 = Theme.TextSecondary }):Play()
end)
return btn
end
local MinimizeBtn = MakeCaptionBtn(0, "—", Theme.CardHover, Theme.TextPrimary)
local ExpandBtn   = MakeCaptionBtn(46, "▢", Theme.CardHover, Theme.TextPrimary)
local CloseBtn    = MakeCaptionBtn(92, "✕", Theme.CloseRed, Color3.new(1, 1, 1))
local dragging, dragInput, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
if ActiveDropdownClose then ActiveDropdownClose() end
dragging = true
dragStart = input.Position
startPos = MainWindow.Position
input.Changed:Connect(function()
if input.UserInputState == Enum.UserInputState.End then
dragging = false
end
end)
end
end)
TitleBar.InputChanged:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
dragInput = input
end
end)
table.insert(Connections, UserInputService.InputChanged:Connect(function(input)
if input == dragInput and dragging then
local delta = input.Position - dragStart
MainWindow.Position = UDim2.new(
startPos.X.Scale, startPos.X.Offset + delta.X,
startPos.Y.Scale, startPos.Y.Offset + delta.Y
)
end
end))
local isMinimized = false
local isExpanded = false
MinimizeBtn.MouseButton1Click:Connect(function()
if ActiveDropdownClose then ActiveDropdownClose() end
isMinimized = not isMinimized
local target = isMinimized and UDim2.new(0, MainWindow.Size.X.Offset, 0, 38) or (isExpanded and ExpandedSize or DefaultSize)
TweenService:Create(MainWindow, FluentTween, { Size = target }):Play()
end)
ExpandBtn.MouseButton1Click:Connect(function()
if ActiveDropdownClose then ActiveDropdownClose() end
isMinimized = false
isExpanded = not isExpanded
local target = isExpanded and ExpandedSize or DefaultSize
TweenService:Create(MainWindow, FluentTween, { Size = target }):Play()
end)
-- ==========================================
-- Left Navigation Pane
-- ==========================================
local Sidebar = Create("Frame", {
Name = "Sidebar",
Size = UDim2.new(0, 205, 1, -38),
Position = UDim2.new(0, 0, 0, 38),
BackgroundTransparency = 1,
BorderSizePixel = 0,
Parent = MainWindow
})
local ProfileRow = Create("Frame", {
Size = UDim2.new(1, -20, 0, 44),
Position = UDim2.new(0, 10, 0, 4),
BackgroundTransparency = 1,
Parent = Sidebar
})
local AvatarFrame = Create("Frame", {
Size = UDim2.new(0, 34, 0, 34),
Position = UDim2.new(0, 3, 0.5, -17),
BackgroundColor3 = Theme.CardBg,
ClipsDescendants = true,
Parent = ProfileRow
}, {
Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
Create("UIStroke", { Color = Theme.WinAccent, Thickness = 1.2, Transparency = 0.25 })
})
local AvatarImage = Create("ImageLabel", {
Size = UDim2.new(1, 0, 1, 0),
BackgroundTransparency = 1,
Image = "",
ScaleType = Enum.ScaleType.Crop,
Parent = AvatarFrame
}, { Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })
local AvatarFallback = Create("TextLabel", {
Size = UDim2.new(1, 0, 1, 0),
BackgroundTransparency = 1,
Text = LocalPlayer and string.sub(LocalPlayer.DisplayName, 1, 1):upper() or "M",
TextColor3 = Theme.TextPrimary,
Font = Enum.Font.GothamBold,
TextSize = 14,
Parent = AvatarFrame
})
task.spawn(function()
if LocalPlayer then
local ok, content, isReady = pcall(function()
return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
end)
if ok and isReady and content then
AvatarImage.Image = content
AvatarFallback.Visible = false
end
end
end)
Create("TextLabel", {
Size = UDim2.new(1, -46, 0, 18),
Position = UDim2.new(0, 44, 0, 5),
BackgroundTransparency = 1,
Text = LocalPlayer and LocalPlayer.DisplayName or "Cyanide User",
TextColor3 = Theme.TextPrimary,
Font = Enum.Font.GothamSemibold,
TextSize = 12,
TextXAlignment = Enum.TextXAlignment.Left,
TextTruncate = Enum.TextTruncate.AtEnd,
Parent = ProfileRow
})
Create("TextLabel", {
Size = UDim2.new(1, -46, 0, 15),
Position = UDim2.new(0, 44, 0, 22),
BackgroundTransparency = 1,
Text = LocalPlayer and ("@" .. LocalPlayer.Name) or "Fluent 2 • Active",
TextColor3 = Theme.TextMuted,
Font = Enum.Font.Gotham,
TextSize = 11,
TextXAlignment = Enum.TextXAlignment.Left,
TextTruncate = Enum.TextTruncate.AtEnd,
Parent = ProfileRow
})
local SearchWrapper = Create("Frame", {
Size = UDim2.new(1, -20, 0, 30),
Position = UDim2.new(0, 10, 0, 54),
BackgroundColor3 = Theme.InputBg,
Parent = Sidebar
}, {
Create("UICorner", { CornerRadius = UDim.new(0, 5) }),
Create("UIStroke", { Color = Theme.Border, Thickness = 1 })
})
local SearchAccentLine = Create("Frame", {
Size = UDim2.new(1, -2, 0, 2),
Position = UDim2.new(0, 1, 1, -2),
BackgroundColor3 = Theme.TextMuted,
BorderSizePixel = 0,
Parent = SearchWrapper
}, { Create("UICorner", { CornerRadius = UDim.new(0, 2) }) })
local SearchBox = Create("TextBox", {
Size = UDim2.new(1, -30, 1, 0),
Position = UDim2.new(0, 10, 0, 0),
BackgroundTransparency = 1,
PlaceholderText = "Find a setting",
PlaceholderColor3 = Theme.TextMuted,
Text = "",
TextColor3 = Theme.TextPrimary,
Font = Enum.Font.Gotham,
TextSize = 12,
TextXAlignment = Enum.TextXAlignment.Left,
ClearTextOnFocus = false,
Parent = SearchWrapper
})
Create("TextLabel", {
Size = UDim2.new(0, 24, 1, 0),
Position = UDim2.new(1, -24, 0, 0),
BackgroundTransparency = 1,
Text = "⌕",
TextColor3 = Theme.TextSecondary,
Font = Enum.Font.Gotham,
TextSize = 14,
Parent = SearchWrapper
})
SearchBox.Focused:Connect(function()
TweenService:Create(SearchAccentLine, QuickTween, { BackgroundColor3 = Theme.WinAccent }):Play()
end)
SearchBox.FocusLost:Connect(function()
TweenService:Create(SearchAccentLine, QuickTween, { BackgroundColor3 = Theme.TextMuted }):Play()
end)
local TabList = Create("Frame", {
Size = UDim2.new(1, 0, 1, -134),
Position = UDim2.new(0, 0, 0, 92),
BackgroundTransparency = 1,
Parent = Sidebar
}, {
Create("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }),
Create("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) })
})
local SidebarFooter = Create("Frame", {
Size = UDim2.new(1, -20, 0, 30),
Position = UDim2.new(0, 10, 1, -38),
BackgroundColor3 = Theme.CardBg,
BackgroundTransparency = 0.4,
Parent = Sidebar
}, {
Create("UICorner", { CornerRadius = UDim.new(0, 5) }),
Create("UIStroke", { Color = Theme.Border, Thickness = 1 }),
Create("TextLabel", {
Size = UDim2.new(1, -14, 1, 0),
Position = UDim2.new(0, 10, 0, 0),
BackgroundTransparency = 1,
Text = "Toggle Key: RightShift",
TextColor3 = Theme.TextMuted,
Font = Enum.Font.GothamMedium,
TextSize = 11,
TextXAlignment = Enum.TextXAlignment.Left
})
})
-- ==========================================
-- Right Content Layer
-- ==========================================
local ContentLayer = Create("Frame", {
Name = "ContentLayer",
Size = UDim2.new(1, -205, 1, -38),
Position = UDim2.new(0, 205, 0, 38),
BackgroundColor3 = Theme.LayerBg,
BorderSizePixel = 0,
Parent = MainWindow
}, {
Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
Create("UIStroke", { Color = Theme.Border, Thickness = 1 })
})
local BreadcrumbBar = Create("Frame", {
Size = UDim2.new(1, 0, 0, 46),
BackgroundTransparency = 1,
Parent = ContentLayer
})
local BreadcrumbLabel = Create("TextLabel", {
Size = UDim2.new(1, -36, 1, 0),
Position = UDim2.new(0, 22, 0, 4),
BackgroundTransparency = 1,
Text = "Combat",
TextColor3 = Theme.TextPrimary,
Font = Enum.Font.GothamBold,
TextSize = 20,
TextXAlignment = Enum.TextXAlignment.Left,
Parent = BreadcrumbBar
})
local PageContainer = Create("Frame", {
Size = UDim2.new(1, 0, 1, -48),
Position = UDim2.new(0, 0, 0, 48),
BackgroundTransparency = 1,
Parent = ContentLayer
})
-- ==========================================
-- Tab & Fluent Component Builder
-- ==========================================
local Tabs = {}
local ActiveTab = nil
local function CreateTab(tabName, iconType)
local TabButton = Create("TextButton", {
Name = tabName .. "Tab",
Size = UDim2.new(1, 0, 0, 36),
BackgroundColor3 = Theme.CardBg,
BackgroundTransparency = 1,
Text = "",
AutoButtonColor = false,
Parent = TabList
}, { Create("UICorner", { CornerRadius = UDim.new(0, 5) }) })
local Indicator = Create("Frame", {
Name = "Indicator",
Size = UDim2.new(0, 3, 0, 16),
Position = UDim2.new(0, 2, 0.5, -8),
BackgroundColor3 = Theme.WinAccent,
BorderSizePixel = 0,
Visible = false,
Parent = TabButton
}, { Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })
local SetIconColor = BuildTabIcon(TabButton, iconType)
local Label = Create("TextLabel", {
Size = UDim2.new(1, -40, 1, 0),
Position = UDim2.new(0, 38, 0, 0),
BackgroundTransparency = 1,
Text = tabName,
TextColor3 = Theme.TextSecondary,
Font = Enum.Font.GothamMedium,
TextSize = 13,
TextXAlignment = Enum.TextXAlignment.Left,
Parent = TabButton
})
local Page = Create("ScrollingFrame", {
Name = tabName .. "Page",
Size = UDim2.new(1, 0, 1, 0),
BackgroundTransparency = 1,
BorderSizePixel = 0,
ScrollBarThickness = 3,
ScrollBarImageColor3 = Theme.BorderTop,
CanvasSize = UDim2.new(0, 0, 0, 0),
AutomaticCanvasSize = Enum.AutomaticSize.Y,
Visible = false,
Parent = PageContainer
}, {
Create("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }),
Create("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 16), PaddingLeft = UDim.new(0, 22), PaddingRight = UDim.new(0, 22) })
})
Page:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
if ActiveDropdownClose then ActiveDropdownClose() end
end)
local tabObj = {
Name = tabName,
Button = TabButton,
Indicator = Indicator,
Label = Label,
SetIconColor = SetIconColor,
Page = Page,
SearchableCards = {}
}
local function Select()
if ActiveDropdownClose then ActiveDropdownClose() end
for _, t in pairs(Tabs) do
t.Page.Visible = false
t.Indicator.Visible = false
TweenService:Create(t.Button, QuickTween, { BackgroundTransparency = 1 }):Play()
t.Label.TextColor3 = Theme.TextSecondary
t.SetIconColor(Theme.TextSecondary)
end
Page.Visible = true
Indicator.Visible = true
TweenService:Create(TabButton, QuickTween, { BackgroundTransparency = 0 }):Play()
Label.TextColor3 = Theme.TextPrimary
SetIconColor(Theme.WinAccent)
BreadcrumbLabel.Text = tabName
ActiveTab = tabObj
end
TabButton.MouseEnter:Connect(function()
if not Page.Visible then
TweenService:Create(TabButton, QuickTween, { BackgroundTransparency = 0.55 }):Play()
end
end)
TabButton.MouseLeave:Connect(function()
if not Page.Visible then
TweenService:Create(TabButton, QuickTween, { BackgroundTransparency = 1 }):Play()
end
end)
TabButton.MouseButton1Click:Connect(Select)
table.insert(Tabs, tabObj)
if #Tabs == 1 then
Select()
end
local Elements = {}
function Elements:AddSection(title)
local sec = Create("TextLabel", {
Size = UDim2.new(1, 0, 0, 22),
BackgroundTransparency = 1,
Text = title,
TextColor3 = Theme.TextSecondary,
Font = Enum.Font.GothamSemibold,
TextSize = 12,
TextXAlignment = Enum.TextXAlignment.Left,
Parent = Page
})
table.insert(tabObj.SearchableCards, { inst = sec, keyword = string.lower(title) })
end
function Elements:AddToggle(title, subtitle, default, callback)
local state = default or false
local hasSub = subtitle ~= nil and subtitle ~= ""
local Card = Create("TextButton", {
Size = UDim2.new(1, 0, 0, hasSub and 50 or 40),
BackgroundColor3 = Theme.CardBg,
Text = "",
AutoButtonColor = false,
Parent = Page
}, {
Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
Create("UIStroke", { Color = Theme.Border, Thickness = 1 }),
Create("TextLabel", {
Size = UDim2.new(1, -100, 0, 18),
Position = UDim2.new(0, 14, 0, hasSub and 7 or 11),
BackgroundTransparency = 1,
Text = title,
TextColor3 = Theme.TextPrimary,
Font = Enum.Font.GothamMedium,
TextSize = 13,
TextXAlignment = Enum.TextXAlignment.Left
})
})
if hasSub then
Create("TextLabel", {
Size = UDim2.new(1, -100, 0, 15),
Position = UDim2.new(0, 14, 0, 27),
BackgroundTransparency = 1,
Text = subtitle,
TextColor3 = Theme.TextMuted,
Font = Enum.Font.Gotham,
TextSize = 11,
TextXAlignment = Enum.TextXAlignment.Left,
Parent = Card
})
end
local StatusText = Create("TextLabel", {
Size = UDim2.new(0, 28, 1, 0),
Position = UDim2.new(1, -86, 0, 0),
BackgroundTransparency = 1,
Text = state and "On" or "Off",
TextColor3 = Theme.TextSecondary,
Font = Enum.Font.Gotham,
TextSize = 12,
TextXAlignment = Enum.TextXAlignment.Right,
Parent = Card
})
local SwitchTrack = Create("Frame", {
Size = UDim2.new(0, 40, 0, 20),
Position = UDim2.new(1, -52, 0.5, -10),
BackgroundColor3 = state and Theme.WinAccent or Theme.InputBg,
Parent = Card
}, {
Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
Create("UIStroke", { Color = state and Theme.WinAccent or Theme.TextMuted, Thickness = 1 })
})
local SwitchKnob = Create("Frame", {
Size = UDim2.new(0, 12, 0, 12),
Position = state and UDim2.new(1, -16, 0.5, -6) or UDim2.new(0, 4, 0.5, -6),
BackgroundColor3 = state and Theme.SidebarBg or Theme.TextSecondary,
Parent = SwitchTrack
}, { Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })
Card.MouseEnter:Connect(function()
TweenService:Create(Card, QuickTween, { BackgroundColor3 = Theme.CardHover }):Play()
end)
Card.MouseLeave:Connect(function()
TweenService:Create(Card, QuickTween, { BackgroundColor3 = Theme.CardBg }):Play()
end)
Card.MouseButton1Click:Connect(function()
state = not state
StatusText.Text = state and "On" or "Off"
TweenService:Create(SwitchTrack, FluentTween, {
BackgroundColor3 = state and Theme.WinAccent or Theme.InputBg
}):Play()
TweenService:Create(SwitchTrack:FindFirstChildOfClass("UIStroke"), FluentTween, {
Color = state and Theme.WinAccent or Theme.TextMuted
}):Play()
TweenService:Create(SwitchKnob, FluentTween, {
Position = state and UDim2.new(1, -16, 0.5, -6) or UDim2.new(0, 4, 0.5, -6),
BackgroundColor3 = state and Theme.SidebarBg or Theme.TextSecondary
}):Play()
if callback then callback(state) end
end)
table.insert(tabObj.SearchableCards, { inst = Card, keyword = string.lower(title .. " " .. (subtitle or "")) })
end
function Elements:AddSlider(title, min, max, default, decimals, suffix, callback)
local dec = decimals or 0
local mult = 10 ^ dec
local value = math.clamp(default or min, min, max)
local Card = Create("Frame", {
Size = UDim2.new(1, 0, 0, 54),
BackgroundColor3 = Theme.CardBg,
Parent = Page
}, {
Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
Create("UIStroke", { Color = Theme.Border, Thickness = 1 })
})
Create("TextLabel", {
Size = UDim2.new(1, -95, 0, 22),
Position = UDim2.new(0, 14, 0, 5),
BackgroundTransparency = 1,
Text = title,
TextColor3 = Theme.TextPrimary,
Font = Enum.Font.GothamMedium,
TextSize = 13,
TextXAlignment = Enum.TextXAlignment.Left,
Parent = Card
})
local ValuePill = Create("Frame", {
Size = UDim2.new(0, 60, 0, 20),
Position = UDim2.new(1, -74, 0, 6),
BackgroundColor3 = Theme.InputBg,
Parent = Card
}, {
Create("UICorner", { CornerRadius = UDim.new(0, 5) }),
Create("UIStroke", { Color = Theme.Border, Thickness = 1 })
})
local ValueLabel = Create("TextLabel", {
Size = UDim2.new(1, 0, 1, 0),
BackgroundTransparency = 1,
Text = string.format("%." .. dec .. "f", value) .. (suffix or ""),
TextColor3 = Theme.WinAccent,
Font = Enum.Font.GothamSemibold,
TextSize = 11,
Parent = ValuePill
})
local Track = Create("TextButton", {
Size = UDim2.new(1, -28, 0, 4),
Position = UDim2.new(0, 14, 0, 38),
BackgroundColor3 = Theme.TextMuted,
Text = "",
AutoButtonColor = false,
Parent = Card
}, { Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })
local pct = (value - min) / (max - min)
local Fill = Create("Frame", {
Size = UDim2.new(pct, 0, 1, 0),
BackgroundColor3 = Theme.WinAccent,
Parent = Track
}, { Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })
local ThumbOuter = Create("Frame", {
Size = UDim2.new(0, 14, 0, 14),
Position = UDim2.new(1, -7, 0.5, -7),
BackgroundColor3 = Theme.CardHover,
Parent = Fill
}, {
Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
Create("UIStroke", { Color = Theme.BorderTop, Thickness = 1 }),
Create("Frame", {
Size = UDim2.new(0, 6, 0, 6),
Position = UDim2.new(0.5, -3, 0.5, -3),
BackgroundColor3 = Theme.WinAccent
}, { Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })
})
local sliding = false
local function UpdateSlider(input)
local relX = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
Fill.Size = UDim2.new(relX, 0, 1, 0)
local raw = min + (max - min) * relX
local rounded = math.floor(raw * mult + 0.5) / mult
ValueLabel.Text = string.format("%." .. dec .. "f", rounded) .. (suffix or "")
if callback then callback(rounded) end
end
Track.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 then
sliding = true
TweenService:Create(ThumbOuter, QuickTween, { Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(1, -8, 0.5, -8) }):Play()
UpdateSlider(input)
end
end)
table.insert(Connections, UserInputService.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 and sliding then
sliding = false
TweenService:Create(ThumbOuter, QuickTween, { Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(1, -7, 0.5, -7) }):Play()
end
end))
table.insert(Connections, UserInputService.InputChanged:Connect(function(input)
if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
UpdateSlider(input)
end
end))
table.insert(tabObj.SearchableCards, { inst = Card, keyword = string.lower(title) })
end
function Elements:AddDropdown(title, options, defaultOption, callback)
local selected = defaultOption or options or "Select"
local isOpen = false
local popupMenu = nil
local Card = Create("Frame", {
Size = UDim2.new(1, 0, 0, 40),
BackgroundColor3 = Theme.CardBg,
Parent = Page
}, {
Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
Create("UIStroke", { Color = Theme.Border, Thickness = 1 })
})
Create("TextLabel", {
Size = UDim2.new(0.6, 0, 1, 0),
Position = UDim2.new(0, 14, 0, 0),
BackgroundTransparency = 1,
Text = title,
TextColor3 = Theme.TextPrimary,
Font = Enum.Font.GothamMedium,
TextSize = 13,
TextXAlignment = Enum.TextXAlignment.Left,
Parent = Card
})
local DropBtn = Create("TextButton", {
Size = UDim2.new(0, 130, 0, 23),
Position = UDim2.new(1, -144, 0.5, -11.5),
BackgroundColor3 = Theme.InputBg,
Text = "",
AutoButtonColor = false,
Parent = Card
}, {
Create("UICorner", { CornerRadius = UDim.new(0, 5) }),
Create("UIStroke", { Color = Theme.BorderTop, Thickness = 1 })
})
local SelectedLabel = Create("TextLabel", {
Size = UDim2.new(1, -22, 1, 0),
Position = UDim2.new(0, 8, 0, 0),
BackgroundTransparency = 1,
Text = selected,
TextColor3 = Theme.TextPrimary,
Font = Enum.Font.Gotham,
TextSize = 11,
TextXAlignment = Enum.TextXAlignment.Left,
TextTruncate = Enum.TextTruncate.AtEnd,
Parent = DropBtn
})
local Chevron = Create("TextLabel", {
Size = UDim2.new(0, 16, 1, 0),
Position = UDim2.new(1, -18, 0, 0),
BackgroundTransparency = 1,
Text = "⌄",
TextColor3 = Theme.TextSecondary,
Font = Enum.Font.GothamBold,
TextSize = 11,
Parent = DropBtn
})
local function CloseMenu()
if not isOpen then return end
isOpen = false
Chevron.Text = "⌄"
if popupMenu then
local m = popupMenu
popupMenu = nil
TweenService:Create(m, QuickTween, { Size = UDim2.new(0, 130, 0, 0), BackgroundTransparency = 1 }):Play()
task.delay(0.12, function()
if m then m:Destroy() end
end)
end
if ActiveDropdownClose == CloseMenu then
ActiveDropdownClose = nil
end
end
DropBtn.MouseButton1Click:Connect(function()
if isOpen then
CloseMenu()
return
end
if ActiveDropdownClose then
ActiveDropdownClose()
end
isOpen = true
ActiveDropdownClose = CloseMenu
Chevron.Text = "⌃"
local absPos = DropBtn.AbsolutePosition
local absSize = DropBtn.AbsoluteSize
local targetHeight = (#options * 21) + 8
popupMenu = Create("Frame", {
Size = UDim2.new(0, absSize.X, 0, 0),
Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + 4),
BackgroundColor3 = Theme.PopupBg,
ClipsDescendants = true,
ZIndex = 60,
Parent = PopupLayer
}, {
Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
Create("UIStroke", { Color = Theme.BorderTop, Thickness = 1 }),
Create("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }),
Create("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4) })
})
for _, opt in ipairs(options) do
local isCurrent = (opt == selected)
local OptBtn = Create("TextButton", {
Size = UDim2.new(1, 0, 0, 19),
BackgroundColor3 = isCurrent and Theme.CardHover or Theme.PopupBg,
Text = "",
AutoButtonColor = false,
ZIndex = 61,
Parent = popupMenu
}, {
Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
Create("Frame", {
Size = UDim2.new(0, 2.5, 0, 10),
Position = UDim2.new(0, 2, 0.5, -5),
BackgroundColor3 = Theme.WinAccent,
Visible = isCurrent,
ZIndex = 62
}, { Create("UICorner", { CornerRadius = UDim.new(1, 0) }) }),
Create("TextLabel", {
Size = UDim2.new(1, -12, 1, 0),
Position = UDim2.new(0, 9, 0, 0),
BackgroundTransparency = 1,
Text = opt,
TextColor3 = isCurrent and Theme.TextPrimary or Theme.TextSecondary,
Font = Enum.Font.GothamMedium,
TextSize = 11,
TextXAlignment = Enum.TextXAlignment.Left,
ZIndex = 62
})
})
OptBtn.MouseEnter:Connect(function()
TweenService:Create(OptBtn, QuickTween, { BackgroundColor3 = Theme.CardHover }):Play()
end)
OptBtn.MouseLeave:Connect(function()
TweenService:Create(OptBtn, QuickTween, {
BackgroundColor3 = (opt == selected) and Theme.CardHover or Theme.PopupBg
}):Play()
end)
OptBtn.MouseButton1Click:Connect(function()
selected = opt
SelectedLabel.Text = opt
CloseMenu()
if callback then callback(opt) end
end)
end
TweenService:Create(popupMenu, FluentTween, { Size = UDim2.new(0, absSize.X, 0, targetHeight) }):Play()
end)
table.insert(tabObj.SearchableCards, { inst = Card, keyword = string.lower(title) })
end
function Elements:AddKeybind(title, defaultKey, callback)
local currentKey = defaultKey or Enum.KeyCode.RightShift
local listening = false
local Card = Create("Frame", {
Size = UDim2.new(1, 0, 0, 40),
BackgroundColor3 = Theme.CardBg,
Parent = Page
}, {
Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
Create("UIStroke", { Color = Theme.Border, Thickness = 1 }),
Create("TextLabel", {
Size = UDim2.new(1, -115, 1, 0),
Position = UDim2.new(0, 14, 0, 0),
BackgroundTransparency = 1,
Text = title,
TextColor3 = Theme.TextPrimary,
Font = Enum.Font.GothamMedium,
TextSize = 13,
TextXAlignment = Enum.TextXAlignment.Left
})
})
local BindBtn = Create("TextButton", {
Size = UDim2.new(0, 88, 0, 23),
Position = UDim2.new(1, -102, 0.5, -11.5),
BackgroundColor3 = Theme.InputBg,
Text = currentKey.Name,
TextColor3 = Theme.WinAccent,
Font = Enum.Font.GothamSemibold,
TextSize = 11,
AutoButtonColor = false,
Parent = Card
}, {
Create("UICorner", { CornerRadius = UDim.new(0, 5) }),
Create("UIStroke", { Color = Theme.BorderTop, Thickness = 1 })
})
BindBtn.MouseButton1Click:Connect(function()
listening = true
BindBtn.Text = "Press key..."
BindBtn.TextColor3 = Theme.TextPrimary
end)
table.insert(Connections, UserInputService.InputBegan:Connect(function(input, gp)
if listening and not gp and input.UserInputType == Enum.UserInputType.Keyboard then
currentKey = input.KeyCode
BindBtn.Text = currentKey.Name
BindBtn.TextColor3 = Theme.WinAccent
listening = false
if callback then callback(currentKey) end
end
end))
table.insert(tabObj.SearchableCards, { inst = Card, keyword = string.lower(title) })
end
function Elements:AddButton(title, callback)
local Btn = Create("TextButton", {
Size = UDim2.new(1, 0, 0, 36),
BackgroundColor3 = Theme.WinAccent,
Text = title,
TextColor3 = Theme.SidebarBg,
Font = Enum.Font.GothamBold,
TextSize = 13,
AutoButtonColor = false,
Parent = Page
}, { Create("UICorner", { CornerRadius = UDim.new(0, 6) }) })
Btn.MouseEnter:Connect(function()
TweenService:Create(Btn, QuickTween, { BackgroundColor3 = Theme.WinAccentHover }):Play()
end)
Btn.MouseLeave:Connect(function()
TweenService:Create(Btn, QuickTween, { BackgroundColor3 = Theme.WinAccent }):Play()
end)
Btn.MouseButton1Click:Connect(function()
if callback then callback() end
end)
table.insert(tabObj.SearchableCards, { inst = Btn, keyword = string.lower(title) })
end
return Elements
end
-- Live Search Filter
SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
if not ActiveTab then return end
local query = string.lower(SearchBox.Text)
for _, entry in ipairs(ActiveTab.SearchableCards) do
entry.inst.Visible = (query == "") or (string.find(entry.keyword, query, 1, true) ~= nil)
end
end)
-- ==========================================
-- Movement & FPS Boost Helpers
-- ==========================================
local function ApplyMovementStats()
local char = LocalPlayer and LocalPlayer.Character
local hum = char and char:FindFirstChildOfClass("Humanoid")
if hum then
hum.WalkSpeed = Config.Misc.WalkSpeed
hum.UseJumpPower = true
hum.JumpPower = Config.Misc.JumpPower
end
end
if LocalPlayer then
table.insert(Connections, LocalPlayer.CharacterAdded:Connect(function(char)
local hum = char:WaitForChild("Humanoid", 5)
if hum then
hum.WalkSpeed = Config.Misc.WalkSpeed
hum.UseJumpPower = true
hum.JumpPower = Config.Misc.JumpPower
end
end))
end
local function ApplyFPSBoost(enabled)
if not enabled then return end
pcall(function()
Lighting.GlobalShadows = false
Lighting.FogEnd = 9e9
settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
end)
for _, obj in ipairs(Lighting:GetChildren()) do
if obj:IsA("PostEffect") or obj:IsA("BlurEffect") or obj:IsA("SunRaysEffect") or obj:IsA("BloomEffect") or obj:IsA("DepthOfFieldEffect") then
obj.Enabled = false
end
end
task.spawn(function()
local count = 0
for _, inst in ipairs(workspace:GetDescendants()) do
if not Config.Misc.FPSBoost then break end
if inst:IsA("BasePart") then
inst.Material = Enum.Material.SmoothPlastic
inst.Reflectance = 0
elseif inst:IsA("Decal") or inst:IsA("Texture") then
inst.Transparency = 1
elseif inst:IsA("ParticleEmitter") or inst:IsA("Trail") or inst:IsA("Smoke") or inst:IsA("Fire") or inst:IsA("Sparkles") then
inst.Enabled = false
end
count += 1
if count % 400 == 0 then
task.wait()
end
end
end)
end
-- ==========================================
-- Create Your 4 Tabs (Combat -> ESP -> Visuals -> Misc)
-- ==========================================
local CombatTab  = CreateTab("Combat",  "SniperScope")
local ESPTab     = CreateTab("ESP",     "RectangleBox")
local VisualsTab = CreateTab("Visuals", "✦")
local MiscTab    = CreateTab("Misc",    "⚙")
-- 1. Combat Tab
CombatTab:AddSection("Aim & Lock On")
CombatTab:AddDropdown("Aim Mode", { "Camera", "Mouse" }, "Camera", function(mode)
Config.Combat.AimMode = mode
end)
CombatTab:AddDropdown("Aim Curve", { "Linear", "Exponential", "Neutral" }, "Neutral", function(curve)
Config.Combat.AimCurve = curve
end)
CombatTab:AddToggle("Lock On", "Hold Right-Click to smoothly track target", false, function(val)
Config.Combat.LockOn = val
end)
CombatTab:AddSlider("Lock On Smoothing", 0.01, 1.00, 0.20, 2, "", function(val)
Config.Combat.LockOnSmooth = val
end)
CombatTab:AddSection("Blatant Lock On")
CombatTab:AddToggle("Blatant Lock On", "Hold Right-Click for high-speed snap lock", false, function(val)
Config.Combat.BlatantLockOn = val
end)
CombatTab:AddSlider("Blatant Lock On Smoothing", 0.01, 1.00, 0.05, 2, "", function(val)
Config.Combat.BlatantSmooth = val
end)
CombatTab:AddSection("Targeting & Spin")
CombatTab:AddDropdown("Body Part", { "Head", "UpperTorso", "HumanoidRootPart", "LowerTorso", "Closest Part" }, "Head", function(part)
Config.Combat.BodyPart = part
end)
CombatTab:AddToggle("Team Check", "Ignores players on your own team", false, function(val)
Config.Combat.TeamCheck = val
end)
CombatTab:AddToggle("Wall Check", "Only locks onto targets in direct line of sight", false, function(val)
Config.Combat.WallCheck = val
end)
CombatTab:AddToggle("Spin Yaw", "Spins your character yaw smoothly", false, function(val)
Config.Combat.SpinYaw = val
local char = LocalPlayer and LocalPlayer.Character
local hum = char and char:FindFirstChildOfClass("Humanoid")
if hum then hum.AutoRotate = not val end
end)
CombatTab:AddSlider("Spin Speed", 5, 100, 25, 0, "", function(val)
Config.Combat.SpinSpeed = val
end)
-- 2. ESP Tab
ESPTab:AddSection("Box & Overlay Visuals")
ESPTab:AddToggle("Draw Boxes", "Draws lightweight 2D bounding boxes", true, function(val)
Config.ESP.Boxes = val
end)
ESPTab:AddToggle("Fill Boxes", "Adds translucent Fluent fill inside boxes", false, function(val)
Config.ESP.FillBoxes = val
end)
ESPTab:AddToggle("Health Bars", "Displays live health bar alongside boxes", true, function(val)
Config.ESP.HealthBar = val
end)
ESPTab:AddToggle("Tracer Lines", "Draws subtle lines from bottom-center to targets", false, function(val)
Config.ESP.Tracers = val
end)
ESPTab:AddToggle("Highlight Chams", "Renders clean player highlights through walls", false, function(val)
Config.ESP.Highlights = val
end)
ESPTab:AddToggle("Name & Distance Tags", "Displays player display name and distance", true, function(val)
Config.ESP.Tags = val
end)
ESPTab:AddSection("ESP Filters & Style")
ESPTab:AddDropdown("ESP Color", { "Win11 Blue", "Crimson", "Emerald", "Amber", "Pure White" }, "Win11 Blue", function(choice)
Config.ESP.AccentColor = ColorPresets[choice] or Theme.WinAccent
end)
ESPTab:AddToggle("Team Check", "Hides ESP for teammates", false, function(val)
Config.ESP.TeamCheck = val
end)
ESPTab:AddToggle("Use Team Colors", "Colors boxes & highlights by player team", false, function(val)
Config.ESP.UseTeamColor = val
end)
ESPTab:AddSlider("Max Render Distance", 50, 1500, 500, 0, "m", function(val)
Config.ESP.MaxDistance = val
end)
-- 3. Visuals Tab
VisualsTab:AddSection("Camera & FOV")
VisualsTab:AddToggle("Show FOV Circle", "Displays target acquisition ring on screen", false, function(val)
Config.Visuals.ShowFOV = val
FOVCircle.Visible = val
end)
VisualsTab:AddSlider("FOV Radius", 30, 500, 140, 0, "px", function(val)
Config.Visuals.FOVRadius = val
FOVCircle.Size = UDim2.new(0, val * 2, 0, val * 2)
end)
VisualsTab:AddSlider("Camera FOV", 50, 120, 70, 0, "°", function(val)
Config.Visuals.CameraFOV = val
if Camera then Camera.FieldOfView = val end
end)
VisualsTab:AddSection("World")
local OrigAmbient = Lighting.Ambient
local OrigBrightness = Lighting.Brightness
VisualsTab:AddToggle("Fullbright", "Brightens dark environments cleanly", false, function(val)
Config.Visuals.Fullbright = val
if val then
Lighting.Ambient = Color3.fromRGB(185, 185, 185)
Lighting.Brightness = 2
else
Lighting.Ambient = OrigAmbient
Lighting.Brightness = OrigBrightness
end
end)
-- 4. Misc Tab
MiscTab:AddSection("Performance & Movement")
MiscTab:AddToggle("FPS Boost", "Disables shadows, textures & post-effects for higher FPS", false, function(val)
Config.Misc.FPSBoost = val
if val then ApplyFPSBoost(true) end
end)
MiscTab:AddSlider("WalkSpeed", 16, 150, 16, 0, "", function(val)
Config.Misc.WalkSpeed = val
ApplyMovementStats()
end)
MiscTab:AddSlider("JumpPower", 50, 250, 50, 0, "", function(val)
Config.Misc.JumpPower = val
ApplyMovementStats()
end)
MiscTab:AddSection("Cyanide Window")
local ToggleKey = Enum.KeyCode.RightShift
MiscTab:AddKeybind("Toggle Menu Key", Enum.KeyCode.RightShift, function(newKey)
ToggleKey = newKey
SidebarFooter:FindFirstChildOfClass("TextLabel").Text = "Toggle Key: " .. newKey.Name
end)
-- ==========================================
-- Lightweight Pooled ESP & Dual-Mode Aim Engine
-- ==========================================
local ESPPool = {}
local RayParams = RaycastParams.new()
RayParams.FilterType = Enum.RaycastFilterType.Exclude
local function HideESP(entry)
if entry.Visible then
entry.Visible = false
entry.Box.Visible = false
entry.Tag.Visible = false
entry.HealthBg.Visible = false
entry.Tracer.Visible = false
if entry.Highlight.Enabled then
entry.Highlight.Enabled = false
end
end
end
local function DestroyESP(player)
local entry = ESPPool[player]
if entry then
entry.Box:Destroy()
entry.Tag:Destroy()
entry.HealthBg:Destroy()
entry.Tracer:Destroy()
entry.Highlight:Destroy()
ESPPool[player] = nil
end
end
local function GetESPEntry(player)
local entry = ESPPool[player]
if entry then return entry end
local Box = Create("Frame", {
BackgroundColor3 = Theme.WinAccent,
BackgroundTransparency = 1,
BorderSizePixel = 0,
Visible = false,
Parent = OverlayLayer
})
local Stroke = Create("UIStroke", {
Color = Theme.WinAccent,
Thickness = 1.3,
Parent = Box
})
local HealthBg = Create("Frame", {
BackgroundColor3 = Color3.fromRGB(20, 20, 20),
BorderSizePixel = 0,
Visible = false,
Parent = OverlayLayer
})
local HealthFill = Create("Frame", {
Size = UDim2.new(1, 0, 1, 0),
AnchorPoint = Vector2.new(0, 1),
Position = UDim2.new(0, 0, 1, 0),
BackgroundColor3 = Color3.fromRGB(72, 225, 145),
BorderSizePixel = 0,
Parent = HealthBg
})
local Tracer = Create("Frame", {
AnchorPoint = Vector2.new(0.5, 0.5),
BackgroundColor3 = Theme.WinAccent,
BorderSizePixel = 0,
Visible = false,
Parent = OverlayLayer
})
local Tag = Create("TextLabel", {
Size = UDim2.new(0, 160, 0, 16),
AnchorPoint = Vector2.new(0.5, 1),
BackgroundTransparency = 1,
Text = player.DisplayName,
TextColor3 = Theme.TextPrimary,
TextStrokeTransparency = 0.5,
Font = Enum.Font.GothamSemibold,
TextSize = 11,
Visible = false,
Parent = OverlayLayer
})
local Highlight = Create("Highlight", {
Name = "CyanideHighlight",
FillColor = Theme.WinAccent,
FillTransparency = 0.65,
OutlineColor = Color3.new(1, 1, 1),
OutlineTransparency = 0.25,
Enabled = false
})
entry = {
Box = Box,
Stroke = Stroke,
HealthBg = HealthBg,
HealthFill = HealthFill,
Tracer = Tracer,
Tag = Tag,
Highlight = Highlight,
Visible = false,
LastDistText = -1,
}
ESPPool[player] = entry
return entry
end
table.insert(Connections, Players.PlayerRemoving:Connect(DestroyESP))
local function IsSameTeam(player)
if not LocalPlayer or not LocalPlayer.Team or not player.Team then return false end
return LocalPlayer.Team == player.Team
end
local function IsVisible(targetPart, targetChar)
if not Config.Combat.WallCheck then return true end
local origin = Camera.CFrame.Position
local direction = targetPart.Position - origin
RayParams.FilterDescendantsInstances = { LocalPlayer.Character, targetChar }
local hit = workspace:Raycast(origin, direction, RayParams)
return hit == nil
end
local PartCandidates = { "Head", "UpperTorso", "HumanoidRootPart", "LowerTorso" }
local function ResolveTargetPart(character, refPos)
local choice = Config.Combat.BodyPart
if choice == "Closest Part" then
local bestPart, bestDist = nil, math.huge
for i = 1, 4 do
local p = character:FindFirstChild(PartCandidates[i])
if p and p:IsA("BasePart") then
local sp, onScreen = Camera:WorldToViewportPoint(p.Position)
if onScreen then
local dx = sp.X - refPos.X
local dy = sp.Y - refPos.Y
local d2 = dx * dx + dy * dy
if d2 < bestDist then
bestDist = d2
bestPart = p
end
end
end
end
return bestPart or character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
end
return character:FindFirstChild(choice) or character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
end
local function GetAimOrigin()
if Config.Combat.AimMode == "Mouse" then
return UserInputService:GetMouseLocation()
else
local vp = Camera.ViewportSize
return Vector2.new(vp.X * 0.5, vp.Y * 0.5)
end
end
local function GetClosestTarget()
local refPos = GetAimOrigin()
local maxR = Config.Visuals.ShowFOV and Config.Visuals.FOVRadius or 2000
local bestDistSq = maxR * maxR
local bestPart = nil
for _, player in ipairs(Players:GetPlayers()) do
if player ~= LocalPlayer then
if not (Config.Combat.TeamCheck and IsSameTeam(player)) then
local char = player.Character
local hum = char and char:FindFirstChildOfClass("Humanoid")
if hum and hum.Health > 0 then
local part = ResolveTargetPart(char, refPos)
if part then
local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
if onScreen then
local dx = sp.X - refPos.X
local dy = sp.Y - refPos.Y
local d2 = dx * dx + dy * dy
if d2 < bestDistSq and IsVisible(part, char) then
bestDistSq = d2
bestPart = part
end
end
end
end
end
end
end
return bestPart
end
-- Helper to move cursor in Mouse Aim Mode
local function MoveMouseRelative(dx, dy)
if type(mousemoverel) == "function" then
mousemoverel(dx, dy)
else
pcall(function()
local vim = game:GetService("VirtualInputManager")
local mPos = UserInputService:GetMouseLocation()
vim:SendMouseMoveEvent(mPos.X + dx, mPos.Y + dy, game)
end)
end
end
-- Compute Aim Step based on Curve ("Linear", "Exponential", "Neutral") & Smoothness
local function ComputeCurveAlpha(smoothSetting, distanceFactor, dt)
-- Lower smoothSetting = faster lock; higher smoothSetting = softer smoothing
local responsiveness = math.clamp(1.02 - smoothSetting, 0.03, 1.0)
local curve = Config.Combat.AimCurve
if curve == "Linear" then
return math.clamp(responsiveness * (dt * 60) * 0.35, 0.02, 1.0)
elseif curve == "Exponential" then
-- Faster pull when far, smooth precision near target
local expScale = math.clamp(distanceFactor / 180, 0.15, 1.6)
return math.clamp((responsiveness * responsiveness) * expScale * (dt * 60), 0.02, 1.0)
else
-- "Neutral": Frame-rate independent exponential smoothing
return math.clamp(1 - math.pow(1 - responsiveness, dt * 60), 0.02, 1.0)
end
end
-- ==========================================
-- Single Lightweight RenderStepped Loop
-- ==========================================
local SpinAngle = 0
local HeadOffset = Vector3.new(0, 1.1, 0)
local FootOffset = Vector3.new(0, 2.8, 0)
table.insert(Connections, RunService.RenderStepped:Connect(function(dt)
Camera = workspace.CurrentCamera
if not Camera then return end
-- Keep FOV Circle synced to Mouse (in Mouse mode) or Screen Center (in Camera mode)
if Config.Visuals.ShowFOV then
if Config.Combat.AimMode == "Mouse" then
local mPos = UserInputService:GetMouseLocation()
FOVCircle.Position = UDim2.fromOffset(mPos.X, mPos.Y)
else
FOVCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
end
end
-- 1. Spin Yaw
if Config.Combat.SpinYaw and LocalPlayer and LocalPlayer.Character then
local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
if root then
SpinAngle = (SpinAngle + (Config.Combat.SpinSpeed * 12 * dt)) % 360
local pos = root.Position
root.CFrame = CFrame.new(pos) * CFrame.Angles(0, math.rad(SpinAngle), 0)
end
end
-- 2. Dual-Mode Lock-On (Camera or Mouse)
if (Config.Combat.LockOn or Config.Combat.BlatantLockOn) and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
local targetPart = GetClosestTarget()
if targetPart then
local smoothVal = Config.Combat.BlatantLockOn
and (Config.Combat.BlatantSmooth * 0.35)
or Config.Combat.LockOnSmooth
if Config.Combat.AimMode == "Mouse" then
local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
if onScreen then
local mPos = UserInputService:GetMouseLocation()
local dx = screenPos.X - mPos.X
local dy = screenPos.Y - mPos.Y
local pixelDist = math.sqrt(dx * dx + dy * dy)
if pixelDist > 0.5 then
local alpha = ComputeCurveAlpha(smoothVal, pixelDist, dt)
MoveMouseRelative(dx * alpha, dy * alpha)
end
end
else
-- Camera Mode
local camPos = Camera.CFrame.Position
local goalCFrame = CFrame.lookAt(camPos, targetPart.Position)
local angleDiff = math.deg(math.acos(math.clamp(Camera.CFrame.LookVector:Dot(goalCFrame.LookVector), -1, 1)))
local alpha = ComputeCurveAlpha(smoothVal, angleDiff * 8, dt)
Camera.CFrame = Camera.CFrame:Lerp(goalCFrame, alpha)
end
end
end
-- 3. Lightweight Pooled ESP Update
local anyESP = Config.ESP.Boxes or Config.ESP.FillBoxes or Config.ESP.HealthBar or Config.ESP.Tracers or Config.ESP.Highlights or Config.ESP.Tags
local camPos = Camera.CFrame.Position
local viewport = Camera.ViewportSize
local tracerOriginX = viewport.X * 0.5
local tracerOriginY = viewport.Y
local maxDist = Config.ESP.MaxDistance
for _, player in ipairs(Players:GetPlayers()) do
if player ~= LocalPlayer then
if not anyESP or (Config.ESP.TeamCheck and IsSameTeam(player)) then
local existing = ESPPool[player]
if existing then HideESP(existing) end
else
local char = player.Character
local hum = char and char:FindFirstChildOfClass("Humanoid")
local root = char and char:FindFirstChild("HumanoidRootPart")
if char and hum and root and hum.Health > 0 then
local dist = (root.Position - camPos).Magnitude
if dist <= maxDist then
local esp = GetESPEntry(player)
esp.Visible = true
local activeColor = (Config.ESP.UseTeamColor and player.TeamColor)
and player.TeamColor.Color
or Config.ESP.AccentColor
if Config.ESP.Highlights then
if esp.Highlight.Adornee ~= char then
esp.Highlight.Adornee = char
esp.Highlight.Parent = char
end
esp.Highlight.FillColor = activeColor
esp.Highlight.Enabled = true
elseif esp.Highlight.Enabled then
esp.Highlight.Enabled = false
end
local head = char:FindFirstChild("Head")
local topWorld = (head and head.Position or root.Position) + HeadOffset
local botWorld = root.Position - FootOffset
local topScreen, topVis = Camera:WorldToViewportPoint(topWorld)
local botScreen, botVis = Camera:WorldToViewportPoint(botWorld)
if topVis or botVis then
local boxH = math.max(12, math.abs(botScreen.Y - topScreen.Y))
local boxW = boxH * 0.58
local cx = (topScreen.X + botScreen.X) * 0.5
local topY = math.min(topScreen.Y, botScreen.Y)
local botY = topY + boxH
local showBox = Config.ESP.Boxes or Config.ESP.FillBoxes
esp.Box.Visible = showBox
if showBox then
esp.Box.Position = UDim2.fromOffset(cx - (boxW * 0.5), topY)
esp.Box.Size = UDim2.fromOffset(boxW, boxH)
esp.Box.BackgroundColor3 = activeColor
esp.Box.BackgroundTransparency = Config.ESP.FillBoxes and 0.72 or 1
esp.Stroke.Enabled = Config.ESP.Boxes
esp.Stroke.Color = activeColor
end
esp.HealthBg.Visible = Config.ESP.HealthBar
if Config.ESP.HealthBar then
local hpPct = math.clamp(hum.Health / math.max(1, hum.MaxHealth), 0, 1)
esp.HealthBg.Position = UDim2.fromOffset(cx - (boxW * 0.5) - 5, topY)
esp.HealthBg.Size = UDim2.fromOffset(2.5, boxH)
esp.HealthFill.Size = UDim2.new(1, 0, hpPct, 0)
esp.HealthFill.BackgroundColor3 = Color3.fromHSV(hpPct * 0.33, 0.85, 0.95)
end
esp.Tracer.Visible = Config.ESP.Tracers
if Config.ESP.Tracers then
local dx = cx - tracerOriginX
local dy = botY - tracerOriginY
local len = math.sqrt(dx * dx + dy * dy)
esp.Tracer.Position = UDim2.fromOffset(tracerOriginX + dx * 0.5, tracerOriginY + dy * 0.5)
esp.Tracer.Size = UDim2.fromOffset(len, 1.2)
esp.Tracer.Rotation = math.deg(math.atan2(dy, dx))
esp.Tracer.BackgroundColor3 = activeColor
end
esp.Tag.Visible = Config.ESP.Tags
if Config.ESP.Tags then
esp.Tag.Position = UDim2.fromOffset(cx, topY - 2)
local intDist = math.floor(dist)
if esp.LastDistText ~= intDist then
esp.LastDistText = intDist
esp.Tag.Text = player.DisplayName .. " [" .. intDist .. "m]"
end
end
else
esp.Box.Visible = false
esp.Tag.Visible = false
esp.HealthBg.Visible = false
esp.Tracer.Visible = false
end
else
local existing = ESPPool[player]
if existing then HideESP(existing) end
end
else
local existing = ESPPool[player]
if existing then HideESP(existing) end
end
end
end
end
end))
-- Toggle Menu Visibility Hotkey
table.insert(Connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
if not gameProcessed and input.KeyCode == ToggleKey then
if ActiveDropdownClose then ActiveDropdownClose() end
MainWindow.Visible = not MainWindow.Visible
end
end))
-- Clean Unload Function
local function UnloadCyanide()
for _, conn in ipairs(Connections) do
if conn.Connected then conn:Disconnect() end
end
for player in pairs(ESPPool) do
DestroyESP(player)
end
local char = LocalPlayer and LocalPlayer.Character
local hum = char and char:FindFirstChildOfClass("Humanoid")
if hum then
hum.AutoRotate = true
hum.WalkSpeed = 16
hum.JumpPower = 50
end
Lighting.Ambient = OrigAmbient
Lighting.Brightness = OrigBrightness
if Camera then Camera.FieldOfView = 70 end
ScreenGui:Destroy()
end
CloseBtn.MouseButton1Click:Connect(UnloadCyanide)
MiscTab:AddButton("Unload Cyanide", UnloadCyanide)