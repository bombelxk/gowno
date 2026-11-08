-- c:\Users\kacpe\Downloads\roblox\bombel_private.lua
-- Lua / bombel_private.lua / Luau / x64 / Roblox Client
local OWNER = "fuckdutchman"
local REPO = "ExploitersHUB-release"
local BRANCH = "main"

local ROOT = "ExploitersHub"
local SCRIPT = ROOT .. "/exploitershub.lua"
local RECORD = ROOT .. "/cache/installed.json"

local WORKERS = 16
local TRIES = 3

local Http = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local genv = (type(getgenv) == "function" and getgenv()) or _G

if genv.BOMBELPRIVATE_INSTALLING then
    return
end
genv.BOMBELPRIVATE_INSTALLING = true

local requester =
    (type(request) == "function" and request)
    or (type(http_request) == "function" and http_request)
    or (type(syn) == "table" and syn.request)
    or nil

local canStore =
    type(writefile) == "function"
    and type(readfile) == "function"
    and type(isfile) == "function"
    and type(makefolder) == "function"
    and type(isfolder) == "function"

local function isLocalFile(path)
    path = tostring(path or ""):gsub("\\", "/")

    return path == "cache/installed.json"
        or path == ROOT .. "/cache/installed.json"
        or path == "ExploitersHub/cache/installed.json"
end

local function fetch(url)
    if requester then
        local ok, response = pcall(requester, {
            Url = url,
            Method = "GET",
            Headers = {
                ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
            }
        })

        if ok and type(response) == "table" then
            local status = tonumber(response.StatusCode) or 0

            if status >= 200 and status < 300
                and type(response.Body) == "string" then
                return response.Body
            end
        end
    end

    local ok, body = pcall(function()
        return game:HttpGet(url)
    end)

    if ok and type(body) == "string" and #body > 0 then
        return body
    end

    return nil, tostring(body)
end

local function has(path)
    local ok, result = pcall(isfile, path)
    return ok and result == true
end

local function folder(path)
    local current = ""

    for part in string.gmatch(path, "[^/]+") do
        current = current == ""
            and part
            or current .. "/" .. part

        local ok, exists = pcall(isfolder, current)

        if not (ok and exists) then
            pcall(makefolder, current)
        end
    end
end

local function store(path, data)
    local parent = path:match("(.+)/[^/]+$")

    if parent then
        folder(parent)
    end

    local ok, result = pcall(writefile, path, data)
    return ok and result ~= false
end

local function safePath(path)
    if type(path) ~= "string" then
        return false
    end

    if not path:match("^[%w_%.%-%/]+$") then
        return false
    end

    if path:find("..", 1, true)
        or path:find("//", 1, true)
        or path:sub(1, 1) == "/"
        or path:sub(-1) == "/" then
        return false
    end

    return true
end

local COLLAPSED = UDim2.fromOffset(100, 30)
local EXPANDED = UDim2.fromOffset(400, 60)
local TOP_OFFSET = 10

local WHITE = Color3.fromRGB(240, 240, 240)
local GRAY = Color3.fromRGB(135, 135, 140)
local RED = Color3.fromRGB(255, 69, 58)

local SPRING = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local SMOOTH = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local FAST = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local Island = {}
Island.__index = Island

local function guiParent()
    if type(gethui) == "function" then
        local ok, ui = pcall(gethui)
        if ok and ui then
            return ui
        end
    end

    local ok = pcall(function()
        return CoreGui.Name
    end)

    if ok then
        return CoreGui
    end

    return Players.LocalPlayer:WaitForChild("PlayerGui")
end

local function make(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        local ok, err = pcall(function()
            obj[k] = v
        end)

        if not ok then
            warn("[BombelPrivate] UI property failed: " .. class .. "." .. tostring(k))
        end
    end
    obj.Parent = parent
    return obj
end

local function round(parent, radius)
    return make("UICorner", {CornerRadius = radius or UDim.new(1, 0)}, parent)
end

function Island.new()
    local self = setmetatable({}, Island)
    local parent = guiParent()

    local old = parent:FindFirstChild("BombelPrivateIsland")
    if old then
        old:Destroy()
    end

    self.gui = make("ScreenGui", {
        Name = "BombelPrivateIsland",
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        DisplayOrder = 999,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, parent)

    self.pill = make("Frame", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, -60),
        Size = COLLAPSED,
        BackgroundColor3 = Color3.new(0, 0, 0),
        BorderSizePixel = 0,
    }, self.gui)
    round(self.pill)

    make("UIStroke", {
        Color = Color3.new(1, 1, 1),
        Transparency = 0.88,
        Thickness = 1,
    }, self.pill)

    self.dot = make("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.fromOffset(8, 8),
        BackgroundColor3 = Color3.fromRGB(28, 28, 32),
        BorderSizePixel = 0,
    }, self.pill)
    round(self.dot)

    self.content = make("CanvasGroup", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        GroupTransparency = 1,
    }, self.pill)
    round(self.content)

    local shade = make("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BorderSizePixel = 0,
        ZIndex = 1,
    }, self.content)
    make("UIGradient", {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.05),
            NumberSequenceKeypoint.new(1, 0.7),
        }),
    }, shade)

    self.title = make("TextLabel", {
        Position = UDim2.fromOffset(16, 8),
        Size = UDim2.fromOffset(230, 14),
        BackgroundTransparency = 1,
        Text = "BOMBEL PRIVATE | Starting",
        TextColor3 = WHITE,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        ZIndex = 2,
    }, self.content)

    self.sub = make("TextLabel", {
        Position = UDim2.fromOffset(16, 24),
        Size = UDim2.fromOffset(230, 14),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = GRAY,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        ZIndex = 2,
    }, self.content)

    self.discord = make("TextLabel", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -16, 0.5, -2),
        Size = UDim2.fromOffset(135, 14),
        BackgroundTransparency = 1,
        Text = "by bombel larp",
        TextColor3 = WHITE,
        TextTransparency = 0.25,
        TextXAlignment = Enum.TextXAlignment.Right,
        Font = Enum.Font.GothamMedium,
        TextSize = 11,
        ZIndex = 2,
    }, self.content)

    self.barBg = make("Frame", {
        Position = UDim2.fromOffset(16, 48),
        Size = UDim2.new(1, -32, 0, 4),
        BackgroundColor3 = Color3.fromRGB(40, 40, 44),
        BorderSizePixel = 0,
        ZIndex = 2,
    }, self.content)
    round(self.barBg)

    self.bar = make("Frame", {
        Size = UDim2.fromScale(0, 1),
        BackgroundColor3 = WHITE,
        BorderSizePixel = 0,
        ZIndex = 2,
    }, self.barBg)
    round(self.bar)

    self.expanded = false
    return self
end

function Island:Show()
    TweenService:Create(self.pill, SPRING, {
        Position = UDim2.new(0.5, 0, 0, TOP_OFFSET)
    }):Play()
end

function Island:Expand()
    if self.expanded then
        return
    end
    self.expanded = true

    TweenService:Create(self.pill, SPRING, {Size = EXPANDED}):Play()
    TweenService:Create(self.dot, FAST, {BackgroundTransparency = 1}):Play()

    task.delay(0.12, function()
        if self.expanded then
            TweenService:Create(self.content, SMOOTH, {GroupTransparency = 0}):Play()
        end
    end)
end

function Island:Collapse()
    if not self.expanded then
        return
    end
    self.expanded = false

    TweenService:Create(self.content, FAST, {GroupTransparency = 1}):Play()
    TweenService:Create(self.pill, SMOOTH, {Size = COLLAPSED}):Play()
    TweenService:Create(self.dot, SMOOTH, {BackgroundTransparency = 0}):Play()
end

function Island:Set(action, alpha, sub)
    alpha = math.clamp(alpha or 0, 0, 1)

    self.title.Text = "BOMBEL PRIVATE | "
        .. tostring(action) .. " "
        .. math.floor(alpha * 100) .. "%"

    if sub then
        self.sub.Text = sub
    end

    TweenService:Create(self.bar, SMOOTH, {
        Size = UDim2.fromScale(alpha, 1)
    }):Play()
end

function Island:Done(action, sub)
    self:Set(action or "Ready", 1, sub)
end

function Island:Fail(text)
    self.title.Text = "BOMBEL PRIVATE | Error"
    self.sub.Text = text or ""
    TweenService:Create(self.bar, FAST, {BackgroundColor3 = RED}):Play()
end

