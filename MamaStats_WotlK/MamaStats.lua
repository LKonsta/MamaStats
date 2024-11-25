local BRACKET_SIZE = 1000

local GS_Rarity = {
    [0] = {Red = 0.55, Green = 0.55, Blue = 0.55 },
    [1] = {Red = 1.00, Green = 1.00, Blue = 1.00 },
    [2] = {Red = 0.12, Green = 1.00, Blue = 0.00 },
    [3] = {Red = 0.00, Green = 0.50, Blue = 1.00 },
    [4] = {Red = 0.69, Green = 0.28, Blue = 0.97 },
    [5] = {Red = 0.94, Green = 0.09, Blue = 0.00 },
    [6] = {Red = 1.00, Green = 0.00, Blue = 0.00 },
    [7] = {Red = 0.90, Green = 0.80, Blue = 0.50 },
}

local GS_Formula = {
    ["A"] = {
        [4] = { ["A"] = 91.4500, ["B"] = 0.6500 },
        [3] = { ["A"] = 81.3750, ["B"] = 0.8125 },
        [2] = { ["A"] = 73.0000, ["B"] = 1.0000 }
    },
    ["B"] = {
        [4] = { ["A"] = 26.0000, ["B"] = 1.2000 },
        [3] = { ["A"] = 0.7500, ["B"] = 1.8000 },
        [2] = { ["A"] = 8.0000, ["B"] = 2.0000 },
        [1] = { ["A"] = 0.0000, ["B"] = 2.2500 }
    }
}

local GS_Quality = {
    [BRACKET_SIZE*6] = {
        ["Red"] = { ["A"] = 0.94, ["B"] = BRACKET_SIZE*5, ["C"] = 0.00006, ["D"] = 1 },
        ["Blue"] = { ["A"] = 0.47, ["B"] = BRACKET_SIZE*5, ["C"] = 0.00047, ["D"] = -1 },
        ["Green"] = { ["A"] = 0, ["B"] = 0, ["C"] = 0, ["D"] = 0 },
        ["Description"] = "Legendary"
    },
    [BRACKET_SIZE*5] = {
        ["Red"] = { ["A"] = 0.69, ["B"] = BRACKET_SIZE*4, ["C"] = 0.00025, ["D"] = 1 },
        ["Blue"] = { ["A"] = 0.28, ["B"] = BRACKET_SIZE*4, ["C"] = 0.00019, ["D"] = 1 },
        ["Green"] = { ["A"] = 0.97, ["B"] = BRACKET_SIZE*4, ["C"] = 0.00096, ["D"] = -1 },
        ["Description"] = "Epic"
    },
    [BRACKET_SIZE*4] = {
        ["Red"] = { ["A"] = 0.0, ["B"] = BRACKET_SIZE*3, ["C"] = 0.00069, ["D"] = 1 },
        ["Blue"] = { ["A"] = 0.5, ["B"] = BRACKET_SIZE*3, ["C"] = 0.00022, ["D"] = -1 },
        ["Green"] = { ["A"] = 1, ["B"] = BRACKET_SIZE*3, ["C"] = 0.00003, ["D"] = -1 },
        ["Description"] = "Superior"
    },
    [BRACKET_SIZE*3] = {
        ["Red"] = { ["A"] = 0.12, ["B"] = BRACKET_SIZE*2, ["C"] = 0.00012, ["D"] = -1 },
        ["Blue"] = { ["A"] = 1, ["B"] = BRACKET_SIZE*2, ["C"] = 0.00050, ["D"] = -1 },
        ["Green"] = { ["A"] = 0, ["B"] = BRACKET_SIZE*2, ["C"] = 0.001, ["D"] = 1 },
        ["Description"] = "Uncommon"
    },
    [BRACKET_SIZE*2] = {
        ["Red"] = { ["A"] = 1, ["B"] = BRACKET_SIZE, ["C"] = 0.00088, ["D"] = -1 },
        ["Blue"] = { ["A"] = 1, ["B"] = 000, ["C"] = 0.00000, ["D"] = 0 },
        ["Green"] = { ["A"] = 1, ["B"] = BRACKET_SIZE, ["C"] = 0.001, ["D"] = -1 },
        ["Description"] = "Common"
    },
    [BRACKET_SIZE] = {
        ["Red"] = { ["A"] = 0.55, ["B"] = 0, ["C"] = 0.00045, ["D"] = 1 },
        ["Blue"] = { ["A"] = 0.55, ["B"] = 0, ["C"] = 0.00045, ["D"] = 1 },
        ["Green"] = { ["A"] = 0.55, ["B"] = 0, ["C"] = 0.00045, ["D"] = 1 },
        ["Description"] = "Trash"
    },
}

