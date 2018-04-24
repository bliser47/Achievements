-- [[ AchievementFrameAchievements ]] --

function updateTrackedAchievements (params)
    local count = table.getn(params);
    for i = 1, count do
        ACHIEVEMENT_TRACKED_ACHIEVEMENTS[params[i]] = true;
    end
end


function AchievementFrameAchievements_OnLoad (self)

    local oldAchievementFrameAchievementsContainerScrollBarShow = AchievementFrameAchievementsContainerScrollBar.Show;
    AchievementFrameAchievementsContainerScrollBar.Show = function (self)
        AchievementFrameAchievements:SetWidth(504);
        for _, button in next, AchievementFrameAchievements.buttons do
            button:SetWidth(496);
        end
        oldAchievementFrameAchievementsContainerScrollBarShow(self);
    end

    local oldAchievementFrameAchievementsContainerScrollBar = AchievementFrameAchievementsContainerScrollBar.Hide;
    AchievementFrameAchievementsContainerScrollBar.Hide =
    function (self)
        AchievementFrameAchievements:SetWidth(530);
        for _, button in next, AchievementFrameAchievements.buttons do
            button:SetWidth(522);
        end
        oldAchievementFrameAchievementsContainerScrollBar(self);
    end

    self:RegisterEvent("ADDON_LOADED");
    AchievementFrameAchievementsContainerScrollBarBG:Show();
    AchievementFrameAchievementsContainer.update = AchievementFrameAchievements_Update;
    HybridScrollFrame_CreateButtons(AchievementFrameAchievementsContainer, "AchievementTemplate", 0, -2);
end

function AchievementFrameAchievements_OnEvent (self, event, params)
    if ( event == "ADDON_LOADED" ) then
        self:RegisterEvent("ACHIEVEMENT_EARNED");
        self:RegisterEvent("CRITERIA_UPDATE");
        self:RegisterEvent("TRACKED_ACHIEVEMENT_UPDATE");

        updateTrackedAchievements(GetTrackedAchievements());
    elseif ( event == "ACHIEVEMENT_EARNED" ) then
        local achievementID = params; --TODO
        AchievementFrameCategories_Update();
        AchievementFrameCategories_UpdateTooltip();
        -- This has to happen before AchievementFrameAchievements_ForceUpdate() in order to achieve the behavior we want, since it clears the selection for progressive achievements.
        local selection = AchievementFrameAchievements.selection;
        AchievementFrameAchievements_ForceUpdate();
        if ( AchievementFrameAchievementsContainer:IsShown() and selection == achievementID ) then
            AchievementFrame_SelectAchievement(selection, true);
        end
        AchievementFrameHeaderPoints:SetText(GetTotalAchievementPoints());

    elseif ( event == "CRITERIA_UPDATE" ) then
        if ( AchievementFrameAchievements.selection ) then
            local id = AchievementFrameAchievementsObjectives.id;
            local button = AchievementFrameAchievementsObjectives:GetParent();
            AchievementFrameAchievementsObjectives.id = nil;
            AchievementButton_DisplayObjectives(button, id, button.completed);
            AchievementFrameAchievements_Update();
        else
            AchievementFrameAchievementsObjectives.id = nil; -- Force redraw
        end
    elseif ( event == "TRACKED_ACHIEVEMENT_UPDATE" ) then
        for k, v in next, ACHIEVEMENT_TRACKED_ACHIEVEMENTS do
            ACHIEVEMENT_TRACKED_ACHIEVEMENTS[k] = nil;
        end

        updateTrackedAchievements(GetTrackedAchievements());
    end

    --[[ TODO: Figure out what this is
    if ( not AchievementMicroButton:IsShown() ) then
        AchievementMicroButton_Update();
    end
    --]]
end

function AchievementFrameAchievementsBackdrop_OnLoad (self)
    self:SetBackdropBorderColor(ACHIEVEMENTUI_GOLDBORDER_R, ACHIEVEMENTUI_GOLDBORDER_G, ACHIEVEMENTUI_GOLDBORDER_B, ACHIEVEMENTUI_GOLDBORDER_A);
    self:SetFrameLevel(self:GetFrameLevel()+1);
end

function AchievementFrameAchievements_Update ()
    local category = achievementFunctions.selectedCategory;
    if ( category == "summary" ) then
        return;
    end
    local scrollFrame = AchievementFrameAchievementsContainer;

    local offset = HybridScrollFrame_GetOffset(scrollFrame);
    local buttons = scrollFrame.buttons;
    -- TODO: When filters get added replace the bottom function with ACHIEVEMENTUI_SELECTEDFILTER
    local numAchievements, numCompleted, completedOffset = AchievementFrame_GetCategoryNumAchievements_All(category);

    Achievements.Debug(numAchievements);

    local numButtons = table.getn(buttons);

    -- If the current category is feats of strength and there are no entries then show the explanation text
    if ( AchievementFrame_IsFeatOfStrength() and numAchievements == 0 ) then
        AchievementFrameAchievementsFeatOfStrengthText:Show();
    else
        AchievementFrameAchievementsFeatOfStrengthText:Hide();
    end

    local selection = AchievementFrameAchievements.selection;
    if ( selection ) then
        AchievementButton_ResetObjectives();
    end

    local extraHeight = scrollFrame.largeButtonHeight or ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT

    local achievementIndex;
    local displayedHeight = 0;
    for i = 1, numButtons do
        achievementIndex = i + offset + completedOffset;
        if ( achievementIndex > numAchievements + completedOffset ) then
            buttons[i]:Hide();
        else
            AchievementButton_DisplayAchievement(buttons[i], category, achievementIndex, selection);
            displayedHeight = displayedHeight + buttons[i]:GetHeight();
        end
    end

    local totalHeight = numAchievements * ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT;
    totalHeight = totalHeight + (extraHeight - ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT);

    HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight);

    if ( selection ) then
        AchievementFrameAchievements.selection = selection;
    else
        HybridScrollFrame_CollapseButton(scrollFrame);
    end
end

function AchievementFrameAchievements_ForceUpdate ()
    if ( AchievementFrameAchievements.selection ) then
        local nextID = GetNextAchievement(AchievementFrameAchievements.selection);
        local id, _, _, completed = GetAchievementInfo(AchievementFrameAchievements.selection);
        if ( nextID and completed ) then
            AchievementFrameAchievements.selection = nil;
        end
    end
    AchievementFrameAchievementsObjectives:Hide();
    AchievementFrameAchievementsObjectives.id = nil;

    local buttons = AchievementFrameAchievementsContainer.buttons;
    for i, button in next, buttons do
        button.id = nil;
    end

    AchievementFrameAchievements_Update();
end

function AchievementFrameAchievements_ClearSelection ()
    AchievementButton_ResetObjectives();
    for _, button in next, AchievementFrameAchievements.buttons do
        button:Collapse();
        button.highlight:Hide(); -- Remove when below is implemented
        --[[ TODO: Support mouse over
        if ( not button:IsMouseOver() ) then
            button.highlight:Hide();
        end
        --]]
        button.selected = nil;
        --[[ TODO: Support tracking
        if ( not button.tracked:GetChecked() ) then
            button.tracked:Hide();
        end
        ]]--
        button.description:Show();
        button.hiddenDescription:Hide();
    end

    AchievementFrameAchievements.selection = nil;
end