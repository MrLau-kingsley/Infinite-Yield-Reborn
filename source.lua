-- ============================================================
-- Infinite Yield 繁體中文 UI 重設計
-- 400 × 275 視窗｜左邊類型｜右邊功能｜點擊執行｜需要數值時輸入
-- ============================================================

if not game:IsLoaded() then game.Loaded:Wait() end

local Players      = game:GetService("Players")
local UIS          = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LP           = Players.LocalPlayer

-- ---------- 取得 IY 命令執行函數 ----------
local function getExecutor()
    local g = getgenv()
    for _, name in ipairs({"IY_CMD", "IY_CMD_FUNC", "processCommand"}) do
        if type(g[name]) == "function" then
            return g[name]
        end
    end
    return nil
end

local function exec(cmd)
    local f = getExecutor()
    if not f then
        warn("[繁中UI] 找不到 IY 命令執行函數，請確認 Infinite Yield 已載入")
        return false
    end
    local ok, err = pcall(f, cmd)
    if not ok then warn("[繁中UI] 執行失敗: " .. tostring(err)) end
    return ok
end

-- ---------- 隱藏原本 IY 主視窗（保留通知） ----------
local OriginalHolder = nil
local function hideOriginalIY()
    local containers = {}
    local ok, hui = pcall(function() return gethui() end)
    if ok and hui then table.insert(containers, hui) end
    table.insert(containers, game:GetService("CoreGui"))
    if LP:FindFirstChild("PlayerGui") then table.insert(containers, LP.PlayerGui) end

    for _, c in ipairs(containers) do
        local ok2, descs = pcall(function() return c:GetDescendants() end)
        if ok2 then
            for _, d in ipairs(descs) do
                if d:IsA("TextLabel") and d.Name == "Title"
                   and tostring(d.Text):find("Infinite Yield") then
                    local holder = d.Parent
                    if holder and holder:IsA("Frame") then
                        OriginalHolder = holder
                        holder.Visible = false
                    end
                end
            end
        end
    end
end
hideOriginalIY()

-- ---------- 建立 ScreenGui ----------
local parentGui
do
    local ok, hui = pcall(function() return gethui() end)
    parentGui = (ok and hui) or game:GetService("CoreGui")
end

local screen = Instance.new("ScreenGui")
screen.Name = "IY_TW_UI"
screen.ResetOnSpawn = false
screen.DisplayOrder = 2147483647
screen.IgnoreGuiInset = true
pcall(function() screen.Parent = parentGui end)

-- ---------- 主視窗 400 × 275 ----------
local win = Instance.new("Frame")
win.Name = "Window"
win.Size = UDim2.fromOffset(400, 275)
win.Position = UDim2.new(0.5, -200, 0.5, -137)
win.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
win.BorderSizePixel = 0
win.Active = true
win.ClipsDescendants = true
win.Parent = screen

-- 自適應縮放（小螢幕自動縮小）
local uiScale = Instance.new("UIScale")
uiScale.Parent = win

local function fitScale()
    local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280,720)
    local s = math.min(1, (vp.X - 40) / 400, (vp.Y - 40) / 275)
    uiScale.Scale = math.max(0.6, s)
end
fitScale()
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fitScale)

-- ---------- 標題欄 ----------
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 22)
titleBar.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
titleBar.BorderSizePixel = 0
titleBar.Parent = win

local titleLabel = Instance.new("TextLabel")
titleLabel.BackgroundTransparency = 1
titleLabel.Size = UDim2.new(1, -50, 1, 0)
titleLabel.Position = UDim2.fromOffset(8, 0)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 14
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Text = "Infinite Yield 繁體中文版"
titleLabel.Parent = titleBar

-- 關閉按鈕
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.fromOffset(22, 22)
closeBtn.Position = UDim2.new(1, -22, 0, 0)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "✕"
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 14
closeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
closeBtn.Parent = titleBar
closeBtn.MouseButton1Click:Connect(function()
    win.Visible = false
end)

-- 顯示原界面按鈕
local showOrigBtn = Instance.new("TextButton")
showOrigBtn.Size = UDim2.fromOffset(70, 22)
showOrigBtn.Position = UDim2.new(1, -94, 0, 0)
showOrigBtn.BackgroundTransparency = 1
showOrigBtn.Text = "顯示原界面"
showOrigBtn.Font = Enum.Font.SourceSans
showOrigBtn.TextSize = 12
showOrigBtn.TextColor3 = Color3.fromRGB(160, 200, 255)
showOrigBtn.Parent = titleBar
showOrigBtn.MouseButton1Click:Connect(function()
    if OriginalHolder then OriginalHolder.Visible = true end
end)

