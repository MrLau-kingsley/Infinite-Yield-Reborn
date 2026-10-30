-- ============================================================
-- Infinite Yield 繁體中文 UI v3
-- 400×275｜左類型右功能｜動態讀取全部 cmds（約 419 條）
-- 懸浮「中」按鈕切換（可拖動，拖動不誤觸）
-- ============================================================
task.spawn(function()
    task.wait(1.5)

    -- 等原版 cmds 表填充完成
    local t0 = tick()
    while (type(cmds) ~= "table" or #cmds == 0) and tick() - t0 < 10 do
        task.wait(0.1)
    end
    if type(execCmd) ~= "function" then
        warn("[繁中UI] 找不到 execCmd，請確認原版已完整執行")
        return
    end

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

    -- ===== 主視窗 =====
    local win = Instance.new("Frame")
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
    title.Text = ("繁中版 v%s｜共 %d 條命令"):format(currentVersion or "6.4.2", #cmds)
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
    closeBtn.MouseButton1Click:Connect(function() win.Visible = false end)

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
        task.delay(3, function()
            if statusBar.Text == old then statusBar.Text = "" end
        end)
    end

    -- ===== 懸浮切換按鈕 =====
    local floatBtn = Instance.new("TextButton")
    floatBtn.Size = UDim2.fromOffset(46, 46)
    floatBtn.Position = UDim2.new(1, -62, 1, -112)
    floatBtn.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
    floatBtn.BackgroundTransparency = 0.15
    floatBtn.BorderSizePixel = 0
    floatBtn.Font = Enum.Font.SourceSansBold
    floatBtn.TextSize = 16
    floatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    floatBtn.Text = "中"
    floatBtn.ZIndex = 20
    floatBtn.Parent = screen
    local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(0.5, 0); fc.Parent = floatBtn
    local fs = Instance.new("UIStroke"); fs.Color = Color3.fromRGB(120, 200, 255); fs.Thickness = 1.5; fs.Transparency = 0.3; fs.Parent = floatBtn

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
        if win.Visible then
            win.Size = UDim2.fromOffset(0, 0)
            TS:Create(win, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(400, 275)}):Play()
        end
    end)

    -- ===== 主視窗拖動 =====
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

    -- ===== 左右欄 =====
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
    leftL.Padding = UDim.new(0, 2); leftL.SortOrder = Enum.SortOrder.LayoutOrder; leftL.Parent = leftPane

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
    rightL.Padding = UDim.new(0, 2); rightL.SortOrder = Enum.SortOrder.LayoutOrder; rightL.Parent = rightPane

    -- ===== 輸入彈窗 =====
    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.fromOffset(300, 140)
    overlay.Position = UDim2.new(0.5, -150, 0.5, -70)
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

    local inHint = Instance.new("TextLabel")
    inHint.Size = UDim2.new(1, -16, 0, 14)
    inHint.Position = UDim2.fromOffset(8, 24)
    inHint.BackgroundTransparency = 1
    inHint.Font = Enum.Font.SourceSans
    inHint.TextSize = 11
    inHint.TextColor3 = Color3.fromRGB(150, 200, 255)
    inHint.TextXAlignment = Enum.TextXAlignment.Left
    inHint.ZIndex = 51
    inHint.Parent = overlay

    local inBox = Instance.new("TextBox")
    inBox.Size = UDim2.new(1, -20, 0, 30)
    inBox.Position = UDim2.fromOffset(10, 40)
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
    okBtn.Position = UDim2.new(0.5, -95, 1, -36)
    okBtn.BackgroundColor3 = Color3.fromRGB(60, 130, 60)
    okBtn.BorderSizePixel = 0
    okBtn.Font = Enum.Font.SourceSansBold
    okBtn.TextSize = 13
    okBtn.TextColor3 = Color3.new(1, 1, 1)
    okBtn.Text = "執行"
    okBtn.ZIndex = 51
    okBtn.Parent = overlay

    local cancelBtn = Instance.new("TextButton")
    cancelBtn.Size = UDim2.fromOffset(90, 26)
    cancelBtn.Position = UDim2.new(0.5, 5, 1, -36)
    cancelBtn.BackgroundColor3 = Color3.fromRGB(100, 60, 60)
    cancelBtn.BorderSizePixel = 0
    cancelBtn.Font = Enum.Font.SourceSansBold
    cancelBtn.TextSize = 13
    cancelBtn.TextColor3 = Color3.new(1, 1, 1)
    cancelBtn.Text = "取消"
    cancelBtn.ZIndex = 51
    cancelBtn.Parent = overlay

    local inputCb = nil
    local function openInput(t, hint, ph, cb)
        inTitle.Text = t
        inHint.Text = hint or ""
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
        overlay.Visible = false; inputCb = nil
    end)
    inBox.FocusLost:Connect(function(enter)
        if enter then
            overlay.Visible = false
            local v = inBox.Text
            local cb = inputCb; inputCb = nil
            if cb then cb(v) end
        end
    end)

    -- ===== 資訊彈窗（選擇器 / 語法） =====
    local infoOverlay = Instance.new("Frame")
    infoOverlay.Size = UDim2.fromOffset(340, 200)
    infoOverlay.Position = UDim2.new(0.5, -170, 0.5, -100)
    infoOverlay.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
    infoOverlay.BorderSizePixel = 0
    infoOverlay.Visible = false
    infoOverlay.ZIndex = 60
    infoOverlay.Parent = win

    local infoBar = Instance.new("Frame")
    infoBar.Size = UDim2.new(1, 0, 0, 22)
    infoBar.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
    infoBar.BorderSizePixel = 0
    infoBar.ZIndex = 61
    infoBar.Parent = infoOverlay

    local infoTitle = Instance.new("TextLabel")
    infoTitle.Size = UDim2.new(1, -30, 1, 0)
    infoTitle.Position = UDim2.fromOffset(8, 0)
    infoTitle.BackgroundTransparency = 1
    infoTitle.Font = Enum.Font.SourceSansBold
    infoTitle.TextSize = 13
    infoTitle.TextColor3 = Color3.fromRGB(160, 200, 255)
    infoTitle.TextXAlignment = Enum.TextXAlignment.Left
    infoTitle.ZIndex = 62
    infoTitle.Parent = infoBar

    local infoClose = Instance.new("TextButton")
    infoClose.Size = UDim2.fromOffset(22, 22)
    infoClose.Position = UDim2.new(1, -22, 0, 0)
    infoClose.BackgroundTransparency = 1
    infoClose.Font = Enum.Font.SourceSansBold
    infoClose.TextSize = 14
    infoClose.TextColor3 = Color3.fromRGB(200, 200, 200)
    infoClose.Text = "✕"
    infoClose.ZIndex = 62
    infoClose.Parent = infoBar

    local infoBody = Instance.new("TextLabel")
    infoBody.Size = UDim2.new(1, -20, 0, 130)
    infoBody.Position = UDim2.fromOffset(10, 28)
    infoBody.BackgroundTransparency = 1
    infoBody.Font = Enum.Font.SourceSans
    infoBody.TextSize = 13
    infoBody.TextColor3 = Color3.new(1, 1, 1)
    infoBody.TextWrapped = true
    infoBody.TextXAlignment = Enum.TextXAlignment.Left
    infoBody.TextYAlignment = Enum.TextYAlignment.Top
    infoBody.ZIndex = 61
    infoBody.Parent = infoOverlay

    local infoCopyBtn = Instance.new("TextButton")
    infoCopyBtn.Size = UDim2.fromOffset(110, 26)
    infoCopyBtn.Position = UDim2.new(0.5, -115, 1, -34)
    infoCopyBtn.BackgroundColor3 = Color3.fromRGB(60, 100, 150)
    infoCopyBtn.BorderSizePixel = 0
    infoCopyBtn.Font = Enum.Font.SourceSansBold
    infoCopyBtn.TextSize = 13
    infoCopyBtn.TextColor3 = Color3.new(1, 1, 1)
    infoCopyBtn.Text = "複製到剪貼板"
    infoCopyBtn.ZIndex = 62
    infoCopyBtn.Parent = infoOverlay

    local infoOkBtn = Instance.new("TextButton")
    infoOkBtn.Size = UDim2.fromOffset(80, 26)
    infoOkBtn.Position = UDim2.new(0.5, 5, 1, -34)
    infoOkBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 62)
    infoOkBtn.BorderSizePixel = 0
    infoOkBtn.Font = Enum.Font.SourceSansBold
    infoOkBtn.TextSize = 13
    infoOkBtn.TextColor3 = Color3.new(1, 1, 1)
    infoOkBtn.Text = "關閉"
    infoOkBtn.ZIndex = 62
    infoOkBtn.Parent = infoOverlay

    local infoCopyText = ""
    local function showInfo(t, body, copyText)
        infoTitle.Text = t
        infoBody.Text = body
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
        if ok then
            toast("已執行：" .. (label or cmdStr))
        else
            toast("執行失敗：" .. tostring(err), Color3.fromRGB(220, 120, 120))
        end
    end

    -- ===== 中文映射表 =====
    local zhRaw = [[
fly=飛行
unfly=停止飛行
flyspeed=飛行速度
vfly=載具飛行
vehiclefly=載具飛行
unvfly=停止載具飛行
vflyspeed=載具飛行速度
vehicleflyspeed=載具飛行速度
qefly=QE飛行
togglefly=切換飛行
togglevfly=切換載具飛行
cframefly=CFly
cfly=CFly
uncframefly=停止CFly
uncfly=停止CFly
cframeflyspeed=CFly速度
cflyspeed=CFly速度
float=懸浮
platform=懸浮
unfloat=取消懸浮
unplatform=取消懸浮
togglefloat=切換懸浮
swim=游泳
unswim=停止游泳
toggleswim=切換游泳
noclip=穿牆
unnoclip=取消穿牆
clip=取消穿牆
togglenoclip=切換穿牆
tpwalk=傳送行走
teleportwalk=傳送行走
untpwalk=停止傳送行走
unteleportwalk=停止傳送行走
flyjump=飛跳
unflyjump=停止飛跳
infjump=無限跳躍
infinitejump=無限跳躍
uninfjump=停止無限跳躍
uninfinitejump=停止無限跳躍
autojump=自動跳躍
ajump=自動跳躍
unautojump=停止自動跳躍
edgejump=邊緣跳
ejump=邊緣跳
unedgejump=停止邊緣跳
jump=跳躍

goto=傳送玩家
to=傳送玩家
tweengoto=Tween傳送
tgoto=Tween傳送
tto=Tween傳送
tweento=Tween傳送
vehiclegoto=載具傳送
vgoto=載具傳送
loopgoto=循環傳送
unloopgoto=停止循環傳送
pulsetp=脈衝傳送
ptp=脈衝傳送
tpposition=傳送座標
tppos=傳送座標
tweentpposition=Tween座標
ttppos=Tween座標
offset=偏移
tweenoffset=Tween偏移
toffset=Tween偏移
thru=穿透
walktoposition=走到座標
walktopos=走到座標
spawnpoint=重生點
spawn=重生點
nospawnpoint=移除重生點
nospawn=移除重生點
flashback=傳送回死點
diedtp=傳送回死點
walltp=牆傳送
nowalltp=停止牆傳送
unwalltp=停止牆傳送
teleporttool=傳送工具
tptool=傳送工具
mouseteleport=滑鼠傳送
mousetp=滑鼠傳送
back=返回
notifyposition=通知座標
notifypos=通知座標
copyposition=複製座標
copypos=複製座標
setwaypoint=設定傳送點
swp=設定傳送點
waypointpos=設定座標點
wpp=設定座標點
waypoints=傳送點列表
showwaypoints=顯示傳送點
hidewaypoints=隱藏傳送點
waypoint=到傳送點
wp=到傳送點
tweenwaypoint=Tween到點
twp=Tween到點
walktowaypoint=走到點
wtwp=走到點
deletewaypoint=刪除點
dwp=刪除點
clearwaypoints=清空點
cwp=清空點
cleargamewaypoints=清空本遊戲點
cgamewp=清空本遊戲點
tweenspeed=Tween速度
tspeed=Tween速度
freecam=自由視角
fc=自由視角
freecampos=自由視角座標
fcpos=自由視角座標
freecamwaypoint=自由視角到點
fcwp=自由視角到點
freecamgoto=自由視角到玩家
fcgoto=自由視角到玩家
fctp=自由視角到玩家
unfreecam=停止自由視角
unfc=停止自由視角
freecamspeed=自由視角速度
fcspeed=自由視角速度
notifyfreecamposition=通知自由視角座標
notifyfcpos=通知自由視角座標
copyfreecamposition=複製自由視角座標
copyfcpos=複製自由視角座標
gotocamera=到相機
gotocam=到相機
tweengotocamera=Tween到相機
tweengotocam=Tween到相機
tgotocam=Tween到相機
fixcam=修復相機
restorecam=恢復相機
lookat=看向
fov=視野
maxzoom=最大縮放
minzoom=最小縮放
camdistance=相機距離
firstp=第一人稱
thirdp=第三人稱
noclipcam=穿牆相機
nccam=穿牆相機
enableshiftlock=啟用Shift鎖
enablesl=啟用Shift鎖
ctrllock=Ctrl鎖
unctrllock=取消Ctrl鎖

freeze=凍結
fr=凍結
freezeanims=凍結動畫
unfreezeanims=解凍動畫
thaw=解凍
unfreeze=解凍
unfr=解凍
anchor=錨定
unanchor=取消錨定
bring=拉
clientbring=拉(客戶端)
cbring=拉(客戶端)
loopbring=循環拉
unloopbring=停止循環拉
view=觀察
spectate=觀察
viewpart=觀察部件
viewp=觀察部件
unview=停止觀察
unspectate=停止觀察
locate=定位
unlocate=取消定位
nolocate=取消定位
hitbox=碰撞箱
headsize=頭部大小
kill=殺
fling=甩
unfling=停止甩
flyfling=飛甩
unflyfling=停止飛甩
walkfling=行走甩
unwalkfling=停止行走甩
invisfling=隱形甩
antifling=防甩
unantifling=取消防甩
stareat=凝視
stare=凝視
unstareat=停止凝視
unstare=停止凝視
scare=驚嚇
spook=驚嚇
carpet=地毯
uncarpet=取消地毯
friend=加好友
unfriend=刪好友
headsit=頭頂坐
walkto=跟隨
follow=跟隨
pathfindwalkto=尋路跟隨
pathfindfollow=尋路跟隨
pathfindwalktowaypoint=尋路到點
pathfindwalktowp=尋路到點
unwalkto=停止跟隨
unfollow=停止跟隨
orbit=環繞
unorbit=停止環繞
bang=撞
unbang=停止撞
jerk=抽動
handlekill=手柄殺
hkill=手柄殺
loopoof=循環OOF
unloopoof=停止OOF
muteboombox=靜音音響
unmuteboombox=取消靜音音響
rolewatch=角色監視
rolewatchstop=停止角色監視
unrolewatch=停止角色監視
rolewatchleave=角色監視離開
staffwatch=員工監視
unstaffwatch=停止員工監視
findfriendgroups=找好友群

esp=透視
espteam=隊伍透視
noesp=關閉透視
unesp=關閉透視
unespteam=關閉透視
esptransparency=透視透明度
partesp=部件透視
unpartesp=取消部件透視
nopartesp=取消部件透視
chams=色塊透視
nochams=關閉色塊
unchams=關閉色塊
xray=透視牆
unxray=關閉透視牆
noxray=關閉透視牆
loopxray=循環透視牆
unloopxray=停止循環透視牆
togglexray=切換透視牆
fullbright=全亮
fb=全亮
loopfullbright=循環全亮
loopfb=循環全亮
unloopfullbright=停止循環全亮
unloopfb=停止循環全亮
ambient=環境光
day=白天
night=夜晚
nofog=去霧
brightness=亮度
globalshadows=全局陰影
gshadows=全局陰影
noglobalshadows=取消全局陰影
nogshadows=取消全局陰影
restorelighting=恢復光照
rlighting=恢復光照
light=光源
nolight=關燈
unlight=關燈
hitboxes=顯示碰撞箱
unhitboxes=關閉碰撞箱
removeads=去廣告
adblock=去廣告
antivoid=防虛空
unantivoid=取消防虛空
noantivoid=取消防虛空
norender=停止渲染
render=渲染

chat=聊天
say=說話
spam=刷屏
unspam=停止刷屏
whisper=私聊
pm=私聊
pmspam=刷私聊
unpmspam=停止刷私聊
spamspeed=刷屏速度
bubblechat=氣泡聊天
unbubblechat=關閉氣泡
nobubblechat=關閉氣泡
chatwindow=聊天窗
unchatwindow=關閉聊天窗
nochatwindow=關閉聊天窗
darkchat=深色聊天
listento=監聽
unlistento=停止監聽
muteallvoices=靜音所有
muteallvcs=靜音所有
unmuteallvoices=取消靜音
unmuteallvcs=取消靜音
mutevc=靜音語音
unmutevc=取消靜音
phonebook=電話簿
call=通話

tools=工具
gears=工具
notools=移除工具
removetools=移除工具
deletetools=移除工具
deleteselectedtool=刪選中工具
dst=刪選中工具
grabtools=抓工具
ungrabtools=停止抓工具
nograbtools=停止抓工具
copytools=複製工具
dupetools=複製工具
clonetools=複製工具
droptools=丟工具
droppabletools=可丟工具
equiptools=裝備工具
unequiptools=收起工具
removespecifictool=移除特定工具
unremovespecifictool=停止移除特定
clearremovespecifictool=清除移除特定
reach=延長
boxreach=盒子延長
unreach=取消延長
noreach=取消延長
grippos=握持位置
usetools=使用工具
btools=建築工具
f3x=F3X
partname=部件名
partpath=部件路徑
fireclickdetectors=觸發點擊
firecd=觸發點擊
firetouchinterests=觸發觸摸
touchinterests=觸發觸摸
fireproximityprompts=觸發提示
firepp=觸發提示
instantproximityprompts=即時提示
instantpp=即時提示
uninstantproximityprompts=取消即時提示
uninstantpp=取消即時提示
noclickdetectorlimits=無限點擊距離
nocdlimits=無限點擊距離
noproximitypromptlimits=無限提示距離
nopplimits=無限提示距離

speed=速度
ws=速度
walkspeed=速度
spoofspeed=偽裝速度
spoofws=偽裝速度
loopspeed=循環速度
loopws=循環速度
unloopspeed=停止循環速度
unloopws=停止循環速度
hipheight=臀部高度
hheight=臀部高度
jumppower=跳躍力
jpower=跳躍力
jp=跳躍力
spoofjumppower=偽裝跳躍
spoofjp=偽裝跳躍
loopjumppower=循環跳躍
loopjp=循環跳躍
unloopjumppower=停止循環跳躍
unloopjp=停止循環跳躍
maxslopeangle=最大坡度
msa=最大坡度
gravity=重力
grav=重力
respawn=重生
refresh=刷新
re=刷新
reset=重置
god=上帝模式
invisible=隱身
invis=隱身
visible=現身
vis=現身
uninvisible=現身
toolinvisible=工具隱身
toolinvis=工具隱身
tinvis=工具隱身
toggleinvis=切換隱身
sit=坐下
lay=躺下
laydown=躺下
sitwalk=坐著走
nosit=禁止坐
unnosit=允許坐
platformstand=平台站立
stun=眩暈
unplatformstand=取消平台站立
unstun=取消眩暈
norotate=禁止旋轉
noautorotate=禁止旋轉
unnorotate=允許旋轉
autorotate=允許旋轉
enablestate=啟用狀態
disablestate=禁用狀態
team=隊伍
dance=跳舞
undance=停止跳舞
nodance=停止跳舞
spasm=抽搐
unspasm=停止抽搐
nospasm=停止抽搐
headthrow=扔頭
noanim=無動畫
reanim=恢復動畫
animspeed=動畫速度
animation=動畫
anim=動畫
emote=表情
em=表情
copyanimation=複製動畫
copyanim=複製動畫
copyemote=複製動畫
copyanimationid=複製動畫ID
copyanimid=複製動畫ID
copyemoteid=複製動畫ID
loopanimation=循環動畫
loopanim=循環動畫
stopanimations=停止動畫
stopanims=停止動畫
refreshanimations=刷新動畫
refreshanims=刷新動畫
allowcustomanim=允許自訂動畫
allowcustomanimations=允許自訂動畫
unallowcustomanim=禁止自訂動畫
unallowcustomanimations=禁止自訂動畫
nobillboardgui=無名牌
nobgui=無名牌
noname=無名牌
loopnobgui=循環無名牌
loopnoname=循環無名牌
unloopnobgui=停止循環無名牌
unloopnoname=停止循環無名牌
noarms=無手臂
rarms=無手臂
nolegs=無腿
rlegs=無腿
nolimbs=無四肢
rlimbs=無四肢
naked=裸體
noface=無臉
removeface=無臉
blockhead=方塊頭
blockhats=方塊帽
blocktool=方塊工具
creeper=苦力怕
drophats=掉帽
drophat=掉帽
nohats=無帽
deletehats=刪帽
rhats=刪帽
hatspin=旋轉帽
spinhats=旋轉帽
unhatspin=停止旋轉帽
unspinhats=停止旋轉帽
clearhats=清帽
cleanhats=清帽
chardelete=刪角色部件
cd=刪角色部件
chardeleteclass=刪角色部件類
cdc=刪角色部件類
deletevelocity=刪速度
dv=刪速度
removeforces=刪速度
weaken=變輕
unweaken=恢復重量
strengthen=變重
unstrengthen=恢復重量
breakvelocity=停止速度
spin=旋轉
unspin=停止旋轉
split=分裂
nilchar=空角色
unnilchar=恢復角色
nonilchar=恢復角色
noroot=無根
removeroot=無根
rroot=無根
replaceroot=替換根
replacerootpart=替換根
clearcharappearance=清外觀
clearchar=清外觀
clrchar=清外觀
trip=絆倒
wallwalk=牆上行走
walkonwalls=牆上行走
promptr6=R6提示
promptr15=R15提示
autoclick=自動點擊
unautoclick=停止自動點擊
noautoclick=停止自動點擊
autokeypress=自動按鍵
keypress=自動按鍵
unautokeypress=停止自動按鍵
hovername=懸停名字
unhovername=停止懸停名字
nohovername=停止懸停名字
mousesensitivity=滑鼠靈敏度
ms=滑鼠靈敏度
clickdelete=點擊刪除
clickteleport=點擊傳送
jerk=抽動

serverinfo=伺服器資訊
info=伺服器資訊
sinfo=伺服器資訊
jobid=複製JobId
notifyjobid=通知JobId
rejoin=重進
rj=重進
serverhop=換服
shop=換服
gameteleport=遊戲傳送
gametp=遊戲傳送
discord=Discord
support=支援
help=幫助
inviteprompt=邀請提示
autorejoin=自動重進
autorj=自動重進
antiidle=防閒置
antiafk=防掛機
datalimit=數據限制
replicationlag=延遲
backtrack=延遲
creatorid=創作者ID
creator=創作者ID
copycreatorid=複製創作者ID
copycreator=複製創作者ID
setcreatorid=設創作者ID
setcreator=設創作者ID
noprompts=無提示
showprompts=顯示提示
enable=啟用核心
disable=禁用核心
showguis=顯示GUI
unshowguis=取消顯示GUI
hideguis=隱藏GUI
unhideguis=取消隱藏GUI
guidelete=GUI刪除
unguidelete=取消GUI刪除
noguidelete=取消GUI刪除
hideiy=隱藏IY
showiy=顯示IY
unhideiy=顯示IY
keepiy=保持IY
unkeepiy=停止保持IY
togglekeepiy=切換保持IY
savegame=保存遊戲
saveplace=保存遊戲
clearerror=清錯誤
clearerrors=清錯誤
antigameplaypaused=防遊戲暫停
unantigameplaypaused=取消防暫停
clientantikick=客戶端防踢
antikick=防踢
clientantiteleport=客戶端防傳送
antiteleport=防傳送
allowrejoin=允許重進
allowrj=允許重進
cancelteleport=取消傳送
canceltp=取消傳送
volume=音量
vol=音量
antilag=防卡
boostfps=提升FPS
lowgraphics=低畫質
record=錄影
rec=錄影
screenshot=截圖
scrnshot=截圖
togglefullscreen=全屏
togglefs=全屏
notify=通知
lastcommand=上一命令
lastcmd=上一命令
notifyping=延遲通知
ping=延遲通知
use2022materials=2022材質
2022materials=2022材質
unuse2022materials=取消2022材質
un2022materials=取消2022材質
alignmentkeys=對齊鍵
unalignmentkeys=取消對齊鍵
noalignmentkeys=取消對齊鍵
exit=退出
shutdown=關閉
leave=離開
removecmd=移除命令
deletecmd=移除命令
breakloops=停止循環
break=停止循環
setfpscap=設定FPS
fpscap=設定FPS
maxfps=設定FPS
console=控制台
oldconsole=舊控制台
explorer=資源管理器
dex=資源管理器
moondex=MoonDex
mdex=MoonDex
remotespy=遠程監視
rspy=遠程監視
cobalt=Cobalt
cspy=Cobalt
simplespy=簡單監視
sspy=簡單監視
audiologger=音頻日誌
alogger=音頻日誌
inspect=檢查
examine=檢查
age=年齡
chatage=聊天年齡
joindate=加入日期
jd=加入日期
chatjoindate=聊天加入日期
cjd=聊天加入日期
copyname=複製名字
copyuser=複製用戶
userid=用戶ID
id=用戶ID
copyplaceid=複製場景ID
placeid=複製場景ID
copygameid=複製遊戲ID
gameid=複製遊戲ID
copyid=複製ID
copyuserid=複製用戶ID
appearanceid=外觀ID
aid=外觀ID
copyappearanceid=複製外觀ID
caid=複製外觀ID
guiscale=介面縮放
fakeout=假傳送
destroyheight=破壞高度
dh=破壞高度
removeterrain=移除地形
rterrain=移除地形
noterrain=移除地形
clearnilinstances=清除空實例
nonilinstances=清除空實例
cni=清除空實例
lockworkspace=鎖定工作區
lockws=鎖定工作區
unlockworkspace=解鎖工作區
unlockws=解鎖工作區
delete=刪除
remove=刪除
deleteclass=刪除類
dc=刪除類
invisibleparts=隱形部件
invisparts=隱形部件
uninvisibleparts=恢復隱形部件
uninvisparts=恢復隱形部件
deleteinvisparts=刪除隱形部件
dip=刪除隱形部件
gotopart=到部件
topart=到部件
tweengotopart=Tween到部件
tgotopart=Tween到部件
ttopart=Tween到部件
gotopartclass=到部件類
gpc=到部件類
tweengotopartclass=Tween到部件類
tgpc=Tween到部件類
gotomodel=到模型
tomodel=到模型
tweengotomodel=Tween到模型
tgotomodel=Tween到模型
ttomodel=Tween到模型
gotopartdelay=到部件延遲
bringpart=拉部件
bringpartclass=拉部件類
bpc=拉部件類
tpunanchored=拉未錨定
tpua=拉未錨定
animsunanchored=凍結未錨定
freezeua=凍結未錨定
freezeunanchored=凍結未錨定
thawunanchored=解凍未錨定
thawua=解凍未錨定
unfreezeua=解凍未錨定

logs=日誌
chatlogs=聊天日誌
clogs=聊天日誌
joinlogs=加入日誌
jlogs=加入日誌
chatlogswebhook=聊天日誌Webhook
logswebhook=日誌Webhook

addalias=添加別名
removealias=移除別名
clraliases=清空別名
addplugin=添加插件
plugin=添加插件
removeplugin=移除插件
deleteplugin=移除插件
reloadplugin=重載插件
addallplugins=添加全部插件
loadallplugins=添加全部插件
]]

    local zhMap = {}
    for line in zhRaw:gmatch("[^\r\n]+") do
        local k, v = line:match("^([^=]+)=(.+)$")
        if k then
            zhMap[k:lower():gsub("%s+$", "")] = v:gsub("^%s+", "")
        end
    end

    -- 已知需要參數但 NAME 無佔位符的命令
    local extraArg = {}
    local function mark(list) for _, n in ipairs(list) do extraArg[n] = true end end
    mark({
        "speed","ws","walkspeed","jumppower","jp","jpower","flyspeed","vflyspeed","cflyspeed",
        "hipheight","gravity","fov","maxzoom","minzoom","camdistance","brightness","guiscale",
        "spamspeed","tweenspeed","tspeed",
        "goto","to","tgoto","tto","vgoto","loopgoto","pulsetp","ptp","bring","cbring","clientbring",
        "loopbring","unloopbring","freeze","thaw","view","spectate","locate","hitbox","headsize",
        "walkto","follow","orbit","stareat","stare","scare","spook","carpet","bang","head sit","headsit",
        "chat","say","spam","whisper","pm","pmspam","unpmspam",
        "tppos","tpposition","ttppos","offset","toffset","thru","walktopos","walktoposition",
        "setwaypoint","swp","waypointpos","wpp","waypoint","wp","deletewaypoint","dwp",
        "tweenwaypoint","twp","walktowaypoint","wtwp",
        "reach","boxreach","grippos","usetools","dupetools","clonetools",
        "notify","userid","id","copyid","copyuserid","age","joindate","jd","chatage","chatjoindate","cjd","inspect","examine",
        "partesp","unpartesp","nopartesp","gotopart","topart","tweengotopart","tgotopart",
        "gotopartclass","gpc","gotomodel","tomodel","bringpart","bringpartclass","bpc",
        "firecd","fireclickdetectors","firepp","fireproximityprompts","firetouchinterests","touchinterests",
        "rolewatch","group","team","enableshiftlock","enablesl","autoclick","autokeypress","keypress",
        "chatlogswebhook","logswebhook","addalias","removealias","addplugin","plugin","removeplugin","deleteplugin","reloadplugin",
        "removespecifictool","unremovespecifictool","guiscale","setfpscap","fpscap","maxfps",
        "volume","vol","datalimit","replicationlag","backtrack","destroyheight","dh","spin","hatspin","spinhats",
        "animation","anim","emote","em","animspeed","copyanimation","copyanim","copyemote",
        "copyanimationid","copyanimid","copyemoteid","loopoof","muteboombox","unmuteboombox",
        "light","ambient","brightness","jerk","mousesensitivity","ms","notifyping","ping",
    })

    -- ===== 分類規則 =====
    local catOrder = {"飛行","傳送","玩家","視覺","聊天","工具","角色","世界","日誌","插件","其他"}
    local catRules = {
        ["飛行"] = {"fly","cfly","vfly","qefly","float","swim","noclip","clip","platformstand","tpwalk","teleportwalk","flyjump"},
        ["傳送"] = {"goto","waypoint","spawn","tppos","tpposition","teleport","flashback","walltp","freecam","gotocam","fixcam","lookat","fov","zoom","camdistance","firstp","thirdp","noclipcam","shiftlock","ctrllock","mousetp","mouseteleport","tptool","teleporttool","pulsetp","ptp","thru","offset","toffset","back","spawn"},
        ["玩家"] = {"freeze","thaw","view","spectate","locate","hitbox","headsize","kill","fling","stare","scare","carpet","friend","unfriend","bang","jerk","bring","orbit","walkto","follow","pathfind","handlekill","hkill","loopoof","boombox","rolewatch","staffwatch","findfriendgroups"},
        ["視覺"] = {"esp","chams","xray","fullbright","bright","fog","shadow","day","night","ambient","restorelighting","hitboxes","removeads","antivoid","norender","material","norender","render"},
        ["聊天"] = {"chat","spam","whisper","pm","bubble","darkchat","mute","voice","listento","phonebook","call"},
        ["工具"] = {"tools","tool","btools","f3x","reach","grip","equip","drop","grab","dupe","fireclick","fireprox","instantprox","noclick","touchinterest","usetools","partname","partpath","delete","lockws","lockworkspace","invisparts","invisibleparts","gotopart","gotomodel","bringpart","tpunanchored","freezeua","freezeunanchored","thawua","thawunanchored"},
        ["角色"] = {"speed","jump","god","invis","visible","sit","lay","dance","anim","emote","spasm","headthrow","creeper","block","naked","noface","noarm","noleg","nolimb","hat","limb","arm","leg","face","trip","split","nilchar","noroot","root","clearchar","stun","rotate","team","anchor","weaken","strengthen","breakvelocity","spoof","chardelete","rig","state","hipheight","gravity","freezeanims","unfreezeanims","autoclick","autokeypress","keypress","hovername","mousesensitivity"},
        ["世界"] = {"server","rejoin","shop","jobid","discord","placeid","creator","age","joindate","gametp","volume","fps","alignment","ctrl","exit","shutdown","leave","record","screenshot","togglefs","antilag","antiidle","antiafk","datalimit","replicationlag","backtrack","prompts","savegame","clearerror","antipaused","antikick","antiteleport","cancelteleport","notify","lastcommand","breakloops","removecmd","keepiy","hideiy","showiy","enable","disable","guis","guidelete","guiscale","console","explorer","dex","spy","audiologger","inspect","examine","copyname","userid","copyplaceid","copygameid","copyid","appearanceid","fakeout","destroyheight","terrain","nilinstances","removeads","escape"},
        ["日誌"] = {"logs","clogs","jlogs","webhook"},
        ["插件"] = {"plugin","alias"},
    }

    local function classify(name)
        local n = name:lower()
        for _, cat in ipairs(catOrder) do
            local keys = catRules[cat]
            if keys then
                for _, k in ipairs(keys) do
                    if n:find(k, 1, true) then return cat end
                end
            end
        end
        return "其他"
    end

    -- ===== 解析 cmds 表 → 分組 =====
    local buckets = {}
    for _, cat in ipairs(catOrder) do buckets[cat] = {} end

    local seen = {}
    for _, c in ipairs(cmds) do
        local fullName = c.NAME
        if type(fullName) == "string" and fullName ~= "" then
            local base = fullName:match("^([^%s%[]+)")
            if base and not seen[base:lower()] then
                seen[base:lower()] = true
                local params = fullName:sub(#base + 1):gsub("^%s+", "")
                local zh = zhMap[base:lower()] or base
                local cat = classify(base)
                local needsArg = (params ~= "" and params:find("%[")) or extraArg[base:lower()] or false
                table.insert(buckets[cat], {
                    label = zh,
                    base = base,
                    params = params,
                    aliases = c.ALIAS,
                    needsArg = needsArg,
                })
            end
        end
    end

    -- ===== 靜態分類：選擇器 / 語法 =====
    local selectors = {
        {label="all（所有人）",          v="all"},
        {label="others（除我以外）",     v="others"},
        {label="me（只有我）",           v="me"},
        {label="@用戶名",                v="@username"},
        {label="#N（隨機N人）",          v="#3"},
        {label="random（隨機一人）",     v="random"},
        {label="%隊伍名（指定隊伍）",    v="%Red"},
        {label="allies / team（隊友）",  v="allies"},
        {label="enemies / nonteam（敵人）", v="enemies"},
        {label="friends（好友）",        v="friends"},
        {label="nonfriends（非好友）",   v="nonfriends"},
        {label="guests（訪客）",         v="guests"},
        {label="bacons（Bacon頭）",      v="bacons"},
        {label="ageN（年齡以下）",       v="age15"},
        {label="radN（範圍內）",         v="rad50"},
        {label="nearest（最近）",        v="nearest"},
        {label="farthest（最遠）",       v="farthest"},
        {label="groupID（群組成員）",    v="group123456"},
        {label="alive（存活）",          v="alive"},
        {label="dead（死亡）",           v="dead"},
        {label="cursor（滑鼠最近）",     v="cursor"},
        {label="npcs（NPC）",            v="npcs"},
        {label="逗號分隔多玩家",         v="noob,noob2,bob"},
        {label="-/+ 前綴（排除/交集）",  v="-age15"},
    }
    local selectorDesc = {
        all="包含伺服器內所有玩家。\n用法：locate all / freeze all",
        others="包含所有人但不含自己。\n用法：kill others / bring others",
        me="只選中自己。\n用法：view me",
        ["@username"]="只按用戶名搜尋（忽略顯示名）。\n用法：goto @notfish",
        ["#3"]="隨機抽出指定數量玩家。\n用法：#3 / goto #2",
        random="隨機選中一位玩家（不含自己）。\n用法：freeze random",
        ["%Red"]="選中指定隊伍所有玩家。\n用法：locate %Blue",
        allies="選中與你同隊玩家。\n用法：bring allies",
        enemies="選中非你隊伍玩家。\n用法：fling enemies",
        friends="選中與你互為好友玩家。\n（剛加好友可能未即時生效）",
        nonfriends="選中與你不是好友玩家。",
        guests="選中訪客玩家（現時多數不存在）。",
        bacons="選中戴 Pal/Kate Hair（Bacon頭）玩家。",
        age15="選中帳號年齡 ≤ N 天玩家。\n用法：age15 / kick -age30",
        rad50="選中距離你 ≤ N studs 玩家。\n用法：rad50 / freeze rad100",
        nearest="選中離你最近玩家。",
        farthest="選中離你最遠玩家。",
        group123456="選中某 Roblox 群組在場玩家。\n用法：group123456",
        alive="選中所有存活玩家。",
        dead="選中所有死亡玩家。",
        cursor="選中滑鼠游標最近玩家。",
        npcs="搜尋遊戲 NPC。",
        ["noob,noob2,bob"]="用逗號同時選中多位玩家。\n用法：locate noob,noob2,bob",
        ["-age15"]="前綴 - 排除、+ 交集/包含。\n-age15 → 15天以上\n%blue-friends → 藍隊非好友",
    }

    local syntaxItems = {
        {label="循環執行（次數^延遲^命令）", v="5^btools",
         desc="格式：[次數]^[延遲秒]^[命令]\n\n5^btools → 執行5次\n10^3^drophats → 每3秒掉帽共10次\ninf^0.1^animspeed 100 → 無限循環\n\n停止：breakloops"},
        {label="一次執行多條（反斜線）", v="drophats\\respawn",
         desc="用 \\ 分隔多條命令一次執行。\n\ndrophats\\respawn\nenable inventory\\enable playerlist\\refresh"},
        {label="命令歷史（↑/↓）", v="",
         desc="命令列聚焦時，按 ↑ / ↓ 瀏覽最近用過命令。"},
        {label="自動完成（Tab）", v="",
         desc="命令列聚焦時，按 Tab 插入最頂建議命令。"},
        {label="排除/包含（- 與 +）", v="-age15",
         desc="- 排除、+ 交集/包含。\n\n-age15 → 15天以上\n%blue-friends → 藍隊非好友\n+friends+alive → 好友且存活"},
        {label="多玩家逗號分隔", v="noob,noob2,bob",
         desc="同一次命令選多位玩家。\n\nlocate noob,noob2,bob\nfreeze A,B,C"},
        {label="玩家選擇器速查", v="",
         desc="all / others / me / @name / #N / random / %team\nallies / enemies / friends / nonfriends / guests / bacons\nageN / radN / nearest / farthest / groupID / alive / dead / cursor / npcs"},
    }

    -- ===== 構建右欄 =====
    local function clearPane()
        for _, c in ipairs(rightPane:GetChildren()) do
            if c ~= rightL then c:Destroy() end
        end
    end

    local function makeCmdButton(parent, item, order)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -8, 0, 26)
        btn.BackgroundColor3 = Color3.fromRGB(56, 56, 58)
        btn.BorderSizePixel = 0
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 14
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Text = "  " .. item.label .. (item.needsArg and "  ✎" or "")
        btn.LayoutOrder = order
        btn.Parent = parent

        btn.MouseEnter:Connect(function()
            TS:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(78, 78, 80)}):Play()
            if item.base then
                local aliasTxt = ""
                if type(item.aliases) == "table" and #item.aliases > 0 then
                    aliasTxt = "｜別名：" .. table.concat(item.aliases, ", ")
                end
                toast(("原名：%s%s%s"):format(item.base, item.params ~= "" and (" " .. item.params) or "", aliasTxt))
            end
        end)
        btn.MouseLeave:Connect(function()
            TS:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(56, 56, 58)}):Play()
        end)
        btn.MouseButton1Click:Connect(function()
            if item.needsArg then
                local hint = item.params ~= "" and item.params or "輸入參數（可留空直接執行）"
                openInput(item.label, "命令：" .. item.base, hint, function(val)
                    val = val:gsub("^%s+", ""):gsub("%s+$", "")
                    local full = item.base .. (val ~= "" and (" " .. val) or "")
                    run(full, item.label)
                end)
            else
                run(item.base, item.label)
            end
        end)
    end

    local function buildDynamic(catName)
        clearPane()
        local list = buckets[catName] or {}
        table.sort(list, function(a, b) return a.base:lower() < b.base:lower() end)
        for i, item in ipairs(list) do
            makeCmdButton(rightPane, item, i)
        end
        rightPane.CanvasSize = UDim2.new(0, 0, 0, rightL.AbsoluteContentSize.Y + 8)
    end

    local function buildSelectors()
        clearPane()
        for i, s in ipairs(selectors) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -8, 0, 26)
            btn.BackgroundColor3 = Color3.fromRGB(56, 56, 58)
            btn.BorderSizePixel = 0
            btn.Font = Enum.Font.SourceSans
            btn.TextSize = 14
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Text = "  " .. s.label .. "  ℹ"
            btn.LayoutOrder = i
            btn.Parent = rightPane
            btn.MouseEnter:Connect(function()
                TS:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(78, 78, 80)}):Play()
            end)
            btn.MouseLeave:Connect(function()
                TS:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(56, 56, 58)}):Play()
            end)
            btn.MouseButton1Click:Connect(function()
                showInfo(s.label, selectorDesc[s.v] or "（無說明）", s.v)
            end)
        end
        rightPane.CanvasSize = UDim2.new(0, 0, 0, rightL.AbsoluteContentSize.Y + 8)
    end

    local function buildSyntax()
        clearPane()
        for i, s in ipairs(syntaxItems) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -8, 0, 26)
            btn.BackgroundColor3 = Color3.fromRGB(56, 56, 58)
            btn.BorderSizePixel = 0
            btn.Font = Enum.Font.SourceSans
            btn.TextSize = 14
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Text = "  " .. s.label .. (s.v ~= "" and "  ⧉" or "  ℹ")
            btn.LayoutOrder = i
            btn.Parent = rightPane
            btn.MouseEnter:Connect(function()
                TS:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(78, 78, 80)}):Play()
            end)
            btn.MouseLeave:Connect(function()
                TS:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(56, 56, 58)}):Play()
            end)
            btn.MouseButton1Click:Connect(function()
                showInfo(s.label, s.desc or "（無說明）", s.v)
            end)
        end
        rightPane.CanvasSize = UDim2.new(0, 0, 0, rightL.AbsoluteContentSize.Y + 8)
    end

    -- ===== 左欄分類按鈕 =====
    local catButtons = {}
    local function makeCat(name, order, onClick)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, -4, 0, 28)
        b.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
        b.BorderSizePixel = 0
        b.Font = Enum.Font.SourceSans
        b.TextSize = 14
        b.TextColor3 = Color3.new(1, 1, 1)
        b.TextXAlignment = Enum.TextXAlignment.Left
        b.Text = "  " .. name
        b.LayoutOrder = order
        b.Parent = leftPane
        table.insert(catButtons, b)
        b.MouseButton1Click:Connect(function()
            for _, x in ipairs(catButtons) do x.BackgroundColor3 = Color3.fromRGB(46, 46, 47) end
            b.BackgroundColor3 = Color3.fromRGB(78, 78, 80)
            onClick()
        end)
        return b
    end

    local order = 0
    local function nextOrder() order = order + 1 return order end

    makeCat("選擇器", nextOrder(), buildSelectors)
    makeCat("語法",   nextOrder(), buildSyntax)
    for _, cat in ipairs(catOrder) do
        local cnt = #(buckets[cat] or {})
        if cnt > 0 then
            makeCat(cat .. " (" .. cnt .. ")", nextOrder(), function() buildDynamic(cat) end)
        end
    end

    leftPane.CanvasSize = UDim2.new(0, 0, 0, leftL.AbsoluteContentSize.Y + 4)

    -- 預設選「選擇器」
    if catButtons[1] then
        catButtons[1].BackgroundColor3 = Color3.fromRGB(78, 78, 80)
        buildSelectors()
    end

    -- 統計
    local total = 0
    for _, cat in ipairs(catOrder) do total = total + #(buckets[cat] or {}) end
    toast(("繁中 UI v3 已載入｜命令 %d 條｜分類 %d 個"):format(total, #catOrder))
end)
