-- [[ AchievementFrameCategories ]] --

function AchievementFrameCategories_OnLoad (self)
    self:SetBackdropBorderColor(ACHIEVEMENTUI_GOLDBORDER_R, ACHIEVEMENTUI_GOLDBORDER_G, ACHIEVEMENTUI_GOLDBORDER_B, ACHIEVEMENTUI_GOLDBORDER_A);
    self.buttons = {};
    self:RegisterEvent("ADDON_LOADED");
    -- TODO: This might be wrong, added this to XML
    --self:SetScript("OnEvent", AchievementFrameCategories_OnEvent);
end

function AchievementFrameCategories_OnEvent (self, event, params)


    if ( event == "ADDON_LOADED" ) then
        local addonName = params;


        if ( addonName and addonName ~= "Achievements" ) then
            return;
        end


        AchievementFrameCategories_GetCategoryList(ACHIEVEMENTUI_CATEGORIES);

        AchievementFrameCategoriesContainerScrollBar.OldShow = AchievementFrameCategoriesContainerScrollBar.Show;
        AchievementFrameCategoriesContainerScrollBar.Show = function (self)
            ACHIEVEMENTUI_CATEGORIESWIDTH = 175;
            AchievementFrameCategories:SetWidth(175);
            AchievementFrameCategoriesContainer:GetScrollChild():SetWidth(175);
            AchievementFrameAchievements:SetPoint("TOPLEFT", "$parentCategories", "TOPRIGHT", 22, 0);
            AchievementFrameStats:SetPoint("TOPLEFT", "$parentCategories", "TOPRIGHT", 22, 0);
            AchievementFrameComparison:SetPoint("TOPLEFT", "$parentCategories", "TOPRIGHT", 22, 0)
            AchievementFrameWaterMark:SetWidth(145);
            AchievementFrameWaterMark:SetTexCoord(0, 145/256, 0, 1);
            for _, button in next, AchievementFrameCategoriesContainer.buttons do
                AchievementFrameCategories_DisplayButton(button, button.element)
            end
            self:OldShow();
        end

        AchievementFrameCategoriesContainerScrollBar.OldHide = AchievementFrameCategoriesContainerScrollBar.Hide;
        AchievementFrameCategoriesContainerScrollBar.Hide =
        function (self)
            ACHIEVEMENTUI_CATEGORIESWIDTH = 197;
            AchievementFrameCategories:SetWidth(197);
            AchievementFrameCategoriesContainer:GetScrollChild():SetWidth(197);
            AchievementFrameAchievements:SetPoint("TOPLEFT", "$parentCategories", "TOPRIGHT", 0, 0);
            --AchievementFrameStats:SetPoint("TOPLEFT", "$parentCategories", "TOPRIGHT", 0, 0);
            --AchievementFrameComparison:SetPoint("TOPLEFT", "$parentCategories", "TOPRIGHT", 0, 0)
            AchievementFrameWaterMark:SetWidth(167);
            AchievementFrameWaterMark:SetTexCoord(0, 167/256, 0, 1);
            for _, button in next, AchievementFrameCategoriesContainer.buttons do
                AchievementFrameCategories_DisplayButton(button, button.element);
            end
            self:OldHide();
        end

        AchievementFrameCategoriesContainerScrollBarBG:Show();
        AchievementFrameCategoriesContainer.update = AchievementFrameCategories_Update;
        HybridScrollFrame_CreateButtons(AchievementFrameCategoriesContainer, "AchievementCategoryTemplate", 0, -5, "TOP", "TOP", 0, 0, "TOP", "BOTTOM");
        AchievementFrameCategories_Update();
        self:UnregisterEvent(event)
    end
end

function AchievementFrameCategories_OnShow (self)
    AchievementFrameCategories_Update();
end

