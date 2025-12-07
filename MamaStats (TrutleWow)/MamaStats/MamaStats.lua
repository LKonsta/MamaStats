ItemIDTooltip = CreateFrame('Frame', 'ItemIDTooltip', GameTooltip)

local COLOR_LIGHT_GREEN = "FFc4e5b7"
local COLOR_GREEN = "FF00FF00"
local COLOR_LIGHT_RED = "FFf0b5b5"
local COLOR_LIGHT_BLUE = "FFbad6ef"
local COLOR_LIGHT_PURPLE = "FFc4ace5"
local COLOR_DARK_RED = "FFff4c4c"

local COLOR_SPELL_FIRE = "FFff9393"
local COLOR_SPELL_SHADOW = "FFbf6ed9"
local COLOR_SPELL_FROST = "FF927dff"
local COLOR_SPELL_NATURE = "FF8efd7d"
local COLOR_SPELL_HOLY = "FFf2fe99"
local COLOR_SPELL_ARCANE = "FFff92e9"

function ColorText(text, color)
    local returnText = ("\124c" .. color .. text .. "\124r")
    return returnText
end

function ColorInjector(text, color, start_pos, end_pos)
	local returnText = string.sub(text, 1, start_pos - 1) .. "\124c" .. color .. string.sub(text, start_pos, end_pos) .. "\124r" .. string.sub(text, end_pos + 1)
	return returnText
end

function goThroughTooltip(tooltip)
    isRelic = false
    if IsControlKeyDown() then
		return
	else
        local textLines = {}
        local regions = {tooltip:GetRegions()}
        for _, r in ipairs(regions) do
            if r:IsObjectType("FontString") then
                local text = r:GetText()
                if text and type(text) == "string" then
                    table.insert(textLines, text)
                    if string.sub(text, 1, 5) == "Relic" then
    					isRelic = true
                    elseif string.sub(text, 1, 6) == "Equip:" and not isRelic then
                        r:SetText(TextChanger(text))
                    else
                        r:SetText(TextColorer(text))
                    end
                end
            end
        end
    end
end

