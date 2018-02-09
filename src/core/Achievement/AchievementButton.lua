-- [[ AchievementButton ]] --

ACHIEVEMENTBUTTON_DESCRIPTIONHEIGHT = 20;
ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT = 84;
ACHIEVEMENTBUTTON_CRITERIAROWHEIGHT = 15;
ACHIEVEMENTBUTTON_METAROWHEIGHT = 14;
ACHIEVEMENTBUTTON_MAXHEIGHT = 232;
ACHIEVEMENTBUTTON_TEXTUREHEIGHT = 128;

function AchievementButton_UpdatePlusMinusTexture (button)
    local id = button.id;
    if ( not id ) then
        return; -- This happens when we create buttons
    end

    local display = false;
    if ( GetAchievementNumCriteria(id) ~= 0 ) then
        display = true;
    elseif ( GetPreviousAchievement(id) and button.completed ) then
        display = true;
    end

    if ( display ) then
        button.plusMinus:Show();
        if ( button.collapsed and button.saturated ) then
            button.plusMinus:SetTexCoord(0, .5, 0, .5);
        elseif ( button.collapsed ) then
            button.plusMinus:SetTexCoord(.5, 1, 0, .5);
        elseif ( button.saturated ) then
            button.plusMinus:SetTexCoord(0, .5, .5, 1);
        else
            button.plusMinus:SetTexCoord(.5, 1, .5, 1);
        end
    else
        button.plusMinus:Hide();
    end
end

function AchievementButton_Collapse (self)
    if ( self.collapsed ) then
        return;
    end

    self.collapsed = true;
    AchievementButton_UpdatePlusMinusTexture(self);
    self:SetHeight(ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT);
    getglobal(self:GetName() .. "Background"):SetTexCoord(0, 1, 1-(ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT / 256), 1);
    getglobal(self:GetName() .. "Glow"):SetTexCoord(0, 1, 0, ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT / 128);

    --[[ TODO: Support tracking
    if ( not self.tracked:GetChecked() ) then
        self.tracked:Hide();
    end
    ]]--
end

function AchievementButton_Expand (self, height)
    if ( not self.collapsed ) then
        return;
    end

    self.collapsed = nil;
    AchievementButton_UpdatePlusMinusTexture(self);
    self:SetHeight(height);
    getglobal(self:GetName() .. "Background"):SetTexCoord(0, 1, max(0, 1-(height / 256)), 1);
    getglobal(self:GetName() .. "Glow"):SetTexCoord(0, 1, 0, (height+5) / 128);
end

function AchievementButton_Saturate (self)
    local name = self:GetName();
    self.saturated = true;
    getglobal(name .. "TitleBackground"):SetTexCoord(0, 0.9765625, 0, 0.3125);
    getglobal(name .. "Background"):SetTexture("Interface\\AddOns\\Achievements\\src\\wotlk\\Textures\\UI-Achievement-Parchment-Horizontal");
    getglobal(name .. "Glow"):SetVertexColor(1.0, 1.0, 1.0);
    self.icon:Saturate();
    self.shield:Saturate();
    self.shield.points:SetVertexColor(1, 1, 1);
    self.reward:SetVertexColor(1, .82, 0);
    self.label:SetVertexColor(1, 1, 1);
    self.description:SetTextColor(0, 0, 0, 1);
    self.description:SetShadowOffset(0, 0);
    AchievementButton_UpdatePlusMinusTexture(self);
    self:SetBackdropBorderColor(ACHIEVEMENTUI_REDBORDER_R, ACHIEVEMENTUI_REDBORDER_G, ACHIEVEMENTUI_REDBORDER_B, ACHIEVEMENTUI_REDBORDER_A);
end

