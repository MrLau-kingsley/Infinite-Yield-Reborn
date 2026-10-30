loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()

-- ============================================================
-- 繁體中文 UI 重設計（400×275，左邊類型，右邊功能，可拖動）
-- 追加於原版 Infinite Yield 末尾，可直接調用 execCmd
-- 顯示/隱藏：右下角懸浮「中」按鈕（可拖動，拖動後不誤觸）
-- ============================================================
task.spawn(function()
    task.wait(1.5)

    pcall(function() if Holder then Holder.Visible = false end end)

    local UIS = UserInputService
    local LP = Players.LocalPlayer
    local TS = TweenService

    local screen = Instance.new("ScreenGui")
    screen.Name = "IY_CN_UI"
    screen.ResetOnSpawn = false
    screen.DisplayOrder = 2147483647
    screen.IgnoreGuiInset = true
    pcall(function() screen.Parent = PARENT end)
    if not screen.Parent then
        pcall(function() screen.Parent = gethui and gethui() or game:GetService("CoreGui") end)
    end

    -- ===== 主視窗 400×275 =====
    local win = Instance.new("Frame")
    win.Name = "MainWindow"
    win.Size = UDim2.fromOffset(400, 275)
    win.Position = UDim2.new(0.5, -200, 0.5, -137)
    win.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
    win.BorderSizePixel = 0
    win.Active = true
    win.ClipsDescendants = true
    win.Parent = screen

    local uiScale = Instance.new("UIScale")
    uiScale.Parent = win
    local function fitScale()
        local vp = workspace.CurrentCamera.ViewportSize
        uiScale.Scale = math.min(1, (vp.X - 40) / 400, (vp.Y - 40) / 275)
    end
    pcall(fitScale)
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function() pcall(fitScale) end)

    -- 標題欄
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 24)
    titleBar.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = win

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, -110, 1, 0)
    title.Position = UDim2.fromOffset(8, 0)
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 13
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = "Infinite Yield Reborn v" .. (currentVersion or "6.4.2")
    title.Parent = titleBar

    local showOrigBtn = Instance.new("TextButton")
    showOrigBtn.Size = UDim2.fromOffset(70, 24)
    showOrigBtn.Position = UDim2.new(1, -96, 0, 0)
    showOrigBtn.BackgroundTransparency = 1
    showOrigBtn.Font = Enum.Font.SourceSans
    showOrigBtn.TextSize = 12
    showOrigBtn.TextColor3 = Color3.fromRGB(160, 200, 255)
    showOrigBtn.Text = "顯示原版"
    showOrigBtn.Parent = titleBar
    showOrigBtn.MouseButton1Click:Connect(function()
        if Holder then Holder.Visible = not Holder.Visible end
    end)

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.fromOffset(24, 24)
    closeBtn.Position = UDim2.new(1, -24, 0, 0)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.TextSize = 14
    closeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    closeBtn.Text = "✕"
    closeBtn.Parent = titleBar
    closeBtn.MouseButton1Click:Connect(function()
        win.Visible = false
    end)

    local statusBar = Instance.new("TextLabel")
    statusBar.Size = UDim2.new(1, 0, 0, 14)
    statusBar.Position = UDim2.new(0, 0, 0, 24)
    statusBar.BackgroundTransparency = 1
    statusBar.Font = Enum.Font.SourceSans
    statusBar.TextSize = 11
    statusBar.TextColor3 = Color3.fromRGB(140, 220, 140)
    statusBar.Text = ""
    statusBar.Parent = win

    local function toast(msg, color)
        statusBar.Text = msg
        statusBar.TextColor3 = color or Color3.fromRGB(140, 220, 140)
        local old = msg
        task.delay(2.5, function()
            if statusBar.Text == old then statusBar.Text = "" end
        end)
    end

    -- ===== 懸浮切換按鈕（右下角，可拖動） =====
    local floatBtn = Instance.new("TextButton")
    floatBtn.Name = "IYR_ToggleBtn"
    floatBtn.Size = UDim2.fromOffset(46, 46)
    floatBtn.Position = UDim2.new(1, -62, 1, -112)
    floatBtn.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
    floatBtn.BackgroundTransparency = 0.15
    floatBtn.BorderSizePixel = 0
    floatBtn.Font = Enum.Font.SourceSansBold
    floatBtn.TextSize = 18
    floatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    floatBtn.Text = "IYR"
    floatBtn.AutoButtonColor = true
    floatBtn.ZIndex = 20
    floatBtn.TextStrokeTransparency = 0
    floatBtn.Parent = screen

    local floatCorner = Instance.new("UICorner")
    floatCorner.CornerRadius = UDim.new(0.5, 0)
    floatCorner.Parent = floatBtn

    local floatStroke = Instance.new("UIStroke")
    floatStroke.Color = Color3.fromRGB(120, 200, 255)
    floatStroke.Thickness = 1.5
    floatStroke.Transparency = 0.3
    floatStroke.Parent = floatBtn

    -- ===== 懸浮按鈕：拖動 + 點擊 分離處理 =====
    local fbDragging = false
    local fbMoved = false
    local fbDragStart = nil
    local fbStartPos = nil
    local DRAG_THRESHOLD = 4   -- 移動超過 4 像素就當成拖動，不再觸發點擊

    floatBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
           or input.UserInputType == Enum.UserInputType.Touch then
            fbDragging = true
            fbMoved = false
            fbDragStart = input.Position
            fbStartPos = floatBtn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    fbDragging = false
                end
            end)
        end
    end)

    floatBtn.InputChanged:Connect(function(input)
        if not fbDragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
           or input.UserInputType == Enum.UserInputType.Touch then
            local d = input.Position - fbDragStart
            if math.abs(d.X) > DRAG_THRESHOLD or math.abs(d.Y) > DRAG_THRESHOLD then
                fbMoved = true
                floatBtn.Position = UDim2.new(
                    fbStartPos.X.Scale, fbStartPos.X.Offset + d.X,
                    fbStartPos.Y.Scale, fbStartPos.Y.Offset + d.Y
                )
            end
        end
    end)

    -- 只有「冇拖動過」先算點擊
    floatBtn.MouseButton1Click:Connect(function()
        if fbMoved then
            fbMoved = false
            return
        end
        win.Visible = not win.Visible
        if win.Visible then
            win.Size = UDim2.fromOffset(0, 0)
            TS:Create(win, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2.fromOffset(400, 275)
            }):Play()
            toast("視窗已顯示")
        end
    end)

    -- ===== 可拖動主視窗（標題欄拖動） =====
    local dragging, dragInput, dragStart, startPos
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = win.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local d = input.Position - dragStart
            win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)

    -- ===== 左側：類型欄 =====
    local leftPane = Instance.new("ScrollingFrame")
    leftPane.Size = UDim2.new(0, 110, 1, -38)
    leftPane.Position = UDim2.fromOffset(0, 38)
    leftPane.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
    leftPane.BorderSizePixel = 0
    leftPane.ScrollBarThickness = 4
    leftPane.ScrollBarImageColor3 = Color3.fromRGB(78, 78, 79)
    leftPane.CanvasSize = UDim2.new(0, 0, 0, 0)
    leftPane.Parent = win

    local leftL = Instance.new("UIListLayout")
    leftL.Padding = UDim.new(0, 2)
    leftL.SortOrder = Enum.SortOrder.LayoutOrder
    leftL.Parent = leftPane

    -- ===== 右側：功能欄 =====
    local rightPane = Instance.new("ScrollingFrame")
    rightPane.Size = UDim2.new(1, -110, 1, -38)
    rightPane.Position = UDim2.fromOffset(110, 38)
    rightPane.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
    rightPane.BorderSizePixel = 0
    rightPane.ScrollBarThickness = 6
    rightPane.ScrollBarImageColor3 = Color3.fromRGB(78, 78, 79)
    rightPane.CanvasSize = UDim2.new(0, 0, 0, 0)
    rightPane.Parent = win

    local rightL = Instance.new("UIListLayout")
    rightL.Padding = UDim.new(0, 2)
    rightL.SortOrder = Enum.SortOrder.LayoutOrder
    rightL.Parent = rightPane

    -- ===== 輸入彈窗 =====
    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.fromOffset(280, 130)
    overlay.Position = UDim2.new(0.5, -140, 0.5, -65)
    overlay.BackgroundColor3 = Color3.fromRGB(30, 30, 32)
    overlay.BorderSizePixel = 0
    overlay.Visible = false
    overlay.ZIndex = 50
    overlay.Parent = win

    local inTitle = Instance.new("TextLabel")
    inTitle.Size = UDim2.new(1, -10, 0, 18)
    inTitle.Position = UDim2.fromOffset(8, 6)
    inTitle.BackgroundTransparency = 1
    inTitle.Font = Enum.Font.SourceSansBold
    inTitle.TextSize = 13
    inTitle.TextColor3 = Color3.new(1, 1, 1)
    inTitle.TextXAlignment = Enum.TextXAlignment.Left
    inTitle.ZIndex = 51
    inTitle.Parent = overlay

    local inBox = Instance.new("TextBox")
    inBox.Size = UDim2.new(1, -20, 0, 28)
    inBox.Position = UDim2.fromOffset(10, 30)
    inBox.BackgroundColor3 = Color3.fromRGB(60, 60, 62)
    inBox.BorderSizePixel = 0
    inBox.Font = Enum.Font.SourceSans
    inBox.TextSize = 14
    inBox.TextColor3 = Color3.new(1, 1, 1)
    inBox.PlaceholderColor3 = Color3.fromRGB(140, 140, 140)
    inBox.Text = ""
    inBox.ClearTextOnFocus = false
    inBox.ZIndex = 51
    inBox.Parent = overlay

    local okBtn = Instance.new("TextButton")
    okBtn.Size = UDim2.fromOffset(90, 26)
    okBtn.Position = UDim2.new(0.5, -95, 1, -38)
    okBtn.BackgroundColor3 = Color3.fromRGB(60, 130, 60)
    okBtn.BorderSizePixel = 0
    okBtn.Font = Enum.Font.SourceSansBold
    okBtn.TextSize = 13
    okBtn.TextColor3 = Color3.new(1, 1, 1)
    okBtn.Text = "確定"
    okBtn.ZIndex = 51
    okBtn.Parent = overlay

    local cancelBtn = Instance.new("TextButton")
    cancelBtn.Size = UDim2.fromOffset(90, 26)
    cancelBtn.Position = UDim2.new(0.5, 5, 1, -38)
    cancelBtn.BackgroundColor3 = Color3.fromRGB(100, 60, 60)
    cancelBtn.BorderSizePixel = 0
    cancelBtn.Font = Enum.Font.SourceSansBold
    cancelBtn.TextSize = 13
    cancelBtn.TextColor3 = Color3.new(1, 1, 1)
    cancelBtn.Text = "取消"
    cancelBtn.ZIndex = 51
    cancelBtn.Parent = overlay

    local inputCb = nil
    local function openInput(t, ph, cb)
        inTitle.Text = t
        inBox.PlaceholderText = ph or ""
        inBox.Text = ""
        overlay.Visible = true
        inputCb = cb
        inBox:CaptureFocus()
    end
    okBtn.MouseButton1Click:Connect(function()
        overlay.Visible = false
        local v = inBox.Text
        local cb = inputCb; inputCb = nil
        if cb then cb(v) end
    end)
    cancelBtn.MouseButton1Click:Connect(function()
        overlay.Visible = false
        inputCb = nil
    end)
    inBox.FocusLost:Connect(function(enter)
        if enter then
            overlay.Visible = false
            local v = inBox.Text
            local cb = inputCb; inputCb = nil
            if cb then cb(v) end
        end
    end)

    -- ===== 執行命令（直接調用原版 execCmd） =====
    local function run(cmdStr, label)
        if type(execCmd) ~= "function" then
            toast("找不到 execCmd，請確認原版已完整執行", Color3.fromRGB(220, 120, 120))
            return
        end
        local ok, err = pcall(execCmd, cmdStr, LP, true)
        if ok then
            toast("已執行：" .. (label or cmdStr))
        else
            toast("執行失敗：" .. tostring(err), Color3.fromRGB(220, 120, 120))
        end
    end

    -- ===== 功能表（繁體中文） =====
    local categories = {
        { name = "角色", items = {
            { label = "重生",          cmd = "respawn" },
            { label = "刷新回到原位",   cmd = "refresh" },
            { label = "重置角色",       cmd = "reset" },
            { label = "上帝模式",       cmd = "god" },
            { label = "隱身",           cmd = "invisible" },
            { label = "現身",           cmd = "visible" },
            { label = "設定速度",       cmd = "speed",       input = "輸入速度（例如 50）" },
            { label = "設定跳躍力",     cmd = "jumppower",   input = "輸入跳躍力（例如 100）" },
            { label = "臀部高度",       cmd = "hipheight",   input = "輸入高度（例如 2）" },
            { label = "坐下",           cmd = "sit" },
            { label = "無限跳躍",       cmd = "infjump" },
            { label = "自動跳躍",       cmd = "autojump" },
        }},
        { name = "飛行", items = {
            { label = "飛行",           cmd = "fly" },
            { label = "停止飛行",       cmd = "unfly" },
            { label = "飛行速度",       cmd = "flyspeed",    input = "輸入速度（例如 3）" },
            { label = "CFly 飛行",      cmd = "cfly" },
            { label = "停止 CFly",      cmd = "uncfly" },
            { label = "懸浮",           cmd = "float" },
            { label = "取消懸浮",       cmd = "unfloat" },
            { label = "游泳",           cmd = "swim" },
            { label = "停止游泳",       cmd = "unswim" },
            { label = "穿牆",           cmd = "noclip" },
            { label = "取消穿牆",       cmd = "clip" },
            { label = "傳送行走",       cmd = "tpwalk",      input = "輸入速度（例如 1）" },
        }},
        { name = "傳送", items = {
            { label = "傳送到座標",     cmd = "tppos",       input = "輸入座標：x y z" },
            { label = "傳送到玩家",     cmd = "goto",        input = "輸入玩家名稱" },
            { label = "Tween 傳送",     cmd = "tgoto",       input = "輸入玩家名稱" },
            { label = "循環傳送",       cmd = "loopgoto",    input = "輸入玩家名稱" },
            { label = "停止循環傳送",   cmd = "unloopgoto" },
            { label = "脈衝傳送",       cmd = "pulsetp",     input = "玩家名稱 [秒數]" },
            { label = "載具傳送",       cmd = "vgoto",       input = "輸入玩家名稱" },
            { label = "傳送到滑鼠",     cmd = "mousetp" },
            { label = "設定重生點",     cmd = "spawn" },
            { label = "移除重生點",     cmd = "nospawn" },
            { label = "傳送到死亡點",   cmd = "flashback" },
            { label = "傳送工具",       cmd = "tptool" },
        }},
        { name = "玩家", items = {
            { label = "凍結玩家",       cmd = "freeze",      input = "輸入玩家名稱" },
            { label = "解凍玩家",       cmd = "thaw",        input = "輸入玩家名稱" },
            { label = "觀察玩家",       cmd = "view",        input = "輸入玩家名稱" },
            { label = "停止觀察",       cmd = "unview" },
            { label = "拉過來",         cmd = "cbring",      input = "輸入玩家名稱" },
            { label = "循環拉",         cmd = "loopbring",   input = "玩家名稱" },
            { label = "停止循環拉",     cmd = "unloopbring", input = "輸入玩家名稱" },
            { label = "甩人",           cmd = "fling" },
            { label = "停止甩人",       cmd = "unfling" },
            { label = "行走甩人",       cmd = "walkfling" },
            { label = "環繞玩家",       cmd = "orbit",       input = "玩家名稱 [速度] [距離]" },
            { label = "停止環繞",       cmd = "unorbit" },
            { label = "跟隨玩家",       cmd = "walkto",      input = "輸入玩家名稱" },
            { label = "停止跟隨",       cmd = "unwalkto" },
            { label = "調整碰撞箱",     cmd = "hitbox",      input = "玩家名 大小" },
            { label = "調整頭部",       cmd = "headsize",    input = "玩家名 大小" },
        }},
        { name = "視覺", items = {
            { label = "透視玩家",       cmd = "esp" },
            { label = "隊伍透視",       cmd = "espteam" },
            { label = "關閉透視",       cmd = "noesp" },
            { label = "色塊透視",       cmd = "chams" },
            { label = "關閉色塊",       cmd = "nochams" },
            { label = "定位玩家",       cmd = "locate",      input = "輸入玩家名稱" },
            { label = "關閉定位",       cmd = "nolocate" },
            { label = "透視牆壁",       cmd = "xray" },
            { label = "關閉透視牆",     cmd = "unxray" },
            { label = "全亮",           cmd = "fullbright" },
            { label = "去霧",           cmd = "nofog" },
            { label = "白天",           cmd = "day" },
            { label = "夜晚",           cmd = "night" },
            { label = "亮度",           cmd = "brightness",  input = "輸入亮度（0-5）" },
            { label = "恢復光照",       cmd = "restorelighting" },
            { label = "顯示碰撞箱",     cmd = "hitboxes" },
            { label = "關閉碰撞箱",     cmd = "unhitboxes" },
            { label = "去除廣告",       cmd = "removeads" },
            { label = "防掉虛空",       cmd = "antivoid" },
        }},
        { name = "聊天", items = {
            { label = "發送聊天",       cmd = "chat",         input = "輸入要發送的文字" },
            { label = "刷屏",           cmd = "spam",         input = "輸入要刷的文字" },
            { label = "停止刷屏",       cmd = "unspam" },
            { label = "私聊",           cmd = "whisper",      input = "玩家名 訊息" },
            { label = "刷私聊",         cmd = "pmspam",       input = "玩家名 訊息" },
            { label = "停止刷私聊",     cmd = "unpmspam",     input = "輸入玩家名稱" },
            { label = "刷屏速度",       cmd = "spamspeed",    input = "輸入秒數（例如 1）" },
            { label = "氣泡聊天",       cmd = "bubblechat" },
            { label = "深色聊天",       cmd = "darkchat" },
            { label = "靜音所有語音",   cmd = "muteallvoices" },
        }},
        { name = "世界", items = {
            { label = "伺服器資訊",     cmd = "serverinfo" },
            { label = "複製 JobId",     cmd = "jobid" },
            { label = "重新加入",       cmd = "rejoin" },
            { label = "換伺服器",       cmd = "serverhop" },
            { label = "Discord 連結",   cmd = "discord" },
            { label = "複製 PlaceId",   cmd = "copyplaceid" },
            { label = "複製創作者 ID",  cmd = "copycreatorid" },
            { label = "用戶 ID",        cmd = "userid",       input = "輸入玩家名稱" },
            { label = "複製用戶 ID",    cmd = "copyid",       input = "輸入玩家名稱" },
            { label = "帳號年齡",       cmd = "age",          input = "輸入玩家名稱" },
            { label = "加入日期",       cmd = "joindate",     input = "輸入玩家名稱" },
        }},
        { name = "工具", items = {
            { label = "複製所有工具",   cmd = "tools" },
            { label = "移除所有工具",   cmd = "notools" },
            { label = "建築工具",       cmd = "btools" },
            { label = "F3X 工具",       cmd = "f3x" },
            { label = "抓取掉落工具",   cmd = "grabtools" },
            { label = "丟下工具",       cmd = "droptools" },
            { label = "工具可丟棄",     cmd = "droppabletools" },
            { label = "裝備所有工具",   cmd = "equiptools" },
            { label = "收起所有工具",   cmd = "unequiptools" },
            { label = "延長工具",       cmd = "reach",        input = "輸入長度（例如 60）" },
            { label = "盒子延長",       cmd = "boxreach",     input = "輸入邊長（例如 60）" },
            { label = "取消延長",       cmd = "unreach" },
            { label = "握持位置",       cmd = "grippos",      input = "輸入 x y z" },
            { label = "使用所有工具",   cmd = "usetools" },
        }},
        { name = "介面", items = {
            { label = "顯示原版 IY",    special = "showorig" },
            { label = "隱藏此視窗",     special = "hide" },
            { label = "打開日誌",       cmd = "logs" },
            { label = "聊天日誌",       cmd = "chatlogs" },
            { label = "加入日誌",       cmd = "joinlogs" },
            { label = "自訂通知",       cmd = "notify",       input = "輸入通知文字" },
            { label = "介面縮放",       cmd = "guiscale",     input = "輸入倍率（0.4 - 2）" },
        }},
    }

    local function clearPane(p, layout)
        for _, c in ipairs(p:GetChildren()) do
            if c ~= layout then c:Destroy() end
        end
    end

    local function splitArgs(s)
        local t = {}
        for part in tostring(s):gmatch("[^,]+") do
            local tr = part:match("^%s*(.-)%s*$")
            if tr ~= "" then table.insert(t, tr) end
        end
        return t
    end

    local function runItem(item)
        if item.special == "hide" then
            win.Visible = false; return
        elseif item.special == "showorig" then
            if Holder then Holder.Visible = true end
            toast("已顯示原版 IY 視窗"); return
        end

        if item.input then
            openInput(item.label, item.input, function(val)
                if val == "" then
                    toast("已取消：未輸入", Color3.fromRGB(220, 180, 100)); return
                end
                local args = splitArgs(val)
                local full = item.cmd .. " " .. table.concat(args, " ")
                run(full, item.label)
            end)
        else
            run(item.cmd, item.label)
        end
    end

    local currentIdx = nil
    local function buildFunctions(idx)
        clearPane(rightPane, rightL)
        local cat = categories[idx]
        if not cat then return end
        currentIdx = idx

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
                TS:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(78, 78, 80)}):Play()
            end)
            btn.MouseLeave:Connect(function()
                TS:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(56, 56, 58)}):Play()
            end)
            btn.MouseButton1Click:Connect(function() runItem(item) end)
        end

        local function updateCanvas()
            rightPane.CanvasSize = UDim2.new(0, 0, 0, rightL.AbsoluteContentSize.Y + 8)
        end
        rightL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
        updateCanvas()
    end

    local catButtons = {}
    for i, cat in ipairs(categories) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, -4, 0, 28)
        b.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
        b.BorderSizePixel = 0
        b.Font = Enum.Font.SourceSans
        b.TextSize = 14
        b.TextColor3 = Color3.new(1, 1, 1)
        b.TextXAlignment = Enum.TextXAlignment.Left
        b.Text = "  " .. cat.name
        b.LayoutOrder = i
        b.Parent = leftPane
        table.insert(catButtons, b)

        b.MouseButton1Click:Connect(function()
            for _, x in ipairs(catButtons) do x.BackgroundColor3 = Color3.fromRGB(46, 46, 47) end
            b.BackgroundColor3 = Color3.fromRGB(78, 78, 80)
            buildFunctions(i)
        end)
    end
    leftPane.CanvasSize = UDim2.new(0, 0, 0, leftL.AbsoluteContentSize.Y + 4)

    if #catButtons > 0 then
        catButtons[1].BackgroundColor3 = Color3.fromRGB(78, 78, 80)
        buildFunctions(1)
    end

    toast("繁體中文介面已載入（右下角懸浮按鈕切換顯示）")
end)
