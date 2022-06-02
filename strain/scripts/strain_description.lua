function onFirstLayout()
	onSizeChanged();
end

function onSizeChanged()
	local _, nHeight = getSize();
	setAnchor("top", "", "center", "current", -(nHeight / 2))
end