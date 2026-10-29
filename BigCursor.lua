-- BigCursor 0.3.4
-- Standalone cursor-size test for the original Azeroth Survivors Windows build.
-- Technique informed by Survivor UI's GPL-3.0 Cursor.lua:
-- https://github.com/morderous/survivor-ui
--
-- The addon hides the game's cursor by handing it a transparent 32x32 texture
-- every frame, then draws the game's own cursor artwork at a configurable size.
-- This is an experimental test build, not yet verified in-game.

local BLANK = "Interface\\AddOns\\BigCursor\\Art\\Blank"
local GAME_CURSOR = "Interface\\Cursor\\"
local DEFAULT_SIZE = 46
local MIN_SIZE = 24
local MAX_SIZE = 512

BigCursorDB = BigCursorDB or {}
if type(BigCursorDB.size) ~= "number" then
    BigCursorDB.size = DEFAULT_SIZE
end
if BigCursorDB.enabled == nil then
    BigCursorDB.enabled = true
end

local cursorLayer = CreateFrame("Frame", "BigCursorOverlay", UIParent)
cursorLayer:SetFrameStrata("TOOLTIP")
cursorLayer:SetAllPoints(UIParent)
cursorLayer:Show()

local cursorTexture = cursorLayer:CreateTexture(nil, "OVERLAY")
cursorTexture:SetTexture(GAME_CURSOR .. "Point")
cursorTexture:SetWidth(DEFAULT_SIZE)
cursorTexture:SetHeight(DEFAULT_SIZE)
cursorTexture:Hide()

local currentShape = nil
local wasHidden = false

local function GetSize()
    local n = tonumber(BigCursorDB.size) or DEFAULT_SIZE
    if n < MIN_SIZE then n = MIN_SIZE end
    if n > MAX_SIZE then n = MAX_SIZE end
    return n
end

local function IsHoldingCursorItem()
    return (CursorHasItem and CursorHasItem())
        or (CursorHasSpell and CursorHasSpell())
        or (CursorHasMoney and CursorHasMoney())
end

local function IsInRun()
    local phase = AZS_RUN and AZS_RUN.ph
    return phase == "playing" or phase == "ready"
end

local function PixelsPerUnit()
    local height = nil
    if GetCVar then
        local resolution = GetCVar("gxResolution") or ""
        local _, _, found = string.find(resolution, "%d+x(%d+)")
        height = tonumber(found)
    end
    return (height or 1080) / UIParent:GetHeight()
end

local function RestoreNativeCursor()
    if wasHidden then
        wasHidden = false
        if ResetCursor then ResetCursor() end
    end
    cursorTexture:Hide()
    currentShape = nil
end

local driver = CreateFrame("Frame")
driver:SetScript("OnUpdate", function()
    if not BigCursorDB.enabled
        or not UIParent:IsVisible()
        or not IsInRun()
        or IsHoldingCursorItem() then
        RestoreNativeCursor()
        return
    end

    -- The original game writes its cursor on each world frame. Give it a
    -- transparent cursor again, then draw the larger game cursor ourselves.
    if not SetCursor(BLANK) then
        RestoreNativeCursor()
        return
    end
    wasHidden = true

    local x, y = GetCursorPosition()
    local scale = UIParent:GetEffectiveScale()
    x, y = x / scale, y / scale

    local shape = "Point"
    if SpellIsTargeting and SpellIsTargeting() then
        shape = "Cast"
    elseif UnitExists("mouseover") and UnitCanAttack("player", "mouseover") then
        shape = "Attack"
    end

    if currentShape ~= shape then
        currentShape = shape
        cursorTexture:SetTexture(GAME_CURSOR .. shape)
    end

    local unit = PixelsPerUnit()
    local size = GetSize() / unit
    cursorTexture:SetWidth(size)
    cursorTexture:SetHeight(size)
    cursorTexture:ClearAllPoints()
    cursorTexture:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x, y)
    cursorTexture:SetVertexColor(1, 1, 1)
    cursorTexture:Show()
end)

local function SetEnabled(on)
    BigCursorDB.enabled = on and true or false
    if not BigCursorDB.enabled then
        RestoreNativeCursor()
    end
    DEFAULT_CHAT_FRAME:AddMessage("BigCursor: " .. (BigCursorDB.enabled and "enabled" or "disabled"))
end

SLASH_BIGCURSOR1 = "/bigcursor"
SlashCmdList["BIGCURSOR"] = function(msg)
    msg = msg or ""
    local _, _, command, value = string.find(msg, "^%s*(%S*)%s*(.-)%s*$")
    command = string.lower(command or "")

    if command == "off" then
        SetEnabled(false)
    elseif command == "on" then
        SetEnabled(true)
    elseif command == "size" then
        local n = tonumber(value)
        if n then
            if n < MIN_SIZE then n = MIN_SIZE end
            if n > MAX_SIZE then n = MAX_SIZE end
            BigCursorDB.size = n
            DEFAULT_CHAT_FRAME:AddMessage("BigCursor: size set to " .. n .. " pixels")
        else
            DEFAULT_CHAT_FRAME:AddMessage("BigCursor: current size is " .. GetSize() .. " pixels. Use /bigcursor size 46")
        end
    elseif command == "reset" then
        BigCursorDB.size = DEFAULT_SIZE
        BigCursorDB.enabled = true
        DEFAULT_CHAT_FRAME:AddMessage("BigCursor: reset to " .. DEFAULT_SIZE .. " pixels and enabled")
    else
        DEFAULT_CHAT_FRAME:AddMessage("BigCursor commands: /bigcursor on | off | size 46 | reset")
    end
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_ENTERING_WORLD")
loader:SetScript("OnEvent", function()
    -- Start with the configured size; the driver takes over when a run is active.
    RestoreNativeCursor()
end)
