local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ContentProvider = game:GetService("ContentProvider")
local player = Players.LocalPlayer

local CONFIG = {
    HubName = "TIAN HUB",
    Version = "KEY SYSTEM",
    LogoAsset = "rbxassetid://80369014097246",
    -- Ganti ID ini kalau mau gambar background yang beda
    BackgroundAsset = "rbxassetid://80369014097246",
    AccessKey = "HIDUP JOKOWI",
    HubURL = "https://raw.githubusercontent.com/tiarkenn-dev/Fffffff/refs/heads/main/main.lua",
}

-- Blue & White palette
local C = {
    bgTop = Color3.fromRGB(10, 22, 56),
    bgBottom = Color3.fromRGB(4, 10, 30),
    card = Color3.fromRGB(16, 32, 76),
    cardHover = Color3.fromRGB(24, 46, 102),
    line = Color3.fromRGB(48, 82, 156),
    text = Color3.fromRGB(255, 255, 255),
    soft = Color3.fromRGB(205, 220, 252),
    muted = Color3.fromRGB(140, 163, 212),
    blue = Color3.fromRGB(59, 130, 246),
    blueLight = Color3.fromRGB(135, 195, 255),
    blueDeep = Color3.fromRGB(30, 80, 220),
    red = Color3.fromRGB(255, 99, 120),
    green = Color3.fromRGB(80, 224, 160),
}

local function guiParent()
    local ok, h = pcall(function() return gethui and gethui() end)
    if ok and h then return h end
    return player:WaitForChild("PlayerGui")
end

local parent = guiParent()
for _, container in ipairs({parent, player:WaitForChild("PlayerGui")}) do
    local old = container:FindFirstChild("TianHubKeySystem")
    if old then old:Destroy() end
end

local function new(class, props, into)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do obj[k] = v end
    obj.Parent = into
    return obj
end

local function round(obj, px)
    return new("UICorner", {CornerRadius = UDim.new(0, px)}, obj)
end

local function stroke(obj, color, transparency, thickness)
    return new("UIStroke", {
        Color = color or C.line,
        Transparency = transparency or 0,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, obj)
end

local function gradient(obj, c1, c2, rotation)
    return new("UIGradient", {
        Color = ColorSequence.new(c1, c2),
        Rotation = rotation or 0,
    }, obj)
end

local function tween(obj, duration, props, style, dir)
    local t = TweenService:Create(obj, TweenInfo.new(
        duration or 0.15, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out
    ), props)
    t:Play()
    return t
end

-- Resolve Decal asset ids into real image textures
local function resolveImage(assetId, apply)
    apply(assetId)
    task.spawn(function()
        local ok, objects = pcall(function() return game:GetObjects(assetId) end)
        if ok and type(objects) == "table" and objects[1] then
            local obj = objects[1]
            local texture
            if obj:IsA("Decal") or obj:IsA("Texture") then
                texture = obj.Texture
            else
                local d = obj:FindFirstChildWhichIsA("Decal", true)
                    or obj:FindFirstChildWhichIsA("Texture", true)
                texture = d and d.Texture
            end
            pcall(function() obj:Destroy() end)
            if type(texture) == "string" and texture ~= "" then
                apply(texture)
            end
        end
    end)
end

----------------------------------------------------------------
-- ROOT
----------------------------------------------------------------
local gui = new("ScreenGui", {
    Name = "TianHubKeySystem",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    DisplayOrder = 999,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, parent)
pcall(function() if syn and syn.protect_gui then syn.protect_gui(gui) end end)

local backdrop = new("Frame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.fromRGB(2, 6, 20),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
}, gui)

local panel = new("Frame", {
    Name = "KeyPanel",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(440, 360),
    BackgroundColor3 = C.bgTop,
    BackgroundTransparency = 0.35,
    BorderSizePixel = 0,
    ClipsDescendants = true,
}, backdrop)
round(panel, 20)
gradient(panel, C.bgTop, C.bgBottom, 90)

-- Background image
local bgImage = new("ImageLabel", {
    Name = "Background",
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Image = CONFIG.BackgroundAsset,
    ImageTransparency = 0.7,
    ScaleType = Enum.ScaleType.Crop,
    ZIndex = 1,
}, panel)
round(bgImage, 20)
resolveImage(CONFIG.BackgroundAsset, function(img) bgImage.Image = img end)

-- Dark blue overlay so text stays readable
local overlay = new("Frame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = C.bgBottom,
    BorderSizePixel = 0,
    ZIndex = 1,
}, panel)
round(overlay, 20)
new("UIGradient", {
    Color = ColorSequence.new(C.bgTop, C.bgBottom),
    Rotation = 90,
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.8),
        NumberSequenceKeypoint.new(1, 0.55),
    }),
}, overlay)

