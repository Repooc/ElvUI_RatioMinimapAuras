local E, L, _, P = unpack(ElvUI)
local A = E.Auras

local ACH
-- local Masque = E.Masque
-- local MasqueGroupBuffs = Masque and Masque:Group('ElvUI', 'Buffs')
-- local MasqueGroupDebuffs = Masque and Masque:Group('ElvUI', 'Debuffs')

for _, auraType in next, {'buffs', 'debuffs'} do
	P.auras[auraType].keepSizeRatio = true
	P.auras[auraType].height = 18
	P.auras[auraType].useCustomCoords = false
	P.auras[auraType].customCoords = {
		left = 0.08,
		right = 0.92,
		top = 0.08,
		bottom = 0.92,
	}
end

local IS_HORIZONTAL_GROWTH = {
	RIGHT_DOWN = true,
	RIGHT_UP = true,
	LEFT_DOWN = true,
	LEFT_UP = true,
}

local DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER = {
	DOWN_RIGHT = -1,
	DOWN_LEFT = -1,
	UP_RIGHT = 1,
	UP_LEFT = 1,
	RIGHT_DOWN = -1,
	RIGHT_UP = 1,
	LEFT_DOWN = -1,
	LEFT_UP = 1,
}

local function trimIcon(button, db)
	if not button.texture or not db then return end

	local left, right, top, bottom = unpack(db.useCustomCoords and {db.customCoords.left, db.customCoords.right, db.customCoords.top, db.customCoords.bottom} or E.TexCoords)
	local changeRatio = db and not db.keepSizeRatio

	if changeRatio then
		local width, height = button:GetSize()
		local ratio = width / height
		if ratio > 1 then
			local trimAmount = (1 - (1 / ratio)) * 0.5
			top = top + trimAmount
			bottom = bottom - trimAmount
		else
			local trimAmount = (1 - ratio) * 0.5
			left = left + trimAmount
			right = right - trimAmount
		end
	end

	button.texture:SetTexCoord(left, right, top, bottom)
end

local function UpdateIcon(_, button)
	if not button then return end

	local db = A.db[button.auraType]
	if not db or db.keepSizeRatio then return end


	local pos = db.barPosition
	local iconSize = db.size - (E.Border * 2)
	local iconHeight = (db.keepSizeRatio and db.size or db.height) - (E.Border * 2)
	local isOnTop, isOnBottom = pos == 'TOP', pos == 'BOTTOM'
	local isHorizontal = isOnTop or isOnBottom

	trimIcon(button, db)
	button.statusBar:Size(isHorizontal and iconSize or (db.barSize + (E.PixelMode and 0 or 2)), isHorizontal and (db.barSize + (E.PixelMode and 0 or 2)) or iconHeight)
end

local function UpdateHeader(_, header)
	if not E.private.auras.enable then return end

	local db = A.db[header.auraType]
	if not db or db.keepSizeRatio then return end

	local template = format('ElvUIAuraTemplate%d%d', db.size, (db.keepSizeRatio and db.size or db.height))
	header:SetAttribute('template', template)

	if header.filter == 'HELPFUL' then
		header:SetAttribute('weaponTemplate', template)
	end

	if IS_HORIZONTAL_GROWTH[db.growthDirection] then
		-- header:SetAttribute('minWidth', ((db.wrapAfter == 1 and 0 or db.horizontalSpacing) + db.size) * db.wrapAfter) --* ElvUI
		-- header:SetAttribute('minHeight', (db.verticalSpacing + db.size) * db.maxWraps) --* ElvUI
		header:SetAttribute('minHeight', (db.verticalSpacing + (db.keepSizeRatio and db.size or db.height)) * db.maxWraps)
		-- header:SetAttribute('xOffset', DIRECTION_TO_HORIZONTAL_SPACING_MULTIPLIER[db.growthDirection] * (db.horizontalSpacing + db.size)) --* ElvUI
		-- header:SetAttribute('yOffset', 0) --* ElvUI
		-- header:SetAttribute('wrapXOffset', 0) --* ElvUI
		-- header:SetAttribute('wrapYOffset', DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER[db.growthDirection] * (db.verticalSpacing + db.size)) --* ElvUI
		header:SetAttribute('wrapYOffset', DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER[db.growthDirection] * (db.verticalSpacing + (db.keepSizeRatio and db.size or db.height)))
	else
		-- header:SetAttribute('minWidth', (db.horizontalSpacing + db.size) * db.maxWraps) --* ElvUI
		-- header:SetAttribute('minHeight', ((db.wrapAfter == 1 and 0 or db.verticalSpacing) + db.size) * db.wrapAfter) --* ElvUI
		header:SetAttribute('minHeight', ((db.wrapAfter == 1 and 0 or db.verticalSpacing) + (db.keepSizeRatio and db.size or db.height)) * db.wrapAfter)
		-- header:SetAttribute('xOffset', 0) --* ElvUI
		-- header:SetAttribute('yOffset', DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER[db.growthDirection] * (db.verticalSpacing + db.size)) --* ElvUI
		header:SetAttribute('yOffset', DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER[db.growthDirection] * (db.verticalSpacing + (db.keepSizeRatio and db.size or db.height)))
		-- header:SetAttribute('wrapXOffset', DIRECTION_TO_HORIZONTAL_SPACING_MULTIPLIER[db.growthDirection] * (db.horizontalSpacing + db.size)) --* ElvUI
		-- header:SetAttribute('wrapYOffset', 0) --* ElvUI
	end

	local index = 1
	local child = select(index, header:GetChildren())

	while child do
		print(child, index)
		child:Size(db.size, db.keepSizeRatio and db.size or db.height)

		index = index + 1
		child = select(index, header:GetChildren())
	end

	-- if MasqueGroupBuffs and E.private.auras.buffsHeader and E.private.auras.masque.buffs then MasqueGroupBuffs:ReSkin() end
	-- if MasqueGroupDebuffs and E.private.auras.debuffsHeader and E.private.auras.masque.debuffs then MasqueGroupDebuffs:ReSkin() end
