local fGetAttackBonusOriginal;

function onInit()
	fGetAttackBonusOriginal = CharWeaponManager.getAttackBonus;
	CharWeaponManager.getAttackBonus = getAttackBonus;
end

function getAttackBonus(nodeChar, nodeWeapon)
	local nMod, sAbility = fGetAttackBonusOriginal(nodeChar, nodeWeapon);

	-- If mind strain is at or above 3, then don't add proficiency with weapons
	-- Safest way to do this is to simply subtract the prof bonus from the total bonus
	if StrainManager.isAtOrAboveStrainLevel(nodeChar, "mind", 3) then
		if DB.getValue(nodeWeapon, "prof", 0) == 1 then
			nMod = nMod - DB.getValue(nodeChar, "profbonus", 0);
		end
	end

	return nMod, sAbility;
end