function AchievementButton_Desaturate (self)
    local name = self:GetName();
    self.saturated = nil;
    getglobal(name .. "TitleBackground"):SetTexCoord(0, 0.9765625, 0.34375, 0.65625);
    getglobal(name .. "Background"):SetTexture("Interface\\AddOns\\Achievements\\src\\wotlk\\Textures\\UI-Achievement-Parchment-Horizontal-Desaturated");
    getglobal(name .. "Glow"):SetVertexColor(.22, .17, .13);
    self.icon:Desaturate();
    self.shield:Desaturate();
    self.shield.points:SetVertexColor(.65, .65, .65);
    self.reward:SetVertexColor(.8, .8, .8);
    self.label:SetVertexColor(.65, .65, .65);
    self.description:SetTextColor(1, 1, 1, 1);
    self.description:SetShadowOffset(1, -1);
    AchievementButton_UpdatePlusMinusTexture(self);
    self:SetBackdropBorderColor(.5, .5, .5);
end

function AchievementButton_OnLoad (self)
    local name = self:GetName();
    self.label = getglobal(name .. "Label");
    self.description = getglobal(name .. "Description");
    self.hiddenDescription = getglobal(name .. "HiddenDescription");
    self.reward = getglobal(name .. "Reward");
    self.rewardBackground = getglobal(name.."RewardBackground");
    self.icon = getglobal(name .. "Icon");
    self.shield = getglobal(name .. "Shield");
    self.objectives = getglobal(name .. "Objectives");
    self.highlight = getglobal(name .. "Highlight");
    self.dateCompleted = getglobal(name .. "DateCompleted");
    self.tracked = getglobal(name .. "Tracked");
    self.check = getglobal(name .. "Check");
    self.plusMinus = getglobal(name .. "PlusMinus");

    self.dateCompleted:ClearAllPoints();
    self.dateCompleted:SetPoint("TOP", self.shield, "BOTTOM", -3, 6);
    if ( not ACHIEVEMENTUI_FONTHEIGHT ) then
        local _, fontHeight = self.description:GetFont();
        ACHIEVEMENTUI_FONTHEIGHT = fontHeight;
    end
    self.description:SetHeight(ACHIEVEMENTUI_FONTHEIGHT * ACHIEVEMENTUI_MAX_LINES_COLLAPSED);
    self.description:SetWidth(ACHIEVEMENTUI_MAXCONTENTWIDTH);
    self.hiddenDescription:SetWidth(ACHIEVEMENTUI_MAXCONTENTWIDTH);

    self:SetBackdropBorderColor(ACHIEVEMENTUI_REDBORDER_R, ACHIEVEMENTUI_REDBORDER_G, ACHIEVEMENTUI_REDBORDER_B, ACHIEVEMENTUI_REDBORDER_A);
    self.Collapse = AchievementButton_Collapse;
    self.Expand = AchievementButton_Expand;
    self.Saturate = AchievementButton_Saturate;
    self.Desaturate = AchievementButton_Desaturate;

    self:Collapse();
    self:Desaturate();

    AchievementFrameAchievements.buttons = AchievementFrameAchievements.buttons or {};
    tinsert(AchievementFrameAchievements.buttons, self);
end

function AchievementButton_OnClick (self, ignoreModifiers)

    -- Modified blizzard code here so that it supports both Vanilla & TBC
    -- TODO: Needs proper coding
    --[[
    local keyDown = false;
    if IsAutoLootKeyDown then
        keyDown = IsAutoLootKeyDown();
    elseif  IsAutoLootKeyDown then
        keyDown = IsAutoLootKeyDown();
    else
        keyDown = IsModifiedClick();
    end


    if(keyDown and not ignoreModifiers) then
        if ( IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow() ) then
            local achievementLink = GetAchievementLink(self.id);
            if ( achievementLink ) then
                ChatEdit_InsertLink(achievementLink);
            end
        elseif ( IsModifiedClick("QUESTWATCHTOGGLE") ) then
            AchievementButton_ToggleTracking(self.id);
        end

        return;
    end
    ]]--

    if ( self.selected ) then
        --[[ TODO: Support IsMouseOver
        if ( not self:IsMouseOver() ) then
            self.highlight:Hide();
        end
        ]]--
        AchievementFrameAchievements_ClearSelection()
        HybridScrollFrame_CollapseButton(AchievementFrameAchievementsContainer);
        AchievementFrameAchievements_Update();
        return;
    end
    AchievementFrameAchievements_ClearSelection()
    AchievementFrameAchievements_SelectButton(self);
    AchievementButton_DisplayAchievement(self, achievementFunctions.selectedCategory, self.index, self.id);
    HybridScrollFrame_ExpandButton(AchievementFrameAchievementsContainer, ((self.index - 1) * ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT), self:GetHeight());
    AchievementFrameAchievements_Update();
    if ( not ignoreModifiers ) then
        AchievementFrameAchievements_AdjustSelection();
    end
