local fRestOriginal;

function onInit()
	fRestOriginal = CharManager.rest;
	CharManager.rest = rest;
end

function rest(nodeChar, bLong)

	fRestOriginal(nodeChar, bLong);
	if bLong then
		StrainManager.clearAllStrain(nodeChar);
	end
end