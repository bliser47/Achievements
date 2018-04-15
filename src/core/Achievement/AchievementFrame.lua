-- [[ AchievementFrame ]] --

function AchievementFrame_ToggleAchievementFrame(toggleStatFrame)

    -- TODO: Support comparison
    --AchievementFrameComparison:Hide();
    AchievementFrameTab_OnClick = AchievementFrameBaseTab_OnClick;
    if ( not toggleStatFrame ) then
        if ( AchievementFrame:IsShown() and AchievementFrame.selectedTab == 1 ) then
            HideUIPanel(AchievementFrame);
        else
            ShowUIPanel(AchievementFrame);
            AchievementFrameTab_OnClick(1);
        end
        return;
    end
    if ( AchievementFrame:IsShown() and AchievementFrame.selectedTab == 2 ) then
        HideUIPanel(AchievementFrame);
    else
        ShowUIPanel(AchievementFrame);
        AchievementFrameTab_OnClick(2);
    end
end

function AchievementFrame_DisplayComparison (unit)
    AchievementFrame.wasShown = nil;
    AchievementFrameTab_OnClick = AchievementFrameComparisonTab_OnClick;
    AchievementFrameTab_OnClick(1);
    ShowUIPanel(AchievementFrame);
    --AchievementFrame_ShowSubFrame(AchievementFrameComparison, AchievementFrameSummary);
    AchievementFrame_ShowSubFrame(AchievementFrameSummary); -- TODO: Remove after above fixed
    AchievementFrameComparison_SetUnit(unit);
    AchievementFrameComparison_ForceUpdate();
end

function AchievementFrame_OnLoad (self)
    --PanelTemplates_SetNumTabs(self, 2);
    --self.selectedTab = 1;
    --PanelTemplates_UpdateTabs(self);
    Achievements_OnLoad();
end

function AchievementFrame_OnShow (self)
    PlaySound("AchievementMenuOpen");
    AchievementFrameHeaderPoints:SetText(GetTotalAchievementPoints());
    if ( not AchievementFrame.wasShown ) then
        AchievementFrame.wasShown = true;
        AchievementCategoryButton_OnClick(AchievementFrameCategoriesContainerButton1);
    end
    UpdateMicroButtons();
    AchievementFrame_LoadTextures();
end

function AchievementFrame_OnHide (self)
    PlaySound("AchievementMenuClose");
    UpdateMicroButtons();
    AchievementFrame_ClearTextures();
end

function AchievementFrame_ForceUpdate ()
    if ( AchievementFrameAchievements:IsShown() ) then
        AchievementFrameAchievements_ForceUpdate();
    elseif ( AchievementFrameStats:IsShown() ) then
        AchievementFrameStats_Update();
    elseif ( AchievementFrameComparison:IsShown() ) then
        AchievementFrameComparison_ForceUpdate();
    end
end

function AchievementFrameBaseTab_OnClick (id)

    --PanelTemplates_Tab_OnClick(getglobal("AchievementFrameTab"..id), AchievementFrame);

    local isSummary = false
    if ( id == 1 ) then
        print('changing to base');
        achievementFunctions = ACHIEVEMENT_FUNCTIONS;
        AchievementFrameCategories_GetCategoryList(ACHIEVEMENTUI_CATEGORIES); -- This needs to happen before AchievementFrame_ShowSubFrame (fix for bug 157885)
        if ( achievementFunctions.selectedCategory == "summary" ) then
            isSummary = true;
            AchievementFrame_ShowSubFrame(AchievementFrameSummary);
        else
            AchievementFrame_ShowSubFrame(AchievementFrameAchievements);
        end
        AchievementFrameWaterMark:SetTexture("Interface\\AddOns\\Achievements\\src\\wotlk\\Textures\\UI-Achievement-AchievementWatermark");
    else
        print('changing to stats');
        achievementFunctions = STAT_FUNCTIONS;
        AchievementFrameCategories_GetCategoryList(ACHIEVEMENTUI_CATEGORIES);
        if ( achievementFunctions.selectedCategory == "summary" ) then
            AchievementFrame_ShowSubFrame(AchievementFrameStats);
            achievementFunctions.selectedCategory = ACHIEVEMENT_COMPARISON_STATS_SUMMARY_ID;
            AchievementFrameStatsContainerScrollBar:SetValue(0);
        else
            AchievementFrame_ShowSubFrame(AchievementFrameStats);
        end
        AchievementFrameWaterMark:SetTexture("Interface\\AddOns\\Achievements\\src\\wotlk\\Textures\\UI-Achievement-StatWatermark");
    end

    AchievementFrameCategories_Update();

    -- TODO: Sometimes updateFunc is undefined here
    if ( not isSummary and achievementFunctions.updateFunc ) then
        achievementFunctions.updateFunc();
    end