end

function AchievementButton_ToggleTracking (id)
    if ( ACHIEVEMENT_TRACKED_ACHIEVEMENTS[id] ) then
        RemoveTrackedAchievement(id);
        AchievementFrameAchievements_ForceUpdate();
        WatchFrame_Update();
        return;
    end

    local count = GetNumTrackedAchievements();

    if ( count >= WATCHFRAME_MAXACHIEVEMENTS ) then
        UIErrorsFrame:AddMessage(format(ACHIEVEMENT_WATCH_TOO_MANY, WATCHFRAME_MAXACHIEVEMENTS), 1.0, 0.1, 0.1, 1.0);
        return;
    end

    local _, _, _, completed = GetAchievementInfo(id)
    if ( completed ) then
        UIErrorsFrame:AddMessage(ERR_ACHIEVEMENT_WATCH_COMPLETED, 1.0, 0.1, 0.1, 1.0);
        return;
    end

    AddTrackedAchievement(id);
    AchievementFrameAchievements_ForceUpdate();
    WatchFrame_Update();

    return true;
end

function AchievementButton_DisplayAchievement (button, category, achievement, selectionID)
    local id, name, points, completed, month, day, year, description, flags, icon, rewardText = GetAchievementInfo(category, achievement);
    if ( not id ) then
        button:Hide();
        return;
    else
        button:Show();
    end

    button.index = achievement;
    button.element = true;

    if ( button.id ~= id ) then
        button.id = id;
        button.label:SetWidth(ACHIEVEMENTBUTTON_LABELWIDTH);
        button.label:SetText(name)

        if ( GetPreviousAchievement(id) ) then
            -- If this is a progressive achievement, show the total score.
            AchievementShield_SetPoints(AchievementButton_GetProgressivePoints(id), button.shield.points, GameFontNormal, GameFontNormalSmall);
        else
            AchievementShield_SetPoints(points, button.shield.points, GameFontNormal, GameFontNormalSmall);
        end

        if ( points > 0 ) then
            button.shield.icon:SetTexture([[Interface\Addons\Achievements\Textures\UI-Achievement-Shields]]);
        else
            button.shield.icon:SetTexture([[Interface\Addons\Achievements\Textures\UI-Achievement-Shields-NoPoints]]);
        end
        button.description:SetText(description);
        button.hiddenDescription:SetText(description);
        button.numLines = ceil(button.hiddenDescription:GetHeight() / ACHIEVEMENTUI_FONTHEIGHT);
        button.icon.texture:SetTexture(icon);
        if ( completed and not button.completed ) then
            button.completed = true;
            button.dateCompleted:SetText(string.format(SHORTDATE, day, month, year));
            button.dateCompleted:Show();
            button:Saturate();
        elseif ( completed ) then
            button.dateCompleted:SetText(string.format(SHORTDATE, day, month, year));
        else
            button.completed = nil;
            button.dateCompleted:Hide();
            button:Desaturate();
        end

        if ( rewardText == "" ) then
            button.reward:Hide();
            button.rewardBackground:Hide();
        else
            button.reward:SetText(rewardText);
            button.reward:Show();
            button.rewardBackground:Show();
            if ( button.completed ) then
                button.rewardBackground:SetVertexColor(1, 1, 1);
            else
                button.rewardBackground:SetVertexColor(0.35, 0.35, 0.35);
            end
        end

        --[[ TODO: Support tracking
        if ( IsTrackedAchievement(id) ) then
            button.check:Show();
            button.label:SetWidth(button.label:GetStringWidth() + 4); -- This +4 here is to fudge around any string width issues that arize from resizing a string set to its string width. See bug 144418 for an example.
            button.tracked:SetChecked(true);
            button.tracked:Show();
        else
            button.check:Hide();
            button.tracked:SetChecked(false);
            button.tracked:Hide();
        end
        ]]--

        AchievementButton_UpdatePlusMinusTexture(button);
    end

    if ( id == selectionID ) then
        local achievements = AchievementFrameAchievements;

        achievements.selection = button.id;
        achievements.selectionIndex = button.index;
        button.selected = true;
        button.highlight:Show();
        local height = AchievementButton_DisplayObjectives(button, button.id, button.completed);
        if ( height == ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT ) then
            button:Collapse();
        else
            button:Expand(height);
        end
        --[[ TODO: Support tracking
        if ( not completed ) then
            button.tracked:Show();
        end
        ]]--
    elseif ( button.selected ) then
        button.selected = nil;
        if ( not button:IsMouseOver() ) then
            button.highlight:Hide();
        end
        button:Collapse();
        button.description:Show();
        button.hiddenDescription:Hide();
    end

    return id;