local lineColor = {
    [0] = "b4a7d6",     -- Purple
    [1] = "9fc5e8",     -- Blue
    [2] = "ea9999",     -- Red
    [3] = "b4a7d6",     -- Purple
    [4] = "b6d7a8",     -- Green
}

function GetQuality(ItemScore)
    ItemScore = tonumber(ItemScore)
    if (not ItemScore) then
        return 0, 0, 0, "Trash"
    end
    local Red = 0.1
    local Blue = 0.1
    local Green = 0.1
    local GS_QualityDescription = "Legendary"
    for i = 0,6 do
        if ((ItemScore > i * BRACKET_SIZE) and (ItemScore <= ((i + 1) * BRACKET_SIZE))) then
            local Red = GS_Quality[( i + 1 ) * BRACKET_SIZE].Red["A"] + (((ItemScore - GS_Quality[( i + 1 ) * BRACKET_SIZE].Red["B"])*GS_Quality[( i + 1 ) * BRACKET_SIZE].Red["C"])*GS_Quality[( i + 1 ) * BRACKET_SIZE].Red["D"])
            local Blue = GS_Quality[( i + 1 ) * BRACKET_SIZE].Green["A"] + (((ItemScore - GS_Quality[( i + 1 ) * BRACKET_SIZE].Green["B"])*GS_Quality[( i + 1 ) * BRACKET_SIZE].Green["C"])*GS_Quality[( i + 1 ) * BRACKET_SIZE].Green["D"])
            local Green = GS_Quality[( i + 1 ) * BRACKET_SIZE].Blue["A"] + (((ItemScore - GS_Quality[( i + 1 ) * BRACKET_SIZE].Blue["B"])*GS_Quality[( i + 1 ) * BRACKET_SIZE].Blue["C"])*GS_Quality[( i + 1 ) * BRACKET_SIZE].Blue["D"])
            return Red, Green, Blue, GS_Quality[( i + 1 ) * BRACKET_SIZE].Description
        end
    end
    return 0.1, 0.1, 0.1, "Trash"
end

function deleteDot(amount)
    return string.sub(amount, 1, string.len(amount)-1)
end

local sL = '\124cFF'
local eL = '\124r'

local function itemToolTipHook(self)
    local _, itemLink = self:GetItem()
    if (itemLink and IsEquippableItem(itemLink)) then
        if (TacoTipConfig.show_item_level) then
            local ilvl = select(4, GetItemInfo(itemLink))
            if (ilvl and ilvl > 1) then
		local iir, iib, iig, iid = GetQuality(ilvl*21)
		local colorCode = 
			string.format("%02x", iir * 255)..
			string.format("%02x", iib * 255)..
			string.format("%02x", iig * 255)
		 
		if (self:GetName() == "GameTooltip" or self:GetName() == "ItemRefTooltip") then 
		    _G[self:GetName().."TextLeft"..1]:SetText(
			sL..colorCode.."["..ilvl.."] "..eL.. (_G[self:GetName().."TextLeft"..1]:GetText())
		    )

		end
		if (self:GetName() == "ShoppingTooltip1" or self:GetName() == "ShoppingTooltip2") then
		    _G[self:GetName().."TextLeft"..2]:SetText(
			sL..colorCode.."["..ilvl.."] "..eL.. (_G[self:GetName().."TextLeft"..2]:GetText())
		    )
		end
            end
        end
    end

    local itemType = 0      --[[ 1 magical, 2 physical, 3 hybrid, 4 tank --]]

    for i = 1, _G[self:GetName()]:NumLines(), 1 do
        local cL = _G[self:GetName().."TextLeft"..i]:GetText()
        local t={}

        for str in string.gmatch(cL, "([^%s]+)") do
            table.insert(t, str)
        end
        if t[2] == "Intellect" or t[2] == "Spirit" then
            if itemType == 0 or itemType == 1 then 
                itemType = 1
            else 
                itemType = 3
            end
        end
        if t[2] == "Agility" or t[2] == "Strength" then
            if itemType == 0 or itemType == 2 then 
                itemType = 2
            else 
                itemType = 3
            end
        end
        
        if t[1] == "Equip:" or "Increases" then
            local nL = renderNewLine(t, itemType)
            if nL ~= "" then
                _G[self:GetName().."TextLeft"..i]:SetText(nL)
            end
        end

        if t[1] == "<Shift" or t[1] == "Races:" or t[1] == "Requires" or t[1] == "<Made" then
            _G[self:GetName().."TextLeft"..i]:SetText("")
        end

        if t[4] == "second)" then
            _G[self:GetName().."TextLeft"..i]:SetText(t[1].." dps)")
        end
    end
