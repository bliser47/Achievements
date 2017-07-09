-- [[ Summary Frame ]] --
function AchievementFrameSummary_OnShow()
    if ( achievementFunctions ~= COMPARISON_ACHIEVEMENT_FUNCTIONS and achievementFunctions ~= COMPARISON_STAT_FUNCTIONS ) then
        AchievementFrameSummary:SetWidth(530);
        AchievementFrameSummary_Update();
    else
        AchievementFrameComparisonDark:Hide();
        AchievementFrameComparisonWatermark:Hide();
        AchievementFrameComparison:SetWidth(650);
        AchievementFrameSummary:SetWidth(650);
        AchievementFrameSummary_Update(true);
    end
end

function AchievementFrameSummary_Update(isCompare)
    AchievementFrameSummaryCategoriesStatusBar_Update();
    AchievementFrameSummary_UpdateAchievements(GetLatestCompletedAchievements());
end

function AchievementFrameSummary_UpdateAchievements(latestAchievement)
    local numAchievements = table.getn(latestAchievement);
    local id, name, points, completed, month, day, year, description, flags, icon;
    local buttons = AchievementFrameSummaryAchievements.buttons;
    local button, anchorTo, achievementID;
    local defaultAchievementCount = 1;

    for i=1, ACHIEVEMENTUI_MAX_SUMMARY_ACHIEVEMENTS do
        if ( buttons ) then
            button = buttons[i];
        end
        if ( not button ) then
            button = CreateFrame("Button", "AchievementFrameSummaryAchievement"..i, AchievementFrameSummaryAchievements, "SummaryAchievementTemplate");

            if ( i == 1 ) then
                button:SetPoint("TOPLEFT",AchievementFrameSummaryAchievementsHeader, "BOTTOMLEFT", 18, 2 );
                button:SetPoint("TOPRIGHT",AchievementFrameSummaryAchievementsHeader, "BOTTOMRIGHT", -18, 2 );
            else
                anchorTo = getglobal("AchievementFrameSummaryAchievement"..i-1);
                button:SetPoint("TOPLEFT",anchorTo, "BOTTOMLEFT", 0, 3 );
                button:SetPoint("TOPRIGHT",anchorTo, "BOTTOMRIGHT", 0, 3 );
            end

            if ( not buttons ) then
                buttons = AchievementFrameSummaryAchievements.buttons;
            end
            --AchievementFrameSummary_LocalizeButton(button);
        end;
        if ( i <= numAchievements ) then
            achievementID = latestAchievement[i];
            id, name, points, completed, month, day, year, description, flags, icon = GetAchievementInfo(achievementID);
            button.label:SetText(name);
            button.description:SetText(description);
            AchievementShield_SetPoints(points, button.shield.points, GameFontNormal, GameFontNormalSmall);
            if ( points > 0 ) then
                button.shield.icon:SetTexture([[Interface\Addons\Achievements\Textures\UI-Achievement-Shields]]);
            else
                button.shield.icon:SetTexture([[Interface\Addons\Achievements\Textures\UI-Achievement-Shields-NoPoints]]);
            end
            button.icon.texture:SetTexture(icon);
            button.id = id;

            if ( completed ) then
                button.dateCompleted:SetText(string.format(SHORTDATE, day, month, year));
            else
                button.dateCompleted:SetText("");
            end

            button:Saturate();
            button.tooltipTitle = nil;
            button:Show();
        else
            for i=defaultAchievementCount, ACHIEVEMENTUI_MAX_SUMMARY_ACHIEVEMENTS do
                achievementID = ACHIEVEMENTUI_DEFAULTSUMMARYACHIEVEMENTS[defaultAchievementCount];
                if ( not achievementID ) then
                    button:Hide();
                    break;
                end
                id, name, points, completed, month, day, year, description, flags, icon = GetAchievementInfo(achievementID);
                if ( completed ) then
                    defaultAchievementCount = defaultAchievementCount+1;
                else
                    id, name, points, completed, month, day, year, description, flags, icon = GetAchievementInfo(achievementID);
                    button.label:SetText(name);
                    button.description:SetText(description);
                    AchievementShield_SetPoints(points, button.shield.points, GameFontNormal, GameFontNormalSmall);
                    if ( points > 0 ) then
                        button.shield.icon:SetTexture([[Interface\Addons\Achievements\Textures\UI-Achievement-Shields]]);
                    else
                        button.shield.icon:SetTexture([[Interface\Addons\Achievements\Textures\UI-Achievement-Shields-NoPoints]]);
                    end
                    button.icon.texture:SetTexture(icon);
                    button.id = id;
                    if ( month ) then
                        button.dateCompleted:SetText(string.format(SHORTDATE, day, month, year));
                    else
                        button.dateCompleted:SetText("");
                    end
                    button:Show();
                    defaultAchievementCount = defaultAchievementCount+1;
                    button:Desaturate();
                    button.tooltipTitle = SUMMARY_ACHIEVEMENT_INCOMPLETE;
                    button.tooltip = SUMMARY_ACHIEVEMENT_INCOMPLETE_TEXT;
                    break;
                end
            end
        end
    end
    if ( numAchievements == 0 ) then
        AchievementFrameSummaryAchievementsEmptyText:Show();
    else
        AchievementFrameSummaryAchievementsEmptyText:Hide();
    end
