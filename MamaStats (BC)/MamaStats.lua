local TipHooker = LibStub("TipHooker-1.0")
MamaStats = LibStub("AceAddon-3.0"):NewAddon("MamaStats")

function MamaStats:OnEnable()
    TipHooker:Hook(ProcessTooltip, "item")
end

function MamaStats:OnDisable()
	TipHooker:Unhook(ProcessTooltip, "item")
end


local COLOR_LIGHT_GREEN = "FFc4e5b7"
local COLOR_GREEN = "FF00FF00"
local COLOR_LIGHT_RED = "FFf0b5b5"
local COLOR_LIGHT_BLUE = "FFbad6ef"
local COLOR_LIGHT_PURPLE = "FFc4ace5"
local COLOR_WHITE = "FFFFFFFF"

local COLOR_SPELL_FIRE = "FFff9393"
local COLOR_SPELL_SHADOW = "FFbf6ed9"
local COLOR_SPELL_FROST = "FF927dff"
local COLOR_SPELL_NATURE = "FF8efd7d"
local COLOR_SPELL_HOLY = "FFf2fe99"
local COLOR_SPELL_ARCANE = "FFff92e9"

local COLOR_TEST_CYAN = "FF00ffff"

local gemTextures = {}
local itemType = 0

local concat_index = 0
local patternCheckBoolean = false

