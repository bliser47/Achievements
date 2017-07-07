-- [[ StatsFrames ]]--

function AchievementFrameStats_OnEvent (self, event, params)
    if ( event == "CRITERIA_UPDATE" and self:IsShown() ) then
        AchievementFrameStats_Update();
    end
end

function AchievementFrameStats_OnLoad (self)
    AchievementFrameStatsContainerScrollBar.Show =
    function (self)
        AchievementFrameStats:SetWidth(504);
        for _, button in next, AchievementFrameStats.buttons do
            button:SetWidth(496);
        end
        getmetatable(self).__index.Show(self);
    end

    AchievementFrameStatsContainerScrollBar.Hide =
    function (self)
        AchievementFrameStats:SetWidth(530);
        for _, button in next, AchievementFrameStats.buttons do
            button:SetWidth(522);
        end
        getmetatable(self).__index.Hide(self);
    end

    self:RegisterEvent("CRITERIA_UPDATE");
    AchievementFrameStatsContainerScrollBarBG:Show();
    AchievementFrameStatsContainer.update = AchievementFrameStats_Update;
    HybridScrollFrame_CreateButtons(AchievementFrameStatsContainer, "StatTemplate");
end

local displayStatCategories = {};

function AchievementFrameStats_Update ()
    local category = achievementFunctions.selectedCategory;
    local scrollFrame = AchievementFrameStatsContainer;
    local offset = HybridScrollFrame_GetOffset(scrollFrame);
    local buttons = scrollFrame.buttons;
    local numButtons = table.getn(buttons);
    local statHeight = 24;

    local numStats, numCompleted = GetCategoryNumAchievements(category);

    local categories = ACHIEVEMENTUI_CATEGORIES;
    -- clear out table
    if ( achievementFunctions.lastCategory ~= category ) then
        local statCat;
        for i in next, displayStatCategories do
            displayStatCategories[i] = nil;
        end
        -- build a list of shown category and stat id's

        tinsert(displayStatCategories, {id = category, header = true});
        for i=1, numStats do
            tinsert(displayStatCategories, {id = GetAchievementInfo(category, i)});
        end
        -- add all the subcategories and their stat id's
        for i, cat in next, categories do
            if ( cat.parent == category ) then
                tinsert(displayStatCategories, {id = cat.id, header = true});
                numStats = GetCategoryNumAchievements(cat.id);
                for k=1, numStats do
                    tinsert(displayStatCategories, {id = GetAchievementInfo(cat.id, k)});
                end
            end
        end
        achievementFunctions.lastCategory = category;
    end

    -- iterate through the displayStatCategories and display them
    local selection = AchievementFrameStats.selection;
    local statCount = table.getn(displayStatCategories);
    local statIndex, id, button;
    local stat;

    local totalHeight = statCount * statHeight;
    local displayedHeight = numButtons * statHeight;
    for i = 1, numButtons do
        button = buttons[i];
        statIndex = offset + i;
        if ( statIndex <= statCount ) then
            stat = displayStatCategories[statIndex];
            if ( stat.header ) then
                AchievementFrameStats_SetHeader(button, stat.id);
            else
                AchievementFrameStats_SetStat(button, stat.id, nil, statIndex);
            end
            button:Show();
        else
            button:Hide();
        end
    end
    HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight);
end

function AchievementFrameStats_SetStat(button, category, index, colorIndex, isSummary)
    --Remove these variables when we know for sure we don't need them
    local id, name, points, completed, month, day, year, description, flags, icon;
    if ( not isSummary ) then
        if ( not index ) then
            id, name, points, completed, month, day, year, description, flags, icon = GetAchievementInfo(category);
        else
            id, name, points, completed, month, day, year, description, flags, icon = GetAchievementInfo(category, index);
        end

    else
        -- This is on the summary page
        id, name, points, completed, month, day, year, description, flags, icon = GetAchievementInfoFromCriteria(category);
    end

    button.id = id;

    if ( not colorIndex ) then
        if ( not index ) then
            message("Error, need a color index or index");
        end
        colorIndex = index;
    end
    button:SetText(name);
    button.background:Show();
    -- Color every other line yellow
    if ( mod(colorIndex, 2) == 1 ) then
        button.background:SetTexCoord(0, 1, 0.1875, 0.3671875);
        button.background:SetBlendMode("BLEND");
        button.background:SetAlpha(1.0);
        button:SetHeight(24);
    else
        button.background:SetTexCoord(0, 1, 0.375, 0.5390625);
        button.background:SetBlendMode("ADD");
        button.background:SetAlpha(0.5);
        button:SetHeight(24);
    end

    -- Figure out the criteria
    local numCriteria = GetAchievementNumCriteria(id);
    if ( numCriteria == 0 ) then
        -- This is no good!
    end
    -- Just show the first criteria for now
    local criteriaString, criteriaType, completed, quantityNumber, reqQuantity, charName, flags, assetID, quantity;
    if ( not isSummary ) then
        quantity = GetStatistic(id);
    else
        criteriaString, criteriaType, completed, quantityNumber, reqQuantity, charName, flags, assetID, quantity = GetAchievementCriteriaInfo(category);
    end
    if ( not quantity ) then
        quantity = "--";
    end
    button.value:SetText(quantity);

    -- Hide the header images
    button.title:Hide();
    button.left:Hide();
    button.middle:Hide();
    button.right:Hide();
    button.isHeader = false;
end

function AchievementFrameStats_SetHeader(button, id)
    -- show header
    button.left:Show();
    button.middle:Show();
    button.right:Show();
    local text;
    if ( id == ACHIEVEMENT_COMPARISON_STATS_SUMMARY_ID ) then
        text = ACHIEVEMENT_SUMMARY_CATEGORY;
    else
        text = GetCategoryInfo(id);
    end
    button.title:SetText(text);
    button.title:Show();
    button.value:SetText("");
    button:SetText("");
    button:SetHeight(24);
    button.background:Hide();
    button.isHeader = true;
    button.id = id;
end

function AchievementStatButton_OnLoad(self, parentFrame)
    local name = self:GetName();
    self.background = _G[name.."BG"];
    self.left = _G[name.."HeaderLeft"];
    self.middle = _G[name.."HeaderMiddle"];
    self.right = _G[name.."HeaderRight"];
    self.text = _G[name.."Text"];
    self.title = _G[name.."Title"];
    self.value = _G[name.."Value"];
    self.value:SetVertexColor(1, 0.97, 0.6);
    parentFrame.buttons = parentFrame.buttons or {};
    tinsert(parentFrame.buttons, self);
end

function AchievementStatButton_OnClick(self)
    if ( self.isHeader ) then
        achievementFunctions.selectedCategory = self.id;
        AchievementFrameCategories_Update();
        AchievementFrameStats_Update();
    elseif ( self.summary ) then
        AchievementFrame_SelectSummaryStatistic(self.id);
    end
end