-- 狀態提示
local statusLabel = Instance.new("TextLabel")
statusLabel.BackgroundTransparency = 1
statusLabel.Size = UDim2.new(1, 0, 0, 16)
statusLabel.Position = UDim2.new(0, 0, 0, 22)
statusLabel.Font = Enum.Font.SourceSans
statusLabel.TextSize = 11
statusLabel.TextColor3 = Color3.fromRGB(140, 220, 140)
statusLabel.Text = ""
statusLabel.Parent = win

local function toast(msg, color)
    statusLabel.Text = msg
    statusLabel.TextColor3 = color or Color3.fromRGB(140, 220, 140)
    task.delay(2.5, function()
        if statusLabel.Text == msg then statusLabel.Text = "" end
    end)
end

-- ---------- 左側：類型欄 ----------
local leftPane = Instance.new("ScrollingFrame")
leftPane.Name = "Categories"
leftPane.Size = UDim2.new(0, 110, 1, -40)
leftPane.Position = UDim2.fromOffset(0, 40)
leftPane.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
leftPane.BorderSizePixel = 0
leftPane.ScrollBarThickness = 4
leftPane.ScrollBarImageColor3 = Color3.fromRGB(78, 78, 79)
leftPane.CanvasSize = UDim2.new(0, 0, 0, 0)
leftPane.Parent = win

local leftLayout = Instance.new("UIListLayout")
leftLayout.Padding = UDim.new(0, 2)
leftLayout.SortOrder = Enum.SortOrder.LayoutOrder
leftLayout.Parent = leftPane

-- ---------- 右側：功能欄 ----------
local rightPane = Instance.new("ScrollingFrame")
rightPane.Name = "Functions"
rightPane.Size = UDim2.new(1, -110, 1, -40)
rightPane.Position = UDim2.fromOffset(110, 40)
rightPane.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
rightPane.BorderSizePixel = 0
rightPane.ScrollBarThickness = 6
rightPane.ScrollBarImageColor3 = Color3.fromRGB(78, 78, 79)
rightPane.CanvasSize = UDim2.new(0, 0, 0, 0)
rightPane.Parent = win

local rightLayout = Instance.new("UIListLayout")
rightLayout.Padding = UDim.new(0, 2)
rightLayout.SortOrder = Enum.SortOrder.LayoutOrder
rightLayout.Parent = rightPane

-- ---------- 功能定義（繁體中文） ----------
local categories = {
    {
        name = "角色",
        items = {
            {label = "飛行模式",        cmd = "fly"},
            {label = "穿牆模式",        cmd = "noclip"},
            {label = "無限跳躍",        cmd = "infjump"},
            {label = "隱形",            cmd = "invisible"},
            {label = "治療自己",        cmd = "heal"},
            {label = "重置角色",        cmd = "reset"},
            {label = "坐下",            cmd = "sit"},
            {label = "設定速度",        cmd = "speed",      input = "輸入速度數值（例如 50）"},
            {label = "設定跳躍力",      cmd = "jumppower",  input = "輸入跳躍力數值（例如 100）"},
            {label = "無敵模式",        cmd = "god"},
        },
    },
    {
        name = "傳送",
        items = {
            {label = "傳送到玩家",      cmd = "tp",     input = "輸入玩家名稱"},
            {label = "傳送到滑鼠位置",  cmd = "tpm"},
            {label = "傳送到座標",      cmd = "tpp",    input = "輸入座標：x, y, z"},
            {label = "返回上一位置",    cmd = "back"},
            {label = "把所有玩家帶來",  cmd = "bring all"},
            {label = "點擊傳送（開關）",cmd = "clicktp"},
            {label = "設定傳送點",      cmd = "swp",    input = "輸入傳送點名稱"},
            {label = "列出傳送點",      cmd = "waypoints"},
        },
    },
    {
        name = "玩家",
        items = {
            {label = "踢出玩家",        cmd = "kick",    input = "輸入玩家名稱"},
            {label = "殺死玩家",        cmd = "kill",    input = "輸入玩家名稱"},
            {label = "凍結玩家",        cmd = "freeze",  input = "輸入玩家名稱"},
            {label = "解除凍結",        cmd = "thaw",    input = "輸入玩家名稱"},
            {label = "爆炸玩家",        cmd = "explode", input = "輸入玩家名稱"},
            {label = "閃爍玩家",        cmd = "flash",   input = "輸入玩家名稱"},
            {label = "查看玩家",        cmd = "view",    input = "輸入玩家名稱"},
            {label = "跟隨玩家",        cmd = "follow",  input = "輸入玩家名稱"},
        },
    },
    {
        name = "世界",
        items = {
            {label = "移除霧氣",        cmd = "fog"},
            {label = "設定時間",        cmd = "time",     input = "輸入時間（0-24 小時）"},
            {label = "設定重力",        cmd = "gravity",  input = "輸入重力值（例如 196.2）"},
            {label = "顯示 FPS",        cmd = "fps"},
            {label = "清除粒子效果",    cmd = "clearparticles"},
        },
    },
    {
        name = "雜項",
        items = {
            {label = "重新加入伺服器",  cmd = "rejoin"},
            {label = "伺服器跳轉",      cmd = "serverhop"},
            {label = "複製位置到剪貼板",cmd = "copypath"},
            {label = "伺服器資訊",      cmd = "serverinfo"},
            {label = "查看日誌",        cmd = "logs"},
        },
    },
    {
        name = "介面",
        items = {
            {label = "隱藏此視窗",      special = "hide"},
            {label = "顯示原 IY 界面",  special = "showoriginal"},
            {label = "重新整理介面",    special = "refresh"},
        },
    },
}