end

AchievementFrameTab_OnClick = AchievementFrameBaseTab_OnClick;

function AchievementFrameComparisonTab_OnClick (id)
    if ( id == 1 ) then
        print('changing to comparison');
        achievementFunctions = COMPARISON_ACHIEVEMENT_FUNCTIONS;
        AchievementFrame_ShowSubFrame(AchievementFrameComparison, AchievementFrameComparisonContainer);
        AchievementFrameWaterMark:SetTexture("Interface\\AddOns\\Achievements\\src\\wotlk\\Textures\\UI-Achievement-AchievementWatermark");
    else
        print('changing to comparison stat');
        achievementFunctions = COMPARISON_STAT_FUNCTIONS;
        AchievementFrame_ShowSubFrame(AchievementFrameComparison, AchievementFrameComparisonStatsContainer);
        AchievementFrameWaterMark:SetTexture("Interface\\AddOns\\Achievements\\src\\wotlk\\Textures\\UI-Achievement-StatWatermark");
    end

    AchievementFrameCategories_GetCategoryList(ACHIEVEMENTUI_CATEGORIES);
    AchievementFrameCategories_Update();
    PanelTemplates_Tab_OnClick(getglobal("AchievementFrameTab"..id), AchievementFrame);

    achievementFunctions.updateFunc();
end

ACHIEVEMENTFRAME_SUBFRAMES = {
    "AchievementFrameSummary",
    "AchievementFrameAchievements",
    --"AchievementFrameStats",
    --"AchievementFrameComparison",
    --"AchievementFrameComparisonContainer",
    --"AchievementFrameComparisonStatsContainer"
};

function AchievementFrame_ShowSubFrame(frame1,frame2,frame3)
    local subFrame, show;
    local params = {frame1,frame2,frame3}; -- TODO: This is a hack!
    for _, name in next, ACHIEVEMENTFRAME_SUBFRAMES  do
        subFrame = getglobal(name);
        show = false;
        for i=1, table.getn(params) do
            if subFrame ==  params[i] then
                show = true
            end
        end
        if ( show ) then
            subFrame:Show();
        else
            subFrame:Hide();
        end
    end
end