function TextChanger(text) 
    local value = ""
    local value_found = false
    local second_value = ""
    local second_value_found = false
    local use_second_value = false
    local is_two_value_stat = false
    local stat = ""
    local second_stat = ""
    local i = 1
    local stat_type = 0 -- 1 physical, 2 spell, 3 defence, 4 hybrid
    local stat_colors = {COLOR_LIGHT_RED, COLOR_LIGHT_BLUE, COLOR_LIGHT_GREEN, COLOR_LIGHT_PURPLE}

    while i <= string.len(text) do

        -- getting value
        if not value_found then
            local char = string.sub(text, i, i)
            if char >= "0" and char <= "9" then
                value = value .. char
            elseif value ~= "" then
                value_found = true
            end
        end 

        -- getting second value
        if value_found and not second_value_found then
            local char = string.sub(text, i, i)
            if char >= "0" and char <= "9" then
                second_value = second_value .. char
            elseif second_value ~= "" then
                second_value_found = true
            end
        end 

        -- getting stat

        -- AoE Atiesh stats

        if string.sub(text, i, i+19) == "of all party members" then
            use_second_value = true
            -- 42 to 0 = 43 to 2
            if string.sub(text, i-56, i-2) == "s damage and healing done by magical spells and effects" then
                stat = " AoE Party Spell Damage"
				stat_type = 2
            elseif string.sub(text, i-45, i-2) == "s healing done by magical spells and effects" then
                stat = " AoE Party Healing"
				stat_type = 2
            elseif string.sub(text, i-22, i-2) == "spell critical chance" then
				stat = "% AoE Party Spell Crit"
                stat_type = 2
			elseif string.sub(text, i-25, i-2) == "attack and casting speed" then
				stat = "% AoE Party Haste"
                stat_type = 4
            end
        elseif string.sub(text, i, i+28) == "s your spell damage by up to " and (string.sub(text, i+30, i+55) == " and your healing by up to" or string.sub(text, i+31, i+56) == " and your healing by up to" or string.sub(text, i+32, i+57) == " and your healing by up to") then
            is_two_value_stat = true
            stat = " Spell Damage"
            second_stat = " Healing"
            stat_type = 2

        -- physical

        elseif string.sub(text, i, i+5) == "hit by" then
            stat = "% Hit"
            stat_type = 1
        elseif string.sub(text, i, i+17) == "critical strike by" then
            stat = "% Crit"
            stat_type = 1
        elseif  string.sub(text, i, i+12) == "Attack Power." then
            stat_type = 1    
            if string.sub(text, i-7, i-1) == "ranged " then
                stat = " Ranged Attack Power"
            else
                stat = " Attack Power"
            end

        -- Attack Power when fighting Beasts.
        -- Attack Power when fighting Undead and Demons.

        elseif  string.sub(text, i, i+25) == "Attack Power when fighting" then
            if string.sub(text, i+27, i+32) == "Beasts" then
				stat = " Attack Power, against Beasts"
                stat_type = 1
            elseif string.sub(text, i+27, i+43) == "Undead and Demons" then
                stat = " Attack Power, against Undead and Demons"
                stat_type = 1
            end
        elseif  string.sub(text, i, i+14) == "Attack Power in" then
            stat = " Attack Power, in Car and Bear froms"
            stat_type = 1
        elseif  string.sub(text, i, i+13) == "attacks ignore" then
            stat = " Armor Pene"
            stat_type = 1
        elseif  string.sub(text, i, i+17) == "attack and casting" then
            stat = "% Haste"
            stat_type = 4
        elseif string.sub(text, i, i+18) == "returned as healing" then
            stat = "% vampirism"
            stat_type = 4
        elseif  string.sub(text, i, i+9) == "Increased " then    
            stat_type = 1
            if string.sub(text, i+10, i+13) == "Axes" then
                stat = " Axes"
            elseif string.sub(text, i+10, i+16) == "Daggers" then
                stat = " Daggers"
            elseif string.sub(text, i+10, i+15) == "Swords" then
                stat = " Swords"
            elseif string.sub(text, i+10, i+14) == "Maces" then
                stat = " Maces"
            elseif string.sub(text, i+10, i+21) == "Fist Weapons" then
                stat = " Fist Weapons"
            elseif string.sub(text, i+10, i+17) == "Polearms" then
                stat = " Polearms"
            elseif  string.sub(text, i+10, i+12) == "Two" then
                if string.sub(text, i+21, i+24) == "Axes" then
                    stat = " Two-handed Axes"
                elseif string.sub(text, i+21, i+26) == "Swords" then
                    stat = " Two-handed Swords"
                elseif string.sub(text, i+21, i+25) == "Maces" then
                    stat = " Two-handed Maces"
                end
            end
            
        -- spell  

        elseif string.sub(text, i, i+16) == "s damage done by " then
            stat_type = 2
            if string.sub(text, i+17, i+20) == "Shad" then
                stat = " " .. ColorText("Shadow", COLOR_SPELL_SHADOW) .. ColorText(" Spell Damage", COLOR_LIGHT_BLUE)
            elseif string.sub(text, i+17, i+20) == "Fire" then
                stat = " " .. ColorText("Fire", COLOR_SPELL_FIRE) .. ColorText(" Spell Damage", COLOR_LIGHT_BLUE)
            elseif string.sub(text, i+17, i+20) == "Fros" then
                stat = " " .. ColorText("Frost", COLOR_SPELL_FROST) .. ColorText(" Spell Damage", COLOR_LIGHT_BLUE)
            elseif string.sub(text, i+17, i+20) == "Natu" then
                stat = " " .. ColorText("Nature", COLOR_SPELL_NATURE) .. ColorText(" Spell Damage", COLOR_LIGHT_BLUE)
            elseif string.sub(text, i+17, i+20) == "Holy" then
                stat = " " .. ColorText("Holy", COLOR_SPELL_HOLY) .. ColorText(" Spell Damage", COLOR_LIGHT_BLUE)
            elseif string.sub(text, i+17, i+20) == "Arca" then
                stat = " " .. ColorText("Arcane", COLOR_SPELL_ARCANE) .. ColorText(" Spell Damage", COLOR_LIGHT_BLUE)
            end
        elseif string.sub(text, i, i+24) == "s damage and healing done" and not string.sub(text, i+67, i+68) ~= "wh" then
            stat = " Spell Damage"
            stat_type = 2
        elseif string.sub(text, i ,i+33) == "s damage done to Undead and Demons" then
			stat = " Spell Damage, against Undead and Demons"
			stat_type = 2
        elseif string.sub(text, i, i+13) == "s healing done" then
            stat = " Healing Spells"
            stat_type = 2
        elseif string.sub(text, i, i+26) == "critical strike with spells" then
            stat = "% Spell Crit"
            stat_type = 2
        elseif string.sub(text, i, i+14) == "hit with spells" then
            stat = "% Spell Hit"
            stat_type = 2
        elseif string.sub(text, i, i+18) == "magical resistances" then
            stat = " Spell Pene"
            stat_type = 2
        elseif string.sub(text, i, i+14) == "mana per 5 sec." then
            if string.sub(text, i, i+16) == "mana per 5 sec. w" then
            else
                stat = " Mp5"
                stat_type = 2
            end
        elseif string.sub(text, i, i+21) == "Mana regeneration to c" then
            stat = "% Mana Regeneration"
            stat_type = 2

        -- tank

        elseif  string.sub(text, i, i+6) == "Defense" then
            stat = " Defense"
            stat_type = 3
        elseif  string.sub(text, i, i+9) == "health per" then
            stat = " Hp5"
            stat_type = 3
        elseif  string.sub(text, i, i+4) == "dodge" then
            stat = "% Dodge"
            stat_type = 3
        elseif  string.sub(text, i, i+4) == "parry" then
            stat = "% Parry"
            stat_type = 3
        elseif  string.sub(text, i, i+14) == "chance to block" then
            stat = "% Block"
            stat_type = 3
        elseif  string.sub(text, i, i+10) == "block value" then
            stat = " Block value"
            stat_type = 3
        elseif  string.sub(text, i, i+26) == "Reduces damage taken from c" then
            stat = "% Crit/Dot Damage Reduction"
            stat_type = 3
        elseif  string.sub(text, i, i+14) == "All Resistances" then
            stat = " All Resistances"
            stat_type = 3
            
        end       
        
        i = i+1
    end

    if is_two_value_stat then
         return ColorText("+" .. value .. stat .. " and +" .. second_value .. second_stat, stat_colors[stat_type])

    elseif value ~= "" and stat ~= "" and stat_type ~= 0 then 
        if use_second_value then
			value = second_value
		end
        return ColorText("+" .. value .. stat, stat_colors[stat_type])
    else
        return ColorText(text, COLOR_GREEN)
    end
    
