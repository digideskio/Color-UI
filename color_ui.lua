--Team Members--
--Avi Mattenson, Eliana Abraham, Jiawei Wang, Jacob Hash, Longhan Li, Yuxuan Zhou--

redOffset = 0
greenOffset = 0
blueOffset = 0
red = 0
blue = 0
green = 0
yversion = 0
mode = 0

--audio patterns

ucPush1 = FlowBox("object","PushA1", _G["FBPush"])
ucPush2 = FlowBox("object","PushA2", _G["FBPush"])
ucPush3 = _G["FBCam"]
ucPush4 = _G["FBGain"]
dac = _G["FBDac"]

--if not ucSample then
	ucSample = FlowBox("object","Sample", _G["FBSample"])
	ucSample:AddFile("green_light_sounds_converted.wav")
	ucSample:AddFile("yellow_light_sounds_converted.wav")
	ucSample:AddFile("yellow_light_sounds_converted1.wav")
	ucSample:AddFile("red_light_sounds_converted.wav")
	ucSample:AddFile("Godzilla_converted1.wav")
--end


ucPush4.Amp:SetPull(ucPush3.Bright)

ucPush4:SetPullLink(0, ucSample, 0)
dac.In:SetPull(ucPush4.Out)
ucPush4:Push(1)

--dac:SetPullLink(0, ucSample, 0)

ucPush1:SetPushLink(0,ucSample, 3)
--ucPush1:Push(0)
ucPush2:SetPushLink(0,ucSample, 2)
ucPush2:Push(1.0)

-- color methods

RED, GREEN, YELLOW, BLUE, NONE = 0, 1, 2, 3, 4

currentColor = NONE

function isRed(r, g, b)
	local RED_DIFFERENCE = 100
	return g + RED_DIFFERENCE < r and b + RED_DIFFERENCE < r
end

function isGreen(r, g, b)
	local GREEN_DIFFERENCE = 50
	return r + GREEN_DIFFERENCE < g and b + GREEN_DIFFERENCE < g
end

function isYellow(r, g, b)
	local YELLOW_MAX_B = 80
	local YELLOW_MIN_RG = 120
	return (r + g) / 2 > YELLOW_MIN_RG and b < YELLOW_MAX_B and math.abs(r - g) < 50
end

function isBlue(r, g, b)
	local BLUE_DIFFERENCE = 100
	return g + 50 < b and r + 150 < b
end

function playAudio(color)
	ucPush2:Push(1.0)
	ucPush2:Push(0.0)
	if color == YELLOW then
		num = 1+yversion
		ucPush1:Push(num/4)
	elseif color == GREEN then
		ucPush1:Push(0/4)
	elseif color == RED then
		ucPush1:Push(3/4)
	elseif color == BLUE then
		ucPush1:Push(4/4)
	end
end

 function colorUpdate(r, g, b)
	lastColor = currentColor
 	if isYellow(r,g,b) then
 		DPrint("Yellow")
 		currentColor = YELLOW
 	elseif isGreen(r,g,b) then
 		DPrint("Green")
 		currentColor = GREEN
 	elseif isRed(r,g,b) then
 		DPrint("Red")
 		currentColor = RED
 	elseif isBlue(r,g,b) then
		DPrint("Blue")
		currentColor = BLUE
	else
		DPrint("nocolor")
	end

	if lastColor ~= currentColor then
			playAudio(currentColor)
	end
 end

