local node = nil;
local strainnode = nil;

function onInit()
	node = getDatabaseNode();
	strainnode = node.getChild("strain");
end