-- Animated glowing border
local border = stroke(panel, C.blue, 0.05, 1.8)
local borderGrad = new("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, C.blueDeep),
        ColorSequenceKeypoint.new(0.5, C.text),
        ColorSequenceKeypoint.new(1, C.blueDeep),
    }),
}, border)
task.spawn(function()
    while gui.Parent do
        borderGrad.Rotation = 0
        local t = tween(borderGrad, 5, {Rotation = 360}, Enum.EasingStyle.Linear)
        t.Completed:Wait()
    end
end)

local scaler = new("UIScale", {Scale = 0.8}, panel)
local function fitScale()
    local cam = workspace.CurrentCamera
    if not cam then return 1 end
    local v = cam.ViewportSize
    return math.clamp(math.min((v.X - 24) / 440, (v.Y - 24) / 360), 0.55, 1)
end
scaler.Scale = fitScale() * 0.85
tween(scaler, 0.4, {Scale = fitScale()}, Enum.EasingStyle.Back)
if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        if gui.Parent then scaler.Scale = fitScale() end
    end)
end

----------------------------------------------------------------
-- HEADER
----------------------------------------------------------------
local header = new("Frame", {
    Position = UDim2.fromOffset(20, 18),
    Size = UDim2.new(1, -40, 0, 60),
    BackgroundTransparency = 1,
    ZIndex = 2,
}, panel)

local logoRing = new("Frame", {
    Size = UDim2.fromOffset(54, 54),
    Position = UDim2.fromOffset(0, 3),
    BackgroundColor3 = C.blue,
    BorderSizePixel = 0,
    ZIndex = 2,
}, header)
round(logoRing, 20)
gradient(logoRing, C.blueLight, C.blueDeep, 45)

local logoHolder = new("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.new(1, -4, 1, -4),
    BackgroundColor3 = C.bgBottom,
    BorderSizePixel = 0,
    ZIndex = 3,
}, logoRing)
round(logoHolder, 20)

local fallback = new("TextLabel", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Text = "T",
    TextColor3 = C.blueLight,
    TextSize = 26,
    Font = Enum.Font.GothamBlack,
    Visible = false,
    ZIndex = 4,
}, logoHolder)

local logo = new("ImageLabel", {
    Name = "TianHubLogo",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.new(1, -6, 1, -6),
    BackgroundTransparency = 1,
    Image = CONFIG.LogoAsset,
    ScaleType = Enum.ScaleType.Fit,
    ZIndex = 4,
}, logoHolder)
round(logo, 20)

resolveImage(CONFIG.LogoAsset, function(img)
    logo.Image = img
    task.spawn(function()
        pcall(function() ContentProvider:PreloadAsync({logo}) end)
        fallback.Visible = not (logo.Parent and logo.IsLoaded)
    end)
end)

new("TextLabel", {
    Position = UDim2.fromOffset(68, 4),
    Size = UDim2.new(1, -120, 0, 28),
    BackgroundTransparency = 1,
    Text = CONFIG.HubName,
    TextColor3 = C.text,
    TextSize = 21,
    Font = Enum.Font.GothamBlack,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 2,
}, header)

local badge = new("Frame", {
    Position = UDim2.fromOffset(69, 35),
    Size = UDim2.fromOffset(86, 18),
    BackgroundColor3 = C.blue,
    BackgroundTransparency = 0.7,
    BorderSizePixel = 0,
    ZIndex = 2,
}, header)
round(badge, 20)
stroke(badge, C.blue, 0.3)
new("TextLabel", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Text = CONFIG.Version,
    TextColor3 = C.text,
    TextSize = 9,
    Font = Enum.Font.GothamBold,
    ZIndex = 3,
}, badge)

local close = new("TextButton", {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, 0, 0, 5),
    Size = UDim2.fromOffset(34, 34),
    BackgroundColor3 = C.card,
    Text = "×",
    TextColor3 = C.soft,
    TextSize = 22,
    Font = Enum.Font.GothamMedium,
    AutoButtonColor = false,
    ZIndex = 3,
}, header)
round(close, 20)
stroke(close, C.line, 0.2)
close.MouseEnter:Connect(function()
    tween(close, 0.12, {BackgroundColor3 = C.red, TextColor3 = C.text})
end)
close.MouseLeave:Connect(function()
    tween(close, 0.12, {BackgroundColor3 = C.card, TextColor3 = C.soft})
end)