function AchievementFrameCategories_GetCategoryList (categories)
    local cats = achievementFunctions.categoryAccessor();

    for i in next, categories do
        categories[i] = nil;
    end
    -- Insert the fake Summary category
    tinsert(categories, { ["id"] = "summary" });


    -- Add the top level categories
    for i, id in next, cats do
        local _, parent = GetCategoryInfo(id);
        if ( parent == -1 ) then
            tinsert(categories, { ["id"] = id });
        end
    end

    local _, parent;
    for i = table.getn(cats), 1, -1 do
        _, parent = GetCategoryInfo(cats[i]);
        for j, category in next, categories do
            if ( category.id == parent ) then
                category.parent = true;
                category.collapsed = true;
                tinsert(categories, j+1, { ["id"] = cats[i], ["parent"] = category.id, ["hidden"] = true});
            end
        end
    end
end

local displayCategories = {};
function AchievementFrameCategories_Update ()
    local scrollFrame = AchievementFrameCategoriesContainer;

    local categories = ACHIEVEMENTUI_CATEGORIES;
    local offset = HybridScrollFrame_GetOffset(scrollFrame);


    local buttons = scrollFrame.buttons;

    local displayCategories = displayCategories;

    for i in next, displayCategories do
        displayCategories[i] = nil;
    end

    displayCategories = {};

    local selection = achievementFunctions.selectedCategory;
    if ( selection == ACHIEVEMENT_COMPARISON_SUMMARY_ID or selection == ACHIEVEMENT_COMPARISON_STATS_SUMMARY_ID ) then
        selection = "summary";
    end

    local parent;
    if ( selection ) then
        for i, category in next, categories do
            if ( category.id == selection ) then
                parent = category.parent;
            end
        end
    end

    for i, category in next, categories do
        if ( not category.hidden ) then
            tinsert(displayCategories, category);
        elseif ( parent and category.id == parent ) then
            category.collapsed = false;
            tinsert(displayCategories, category);
        elseif ( parent and category.parent and category.parent == parent ) then
            category.hidden = false;
            tinsert(displayCategories, category);
        end
    end


    local numCategories = table.getn(displayCategories);
    local numButtons = 0;
    if buttons ~= nill then
        numButtons = table.getn(buttons);
    end


    local totalHeight = numCategories * buttons[1]:GetHeight();
    local displayedHeight = 0;


    local element
    for i = 1, numButtons do
        element = displayCategories[i + offset];
        displayedHeight = displayedHeight + buttons[i]:GetHeight();
        if ( element ) then
            AchievementFrameCategories_DisplayButton(buttons[i], element);
            if ( selection and element.id == selection ) then
                buttons[i]:LockHighlight();
            else
                buttons[i]:UnlockHighlight();
            end
            buttons[i]:Show();
        else
            buttons[i].element = nil;
            buttons[i]:Hide();
        end
    end


    HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight);

    return displayCategories;

end

function AchievementFrameCategories_DisplayButton (button, element)
    if ( not element ) then
        button.element = nil;
        button:Hide();
        return;
    end

    button:Show();
    if ( type(element.parent) == "number" ) then
        button:SetWidth(ACHIEVEMENTUI_CATEGORIESWIDTH - 25);
        button.label:SetFontObject("GameFontHighlight");
        button.parentID = element.parent;
        button.background:SetVertexColor(0.6, 0.6, 0.6);
    else
        button:SetWidth(ACHIEVEMENTUI_CATEGORIESWIDTH - 10);
        button.label:SetFontObject("GameFontNormal");
        button.parentID = element.parent;
        button.background:SetVertexColor(1, 1, 1);
    end

    local categoryName, parentID, flags;
    local numAchievements, numCompleted;

    local id = element.id;

    -- kind of janky
    if ( id == "summary" ) then
        categoryName = ACHIEVEMENT_SUMMARY_CATEGORY;
        numAchievements, numCompleted = GetNumCompletedAchievements();
    else
        categoryName, parentID, flags = GetCategoryInfo(id);
        numAchievements, numCompleted = AchievementFrame_GetCategoryTotalNumAchievements(id, true);
    end
    button.label:SetText(categoryName);
    button.categoryID = id;
    button.flags = flags;
    button.element = element;

    -- For the tooltip
    button.name = categoryName;
    if ( id == FEAT_OF_STRENGTH_ID ) then
        -- This is the feat of strength category since it's sorted to the end of the list
        button.text = FEAT_OF_STRENGTH_DESCRIPTION;
        button.showTooltipFunc = AchievementFrameCategory_FeatOfStrengthTooltip;
    elseif ( AchievementFrame.selectedTab == 1 ) then
        button.text = nil;
        button.numAchievements = numAchievements;
        button.numCompleted = numCompleted;
        button.numCompletedText = numCompleted.."/"..numAchievements;
        button.showTooltipFunc = AchievementFrameCategory_StatusBarTooltip;
    else
        button.showTooltipFunc = nil;
    end