end

function AchievementFrameSummaryCategoriesStatusBar_Update()
    local total, completed = GetNumCompletedAchievements();
    AchievementFrameSummaryCategoriesStatusBar:SetMinMaxValues(0, total);
    AchievementFrameSummaryCategoriesStatusBar:SetValue(completed);
    AchievementFrameSummaryCategoriesStatusBarText:SetText(completed.."/"..total);
end

function AchievementFrameSummaryAchievement_OnLoad(self)
    AchievementComparisonPlayerButton_OnLoad(self);
    self.highlight = getglobal(self:GetName().."Highlight");
    AchievementFrameSummaryAchievements.buttons = AchievementFrameSummaryAchievements.buttons or {};
    tinsert(AchievementFrameSummaryAchievements.buttons, self);
    self:Saturate();
    self:SetBackdropBorderColor(ACHIEVEMENTUI_REDBORDER_R, ACHIEVEMENTUI_REDBORDER_G, ACHIEVEMENTUI_REDBORDER_B, 0.5);
    self.titleBar:SetVertexColor(1,1,1,0.5);
    self.dateCompleted:Show();
end

function AchievementFrameSummaryAchievement_OnClick(self)
    local id = self.id
    local nextID, completed = GetNextAchievement(id);
    if ( nextID and completed ) then
        local newID;
        while ( nextID and completed ) do
            newID, completed = GetNextAchievement(nextID);
            if ( completed ) then
                nextID = newID;
            end
        end
        id = nextID;
    end

    AchievementFrame_SelectAchievement(id);
end

function AchievementFrameSummaryAchievement_OnEnter(self)
    self.highlight:Show();
    if ( self.tooltipTitle ) then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
        GameTooltip:SetText(self.tooltipTitle,1,1,1);
        GameTooltip:AddLine(self.tooltip, nil, nil, nil, 1);
        GameTooltip:Show();
    end
end

function AchievementFrameSummaryCategoryButton_OnClick (self)
    local id = self:GetParent():GetID();
    for _, button in next, AchievementFrameCategoriesContainer.buttons do
        if ( button.categoryID == id ) then
            button:Click();
            return;
        end
    end
end

function AchievementFrameSummaryCategory_OnLoad (self)
    self:SetMinMaxValues(0, 100);
    self:SetValue(0);
    local name = self:GetName();
    self.text = getglobal(name .. "Text");

    local categoryID = self:GetID();
    local categoryName = GetCategoryInfo(categoryID);
    getglobal(name .. "Label"):SetText(categoryName);
    -- TODO: Make this based on model
    if ( categoryID ~= 92 ) then
        self:Hide();
    end
end