-- Drag (mouse + touch)
do
    local dragging, dragStart, startPos = false, nil, nil
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = panel.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            panel.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

local divider = new("Frame", {
    Position = UDim2.fromOffset(20, 92),
    Size = UDim2.new(1, -40, 0, 1),
    BackgroundColor3 = C.blueLight,
    BorderSizePixel = 0,
    ZIndex = 2,
}, panel)
new("UIGradient", {
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0.25),
        NumberSequenceKeypoint.new(1, 1),
    }),
}, divider)

----------------------------------------------------------------
-- BODY
----------------------------------------------------------------
new("TextLabel", {
    Position = UDim2.fromOffset(24, 108),
    Size = UDim2.new(1, -48, 0, 28),
    BackgroundTransparency = 1,
    Text = "Masukkan Key",
    TextColor3 = C.text,
    TextSize = 22,
    Font = Enum.Font.GothamBlack,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 2,
}, panel)

new("TextLabel", {
    Position = UDim2.fromOffset(24, 138),
    Size = UDim2.new(1, -48, 0, 20),
    BackgroundTransparency = 1,
    Text = "Ketik key kamu untuk membuka hub.",
    TextColor3 = C.soft,
    TextTransparency = 0.15,
    TextSize = 12,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 2,
}, panel)

local inputWrap = new("Frame", {
    Position = UDim2.fromOffset(24, 176),
    Size = UDim2.new(1, -48, 0, 50),
    BackgroundColor3 = C.card,
    BackgroundTransparency = 0.15,
    BorderSizePixel = 0,
    ZIndex = 2,
}, panel)
round(inputWrap, 20)
local inputStroke = stroke(inputWrap, C.line, 0, 1.2)

local keyBox = new("TextBox", {
    Position = UDim2.fromOffset(16, 0),
    Size = UDim2.new(1, -32, 1, 0),
    BackgroundTransparency = 1,
    Text = "",
    PlaceholderText = "Masukkan key di sini...",
    PlaceholderColor3 = C.muted,
    TextColor3 = C.text,
    TextSize = 14,
    Font = Enum.Font.GothamMedium,
    ClearTextOnFocus = false,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 3,
}, inputWrap)

keyBox.Focused:Connect(function()
    tween(inputStroke, 0.15, {Color = C.blueLight, Thickness = 1.8})
    tween(inputWrap, 0.15, {BackgroundColor3 = C.cardHover})
end)
keyBox.FocusLost:Connect(function()
    tween(inputStroke, 0.15, {Color = C.line, Thickness = 1.2})
    tween(inputWrap, 0.15, {BackgroundColor3 = C.card})
end)

-- Status pill
local statusPill = new("Frame", {
    Position = UDim2.fromOffset(24, 238),
    Size = UDim2.new(1, -48, 0, 28),
    BackgroundColor3 = C.card,
    BackgroundTransparency = 0.35,
    BorderSizePixel = 0,
    ZIndex = 2,
}, panel)
round(statusPill, 20)
local pillStroke = stroke(statusPill, C.line, 0.5)

local statusDot = new("Frame", {
    AnchorPoint = Vector2.new(0, 0.5),
    Position = UDim2.new(0, 13, 0.5, 0),
    Size = UDim2.fromOffset(8, 8),
    BackgroundColor3 = C.muted,
    BorderSizePixel = 0,
    ZIndex = 3,
}, statusPill)
round(statusDot, 20)

local status = new("TextLabel", {
    Position = UDim2.fromOffset(30, 0),
    Size = UDim2.new(1, -38, 1, 0),
    BackgroundTransparency = 1,
    Text = "Menunggu key",
    TextColor3 = C.muted,
    TextSize = 12,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 3,
}, statusPill)

-- Verify button (gradient lives on its own frame so the text stays pure white)
local verifySize = UDim2.new(1, -48, 0, 46)
local verify = new("TextButton", {
    Position = UDim2.fromOffset(24, 282),
    Size = verifySize,
    BackgroundColor3 = C.blue,
    Text = "",
    AutoButtonColor = false,
    ZIndex = 3,
}, panel)
round(verify, 20)
local verifyStroke = stroke(verify, C.blueLight, 0.45)