end

function TextColorer(text)
	local i = 1
    local true_i = 1
    local colorchange_i = 12
    local oldText = text
    local newText = ""


    --loopping through the text

    while i <= string.len(text) do
    
        -- chancing spell type colors
        if string.sub(text, i, i+5) == "Shadow" then
            newText = ColorInjector(oldText, COLOR_SPELL_SHADOW, true_i, true_i+5)
            oldText = newText
            i = i + 9 -- length of color codes + length of "Shadow" - 1
            true_i = true_i + colorchange_i + 9
        elseif string.sub(text, i, i+3) == "Fire" then
            newText = ColorInjector(oldText, COLOR_SPELL_FIRE, true_i, true_i+3)
            oldText = newText
            i = i + 7 -- length of color codes + length of "Fire" - 1
            true_i = true_i + colorchange_i + 7
        elseif string.sub(text, i, i+4) == "Frost" then
            newText = ColorInjector(oldText, COLOR_SPELL_FROST, true_i, true_i+4)
            oldText = newText
            i = i + 8 -- length of color codes + length of "Frost" - 1
            true_i = true_i + colorchange_i + 8
        elseif string.sub(text, i, i+5) == "Nature" then
            newText = ColorInjector(oldText, COLOR_SPELL_NATURE, true_i, true_i+5)
            oldText = newText
            i = i + 9 -- length of color codes + length of "Nature" - 1
            true_i = true_i + colorchange_i + 9
        elseif string.sub(text, i, i+3) == "Holy" then
            newText = ColorInjector(oldText, COLOR_SPELL_HOLY, true_i, true_i+3)
            oldText = newText
            i = i + 7 -- length of color codes + length of "Holy" - 1
            true_i = true_i + colorchange_i + 7
        elseif string.sub(text, i, i+5) == "Arcane" then
            newText = ColorInjector(oldText, COLOR_SPELL_ARCANE, true_i, true_i+5)
            oldText = newText
            i = i + 9 -- length of color codes + length of "Arcane" - 1
            true_i = true_i + colorchange_i + 9
            
            
        elseif string.sub(text, i, i+4) == "bleed" then
            newText = ColorInjector(oldText, COLOR_DARK_RED, true_i, true_i+4)
            oldText = newText
            i = i + 9
            true_i = true_i + colorchange_i + 9
        end
        
        
        
        i = i+1
        true_i = true_i+1
    end
    return oldText