function updateHandler(self, elapsedTime)
	if frozen == 1 then
		return
	end

	r1,g1,b1 = camera.t:PixelColor(ScreenWidth()/2, ScreenHeight()/2)
	r2,g2,b2 = camera.t:PixelColor(ScreenWidth()/2, ScreenHeight()/4)
	r3,g3,b3 = camera.t:PixelColor(ScreenWidth()/2, ScreenHeight()*3/4)

	r4 = math.floor((r1+r2+r3)/3)
	g4 = math.floor((g1+g2+g3)/3)
	b4 = math.floor((b1+b2+b3)/3)

	--r4 = ucPush3.Red
	if mode == 0 then
		-- Nothing needed
	elseif mode == 1 then
		r4 = r4 + redOffset
		g4 = g4 + greenOffset
		b4 = b4 + blueOffset
	end

	if r4 < 0 then r4 = 0 end
	if r4 > 255 then r4 = 255 end
	if g4 < 0 then g4 = 0 end
	if g4 > 255 then g4 = 255 end
	if b4 < 0 then b4 = 0 end
	if b4 > 255 then b4 = 255 end

	color.t:SetSolidColor(r4, g4, b4)

	infoBoxes[0].title:SetLabel(r4)
	infoBoxes[1].title:SetLabel(g4)
	infoBoxes[2].title:SetLabel(b4)

	colorUpdate(r4, g4, b4)
end

function freezerHandler(self)
	if freezer.title:Label() == "FREEZE" then
		freezer.title:SetLabel("UNFREEZE")
		freezer.title:SetFontHeight(25)
		freezer.t:SetSolidColor(0, 255, 0, 255)
		frozen = 1
	elseif freezer.title:Label() == "UNFREEZE" then
		freezer.title:SetLabel("FREEZE")
		freezer.title:SetFontHeight(35)
		freezer.t:SetSolidColor(255, 0, 0, 255)
		frozen = 0
	end
end

function setCam(self, texture)
	settingButtons[0].t:SetSolidColor(255,153,153,255)
	settingButtons[1].t:SetSolidColor(128,128,128,255)
	mode = 0
	board:Hide()
end

function setCamMan(self)
	settingButtons[0].t:SetSolidColor(128, 128, 128, 255)
	settingButtons[1].t:SetSolidColor(255,153,153,255)
	mode = 1
	board:Hide()
end

function addRed(self)
	if redOffset < 255 then
		redOffset = redOffset + 10
		infoBoxes0[0].title:SetLabel("Offset:" .. redOffset)
	end
end

function minusRed(self)
	if redOffset > -255 then
		redOffset = redOffset - 10
		infoBoxes0[0].title:SetLabel("Offset:" .. redOffset)
	end
end

function addGreen(self)
	if greenOffset < 255 then
		greenOffset = greenOffset + 10
		infoBoxes0[1].title:SetLabel("Offset:" .. greenOffset)
	end
end

function minusGreen(self)
	if greenOffset > -255 then
		greenOffset = greenOffset - 10
		infoBoxes0[1].title:SetLabel("Offset:" .. greenOffset)
	end
end

function addBlue(self)
	if blueOffset < 255 then
		blueOffset = blueOffset + 10
		infoBoxes0[2].title:SetLabel("Offset:" .. blueOffset)
	end
end

function minusBlue(self)
	if blueOffset > -255 then
		blueOffset = blueOffset - 10
		infoBoxes0[2].title:SetLabel("Offset:" .. blueOffset)
	end
end

function resetHandler(self)
	redOffset = 0
	greenOffset = 0
	blueOffset = 0
	red = 0
	green = 0
	blue = 0
	reset = 1
	currentColor = NULL
	ucPush2:Push(1)
	infoBoxes0[0].title:SetLabel("Offset:" .. redOffset)
	infoBoxes0[1].title:SetLabel("Offset:" .. greenOffset)
	infoBoxes0[2].title:SetLabel("Offset:" .. blueOffset)
end

function changePage1(self, x, y, dx, dy)
	if dx > 10 then
		SetPage(1)
	end
end

function Page2InfoRed1(self)
	--buttons[0].t = buttons[0]:Texture()
	buttons[0].t:SetSolidColor(255, 0, 0, 255)
	buttons[3].t:SetSolidColor(255, 255, 255, 255)
end

function Page2InfoYellow1(self)
	buttons[1].t:SetSolidColor(255, 0, 0, 255)
	buttons[4].t:SetSolidColor(255, 255, 255, 255)
	yversion = 0
end

function Page2InfoGreen1(self)
	buttons[2].t:SetSolidColor(255, 0, 0, 255)
	buttons[5].t:SetSolidColor(255, 255, 255, 255)
end