end

function AchievementFrameAchievements_SelectButton (button)
    local achievements = AchievementFrameAchievements;

    achievements.selection = button.id;
    achievements.selectionIndex = button.index;
    button.selected = true;
end

function AchievementButton_ResetObjectives ()
    AchievementFrameAchievementsObjectives:Hide();
end

function AchievementButton_DisplayObjectives (button, id, completed)
    local objectives = AchievementFrameAchievementsObjectives;

    objectives:ClearAllPoints();
    objectives:SetParent(button);
    objectives:Show();
    objectives.completed = completed;
    local height = 0;
    if ( objectives.id == id ) then
        local ACHIEVEMENTMODE_CRITERIA = 1;
        if ( objectives.mode == ACHIEVEMENTMODE_CRITERIA ) then
            if ( objectives:GetHeight() > 0 ) then
                objectives:SetPoint("TOP", "$parentHiddenDescription", "BOTTOM", 0, -8);
                objectives:SetPoint("LEFT", "$parentIcon", "RIGHT", -5, 0);
                objectives:SetPoint("RIGHT", "$parentShield", "LEFT", -10, 0);
            end
            height = ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT + objectives:GetHeight();
        else
            objectives:SetPoint("TOP", "$parentHiddenDescription", "BOTTOM", 0, -8);
            height = ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT + objectives:GetHeight();
        end
    elseif ( completed and GetPreviousAchievement(id) ) then
        objectives:SetHeight(0);
        AchievementButton_ResetCriteria();
        AchievementButton_ResetProgressBars();
        AchievementButton_ResetMiniAchievements();
        AchievementButton_ResetMetas();
        AchievementObjectives_DisplayProgressiveAchievement(objectives, id);
        objectives:SetPoint("TOP", "$parentHiddenDescription", "BOTTOM", 0, -8);
        height = ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT + objectives:GetHeight();
    else
        objectives:SetHeight(0);
        AchievementButton_ResetCriteria();
        AchievementButton_ResetProgressBars();
        AchievementButton_ResetMiniAchievements();
        AchievementButton_ResetMetas();
        AchievementObjectives_DisplayCriteria(objectives, id);
        if ( objectives:GetHeight() > 0 ) then
            objectives:SetPoint("TOP", "$parentHiddenDescription", "BOTTOM", 0, -8);
            objectives:SetPoint("LEFT", "$parentIcon", "RIGHT", -5, -25);
            objectives:SetPoint("RIGHT", "$parentShield", "LEFT", -10, 0);
        end
        height = ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT + objectives:GetHeight();
    end

    if ( height ~= ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT or button.numLines > ACHIEVEMENTUI_MAX_LINES_COLLAPSED ) then
        button.hiddenDescription:Show();
        button.description:Hide();
        local descriptionHeight = button.hiddenDescription:GetHeight();
        height = height + descriptionHeight - ACHIEVEMENTBUTTON_DESCRIPTIONHEIGHT;
        if ( button.reward:IsShown() ) then
            height = height + 4;
        end
    end

    objectives.id = id;
    return height;