-- ---------- 工具函數 ----------
local function clearPane(pane, layout)
    for _, c in ipairs(pane:GetChildren()) do
        if c ~= layout then c:Destroy() end
    end
end

local function splitArgs(s)
    local t = {}
    for part in tostring(s):gmatch("[^,]+") do
        local trimmed = part:match("^%s*(.-)%s*$")
        if trimmed ~= "" then table.insert(t, trimmed) end
    end
    return t
end

-- ---------- 輸入彈窗 ----------
local inputOverlay = Instance.new("Frame")
inputOverlay.Name = "InputOverlay"
inputOverlay.Size = UDim2.fromOffset(270, 120)
inputOverlay.Position = UDim2.new(0.5, -135, 0.5, -60)
inputOverlay.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
inputOverlay.BorderSizePixel = 0
inputOverlay.Visible = false
inputOverlay.ZIndex = 50
inputOverlay.Parent = win

local inputTitle = Instance.new("TextLabel")
inputTitle.Size = UDim2.new(1, -10, 0, 18)
inputTitle.Position = UDim2.fromOffset(5, 4)
inputTitle.BackgroundTransparency = 1
inputTitle.Font = Enum.Font.SourceSansBold
inputTitle.TextSize = 13
inputTitle.TextColor3 = Color3.new(1, 1, 1)
inputTitle.TextXAlignment = Enum.TextXAlignment.Left
inputTitle.ZIndex = 51
inputTitle.Parent = inputOverlay

local inputBox = Instance.new("TextBox")
inputBox.Size = UDim2.new(1, -20, 0, 26)
inputBox.Position = UDim2.fromOffset(10, 28)
inputBox.BackgroundColor3 = Color3.fromRGB(60, 60, 62)
inputBox.BorderSizePixel = 0
inputBox.Font = Enum.Font.SourceSans
inputBox.TextSize = 14
inputBox.TextColor3 = Color3.new(1, 1, 1)
inputBox.PlaceholderText = ""
inputBox.Text = ""
inputBox.ClearTextOnFocus = false
inputBox.ZIndex = 51
inputBox.Parent = inputOverlay

local okBtn = Instance.new("TextButton")
okBtn.Size = UDim2.fromOffset(80, 24)
okBtn.Position = UDim2.new(0.5, -85, 1, -34)
okBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
okBtn.BorderSizePixel = 0
okBtn.Font = Enum.Font.SourceSansBold
okBtn.TextSize = 13
okBtn.TextColor3 = Color3.new(1, 1, 1)
okBtn.Text = "確定"
okBtn.ZIndex = 51
okBtn.Parent = inputOverlay

local cancelBtn = Instance.new("TextButton")
cancelBtn.Size = UDim2.fromOffset(80, 24)
cancelBtn.Position = UDim2.new(0.5, 5, 1, -34)
cancelBtn.BackgroundColor3 = Color3.fromRGB(90, 60, 60)
cancelBtn.BorderSizePixel = 0
cancelBtn.Font = Enum.Font.SourceSansBold
cancelBtn.TextSize = 13
cancelBtn.TextColor3 = Color3.new(1, 1, 1)
cancelBtn.Text = "取消"
cancelBtn.ZIndex = 51
cancelBtn.Parent = inputOverlay