end

GameTooltip:HookScript("OnTooltipSetItem", itemToolTipHook)
ShoppingTooltip1:HookScript("OnTooltipSetItem", itemToolTipHook)
ShoppingTooltip2:HookScript("OnTooltipSetItem", itemToolTipHook)
ItemRefTooltip:HookScript("OnTooltipSetItem", itemToolTipHook)

function renderNewLine(t, itemType)
    local amount
    local attribute
    local itemType = itemType

    if t[2] == "Increases" or t[2] == "Improves" or t[2] == "Restores" or t[1] == "Increases" then

        -- Main stats

        if t[3] == "spell" and t[4] == "power" then
            amount = deleteDot(t[6])
            attribute = "Spell power"
            itemType = 1
        elseif t[3] == "attack" and t[4] == "power" then
            amount = deleteDot(t[6])
            attribute = "Attack power"
            itemType = 2
        elseif t[2] == "attack" and t[3] == "power" and t[7] == "Cat," then
            amount = t[5]
            attribute = "Attack power in Cat and Bear forms."
            itemType = 2

        -- Hybrid stats

        elseif t[3] == "haste" then
            amount = deleteDot(t[6])
            attribute = "Haste"
        elseif t[3] == "hit" then
            amount = deleteDot(t[6])
            attribute = "Hit"
        elseif t[4] == "hit" then
            amount = deleteDot(t[7])
            attribute = "Hit"
        elseif t[3] == "critical" and t[4] == "strike" then
            amount = deleteDot(t[7])
            attribute = "Critical strike"
        elseif t[4] == "critical" and t[5] == "strike" then
            amount = deleteDot(t[8])
            attribute = "Critical strike"

        -- Physical only stats

        elseif t[4] == "armor" and t[5] == "penetration" then
            amount = deleteDot(t[7])
            attribute = "Armor penetration"
            itemType = 2
        elseif t[3] == "armor" and t[4] == "penetration" then
            amount = deleteDot(t[7])
            attribute = "Armor penetration"
            itemType = 2
        elseif t[4] == "expertise" then
            amount = deleteDot(t[7])
            attribute = "Expertise"
            itemType = 2

        -- Caster only stats
        elseif t[4] == "spell" and t[5] == "penetration" then
            amount = deleteDot(t[7])
            attribute = "Spell penetration"
            itemType = 1
        elseif t[4] == "mana" and t[5] == "per" then
            amount = t[3]
            attribute = "Mp5"
            itemType = 1

        -- Tank stats

        elseif t[3] == "defense" then
            amount = deleteDot(t[6])
            attribute = "Defense"
            itemType = 4
        elseif t[4] == "parry" then
            amount = deleteDot(t[7])
            attribute = "Parry"
            itemType = 4
        elseif t[4] == "dodge" then
            amount = deleteDot(t[7])
            attribute = "Dodge"
            itemType = 4
        elseif t[4] == "block" and t[5] == "value" then
            amount = deleteDot(t[10])
            attribute = "Block value"
            itemType = 4
        elseif t[4] == "shield" and t[5] == "block" then
            amount = deleteDot(t[8])
            attribute = "Block"
            itemType = 4
        elseif t[4] == "block" and t[5] == "rating" then
            amount = deleteDot(t[8])
            attribute = "Block"
            itemType = 4
        elseif t[4] == "health" and t[5] == "per" then
            amount = t[3]
            attribute = "Hp5"
            itemType = 4

        -- PvP stats

        elseif t[4] == "resilience" then
            amount = deleteDot(t[7])
            attribute = "Resilience"
            itemType = 4
        end
    end
    if (attribute) then
        return sL..lineColor[itemType].."+"..amount.." "..attribute..eL
    else 
        return ""
    end

end

