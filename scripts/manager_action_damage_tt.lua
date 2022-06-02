local fGetReductionTypeOriginal;
function onInit()
	fGetReductionTypeOriginal = ActionDamage.getReductionType;
	ActionDamage.getReductionType = getReductionType;
end

function getReductionType(rSource, rTarget, sEffectType)
	local aFinal = fGetReductionTypeOriginal(rSource, rTarget, sEffectType)

	if sEffectType == "VULN" then
		if ActorManager.isPC(rTarget) and StrainManager.isAtOrAboveStrainLevel(rTarget, "soul", 3) then
			aFinal["necrotic"] = { aNegatives = {}, mod = 0 };
		end
	end

	return aFinal;
end