function Island:Destroy()
    self:Collapse()
    task.wait(0.35)

    TweenService:Create(self.pill, SMOOTH, {
        Position = UDim2.new(0.5, 0, 0, -60)
    }):Play()

    task.wait(0.35)
    self.gui:Destroy()
end

local island = nil

local function ui(method, ...)
    if island then
        pcall(island[method], island, ...)
    end
end

local function startIsland()
    local ok, result = pcall(Island.new)

    if not ok then
        warn("[BombelPrivate] Island failed: " .. tostring(result))
        return
    end

    island = result
    island:Show()
    task.wait(0.5)
    island:Expand()
    task.wait(0.4)
    island:Set("Checking", 0, "Connecting to GitHub...")
end

local function readRecord()
    local record = {}

    if has(RECORD) then
        local ok, data = pcall(function()
            return Http:JSONDecode(readfile(RECORD))
        end)

        if ok and type(data) == "table" then
            record = data
        end
    end

    if type(record.files) ~= "table" then
        record.files = {}
    end

    return record
end

local function saveRecord(record)
    local ok, data = pcall(function()
        return Http:JSONEncode(record)
    end)

    if ok then
        store(RECORD, data)
    end
end

local function getRepository()
    local commitUrl =
        "https://api.github.com/repos/"
        .. OWNER .. "/" .. REPO
        .. "/commits/" .. BRANCH

    local commitBody, err = fetch(commitUrl)

    if not commitBody then
        return nil, err
    end

    local ok, commit = pcall(function()
        return Http:JSONDecode(commitBody)
    end)

    if not ok or type(commit) ~= "table"
        or type(commit.sha) ~= "string" then
        return nil, "Invalid commit response"
    end

    local commitSha = commit.sha

    local treeUrl =
        "https://api.github.com/repos/"
        .. OWNER .. "/" .. REPO
        .. "/git/trees/" .. commitSha
        .. "?recursive=1"

    local treeBody, why = fetch(treeUrl)

    if not treeBody then
        return nil, why
    end

    local decodedOk, tree = pcall(function()
        return Http:JSONDecode(treeBody)
    end)

    if not decodedOk or type(tree) ~= "table"
        or type(tree.tree) ~= "table" then
        return nil, "Invalid repository tree"
    end

    if tree.truncated then
        return nil, "GitHub returned an incomplete file list"
    end

    return {
        commit = commitSha,
        tree = tree.tree
    }
end