function Page2InfoRed2(self)
	--buttons[3].t = buttons[3]:Texture()
	buttons[3].t:SetSolidColor(255, 0, 0, 255)
	buttons[0].t:SetSolidColor(255, 255, 255, 255)
end

function Page2InfoYellow2(self)
	buttons[4].t:SetSolidColor(255, 0, 0, 255)
	buttons[1].t:SetSolidColor(255, 255, 255, 255)
	yversion = 1
end

function Page2InfoGreen2(self)
	buttons[5].t:SetSolidColor(255, 0, 0, 255)
	buttons[2].t:SetSolidColor(255, 255, 255, 255)
end



function changePage2(self, x, y, dx, dy)
	if dx < -10 then
		SetPage(2)
	end
end

SetPage(1)
FreeAllRegions()
r = Region()
r:SetWidth(ScreenWidth())
r:SetHeight(ScreenHeight())
r:SetLayer("BACKGROUND")
r.t = r:Texture(255, 255, 255, 255)
r:EnableInput(true)
r:Handle("OnMove", changePage2)
r:Show()

board = Region()
board:SetWidth(ScreenWidth()/3)
board:SetHeight(ScreenHeight()/3)
board:SetLayer("MEDIUM")
board.t = board:Texture(0, 255, 255, 255)
board:Hide()

camera = Region()
camera:SetWidth(ScreenWidth()/3)
camera:SetHeight(ScreenHeight()/3)
camera:SetLayer("LOW")
camera.t = camera:Texture(255, 255, 255, 255)
camera.t:UseCamera()
camera:Show()
camera:Handle("OnUpdate", updateHandler)

color = Region()
color:SetWidth(ScreenWidth()/3)
color:SetHeight(ScreenHeight()/3)
color:SetAnchor("LEFT", camera, "RIGHT", ScreenWidth()/3, 0)
color.t = color:Texture(0, 0, 0, 255)
color.title = color:TextLabel()
color.title:SetFontHeight(15)
color.title:SetLabel("Major Camera Color: ")
color.title:SetVerticalAlign("TOP")
color.title:SetColor(255, 255, 0, 255)
color:Show()

frozen = 0
freezer = Region()
freezer:SetWidth(ScreenWidth()/6)
freezer:SetHeight(ScreenWidth()/6)
freezer:SetAnchor("TOP", camera, "TOPRIGHT", ScreenWidth()/6, 0)
freezer:SetLayer("TOP")
freezer.t = freezer:Texture(255, 0, 0, 255)
freezer.title = freezer:TextLabel()
freezer.title:SetLabel("FREEZE")
freezer.title:SetColor(0, 0, 0, 255)
freezer.title:SetFontHeight(20)
freezer:Show()
freezer:Handle("OnTouchDown", freezerHandler)
freezer:EnableInput(true)

reset = Region()
reset:SetWidth(ScreenWidth()/6)
reset:SetHeight(ScreenWidth()/6)
reset:SetAnchor("TOP", freezer, "BOTTOM",0, -ScreenHeight()/12)
reset:SetLayer("TOP")
reset.t = reset:Texture(0, 255, 0, 255)
reset.title = reset:TextLabel()
reset.title:SetLabel("RESET")
reset.title:SetColor(0, 0, 0, 255)
reset.title:SetFontHeight(20)
reset:Show()
reset:Handle("OnTouchDown", resetHandler)
reset:EnableInput(true)

settingButtons = {}
for i= 0, 1 do
	settingButtons[i] = Region()
	settingButtons[i]:SetWidth(ScreenWidth()/4)
	settingButtons[i]:SetHeight(ScreenHeight()/8)
	settingButtons[i]:SetLayer("TOP")
	settingButtons[i]:SetAnchor("TOPLEFT", r, "TOPLEFT", (i+1)*ScreenWidth()/6+i*ScreenWidth()/4, -ScreenHeight()*1/32)
	settingButtons[i].t = settingButtons[i]:Texture(255, 0, 0, 255)
	settingButtons[i]:Show()
	settingButtons[i].title = settingButtons[i]:TextLabel()
	settingButtons[i].title:SetColor(255, 255, 255, 255)
	settingButtons[i].title:SetFontHeight(20)
	settingButtons[i]:EnableInput(true)