end

function AchievementShield_SetPoints(points, pointString, normalFont, smallFont)
    if ( points == 0 ) then
        pointString:SetText("");
        return;
    end
    if ( points <= 100 ) then
        pointString:SetFontObject(normalFont);
    else
        pointString:SetFontObject(smallFont);
    end
    pointString:SetText(points);
end

function AchievementButton_ResetTable (t)
    for k, v in next, t do
        v:Hide();
    end
end


function AchievementButton_ResetCriteria ()
    AchievementButton_ResetTable(ACHIEVEMENT_CRITERIA_TABLE);
end

function AchievementButton_GetCriteria (index)
    if ( ACHIEVEMENT_CRITERIA_TABLE[index] ) then
        return ACHIEVEMENT_CRITERIA_TABLE[index];
    end

    local frame = CreateFrame("FRAME", "AchievementFrameCriteria" .. index, AchievementFrameAchievements, "AchievementCriteriaTemplate");
    AchievementFrame_LocalizeCriteria(frame);
    ACHIEVEMENT_CRITERIA_TABLE[index] = frame;

    return frame;
end

function AchievementButton_ResetMiniAchievements ()
    AchievementButton_ResetTable(ACHIEVEMENT_MINI_TABLE);
end

function AchievementButton_GetMiniAchievement (index)
    if ( ACHIEVEMENT_MINI_TABLE[index] ) then
        return ACHIEVEMENT_MINI_TABLE[index];
    end

    local frame = CreateFrame("FRAME", "AchievementFrameMiniAchievement" .. index, AchievementFrameAchievements, "MiniAchievementTemplate");
    AchievementButton_LocalizeMiniAchievement(frame);
    ACHIEVEMENT_MINI_TABLE[index] = frame;

    return frame;
end


function AchievementButton_ResetProgressBars ()
    AchievementButton_ResetTable(ACHIEVEMENT_PROGRESS_BAR_TABLE);
end

function AchievementButton_GetProgressBar (index)
    if ( ACHIEVEMENT_PROGRESS_BAR_TABLE[index] ) then
        return ACHIEVEMENT_PROGRESS_BAR_TABLE[index];
    end

    local frame = CreateFrame("STATUSBAR", "AchievementFrameProgressBar" .. index, AchievementFrameAchievements, "AchievementProgressBarTemplate");
    AchievementButton_LocalizeProgressBar(frame);
    ACHIEVEMENT_PROGRESS_BAR_TABLE[index] = frame;

    return frame;
end

function AchievementButton_ResetMetas ()
    AchievementButton_ResetTable(ACHIEVEMENT_META_CRITERIA_TABLE);
end

function AchievementButton_GetMeta (index)
    if ( ACHIEVEMENT_META_CRITERIA_TABLE[index] ) then
        return ACHIEVEMENT_META_CRITERIA_TABLE[index];
    end

    local frame = CreateFrame("BUTTON", "AchievementFrameMeta" .. index, AchievementFrameAchievements, "MetaCriteriaTemplate");
    AchievementButton_LocalizeMetaAchievement(frame);
    ACHIEVEMENT_META_CRITERIA_TABLE[index] = frame;

    return frame;
end

function AchievementButton_GetProgressivePoints(achievementID)
    local points;
    local _, _, progressivePoints, completed = GetAchievementInfo(achievementID);

    while GetPreviousAchievement(achievementID) do
        achievementID = GetPreviousAchievement(achievementID);
        _, _, points, completed = GetAchievementInfo(achievementID);
        progressivePoints = progressivePoints+points;
    end

    if ( progressivePoints ) then
        return progressivePoints;
    else
        return 0;
    end
end