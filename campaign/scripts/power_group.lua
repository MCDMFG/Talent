local fSetHeaderCategory;

function onInit()
	fSetHeaderCategory = super.setHeaderCategory
	super.setHeaderCategory = setHeaderCategory
end

function setHeaderCategory(rGroup, sGroup, nLevel, bAllowDelete)
	fSetHeaderCategory(rGroup, sGroup, nLevel, bAllowDelete);

	if sGroup ~= "" and rGroup.grouptype == "psionic" then
		if not nLevel then
			name.setValue(sGroup);
		elseif nLevel > 0 and nLevel <= 6 then
			name.setValue(sGroup .. " (" .. Interface.getString("order_" .. nLevel) .. ")");
		else
			name.setValue(sGroup);
		end
		if nLevel == 2 then
			name.setIcon("char_abilities_green");
		elseif nLevel == 3 then
			name.setIcon("char_abilities_orange");
		elseif nLevel == 4 then
			name.setIcon("char_abilities_blue");
		elseif nLevel == 5 then
			name.setIcon("char_abilities_red");
		elseif nLevel == 6 then
			name.setIcon("char_abilities_purple");
		else
			name.setIcon("char_abilities");
		end
		level.setValue(nLevel);
		group.setValue(sGroup);

		super.setNode(rGroup.node);
		if bAllowDelete then
			idelete.setVisibility(true);
		end
	end
end