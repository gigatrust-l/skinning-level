local addonName = "SkinningLevel"
local sklvl = {}

local function getSkinningLevel()
    
    local prof1, prof2, archaeology, fishing, cooking, firstAid = GetProfessions()
    local professions = {prof1, prof2, archaeology, fishing, cooking, firstAid}

    for _, skill in pairs(professions) do
        name, icon, skillLevel, maxSkillLevel, numAbilities, spelloffset, skillLine, skillModifier, specializationIndex, specializationOffset = GetProfessionInfo(skill)

        if name == "Skinning" then
            return skillLevel,skillModifier, maxSkillLevel
        end
    end

    return 0, 0, 0

end

local function getMaxMobLevel(skinLevel, skinTrueLevel)

    if skinLevel > 0 then

        if skinLevel == 1 then
            return 10
        elseif skinLevel <= 100 then
            return math.floor((skinLevel/10)+10)
        elseif skinLevel > 100 and skinLevel < 374 then
            return math.min(math.floor(skinLevel/5), 73)
        elseif skinLevel >= 375 and skinLevel < 440 then
            local index=1
            for i=74, 80, 1 do
                if (i*5)+(index*5) > skinLevel then
                    return i-1
                elseif (i*5)+(index*5) == skinLevel then
                    return i
                end
		index = index + 1
            end

        elseif skinLevel >= 440 and skinLevel < 470 then

            return math.min(math.floor((skinLevel-35)/5), 83)

        elseif skinLevel >=470 and skinLevel < 600 then

            return math.min(math.floor((skinLevel+1210)/20))

        elseif skinTrueLevel >= 600 then 

            return "Max"

        end

    end

    return 0

end

local function CreateDisplayFrame(name, parentFrame, anchorPoint, relativePoint, xOffset)
    local frame = CreateFrame("Frame", name .. "Frame", parentFrame or UIParent)
    frame:SetSize(100, 20) 

    if parentFrame then
        frame:SetPoint(anchorPoint, parentFrame, relativePoint, xOffset, 0)
        
    else
        frame:SetPoint("CENTER", UIParent, "CENTER", 0, 100)
        
        frame:SetMovable(true)
        frame:EnableMouse(true)
        frame:RegisterForDrag("LeftButton")

        frame:SetScript("OnDragStart", function(self)
            self:StartMoving()
        end)

        frame:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing()
            local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
            sklvldb.point = point
            sklvldb.relativePoint = relativePoint
            sklvldb.xOfs = xOfs
            sklvldb.yOfs = yOfs
        end)

    end

    local texture = frame:CreateTexture(nil, "BACKGROUND")
    texture:SetAllPoints(true)
    texture:SetColorTexture(0.1, 0.1, 0.1, 0.8)

    local levelText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    levelText:SetPoint("CENTER") 
    levelText:SetText("Error")
    
    frame.LevelText = levelText

    return frame

end


local function makeDisplay()
    local spacing = 1 
    local width = 100

    sklvl.currentSkillDisplay = CreateDisplayFrame(addonName .. "currentSkillDisplay", nil)
    sklvl.maxSkillDisplay = CreateDisplayFrame(addonName .. "maxSkillDisplay",sklvl.currentSkillDisplay,"LEFT","RIGHT",spacing)
    sklvl.maxLevelDisplay = CreateDisplayFrame(addonName .. "maxLevelDisplay", sklvl.maxSkillDisplay,"LEFT","RIGHT",spacing)

end

local function UpdateLevelDisplay()
    if sklvldb.shown == true then

        local current, modifier, max = getSkinningLevel()

        local maxLevel = getMaxMobLevel(current+modifier, current)

        if current == 0 then
            sklvl.currentSkillDisplay:Hide()
            sklvl.maxSkillDisplay:Hide()
            sklvl.maxLevelDisplay:Hide()
            sklvldb.shown = false

        else
            sklvl.currentSkillDisplay:Show()
            sklvl.maxSkillDisplay:Show()
            sklvl.maxLevelDisplay:Show()

            sklvl.currentSkillDisplay.LevelText:SetText(tostring(current) .. " + " .. tostring(modifier))
            sklvl.maxSkillDisplay.LevelText:SetText(max)
            sklvl.maxLevelDisplay.LevelText:SetText(maxLevel)

        end

    else
        sklvl.currentSkillDisplay:Hide()
        sklvl.maxSkillDisplay:Hide()
        sklvl.maxLevelDisplay:Hide()
    
    end

end

SLASH_SKLVL1, SLASH_SKLVL2 = '/skinninglevel', '/sklvl'; -- 3.
function SlashCmdList.SKLVL(msg, editBox) -- 4.
    if msg == "update" then
        UpdateLevelDisplay()

    elseif msg == "test" then
        print("Skinning Level is Working")

    elseif msg == "max" then
        local current, modifier, max = getSkinningLevel()

        local maxLevel = getMaxMobLevel(current+modifier, current)

        print("Max Level: ".. maxLevel)

    elseif msg == "show" then
        sklvldb.shown = true

        UpdateLevelDisplay()

    elseif msg == "hide" then
        sklvldb.shown = false

        UpdateLevelDisplay()

    else
        print("Commands:")
        print("/sklvl test - Displays test message")
        print("/sklvl update - Manually updates stat info")
        print("/sklvl max - Displays maximum mob level")
        print("/sklvl show - Shows Skinning Level Interface")
        print("/sklvl hide - Hides Skinning Level Interface")

    end

end

local function OnEvent(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 == "SkinningLevel" then
            sklvldb = sklvldb or {}

            makeDisplay()

            if not sklvldb.shown == nil then
                sklvl.currentSkillDisplay:ClearAllPoints()
                sklvl.currentSkillDisplay:SetPoint(sklvldb.point,UIParent,sklvldb.relativePoint,sklvldb.xOfs,sklvldb.yOfs)

            else
                sklvl.currentSkillDisplay:SetPoint("CENTER", UIParent, "CENTER", 0, 100)

            end

            if sklvldb.shown == nil then
                sklvldb.shown = true

            end

        end

    elseif event == "PLAYER_LEVEL_UP" then
        UpdateLevelDisplay()

    elseif event == "SKILL_LINES_CHANGED" then
        UpdateLevelDisplay()

    end

end

local eventFrame = CreateFrame("Frame")  

eventFrame:RegisterEvent("PLAYER_LEVEL_UP") 

eventFrame:RegisterEvent("SKILL_LINES_CHANGED")

eventFrame:RegisterEvent("ADDON_LOADED")

eventFrame:SetScript("OnEvent", OnEvent)