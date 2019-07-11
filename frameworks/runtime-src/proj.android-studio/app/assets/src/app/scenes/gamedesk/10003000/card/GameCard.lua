
local GameCard = class("GameCard", cc.Sprite)

local bit = require("bit")

-- δѡ��
GameCard.Card_None = 0
-- ѡ��
GameCard.Card_Selected = 1
-- ����(δѡ��,ѡ��)
GameCard.Card_All = 2

function GameCard:ctor(byCard, nLocalSeat)

    self.nState = GameCard.Card_None
	self.byCard = byCard
    self.bTouch = false
    self.bChooseTouch = true

	self:setDisplayFrameName(byCard, nLocalSeat)
end

function GameCard:setDisplayFrameName(byCard, nLocalSeat)

    local szFileName = ""

    local nColor = bit.rshift(byCard, 4)
    local nNum = bit.band(byCard, 0x0F)
    if nNum ~= 0 then

        szFileName = nColor.."_"..nNum..".png"

        -- ��������
        local fScale = 0.5
        local nRotation = 0
        if nLocalSeat == 1 then
            fScale = 0.8
        elseif nLocalSeat == 2 then
            fScale = 0.5
        elseif nLocalSeat == 3 then
            fScale = 0.5
        end
        self:setScale(fScale)
	    self:setSpriteFrame(szFileName)
        self:setVisible(true)
    end
end

function GameCard:setState(nState)
	self.nState = nState
end

function GameCard:getState()
	return self.nState
end

function GameCard:onTouched(bTouch)

	if bTouch then
		self:onTouchIn()
	else
		self:onTouchOut()
	end
end

function GameCard:onTouchIn()

	if self.nState == GameCard.Card_Selected then
		return
	end
	self:setPosition(self:getPositionX(), self:getPositionY() + 20)
	self.nState = GameCard.Card_Selected
end

function GameCard:onTouchOut()

    if self.nState == GameCard.Card_None then
		return
	end

	self:setPosition(self:getPositionX(), self:getPositionY() - 20)
	self.nState = GameCard.Card_None
end

-- ѡ����ɫ
function GameCard:setTouchFlag()
    self.bTouch = true
    self:setColor(cc.c3b(125, 125, 125))
end

-- ����ѡ��״̬
function GameCard:setTouchState(bChooseTouch)

    self.bChooseTouch = bChooseTouch

    if bChooseTouch then
        self:setColor(cc.c3b(255, 255, 255))
    else
        self:setColor(cc.c3b(125, 125, 125))
    end
end

function GameCard:caluteTouch()

    if not self.bChooseTouch then
        return
    end

    self:setColor(cc.c3b(255, 255, 255))

    if self.bTouch then
        if self.nState == GameCard.Card_None then
            self:onTouchIn()
        else
            self:onTouchOut()
        end
    end
    self.bTouch = false
end

function GameCard:initView()

end

function GameCard:initTouch()

end

function GameCard:initAll()

end

function GameCard:setCardData(byCard)
	self.byCard = byCard
end

function GameCard:getCardData(nCardType)

    -- ����ѡ�����ƣ�Ҫƥ������
    if nCardType ~= GameCard.Card_All then
        if self.nState ~= nCardType then
            return 0
        end
    end

	return self.byCard
end

function GameCard:onEnter()

end

function GameCard:onExit()

end

return GameCard