function AchievementObjectives_DisplayProgressiveAchievement (objectivesFrame, id)
    local ACHIEVEMENTMODE_PROGRESSIVE = 2;
    local achievementID = id;

    for i in next, ACHIEVEMENT_ACHIEVEMENT_LIST do
        ACHIEVEMENT_ACHIEVEMENT_LIST[i] = nil;
    end

    tinsert(ACHIEVEMENT_ACHIEVEMENT_LIST, 1, achievementID);
    while GetPreviousAchievement(achievementID) do
        tinsert(ACHIEVEMENT_ACHIEVEMENT_LIST, 1, GetPreviousAchievement(achievementID));
        achievementID = GetPreviousAchievement(achievementID);
    end

    local i = 0;
    for index, achievementID in ipairs(ACHIEVEMENT_ACHIEVEMENT_LIST) do
        local _, achievementName, points, completed, month, day, year, description, flags, iconpath = GetAchievementInfo(achievementID);

        local miniAchievement = AchievementButton_GetMiniAchievement(index);

        miniAchievement:Show();
        miniAchievement:SetParent(objectivesFrame);
        _G[miniAchievement:GetName() .. "Icon"]:SetTexture(iconpath);
        if ( index == 1 ) then
            miniAchievement:SetPoint("TOPLEFT", objectivesFrame, "TOPLEFT", -4, -4);
        elseif ( index == 7 ) then
            miniAchievement:SetPoint("TOPLEFT", ACHIEVEMENT_MINI_TABLE[1], "BOTTOMLEFT", 0, -8);
        else
            miniAchievement:SetPoint("TOPLEFT", ACHIEVEMENT_MINI_TABLE[index-1], "TOPRIGHT", 4, 0);
        end

        miniAchievement.points:SetText(points);

        miniAchievement.numCriteria = 0;
        if ( not ( bit.band(flags, ACHIEVEMENT_FLAGS_HAS_PROGRESS_BAR) == ACHIEVEMENT_FLAGS_HAS_PROGRESS_BAR ) ) then
            for i = 1, GetAchievementNumCriteria(achievementID) do
                local criteriaString, criteriaType, completed = GetAchievementCriteriaInfo(achievementID, i);
                if ( completed == false ) then
                    criteriaString = "|CFF808080 - " .. criteriaString;
                else
                    criteriaString = "|CFF00FF00 - " .. criteriaString;
                end
                miniAchievement["criteria" .. i] = criteriaString;
                miniAchievement.numCriteria = i;
            end
        end
        miniAchievement.name = achievementName;
        miniAchievement.desc = description;
        if ( month ) then
            miniAchievement.date = string.format(SHORTDATE, day, month, year);
        end
        i = index;
    end

    objectivesFrame:SetHeight(math.ceil(i/6) * ACHIEVEMENTUI_PROGRESSIVEHEIGHT);
    objectivesFrame:SetWidth(min(i, 6) * ACHIEVEMENTUI_PROGRESSIVEWIDTH);
    objectivesFrame.mode = ACHIEVEMENTMODE_PROGRESSIVE;
end