end

function AchievementFrameCategory_StatusBarTooltip(self)
    GameTooltip_SetDefaultAnchor(GameTooltip, self);
    GameTooltip:SetMinimumWidth(128, 1);
    GameTooltip:SetText(self.name, 1, 1, 1, nil, 1);
    GameTooltip_ShowStatusBar(GameTooltip, 0, self.numAchievements, self.numCompleted, self.numCompletedText);
    GameTooltip:Show();
end

function AchievementFrameCategory_FeatOfStrengthTooltip(self)
    GameTooltip_SetDefaultAnchor(GameTooltip, self);
    GameTooltip:SetText(self.name, 1, 1, 1);
    GameTooltip:AddLine(self.text, nil, nil, nil, 1);
    GameTooltip:Show();
end

function AchievementFrameCategories_UpdateTooltip()
    local container = AchievementFrameCategoriesContainer;
    if ( not container:IsVisible() or not container.buttons ) then
        return;
    end

    for _, button in next, AchievementFrameCategoriesContainer.buttons do
        if ( button:IsMouseOver() and button.showTooltipFunc ) then
            button:showTooltipFunc();
            break;
        end
    end
end

function AchievementFrameCategories_SelectButton (button)
    local id = button.element.id;

    if ( type(button.element.parent) ~= "number" ) then
        -- Is top level category (can expand/contract)
        if ( button.isSelected and button.element.collapsed == false ) then
            button.element.collapsed = true;
            for i, category in next, ACHIEVEMENTUI_CATEGORIES do
                if ( category.parent == id ) then
                    category.hidden = true;
                end
            end
        else
            for i, category in next, ACHIEVEMENTUI_CATEGORIES do
                if ( category.parent == id ) then
                    category.hidden = false;
                elseif ( category.parent == true ) then
                    category.collapsed = true;
                elseif ( category.parent ) then
                    category.hidden = true;
                end
            end
            button.element.collapsed = false;
        end
    end

    local buttons = AchievementFrameCategoriesContainer.buttons;
    for _, button in next, buttons do
        button.isSelected = nil;
    end

    button.isSelected = true;

    if ( id == achievementFunctions.selectedCategory ) then
        -- If this category was selected already, bail after changing collapsed states
        return
    end

    --Intercept "summary" category
    if ( id == "summary" ) then
        if ( achievementFunctions == ACHIEVEMENT_FUNCTIONS ) then
            AchievementFrame_ShowSubFrame(AchievementFrameSummary);
            achievementFunctions.selectedCategory = id;
            return;
        elseif (  achievementFunctions == STAT_FUNCTIONS ) then
            AchievementFrame_ShowSubFrame(AchievementFrameStats);
            achievementFunctions.selectedCategory = ACHIEVEMENT_COMPARISON_STATS_SUMMARY_ID;
            AchievementFrameStatsContainerScrollBar:SetValue(0);
        elseif ( achievementFunctions == COMPARISON_ACHIEVEMENT_FUNCTIONS ) then
            -- Put the summary stuff for comparison here, Derek!
            AchievementFrame_ShowSubFrame(AchievementFrameComparison, AchievementFrameComparisonContainer);
            achievementFunctions.selectedCategory = ACHIEVEMENT_COMPARISON_SUMMARY_ID;
            AchievementFrameComparisonContainerScrollBar:SetValue(0);
            AchievementFrameComparison_UpdateStatusBars(ACHIEVEMENT_COMPARISON_SUMMARY_ID);
        elseif ( achievementFunctions == COMPARISON_STAT_FUNCTIONS ) then
            AchievementFrame_ShowSubFrame(AchievementFrameComparison, AchievementFrameComparisonStatsContainer);
            achievementFunctions.selectedCategory = ACHIEVEMENT_COMPARISON_STATS_SUMMARY_ID;
            AchievementFrameComparisonStatsContainerScrollBar:SetValue(0);
        end

    else
        if ( achievementFunctions == STAT_FUNCTIONS ) then
            AchievementFrame_ShowSubFrame(AchievementFrameStats);
            AchievementFrameStatsContainerScrollBar:SetValue(0);
        elseif ( achievementFunctions == ACHIEVEMENT_FUNCTIONS ) then
            AchievementFrame_ShowSubFrame(AchievementFrameAchievements);
            AchievementFrameAchievementsContainerScrollBar:SetValue(0);
            if ( id == FEAT_OF_STRENGTH_ID ) then
                --AchievementFrameFilterDropDown:Hide();
                AchievementFrameHeaderRightDDLInset:Hide();
            else
                --AchievementFrameFilterDropDown:Show();
                AchievementFrameHeaderRightDDLInset:Show();
            end
        elseif ( achievementFunctions == COMPARISON_ACHIEVEMENT_FUNCTIONS ) then
            AchievementFrame_ShowSubFrame(AchievementFrameComparison, AchievementFrameComparisonContainer);
            AchievementFrameComparisonContainerScrollBar:SetValue(0);
            AchievementFrameComparison_UpdateStatusBars(id);
        else
            AchievementFrame_ShowSubFrame(AchievementFrameComparison, AchievementFrameComparisonStatsContainer);
            AchievementFrameComparisonStatsContainerScrollBar:SetValue(0);
        end
        achievementFunctions.selectedCategory = id;
    end

    if ( achievementFunctions.clearFunc ) then
        achievementFunctions.clearFunc();
    end

    achievementFunctions.updateFunc();