end


-- Function to process tooltips
local function HookTooltips(tooltip)
    if tooltip and tooltip:IsVisible() then
        goThroughTooltip(tooltip)
    end
end

-- Hook tooltips
local function HookAllTooltips()
    -- Hooking the GameTooltip
    if GameTooltip and GameTooltip:IsVisible() then
        HookTooltips(GameTooltip)
    end

    -- Hooking the ItemRefTooltip
    if ItemRefTooltip and ItemRefTooltip:IsVisible() then
        HookTooltips(ItemRefTooltip)
    end

    -- Manually referencing and hooking AtlasLoot tooltips
    local atlasLootTooltip = AtlasLootTooltip  -- Directly referencing the tooltip frame
    local atlasLootTooltip2 = AtlasLootTooltip2  -- Directly referencing the second tooltip frame

    -- Check and hook AtlasLoot tooltips specifically
    if atlasLootTooltip and atlasLootTooltip:IsVisible() then
        HookTooltips(atlasLootTooltip)
    end

    if atlasLootTooltip2 and atlasLootTooltip2:IsVisible() then
        HookTooltips(atlasLootTooltip2)
    end

    -- Hooking the Equip Compare Tooltips (ShoppingTooltip1 and ShoppingTooltip2)
    if ShoppingTooltip1 and ShoppingTooltip1:IsVisible() then
        HookTooltips(ShoppingTooltip1)
    end

    if ShoppingTooltip2 and ShoppingTooltip2:IsVisible() then
        HookTooltips(ShoppingTooltip2)
    end
end

-- Hook tooltips when they show up (including shopping tooltips)
local function OnTooltipShow(self)
    -- Hook all tooltips (GameTooltip, ItemRefTooltip, AtlasLootTooltips, Equip Compare Tooltips)
    HookAllTooltips()
end

-- Set the script to run when tooltips are shown or updated
ItemIDTooltip:SetScript("OnShow", OnTooltipShow)

-- Hook OnShow for ShoppingTooltip1 and ShoppingTooltip2 to ensure they're processed
ShoppingTooltip1:SetScript("OnShow", OnTooltipShow)
ShoppingTooltip2:SetScript("OnShow", OnTooltipShow)

-- Save the original functions for SetOwner and SetHyperlink
local originalSetOwner = AtlasLootTooltip.SetOwner
local originalSetHyperlink = AtlasLootTooltip.SetHyperlink

-- Hooking SetOwner function of AtlasLootTooltip
AtlasLootTooltip.SetOwner = function(self, owner, anchor, x, y)
    -- Call the original SetOwner function
    originalSetOwner(self, owner, anchor, x, y)
    
    -- Process the tooltip
    goThroughTooltip(self)
end

-- Hooking SetHyperlink function of AtlasLootTooltip
AtlasLootTooltip.SetHyperlink = function(self, hyperlink)
    -- Call the original SetHyperlink function
    originalSetHyperlink(self, hyperlink)
    
    -- Process the tooltip
    goThroughTooltip(self)
end