end
settingButtons[0].title:SetLabel("Camera")
settingButtons[1].title:SetLabel("Camera+Manual")
settingButtons[0].t:SetSolidColor(128, 128, 128, 255)
settingButtons[1].t:SetSolidColor(128, 128, 128, 255)
settingButtons[0]:Handle("OnTouchDown", setCam)
settingButtons[1]:Handle("OnTouchDown", setCamMan)

texts = {}
for i=0,2 do
	texts[i] = Region()
	texts[i]:SetWidth(ScreenWidth()/4)
	texts[i]:SetHeight(ScreenHeight()/12)
	texts[i]:SetLayer("LOW")
	texts[i]:SetAnchor("TOPLEFT", r, "TOPLEFT", (i+1)*ScreenWidth()/16+i*ScreenWidth()/4, -ScreenHeight()*1/6)
	texts[i].t = texts[i]:Texture(255, 255, 255, 255)
	texts[i]:Show()
	texts[i].title = texts[i]:TextLabel()
	texts[i].title:SetFontHeight(20)
end
texts[0].title:SetLabel("RED")
texts[1].title:SetLabel("GREEN")
texts[2].title:SetLabel("BLUE")
texts[0].title:SetColor(255, 0, 0, 255)
texts[1].title:SetColor(0, 255, 0, 255)
texts[2].title:SetColor(0, 0, 255, 255)

addButtons = {}
for i=0,2 do
	addButtons[i] = Region()
	addButtons[i]:SetWidth(ScreenWidth()/8)
	addButtons[i]:SetHeight(ScreenWidth()/8)
	addButtons[i]:SetLayer("LOW")
	addButtons[i]:SetAnchor("TOP", texts[i], "BOTTOM", 0, -ScreenHeight()*1/256)
	addButtons[i].title = addButtons[i]:TextLabel()
	addButtons[i].title:SetColor(255, 255, 255, 255)
	addButtons[i].title:SetFontHeight(20)
	addButtons[i].title:SetLabel("+")
	addButtons[i]:Show()
	addButtons[i]:EnableInput(true)
end
addButtons[0].t = addButtons[0]:Texture(255, 0, 0, 255)
addButtons[1].t = addButtons[1]:Texture(0, 255, 0, 255)
addButtons[2].t = addButtons[2]:Texture(0, 0, 255, 255)
addButtons[0]:Handle("OnTouchDown", addRed)
addButtons[1]:Handle("OnTouchDown", addGreen)
addButtons[2]:Handle("OnTouchDown", addBlue)


minusButtons = {}
for i=0,2 do
	minusButtons[i] = Region()
	minusButtons[i]:SetWidth(ScreenWidth()/8)
	minusButtons[i]:SetHeight(ScreenWidth()/8)
	minusButtons[i]:SetLayer("LOW")
	minusButtons[i]:SetAnchor("TOP", addButtons[i], "BOTTOM", 0, -ScreenHeight()*1/32)
	minusButtons[i].title = minusButtons[i]:TextLabel()
	minusButtons[i].title:SetColor(255, 255, 255, 255)
	minusButtons[i].title:SetFontHeight(20)
	minusButtons[i].title:SetLabel("-")
	minusButtons[i]:Show()
	minusButtons[i]:EnableInput(true)
end
minusButtons[0].t = minusButtons[0]:Texture(255, 0, 0, 255)
minusButtons[1].t = minusButtons[1]:Texture(0, 255, 0, 255)
minusButtons[2].t = minusButtons[2]:Texture(0, 0, 255, 255)
minusButtons[0]:Handle("OnTouchDown", minusRed)
minusButtons[1]:Handle("OnTouchDown", minusGreen)
minusButtons[2]:Handle("OnTouchDown", minusBlue)


