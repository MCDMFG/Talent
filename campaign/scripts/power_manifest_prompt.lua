local rActor = nil;
local rAction = nil;
local nodePower = nil;

function setData(actor, action, powernode)
	rActor = actor;
	rAction = action;
	nodePower = powernode;

	main.subwindow.name.setValue(rAction.label);
	main.subwindow.order.setValue(rAction.nLevel);
	main.subwindow.order.setMinValue(rAction.nLevel);
	updateTooltip(rAction.nLevel);
end

function updateTooltip(nLevel)
	local sOrderText = Interface.getString("order_" .. nLevel);
	local sTooltip = string.format(Interface.getString("promp_tooltip_ok"), sOrderText);
	button_ok.setTooltipText(sTooltip)
end

function ok()
	local nLevel = main.subwindow.order.getValue();
	rAction.nLevel = nLevel;
	rAction.bPrompt =  false;
	PowerManager.performAction(nil, rActor, rAction, nodePower)
	close();
end