local inputCallback = nil

local function openInput(title, placeholder, callback)
    inputTitle.Text = title
    inputBox.PlaceholderText = placeholder or ""
    inputBox.Text = ""
    inputOverlay.Visible = true
    inputCallback = callback
    inputBox:CaptureFocus()
end

okBtn.MouseButton1Click:Connect(function()
    local val = inputBox.Text
    inputOverlay.Visible = false
    local cb = inputCallback
    inputCallback = nil
    if cb then cb(val) end
end)

cancelBtn.MouseButton1Click:Connect(function()
    inputOverlay.Visible = false
    inputCallback = nil
end)

inputBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local val = inputBox.Text
        inputOverlay.Visible = false
        local cb = inputCallback
        inputCallback = nil
        if cb then cb(val) end
    end
end)

-- ---------- 執行功能 ----------
local function runItem(item)
    if item.special == "hide" then
        win.Visible = false
        return
    elseif item.special == "showoriginal" then
        if OriginalHolder then OriginalHolder.Visible = true end
        toast("已顯示原 IY 界面")
        return
    elseif item.special == "refresh" then
        toast("介面已重新整理")
        return
    end

    if item.input then
        openInput(item.label, item.input, function(val)
            if val == "" then
                toast("已取消：未輸入數值", Color3.fromRGB(220, 180, 100))
                return
            end
            local args = splitArgs(val)
            local full = item.cmd .. " " .. table.concat(args, " ")
            if exec(full) then
                toast("已執行：" .. item.label)
            else
                toast("執行失敗：" .. item.label, Color3.fromRGB(220, 120, 120))
            end
        end)
    else
        if exec(item.cmd) then
            toast("已執行：" .. item.label)
        else
            toast("執行失敗：" .. item.label, Color3.fromRGB(220, 120, 120))
        end
    end
end

-- ---------- 產生右側功能按鈕 ----------
local currentCategory = nil

local function buildFunctions(catIndex)
    clearPane(rightPane, rightLayout)
    local cat = categories[catIndex]
    if not cat then return end
    currentCategory = catIndex

    for i, item in ipairs(cat.items) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -8, 0, 26)
        btn.BackgroundColor3 = Color3.fromRGB(56, 56, 58)
        btn.BorderSizePixel = 0
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 14
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Text = "  " .. item.label .. (item.input and "  ✎" or "")
        btn.LayoutOrder = i
        btn.Parent = rightPane

        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.12), {
                BackgroundColor3 = Color3.fromRGB(78, 78, 80)
            }):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.12), {
                BackgroundColor3 = Color3.fromRGB(56, 56, 58)
            }):Play()
        end)
        btn.MouseButton1Click:Connect(function()
            runItem(item)
        end)
    end

    rightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        rightPane.CanvasSize = UDim2.new(0, 0, 0, rightLayout.AbsoluteContentSize.Y + 8)
    end)
    rightPane.CanvasSize = UDim2.new(0, 0, 0, rightLayout.AbsoluteContentSize.Y + 8)
end

-- ---------- 產生左側類型按鈕 ----------
local categoryButtons = {}

for i, cat in ipairs(categories) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -4, 0, 28)
    btn.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 14
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Text = "  " .. cat.name
    btn.LayoutOrder = i
    btn.Parent = leftPane
    table.insert(categoryButtons, btn)

    btn.MouseButton1Click:Connect(function()
        for _, b in ipairs(categoryButtons) do
            b.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
        end
        btn.BackgroundColor3 = Color3.fromRGB(78, 78, 80)
        buildFunctions(i)
    end)
end

leftPane.CanvasSize = UDim2.new(0, 0, 0, leftLayout.AbsoluteContentSize.Y + 4)

-- 預設選中第一個類型
if #categoryButtons > 0 then
    categoryButtons[1].BackgroundColor3 = Color3.fromRGB(78, 78, 80)
    buildFunctions(1)
end

-- ---------- 顯示／隱藏快捷鍵（右 Shift） ----------
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        win.Visible = not win.Visible
    end
end)

toast("繁體中文介面已載入（右 Shift 隱藏／顯示）", Color3.fromRGB(140, 220, 140))