infoBoxes0 = {}
for i=0,2 do
	infoBoxes0[i] = Region()
	infoBoxes0[i]:SetWidth(ScreenWidth()/4)
	infoBoxes0[i]:SetHeight(ScreenWidth()/32)
	infoBoxes0[i]:SetLayer("LOW")
	infoBoxes0[i]:SetAnchor("TOP", minusButtons[i], "BOTTOM", 0, -ScreenHeight()*1/256)
	infoBoxes0[i].title = infoBoxes0[i]:TextLabel()
	infoBoxes0[i].t = infoBoxes0[i]:Texture(255, 255, 255, 255)
	infoBoxes0[i].title:SetFontHeight(20)
	infoBoxes0[i]:Show()
end
infoBoxes0[0].title:SetColor(255, 0, 0, 255)
infoBoxes0[1].title:SetColor(0, 255, 0, 255)
infoBoxes0[2].title:SetColor(0, 0, 255, 255)
infoBoxes0[0].title:SetLabel("Offset:" .. redOffset)
infoBoxes0[1].title:SetLabel("Offset:" .. greenOffset)
infoBoxes0[2].title:SetLabel("Offset:" .. blueOffset)

infoBoxes = {}
for i=0,2 do
	infoBoxes[i] = Region()
	infoBoxes[i]:SetWidth(ScreenWidth()/4)
	infoBoxes[i]:SetHeight(ScreenWidth()/8)
	infoBoxes[i]:SetLayer("LOW")
	infoBoxes[i]:SetAnchor("TOP", minusButtons[i], "BOTTOM", 0, -ScreenHeight()*1/16)
	infoBoxes[i].title = infoBoxes[i]:TextLabel()
	infoBoxes[i].title:SetFontHeight(20)
	infoBoxes[i].t = infoBoxes[i]:Texture(255, 255, 255, 255)
	infoBoxes[i].title:SetLabel("255")
	infoBoxes[i]:Show()
end
infoBoxes[0].title:SetColor(255, 0, 0, 255)
infoBoxes[1].title:SetColor(0, 255, 0, 255)
infoBoxes[2].title:SetColor(0, 0, 255, 255)

--

SetPage(2)
r2 = Region()
r2:SetWidth(ScreenWidth())
r2:SetHeight(ScreenHeight())
r2.t = r2:Texture(0, 0, 0, 255)
r2:SetLayer("BACKGROUND")
r2:Handle("OnMove", changePage1)
r2:EnableInput(true)
r2:Show()
buttons = {}
for i=0, 5 do
	buttons[i] = Region()
	buttons[i]:SetWidth(ScreenWidth()/3)
	buttons[i]:SetHeight(ScreenHeight()/12)
	if i<=2 then
		buttons[i]:SetAnchor("TOPLEFT", r2, "TOPLEFT", 0, -ScreenHeight()/24-ScreenHeight()*i/3)
	else
		buttons[i]:SetAnchor("TOPRIGHT", r2, "TOPRIGHT", 0, -ScreenHeight()/24-ScreenHeight()*(i-3)/3)
	end
	buttons[i].t = buttons[i]:Texture(255, 255, 255, 255)
	buttons[i].title = buttons[i]:TextLabel()
	buttons[i].title:SetColor(0, 0, 0, 255)
	buttons[i].title:SetFontHeight(35)
	buttons[i]:Handle("OnTouchDown", Page2Info)
	buttons[i]:EnableInput(true)
	buttons[i]:Show()
end

buttons[0]:Handle("OnTouchDown", Page2InfoRed1)
buttons[1]:Handle("OnTouchDown", Page2InfoYellow1)
buttons[2]:Handle("OnTouchDown", Page2InfoGreen1)
buttons[3]:Handle("OnTouchDown", Page2InfoRed2)
buttons[4]:Handle("OnTouchDown", Page2InfoYellow2)
buttons[5]:Handle("OnTouchDown", Page2InfoGreen2)

buttons[0].title:SetLabel("Red V.1")
buttons[1].title:SetLabel("Yellow V.1")
buttons[2].title:SetLabel("Green V.1")
buttons[3].title:SetLabel("Red V.2")
buttons[4].title:SetLabel("Yellow V.2")
buttons[5].title:SetLabel("Green V.2")

SetPage(1)