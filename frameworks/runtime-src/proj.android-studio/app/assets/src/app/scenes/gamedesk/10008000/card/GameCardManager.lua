
local GameCardManager = class("GameCardManager", G_BaseLayer)

local GameConfigManager         = require("app.scenes.gamedesk.GameConfigManager")
local GameCard                  = require("app.scenes.gamedesk."..GameConfigManager.tGameID.NN..".card.GameCard")

local scheduler = cc.Director:getInstance():getScheduler()

-- ��������
function GameCardManager:onCreate()

    -- ���Ƶ�
    self.ptStandCard = {}
    self.ptStandCard[1] = cc.p(400, 50)
    self.ptStandCard[2] = cc.p(560, 402)
    self.ptStandCard[3] = cc.p(358, 402)
    self.ptStandCard[4] = cc.p(758, 402)
    self.ptStandCard[5] = cc.p(60, 219)
    self.ptStandCard[6] = cc.p(993, 219)
    self.ptStandCard[7] = cc.p(191, 365)
    self.ptStandCard[8] = cc.p(937, 365)
end

-- ��ʼ����ͼ
function GameCardManager:initView()
	
    self.tStandCardsBatchNode = {}
    for i=1, G_GameDefine.nMaxPlayerCount do
        self.tStandCardsBatchNode[i] = cc.Node:create()
        self:addChild(self.tStandCardsBatchNode[i])
    end
end

-- ��ʼ������
function GameCardManager:initTouch()

end

-- ����
function GameCardManager:onEnter()

end

-- �˳�
function GameCardManager:onExit()

end

-- ��ԭ
function GameCardManager:restore()
    
    for i=1, G_GameDefine.nMaxPlayerCount do
	    self.tStandCardsBatchNode[i]:removeAllChildren()
    end
end

-- �����ʾ������
function GameCardManager:clearShowEndCard(nLocalSeat)

    if nLocalSeat == G_GameDefine.nMaxPlayerCount then
        for i=1, G_GameDefine.nMaxPlayerCount do
            self.tStandCardsBatchNode[i]:removeAllChildren()
        end
    else
        self.tStandCardsBatchNode[nLocalSeat]:removeAllChildren()
    end
end

-- ������ʾ������
function GameCardManager:createShowEndCard(nLocalSeat, cbCardData, cbCardCount)

    self.tStandCardsBatchNode[nLocalSeat]:removeAllChildren()

    local nOffX = self.ptStandCard[nLocalSeat].x
    local nOffY = self.ptStandCard[nLocalSeat].y
    local nOffEndX = 32
    
    for i=1, cbCardCount do

        if cbCardData[i] ~= 0 then
            local pGameCard = GameCard:create(cbCardData[i], nLocalSeat)
            pGameCard:setScale(0.5)
            pGameCard:setVisible(true)
            pGameCard:setPosition(cc.p(nOffX + nOffEndX*(i-1), nOffY))
            self.tStandCardsBatchNode[nLocalSeat]:addChild(pGameCard)
        end
    end
end

return GameCardManager
