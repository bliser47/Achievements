function AchievementFrameComparison_OnLoad (self)
    AchievementFrameComparisonContainer_OnLoad(self);
    AchievementFrameComparisonStatsContainer_OnLoad(self);
    self:RegisterEvent("ACHIEVEMENT_EARNED");
    self:RegisterEvent("INSPECT_ACHIEVEMENT_READY");
end

function AchievementFrameComparisonContainer_OnLoad (parent)
    AchievementFrameComparisonContainerScrollBar.Show =
    function (self)
        AchievementFrameComparison:SetWidth(626);
        AchievementFrameComparisonSummaryPlayer:SetWidth(498);
        for _, button in next, AchievementFrameComparisonContainer.buttons do
            button:SetWidth(616);
            button.player:SetWidth(498);
        end
        getmetatable(self).__index.Show(self);
    end

    AchievementFrameComparisonContainerScrollBar.Hide =
    function (self)
        AchievementFrameComparison:SetWidth(650);
        AchievementFrameComparisonSummaryPlayer:SetWidth(522);
        for _, button in next, AchievementFrameComparisonContainer.buttons do
            button:SetWidth(640);
            button.player:SetWidth(522);
        end
        getmetatable(self).__index.Hide(self);
    end

    AchievementFrameComparisonContainerScrollBarBG:Show();
    AchievementFrameComparisonContainer.update = AchievementFrameComparison_Update;
    HybridScrollFrame_CreateButtons(AchievementFrameComparisonContainer, "ComparisonTemplate", 0, -2);
end

function AchievementFrameComparisonStatsContainer_OnLoad (parent)
    AchievementFrameComparisonStatsContainerScrollBar.Show =
    function (self)
        AchievementFrameComparison:SetWidth(626);
        for _, button in next, AchievementFrameComparisonStatsContainer.buttons do
            button:SetWidth(616);
        end
        getmetatable(self).__index.Show(self);
    end

    AchievementFrameComparisonStatsContainerScrollBar.Hide =
    function (self)
        AchievementFrameComparison:SetWidth(650);
        for _, button in next, AchievementFrameComparisonStatsContainer.buttons do
            button:SetWidth(640);
        end
        getmetatable(self).__index.Hide(self);
    end

    AchievementFrameComparisonStatsContainerScrollBarBG:Show();
    AchievementFrameComparisonStatsContainer.update = AchievementFrameComparison_UpdateStats;
    HybridScrollFrame_CreateButtons(AchievementFrameComparisonStatsContainer, "ComparisonStatTemplate", 0, -2);
end

function AchievementFrameComparison_OnShow ()
    AchievementFrameStats:Hide();
    AchievementFrameAchievements:Hide();
    AchievementFrame:SetWidth(890);
    AchievementFrame:SetAttribute("UIPanelLayout-xOffset", 38);
    UpdateUIPanelPositions(AchievementFrame);
    AchievementFrame.isComparison = true;
end

function AchievementFrameComparison_OnHide ()
    AchievementFrame.selectedTab = nil;
    AchievementFrame:SetWidth(768);
    AchievementFrame:SetAttribute("UIPanelLayout-xOffset", 80);
    UpdateUIPanelPositions(AchievementFrame);
    AchievementFrame.isComparison = false;
    ClearAchievementComparisonUnit();
end

function AchievementFrameComparison_OnEvent (self, event, params)
    if ( event == "INSPECT_ACHIEVEMENT_READY" ) then
        AchievementFrameComparisonHeaderPoints:SetText(GetComparisonAchievementPoints());
        AchievementFrameComparison_UpdateStatusBars(achievementFunctions.selectedCategory)
    elseif ( event == "UNIT_PORTRAIT_UPDATE" ) then
        local updateUnit = params; --TODO
        if ( updateUnit and updateUnit == AchievementFrameComparisonHeaderPortrait.unit and UnitName(updateUnit) == AchievementFrameComparisonHeaderName:GetText() ) then
            SetPortraitTexture(AchievementFrameComparisonHeaderPortrait, updateUnit);
        end
    end

    AchievementFrameComparison_ForceUpdate();
end

