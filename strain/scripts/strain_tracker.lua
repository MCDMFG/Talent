local node = nil;
local strainnode = nil;

function onInit()
	node = getDatabaseNode();
	strainnode = node.getChild("strain");
end

function clearAllStrain()
	StrainManager.clearAllStrain(node);
end

function clearStrain(sType)
	StrainManager.setCurrentStrain(node, sType, 0);
end