function AchievementFrame_GetCategoryTotalNumAchievements (id, showAll)
    -- Not recursive because we only have one deep and this saves time.
    local totalAchievements, totalCompleted = 0, 0;
    local numAchievements, numCompleted = GetCategoryNumAchievements(id, showAll);
    totalAchievements = totalAchievements + numAchievements;
    totalCompleted = totalCompleted + numCompleted;

    for _, category in next, ACHIEVEMENTUI_CATEGORIES do
        if ( category.parent == id ) then
            numAchievements, numCompleted = GetCategoryNumAchievements(category.id, showAll);
            totalAchievements = totalAchievements + numAchievements;
            totalCompleted = totalCompleted + numCompleted;
        end
    end

    return totalAchievements, totalCompleted;
end

function AchievementFrameSummaryCategory_OnEvent (self, event, params)
    AchievementFrameSummaryCategory_OnShow(self);
end

function AchievementFrameSummaryCategory_OnShow (self)
    local totalAchievements, totalCompleted = AchievementFrame_GetCategoryTotalNumAchievements(self:GetID(), true);

    self.text:SetText(string.format("%d/%d", totalCompleted, totalAchievements));
    self:SetMinMaxValues(0, totalAchievements);
    self:SetValue(totalCompleted);
    self:RegisterEvent("ACHIEVEMENT_EARNED");
end

function AchievementFrameSummaryCategory_OnHide (self)
    self:UnregisterEvent("ACHIEVEMENT_EARNED");
end

function AchievementFrame_SelectAchievement(id, forceSelect)
    if ( not AchievementFrame:IsShown() and not forceSelect ) then
        return;
    end

    local _, _, _, achCompleted = GetAchievementInfo(id);

    --[[ TODO: Implement filters
    if ( achCompleted and (ACHIEVEMENTUI_SELECTEDFILTER == AchievementFrameFilters[ACHIEVEMENT_FILTER_INCOMPLETE].func) ) then
        AchievementFrame_SetFilter(ACHIEVEMENT_FILTER_ALL);
    elseif ( (not achCompleted) and (ACHIEVEMENTUI_SELECTEDFILTER == AchievementFrameFilters[ACHIEVEMENT_FILTER_COMPLETE].func) ) then
        AchievementFrame_SetFilter(ACHIEVEMENT_FILTER_ALL);
    end
    ]]--

    AchievementFrameTab_OnClick = AchievementFrameBaseTab_OnClick;
    AchievementFrameTab_OnClick(1);
    AchievementFrameSummary:Hide();
    AchievementFrameAchievements:Show();

    -- Figure out if this is part of a progressive achievement; if it is and it's incomplete, make sure the previous level was completed. If not, find the first incomplete achievement in the chain and display that instead.
    local _, _, _, completed = GetAchievementInfo(id);
    if ( not completed and GetPreviousAchievement(id) ) then
        local prevID = GetPreviousAchievement(id);
        _, _, _, completed = GetAchievementInfo(prevID);
        while ( prevID and not completed ) do
            id = prevID;
            prevID = GetPreviousAchievement(id);
            if ( prevID ) then
                _, _, _, completed = GetAchievementInfo(prevID);
            end
        end
    elseif ( completed ) then
        local nextID, completed = GetNextAchievement(id);
        if ( nextID and completed ) then
            local newID
            while ( nextID and completed ) do
                newID, completed = GetNextAchievement(nextID);
                if ( completed ) then
                    nextID = newID;
                end
            end
            id = nextID;
        end
    end

    AchievementFrameCategories_ClearSelection();
    local category = GetAchievementCategory(id);

    local categoryIndex, parent, hidden = 0;
    for i, entry in next, ACHIEVEMENTUI_CATEGORIES do
        if ( entry.id == category ) then
            parent = entry.parent;
        end
    end

    for i, entry in next, ACHIEVEMENTUI_CATEGORIES do
        if ( entry.id == parent ) then
            entry.collapsed = false;
        elseif ( entry.parent == parent ) then
            entry.hidden = false;
        elseif ( entry.parent == true ) then
            entry.collapsed = true;
        elseif ( entry.parent ) then
            entry.hidden = true;
        end
    end

    achievementFunctions.selectedCategory = category;
    AchievementFrameCategoriesContainerScrollBar:SetValue(0);
    AchievementFrameCategories_Update();

    local shown, i = false, 1;
    while ( not shown ) do
        for _, button in next, AchievementFrameCategoriesContainer.buttons do
            if ( button.categoryID == category and math.ceil(button:GetBottom()) >= math.ceil(AchievementFrameAchievementsContainer:GetBottom())) then
                shown = true;
            end
        end

        if ( not shown ) then
            local _, maxVal = AchievementFrameCategoriesContainerScrollBar:GetMinMaxValues();
            if ( AchievementFrameCategoriesContainerScrollBar:GetValue() == maxVal ) then
                --assert(false)
                return;
            else
                HybridScrollFrame_OnMouseWheel(AchievementFrameCategoriesContainer, -1);
            end
        end

        -- Remove me if everything's working fine
        i = i + 1;
        if ( i > 100 ) then
            --assert(false);
            return;
        end
    end

    AchievementFrameAchievements_ClearSelection();
    AchievementFrameAchievementsContainerScrollBar:SetValue(0);
    AchievementFrameAchievements_Update();

    local shown = false;
    while ( not shown ) do
        for _, button in next, AchievementFrameAchievementsContainer.buttons do
            if ( button.id == id and math.ceil(button:GetTop()) >= math.ceil(AchievementFrameAchievementsContainer:GetBottom())) then
                -- The "True" here ignores modifiers, so you don't accidentally track or link this achievement. :P
                AchievementButton_OnClick(button, true);

                -- We found the button!
                shown = button;
                break;
            end
        end

        local _, maxVal = AchievementFrameAchievementsContainerScrollBar:GetMinMaxValues();
        if ( shown ) then
            -- If we can, move the achievement we're scrolling to to the top of the screen.
            local newHeight = AchievementFrameAchievementsContainerScrollBar:GetValue() + AchievementFrameAchievementsContainer:GetTop() - shown:GetTop();
            newHeight = min(newHeight, maxVal);
            AchievementFrameAchievementsContainerScrollBar:SetValue(newHeight);
        else
            if ( AchievementFrameAchievementsContainerScrollBar:GetValue() == maxVal ) then
                --assert(false, "Failed to find achievement " .. id .. " while jumping!")
                return;
            else
                HybridScrollFrame_OnMouseWheel(AchievementFrameAchievementsContainer, -1);
            end
        end
    end