function AchievementFrameComparison_SetUnit (unit)
    ClearAchievementComparisonUnit();
    SetAchievementComparisonUnit(unit);

    AchievementFrameComparisonHeaderPoints:SetText(GetComparisonAchievementPoints());
    AchievementFrameComparisonHeaderName:SetText(UnitName(unit));
    SetPortraitTexture(AchievementFrameComparisonHeaderPortrait, unit);
    AchievementFrameComparisonHeaderPortrait.unit = unit;
    AchievementFrameComparisonHeaderPortrait.race = UnitRace(unit);
    AchievementFrameComparisonHeaderPortrait.sex = UnitSex(unit);
end

function AchievementFrameComparison_ClearSelection ()
    -- Doesn't do anything WHEE~!
end

function AchievementFrameComparison_ForceUpdate ()
    if ( achievementFunctions == COMPARISON_ACHIEVEMENT_FUNCTIONS ) then
        local buttons = AchievementFrameComparisonContainer.buttons;
        for i, button in next, buttons do
            button.id = nil;
        end

        AchievementFrameComparison_Update();
    elseif ( achievementFunctions == COMPARISON_STAT_FUNCTIONS ) then
        AchievementFrameComparison_UpdateStats();
    end
end

function AchievementFrameComparison_Update ()
    local category = achievementFunctions.selectedCategory;
    if ( not category or category == "summary" ) then
        return;
    end
    local scrollFrame = AchievementFrameComparisonContainer

    local offset = HybridScrollFrame_GetOffset(scrollFrame);
    local buttons = scrollFrame.buttons;
    local numAchievements, numCompleted = GetCategoryNumAchievements(category);
    local numButtons = table.getn(buttons);

    local achievementIndex;
    local buttonHeight = buttons[1]:GetHeight();
    for i = 1, numButtons do
        achievementIndex = i + offset;
        AchievementFrameComparison_DisplayAchievement(buttons[i], category, achievementIndex);
    end

    HybridScrollFrame_Update(scrollFrame, buttonHeight*numAchievements, buttonHeight*numButtons);
end

ACHIEVEMENTCOMPARISON_PLAYERSHIELDFONT1 = GameFontNormal;
ACHIEVEMENTCOMPARISON_PLAYERSHIELDFONT2 = GameFontNormalSmall;
ACHIEVEMENTCOMPARISON_FRIENDSHIELDFONT1 = GameFontNormalSmall;
ACHIEVEMENTCOMPARISON_FRIENDSHIELDFONT2 = GameFontNormalSmall;

function AchievementFrameComparison_DisplayAchievement (button, category, index)
    local id, name, points, completed, month, day, year, description, flags, icon, rewardText = GetAchievementInfo(category, index);
    if ( not id ) then
        button:Hide();
        return;
    else
        button:Show();
    end

    if ( GetPreviousAchievement(id) ) then
        -- If this is a progressive achievement, show the total score.
        points = AchievementButton_GetProgressivePoints(id);
    end

    if ( button.id ~= id ) then
        button.id = id;

        local player = button.player;
        local friend = button.friend;

        local friendCompleted, friendMonth, friendDay, friendYear = GetAchievementComparisonInfo(id);
        player.label:SetText(name);

        player.description:SetText(description);

        player.icon.texture:SetTexture(icon);
        friend.icon.texture:SetTexture(icon);

        if ( points > 0 ) then
            player.shield.icon:SetTexture([[Interface\Addons\Achievements\Textures\UI-Achievement-Shields]]);
            friend.shield.icon:SetTexture([[Interface\Addons\Achievements\Textures\UI-Achievement-Shields]]);
        else
            player.shield.icon:SetTexture([[Interface\Addons\Achievements\Textures\UI-Achievement-Shields-NoPoints]]);
            friend.shield.icon:SetTexture([[Interface\Addons\Achievements\Textures\UI-Achievement-Shields-NoPoints]]);
        end
        AchievementShield_SetPoints(points, player.shield.points, ACHIEVEMENTCOMPARISON_PLAYERSHIELDFONT1, ACHIEVEMENTCOMPARISON_PLAYERSHIELDFONT2);
        AchievementShield_SetPoints(points, friend.shield.points, ACHIEVEMENTCOMPARISON_FRIENDSHIELDFONT1, ACHIEVEMENTCOMPARISON_FRIENDSHIELDFONT2);

        if ( completed and not player.completed ) then
            player.completed = true;
            player.dateCompleted:SetText(string.format(SHORTDATE, day, month, year));
            player.dateCompleted:Show();
            player:Saturate();
        elseif ( completed ) then
            player.dateCompleted:SetText(string.format(SHORTDATE, day, month, year));
        else
            player.completed = nil;
            player.dateCompleted:Hide();
            player:Desaturate();
        end

        if ( friendCompleted and not friend.completed ) then
            friend.completed = true;
            friend.status:SetText(string.format(SHORTDATE, friendDay, friendMonth, friendYear));
            friend:Saturate();
        elseif ( friendCompleted ) then
            friend.status:SetText(string.format(SHORTDATE, friendDay, friendMonth, friendYear));
        else
            friend.completed = nil;
            friend.status:SetText(INCOMPLETE);
            friend:Desaturate();
        end
    end