-- Tools
function TableConcat(t1,t2)
    for i = 1, #t2 do
        t1[#t1+1] = t2[i]
    end
    -- concat debug for checking groups by number
    --[[
    if (#t1 > 0) then
        t1[#t1] = t1[#t1] .. "_" .. concat_index
        concat_index = concat_index+1
    end
    ]]
    return t1
end

function ColorText(color, text)
    local returnText = ("|c" .. color .. text .. "|r")
    return returnText
end

-- Process Tooltip
function ProcessTooltip(tooltip)
    local tipTextLeft = tooltip:GetName().."TextLeft"
	local tipTexture = tooltip:GetName().."Texture"
    itemType = 0
    
    local originalItemName, originalItemLink  = _G[tooltip:GetName()]:GetItem();
    if(originalItemName) then
        local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType,
        itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(originalItemName);
        if (itemLevel) then
            _G[tipTextLeft..1]:SetText("("..itemLevel..") ".._G[tipTextLeft..1]:GetText())
        else 
            local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType,
            itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(originalItemLink);
            if (itemLevel) then
                _G[tipTextLeft..1]:SetText("("..itemLevel..") ".._G[tipTextLeft..1]:GetText())
            end
        end 
    end


    -- if tooltip is a Relic
    if (_G[tipTextLeft..3]:GetText()== "Relic") 
    or (_G[tipTextLeft..4]:GetText() == "Relic") then
        return  
    end

    -- if tooltip is a recipe
    local startIndex = 3
    local patterCheck = _G[tipTextLeft..1]:GetText()
    if (string.sub(patterCheck, 1, 6) == "Plans:") 
    or (string.sub(patterCheck, 1, 6) == "Schema") 
    or (string.sub(patterCheck, 1, 6) == "Patter") 
    or (string.sub(patterCheck, 1, 6) == "Design") then
        if (patternCheckBoolean) then
            patternCheckBoolean = false
            return
        else
            patternCheckBoolean = true
            for i = 1, 10 do
                if (string.sub(_G[tipTextLeft..i]:GetText(), 1, 4) == "Use:") then
                    startIndex = i+3
                    i = 10
                end
            end
        end
    end

    -- adding rows to cleanup
    local rowsToClean = {}
    local rowsToCleanColor = {}
    local equips = false
    for i = startIndex, tooltip:NumLines() do 
         
        local fontString = _G[tipTextLeft..i]
		local text = fontString:GetText()
        local r, g, b, a = fontString:GetTextColor()
        local textColor = (r .. "T" .. g .. "T" .. b)
        local nextRow = _G[tipTextLeft..i+1]:GetText()

        table.insert(rowsToClean, text)
        table.insert(rowsToCleanColor, textColor)
    
        if text then
            if (string.sub(text, (#text-7), #text) == "Strength") 
            or (string.sub(text, (#text-6), #text) == "Agility") then
                if (itemType == 0) or (itemType == 2) then
                    itemType = 2
                else
                    itemType = 4
                end
            elseif (string.sub(text, (#text-8), #text) == "Intellect") 
            or (string.sub(text, (#text-5), #text) == "Spirit") then
                if (itemType == 0) or (itemType == 3) then
                    itemType = 3
                else 
                    itemType = 4
                end
            end
        end 

        -- what row to stop adding rows to cleanup
        if text then
            if (string.sub(text, 1, 6) == "Equip:") 
            or (string.sub(text, 1, 8) == "Requires") 
            or (string.sub(text, 12, 15) == "Made")
            or (string.sub(text, 1, 4) == "Use:")
            or (string.sub(text, 1, 6) == "Chance")
            or (string.sub(text, 1, 9) == "Increases") then
                --print(fontString:GetTextColor())
                equips = true
                if (nextRow) then
                    if (string.sub(nextRow, 1, 6) == "Equip:") 
                    or (string.sub(nextRow, 1, 8) == "Requires") 
                    or (string.sub(nextRow, 12, 15) == "Made")
                    or (string.sub(nextRow, 1, 4) == "Use:")
                    or (string.sub(nextRow, 1, 6) == "Chance")
                    or (string.sub(nextRow, 1, 9) == "Increases") then
                        -- do nothing
                    else
                        break
                    end
                end
            end
        end
    end

    -- if all rows are in rowsToCleanUp then do nothing
    if not(equips) then
        return
    end

    -- Simplify Equip: stats
    local simplifiedRows = simplifyEquipRows(rowsToClean)

    -- Adds things
    -- local simplifiedRows = addExtraColorToStats(simplifiedRows)

    -- Sort Simplified Rows
    --
    --local sortedSimplifiedRows, sortedSimplifiedRowsColor = sortRows(simplifiedRows, rowsToCleanColor)         --- 25.11.2022
    --

    local rowsToTooltip

    if (sortedSimplifiedRows) then
        rowsToTooltip = sortedSimplifiedRows
    elseif (simplifiedRows) then
        rowsToTooltip = simplifiedRows
    end

    -- insert new rows to tooltip
    for key, text in pairs(rowsToTooltip) do
        local row = _G[tipTextLeft..((startIndex-1)+key)]
        row:SetText(text)

        if (sortedSimplifiedRowsColor) then
            local c = sortedSimplifiedRowsColor[key]

            local colorTable = {}
            for str in string.gmatch(c, "([^T]+)") do
                if str then 
                    table.insert(colorTable, str)
                end
            end
            row:SetTextColor(colorTable[1], colorTable[2], colorTable[3])
        end
    end


end

function simplifyEquipRows(er)
    local simplifiedEquipRows = {}
    local rowsToColor = {}
    local rowsAfterColored = {}
    for key, text in pairs(er) do

        -- splitting sentence into words
        local textTable = {}
        for str in string.gmatch(text, "([^ ]+)") do
            if str then 
                table.insert(textTable, str)
            end
        end

        -- if row is druid weapon
        if (textTable[1] == "Increases" and textTable[2] == "attack") then
            for i = 1, #textTable do
                textTable[#textTable-i] = textTable[#textTable-i-1]
            end
            textTable[1] = "Equip:"
        end


        local newText = "+"
        local statType = "not avaliable"
        local statAmount
        local additionalText = ""
        local rowDone = false
        
        -- Setting text for stats
        if (textTable[1] == "Equip:") then
            if (textTable[2] == "Improves") or (textTable[2] == "Increases") or (textTable[2] == "Restores") then
                for key, str in pairs(textTable) do
                    -- Defence --

                    if (str == "resilience") then																	                            -- Resilience
                        statType = " Resilience "	
                        statColorIndex = 1
                    elseif (str == "defense") then																		                        -- Defence
                        statType = " Defense rating "
                        statColorIndex = 1
                    elseif (str == "dodge") then																			                    -- Dodge
                        statType = " Dodge rating "
                        statColorIndex = 1
                    elseif (str == "parry") then																			                    -- Parry
                        statType = " Parry rating "
                        statColorIndex = 1
                    elseif (str == "block") and (textTable[key+1] == "rating") then																-- Block
                        statType = " Block rating "
                        statColorIndex = 1
                    elseif (str == "block") and (textTable[key+1] == "value") then                                                              -- Block value
                        statType = " Block value "
                        statColorIndex = 1
                    elseif (str == "Restores") and (textTable[key+2] == "health") and (#textTable < 8) then                                     -- health per 5
                        statType = " Hp5 "
                        statColorIndex = 1

                    -- Physical --

                    elseif (str == "attack" and textTable[key+1] == "power") then                                                                   -- Attack power						
                        if (textTable[key+5] and textTable[key+5] == "Cat,") then                                                                   -- Druid Attack power
                            additionalText = "in Cat, and Bear forms"                                                
                        elseif (textTable[key+6] and textTable[key+6] == "Undead" and textTable[key+8] == "Demons.") then                           -- Undead and Deamon attack power
                            additionalText = "against Undead and Demons"                                                   										
                        end
                        statType = " Attack Power "
                        statColorIndex = 2
                    elseif (str == "expertise") then																		                        -- Expertise
                        statType = " Expertise rating "
                        statColorIndex = 2
                    elseif (str == "armor" and textTable[key+1] == "penetration") then                                                                 -- Armour pene
                        statType = " Armor Penetration "
                        statColorIndex = 2
                      
                    -- Spells --

                    elseif (str == "spell" and textTable[key+1] == "power") then
                        statType = " Spell Power "
                        statColorIndex = 3
                    elseif (str == "spell" and textTable[key+1] == "penetration") then
                        statType = " Spell Penetration "
                        statColorIndex = 3
                    elseif (str == "Restores") and (textTable[key+2] == "mana") then
                        statType = " Mp5 "                                                                                  -- Mana per 5
                        statColorIndex = 3
                    

                    -- Both --

                    elseif (str == "critical" and textTable[key+1] == "strike") then								                                -- Critical Strike
                        statType = " Critical Strike rating "
                        statColorIndex = 4
                    elseif (str == "hit" and textTable[key-1] ~= "spell") then																		-- Hit
                        statType = " Hit rating "
                        statColorIndex = 4
                    elseif (str == "haste" and textTable[key-1] ~= "spell") then																	-- Haste
                        statType = " Haste rating "
                        statColorIndex = 4

                    end

                    -- Forming simplified text
                    if (tonumber(str) and statType ~= "not avaliable") then
                        statAmount = str
                                --("+"     .. "100"                             .. " Attack Power " .. "in Cat, Bear and Moonkin form")
                                --("+"     .. "50"                              .. " Spell Damage " .. "")
                        newText = (statColorIndex .. newText .. string.gsub(statAmount, "%.", "") .. statType .. additionalText)
                        rowDone = true
                    end
                    if (rowDone) then
                        break
                    end
                end
            end

            
            
            -- Setting colors based on stat type
            if (statColorIndex == 2) and (itemType ~= 4) then
                itemType = 2
            elseif (statColorIndex == 3) and (itemType ~= 4) then
                itemType = 3
            end
        end

        -- Adding Color to text --
        if (rowDone) then
            table.insert(rowsToColor, newText)
        else 
            table.insert(simplifiedEquipRows, text)
        end
    end

    local number1 = {}
    local number2 = {}
    local number3 = {}
    local number4 = {}

    for key, str in pairs(rowsToColor) do
        if (string.sub(str, 1, 1) == "1") then
            table.insert(number1, ColorText(COLOR_LIGHT_GREEN, string.sub(str,2,#str)))
        elseif (string.sub(str, 1, 1) == "2") then
            table.insert(number2, ColorText(COLOR_LIGHT_RED, string.sub(str,2,#str)))
        elseif (string.sub(str, 1, 1) == "3") then
            table.insert(number3, ColorText(COLOR_LIGHT_BLUE, string.sub(str,2,#str)))
        elseif (string.sub(str, 1, 1) == "4") then
            if (itemType == 2) then
                table.insert(number4, ColorText(COLOR_LIGHT_RED, string.sub(str,2,#str)))
            elseif (itemType == 3) then
                table.insert(number4, ColorText(COLOR_LIGHT_BLUE, string.sub(str,2,#str)))
            else
                table.insert(number4, ColorText(COLOR_LIGHT_PURPLE, string.sub(str,2,#str)))
            end
        end
    end
    local storedColoredRows = {}

    TableConcat(storedColoredRows, number1)
    TableConcat(storedColoredRows, number2)
    TableConcat(storedColoredRows, number3)
    TableConcat(storedColoredRows, number4)
    

    local finalRows = TableConcat(simplifiedEquipRows, storedColoredRows)
    
    return finalRows
end

function colorRows(rows)
    return rows
end
--[[
function addExtraColorToStats(er)
    local simplifiedEquipRows = {}
    for key, text in pairs(er) do

        -- splitting sentence into words
        local textTable = {}
        for str in string.gmatch(text, "([^ ]+)") do
            if str then 
                table.insert(textTable, str)
            end
        end
        -- Setting color for remaining texts
        if (textTable[1] == "Use:") or (textTable[1] == "Chance") or (textTable[1] == "Equip:" and not(rowDone)) or (textTable[1] == "Set:") then
            newText = ColorText(COLOR_GREEN, textTable[1])
            local emptyBuffer = 1
            local yourSpot = false
            for key, str in pairs(textTable) do
                if (emptyBuffer <= 0) then
                    -- Remove "Your"s
                    if (str == "your") then
                        str = ""
                        yourSpot = true
                    elseif (str == "Your") and (textTable[key+1] == "attacks") then
                        str = ""
                        yourSpot = true
                        emptyBuffer = 2

                    -- Normal Stats
                    elseif (str == "Spirit") or (str == "spirit") then
                        str = ColorText(COLOR_WHITE, "Spirit")
                    elseif (str == "Stamina") or (str == "stamina") then
                        str = ColorText(COLOR_WHITE, "Stamina")
                    elseif (str == "Strength") or (str == "strength") then
                        str = ColorText(COLOR_WHITE, "Strength")
                    elseif (str == "Agility") or (str == "agility") then
                        str = ColorText(COLOR_WHITE, "Agility")
                    elseif (str == "Intellect") or (str == "intellect") then
                        str = ColorText(COLOR_WHITE, "Intellect")

                    -- Defence
                    elseif (str == "the") and (textTable[key+1] == "block") and (textTable[key+2] == "value") and (textTable[key+3] == "of") then
                        str = ColorText(COLOR_LIGHT_GREEN, "Block value")
                        emptyBuffer = 6
                    elseif (str == "defense") and (textTable[key+1] == "rating") then
                        str = ColorText(COLOR_LIGHT_GREEN, "Defence Rating")
                        emptyBuffer = 2
                    elseif (str == "Armor") then
                        str = ColorText(COLOR_LIGHT_GREEN, "Armor")
                    elseif (str == "maximum") and (textTable[key+1] == "health") then
                        str = ColorText(COLOR_LIGHT_GREEN, "Max Health")
                        emptyBuffer = 2

                    -- Physical
                    elseif (str == "attack") and (textTable[key+1] == "power") then
                        str = ColorText(COLOR_LIGHT_RED, "Attack Power")
                        emptyBuffer = 2
                    elseif (str == "haste") and (textTable[key+1] == "rating") and not(textTable[key-1] == "spell") then
                        str = ColorText(COLOR_LIGHT_RED, "Haste")
                        emptyBuffer = 2
                    elseif (str == "critical") and (textTable[key+1] == "strike") and (textTable[key+2] == "rating") then
                        str = ColorText(COLOR_LIGHT_RED, "Critical Strike rating")
                        emptyBuffer = 3
                    elseif (str == "ignore") and (textTable[key+2] == "of") then
                        local startOfArmorPen = ColorText(COLOR_GREEN, "Increase ")
                        local middleOfArmorPen = ColorText(COLOR_LIGHT_RED, "Armor Penetration")
                        local endOfArmorPen = ColorText(COLOR_GREEN, " by " .. textTable[key+1])
                        str = (startOfArmorPen .. middleOfArmorPen .. endOfArmorPen)
                        emptyBuffer = 6  
                    
                    -- Normal word
                    else 
                        str = ColorText(COLOR_GREEN, str)
                    end

                    if (yourSpot) then
                        yourSpot = false
                    else
                        newText = newText .. " " .. str
                    end
                end
                emptyBuffer = emptyBuffer - 1
            end
        end 
        table.insert(simplifiedEquipRows, newText)
    end
    return simplifiedEquipRows
end
]]

--[[
function sortRows(rows, rowsColor)
    concat_index = 0
    local sortedSimplifiedRows = {}
    local sortedSimplifiedRowsColor = {}
    local noMorePrio0 = false
    local possibleEnchant = true

    local ttPrio0 = {}  -- before stuff
    local ttPrio1 = {}  -- + stats
    local ttPrio2 = {}  -- enchants
    local ttPrio3 = {}  -- empty spaces
    local ttPrio4 = {}  -- sockets
    local ttPrio5 = {}  -- reqs, dura and class
    local ttPrio6 = {}  -- after stuff

    local ttPrio0Color = {}
    local ttPrio1Color = {}
    local ttPrio2Color = {}
    local ttPrio3Color = {}
    local ttPrio4Color = {}
    local ttPrio5Color = {}
    local ttPrio6Color = {}



    for i = 1, #rows do
        -- Check for gem slots
        if (rows[i+3]) and gemTextures[(#gemTextures)-2] and (#gemTextures > 2) 
            and (string.sub(rows[i+3], 1, 6) == "Socket") then
            table.insert(ttPrio4, (gemTextures[(#gemTextures)-2] .. rows[i]))
            table.insert(ttPrio4Color, rowsColor[i])
        elseif (rows[i+2]) and gemTextures[(#gemTextures)-1] and (#gemTextures > 1) 
            and (string.sub(rows[i+2], 1, 6) == "Socket") then
            table.insert(ttPrio4, (gemTextures[(#gemTextures)-1] .. rows[i]))
            table.insert(ttPrio4Color, rowsColor[i])
        elseif (rows[i+1]) and gemTextures[#gemTextures] and (string.sub(rows[i+1], 1, 6) == "Socket") then
            table.insert(ttPrio4, (gemTextures[#gemTextures] .. rows[i]))
            table.insert(ttPrio4Color, rowsColor[i])



        -- Socket Bonus row
        elseif (rows[i]) and (string.sub(rows[i], 1, 6) == "Socket") then
            table.insert(ttPrio4, rows[i])
            table.insert(ttPrio4Color, rowsColor[i])
            noMorePrio0 = true
            possibleEnchant = false

        -- Equip:, use: and all the rest
        elseif (string.sub(rows[i], 1, 6) == "Equip:") 
            or (string.sub(rows[i], 1, 4) == "Use:")
            or (string.sub(rows[i], 1, 6) == "Chance") then
            table.insert(ttPrio6, rows[i])
            table.insert(ttPrio6Color, rowsColor[i])
            noMorePrio0 = true

        -- Enchant Row, identified by green color and checking if armor row is green for "increased" armour
        elseif (string.sub(rowsColor[i], 1, 2) == "0T") 
            and (possibleEnchant) then
            if (string.sub(rows[i], (#rows[i]-4), (#rows[i])) == "Armor")
                and (#rows[i] < 14) then
                    table.insert(ttPrio0, rows[i])
                    table.insert(ttPrio0Color, rowsColor[i])
                    noMorePrio0 = true
                else
                    table.insert(ttPrio2, rows[i])
                    table.insert(ttPrio2Color, rowsColor[i])
                    noMorePrio0 = true
                    possibleEnchant = false
                end

        -- + Stats
        elseif (string.sub(rows[i], 1, 1) == "+")
            or (string.sub(rows[i], 1, 1) == "-")
            or (string.sub(rows[i], 11, 11) == "+") then
            table.insert(ttPrio1, rows[i])
            table.insert(ttPrio1Color, rowsColor[i])
            noMorePrio0 = true

        -- Bottom stuff
        elseif (string.sub(rows[i], 1, 8) == "Requires")
            or (string.sub(rows[i], 1, 10) == "Durability") 
            or (string.sub(rows[i], 1, 8) == "Classes:") then
            table.insert(ttPrio5, rows[i])
            table.insert(ttPrio5Color, rowsColor[i])
            noMorePrio0 = true
            possibleEnchant = false

        -- Empty spaces
        elseif (rows[i] == " ") then
            table.insert(ttPrio3, rows[i])
            table.insert(ttPrio3Color, rowsColor[i])
            noMorePrio0 = true

        -- Before stuff
        elseif not(noMorePrio0) then
            table.insert(ttPrio0, rows[i])
            table.insert(ttPrio0Color, rowsColor[i])

        -- Rest bullshit, lore text etc
        else
            table.insert(ttPrio6, rows[i])
            table.insert(ttPrio6Color, rowsColor[i])
        end
    end

    TableConcat(sortedSimplifiedRows, ttPrio0)
    TableConcat(sortedSimplifiedRows, ttPrio1)
    TableConcat(sortedSimplifiedRows, ttPrio2)
    TableConcat(sortedSimplifiedRows, ttPrio3)
    TableConcat(sortedSimplifiedRows, ttPrio4)
    TableConcat(sortedSimplifiedRows, ttPrio5)
    TableConcat(sortedSimplifiedRows, ttPrio6)

    TableConcat(sortedSimplifiedRowsColor, ttPrio0Color)
    TableConcat(sortedSimplifiedRowsColor, ttPrio1Color)
    TableConcat(sortedSimplifiedRowsColor, ttPrio2Color)
    TableConcat(sortedSimplifiedRowsColor, ttPrio3Color)
    TableConcat(sortedSimplifiedRowsColor, ttPrio4Color)
    TableConcat(sortedSimplifiedRowsColor, ttPrio5Color)
    TableConcat(sortedSimplifiedRowsColor, ttPrio6Color)

    return sortedSimplifiedRows, sortedSimplifiedRowsColor
end
]]