end

function AchievementFrameAchievements_FindSelection()
    local _, maxVal = AchievementFrameAchievementsContainerScrollBar:GetMinMaxValues();
    local scrollHeight = AchievementFrameAchievementsContainer:GetHeight();
    local newHeight = 0;
    AchievementFrameAchievementsContainerScrollBar:SetValue(0);
    while ( not shown ) do
        for _, button in next, AchievementFrameAchievementsContainer.buttons do
            if ( button.selected ) then
                newHeight = AchievementFrameAchievementsContainerScrollBar:GetValue() + AchievementFrameAchievementsContainer:GetTop() - button:GetTop();
                newHeight = min(newHeight, maxVal);
                AchievementFrameAchievementsContainerScrollBar:SetValue(newHeight);
                return;
            end
        end
        if ( AchievementFrameAchievementsContainerScrollBar:GetValue() == maxVal ) then
            return;
        else
            newHeight = newHeight + scrollHeight;
            newHeight = min(newHeight, maxVal);
            AchievementFrameAchievementsContainerScrollBar:SetValue(newHeight);
        end
    end
end

function AchievementFrameAchievements_AdjustSelection()
    local selectedButton;
    -- check if selection is visible
    for _, button in next, AchievementFrameAchievementsContainer.buttons do
        if ( button.selected ) then
            selectedButton = button;
            break;
        end
    end

    if ( not selectedButton ) then
        AchievementFrameAchievements_FindSelection();
    else
        local newHeight;
        if ( selectedButton:GetTop() > AchievementFrameAchievementsContainer:GetTop() ) then
            newHeight = AchievementFrameAchievementsContainerScrollBar:GetValue() + AchievementFrameAchievementsContainer:GetTop() - selectedButton:GetTop();
        elseif ( selectedButton:GetBottom() < AchievementFrameAchievementsContainer:GetBottom() ) then
            if ( selectedButton:GetHeight() > AchievementFrameAchievementsContainer:GetHeight() ) then
                newHeight = AchievementFrameAchievementsContainerScrollBar:GetValue() + AchievementFrameAchievementsContainer:GetTop() - selectedButton:GetTop();
            else
                newHeight = AchievementFrameAchievementsContainerScrollBar:GetValue() + AchievementFrameAchievementsContainer:GetBottom() - selectedButton:GetBottom();
            end
        end
        if ( newHeight ) then
            local _, maxVal = AchievementFrameAchievementsContainerScrollBar:GetMinMaxValues();
            newHeight = min(newHeight, maxVal);
            AchievementFrameAchievementsContainerScrollBar:SetValue(newHeight);
        end
    end