end

local displayStatCategories = {};
function AchievementFrameComparison_UpdateStats ()
    local category = achievementFunctions.selectedCategory;
    local scrollFrame = AchievementFrameComparisonStatsContainer;
    local offset = HybridScrollFrame_GetOffset(scrollFrame);
    local buttons = scrollFrame.buttons;
    local numButtons = table.getn(buttons);
    local headerHeight = 24;
    local statHeight = 24;
    local totalHeight = 0;
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
        totalHeight = totalHeight+headerHeight;

        for i=1, numStats do
            tinsert(displayStatCategories, {id = GetAchievementInfo(category, i)});
            totalHeight = totalHeight+statHeight;
        end
        achievementFunctions.lastCategory = category;
        achievementFunctions.lastHeight = totalHeight;
    else
        totalHeight = achievementFunctions.lastHeight;
    end

    -- add all the subcategories and their stat id's
    for i, cat in next, categories do
        if ( cat.parent == category ) then
            tinsert(displayStatCategories, {id = cat.id, header = true});
            totalHeight = totalHeight+headerHeight;
            numStats = GetCategoryNumAchievements(cat.id);
            for k=1, numStats do
                tinsert(displayStatCategories, {id = GetAchievementInfo(cat.id, k)});
                totalHeight = totalHeight+statHeight;
            end
        end
    end

    -- iterate through the displayStatCategories and display them
    local statCount = table.getn(displayStatCategories);
    local statIndex, id, button;
    local stat;
    local displayedHeight = 0;
    for i = 1, numButtons do
        button = buttons[i];
        statIndex = offset + i;
        if ( statIndex <= statCount ) then
            stat = displayStatCategories[statIndex];
            if ( stat.header ) then
                AchievementFrameComparisonStats_SetHeader(button, stat.id);
            else
                AchievementFrameComparisonStats_SetStat(button, stat.id, nil, statIndex);
            end
            button:Show();
        else
            button:Hide();
        end
        displayedHeight = displayedHeight+button:GetHeight();
    end
    HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight);
end

function AchievementFrameComparisonStat_OnLoad (self)
    local name = self:GetName();
    self.background = getglobal(name.."BG");
    self.left = getglobal(name.."HeaderLeft");
    self.middle = getglobal(name.."HeaderMiddle");
    self.right = getglobal(name.."HeaderRight");
    self.left2 = getglobal(name.."HeaderLeft2");
    self.middle2 = getglobal(name.."HeaderMiddle2");
    self.right2 = getglobal(name.."HeaderRight2");
    self.text = getglobal(name.."Text");
    self.title = getglobal(name.."Title");
    self.value = getglobal(name.."Value");
    self.value:SetVertexColor(1, 0.97, 0.6);
    self.friendValue = getglobal(name.."ComparisonValue");
    self.friendValue:SetVertexColor(1, 0.97, 0.6);
    self.mouseover = getglobal(name.. "Mouseover");
end