function AchievementObjectives_DisplayCriteria (objectivesFrame, id)
    if ( not id ) then
        return;
    end

    local ACHIEVEMENTMODE_CRITERIA = 1;
    local numCriteria = GetAchievementNumCriteria(id);

    if ( numCriteria == 0 ) then
        objectivesFrame.mode = ACHIEVEMENTMODE_CRITERIA;
        objectivesFrame:SetHeight(0);
        return;
    end

    local frameLevel = objectivesFrame:GetFrameLevel() + 1;

    -- Why textStrings? You try naming anything just "string" and see how happy you are.
    local textStrings, progressBars, metas = 0, 0, 0;

    local numRows = 0;
    local maxCriteriaWidth = 0;
    local yPos;
    for i = 1, numCriteria do
        local criteriaString, criteriaType, completed, quantity, reqQuantity, charName, flags, assetID, quantityString = GetAchievementCriteriaInfo(id, i);

        if ( criteriaType == CRITERIA_TYPE_ACHIEVEMENT and assetID ) then
            metas = metas + 1;
            local metaCriteria = AchievementButton_GetMeta(metas);

            if ( metas == 1 ) then
                metaCriteria:SetPoint("TOP", objectivesFrame, "TOP", 0, -4);
                numRows = numRows + 2;
            elseif ( math.fmod(metas, 2) == 0 ) then
                yPos = -((metas/2 - 1) * 28) - 8;
                ACHIEVEMENT_META_CRITERIA_TABLE[metas-1]:SetPoint("TOPLEFT", objectivesFrame, "TOPLEFT", 20, yPos);
                metaCriteria:SetPoint("TOPLEFT", objectivesFrame, "TOPLEFT", 210, yPos);
            else
                metaCriteria:SetPoint("TOPLEFT", objectivesFrame, "TOPLEFT", 20, -(math.ceil(metas/2 - 1) * 28) - 8);
                numRows = numRows + 2;
            end

            local id, achievementName, points, completed, month, day, year, description, flags, iconpath = GetAchievementInfo(assetID);

            if ( month ) then
                metaCriteria.date = string.format(SHORTDATE, day, month, year);
            else
                metaCriteria.date = nil;
            end

            metaCriteria.id = id;
            metaCriteria.label:SetText(achievementName);
            metaCriteria.icon:SetTexture(iconpath);

            if ( objectivesFrame.completed and completed ) then
                metaCriteria.check:Show();
                metaCriteria.border:SetVertexColor(1, 1, 1, 1);
                metaCriteria.icon:SetVertexColor(1, 1, 1, 1);
                metaCriteria.label:SetShadowOffset(0, 0)
                metaCriteria.label:SetTextColor(0, 0, 0, 1);
            elseif ( completed ) then
                metaCriteria.check:Show();
                metaCriteria.border:SetVertexColor(1, 1, 1, 1);
                metaCriteria.icon:SetVertexColor(1, 1, 1, 1);
                metaCriteria.label:SetShadowOffset(1, -1)
                metaCriteria.label:SetTextColor(0, 1, 0, 1);
            else
                metaCriteria.check:Hide();
                metaCriteria.border:SetVertexColor(.75, .75, .75, 1);
                metaCriteria.icon:SetVertexColor(.55, .55, .55, 1);
                metaCriteria.label:SetShadowOffset(1, -1)
                metaCriteria.label:SetTextColor(.6, .6, .6, 1);
            end

            metaCriteria:SetParent(objectivesFrame);
            metaCriteria:Show();
        elseif ( bit.band(flags, ACHIEVEMENT_CRITERIA_PROGRESS_BAR) == ACHIEVEMENT_CRITERIA_PROGRESS_BAR ) then
            -- Display this criteria as a progress bar!
            progressBars = progressBars + 1;
            local progressBar = AchievementButton_GetProgressBar(progressBars);

            if ( progressBars == 1 ) then
                progressBar:SetPoint("TOP", objectivesFrame, "TOP", 4, -4);
            else
                progressBar:SetPoint("TOP", ACHIEVEMENT_PROGRESS_BAR_TABLE[progressBars-1], "BOTTOM", 0, 0);
            end

            progressBar.text:SetText(string.format("%s", quantityString));
            progressBar:SetMinMaxValues(0, reqQuantity);
            progressBar:SetValue(quantity);

            progressBar:SetParent(objectivesFrame);
            progressBar:Show();

            numRows = numRows + 1;
        else
            textStrings = textStrings + 1;
            local criteria = AchievementButton_GetCriteria(textStrings);
            criteria:ClearAllPoints();
            if ( textStrings == 1 ) then
                if ( numCriteria == 1 ) then
                    criteria:SetPoint("TOP", objectivesFrame, "TOP", -14, 0);
                else
                    criteria:SetPoint("TOPLEFT", objectivesFrame, "TOPLEFT", 0, 0);
                end

            else
                criteria:SetPoint("TOPLEFT", ACHIEVEMENT_CRITERIA_TABLE[textStrings-1], "BOTTOMLEFT", 0, 0);
            end

            if ( objectivesFrame.completed and completed ) then
                criteria.name:SetTextColor(0, 0, 0, 1);
                criteria.name:SetShadowOffset(0, 0);
            elseif ( completed ) then
                criteria.name:SetTextColor(0, 1, 0, 1);
                criteria.name:SetShadowOffset(1, -1);
            else
                criteria.name:SetTextColor(.6, .6, .6, 1);
                criteria.name:SetShadowOffset(1, -1);
            end

            if ( completed ) then
                criteria.check:SetPoint("LEFT", 18, -3);
                criteria.name:SetPoint("LEFT", criteria.check, "RIGHT", 0, 2);
                criteria.check:Show();
                criteria.name:SetText(criteriaString);
            else
                criteria.check:SetPoint("LEFT", 0, -3);
                criteria.name:SetPoint("LEFT", criteria.check, "RIGHT", 5, 2);
                criteria.check:Hide();
                criteria.name:SetText("- "..criteriaString);
            end

            criteria:SetParent(objectivesFrame);
            criteria:Show();
            local stringWidth = criteria.name:GetStringWidth()
            criteria:SetWidth(stringWidth + criteria.check:GetWidth());
            maxCriteriaWidth = max(maxCriteriaWidth, stringWidth + criteria.check:GetWidth());

            numRows = numRows + 1;
        end
    end

    if ( textStrings > 0 and progressBars > 0 ) then
        -- If we have text criteria and progressBar criteria, display the progressBar criteria first and position the textStrings under them.
        ACHIEVEMENT_CRITERIA_TABLE[1]:ClearAllPoints();
        if ( textStrings == 1 ) then
            ACHIEVEMENT_CRITERIA_TABLE[1]:SetPoint("TOP", ACHIEVEMENT_PROGRESS_BAR_TABLE[progressBars], "BOTTOM", -14, -4);
        else
            ACHIEVEMENT_CRITERIA_TABLE[1]:SetPoint("TOP", ACHIEVEMENT_PROGRESS_BAR_TABLE[progressBars], "BOTTOM", 0, -4);
            ACHIEVEMENT_CRITERIA_TABLE[1]:SetPoint("LEFT", objectivesFrame, "LEFT", 0, 0);
        end
    elseif ( textStrings > 1 ) then
        -- Figure out if we can make multiple columns worth of criteria instead of one long one
        local numColumns = floor(ACHIEVEMENTUI_MAXCONTENTWIDTH/maxCriteriaWidth);
        if ( numColumns > 1 ) then
            local step;
            local rows = 1;
            local position = 0;
            for i=1, table.getn(ACHIEVEMENT_CRITERIA_TABLE) do
                position = position + 1;
                if ( position > numColumns ) then
                    position = position - numColumns;
                    rows = rows + 1;
                end

                if ( rows == 1 ) then
                    ACHIEVEMENT_CRITERIA_TABLE[i]:ClearAllPoints();
                    ACHIEVEMENT_CRITERIA_TABLE[i]:SetPoint("TOPLEFT", objectivesFrame, "TOPLEFT", (position - 1)*(ACHIEVEMENTUI_MAXCONTENTWIDTH/numColumns), 0);
                else
                    ACHIEVEMENT_CRITERIA_TABLE[i]:ClearAllPoints();
                    ACHIEVEMENT_CRITERIA_TABLE[i]:SetPoint("TOPLEFT", ACHIEVEMENT_CRITERIA_TABLE[position + ((rows - 2) * numColumns)], "BOTTOMLEFT", 0, 0);
                end
            end
            numRows = ceil(numRows/numColumns);
        end
    end

    if ( metas > 0 ) then
        objectivesFrame:SetHeight(numRows * ACHIEVEMENTBUTTON_METAROWHEIGHT + 10);
    else
        objectivesFrame:SetHeight(numRows * ACHIEVEMENTBUTTON_CRITERIAROWHEIGHT);
    end
    objectivesFrame.mode = ACHIEVEMENTMODE_CRITERIA;