local function makePlan(repository, record)
    local files = {}
    local bytes = 0
    local unchanged = 0

    for _, item in ipairs(repository.tree) do
        if item.type == "blob"
            and safePath(item.path)
            and not isLocalFile(item.path)
            and type(item.sha) == "string"
            and type(item.size) == "number" then

            local destination = ROOT .. "/" .. item.path
            local oldStamp = record.files[item.path]

            local exists = has(destination)
            local sameSize = false

            if exists then
                local ok, content = pcall(readfile, destination)

                sameSize = ok
                    and type(content) == "string"
                    and (item.path == "exploitershub.lua" and #content > 0 or #content == item.size)
            end

            if exists and sameSize and oldStamp == item.sha then
                unchanged = unchanged + 1
            else
                files[#files + 1] = {
                    path = item.path,
                    sha = item.sha,
                    size = item.size,
                    destination = destination
                }

                bytes = bytes + item.size
            end
        end
    end

    table.sort(files, function(a, b)
        return a.path < b.path
    end)

    return files, bytes, unchanged
end

local function replaceExact(str, findStr, replaceStr)
    local p = str:find(findStr, 1, true)
    if p then
        return str:sub(1, p - 1) .. replaceStr .. str:sub(p + #findStr)
    end
    return str
end

local function replaceAllExact(str, findStr, replaceStr)
    local len = #findStr
    local p = str:find(findStr, 1, true)
    while p do
        str = str:sub(1, p - 1) .. replaceStr .. str:sub(p + len)
        p = str:find(findStr, p + #replaceStr, true)
    end
    return str
end

local function patchHub(source)
    if not source or type(source) ~= "string" then return source end

    -- 0. Self-repair any previously corrupted tokens on disk from older builds
    source = replaceExact(
        source,
        "_lf.BackgroundColor3=Color3.fromRGB(10,10,12)_lf.BackgroundTransparency=0end",
        "_lf.BackgroundColor3=Color3.fromRGB(10,10,12) _lf.BackgroundTransparency=0 end"
    )
    source = replaceAllExact(source, "if false thenlocal ", "if false then local ")
    source = replaceExact(source, "_cAU.state.glass=0_cAU", "_cAU.state.glass=0 _cAU")
    source = replaceExact(
        source,
        "Color3.fromRGB(120,120,125) endlocal ",
        "Color3.fromRGB(120,120,125) end local "
    )
    source = replaceExact(
        source,
        "_cxl.Transparency=NumberSequence.new(1)_cxm",
        "_cxl.Transparency=NumberSequence.new(1) _cxm"
    )
    source = replaceExact(
        source,
        "_bYG.BackgroundColor3=Color3.fromRGB(10,10,12)_bYG.BackgroundTransparency=0if",
        "_bYG.BackgroundColor3=Color3.fromRGB(10,10,12) _bYG.BackgroundTransparency=0 if"
    )
    source = replaceExact(
        source,
        "_gE.state={scheme=_ejd(650),accent=Color3.fromRGB(255, 59, 48),glass=0.6",
        "_gE.state={scheme=_ejd(650),accent=Color3.fromRGB(255, 59, 48),glass=0"
    )

    -- 1. Neutralize _Eo (Discord opener)
    local p1 = source:find("local function _Eo()", 1, true)
    if p1 then
        local p2 = source:find("end _Ek.MouseButton1Click:Connect(_Eo)", p1, true)
        if p2 then
            local endTag = "end _Ek.MouseButton1Click:Connect(_Eo)"
            local old_block = source:sub(p1, p2 + #endTag - 1)
            source = replaceExact(source, old_block, "local function _Eo() return end _Ek.MouseButton1Click:Connect(_Eo)")
        end
    end

    -- 2. Lower music top bar so watermark "BOMBEL PRIVATE" is clearly visible above it
    source = replaceExact(
        source,
        "Position=UDim2.new(0.5,(-7145+7145),(-7731+7731),(713-703))",
        "Position=UDim2.new(0.5,0,0,52)"
    )

    -- 3. Add Now Playing HUD toggle to Settings ("On screen") - idempotent
    local hudToggles = '_cBJ:toggle({id=_ejd(2866),label="Now Playing HUD",desc="Shows current song and minute timestamp on screen",bindable=false})_cBJ:toggle({id=_ejd(2869),label="Music Top Bar",desc="Shows the music island and lyrics at the top",bindable=false})'
    source = replaceAllExact(source, hudToggles .. hudToggles, hudToggles)
    if not source:find('_cBJ:toggle({id=_ejd(2866)', 1, true) then
        source = replaceExact(
            source,
            "_cBJ:toggle({id=_ejd(1231),label=_ejd(3133),tip=_ejd(3134),bindable=false})",
            '_cBJ:toggle({id=_ejd(1231),label=_ejd(3133),tip=_ejd(3134),bindable=false})' .. hudToggles
        )
    end

    -- 4. Update Music tab mini player toggle label
    source = replaceExact(
        source,
        "_cgU:toggle({id=_ejd(2866),label=_ejd(2867),desc=_ejd(2868),default=true,bindable=false})",
        '_cgU:toggle({id=_ejd(2866),label="Now Playing HUD",desc="Shows current song and minute timestamp on screen",default=true,bindable=false})'
    )

    -- 5. Pure jet black menu theme (eliminate grey #0B0B0F, set popover/cards to pure black #000000)
    source = replaceExact(
        source,
        "dark={label=_ejd(636),base=_gD(_ejd(637))",
        "dark={label=_ejd(636),base=Color3.fromRGB(0,0,0)"
    )
    source = replaceExact(
        source,
        "midnight={label=_ejd(641),base=_gD(_ejd(642))",
        "midnight={label=_ejd(641),base=Color3.fromRGB(0,0,0)"
    )
    source = replaceExact(
        source,
        "_gF.popover=_gI.base:Lerp(_gI.ink,_gI.dark and 0.07 or 0.0)",
        "_gF.popover=Color3.fromRGB(0,0,0) "
    )
    source = replaceExact(source, "fill={0.045,0.075,0.115}", "fill={0.015,0.025,0.04}")
    source = replaceExact(source, "fill={0.055,0.09,0.13}", "fill={0.015,0.025,0.04}")

    -- 5b. Strip "liquid glass" effects (sheen, grain, glass transparency, white card tints)
    source = replaceExact(
        source,
        "_jp.bind(_lf,_ejd(747),_ejd(730))_jp.bind(_lf,_ejd(749),_lc.fill or _ejd(752))",
        "_lf.BackgroundColor3=Color3.fromRGB(10,10,12) _lf.BackgroundTransparency=0 "
    )
    source = replaceExact(source, "if _lc.sheen~=false then", "if false then ")
    source = replaceExact(source, "if _lc.grain~=false and _jr.image(_ejd(389))then", "if false then ")
    source = replaceExact(
        source,
        "_gE.state={scheme=_ejd(650),accent=_gD(_ejd(655)),glass=0.6",
        "_gE.state={scheme=_ejd(650),accent=_gD(_ejd(655)),glass=0"
    )
    source = replaceExact(
        source,
        "_cAU.state.glass=_cAX.get(_ejd(503))/(2829-2729)",
        "_cAU.state.glass=0 "
    )

    -- 5c. Toggle switch track & knob styling: solid dark black when turned off, crimson when on
    source = replaceExact(
        source,
        "local _vr=_vq and _uq.accent or _uq.ink local _vs=_vq and(3030-3030)or _uq.fill3A-0.05",
        "local _vr=_vq and (_uq.accent or Color3.fromRGB(255,59,48)) or Color3.fromRGB(18,18,22) local _vs=0 if _vl then _vl.BackgroundColor3=_vq and Color3.new(1,1,1) or Color3.fromRGB(120,120,125) end "
    )

    -- 5d. Music HUD & mini player: solid jet black, kill glossy liquid gradient & white glow stroke
    source = replaceExact(
        source,
        "BackgroundColor3=Color3.fromRGB((7337-7313),(4840-4816),(-6798+6826)),BackgroundTransparency=0.03",
        "BackgroundColor3=Color3.fromRGB(0,0,0),BackgroundTransparency=0"
    )
    source = replaceExact(
        source,
        "_cxl.Color=ColorSequence.new(_csB,Color3.fromRGB((9358-9238),(-1177+1297),(5391-5271)))",
        "_cxl.Transparency=NumberSequence.new(1) "
    )
    source = replaceExact(
        source,
        "_cxm.Color,_cxm.Transparency,_cxm.Thickness=_csB,_cxh and 0.7 or 0.9,(9533-9532)",
        "_cxm.Color,_cxm.Transparency,_cxm.Thickness=Color3.fromRGB(35,35,40),0,(9533-9532)"
    )
    source = replaceExact(
        source,
        "_bYH.paint(_bYG,_ejd(747),_ejd(2712))_bYG.BackgroundTransparency=(-7079+7080)-0.065*_bYI",
        "_bYG.BackgroundColor3=Color3.fromRGB(10,10,12) _bYG.BackgroundTransparency=0 "
    )

    -- 6. Music bars color (lock to active theme Crimson Blood Red, eliminate SoundCloud orange cover tint)
    source = replaceExact(
        source,
        "function _csz.wordColor(_cuD)return(_csz.vivid and _csz.accent and _csv.get(_ejd(2720))~=false)and _csz.accent or _cuD end",
        "function _csz.wordColor(_cuD)return _a.T.accent or Color3.fromRGB(255,59,48)end"
    )
    source = replaceExact(
        source,
        "local function _cuE(_cuF)local _cuG,_cuH=pcall(_cuF.color,_ejd(791))return(_cuG and typeof(_cuH)==_ejd(854))and _cuH or Color3.fromRGB((-356+611),(-6756+6815),(-3330+3408))end",
        "local function _cuE(_cuF)return _a.T.accent or Color3.fromRGB(255,59,48)end"
    )
    source = replaceExact(
        source,
        "_cgU:toggle({id=_ejd(2720),label=_ejd(2872),desc=_ejd(2873),default=true,bindable=false})",
        "_cgU:toggle({id=_ejd(2720),label=_ejd(2872),desc=_ejd(2873),default=false,bindable=false})"
    )

    -- 7. ESP default color: WHITE
    source = replaceExact(
        source,
        "_bcF.define(_ejd(1403),_bcA.hex(_ejd(1404)))",
        "_bcF.define(_ejd(1403),Color3.fromRGB(255,255,255))"
    )
    source = replaceAllExact(source, "_ejd(1404)", '"FFFFFF"')

    -- 8. Greeting color & default accent
    source = replaceExact(
        source,
        "Color3.fromRGB((-8708+8804),(-7166+7287),(2575-2394))",
        "Color3.fromRGB(255, 59, 48)"
    )
    source = replaceExact(
        source,
        "accent=_gD(_ejd(655))",
        "accent=Color3.fromRGB(255, 59, 48)"
    )
    source = replaceExact(
        source,
        '{id=_ejd(653),label=_ejd(654),color=_gD(_ejd(655))}',
        '{id="blood",label="Blood Red",color=Color3.fromRGB(255,59,48)}'
    )

    -- 9. Rebrand strings
    source = replaceAllExact(source, "_ejd(1048)", '"BOMBEL PRIVATE"')
    source = replaceAllExact(source, "_ejd(1050)", '"by bombel larp"')
    source = replaceAllExact(source, "_ejd(1160)", '"BOMBEL PRIVATE"')
    source = replaceAllExact(source, "_ejd(1216)", '"BombelPrivate"')
    source = replaceAllExact(source, "_ejd(1075)", '"Unload Bombel Private"')

    -- 10. Hitbox expander max studs: keep at 6.35 (and self-repair 15 -> 6.35 from older builds)
    source = replaceExact(
        source,
        "max=15,step=0.05,default=(-4318+4323),suffix=_ejd(2170)",
        "max=6.35,step=0.05,default=(-4318+4323),suffix=_ejd(2170)"
    )

    -- 11. FPS Optimizations (eliminate workspace:GetDescendants() x3 every 1s, CanvasGroup FBOs, UIShadow GPU blur, and idle per-frame jobs)
    source = replaceExact(
        source,
        "if not _a._rainbowCarLoop then _a._rainbowCarLoop=_a.connect(_bwy.RunService.Heartbeat,function(_bEi)_bDo.timer+=_bEi if _bDo.timer>=(-2465+2466)then _bDo.timer=(9951-9951)_bEa()end if not _bwE.get(_ejd(2358))then return end",
        "if not _a._rainbowCarLoop then _a._rainbowCarLoop=_a.connect(_bwy.RunService.Heartbeat,function(_bEi)if not _bwE.get(_ejd(2358))then return end _bDo.timer+=_bEi if _bDo.timer>=2.5 then _bDo.timer=0 _bEa()end"
    )
    source = replaceExact(
        source,
        "end end end end)end _bEa()",
        "end end end end)end "
    )
    source = replaceExact(
        source,
        "if _lc.shadow and _jt.fx.shadow then",
        "if false then "
    )
    source = replaceExact(
        source,
        "local _lw=Instance.new(_jt.fx.canvas and _ejd(757)or _ejd(726))",
        "local _lw=Instance.new(_ejd(726))"
    )
    source = replaceExact(
        source,
        "_bsR.every(function(_bvz)_a.try(_ejd(1714),_bvm,_bvz)end,nil,_ejd(1715))",
        "_bsR.every(function(_bvz)if _bsU.o and _bsU.o.motionBlur then _a.try(_ejd(1714),_bvm,_bvz)end end,nil,_ejd(1715))"
    )
    source = replaceExact(
        source,
        "_bsR.every(function()_a.try(_ejd(1717),_buM)end,nil,_ejd(1717))",
        "_bsR.every(function()local _o=_bsU.o if _o and(_o.bodyTint or _o.aura~=_ejd(804)or _o.steps~=_ejd(804))then _a.try(_ejd(1717),_buM)end end,20,_ejd(1717))"
    )

    -- 12. Complete Aim Assist + FOV Circle + Mouse/Camera + Hitbox (6.35 max) + Optimized NoRecoil module
    local pAimStart = source:find("do local _bkq,_bkr,_bks=_a.S,_a.util,_a.Config", 1, true)
    local pAimEnd = pAimStart and source:find("do local _bnp,_bnq=_a.S,_a.Config", pAimStart, true)
    if pAimStart and pAimEnd then
        local newAimBlock = [=[do local _bkq,_bkr,_bks=_a.S,_a.util,_a.Config
local _bkt=game:GetService(_ejd(1451))
local _bku=game:GetService(_ejd(1452))
local _bkv=game:GetService(_ejd(1453))
local _bkw=game:GetService(_ejd(1454))
local _bkx=_bkt.LocalPlayer
local _bkz={target=nil,active=false}
_a.Aim=_bkz
local _bkA=100000
local _bkB=2500
_bkz.FAR,_bkz.WHOLE=_bkA,_bkB
local _bkD=(type(mousemoverel)=="function" and mousemoverel)
    or (type(getgenv)=="function" and type(getgenv().mousemoverel)=="function" and getgenv().mousemoverel)
    or (type(Input)=="table" and type(Input.MoveMouse)=="function" and Input.MoveMouse)
    or (type(syn)=="table" and type(syn.mousemoverel)=="function" and syn.mousemoverel)
    or (type(fluxus)=="table" and type(fluxus.mousemoverel)=="function" and fluxus.mousemoverel)
    or nil
_bkz.canMouse=true
_bkz.canClick=true

local _bkE
local _bkG=false
local _bkH=nil
local _aimScreen,_fovFrame,_fovStroke,_snapFrame,_markFrame,_markStroke,_crossH,_crossV,_infoLabel
local _stickyEntry,_stickyPart=nil,nil
local _lastTargetGoneAt=0
local _lastMousePos=nil
local _mouseMoveWorks=nil
local _rayParams=RaycastParams.new()
_rayParams.FilterType=Enum.RaycastFilterType.Exclude
_rayParams.IgnoreWater=true

local function _ensureAimGui()
    if _aimScreen and _aimScreen.Parent then return end
    _aimScreen=_a.screen(8200)
    if not _aimScreen then return end

    _fovFrame=Instance.new("Frame")
    _fovFrame.Name="AimFov"
    _fovFrame.AnchorPoint=Vector2.new(0.5,0.5)
    _fovFrame.BackgroundTransparency=1
    _fovFrame.BorderSizePixel=0
    _fovFrame.Visible=false
    _fovFrame.Parent=_aimScreen
    local _fc=Instance.new("UICorner")
    _fc.CornerRadius=UDim.new(1,0)
    _fc.Parent=_fovFrame
    _fovStroke=Instance.new("UIStroke")
    _fovStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    _fovStroke.Thickness=1.5
    _fovStroke.Color=Color3.fromRGB(255,59,48)
    _fovStroke.Transparency=0.25
    _fovStroke.Parent=_fovFrame

    _snapFrame=Instance.new("Frame")
    _snapFrame.Name="AimSnapline"
    _snapFrame.AnchorPoint=Vector2.new(0.5,0.5)
    _snapFrame.BorderSizePixel=0
    _snapFrame.BackgroundColor3=Color3.fromRGB(255,59,48)
    _snapFrame.Visible=false
    _snapFrame.Parent=_aimScreen

    _markFrame=Instance.new("Frame")
    _markFrame.Name="AimMark"
    _markFrame.AnchorPoint=Vector2.new(0.5,0.5)
    _markFrame.Size=UDim2.fromOffset(10,10)
    _markFrame.BorderSizePixel=0
    _markFrame.BackgroundColor3=Color3.fromRGB(255,59,48)
    _markFrame.Visible=false
    _markFrame.Parent=_aimScreen
    local _mc=Instance.new("UICorner")
    _mc.CornerRadius=UDim.new(1,0)
    _mc.Parent=_markFrame
    _markStroke=Instance.new("UIStroke")
    _markStroke.Thickness=1.5
    _markStroke.Color=Color3.fromRGB(255,59,48)
    _markStroke.Enabled=false
    _markStroke.Parent=_markFrame

    _crossH=Instance.new("Frame")
    _crossH.AnchorPoint=Vector2.new(0.5,0.5)
    _crossH.Position=UDim2.fromScale(0.5,0.5)
    _crossH.Size=UDim2.fromOffset(12,2)
    _crossH.BorderSizePixel=0
    _crossH.Visible=false
    _crossH.Parent=_markFrame

    _crossV=Instance.new("Frame")
    _crossV.AnchorPoint=Vector2.new(0.5,0.5)
    _crossV.Position=UDim2.fromScale(0.5,0.5)
    _crossV.Size=UDim2.fromOffset(2,12)
    _crossV.BorderSizePixel=0
    _crossV.Visible=false
    _crossV.Parent=_markFrame

    _infoLabel=Instance.new("TextLabel")
    _infoLabel.Name="AimInfo"
    _infoLabel.AnchorPoint=Vector2.new(0.5,0)
    _infoLabel.Size=UDim2.fromOffset(200,16)
    _infoLabel.BackgroundTransparency=1
    _infoLabel.Font=Enum.Font.GothamBold
    _infoLabel.TextSize=11
    _infoLabel.TextColor3=Color3.new(1,1,1)
    _infoLabel.TextStrokeTransparency=0.35
    _infoLabel.TextStrokeColor3=Color3.new(0,0,0)
    _infoLabel.Visible=false
    _infoLabel.Parent=_aimScreen
end

local function _hideVisuals()
    if _fovFrame then _fovFrame.Visible=false end
    if _snapFrame then _snapFrame.Visible=false end
    if _markFrame then _markFrame.Visible=false end
    if _infoLabel then _infoLabel.Visible=false end
end

local function _aimColor()
    if _bkE and _bkE.ownColor and typeof(_bkE.color)=="Color3" then
        return _bkE.color
    end
    return (_a.T and _a.T.accent) or Color3.fromRGB(255,59,48)
end

local function _isKeyHeld(keyName)
    if not keyName or keyName=="None" or keyName=="" then return false end
    if keyName=="MouseButton2" then
        return _bkv:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    elseif keyName=="MouseButton3" then
        return _bkv:IsMouseButtonPressed(Enum.UserInputType.MouseButton3)
    elseif keyName=="MouseButton1" then
        return _bkv:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
    end
    local ok,kc=pcall(function() return Enum.KeyCode[keyName] end)
    if ok and kc then
        return _bkv:IsKeyDown(kc)
    end
    return false
end

local function _isAimActive()
    if not _bkE or not _bkE.enabled then return false end
    local mode=_bkE.mode or "hold"
    if mode=="always" then
        return true
    elseif mode=="toggle" then
        return _bkG==true
    else
        local k=_bkE.key or "Q"
        if _isKeyHeld(k) then return true end
        if k=="Q" and _bkv:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            return true
        end
        return _bkG==true
    end
end

local function _canSee(camPos, targetPart, targetChar)
    if not _bkE.wallCheck then return true end
    local filter={workspace.CurrentCamera, _bkx and _bkx.Character, targetChar}
    _rayParams.FilterDescendantsInstances=filter
    local origin=camPos
    local dir=targetPart.Position-origin
    for _=1,4 do
        local hit=_bkw:Raycast(origin,dir,_rayParams)
        if not hit or not hit.Instance then return true end
        if targetChar and hit.Instance:IsDescendantOf(targetChar) then return true end
        if _bkE.wallClear and hit.Instance:IsA("BasePart") and (hit.Instance.Transparency>=0.35 or not hit.Instance.CanCollide) then
            table.insert(filter,hit.Instance)
            _rayParams.FilterDescendantsInstances=filter
            origin=hit.Position+dir.Unit*0.05
            dir=targetPart.Position-origin
            if dir.Magnitude<0.1 then return true end
        else
            return false
        end
    end
    return false
end

local function _resolvePart(char, mousePos, cam)
    local parts=_bkE.parts
    local wantHead,wantTorso,wantRoot,wantNearest=false,false,false,false
    if type(parts)=="table" and #parts>0 then
        for _,p in ipairs(parts) do
            if p=="head" then wantHead=true
            elseif p=="torso" then wantTorso=true
            elseif p=="root" then wantRoot=true
            elseif p=="nearest" then wantNearest=true end
        end
    else
        wantHead=true
    end
    if wantNearest then
        local candidates={"Head","UpperTorso","Torso","LowerTorso","HumanoidRootPart"}
        local bestP,bestD=nil,math.huge
        for _,name in ipairs(candidates) do
            local pt=char:FindFirstChild(name)
            if pt and pt:IsA("BasePart") then
                local vp,vis=cam:WorldToViewportPoint(pt.Position)
                if vis and vp.Z>0 then
                    local d=(Vector2.new(vp.X,vp.Y)-mousePos).Magnitude
                    if d<bestD then bestD=d;bestP=pt end
                end
            end
        end
        if bestP then return bestP end
    end
    if wantHead then
        local h=char:FindFirstChild("Head")
        if h and h:IsA("BasePart") then return h end
    end
    if wantTorso then
        local t=char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
        if t and t:IsA("BasePart") then return t end
    end
    if wantRoot then
        local r=char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
        if r and r:IsA("BasePart") then return r end
    end
    return char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
end

local function _predictPoint(char, part, camPos)
    local pos=part.Position+Vector3.new(0,tonumber(_bkE.offset) or 0,0)
    if not _bkE.predict then return pos end
    local root=char:FindFirstChild("HumanoidRootPart") or part
    local vel=root and root.AssemblyLinearVelocity or Vector3.zero
    if vel.Magnitude>0.5 and vel.Magnitude<450 then
        local ping=0
        pcall(function() ping=_bkx:GetNetworkPing() end)
        local extra=(tonumber(_bkE.lead) or 0)/1000
        local dist=(pos-camPos).Magnitude
        local bSpeed=tonumber(_bkE.bulletSpeed) or 0
        local travel=(bSpeed>0) and (dist/bSpeed) or 0
        local t=math.clamp(ping+extra+travel,0,1.2)
        pos=pos+vel*t
        local drop=tonumber(_bkE.drop) or 0
        if drop>0 and travel>0 then
            pos=pos+Vector3.new(0,0.5*drop*travel*travel,0)
        end
    end
    return pos
end

local function _pickTarget(cam, mousePos)
    local fovRadius=tonumber(_bkE.fov) or 180
    local maxRange=tonumber(_bkE.range) or _bkA
    if maxRange>=_bkA then maxRange=math.huge end
    local camPos=cam.CFrame.Position
    local roster=_a.Roster
    local onlyMarked=_bkE.onlyMarked and roster and roster.anyTargets and roster.anyTargets()
    local prio=_bkE.priority or "crosshair"

    local switchDelay=(tonumber(_bkE.switchDelay) or 0)/1000
    if switchDelay>0 and (os.clock()-_lastTargetGoneAt)<switchDelay then
        return nil,nil,nil
    end

    if _bkE.sticky and _stickyEntry and _stickyPart and _stickyPart.Parent then
        local plr=_stickyEntry.player or _stickyEntry
        local char=plr and plr.Character
        local hum=char and char:FindFirstChildOfClass("Humanoid")
        if char and hum and hum.Health>0 then
            local pt=_predictPoint(char,_stickyPart,camPos)
            local vp,vis=cam:WorldToViewportPoint(pt)
            if vis and vp.Z>0 then
                local screenDist=(Vector2.new(vp.X,vp.Y)-mousePos).Magnitude
                local worldDist=(pt-camPos).Magnitude
                if (fovRadius>=_bkB or screenDist<=fovRadius) and worldDist<=maxRange and _canSee(camPos,_stickyPart,char) then
                    return _stickyEntry,_stickyPart,pt
                end
            end
        else
            _lastTargetGoneAt=os.clock()
        end
    end
    _stickyEntry,_stickyPart=nil,nil

    local bestEntry,bestPart,bestPoint=nil,nil,nil
    local bestScore=math.huge

    for _,plr in ipairs(_bkt:GetPlayers()) do
        if plr~=_bkx and plr.Character then
            local char=plr.Character
            local entry=roster and roster.byPlayer and roster.byPlayer[plr]
            local skip=false
            if entry and roster.isHidden and roster.isHidden(entry) then skip=true end
            if not skip and onlyMarked and not (entry and roster.isTarget and roster.isTarget(entry)) then skip=true end
            if not skip and _bkE.teamCheck then
                if entry and roster.isEnemy then
                    if not roster.isEnemy(entry) then skip=true end
                elseif _bkx.Team~=nil and plr.Team~=nil and _bkx.Team==plr.Team then
                    skip=true
                end
            end
            if not skip and _bkE.ignoreFriends and entry and roster.isFriend and roster.isFriend(entry) then
                skip=true
            end
            if not skip and _bkE.skipShielded and char:FindFirstChildOfClass("ForceField") then
                skip=true
            end
            if not skip then
                local hum=(entry and entry.humanoid) or char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health>0 then
                    local part=_resolvePart(char,mousePos,cam)
                    if part then
                        local worldDist=(part.Position-camPos).Magnitude
                        if worldDist<=maxRange then
                            local aimPt=_predictPoint(char,part,camPos)
                            local vp,vis=cam:WorldToViewportPoint(aimPt)
                            if vis and vp.Z>0 then
                                local screenDist=(Vector2.new(vp.X,vp.Y)-mousePos).Magnitude
                                if fovRadius>=_bkB or screenDist<=fovRadius then
                                    if _canSee(camPos,part,char) then
                                        local score=screenDist
                                        if prio=="distance" then score=worldDist
                                        elseif prio=="health" then score=hum.Health end
                                        if score<bestScore then
                                            bestScore=score
                                            bestEntry=entry or plr
                                            bestPart=part
                                            bestPoint=aimPt
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    if bestEntry and _bkE.sticky then
        _stickyEntry,_stickyPart=bestEntry,bestPart
    end
    return bestEntry,bestPart,bestPoint
end

local function _bkU()
    if not _bkE then return end
    local cam=_bkw.CurrentCamera
    local menuOpen=(_a.Window and type(_a.Window.anyOpen)=="function" and _a.Window.anyOpen()) or false
    if not cam or menuOpen or _bkv:GetFocusedTextBox()~=nil then
        _bkz.active=false
        _bkz.target=nil
        _hideVisuals()
        return
    end

    _ensureAimGui()
    local mousePos=_bkv:GetMouseLocation()
    local col=_aimColor()
    local fovRadius=tonumber(_bkE.fov) or 180
    local showCircle=(_bkE.showFov==true) and (fovRadius<_bkB)

    if _fovFrame then
        _fovFrame.Visible=showCircle
        if showCircle then
            local d=fovRadius*2
            _fovFrame.Position=UDim2.fromOffset(mousePos.X,mousePos.Y)
            _fovFrame.Size=UDim2.fromOffset(d,d)
            _fovStroke.Color=col
            _fovStroke.Thickness=tonumber(_bkE.fovThickness) or 1.5
            local op=math.clamp((tonumber(_bkE.fovOpacity) or 35)/100,0.05,1)
            _fovStroke.Transparency=1-op
            _fovFrame.BackgroundColor3=col
            _fovFrame.BackgroundTransparency=_bkE.fovFill and math.clamp(1-op*0.25,0.65,0.96) or 1
        end
    end

    if not _bkE.enabled then
        _bkz.active=false
        _bkz.target=nil
        if _snapFrame then _snapFrame.Visible=false end
        if _markFrame then _markFrame.Visible=false end
        if _infoLabel then _infoLabel.Visible=false end
        return
    end

    local activeNow=_isAimActive()
    _bkz.active=activeNow
    local needTarget=activeNow or _bkE.showTarget or _bkE.snapline or _bkE.targetInfo
    if not needTarget then
        _bkz.target=nil
        if _snapFrame then _snapFrame.Visible=false end
        if _markFrame then _markFrame.Visible=false end
        if _infoLabel then _infoLabel.Visible=false end
        return
    end

    local entry,part,aimPt=_pickTarget(cam,mousePos)
    _bkz.target=entry
    if not part or not aimPt then
        if _snapFrame then _snapFrame.Visible=false end
        if _markFrame then _markFrame.Visible=false end
        if _infoLabel then _infoLabel.Visible=false end
        return
    end

    local vp,vis=cam:WorldToViewportPoint(aimPt)
    if not vis or vp.Z<=0 then
        if _snapFrame then _snapFrame.Visible=false end
        if _markFrame then _markFrame.Visible=false end
        if _infoLabel then _infoLabel.Visible=false end
        return
    end

    local target2D=Vector2.new(vp.X,vp.Y)

    if _snapFrame then
        if _bkE.snapline then
            local mid=(mousePos+target2D)*0.5
            local diff=target2D-mousePos
            _snapFrame.Position=UDim2.fromOffset(mid.X,mid.Y)
            _snapFrame.Size=UDim2.fromOffset(diff.Magnitude,1.5)
            _snapFrame.Rotation=math.deg(math.atan2(diff.Y,diff.X))
            _snapFrame.BackgroundColor3=col
            _snapFrame.Visible=true
        else
            _snapFrame.Visible=false
        end
    end

    if _markFrame then
        if _bkE.showTarget then
            local style=_bkE.markStyle or "dot"
            _markFrame.Position=UDim2.fromOffset(target2D.X,target2D.Y)
            _markFrame.BackgroundColor3=col
            _markStroke.Color=col
            _crossH.BackgroundColor3=col
            _crossV.BackgroundColor3=col
            if style=="ring" then
                _markFrame.Size=UDim2.fromOffset(14,14)
                _markFrame.BackgroundTransparency=1
                _markStroke.Enabled=true
                _crossH.Visible=false
                _crossV.Visible=false
            elseif style=="cross" then
                _markFrame.Size=UDim2.fromOffset(14,14)
                _markFrame.BackgroundTransparency=1
                _markStroke.Enabled=false
                _crossH.Visible=true
                _crossV.Visible=true
            else
                _markFrame.Size=UDim2.fromOffset(8,8)
                _markFrame.BackgroundTransparency=0
                _markStroke.Enabled=false
                _crossH.Visible=false
                _crossV.Visible=false
            end
            _markFrame.Visible=true
        else
            _markFrame.Visible=false
        end
    end

    if _infoLabel then
        if _bkE.targetInfo then
            local plr=(type(entry)=="table" and entry.player) or entry
            local char=part.Parent
            local hum=char and char:FindFirstChildOfClass("Humanoid")
            local hp=hum and math.floor(hum.Health+0.5) or 0
            local dist=math.floor((aimPt-cam.CFrame.Position).Magnitude+0.5)
            local name=(plr and (plr.DisplayName or plr.Name)) or "Target"
            _infoLabel.Text=string.format("%s · %dst · %d HP",name,dist,hp)
            _infoLabel.Position=UDim2.fromOffset(target2D.X,target2D.Y+12)
            _infoLabel.TextColor3=col
            _infoLabel.Visible=true
        else
            _infoLabel.Visible=false
        end
    end

    if not activeNow then return end

    local delta=target2D-mousePos
    local dz=tonumber(_bkE.deadzone) or 0
    if dz>0 and delta.Magnitude<=dz then return end

    local sx=math.clamp(tonumber(_bkE.smooth) or 25,0,99)
    local sy=(_bkE.split and math.clamp(tonumber(_bkE.smoothY) or sx,0,99)) or sx
    local sens=math.clamp((tonumber(_bkE.sens) or 100)/100,0.05,4)
    local ax=(sx<=0 and 1) or math.clamp(((100-sx)/100)^1.2*sens,0.04,1)
    local ay=(sy<=0 and 1) or math.clamp(((100-sy)/100)^1.2*sens,0.04,1)

    local method=_bkE.method or "mouse"
    local camLocked=(_bkv.MouseBehavior~=Enum.MouseBehavior.Default)
        or ((cam.Focus.Position-cam.CFrame.Position).Magnitude<1.5)

    if method=="mouse" and _bkD then
        local dx=delta.X*ax*0.65
        local dy=delta.Y*ay*0.65
        if math.abs(dx)<1 and math.abs(delta.X)>1.2 then dx=delta.X>0 and 1 or -1 end
        if math.abs(dy)<1 and math.abs(delta.Y)>1.2 then dy=delta.Y>0 and 1 or -1 end
        pcall(_bkD,dx,dy)
    end

    local goalCF=CFrame.lookAt(cam.CFrame.Position,aimPt)
    if method=="mouse" and not camLocked then
        local ray=cam:ViewportPointToRay(mousePos.X,mousePos.Y)
        local localDir=cam.CFrame:VectorToObjectSpace(ray.Direction.Unit)
        if localDir.Magnitude>0.001 then
            goalCF=goalCF*CFrame.lookAt(Vector3.zero,localDir):Inverse()
        end
    end
    local camAlpha=math.clamp((ax+ay)*0.5,0.04,1)
    cam.CFrame=cam.CFrame:Lerp(goalCF,camAlpha)
end

function _bkz.define()
    _bks.define(_ejd(1456),false)
    _bks.define(_ejd(497),180)
    _bks.define(_ejd(501),25)
    _bks.define(_ejd(1457),_ejd(887))
    _bks.define(_ejd(1458),_ejd(1459))
    _bks.define(_ejd(498),_ejd(365))
    _bks.define(_ejd(1460),true)
    _bks.define(_ejd(1461),1.5)
    _bks.define(_ejd(1462),65)
    _bks.define(_ejd(500),100)
    _bks.define(_ejd(1463),false)
    _bks.define(_ejd(1464),false)
    _bks.define(_ejd(1465),_bkr.hex(_ejd(686)))
    _bks.define(_ejd(1466),false)
    _bks.define(_ejd(1467),_ejd(297))
    _bks.define(_ejd(1468),false)
    _bks.define(_ejd(1469),false)
    _bks.define(_ejd(1470),false)
    _bks.define(_ejd(1471),25)
    _bks.define(_ejd(1472),0)
    _bks.define(_ejd(1473),0)
    _bks.define(_ejd(1474),{_ejd(533)})
    _bks.define(_ejd(1475),_ejd(146))
    _bks.define(_ejd(1476),false)
    _bks.define(_ejd(1477),0)
    _bks.define(_ejd(1478),true)
    _bks.define(_ejd(1479),false)
    _bks.define(_ejd(1480),false)
    _bks.define(_ejd(1481),false)
    _bks.define(_ejd(1482),false)
    _bks.define(_ejd(499),_bkA)
    _bks.define(_ejd(1483),false)
    _bks.define(_ejd(1484),false)
    _bks.define(_ejd(1485),0)
    _bks.define(_ejd(1486),0)
    _bks.define(_ejd(1487),0)
    _bks.define(_ejd(1488),false)
    _bks.define(_ejd(1489),_ejd(799))
    _bks.define(_ejd(1490),80)
    _bks.define(_ejd(1491),0)
    _bks.define(_ejd(1492),false)
    _bks.define(_ejd(1493),false)
    _bks.define(_ejd(1494),false)
    _bks.define(_ejd(1495),false)
    _bks.define(_ejd(1496),5)
    _bks.define(_ejd(496),false)
    _bks.define(_ejd(1497),67)
end

local _bld={Enabled=false,Size=5,HeadOnly=false,Transparent=false}
local _ble={}
local _blf=false
local _blg=0

local function _blh()
    for _bli,_blj in pairs(_ble)do
        if _bli and _bli.Character then
            local _blk=_bli.Character:FindFirstChild(_ejd(1031))
            if _blk then
                local _bll=_blk:FindFirstChildOfClass(_ejd(1019))
                if _bll then
                    pcall(function()_bll.Scale=Vector3.new(1,1,1)end)
                else
                    _blk.Size=_blj
                end
                _blk.Transparency=0
                _blk.Material=Enum.Material.Plastic
                for _,_bln in ipairs(_blk:GetChildren())do
                    if _bln:IsA(_ejd(1498))or _bln:IsA(_ejd(1499))then
                        _bln.Transparency=0
                    elseif _bln:IsA(_ejd(1500))or _bln:IsA(_ejd(1501))then
                        _bln.Enabled=true
                    end
                end
            end
        end
    end
    table.clear(_ble)
    _blf=false
end

local function _blo()
    if not _bld.Enabled then
        if _blf then _blh()end
        return
    end
    local _blp=os.clock()
    if _blp-_blg<0.25 then return end
    _blg=_blp
    _blf=true
    local _blq=math.clamp(tonumber(_bld.Size) or 5,1,6.35)
    local _blr=_bld.Transparent
    for _,_blt in ipairs(_bkt:GetPlayers())do
        if _blt~=_bkx and _blt.Character then
            local _blu=_blt.Character:FindFirstChildOfClass(_ejd(620))
            local _blv=_blt.Character:FindFirstChild(_ejd(1031))
            if _blu and _blv and _blu.Health>0 then
                if not _ble[_blt]then _ble[_blt]=_blv.Size end
                local _blw=_blv:FindFirstChildOfClass(_ejd(1019))
                local _blx=_blr and 1 or 0.65
                if _blw then
                    local _bly=_ble[_blt]
                    local _blC=Vector3.new(_blq/_bly.X,_blq/_bly.Y,_blq/_bly.Z)
                    if (_blw.Scale-_blC).Magnitude>0.05 or math.abs(_blv.Transparency-_blx)>0.05 then
                        pcall(function()_blw.Scale=_blC end)
                        _blv.CanCollide=false
                        if _blr then
                            _blv.Transparency=1
                        else
                            _blv.Transparency=0.65
                            _blv.Material=Enum.Material.ForceField
                            _blv.Color=Color3.fromRGB(255,50,50)
                        end
                    end
                else
                    local _blG=Vector3.new(_blq,_blq,_blq)
                    if (_blv.Size-_blG).Magnitude>0.05 or math.abs(_blv.Transparency-_blx)>0.05 then
                        local _blI=_blu.RigType==Enum.HumanoidRigType.R15 and _blt.Character:FindFirstChild(_ejd(1502),true)or(_blt.Character:FindFirstChild(_ejd(1325))and _blt.Character.Torso:FindFirstChild(_ejd(1502)))
                        local _blJ=_blI and _blI.C1
                        _blv.Size=_blG
                        if _blI and _blJ then pcall(function()_blI.C1=_blJ end)end
                        _blv.CanCollide=false
                        if _blr then
                            _blv.Transparency=1
                            _blv.Material=Enum.Material.Plastic
                        else
                            _blv.Transparency=0.65
                            _blv.Material=Enum.Material.ForceField
                            _blv.Color=Color3.fromRGB(255,50,50)
                        end
                        for _,_blL in ipairs(_blv:GetChildren())do
                            if _blL:IsA(_ejd(1498))or _blL:IsA(_ejd(1499))then
                                _blL.Transparency=_blr and 1 or 0
                            elseif _blL:IsA(_ejd(1500))or _blL:IsA(_ejd(1501))then
                                _blL.Enabled=not _blr
                            end
                        end
                    end
                end
            end
        end
    end
end

local _blM=0
local _blN=0
local _blO=false
local _blP=0.08
local _trigRayParams=RaycastParams.new()
_trigRayParams.FilterType=Enum.RaycastFilterType.Exclude
_trigRayParams.IgnoreWater=true

local function _blQ()
    if not _blO then return end
    local _blR=os.clock()
    if _blR-_blN<0.035 then return end
    _blN=_blR
    if _blR-_blM<_blP then return end
    local _blS=_bkw.CurrentCamera
    if not _blS or not _bkx then return end
    local _blU=_bkv:GetMouseLocation()
    local _blW=false
    _trigRayParams.FilterDescendantsInstances={_blS,_bkx.Character}
    local _bmk=_blS:ViewportPointToRay(_blU.X,_blU.Y)
    local _bml=_bkw:Raycast(_bmk.Origin,_bmk.Direction*1000,_trigRayParams)
    if _bml and _bml.Instance then
        local _bmn=_bml.Instance:FindFirstAncestorOfClass(_ejd(1503))
        if _bmn then
            local _bmo=_bkt:GetPlayerFromCharacter(_bmn)
            if _bmo and _bmo~=_bkx then
                local _bmp=_bmn:FindFirstChildOfClass(_ejd(620))
                if _bmp and _bmp.Health>0 then _blW=true end
            end
        end
    end
    if _blW then
        _blM=_blR
        if _bkx.Character then
            local _bmq=_bkx.Character:FindFirstChildOfClass(_ejd(1331))
            if _bmq then pcall(function()_bmq:Activate()end)end
        end
        if type(mouse1click)=="function" then pcall(mouse1click) end
    end
end

function _bkz.start()
    if _bkz.started then return end
    _bkz.started=true
    _bkz.define()

    _bkE=_bks.mirror({
        enabled=_ejd(1456),
        fov=_ejd(497),
        smooth=_ejd(501),
        mode=_ejd(1457),
        key=_ejd(1458),
        method=_ejd(498),
        showFov=_ejd(1460),
        fovThickness=_ejd(1461),
        fovOpacity=_ejd(1462),
        sens=_ejd(500),
        fovFill=_ejd(1463),
        ownColor=_ejd(1464),
        color=_ejd(1465),
        showTarget=_ejd(1466),
        markStyle=_ejd(1467),
        snapline=_ejd(1468),
        targetInfo=_ejd(1469),
        split=_ejd(1470),
        smoothY=_ejd(1471),
        deadzone=_ejd(1472),
        offset=_ejd(1473),
        parts=_ejd(1474),
        priority=_ejd(1475),
        onlyMarked=_ejd(1476),
        switchDelay=_ejd(1477),
        teamCheck=_ejd(1478),
        wallCheck=_ejd(1479),
        wallClear=_ejd(1480),
        ignoreFriends=_ejd(1481),
        skipShielded=_ejd(1482),
        range=_ejd(499),
        sticky=_ejd(1483),
        predict=_ejd(1484),
        lead=_ejd(1485),
        bulletSpeed=_ejd(1486),
        drop=_ejd(1487)
    })
    _bkz.options=_bkE

    if tonumber(_bks.get(_ejd(501)))==100 then
        _bks.set(_ejd(501),25)
    end
    if tonumber(_bks.get(_ejd(1496))) and tonumber(_bks.get(_ejd(1496)))>6.35 then
        _bks.set(_ejd(1496),6.35)
    end

    _bks.on(_ejd(1493),function(_bmv)_bld.Enabled=_bmv if not _bmv then _blh()end end,true)
    _bks.on(_ejd(1494),function(_bmw)_bld.HeadOnly=_bmw end,true)
    _bks.on(_ejd(1495),function(_bmx)_bld.Transparent=_bmx end,true)
    _bks.on(_ejd(1496),function(_bmy)_bld.Size=math.clamp(tonumber(_bmy) or 5,1,6.35) end,true)

    _blO=_bks.get(_ejd(1488))==true
    _blP=(tonumber(_bks.get(_ejd(1490))) or 80)/1000
    _bks.on(_ejd(1488),function(_bmz)_blO=_bmz==true end)
    _bks.on(_ejd(1490),function(_bmA)_blP=(tonumber(_bmA) or 80)/1000 end)

    _a.connect(_bkv.InputBegan,function(_bmB,_bmC)
        if _bmC or not _bkE.enabled then return end
        local kName=_bks.keyName and _bks.keyName(_bmB) or (_bmB.UserInputType==Enum.UserInputType.Keyboard and _bmB.KeyCode.Name) or nil
        local bound=_bkE.key or "Q"
        if kName and (kName==bound or (bound=="Q" and kName=="MouseButton2")) then
            if (_bkE.mode or "hold")=="toggle" then
                _bkG=not _bkG
            else
                _bkG=true
            end
        end
    end,_ejd(1505))

    _a.connect(_bkv.InputEnded,function(_bmD)
        local kName=_bks.keyName and _bks.keyName(_bmD) or (_bmD.UserInputType==Enum.UserInputType.Keyboard and _bmD.KeyCode.Name) or nil
        local bound=_bkE.key or "Q"
        if kName and (kName==bound or (bound=="Q" and kName=="MouseButton2")) then
            if (_bkE.mode or "hold")~="toggle" then
                _bkG=false
            end
        end
    end,_ejd(1506))

    _bkH=_bku.RenderStepped:Connect(function()
        if _bkE.enabled or _bkE.showFov then
            pcall(_bkU)
        else
            _hideVisuals()
        end
        if _bld.Enabled or _blf then
            pcall(_blo)
        end
        if _blO then
            pcall(_blQ)
        end
    end)

    local _bmJ={}
    local _bmL=false
    local _recoilScanned=false
    local function _bmM(_bmN)
        if _bmJ[_bmN]then return end
        _bmJ[_bmN]=true
        if type(_bmN.AddRecoil)=="function" then
            local _bmO=_bmN.AddRecoil
            _bmN.AddRecoil=function(...)if _bmL then return end return _bmO(...)end
        end
        if type(_bmN.Shake)=="function" then
            local _bmP=_bmN.Shake
            _bmN.Shake=function(...)if _bmL then return end return _bmP(...)end
        end
    end
    local function _bmV()
        local _bmW=game:GetService(_ejd(1510))
        for _,_bmY in ipairs(_bmW:GetDescendants())do
            if _bmY:IsA(_ejd(1511))and _bmY.Name==_ejd(1512)then
                local _bmZ,_bna=pcall(require,_bmY)
                if _bmZ and type(_bna)=="table" and type(_bna.AddRecoil)=="function" then
                    _bmM(_bna)
                end
            end
        end
    end
    local function _bnb()
        local _bnd=_bks.get(_ejd(496))==true or _bks.get(_ejd(1513))==true
        _bmL=_bnd
        if _bnd and not _recoilScanned then
            _recoilScanned=true
            task.spawn(function() pcall(_bmV) end)
        end
    end
    _bks.on(_ejd(496),_bnb)
    _bks.on(_ejd(1513),_bnb)
    _bnb()

    _a.spoofHooked=_a.spoofHooked or false
    local function _bne()
        local _bnf=math.floor(tonumber(_bks.get(_ejd(1497))) or 67)
        local _bng=_bkt.LocalPlayer
        if not _bng then return false end
        local _bni=pcall(function()
            _bng:SetAttribute(_ejd(1514),_bnf)
            _bng:SetAttribute(_ejd(1515),_bnf)
            _bng:SetAttribute(_ejd(1516),_bnf)
            _bng:SetAttribute(_ejd(1517),_bnf)
        end)
        local _bnk=pcall(function()
            local _bnj=_bng:FindFirstChild(_ejd(1518)) or _bng:FindFirstChild(_ejd(1514)) or _bng:FindFirstChild(_ejd(1515))
            if _bnj and _bnj:IsA(_ejd(1519))then _bnj.Value=_bnf end
        end)
        return _bni and _bnk
    end
    _a.applySpoof=_bne

    _bkt.PlayerRemoving:Connect(function(_bnl)_ble[_bnl]=nil end)
    _a.own(function()
        if _bkH then _bkH:Disconnect()_bkH=nil end
        _hideVisuals()
        _bkz.target,_bkz.active=nil,false
        _bkG=false
        _bmL=false
        _blh()
    end)
end end ]=]
        source = source:sub(1, pAimStart - 1) .. newAimBlock .. source:sub(pAimEnd)
    end

    return source
end

local function download(item, commit)
    local encoded = {}

    for part in string.gmatch(item.path, "[^/]+") do
        local value = Http:UrlEncode(part)
        value = value:gsub("%+", "%%20")
        encoded[#encoded + 1] = value
    end

    local url =
        "https://raw.githubusercontent.com/"
        .. OWNER .. "/" .. REPO .. "/"
        .. commit .. "/"
        .. table.concat(encoded, "/")

    local lastError = "Unknown download error"

    for attempt = 1, TRIES do
        local data, err = fetch(url)

        if data then
            if #data ~= item.size then
                lastError = "Wrong file size"
            elseif store(item.destination, data) then
                return true
            else
                lastError = "Could not save file"
            end
        else
            lastError = tostring(err)
        end

        if attempt < TRIES then
            task.wait(attempt * 0.5)
        end
    end

    return false, lastError
end

local function downloadAll(files, commit, record)
    local total = #files

    if total == 0 then
        print("[BombelPrivate] Everything is up to date.")
        ui("Set", "Up to date", 1, "0/0 assets")
        return true
    end

    local cursor = 0
    local completed = 0
    local downloaded = 0
    local failed = 0
    local active = 0

    local function worker()
        while true do
            cursor = cursor + 1
            local item = files[cursor]

            if not item then
                break
            end

            local ok, result, err = pcall(download, item, commit)

            if ok and result then
                record.files[item.path] = item.sha
                downloaded = downloaded + 1
                print("[Downloaded] " .. item.path)
            else
                failed = failed + 1
                warn("[Failed] " .. item.path .. " "
                    .. tostring(ok and err or result))
            end

            completed = completed + 1

            print(
                "[BombelPrivate] "
                .. completed .. "/" .. total
                .. " | Downloaded: " .. downloaded
                .. " | Failed: " .. failed
            )

            ui(
                "Set",
                "Downloading",
                completed / total,
                completed .. "/" .. total .. " assets"
            )

            if completed % 5 == 0 or completed == total then
                saveRecord(record)
            end
        end

        active = active - 1
    end

    local count = math.min(WORKERS, total)
    active = count

    for i = 1, count do
        task.spawn(worker)
    end

    while active > 0 do
        task.wait(0.1)
    end

    saveRecord(record)
    return failed == 0
end

local function verify(files)
    for _, item in ipairs(files) do
        if not isLocalFile(item.path)
            and not isLocalFile(item.destination)
            and item.path ~= "exploitershub.lua" then

            local path = item.destination

            if not has(path) then
                return false, "Missing file: " .. item.path
            end

            local ok, content = pcall(readfile, path)

            if not ok or type(content) ~= "string" then
                return false, "Invalid file: " .. item.path
            end

            if #content ~= item.size then
                return false, "Invalid file: " .. item.path
            end
        end
    end

    return true
end

local function compileSource(code)
    local ok1, fn1, err1 = pcall(loadstring, code, "=BombelPrivate")
    if ok1 and type(fn1) == "function" then
        return fn1, nil
    end

    local ok2, fn2, err2 = pcall(loadstring, code)
    if ok2 and type(fn2) == "function" then
        return fn2, nil
    end

    return nil, tostring(err2 or err1 or fn2 or fn1 or "Compilation returned nil")
end

local function start()
    if type(loadstring) ~= "function" then
        error("This executor does not support loadstring")
    end

    local ok, source = false, nil
    if has(SCRIPT) then
        ok, source = pcall(readfile, SCRIPT)
    end

    local chunk, problem
    if ok and type(source) == "string" and #source > 0 then
        local patched = patchHub(source)
        chunk, problem = compileSource(patched)
        if chunk and patched ~= source then
            pcall(writefile, SCRIPT, patched)
        end
    end

    if not chunk then
        warn("[BombelPrivate] Refreshing core script from upstream...")
        local freshUrl = "https://raw.githubusercontent.com/" .. OWNER .. "/" .. REPO .. "/main/exploitershub.lua?t=" .. tostring(os.time())
        local freshSource, fetchErr = fetch(freshUrl)
        if freshSource and type(freshSource) == "string" and #freshSource > 100000 then
            local patched = patchHub(freshSource)
            store(SCRIPT, patched)
            chunk, problem = compileSource(patched)
        else
            problem = problem or ("Could not fetch core script: " .. tostring(fetchErr))
        end
    end

    if not chunk then
        warn("[BombelPrivate] Compilation error: " .. tostring(problem))
        print("[BombelPrivate] Compilation error: " .. tostring(problem))
        error("Main script compilation failed: " .. tostring(problem))
    end

    return chunk()
end

local function install()
    if not canStore then
        error("This executor does not support the required file functions.")
    end

    folder(ROOT)
    folder(ROOT .. "/cache")

    startIsland()

    local record = readRecord()

    print("[BombelPrivate] Checking GitHub...")
    ui("Set", "Checking", 0, "Checking GitHub...")

    local repository, err = getRepository()

    if not repository then
        error("Could not check GitHub: " .. tostring(err))
    end

    ui("Set", "Preparing", 0, "Building file list...")

    local files, bytes, unchanged =
        makePlan(repository, record)

    print("[BombelPrivate] Commit: " .. repository.commit)
    print("[BombelPrivate] Already current: " .. unchanged)
    print("[BombelPrivate] To download: " .. #files)
    print("[BombelPrivate] Download size: " .. bytes .. " bytes")

    ui("Set", "Downloading", 0, "0/" .. #files .. " assets")

    if not downloadAll(files, repository.commit, record) then
        error("Some files could not be downloaded. Run the loader again.")
    end

    local latestFiles = {}

    for _, item in ipairs(repository.tree) do
        if item.type == "blob"
            and safePath(item.path)
            and not isLocalFile(item.path)
            and type(item.size) == "number" then

            latestFiles[#latestFiles + 1] = {
                path = item.path,
                size = item.size,
                destination = ROOT .. "/" .. item.path
            }
        end
    end

    ui("Set", "Verifying", 1, "Verifying files...")

    local valid, problem = verify(latestFiles)

    if not valid then
        error("Verification failed: " .. tostring(problem))
    end

    record.commit = repository.commit
    saveRecord(record)

    print("[BombelPrivate] All files are present.")
    print("[BombelPrivate] Starting main script...")

    ui("Done", "Starting", "Starting main script...")

    genv.BOMBELPRIVATE_INSTALLING = nil

    task.spawn(function()
        task.wait(1.2)
        ui("Destroy")
    end)

    return start()
end

local ok, problem = pcall(install)

genv.BOMBELPRIVATE_INSTALLING = nil

if not ok then
    local errText = tostring(problem or "Unknown error")
    warn("[BombelPrivate] Installer error: " .. errText)
    print("[BombelPrivate] Installer error: " .. errText)

    local cleanMsg = errText:gsub("^.-:%d+:%s*", "")
    ui("Fail", cleanMsg:sub(1, 42))

    task.spawn(function()
        task.wait(6)
        ui("Destroy")
    end)
end