function AchievementFrameComparisonStats_SetStat (button, category, index, colorIndex, isSummary)
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
    local criteriaString, criteriaType, completed, quantityNumber, reqQuantity, charName, flags, assetID, quantity, friendQuantity;
    if ( not isSummary ) then
        friendQuantity = GetComparisonStatistic(id);
        quantity = GetStatistic(id);
    else
        criteriaString, criteriaType, completed, quantityNumber, reqQuantity, charName, flags, assetID, quantity = GetAchievementCriteriaInfo(category);
    end
    if ( not quantity ) then
        quantity = "--";
    end
    if ( not friendQuantity ) then
        friendQuantity = "--";
    end

    button.value:SetText(quantity);

    -- We're gonna use button.text here to measure string width for friendQuantity. This saves us many strings!
    button.text:SetText(friendQuantity);
    local width = button.text:GetStringWidth();
    if ( width > button.friendValue:GetWidth() ) then
        button.friendValue:SetFontObject("AchievementFont_Small");
        button.mouseover:Show();
        button.mouseover.tooltip = friendQuantity;
    else
        button.friendValue:SetFontObject("GameFontHighlightRight");
        button.mouseover:Hide();
        button.mouseover.tooltip = nil;
    end

    button.text:SetText(name);
    button.friendValue:SetText(friendQuantity);


    -- Hide the header images
    button.title:Hide();
    button.left:Hide();
    button.middle:Hide();
    button.right:Hide();
    button.left2:Hide();
    button.middle2:Hide();
    button.right2:Hide();
    button.isHeader = false;
end

function AchievementFrameComparisonStats_SetHeader(button, id)
    -- show header
    button.left:Show();
    button.middle:Show();
    button.right:Show();
    button.left2:Show();
    button.middle2:Show();
    button.right2:Show();
    button.title:SetText(GetCategoryInfo(id));
    button.title:Show();
    button.friendValue:SetText("");
    button.value:SetText("");
    button.text:SetText("");
    button:SetHeight(24);
    button.background:Hide();
    button.isHeader = true;
    button.id = id;
end





function AchievementComparisonFriendButton_Saturate (self)
    local name = self:GetName();
    getglobal(name .. "TitleBackground"):SetTexCoord(0.3, 0.575, 0, 0.3125);
    getglobal(name .. "Background"):SetTexture("Interface\\Addons\\Achievements\\src\\wotlk\\Textures\\UI-Achievement-Parchment-Horizontal");
    getglobal(name .. "Glow"):SetVertexColor(1.0, 1.0, 1.0);
    self.icon:Saturate();
    self.shield:Saturate();
    self.shield.points:SetVertexColor(1, 1, 1);
    self.status:SetVertexColor(1, .82, 0);
    self:SetBackdropBorderColor(ACHIEVEMENTUI_REDBORDER_R, ACHIEVEMENTUI_REDBORDER_G, ACHIEVEMENTUI_REDBORDER_B, ACHIEVEMENTUI_REDBORDER_A);
end

function AchievementComparisonFriendButton_Desaturate (self)
    local name = self:GetName();
    getglobal(name .. "TitleBackground"):SetTexCoord(0.3, 0.575, 0.34375, 0.65625);
    getglobal(name .. "Background"):SetTexture("Interface\\Addons\\Achievements\\src\\wotlk\\Textures\\UI-Achievement-Parchment-Horizontal-Desaturated");
    getglobal(name .. "Glow"):SetVertexColor(.22, .17, .13);
    self.icon:Desaturate();
    self.shield:Desaturate();
    self.shield.points:SetVertexColor(.65, .65, .65);
    self.status:SetVertexColor(.65, .65, .65);
    self:SetBackdropBorderColor(.5, .5, .5);
end

function AchievementComparisonFriendButton_OnLoad (self)
    local name = self:GetName();

    self.status = getglobal(name .. "Status");
    self.icon = getglobal(name .. "Icon");
    self.shield = getglobal(name .. "Shield");

    self:SetBackdropBorderColor(ACHIEVEMENTUI_REDBORDER_R, ACHIEVEMENTUI_REDBORDER_G, ACHIEVEMENTUI_REDBORDER_B, ACHIEVEMENTUI_REDBORDER_A);
    self.Saturate = AchievementComparisonFriendButton_Saturate;
    self.Desaturate = AchievementComparisonFriendButton_Desaturate;

    self:Desaturate();
end



function AchievementFrame_IsComparison()
    return AchievementFrame.isComparison;
end