end

function AchievementFrame_GetCategoryNumAchievements_All (categoryID)
    local numAchievements, numCompleted = GetCategoryNumAchievements(categoryID);

    return numAchievements, numCompleted, 0;
end

function AchievementFrame_IsFeatOfStrength()
    if ( AchievementFrame.selectedTab == 1 and achievementFunctions.selectedCategory == displayCategories[table.getn(displayCategories)].id ) then
        return true;
    end
    return false;
end

function AchievementFrame_ClearTextures()
    for k, v in pairs(ACHIEVEMENT_TEXTURES_TO_LOAD) do
        getglobal(v.name):SetTexture(nil);
    end
end

function AchievementFrame_LoadTextures()
    for k, v in pairs(ACHIEVEMENT_TEXTURES_TO_LOAD) do
        if ( v.file ) then
            getglobal(v.name):SetTexture(v.file);
        end
    end
end

function AchievementFrame_GetCategoryNumAchievements_Complete (categoryID)
    local numAchievements, numCompleted = GetCategoryNumAchievements(categoryID);

    return numCompleted, numCompleted, 0;
end

function AchievementFrame_GetCategoryNumAchievements_Incomplete (categoryID)
    local numAchievements, numCompleted = GetCategoryNumAchievements(categoryID);

    return numAchievements - numCompleted, 0, numCompleted
end