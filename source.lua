-- ============================================================
-- Infinite Yield 繁體中文 UI v4
-- 400×275｜開關合併｜狀態指示｜詳細說明｜約 300+ 條命令
-- 懸浮「中」按鈕切換（可拖動）
-- ============================================================
task.spawn(function()
    task.wait(1.5)
    local t0 = tick()
    while (type(cmds) ~= "table" or #cmds == 0) and tick() - t0 < 10 do task.wait(0.1) end
    if type(execCmd) ~= "function" then warn("[繁中UI] 找不到 execCmd") return end

    pcall(function() if Holder then Holder.Visible = false end end)

    local UIS, LP, TS = UserInputService, Players.LocalPlayer, TweenService

    local screen = Instance.new("ScreenGui")
    screen.Name = "IYR_UI"; screen.ResetOnSpawn = false
    screen.DisplayOrder = 2147483647; screen.IgnoreGuiInset = true
    pcall(function() screen.Parent = PARENT end)
    if not screen.Parent then pcall(function() screen.Parent = gethui and gethui() or game:GetService("CoreGui") end) end

    -- ===== 主視窗 =====
    local win = Instance.new("Frame")
    win.Size = UDim2.fromOffset(400, 275)
    win.Position = UDim2.new(0.5, -200, 0.5, -137)
    win.BackgroundColor3 = Color3.fromRGB(40, 40, 42)
    win.BorderSizePixel = 0; win.Active = true; win.ClipsDescendants = true
    win.Parent = screen

    local uiScale = Instance.new("UIScale"); uiScale.Parent = win
    local function fitScale()
        local vp = workspace.CurrentCamera.ViewportSize
        uiScale.Scale = math.min(1, (vp.X - 40) / 400, (vp.Y - 40) / 275)
    end
    pcall(fitScale)
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function() pcall(fitScale) end)

    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 24)
    titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 32)
    titleBar.BorderSizePixel = 0; titleBar.Parent = win

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, -110, 1, 0); title.Position = UDim2.fromOffset(8, 0)
    title.Font = Enum.Font.SourceSansBold; title.TextSize = 13
    title.TextColor3 = Color3.fromRGB(200, 220, 255)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = "Infinite Yield Reborn"
    title.Parent = titleBar

    local showOrigBtn = Instance.new("TextButton")
    showOrigBtn.Size = UDim2.fromOffset(70, 24); showOrigBtn.Position = UDim2.new(1, -96, 0, 0)
    showOrigBtn.BackgroundTransparency = 1; showOrigBtn.Font = Enum.Font.SourceSans
    showOrigBtn.TextSize = 12; showOrigBtn.TextColor3 = Color3.fromRGB(140, 180, 255)
    showOrigBtn.Text = "顯示原版"; showOrigBtn.Parent = titleBar
    showOrigBtn.MouseButton1Click:Connect(function()
        if Holder then Holder.Visible = not Holder.Visible end
    end)

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.fromOffset(24, 24); closeBtn.Position = UDim2.new(1, -24, 0, 0)
    closeBtn.BackgroundTransparency = 1; closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.TextSize = 14; closeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    closeBtn.Text = "✕"; closeBtn.Parent = titleBar
    closeBtn.MouseButton1Click:Connect(function() win.Visible = false end)

    local statusBar = Instance.new("TextLabel")
    statusBar.Size = UDim2.new(1, 0, 0, 14); statusBar.Position = UDim2.new(0, 0, 0, 24)
    statusBar.BackgroundTransparency = 1; statusBar.Font = Enum.Font.SourceSans
    statusBar.TextSize = 11; statusBar.TextColor3 = Color3.fromRGB(140, 220, 140)
    statusBar.Text = ""; statusBar.Parent = win

    local function toast(msg, color)
        statusBar.Text = msg
        statusBar.TextColor3 = color or Color3.fromRGB(140, 220, 140)
        local old = msg
        task.delay(3, function() if statusBar.Text == old then statusBar.Text = "" end end)
    end

    -- ===== 懸浮切換按鈕 =====
    local floatBtn = Instance.new("TextButton")
    floatBtn.Size = UDim2.fromOffset(46, 46)
    floatBtn.Position = UDim2.new(1, -62, 1, -112)
    floatBtn.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
    floatBtn.BackgroundTransparency = 0.1
    floatBtn.BorderSizePixel = 0; floatBtn.Font = Enum.Font.SourceSansBold
    floatBtn.TextSize = 16; floatBtn.TextColor3 = Color3.new(1, 1, 1)
    floatBtn.Text = "IYR"; floatBtn.ZIndex = 20; floatBtn.Parent = screen
    local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(0.5, 0); fc.Parent = floatBtn
    local fs = Instance.new("UIStroke"); fs.Color = Color3.fromRGB(120, 180, 255)
    fs.Thickness = 1.5; fs.Transparency = 0.3; fs.Parent = floatBtn

    local fbDragging, fbMoved, fbDragStart, fbStartPos = false, false, nil, nil
    floatBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            fbDragging, fbMoved = true, false
            fbDragStart, fbStartPos = input.Position, floatBtn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then fbDragging = false end
            end)
        end
    end)
    floatBtn.InputChanged:Connect(function(input)
        if not fbDragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local d = input.Position - fbDragStart
            if math.abs(d.X) > 4 or math.abs(d.Y) > 4 then
                fbMoved = true
                floatBtn.Position = UDim2.new(fbStartPos.X.Scale, fbStartPos.X.Offset + d.X, fbStartPos.Y.Scale, fbStartPos.Y.Offset + d.Y)
            end
        end
    end)
    floatBtn.MouseButton1Click:Connect(function()
        if fbMoved then fbMoved = false return end
        win.Visible = not win.Visible
    end)

    -- 主視窗拖動
    local dragging, dragInput, dragStart, startPos
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging, dragStart, startPos = true, input.Position, win.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local d = input.Position - dragStart
            win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)

    -- 左右欄
    local leftPane = Instance.new("ScrollingFrame")
    leftPane.Size = UDim2.new(0, 110, 1, -38); leftPane.Position = UDim2.fromOffset(0, 38)
    leftPane.BackgroundColor3 = Color3.fromRGB(30, 30, 32)
    leftPane.BorderSizePixel = 0; leftPane.ScrollBarThickness = 4
    leftPane.ScrollBarImageColor3 = Color3.fromRGB(78, 78, 79)
    leftPane.CanvasSize = UDim2.new(0, 0, 0, 0); leftPane.Parent = win
    local leftL = Instance.new("UIListLayout")
    leftL.Padding = UDim.new(0, 2); leftL.SortOrder = Enum.SortOrder.LayoutOrder; leftL.Parent = leftPane

    local rightPane = Instance.new("ScrollingFrame")
    rightPane.Size = UDim2.new(1, -110, 1, -38); rightPane.Position = UDim2.fromOffset(110, 38)
    rightPane.BackgroundColor3 = Color3.fromRGB(40, 40, 42)
    rightPane.BorderSizePixel = 0; rightPane.ScrollBarThickness = 6
    rightPane.ScrollBarImageColor3 = Color3.fromRGB(78, 78, 79)
    rightPane.CanvasSize = UDim2.new(0, 0, 0, 0); rightPane.Parent = win
    local rightL = Instance.new("UIListLayout")
    rightL.Padding = UDim.new(0, 2); rightL.SortOrder = Enum.SortOrder.LayoutOrder; rightL.Parent = rightPane

    -- ===== 輸入彈窗 =====
    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.fromOffset(300, 140)
    overlay.Position = UDim2.new(0.5, -150, 0.5, -70)
    overlay.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
    overlay.BorderSizePixel = 0; overlay.Visible = false; overlay.ZIndex = 50; overlay.Parent = win

    local inTitle = Instance.new("TextLabel")
    inTitle.Size = UDim2.new(1, -10, 0, 18); inTitle.Position = UDim2.fromOffset(8, 6)
    inTitle.BackgroundTransparency = 1; inTitle.Font = Enum.Font.SourceSansBold
    inTitle.TextSize = 13; inTitle.TextColor3 = Color3.fromRGB(200, 220, 255)
    inTitle.TextXAlignment = Enum.TextXAlignment.Left; inTitle.ZIndex = 51; inTitle.Parent = overlay

    local inHint = Instance.new("TextLabel")
    inHint.Size = UDim2.new(1, -16, 0, 14); inHint.Position = UDim2.fromOffset(8, 24)
    inHint.BackgroundTransparency = 1; inHint.Font = Enum.Font.SourceSans
    inHint.TextSize = 11; inHint.TextColor3 = Color3.fromRGB(150, 200, 255)
    inHint.TextXAlignment = Enum.TextXAlignment.Left; inHint.ZIndex = 51; inHint.Parent = overlay

    local inBox = Instance.new("TextBox")
    inBox.Size = UDim2.new(1, -20, 0, 30); inBox.Position = UDim2.fromOffset(10, 40)
    inBox.BackgroundColor3 = Color3.fromRGB(60, 60, 62)
    inBox.BorderSizePixel = 0; inBox.Font = Enum.Font.SourceSans
    inBox.TextSize = 14; inBox.TextColor3 = Color3.new(1, 1, 1)
    inBox.PlaceholderColor3 = Color3.fromRGB(140, 140, 140)
    inBox.Text = ""; inBox.ClearTextOnFocus = false; inBox.ZIndex = 51; inBox.Parent = overlay

    local okBtn = Instance.new("TextButton")
    okBtn.Size = UDim2.fromOffset(90, 26); okBtn.Position = UDim2.new(0.5, -95, 1, -36)
    okBtn.BackgroundColor3 = Color3.fromRGB(60, 130, 60)
    okBtn.BorderSizePixel = 0; okBtn.Font = Enum.Font.SourceSansBold
    okBtn.TextSize = 13; okBtn.TextColor3 = Color3.new(1, 1, 1)
    okBtn.Text = "執行"; okBtn.ZIndex = 51; okBtn.Parent = overlay

    local cancelBtn = Instance.new("TextButton")
    cancelBtn.Size = UDim2.fromOffset(90, 26); cancelBtn.Position = UDim2.new(0.5, 5, 1, -36)
    cancelBtn.BackgroundColor3 = Color3.fromRGB(100, 60, 60)
    cancelBtn.BorderSizePixel = 0; cancelBtn.Font = Enum.Font.SourceSansBold
    cancelBtn.TextSize = 13; cancelBtn.TextColor3 = Color3.new(1, 1, 1)
    cancelBtn.Text = "取消"; cancelBtn.ZIndex = 51; cancelBtn.Parent = overlay

    local inputCb = nil
    local function openInput(t, hint, ph, cb)
        inTitle.Text = t; inHint.Text = hint or ""
        inBox.PlaceholderText = ph or ""; inBox.Text = ""
        overlay.Visible = true; inputCb = cb; inBox:CaptureFocus()
    end
    okBtn.MouseButton1Click:Connect(function()
        overlay.Visible = false
        local v = inBox.Text
        local cb = inputCb; inputCb = nil
        if cb then cb(v) end
    end)
    cancelBtn.MouseButton1Click:Connect(function() overlay.Visible = false; inputCb = nil end)
    inBox.FocusLost:Connect(function(enter)
        if enter then
            overlay.Visible = false
            local v = inBox.Text
            local cb = inputCb; inputCb = nil
            if cb then cb(v) end
        end
    end)

    -- ===== 資訊彈窗 =====
    local infoOverlay = Instance.new("Frame")
    infoOverlay.Size = UDim2.fromOffset(340, 200)
    infoOverlay.Position = UDim2.new(0.5, -170, 0.5, -100)
    infoOverlay.BackgroundColor3 = Color3.fromRGB(26, 26, 28)
    infoOverlay.BorderSizePixel = 0; infoOverlay.Visible = false; infoOverlay.ZIndex = 60; infoOverlay.Parent = win

    local infoBar = Instance.new("Frame")
    infoBar.Size = UDim2.new(1, 0, 0, 22)
    infoBar.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
    infoBar.BorderSizePixel = 0; infoBar.ZIndex = 61; infoBar.Parent = infoOverlay

    local infoTitle = Instance.new("TextLabel")
    infoTitle.Size = UDim2.new(1, -30, 1, 0); infoTitle.Position = UDim2.fromOffset(8, 0)
    infoTitle.BackgroundTransparency = 1; infoTitle.Font = Enum.Font.SourceSansBold
    infoTitle.TextSize = 13; infoTitle.TextColor3 = Color3.fromRGB(160, 200, 255)
    infoTitle.TextXAlignment = Enum.TextXAlignment.Left; infoTitle.ZIndex = 62; infoTitle.Parent = infoBar

    local infoClose = Instance.new("TextButton")
    infoClose.Size = UDim2.fromOffset(22, 22); infoClose.Position = UDim2.new(1, -22, 0, 0)
    infoClose.BackgroundTransparency = 1; infoClose.Font = Enum.Font.SourceSansBold
    infoClose.TextSize = 14; infoClose.TextColor3 = Color3.fromRGB(200, 200, 200)
    infoClose.Text = "✕"; infoClose.ZIndex = 62; infoClose.Parent = infoBar

    local infoBody = Instance.new("TextLabel")
    infoBody.Size = UDim2.new(1, -20, 0, 130); infoBody.Position = UDim2.fromOffset(10, 28)
    infoBody.BackgroundTransparency = 1; infoBody.Font = Enum.Font.SourceSans
    infoBody.TextSize = 13; infoBody.TextColor3 = Color3.fromRGB(220, 220, 220)
    infoBody.TextWrapped = true; infoBody.TextXAlignment = Enum.TextXAlignment.Left
    infoBody.TextYAlignment = Enum.TextYAlignment.Top; infoBody.ZIndex = 61; infoBody.Parent = infoOverlay

    local infoCopyBtn = Instance.new("TextButton")
    infoCopyBtn.Size = UDim2.fromOffset(110, 26); infoCopyBtn.Position = UDim2.new(0.5, -115, 1, -34)
    infoCopyBtn.BackgroundColor3 = Color3.fromRGB(60, 100, 150)
    infoCopyBtn.BorderSizePixel = 0; infoCopyBtn.Font = Enum.Font.SourceSansBold
    infoCopyBtn.TextSize = 13; infoCopyBtn.TextColor3 = Color3.new(1, 1, 1)
    infoCopyBtn.Text = "複製到剪貼板"; infoCopyBtn.ZIndex = 62; infoCopyBtn.Parent = infoOverlay

    local infoOkBtn = Instance.new("TextButton")
    infoOkBtn.Size = UDim2.fromOffset(80, 26); infoOkBtn.Position = UDim2.new(0.5, 5, 1, -34)
    infoOkBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 62)
    infoOkBtn.BorderSizePixel = 0; infoOkBtn.Font = Enum.Font.SourceSansBold
    infoOkBtn.TextSize = 13; infoOkBtn.TextColor3 = Color3.new(1, 1, 1)
    infoOkBtn.Text = "關閉"; infoOkBtn.ZIndex = 62; infoOkBtn.Parent = infoOverlay

    local infoCopyText = ""
    local function showInfo(t, body, copyText)
        infoTitle.Text = t; infoBody.Text = body
        infoCopyText = copyText or ""
        infoCopyBtn.Visible = infoCopyText ~= ""
        infoOverlay.Visible = true
    end
    infoClose.MouseButton1Click:Connect(function() infoOverlay.Visible = false end)
    infoOkBtn.MouseButton1Click:Connect(function() infoOverlay.Visible = false end)
    infoCopyBtn.MouseButton1Click:Connect(function()
        if infoCopyText == "" then return end
        if type(toClipboard) == "function" then pcall(toClipboard, infoCopyText)
        elseif everyClipboard then pcall(everyClipboard, infoCopyText) end
        infoCopyBtn.Text = "已複製 ✓"
        task.delay(1.2, function() infoCopyBtn.Text = "複製到剪貼板" end)
    end)

    -- ===== 執行 =====
    local function run(cmdStr, label)
        local ok, err = pcall(execCmd, cmdStr, LP, true)
        if ok then toast("已執行：" .. (label or cmdStr))
        else toast("失敗：" .. tostring(err), Color3.fromRGB(220, 120, 120)) end
        return ok
    end

    -- ===== 資料庫 =====
    -- 格式：cmd|off|type|中文|說明|參數
    -- type: t=toggle(有開關) / a=action(單次) / v=value(要輸入)
    local DB_RAW = [[
# 飛行與移動
fly|unfly|t|自由飛行|脫離重力自由移動，WASD 沿視角方向飛。點擊開啟，再點關閉。|
flyspeed||v|飛行速度|數字越大飛越快，預設 20。建議 10-100 之間。|[數值]
vfly|unvfly|t|載具飛行|坐在載具入面自由飛。| 
vflyspeed||v|載具飛行速度|調整載具飛行速度，預設 1。|[數值]
cfly|uncfly|t|CFly 飛行|用 CFrame 移動，可繞過部分反作弊，手機可用。|
cflyspeed||v|CFly 速度|調整 CFly 移動速度。|[數值]
float|unfloat|t|懸浮平台|腳下生成隱形平台，可浮空。按 Q 下降 / E 上升。|
swim|unswim|t|空中游泳|在陸地上模擬游泳狀態，可空中滑行。|
noclip|clip|t|穿牆模式|身體穿過所有物件，唔會被牆阻擋。|
tpwalk|untpwalk|t|傳送行走|移動時高速前移，比加速更難檢測。|
tpwalkspeed||v|傳送行走速度|調整傳送行走速度。|[數值]
infjump|uninfjump|t|無限跳躍|落地前可再次跳躍，空中連跳。|
autojump|unautojump|t|自動跳躍|撞到物件時自動跳起。|
edgejump|unedgejump|t|邊緣跳|走到平台邊緣時自動跳起。|
flyjump|unflyjump|t|飛跳|按住空白鍵持續上升，放開則下墜。|
jump||a|跳躍|立即觸發一次跳躍動作。|
speed||v|移動速度|調整行走速度，Roblox 預設 16。設定 50 明顯加速。|[數值]
jumppower||v|跳躍力|調整跳躍高度，預設 50。100 可跳很高。|[數值]
hipheight||v|臀部高度|調整角色與地面距離，預設 2（R15）/ 0（R6）。|[數值]
gravity||v|重力|修改世界重力，預設 196.2。設定 0 可漂浮。|[數值]
maxslopeangle||v|最大坡度|可爬嘅最斜角度，預設 89。|[數值]
walkfling|unwalkfling|t|行走甩人|碰觸時高速甩飛，無需工具。|
flyfling|unflyfling|t|飛甩|結合飛行嘅甩人方式。|
fling|unfling|t|甩人|每次觸碰都甩飛對方，需站在地面。|
antifling|unantifling|t|防甩|阻止其他玩家甩你。|

# 傳送
goto||v|傳送到玩家|瞬間移動到指定玩家身旁。|[玩家]
tgoto||v|Tween 傳送|用平滑動畫移動到玩家，較少觸發反作弊。|[玩家]
vgoto||v|載具傳送|坐下載具後整個載具移動到玩家位置。|[玩家]
loopgoto|unloopgoto|t|循環跟隨|持續不停傳送到目標玩家。|
pulsetp||v|脈衝傳送|瞬間傳到目標，停留指定秒數後返回原位。|[玩家] [秒數]
tppos||v|傳送到座標|直接傳送到世界座標。|[X Y Z]
ttppos||v|Tween 到座標|用平滑動畫傳送到座標。|[X Y Z]
offset||v|座標偏移|以當前位置為基準偏移指定距離。|[X Y Z]
toffset||v|Tween 座標偏移|用平滑動畫做座標偏移。|[X Y Z]
thru||v|向前穿透|朝角色面向方向向前移動 N studs。|[距離]
walktopos||v|走到座標|讓角色自動走向座標。|[X Y Z]
mousetp||a|傳送到滑鼠|瞬間移動到滑鼠指向位置。|
gotocam||a|傳送到相機|移動到當前相機位置。|
flashback||a|回到死亡點|傳送回上次死亡的位置。|
spawn||a|設定重生點|將當前位置設為重生點，重進遊戲後回到此處。|
nospawn||a|移除重生點|清除自訂重生點。|
tptool||a|傳送工具|獲得一個點擊即可傳送嘅工具。|
walltp|nowalltp|t|牆壁傳送|撞到牆時自動穿過或爬到牆頂。|
back||a|返回上一位置|返回上次傳送前的位置。|
notifypos||v|顯示玩家座標|通知某玩家的當前座標。|[玩家]
copypos||v|複製座標|複製某玩家座標到剪貼板。|[玩家]

# 傳送點管理
swp||v|設定傳送點|用當前位置建立一個命名傳送點。|[名稱]
wpp||v|設定座標傳送點|用指定座標建立傳送點。|[名稱] [X Y Z]
wp||v|傳送到傳送點|傳送到指定命名傳送點。|[名稱]
twp||v|Tween 到傳送點|平滑移動到傳送點。|[名稱]
wtwp||v|走到傳送點|自動走向傳送點。|[名稱]
dwp||v|刪除傳送點|移除指定傳送點。|[名稱]
waypoints||a|列出傳送點|顯示所有已儲存傳送點。|
cwp||a|清空傳送點|刪除所有傳送點。|
cgamewp||a|清空本遊戲傳送點|只刪除屬於當前遊戲嘅傳送點。|
tspeed||v|Tween 速度|調整所有 Tween 類命令的移動速度。|[數值]

# 相機與視角
freecam|unfreecam|t|自由視角|相機脫離角色自由移動，WASD 移動。|
fcpos||v|自由視角到座標|開啟自由視角並移動到指定座標。|[X Y Z]
fctp||v|自由視角到玩家|開啟自由視角並移動到玩家位置。|[玩家]
fcspeed||v|自由視角速度|調整自由視角移動速度。|[數值]
lookat||v|看向玩家|把相機強制轉向目標玩家。|[玩家]
fov||v|視野範圍|調整相機 FOV，預設 70。120 可看到更廣。|[數值]
maxzoom||v|最大縮放|相機能拉最遠的距離。|[數值]
minzoom||v|最小縮放|相機能拉最近的距離。0.5 可第一人稱。|[數值]
camdistance||v|相機距離|把相機固定在某個距離。|[數值]
firstp||a|第一人稱|強制切換第一人稱視角。|
thirdp||a|第三人稱|切回正常第三人稱視角。|
noclipcam||a|穿牆相機|相機可穿過牆壁看到場景。|
fixcam||a|修復相機|重置相機到正常狀態。|
enableshiftlock||a|啟用 Shift 鎖|開啟 Roblox 內建 Shift 鎖定功能。|
ctrllock||a|Ctrl 鍵鎖定|將 Shift 鎖定鍵改為左 Ctrl。|
unctrllock||a|還原鎖定鍵|將鎖定鍵還原為預設左 Shift。|
ms||v|滑鼠靈敏度|調整滑鼠靈敏度，預設 1。|[0-10]

# 玩家互動
view||v|觀察玩家|相機切換到目標玩家視角。|[玩家]
unview||a|停止觀察|恢復自己相機。|
freeze||v|凍結玩家|把目標玩家所有部件錨定，無法移動。|[玩家]
thaw||v|解凍玩家|解除目標玩家的錨定狀態。|[玩家]
bring||v|拉過來|把指定玩家拉到你身邊。|[玩家]
cbring||v|拉過來(客戶端)|只在你視角拉人（不會真實移動）。|[玩家]
loopbring|unloopbring|t|循環拉人|持續不停把玩家拉到你身邊。|
locate||v|定位玩家|顯示目標玩家位置、血量、距離。|[玩家]
nolocate||v|取消定位|移除目標玩家定位。|[玩家] / 留空取消全部
hitbox||v|調整碰撞箱|放大某玩家碰撞箱，方便攻擊。|[玩家] [大小]
headsize||v|調整頭部|放大某玩家頭部尺寸。|[玩家] [大小]
stareat|unstareat|t|凝視玩家|角色持續面向目標玩家。|
scare||v|驚嚇玩家|瞬間出現在目標面前 0.5 秒。|[玩家]
carpet|uncarpet|t|當地毯|躺在目標玩家腳下跟隨移動。|
headsit||v|坐頭頂|坐在目標玩家頭頂。|[玩家]
walkto|unwalkto|t|跟隨玩家|持續走向目標玩家。|
pathfindwalkto||v|尋路跟隨|用尋路系統跟隨目標，能繞過障礙。|[玩家]
orbit|unorbit|t|環繞玩家|繞住目標玩家轉圈，可調速度距離。|
bang|unbang|t|撞擊|對目標玩家做出撞擊動作，需工具。|
handlekill||v|手柄殺|用工具手柄碰觸傷害玩家，需手持工具。|[玩家] [範圍]
friend||v|加好友|向目標玩家發送好友請求。|[玩家]
unfriend||v|刪好友|從好友名單移除目標玩家。|[玩家]
jerk||a|抽動動作|做出特殊動作（需工具）。|
loopoof|unloopoof|t|循環 OOF|讓所有人的死亡音效無限重播。|
muteboombox||v|靜音音響|靜音目標玩家的音響音樂。|[玩家]
unmuteboombox||v|取消靜音音響|恢復目標玩家的音響音樂。|[玩家]
rolewatch||v|角色監視|監視指定群組的某角色入場。|[群組ID] [角色名]
rolewatchstop||a|停止角色監視|停止角色監視。|
rolewatchleave||a|切換自動離開|開啟後有人加入即自動退出伺服器。|
staffwatch||a|員工監視|監視有管理權限嘅玩家入場。|
unstaffwatch||a|停止員工監視|停止員工監視。|
findfriendgroups||a|尋找好友群|分析玩家之間的好友關係群組。|
hitboxes||a|顯示碰撞箱|顯示所有物件的碰撞邊界框。|
unhitboxes||a|隱藏碰撞箱|關閉碰撞箱顯示。|
hovername|unhovername|t|懸停顯示名字|滑鼠懸停在玩家身上顯示其名字。|

# 透視與視覺
esp|noesp|t|玩家透視|方塊 + 名稱 + 血量 + 距離資訊。|
espteam|noesp|t|隊伍透視|同 esp，但隊友綠色、敵人紅色。|
chams|nochams|t|色塊透視|只顯示彩色方塊，不含文字。|
esptransparency||v|透視透明度|調整透視方塊的透明度，0 最透明。|[數值]
partesp|unpartesp|t|部件透視|高亮指定的部件名稱。|[部件名]
xray|unxray|t|透視牆壁|讓所有部件半透明，看穿地圖。|
loopxray|unloopxray|t|循環透視牆|持續保持透視狀態。|
fullbright||a|全亮|把光照拉到最亮，看清暗處。|
loopfullbright|unloopfullbright|t|循環全亮|持續保持全亮狀態。|
day||a|白天|把遊戲時間設為白天 14:00。|
night||a|夜晚|把遊戲時間設為夜晚 00:00。|
nofog||a|去霧|移除場景霧氣。|
brightness||v|亮度|調整光照亮度。|[0-5]
ambient||v|環境光顏色|設定環境光 RGB。|[R G B]
gshadows|nogshadows|t|全局陰影|開啟全局陰影效果。|
restorelighting||a|恢復光照|把光照恢復到原始設定。|
light|unlight|t|角色光源|在角色身上加一盞燈。|[半徑] [亮度]
removeads||a|去廣告|移除遊戲內的廣告看板（循環）。|
antivoid|unantivoid|t|防虛空|掉出地圖時自動向上推回。|
fakeout||a|假傳送|瞬間掉入虛空再返回，甩開跟隨者。|
norender|render|t|停止渲染|關閉 3D 渲染節省 CPU。|
use2022materials|unuse2022materials|t|2022 材質|啟用 2022 新版 Roblox 材質。|

# 聊天
chat||v|發送聊天|發送指定文字到公頻。|[文字]
spam|unspam|t|刷屏|持續重複發送指定文字。|[文字]
whisper||v|私聊|向指定玩家發送私訊。|[玩家] [訊息]
pmspam|unpmspam|t|刷私聊|持續向指定玩家發私訊。|
spamspeed||v|刷屏速度|兩次發送之間的間隔秒數，預設 1。|[數值]
bubblechat|unbubblechat|t|氣泡聊天|顯示玩家頭頂的氣泡對話框。|
chatwindow|unchatwindow|t|聊天視窗|顯示/隱藏聊天視窗。|
darkchat||a|深色聊天|把聊天介面改為深色主題。|
listento|unlistento|t|監聽玩家|把音訊監聽器移到目標玩家位置。|[玩家]
muteallvoices|unmuteallvoices|t|靜音全部語音|靜音所有玩家的語音聊天。|
mutevc||v|靜音單人語音|靜音指定玩家的語音。|[玩家]
unmutevc||v|取消靜音單人|恢復指定玩家的語音。|[玩家]
phonebook||a|電話簿|開啟 Roblox 電話簿介面（需語音功能）。|

# 角色控制
respawn||a|重生|立即讓角色死亡並重生。|
refresh||a|刷新回到原位|重生但保持當前位置和相機。|
reset||a|重置角色|正常死亡重置。|
god||a|上帝模式|複製 Humanoid 防止常規死亡，對部分遊戲無效。|
invisible|visible|t|隱身|對其他玩家隱形。|
toolinvis||a|工具隱身|隱身但仍可使用工具。|
toggleinvis||a|切換隱身|用一條命令切換隱身狀態。|
sit||a|坐下|讓角色坐下。|
lay||a|躺下|讓角色躺平。|
sitwalk||a|坐著走|坐姿但可以移動，搞笑效果。|
nosit|unnosit|t|禁止坐下|阻止角色被強制坐下。|
stun|unstun|t|平台站立|強制角色進入 PlatformStand，無法移動。|
norotate|unnorotate|t|禁止旋轉|關閉角色自動面向移動方向。|
anchor|unanchor|t|錨定角色|固定角色在當前位置。|
weaken||a|變輕|降低角色密度，可被輕易推動。|
strengthen||v|變重|增加角色密度，較難被推動。|[數值]
unweaken||a|恢復重量|把密度還原到預設值。|
breakvelocity||a|停止移動|把所有部件速度歸零。|
spin|unspin|t|旋轉角色|讓角色高速旋轉。|[速度]
split||a|身體分裂|切斷角色腰部，分成兩半。|
nilchar|unnilchar|t|角色消失|把角色從工作區移除（本機）。|
noroot||a|移除根部件|刪除 HumanoidRootPart。|
replaceroot||a|替換根部件|重新生成一個 HumanoidRootPart。|
clearchar||a|清除外觀|移除所有衣物、飾品、身體顏色。|
trip||a|絆倒|讓角色跌倒在地。|
wallwalk||a|牆上行走|可以在牆壁上行走（載入外部腳本）。|
promptr6||a|切換 R6|提示遊戲切換角色骨骼為 R6。|
promptr15||a|切換 R15|提示遊戲切換角色骨骼為 R15。|
freezeanims|unfreezeanims|t|凍結動畫|把所有動畫速度歸零。|
animspeed||v|動畫速度|調整當前動畫播放速度。|[數值]
dance|undance|t|跳舞|播放隨機舞蹈動畫。|
spasm|unspasm|t|抽搐|播放快速抽搐動畫。|
headthrow||a|扔頭|做出扔頭動作。|
noanim|reanim|t|關閉動畫|暫停所有角色動畫。|
loopanim||a|循環動畫|讓當前動畫無限循環。|
stopanims||a|停止所有動畫|停止當前所有播放中的動畫。|
refreshanims||a|刷新動畫|重置動畫系統。|
allowcustomanim|unallowcustomanim|t|允許自訂動畫|允許外部自訂動畫包。|
animation||v|播放動畫|播放指定 ID 的動畫。|[動畫ID] [速度]
emote||v|播放表情|播放指定 ID 的表情。|[動畫ID] [速度]
copyanim||v|複製玩家動畫|複製目標玩家當前播放的動畫。|[玩家]
copyanimid||v|複製動畫 ID|把動畫 ID 複製到剪貼板。|[玩家]
autoclick|unautoclick|t|自動點擊|自動模擬滑鼠左鍵點擊。|
autoclickdelay||v|自動點擊延遲|每次點擊間隔秒數。|[數值]
autokeypress|unautokeypress|t|自動按鍵|自動模擬鍵盤按鍵按下/放開。|
clickdelete||a|點擊刪除提示|在 Keybind 設定中綁定滑鼠點擊刪除。|
clickteleport||a|點擊傳送提示|在 Keybind 設定中綁定滑鼠點擊傳送。|
team||v|切換隊伍|把玩家切換到指定隊伍。|[隊伍名]

# 外觀
noarms||a|移除手臂|刪除角色的手臂。|
nolegs||a|移除腿部|刪除角色的腿。|
nolimbs||a|移除四肢|刪除角色的手臂和腿。|
naked||a|裸體|移除所有衣物和飾品。|
noface||a|移除臉|刪除臉部貼圖。|
blockhead||a|方塊頭|把頭部變成方塊（R6）。|
blockhats||a|方塊帽|把所有帽子變成方塊。|
blocktool||a|方塊工具|把手中工具變成方塊。|
creeper||a|苦力怕造型|變成 Minecraft 苦力怕外形。|
drophats||a|掉帽子|把所有帽子丟到地上。|
nohats||a|刪除帽子|直接銷毀所有帽子。|
hatspin|unhatspin|t|旋轉帽子|讓帽子高速旋轉。|[速度]
clearhats||a|清除地上帽子|刪除工作區所有帽子。|
chardelete||v|刪除角色部件|刪除指定名稱的角色部件。|[部件名]
chardeleteclass||v|刪除角色部件類|按 ClassName 刪除角色部件。|[類名]

# 工具
tools||a|複製所有工具|從 ReplicatedStorage/Lighting 複製所有工具到背包。|
notools||a|清空所有工具|移除背包和角色身上所有工具。|
deleteselectedtool||a|刪除手中工具|銷毀當前手持的工具。|
btools||a|建築工具|獲得 Roblox 建築工具（HopperBin）。|
f3x||a|F3X 工具|載入 F3X 建築工具。|
grabtools|ungrabtools|t|自動抓工具|自動撿起地上掉落的工具。|
copytools||v|複製玩家工具|複製目標玩家所有工具到背包。|[玩家]
dupetools||v|複製手中工具|把手中工具複製 N 次。|[次數]
droptools||a|丟下工具|把手持工具全部丟到地上。|
droppabletools||a|允許丟棄|讓所有工具可以被丟棄。|
equiptools||a|裝備所有工具|把所有背包工具同時裝備。|
unequiptools||a|收起所有工具|收起所有手持工具。|
removespecifictool||v|持續移除指定工具|自動移除背包中指定名稱的工具。|[工具名]
unremovespecifictool||v|停止移除特定工具|取消指定工具的持續移除。|[工具名]
reach||v|延展工具|拉長手中工具觸及範圍。|[長度]
boxreach||v|盒子延展|把工具判定改成盒子形狀。|[邊長]
unreach||a|取消工具延展|恢復工具原始大小。|
grippos||v|握持位置|調整手持工具的握持偏移。|[X Y Z]
usetools||v|使用所有工具|同時激活背包所有工具。|[次數] [間隔]
partname||a|部件名工具|點擊部件顯示其路徑和名稱。|
firecd||v|觸發點擊探測器|觸發所有或指定名稱的 ClickDetector。|[名稱]
firetouchinterests||v|觸發觸摸|觸發所有 TouchTransmitter。|[名稱]
firepp||v|觸發靠近提示|觸發所有 ProximityPrompt。|[名稱]
instantpp|uninstantpp|t|即時靠近提示|無需按住等待，直接觸發靠近提示。|
nocdlimits||a|無限點擊距離|把 ClickDetector 觸發距離設為無限。|
nopplimits||a|無限提示距離|把 ProximityPrompt 觸發距離設為無限。|

# 物件操作
delete||v|刪除同名部件|刪除工作區所有同名部件。|[部件名]
deleteclass||v|刪除同類部件|按 ClassName 刪除部件。|[類名]
lockws||a|鎖定工作區|鎖定所有部件避免誤觸。|
unlockws||a|解鎖工作區|解除所有部件的鎖定。|
invisparts|uninvisparts|t|顯示隱形部件|把透明部件顯示出來。|
dip||a|刪除隱形部件|刪除所有透明且可碰撞的部件。|
gotopart||v|移動到部件|把角色移動到指定部件位置。|[部件名]
tgotopart||v|Tween 到部件|用平滑動畫移動到部件。|[部件名]
gpc||v|移動到部件類|移動到指定 ClassName 的所有部件。|[類名]
tgpc||v|Tween 到部件類|Tween 移動到部件類。|[類名]
gotomodel||v|移動到模型|移動到指定模型位置。|[模型名]
tgotomodel||v|Tween 到模型|Tween 移動到模型。|[模型名]
bringpart||v|拉部件過來|把指定部件拉到角色位置。|[部件名]
bpc||v|拉部件類|把指定 ClassName 部件拉到身邊。|[類名]
tpua||v|拉未錨定部件|把所有未錨定部件拉向目標玩家。|[玩家]
freezeua|thawua|t|凍結未錨定|凍結所有未錨定部件（除了玩家角色）。|
noterrain||a|移除地形|刪除所有地形。|
cni||a|清除空實例|清除所有 parent 為 nil 的實例。|
destroyheight||v|設定破壞高度|設定 FallenPartsDestroyHeight。|[數值]

# 世界與伺服器
serverinfo||a|伺服器資訊|顯示當前伺服器詳細資訊。|
jobid||a|複製 JobId|把當前 JobId 複製到剪貼板。|
notifyjobid||a|通知 JobId|顯示當前 JobId 通知。|
rejoin||a|重新加入|重新加入當前伺服器。|
serverhop||a|換伺服器|跳轉到隨機其他伺服器。|
gametp||v|遊戲傳送|按 PlaceId 進入另一個遊戲。|[PlaceId]
discord||a|Discord 邀請|複製 IY 官方 Discord 連結。|
inviteprompt||v|邀請提示|顯示 Roblox 邀請提示。|[玩家]
autorejoin||a|自動重進|被踢出時自動重進。|
antiafk||a|防掛機|防止因閒置被踢出。|
datalimit||v|數據限制|限制網路發送速率。|[kbps]
replicationlag||v|網路延遲|設定 IncomingReplicationLag。|[數值]
creatorid||a|顯示創作者 ID|顯示遊戲創作者 ID。|
copycreatorid||a|複製創作者 ID|複製創作者 ID 到剪貼板。|
noprompts|showprompts|t|禁止購買提示|阻止遊戲彈出購買/進階會員提示。|
enable||v|啟用核心 UI|啟用 Roblox 核心 UI。|[inventory/playerlist/chat/reset]
disable||v|停用核心 UI|停用 Roblox 核心 UI。|[inventory/playerlist/chat/reset]
showguis||a|顯示所有 GUI|顯示所有原本隱藏的 GUI。|
unshowguis||a|還原顯示 GUI|還原 showguis 的改動。|
hideguis||a|隱藏所有 GUI|隱藏 PlayerGui 所有 GUI。|
unhideguis||a|還原隱藏 GUI|還原 hideguis 的改動。|
guidelete|unguidelete|t|GUI 刪除模式|按住 Backspace 並點擊可刪除 GUI。|
hideiy||a|隱藏 IY|把原版 IY 視窗縮到最小。|
showiy||a|顯示 IY|重新顯示原版 IY 視窗。|
keepiy|unkeepiy|t|傳送保留 IY|傳送後自動重新執行 IY。|
savegame||a|保存遊戲|用 saveinstance 把整個遊戲下載到本地。|
clearerror||a|清除錯誤提示|清除遊戲斷線的錯誤彈窗。|
antipaused|unantipaused|t|防遊戲暫停|阻止資源載入時嘅暫停提示。|
clientantikick||a|客戶端防踢|阻止本地腳本踢你（非伺服器端）。|
clientantiteleport||a|客戶端防傳送|阻止本地腳本傳送。|
allowrejoin||a|允許重新加入|切換客戶端防傳送是否允許重進。|
cancelteleport||a|取消傳送|取消正在進行的傳送。|
volume||v|音量|調整遊戲主音量。|[0-10]
antilag||a|防卡頓|降低畫質提升 FPS。|
fpscap||v|設定 FPS 上限|限制遊戲最大幀率。|[數值]
record||a|開始錄影|啟動 Roblox 內建錄影。|
screenshot||a|截圖|截取當前畫面。|
togglefs||a|切換全屏|切換全屏/視窗模式。|
notify||v|發送通知|彈出 Roblox 原生通知。|[文字]
lastcommand||a|重複上一命令|執行你上一條命令。|
ping||a|顯示延遲|顯示當前網路延遲毫秒。|
alignmentkeys|unalignmentkeys|t|對齊按鍵|啟用 , 和 . 鍵做相機左右轉。|
exit||a|退出遊戲|立即退出 Roblox。|
removecmd||v|移除命令|暫時移除指定命令直到重載腳本。|[命令名]
breakloops||a|停止所有循環|停止所有 5^btools 類型的循環命令。|
debug||v|調試模式|開啟調試輸出。|[true/false]
guiscale||v|介面縮放|調整 IY 介面大小，預設 1。|[0.4-2]

# 資訊查詢
inspect||v|檢查玩家|打開目標玩家的詳細資料面板。|[玩家]
age||v|帳號年齡|顯示目標玩家的帳號年齡（天）。|[玩家]
chatage||v|聊天帳號年齡|把目標年齡發到聊天。|[玩家]
joindate||v|加入日期|顯示目標加入 Roblox 的日期。|[玩家]
chatjoindate||v|聊天加入日期|把加入日期發到聊天。|[玩家]
copyname||v|複製玩家名字|把玩家完整用戶名複製到剪貼板。|[玩家]
userid||v|顯示用戶 ID|顯示目標玩家 UserId。|[玩家]
copyid||v|複製用戶 ID|把 UserId 複製到剪貼板。|[玩家]
copyplaceid||a|複製 PlaceId|把當前遊戲 PlaceId 複製到剪貼板。|
copygameid||a|複製 GameId|把遊戲 GameId 複製到剪貼板。|
aid||v|顯示外觀 ID|顯示玩家 CharacterAppearanceId。|[玩家]
caid||v|複製外觀 ID|複製玩家外觀 ID 到剪貼板。|[玩家]

# 開發工具
console||a|打開控制台|顯示 Roblox 開發者控制台（F9）。|
oldconsole||a|舊版控制台|載入舊主題控制台。|
dex||a|Dex 資源管理器|開啟 Dex++ 資源管理器。|
mdex||a|MoonDex|開啟 Moon 的 DEX。|
rspy||a|遠程監視器|開啟 Cobalt 遠程監視器。|
sspy||a|簡易監視器|開啟 SimpleSpy V3。|
alogger||a|音頻日誌|開啟 Edge 音頻記錄器。|

# 插件與別名
addalias||v|新增別名|為命令新增自訂別名。|[命令] [別名]
removealias||v|移除別名|移除指定別名。|[別名]
clraliases||a|清空所有別名|刪除全部自訂別名。|
addplugin||v|新增插件|載入指定 .iy 插件文件。|[檔名]
removeplugin||v|移除插件|卸載指定插件。|[檔名]
reloadplugin||v|重載插件|重新載入插件。|[檔名]
addallplugins||a|載入所有插件|載入 workspace 中所有 .iy 插件。|

# 日誌
logs||a|開啟日誌|顯示日誌面板。|
clogs||a|聊天日誌|記錄聊天內容到日誌面板。|
jlogs||a|加入日誌|記錄玩家加入訊息到日誌面板。|
logswebhook||v|日誌 Webhook|把日誌發送到 Discord Webhook。|[URL]
]]

    -- ===== 解析資料 =====
    local DB = {}
    local currentCat = nil
    for raw in DB_RAW:gmatch("[^\r\n]+") do
        if raw:match("^#") then
            currentCat = {name = raw:sub(2):gsub("^%s+", ""), items = {}}
            table.insert(DB, currentCat)
        elseif raw ~= "" and currentCat then
            local parts = {}
            for p in (raw.."|||||"):gmatch("([^|]*)|") do table.insert(parts, p) end
            local off = parts[2] ~= "" and parts[2] or nil
            local type = parts[3]
            local params = parts[6] or ""
            if type == "t" and not off then type = "a" end
            table.insert(currentCat.items, {
                cmd = parts[1],
                off = off,
                type = type,
                zh = parts[4] ~= "" and parts[4] or parts[1],
                desc = parts[5] ~= "" and parts[5] or "（未提供說明）",
                params = params,
            })
        end
    end

    -- ===== 選擇器 / 語法（獨立分類） =====
    local selectors = {
        {label="all（全體玩家）",       v="all",        desc="包含伺服器內所有玩家。\n\n用法：\n  locate all\n  freeze all"},
        {label="others（除我以外）",    v="others",     desc="所有人但不包含自己。\n\n用法：\n  kill others\n  bring others"},
        {label="me（只有我）",          v="me",         desc="只選中自己。\n\n用法：\n  view me"},
        {label="@用戶名（精確搜尋）",   v="@username",  desc="按 Roblox 用戶名精確搜尋，忽略顯示名稱。\n\n用法：\n  goto @notfish"},
        {label="#N（隨機 N 人）",       v="#3",         desc="從伺服器隨機抽 N 位玩家。\n\n用法：\n  #3 → 隨機 3 位\n  goto #2 → 傳送到隨機 2 位"},
        {label="random（隨機 1 人）",   v="random",     desc="隨機選中一位玩家（不含自己）。\n\n用法：\n  freeze random"},
        {label="%隊伍名（指定隊伍）",   v="%Red",       desc="選中指定隊伍的所有玩家。\n\n用法：\n  locate %Blue\n  kill %Red"},
        {label="allies（隊友）",        v="allies",     desc="選中與你同隊的玩家。\n\n用法：\n  bring allies"},
        {label="enemies（敵人）",       v="enemies",    desc="選中非你隊伍的玩家。\n\n用法：\n  fling enemies"},
        {label="friends（好友）",       v="friends",    desc="選中與你互為好友的玩家。\n（剛加好友可能延遲生效）"},
        {label="nonfriends（非好友）",  v="nonfriends", desc="選中與你不是好友的玩家。"},
        {label="guests（訪客）",        v="guests",     desc="選中訪客玩家（多數已不存在）。"},
        {label="bacons（Bacon 頭）",    v="bacons",     desc="選中戴 Pal Hair / Kate Hair（Bacon 頭）的玩家。"},
        {label="ageN（年齡以下）",      v="age15",      desc="選中帳號年齡 ≤ N 天的玩家。\n\n用法：\n  age15 → 15 天以下\n  -age15 → 15 天以上"},
        {label="radN（半徑 N 內）",     v="rad50",      desc="選中距離你 ≤ N studs 的玩家。\n\n用法：\n  rad50\n  freeze rad100"},
        {label="nearest（最近的玩家）", v="nearest",    desc="選中離你最近的玩家。"},
        {label="farthest（最遠的玩家）",v="farthest",   desc="選中離你最遠的玩家。"},
        {label="groupID（群組成員）",   v="group123456",desc="選中某 Roblox 群組的所有在場玩家。\n\n用法：\n  group123456"},
        {label="alive（存活玩家）",     v="alive",      desc="選中所有存活玩家。"},
        {label="dead（死亡玩家）",      v="dead",       desc="選中所有死亡玩家。"},
        {label="cursor（滑鼠最近）",    v="cursor",     desc="選中滑鼠游標最近的玩家。"},
        {label="npcs（遊戲 NPC）",      v="npcs",       desc="搜尋遊戲中所有 NPC（非玩家角色）。"},
        {label="逗號分隔（多玩家）",    v="noob,noob2", desc="一次命令同時選中多位玩家。\n\n用法：\n  locate noob,noob2,bob\n  freeze A,B,C"},
        {label="-/+ 前綴（排除/交集）", v="-age15",     desc="在選擇器前加 - 表示排除、加 + 表示交集。\n\n-age15 → 15天以上\n%blue-friends → 藍隊非好友\n+friends+alive → 好友且存活"},
    }

    local syntaxItems = {
        {label="循環執行（次數^延遲^命令）", v="5^btools",
         desc="格式：[次數]^[延遲秒]^[命令]\n\n例：\n  5^btools → 給5次工具\n  10^3^drophats → 每3秒掉帽，共10次\n  inf^0.1^animspeed 100 → 無限循環\n\n停止：breakloops"},
        {label="一次執行多條命令", v="drophats\\respawn",
         desc="用反斜線 \\ 分隔，一次執行多條命令。\n\n例：\n  drophats\\respawn\n  enable inventory\\enable playerlist\\refresh"},
        {label="命令歷史（↑ / ↓）", v="",
         desc="命令列聚焦時按 ↑ / ↓ 瀏覽最近使用過的命令。"},
        {label="自動完成（Tab）", v="",
         desc="命令列聚焦時按 Tab 插入最頂的建議命令。"},
        {label="排除 / 包含（- 與 +）", v="-age15",
         desc="選擇器前綴：\n  - 排除\n  + 交集/包含\n\n例：\n  -age15 → 15天以上\n  +friends+alive → 好友且存活"},
        {label="多玩家逗號分隔", v="A,B,C",
         desc="一次命令選擇多位玩家。\n\n例：\n  locate noob,noob2,bob"},
        {label="玩家選擇器速查", v="",
         desc="all / others / me / @name / #N / random / %team\nallies / enemies / friends / nonfriends / guests / bacons\nageN / radN / nearest / farthest / groupID / alive / dead / cursor / npcs"},
    }

    -- ===== 開關狀態追蹤 =====
    local toggleState = {}

    -- ===== 構建右欄 =====
    local btnMap = {}  -- cmd -> {btn, dot, stateLabel}

    local function clearPane()
        for _, c in ipairs(rightPane:GetChildren()) do
            if c ~= rightL then c:Destroy() end
        end
        btnMap = {}
    end

    local function updateToggleVisual(cmd)
        local entry = btnMap[cmd]
        if not entry then return end
        local on = toggleState[cmd]
        if on then
            entry.btn.BackgroundColor3 = Color3.fromRGB(45, 90, 55)
            entry.dot.BackgroundColor3 = Color3.fromRGB(80, 220, 100)
            entry.badge.Text = "開"
            entry.badge.TextColor3 = Color3.fromRGB(140, 255, 160)
        else
            entry.btn.BackgroundColor3 = Color3.fromRGB(56, 56, 58)
            entry.dot.BackgroundColor3 = Color3.fromRGB(120, 120, 125)
            entry.badge.Text = "關"
            entry.badge.TextColor3 = Color3.fromRGB(140, 140, 145)
        end
    end

    local function makeCmdButton(item, order)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -8, 0, 40)
        btn.BackgroundColor3 = Color3.fromRGB(56, 56, 58)
        btn.BorderSizePixel = 0; btn.Text = ""
        btn.LayoutOrder = order; btn.Parent = rightPane

        -- 狀態圓點
        local dot = Instance.new("Frame")
        dot.Size = UDim2.fromOffset(8, 8); dot.Position = UDim2.fromOffset(6, 8)
        dot.BackgroundColor3 = Color3.fromRGB(120, 120, 125)
        dot.BorderSizePixel = 0; dot.ZIndex = 2
        local dc = Instance.new("UICorner"); dc.CornerRadius = UDim.new(0.5, 0); dc.Parent = dot
        dot.Parent = btn
        if item.type ~= "t" then dot.Visible = false end

        -- 中文名
        local name = Instance.new("TextLabel")
        name.BackgroundTransparency = 1
        name.Size = UDim2.new(1, -58, 0, 16)
        name.Position = UDim2.fromOffset(20, 2)
        name.Font = Enum.Font.SourceSansSemibold; name.TextSize = 13
        name.TextColor3 = Color3.fromRGB(230, 230, 230)
        name.TextXAlignment = Enum.TextXAlignment.Left
        name.Text = item.zh .. (item.type == "v" and "  ✎" or "")
        name.ZIndex = 2; name.Parent = btn

        -- 參數提示（右上）
        local params = Instance.new("TextLabel")
        params.BackgroundTransparency = 1
        params.Size = UDim2.new(0, 60, 0, 16)
        params.Position = UDim2.new(1, -62, 0, 2)
        params.Font = Enum.Font.SourceSans; params.TextSize = 10
        params.TextColor3 = Color3.fromRGB(150, 200, 255)
        params.TextXAlignment = Enum.TextXAlignment.Right
        params.Text = item.params
        params.ZIndex = 2; params.Parent = btn

        -- 說明（第二行）
        local desc = Instance.new("TextLabel")
        desc.BackgroundTransparency = 1
        desc.Size = UDim2.new(1, -28, 0, 18)
        desc.Position = UDim2.fromOffset(20, 18)
        desc.Font = Enum.Font.SourceSans; desc.TextSize = 11
        desc.TextColor3 = Color3.fromRGB(150, 150, 155)
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.TextYAlignment = Enum.TextYAlignment.Top
        desc.TextTruncate = Enum.TextTruncate.AtEnd
        desc.Text = item.desc
        desc.ZIndex = 2; desc.Parent = btn

        -- 開關徽章
        local badge = Instance.new("TextLabel")
        badge.BackgroundTransparency = 1
        badge.Size = UDim2.new(0, 24, 0, 16)
        badge.Position = UDim2.new(1, -30, 0, 2)
        badge.Font = Enum.Font.SourceSansBold; badge.TextSize = 11
        badge.TextColor3 = Color3.fromRGB(140, 140, 145)
        badge.Text = "關"; badge.ZIndex = 2; badge.Parent = btn
        if item.type ~= "t" then badge.Visible = false end

        btn.MouseEnter:Connect(function()
            if not (item.type == "t" and toggleState[item.cmd]) then
                TS:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(72, 72, 75)}):Play()
            end
            toast(item.cmd .. (item.params ~= "" and (" " .. item.params) or "") .. " — " .. item.zh)
        end)
        btn.MouseLeave:Connect(function()
            if not (item.type == "t" and toggleState[item.cmd]) then
                TS:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(56, 56, 58)}):Play()
            end
        end)

        btn.MouseButton1Click:Connect(function()
            if item.type == "t" and item.off then
                local on = toggleState[item.cmd]
                if on then
                    run(item.off, item.zh .. " 關閉")
                    toggleState[item.cmd] = false
                else
                    run(item.cmd, item.zh .. " 開啟")
                    toggleState[item.cmd] = true
                end
                updateToggleVisual(item.cmd)
            elseif item.type == "v" then
                openInput(item.zh, "命令：" .. item.cmd .. (item.params ~= "" and ("  參數：" .. item.params) or ""),
                    item.params ~= "" and item.params or "輸入參數", function(val)
                    val = val:gsub("^%s+", ""):gsub("%s+$", "")
                    local full = item.cmd .. (val ~= "" and (" " .. val) or "")
                    run(full, item.zh)
                end)
            else
                run(item.cmd, item.zh)
            end
        end)

        btnMap[item.cmd] = {btn = btn, dot = dot, badge = badge}
        if item.type == "t" then updateToggleVisual(item.cmd) end
    end

    local function buildCategory(catData)
        clearPane()
        for i, item in ipairs(catData.items) do
            makeCmdButton(item, i)
        end
        rightPane.CanvasSize = UDim2.new(0, 0, 0, rightL.AbsoluteContentSize.Y + 8)
    end

    -- 選擇器 / 語法構建
    local function buildSelectors()
        clearPane()
        for i, s in ipairs(selectors) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -8, 0, 40)
            btn.BackgroundColor3 = Color3.fromRGB(56, 56, 58)
            btn.BorderSizePixel = 0; btn.Text = ""
            btn.LayoutOrder = i; btn.Parent = rightPane

            local name = Instance.new("TextLabel")
            name.BackgroundTransparency = 1
            name.Size = UDim2.new(1, -14, 0, 16)
            name.Position = UDim2.fromOffset(8, 2)
            name.Font = Enum.Font.SourceSansSemibold; name.TextSize = 13
            name.TextColor3 = Color3.fromRGB(230, 230, 230)
            name.TextXAlignment = Enum.TextXAlignment.Left
            name.Text = s.label; name.ZIndex = 2; name.Parent = btn

            local desc = Instance.new("TextLabel")
            desc.BackgroundTransparency = 1
            desc.Size = UDim2.new(1, -16, 0, 18)
            desc.Position = UDim2.fromOffset(8, 18)
            desc.Font = Enum.Font.SourceSans; desc.TextSize = 11
            desc.TextColor3 = Color3.fromRGB(150, 150, 155)
            desc.TextXAlignment = Enum.TextXAlignment.Left
            desc.TextYAlignment = Enum.TextYAlignment.Top
            desc.TextTruncate = Enum.TextTruncate.AtEnd
            desc.Text = s.desc:gsub("\n", " "):gsub("用法：", "")
            desc.ZIndex = 2; desc.Parent = btn

            btn.MouseEnter:Connect(function()
                TS:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(72, 72, 75)}):Play()
            end)
            btn.MouseLeave:Connect(function()
                TS:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(56, 56, 58)}):Play()
            end)
            btn.MouseButton1Click:Connect(function()
                showInfo(s.label, s.desc, s.v)
            end)
        end
        rightPane.CanvasSize = UDim2.new(0, 0, 0, rightL.AbsoluteContentSize.Y + 8)
    end

    local function buildSyntax()
        clearPane()
        for i, s in ipairs(syntaxItems) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -8, 0, 40)
            btn.BackgroundColor3 = Color3.fromRGB(56, 56, 58)
            btn.BorderSizePixel = 0; btn.Text = ""
            btn.LayoutOrder = i; btn.Parent = rightPane

            local name = Instance.new("TextLabel")
            name.BackgroundTransparency = 1
            name.Size = UDim2.new(1, -14, 0, 16)
            name.Position = UDim2.fromOffset(8, 2)
            name.Font = Enum.Font.SourceSansSemibold; name.TextSize = 13
            name.TextColor3 = Color3.fromRGB(230, 230, 230)
            name.TextXAlignment = Enum.TextXAlignment.Left
            name.Text = s.label; name.ZIndex = 2; name.Parent = btn

            local desc = Instance.new("TextLabel")
            desc.BackgroundTransparency = 1
            desc.Size = UDim2.new(1, -16, 0, 18)
            desc.Position = UDim2.fromOffset(8, 18)
            desc.Font = Enum.Font.SourceSans; desc.TextSize = 11
            desc.TextColor3 = Color3.fromRGB(150, 150, 155)
            desc.TextXAlignment = Enum.TextXAlignment.Left
            desc.TextYAlignment = Enum.TextYAlignment.Top
            desc.TextTruncate = Enum.TextTruncate.AtEnd
            desc.Text = s.desc:gsub("\n", " ")
            desc.ZIndex = 2; desc.Parent = btn

            btn.MouseEnter:Connect(function()
                TS:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(72, 72, 75)}):Play()
            end)
            btn.MouseLeave:Connect(function()
                TS:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(56, 56, 58)}):Play()
            end)
            btn.MouseButton1Click:Connect(function()
                showInfo(s.label, s.desc, s.v)
            end)
        end
        rightPane.CanvasSize = UDim2.new(0, 0, 0, rightL.AbsoluteContentSize.Y + 8)
    end

    -- ===== 左欄 =====
    local catButtons = {}
    local function makeCat(name, order, onClick)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, -4, 0, 28)
        b.BackgroundColor3 = Color3.fromRGB(40, 40, 42)
        b.BorderSizePixel = 0; b.Font = Enum.Font.SourceSans
        b.TextSize = 13; b.TextColor3 = Color3.fromRGB(200, 200, 205)
        b.TextXAlignment = Enum.TextXAlignment.Left
        b.Text = "  " .. name
        b.LayoutOrder = order; b.Parent = leftPane
        table.insert(catButtons, b)
        b.MouseButton1Click:Connect(function()
            for _, x in ipairs(catButtons) do x.BackgroundColor3 = Color3.fromRGB(40, 40, 42) end
            b.BackgroundColor3 = Color3.fromRGB(75, 75, 80)
            onClick()
        end)
        return b
    end

    local ord = 0
    local function nextOrd() ord = ord + 1; return ord end

    makeCat("選擇器", nextOrd(), buildSelectors)
    makeCat("語法", nextOrd(), buildSyntax)
    for _, cat in ipairs(DB) do
        if #cat.items > 0 then
            makeCat(cat.name .. " (" .. #cat.items .. ")", nextOrd(), function() buildCategory(cat) end)
        end
    end

    leftPane.CanvasSize = UDim2.new(0, 0, 0, leftL.AbsoluteContentSize.Y + 4)

    if catButtons[1] then
        catButtons[1].BackgroundColor3 = Color3.fromRGB(75, 75, 80)
        buildSelectors()
    end

    local total = 0
    for _, cat in ipairs(DB) do total = total + #cat.items end
    toast(("繁中 Infinite Yield Reborn v4 已載入｜%d 條命令｜%d 個分類"):format(total, #DB))
end)