end

function AchievementFrame_SelectSummaryStatistic (criteriaId)
    AchievementFrameTab_OnClick = AchievementFrameBaseTab_OnClick;
    AchievementFrameTab_OnClick(2);
    AchievementFrameStats:Show();
    AchievementFrameSummary:Hide();

    AchievementFrameCategories_ClearSelection();

    local id = GetAchievementInfoFromCriteria(criteriaId);
    local category = GetAchievementCategory(id);

    local categoryIndex, parent, hidden = 0;

    local categoryIndex, parent, hidden = 0;
    for i, entry in next, ACHIEVEMENTUI_CATEGORIES do
        if ( entry.id == category ) then
            parent = entry.parent;
        end
    end

    for i, entry in next, ACHIEVEMENTUI_CATEGORIES do
        if ( entry.id == parent ) then
            entry.collapsed = false;
        elseif ( entry.parent == parent ) then
            entry.hidden = false;
        elseif ( entry.parent == true ) then
            entry.collapsed = true;
        elseif ( entry.parent ) then
            entry.hidden = true;
        end
    end

    achievementFunctions.selectedCategory = category;
    AchievementFrameCategories_Update();
    AchievementFrameCategoriesContainerScrollBar:SetValue(0);

    local shown, i = false, 1;
    while ( not shown ) do
        for _, button in next, AchievementFrameCategoriesContainer.buttons do
            if ( button.categoryID == category and math.ceil(button:GetBottom()) >= math.ceil(AchievementFrameAchievementsContainer:GetBottom())) then
                shown = true;
            end
        end

        if ( not shown ) then
            local _, maxVal = AchievementFrameCategoriesContainerScrollBar:GetMinMaxValues();
            if ( AchievementFrameCategoriesContainerScrollBar:GetValue() == maxVal ) then
                assert(false)
            else
                HybridScrollFrame_OnMouseWheel(AchievementFrameCategoriesContainer, -1);
            end
        end

        -- Remove me if everything's working fine
        i = i + 1;
        if ( i > 100 ) then
            assert(false);
        end
    end

    AchievementFrameStats_Update();
    AchievementFrameStatsContainerScrollBar:SetValue(0);

    local shown, i = false, 1;
    while ( not shown ) do
        for _, button in next, AchievementFrameStatsContainer.buttons do
            if ( button.id == id and math.ceil(button:GetBottom()) >= math.ceil(AchievementFrameStatsContainer:GetBottom())) then
                AchievementStatButton_OnClick(button);

                -- We found the button! MAKE IT SHOWN ZOMG!
                shown = button;
            end
        end

        if ( shown and AchievementFrameStatsContainerScrollBar:IsShown() ) then
            -- If we can, move the achievement we're scrolling to to the top of the screen.
            AchievementFrameStatsContainerScrollBar:SetValue(AchievementFrameStatsContainerScrollBar:GetValue() + AchievementFrameStatsContainer:GetTop() - shown:GetTop());
        elseif ( not shown ) then
            local _, maxVal = AchievementFrameStatsContainerScrollBar:GetMinMaxValues();
            if ( AchievementFrameStatsContainerScrollBar:GetValue() == maxVal ) then
                assert(false)
            else
                HybridScrollFrame_OnMouseWheel(AchievementFrameStatsContainer, -1);
            end
        end

        -- Remove me if everything's working fine.
        i = i + 1;
        if ( i > 100 ) then
            assert(false);
        end
    end
end