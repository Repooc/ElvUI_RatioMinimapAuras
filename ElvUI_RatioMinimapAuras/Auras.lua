local E, L, V, P, G = unpack(ElvUI)
local A = E.Auras

local ACH
-- local Masque = E.Masque
-- local MasqueGroupBuffs = Masque and Masque:Group('ElvUI', 'Buffs')
-- local MasqueGroupDebuffs = Masque and Masque:Group('ElvUI', 'Debuffs')

for _, auraType in next, {'buffs', 'debuffs'} do
	P.auras[auraType].keepSizeRatio = true
	P.auras[auraType].height = 18
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

local function UpdateIcon(_, button)
	local db = A.db[button.auraType]

	local pos = db.barPosition
	local iconSize = db.size - (E.Border * 2)
	local iconHeight = (db.keepSizeRatio and db.size or db.height) - (E.Border * 2)
	local isOnTop, isOnBottom = pos == 'TOP', pos == 'BOTTOM'
	local isHorizontal = isOnTop or isOnBottom

	button.statusBar:Size(isHorizontal and iconSize or (db.barSize + (E.PixelMode and 0 or 2)), isHorizontal and (db.barSize + (E.PixelMode and 0 or 2)) or iconHeight)
end

local function UpdateHeader(_, header)
	if not E.private.auras.enable then return end

	local db = A.db[header.auraType]

	local template = format('ElvUIAuraTemplate%d%d', db.size, (db.keepSizeRatio and db.size or db.height))

	if header.filter == 'HELPFUL' then
		header:SetAttribute('weaponTemplate', template)
	end

	header:SetAttribute('template', template)

	if IS_HORIZONTAL_GROWTH[db.growthDirection] then
		header:SetAttribute('minHeight', (db.verticalSpacing + (db.keepSizeRatio and db.size or db.height)) * db.maxWraps)
		header:SetAttribute('wrapYOffset', DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER[db.growthDirection] * (db.verticalSpacing + (db.keepSizeRatio and db.size or db.height)))
	else
		header:SetAttribute('minHeight', ((db.wrapAfter == 1 and 0 or db.verticalSpacing) + (db.keepSizeRatio and db.size or db.height)) * db.wrapAfter)
		header:SetAttribute('yOffset', DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER[db.growthDirection] * (db.verticalSpacing + (db.keepSizeRatio and db.size or db.height)))
	end

	local index = 1
	local child = select(index, header:GetChildren())
	while child do
		child:Size(db.size, db.keepSizeRatio and db.size or db.height)

		A:UpdateIcon(child)

		--Blizzard bug fix, icons arent being hidden when you reduce the amount of maximum buttons
		if index > (db.maxWraps * db.wrapAfter) and child:IsShown() then
			child:Hide()
		end

		index = index + 1
		child = select(index, header:GetChildren())
	end

	-- if MasqueGroupBuffs and E.private.auras.buffsHeader and E.private.auras.masque.buffs then MasqueGroupBuffs:ReSkin() end
	-- if MasqueGroupDebuffs and E.private.auras.debuffsHeader and E.private.auras.masque.debuffs then MasqueGroupDebuffs:ReSkin() end
end

local function GetOptions()
	ACH = E.Libs.ACH
	local Auras = E.Options.args.auras

	Auras.args.buffs.args.sizeGroup = ACH:Group(L["Size"], nil, -3)
	Auras.args.buffs.args.sizeGroup.inline = true
	Auras.args.buffs.args.sizeGroup.args.keepSizeRatio = ACH:Toggle(L["Keep Size Ratio"], nil, 1)
	Auras.args.buffs.args.sizeGroup.args.height = ACH:Range(L["Icon Height"], nil, 5, { min = 16, max = 60, step = 2 }, nil, nil, nil, nil, function() return E.db.auras['buffs'].keepSizeRatio end)
	Auras.args.buffs.args.sizeGroup.args.size = ACH:Range(function() return E.db.auras['buffs'].keepSizeRatio and L["Size"] or L["Icon Width"] end, L["Set the size of the individual auras."], 5, { min = 16, max = 60, step = 2 })
	Auras.args.buffs.args.size.hidden = true

	Auras.args.debuffs.args.sizeGroup = ACH:Group(L["Size"], nil, -3)
	Auras.args.debuffs.args.sizeGroup.inline = true
	Auras.args.debuffs.args.sizeGroup.args.keepSizeRatio = ACH:Toggle(L["Keep Size Ratio"], nil, 1)
	Auras.args.debuffs.args.sizeGroup.args.height = ACH:Range(L["Icon Height"], nil, 5, { min = 16, max = 60, step = 2 }, nil, nil, nil, nil, function() return E.db.auras['buffs'].keepSizeRatio end)
	Auras.args.debuffs.args.sizeGroup.args.size = ACH:Range(function() return E.db.auras['debuffs'].keepSizeRatio and L["Size"] or L["Icon Width"] end, L["Set the size of the individual auras."], 5, { min = 16, max = 60, step = 2 })
	Auras.args.debuffs.args.size.hidden = true
end

local function Initialize()
	hooksecurefunc(A, 'UpdateHeader', UpdateHeader)
	hooksecurefunc(A, 'UpdateIcon', UpdateIcon)

	E.Libs.EP:RegisterPlugin('ElvUI_RatioAuras', GetOptions)
end
hooksecurefunc(E, 'LoadAPI', Initialize)