end

local function GetSharedOptions(auraType)
	local config = E.Options.args.auras
	config.args[auraType].args.sizeGroup = ACH:Group(L["Size"], nil, -3)
	config.args[auraType].args.sizeGroup.inline = true
	config.args[auraType].args.sizeGroup.args.keepSizeRatio = ACH:Toggle(L["Keep Size Ratio"], nil, 1)
	config.args[auraType].args.sizeGroup.args.height = ACH:Range(L["Icon Height"], nil, 5, { min = 10, max = 60, step = 1 }, nil, nil, nil, nil, function() return E.db.auras[auraType].keepSizeRatio end)
	config.args[auraType].args.sizeGroup.args.size = ACH:Range(function() return E.db.auras[auraType].keepSizeRatio and L["Size"] or L["Icon Width"] end, L["Set the size of the individual auras."], 5, { min = 10, max = 60, step = 1 })
	config.args[auraType].args.sizeGroup.args.spacer = ACH:Spacer(6, 'full')
	config.args[auraType].args.sizeGroup.args.useCustomCoords = ACH:Toggle(L["Use Custom Coords"], nil, 7, nil, nil, nil, nil, nil, nil, function() return E.db.auras[auraType].keepSizeRatio end)
	config.args[auraType].args.sizeGroup.args.CustomCoordsGroup = ACH:Group(L["Custom Coords"], nil, 8, nil, function(info) return E.db.auras[auraType].customCoords[info[#info]] end, function(info, value) E.db.auras[auraType].customCoords[info[#info]] = value A:UpdateHeader(A.BuffFrame) A:UpdateHeader(A.DebuffFrame) end, nil, function() return E.db.auras[auraType].keepSizeRatio or not E.db.auras[auraType].useCustomCoords end)
	config.args[auraType].args.sizeGroup.args.CustomCoordsGroup.args.left = ACH:Range(L["Left"], nil, 1, { min = 0, max = 1, step = 0.01 })
	config.args[auraType].args.sizeGroup.args.CustomCoordsGroup.args.right = ACH:Range(L["Right"], nil, 2, { min = 0, max = 1, step = 0.01 })
	config.args[auraType].args.sizeGroup.args.CustomCoordsGroup.args.top = ACH:Range(L["Top"], nil, 3, { min = 0, max = 1, step = 0.01 })
	config.args[auraType].args.sizeGroup.args.CustomCoordsGroup.args.bottom = ACH:Range(L["Bottom"], nil, 4, { min = 0, max = 1, step = 0.01 })
	config.args[auraType].args.size.hidden = true

	return config
end

local function GetOptions()
	ACH = E.Libs.ACH

	GetSharedOptions('buffs')
	GetSharedOptions('debuffs')
end

local function Initialize()
	hooksecurefunc(A, 'UpdateHeader', UpdateHeader)
	hooksecurefunc(A, 'UpdateIcon', UpdateIcon)

	E.Libs.EP:RegisterPlugin('ElvUI_RatioMinimapAuras', GetOptions)
end
hooksecurefunc(E, 'LoadAPI', Initialize)
