local fUpdateDisplay;

function onInit()
	fUpdateDisplay = super.updateDisplay;
	super.updateDisplay = updateDisplay;
	super.onInit();
end

function updateDisplay()
	local sCasterType = castertype.getStringValue();
	local bUses = (sCasterType == "");
	local bSpells = (sCasterType == "memorization");
	local bPsionics = (sCasterType == "psionic");

	groupuses_label.setVisible(bUses);
	uses.setVisible(bUses);
	usesperiod.setVisible(bUses);
	
	groupprepared_label.setVisible(bSpells);
	prepared.setVisible(bSpells);

	grouppowerdie_label.setVisible(bPsionics);
	powerdie.setVisible(bPsionics);
end