local verifyFill = new("Frame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = C.blue,
    BorderSizePixel = 0,
    ZIndex = 3,
}, verify)
round(verifyFill, 20)
local verifyGrad = gradient(verifyFill, C.blueLight, C.blueDeep, 20)

local verifyLabel = new("TextLabel", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Text = "VERIFY KEY",
    TextColor3 = C.text,
    TextSize = 13,
    Font = Enum.Font.GothamBlack,
    ZIndex = 4,
}, verify)

verify.MouseEnter:Connect(function()
    tween(verifyStroke, 0.12, {Transparency = 0})
    tween(verifyGrad, 0.12, {Offset = Vector2.new(0.15, 0)})
end)
verify.MouseLeave:Connect(function()
    tween(verifyStroke, 0.12, {Transparency = 0.45})
    tween(verifyGrad, 0.12, {Offset = Vector2.new(0, 0)})
end)
verify.MouseButton1Down:Connect(function()
    tween(verify, 0.07, {Size = verifySize - UDim2.fromOffset(4, 2)})
end)
verify.MouseButton1Up:Connect(function()
    tween(verify, 0.1, {Size = verifySize})
end)

new("TextLabel", {
    Position = UDim2.new(0, 24, 1, -24),
    Size = UDim2.new(1, -48, 0, 14),
    BackgroundTransparency = 1,
    Text = "SECURE ACCESS  •  " .. CONFIG.HubName,
    TextColor3 = C.soft,
    TextTransparency = 0.45,
    TextSize = 8,
    Font = Enum.Font.GothamMedium,
    ZIndex = 2,
}, panel)

----------------------------------------------------------------
-- LOGIC
----------------------------------------------------------------
local busy = false

local function setStatus(message, color)
    status.Text = tostring(message)
    status.TextColor3 = color or C.muted
    tween(statusDot, 0.15, {BackgroundColor3 = color or C.muted})
    tween(pillStroke, 0.15, {Color = color or C.line, Transparency = color and 0.2 or 0.5})
end

local function setInputState(color)
    tween(inputStroke, 0.15, {Color = color, Thickness = 1.8})
end

local function shake()
    local base = panel.Position
    for _, dx in ipairs({-8, 8, -5, 5, 0}) do
        tween(panel, 0.04, {Position = UDim2.new(
            base.X.Scale, base.X.Offset + dx, base.Y.Scale, base.Y.Offset
        )})
        task.wait(0.04)
    end
end

local function normalize(text)
    return (tostring(text or ""):gsub("^%s+", ""):gsub("%s+$", ""):gsub("%s+", " ")):upper()
end

local function ValidateKey(key)
    if normalize(key) == normalize(CONFIG.AccessKey) and key ~= "" then
        return true
    end
    return false
end

local function closeGui()
    tween(scaler, 0.2, {Scale = 0.7}, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    tween(backdrop, 0.2, {BackgroundTransparency = 1})
    task.delay(0.22, function()
        if gui and gui.Parent then gui:Destroy() end
    end)
end

local function loadHub()
    local ok, err = pcall(function()
        local source = game:HttpGet(CONFIG.HubURL)
        local chunk = loadstring(source)
        assert(type(chunk) == "function", "Hub source could not be compiled")
        chunk()
    end)

    if ok then
        task.wait(0.5)
        closeGui()
    else
        setStatus("Hub gagal dimuat", C.red)
        warn("[TIAN HUB] " .. tostring(err))
    end
end

keyBox:GetPropertyChangedSignal("Text"):Connect(function()
    if not busy then
        setStatus("Menunggu key", nil)
        tween(inputStroke, 0.15, {Color = C.blueLight, Thickness = 1.8})
    end
end)

verify.Activated:Connect(function()
    if busy then return end
    busy = true
    verifyLabel.Text = "MEMERIKSA..."

    local key = tostring(keyBox.Text or "")
    if ValidateKey(key) then
        verifyLabel.Text = "KEY VALID"
        setStatus("Key valid", C.green)
        setInputState(C.green)
        loadHub()
    else
        verifyLabel.Text = "VERIFY KEY"
        setStatus("Key invalid", C.red)
        setInputState(C.red)
        shake()
    end
    busy = false
end)

close.Activated:Connect(closeGui)

tween(backdrop, 0.3, {BackgroundTransparency = 0.4})