end

function AchievementFrameAchievements_OnShow()
    if ( achievementFunctions.selectedCategory == FEAT_OF_STRENGTH_ID ) then
        --AchievementFrameFilterDropDown:Hide();
        AchievementFrameHeaderRightDDLInset:Hide();
    else
        --AchievementFrameFilterDropDown:Show();
        AchievementFrameHeaderRightDDLInset:Show();
    end
end

function AchievementFrameCategories_ClearSelection ()
    local buttons = AchievementFrameCategoriesContainer.buttons;
    for _, button in next, buttons do
        button.isSelected = nil;
        button:UnlockHighlight();
    end

    for i, category in next, ACHIEVEMENTUI_CATEGORIES do
        if ( category.parent == true ) then
            category.collapsed = true;
        elseif ( category.parent ) then
            category.hidden = true;
        end
    end
end

function AchievementFrameComparison_UpdateStatusBars (id)
    local numAchievements, numCompleted = GetCategoryNumAchievements(id);
    local name = GetCategoryInfo(id);

    if ( id == ACHIEVEMENT_COMPARISON_SUMMARY_ID ) then
        name = ACHIEVEMENT_SUMMARY_CATEGORY;
    end

    local statusBar = AchievementFrameComparisonSummaryPlayerStatusBar;
    statusBar:SetMinMaxValues(0, numAchievements);
    statusBar:SetValue(numCompleted);
    statusBar.title:SetText(string.format(ACHIEVEMENTS_COMPLETED_CATEGORY, name));
    statusBar.text:SetText(numCompleted.."/"..numAchievements);

    local friendCompleted = GetComparisonCategoryNumAchievements(id);

    statusBar = AchievementFrameComparisonSummaryFriendStatusBar;
    statusBar:SetMinMaxValues(0, numAchievements);
    statusBar:SetValue(friendCompleted);
    statusBar.text:SetText(friendCompleted.."/"..numAchievements);
end