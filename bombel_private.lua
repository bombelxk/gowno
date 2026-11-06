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
            Method = "GET"
        })

        if ok and type(response) == "table" then
            local status = tonumber(response.StatusCode) or 0

            if status >= 200 and status < 300
                and type(response.Body) == "string" then
                return response.Body
            end

            if status >= 400 then
                return nil, "HTTP " .. status
            end
        end
    end

    local ok, body = pcall(function()
        return game:HttpGet(url)
    end)

    if ok and type(body) == "string" then
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

    -- 1. Neutralize _Eo (Discord opener)
    local p1 = source:find("local function _Eo()")
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

    -- 3. Add Now Playing HUD toggle to Settings ("On screen")
    source = replaceExact(
        source,
        "_cBJ:toggle({id=_ejd(1231),label=_ejd(3133),tip=_ejd(3134),bindable=false})",
        '_cBJ:toggle({id=_ejd(1231),label=_ejd(3133),tip=_ejd(3134),bindable=false})_cBJ:toggle({id=_ejd(2866),label="Now Playing HUD",desc="Shows current song and minute timestamp on screen",bindable=false})_cBJ:toggle({id=_ejd(2869),label="Music Top Bar",desc="Shows the music island and lyrics at the top",bindable=false})'
    )

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

    -- 10. Hitbox expander max studs: increase from 6.35 to 15
    source = replaceExact(
        source,
        "max=6.35,step=0.05,default=(-4318+4323),suffix=_ejd(2170)",
        "max=15,step=0.05,default=(-4318+4323),suffix=_ejd(2170)"
    )

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
            elseif store(item.destination, (item.path == "exploitershub.lua" and patchHub(data)) or data) then
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
            and not isLocalFile(item.destination) then

            local path = item.destination

            if not has(path) then
                return false, "Missing file: " .. item.path
            end

            local ok, content = pcall(readfile, path)

            if not ok or type(content) ~= "string" then
                return false, "Invalid file: " .. item.path
            end

            if item.path == "exploitershub.lua" then
                if #content == 0 then
                    return false, "Invalid file: " .. item.path
                end
            else
                if #content ~= item.size then
                    return false, "Invalid file: " .. item.path
                end
            end
        end
    end

    return true
end

local function start()
    if not has(SCRIPT) then
        error("exploitershub.lua is missing")
    end

    if type(loadstring) ~= "function" then
        error("This executor does not support loadstring")
    end

    local ok, source = pcall(readfile, SCRIPT)

    if not ok or type(source) ~= "string" then
        error("Could not read exploitershub.lua")
    end

    -- Dynamically patch to Bombel Private with Crimson Red theme, pure black UI, and no Discord
    source = patchHub(source)
    pcall(writefile, SCRIPT, source)

    local chunk, problem = loadstring(source, "=BombelPrivate")
    if not chunk then
        chunk, problem = loadstring(source)
    end

    if not chunk then
        warn("[BombelPrivate] Compilation error: " .. tostring(problem))
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
    warn("[BombelPrivate] Installer error: " .. tostring(problem))

    ui("Fail", tostring(problem):sub(1, 40))

    task.spawn(function()
        task.wait(4)
        ui("Destroy")
    end)
end
