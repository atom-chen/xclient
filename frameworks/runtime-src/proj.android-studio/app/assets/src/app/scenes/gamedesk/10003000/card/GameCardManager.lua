
local GameCardManager = class("GameCardManager", G_BaseLayer)

local GameConfigManager         = require("app.scenes.gamedesk.GameConfigManager")
local GameCard                  = require("app.scenes.gamedesk."..GameConfigManager.tGameID.PDK..".card.GameCard")

local scheduler = cc.Director:getInstance():getScheduler()

-- ��������
function GameCardManager:onCreate()

    -- ���Ƶ�
    self.ptOutCard = {}
    self.ptOutCard[1] = cc.p(568,280)
    self.ptOutCard[2] = cc.p(300,390)
    self.ptOutCard[3] = cc.p(860,390)

    -- ����ƫ��
    self.ptOutCardOff = {}
    self.ptOutCardOff[1] = cc.p(30,-35)
    self.ptOutCardOff[2] = cc.p(300,390)
    self.ptOutCardOff[3] = cc.p(860,390)

    -- ���Ƶ�
    self.ptStandCard = {}
    self.ptStandCard[1] = cc.p(190,95)
    self.ptStandCard[2] = cc.p(180,570)
    self.ptStandCard[3] = cc.p(940,195)

    -- ���Ƶ�ƫ��
    self.ptStandOff = {}
    self.ptStandOff[1] = cc.p(55,0)
    self.ptStandOff[2] = cc.p(0,-25)
    self.ptStandOff[3] = cc.p(0,25)

    -- ���Ƶ�
    self.ptReplyStandCard = {}
    self.ptReplyStandCard[1] = cc.p(190,95)
    self.ptReplyStandCard[2] = cc.p(180,590)
    self.ptReplyStandCard[3] = cc.p(940,215)

    -- ���Ƶ�ƫ��
    self.ptReplyStandOff = {}
    self.ptReplyStandOff[1] = cc.p(55,0)
    self.ptReplyStandOff[2] = cc.p(0,-25)
    self.ptReplyStandOff[3] = cc.p(0,25)

    self.ptHeadPt = {}
    self.ptHeadPt[1] = cc.p(73,124)
    self.ptHeadPt[2] = cc.p(73,415)
    self.ptHeadPt[3] = cc.p(1047,415)

	self:init()
end

-- ��ʼ����ͼ
function GameCardManager:initView()
	
    self.tStandCardsBatchNode = {}
    self.tOutCardsBatchNode = {}
    for i=1, G_GameDefine.nMaxPlayerCount do
        
        self.tStandCardsBatchNode[i] = cc.Node:create()
	    self:addChild(self.tStandCardsBatchNode[i])

        self.tOutCardsBatchNode[i] = cc.Node:create()
        self:addChild(self.tOutCardsBatchNode[i])
    end
end

-- ��ʼ������
function GameCardManager:initTouch()

end

-- ����
function GameCardManager:onEnter()
	self.listener = cc.EventListenerTouchOneByOne:create()
	self.listener:setSwallowTouches(false)
	self.listener:registerScriptHandler(handler(self,self.onTouchBegin),cc.Handler.EVENT_TOUCH_BEGAN)
	self.listener:registerScriptHandler(handler(self,self.onTouchMove),cc.Handler.EVENT_TOUCH_MOVED)
	self.listener:registerScriptHandler(handler(self,self.onTouchEnded),cc.Handler.EVENT_TOUCH_ENDED)
	self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.listener,self)
end

-- �˳�
function GameCardManager:onExit()
	self:getEventDispatcher():removeEventListener(self.listener)
end

-- ������ʼ
function GameCardManager:onTouchBegin(touch, event)

    -- �طŲ�����
    if G_GameDefine.bReplay then
        return false
    end
    
    local location = touch:getLocationInView()
    local touchPoint = cc.Director:getInstance():convertToGL(location)
    self:touchSelectCard(touchPoint, true)
	return true
end

-- �����ƶ�
function GameCardManager:onTouchMove(touch, event)

    -- �طŲ�����
    if G_GameDefine.bReplay then
        return
    end
    
    local location = touch:getLocationInView()
    local touchPoint = cc.Director:getInstance():convertToGL(location)
    self:touchSelectCard(touchPoint, true)
end

-- ��������
function GameCardManager:onTouchEnded(touch, event)

    -- �طŲ�����
    if G_GameDefine.bReplay then
        return
    end
    
    local location = touch:getLocationInView()
    local touchPoint = cc.Director:getInstance():convertToGL(location)
    self:touchSelectCard(touchPoint, true)

    for i=self.nCardCount[1], 1, -1 do
        self.tCardsArrayStand[1][i]:caluteTouch()
    end
end

-- ��ʼ��
function GameCardManager:init()
	self.tCardsArrayStand = {}
	self.tCardsArrayOut = {}

    for i=1, G_GameDefine.nMaxPlayerCount do
        self.tCardsArrayStand[i] = {}
    end

    self.nCardCount = {}
    self.nCardCount[1] = 0
    self.nCardCount[2] = 0
    self.nCardCount[3] = 0

    self.nStartTouchTime = 0
    self.nPromptCount = 1

    if self.schedule_outcard then
    	scheduler:unscheduleScriptEntry(self.schedule_outcard)
    	self.schedule_outcard = nil
    end
end

-- ��ԭ
function GameCardManager:restore()
    
    for i=1, G_GameDefine.nMaxPlayerCount do
	    self.tStandCardsBatchNode[i]:removeAllChildren()
        self.tOutCardsBatchNode[i]:removeAllChildren()
    end

	self:init()
end

-- ѡ����
function GameCardManager:touchSelectCard(touchPoint, bBeginTouch)

    local bFind = false
    for i=self.nCardCount[1], 1, -1 do
        if self.tCardsArrayStand[1][i] ~= nil and cc.rectContainsPoint(self.tCardsArrayStand[1][i]:getBoundingBox(), touchPoint) then
            self.tCardsArrayStand[1][i]:setTouchFlag()
            bFind = true
            break
         end
    end
end

-- ������ʾ����
function GameCardManager:createShowStandCard(nLocalSeat, cbCardData, cbCardCount)

    self.tCardsArrayStand[nLocalSeat] = {}
    self.tStandCardsBatchNode[nLocalSeat]:removeAllChildren()

    local nAdd = (G_GameDefine.nCardCount - cbCardCount) / 2
    for i=1, cbCardCount do
         local pGameCard = GameCard:create(cbCardData[i], nLocalSeat)
         local curPoint = self:caluteCardPoint(0, i+nAdd, nLocalSeat, true)
         pGameCard:setPosition(curPoint)
         pGameCard:setVisible(true)
         self.tCardsArrayStand[nLocalSeat][i] = pGameCard
         self.tStandCardsBatchNode[nLocalSeat]:addChild(pGameCard)
    end

    self.nCardCount[nLocalSeat] = cbCardCount
end

-- ������ʾ����
function GameCardManager:createShowOutCard(nLocalSeat, cbCardData, cbCardCount)

    self.tCardsArrayOut[nLocalSeat] = {}
    self.tOutCardsBatchNode[nLocalSeat]:removeAllChildren()

    local nOutOff = 30
    local nStartX = self.ptOutCard[nLocalSeat].x - cbCardCount*nOutOff/2
    local nStartY = self.ptOutCard[nLocalSeat].y
    if nLocalSeat == 2 then
        nStartX = self.ptOutCard[nLocalSeat].x
    elseif nLocalSeat == 3 then
        nStartX = self.ptOutCard[nLocalSeat].x - cbCardCount*nOutOff
    end

    if nLocalSeat == 1 or G_GameDefine.bReplay then

        for i=1, cbCardCount do
            for nIndex, pGameCard in pairs(self.tCardsArrayStand[nLocalSeat]) do
                if pGameCard:getCardData(GameCard.Card_All) == cbCardData[i] then
                    -- �Ƴ���
                    self.tStandCardsBatchNode[nLocalSeat]:removeChild(pGameCard)
                    -- �Ƴ�Ԫ��
                    table.remove(self.tCardsArrayStand[nLocalSeat], nIndex)
                    break
                end
            end
        end

        -- ������
        local nAdd = (G_GameDefine.nCardCount - self.nCardCount[nLocalSeat]) / 2
        for nIndex, pGameCard in pairs(self.tCardsArrayStand[nLocalSeat]) do
            local curPoint = self:caluteCardPoint(0, nIndex+nAdd, nLocalSeat, true)
            pGameCard:setPosition(curPoint)
            pGameCard:setVisible(true)
        end

        -- ��������
        self.tStandCardsBatchNode[nLocalSeat]:sortAllChildren()
    end

    for i=1, cbCardCount do
        local pGameCard = GameCard:create(cbCardData[i], nLocalSeat)
        pGameCard:setPosition(cc.p(nStartX+i*nOutOff, nStartY))
        pGameCard:setScale(0.5)
        pGameCard:setVisible(true)
        self.tOutCardsBatchNode[nLocalSeat][i] = pGameCard
        self.tOutCardsBatchNode[nLocalSeat]:addChild(pGameCard)
    end
end

-- �����ʾ����
function GameCardManager:clearShowOutCard(nLocalSeat)

    if nLocalSeat == G_GameDefine.nMaxPlayerCount then
        for i=1, G_GameDefine.nMaxPlayerCount do
            self.tCardsArrayOut[i] = {}
            self.tOutCardsBatchNode[i]:removeAllChildren()
        end
    else
        self.tCardsArrayOut[nLocalSeat] = {}
        self.tOutCardsBatchNode[nLocalSeat]:removeAllChildren()
    end
end

-- ������ʾ������
function GameCardManager:createShowEndCard(nLocalSeat, cbCardData, cbCardCount)

    -- �Լ�������ʾ��
    if nLocalSeat == 1 then
        return
    end

    self.tCardsArrayStand[nLocalSeat] = {}
    self.tStandCardsBatchNode[nLocalSeat]:removeAllChildren()

    local nOffX = 0
    local nOffY = 0
    
    local nChangeOffX = 0
    local nChangeOffY = 0
    if nLocalSeat == 2 then
        nChangeOffX = 240
        nChangeOffY = 445
	elseif nLocalSeat == 3 then
        nChangeOffX = 660
        nChangeOffY = 445
    end
    local nOffEndX = 32
    
    for i=1, cbCardCount do

        if cbCardData[i] ~= 0 then
            local pGameCard = GameCard:create(cbCardData[i], nLocalSeat)
            pGameCard:setScale(0.5)
            pGameCard:setVisible(true)
            if cbCardCount >= 8 then
                if i <= 8 then
                    nOffX = nChangeOffX
                    nOffY = nChangeOffY
                    pGameCard:setPosition(cc.p(nOffX + nOffEndX*(i-1), nOffY))
                else
                    nOffX = nChangeOffX
                    if nLocalSeat == 3 then
                        nOffX = nChangeOffX + (G_GameDefine.nCardCount - cbCardCount) * nOffEndX
                    end
                    nOffY = -45 + nChangeOffY
                    pGameCard:setPosition(cc.p(nOffX + nOffEndX*((i-1)%8), nOffY))
                end
            else
                nOffX = nChangeOffX
                nOffY = nChangeOffY
                pGameCard:setPosition(cc.p(nOffX + nOffEndX*(i-1), nOffY))
            end
            self.tCardsArrayStand[nLocalSeat][i] = pGameCard
            self.tStandCardsBatchNode[nLocalSeat]:addChild(pGameCard)
        end
    end
end

-- �����������
function GameCardManager:setUserCardCount(nServerSeat, cbCardCount)

    local nLocalSeat = G_GamePlayer:getLocalSeat(nServerSeat)
    self.nCardCount[nLocalSeat] = cbCardCount
    G_DeskScene.GameAvatarLayer:setCardCount(nServerSeat, self.nCardCount[nLocalSeat])
end

-- �����������
function GameCardManager:addUserCardCount(nServerSeat, cbCardCount)

    local nLocalSeat = G_GamePlayer:getLocalSeat(nServerSeat)
    self.nCardCount[nLocalSeat] = self.nCardCount[nLocalSeat] - cbCardCount
    G_DeskScene.GameAvatarLayer:setCardCount(nServerSeat, self.nCardCount[nLocalSeat])
end

-- �����Ƶ�
function GameCardManager:caluteCardPoint(nStart, nNum, nLocalSeat, bNoMove)

    local nOffX = 0
    local nOffY = 0
    if nStart ~= 0 then
        nOffX = ptStandOff[nLocalSeat].x * nStart / 2
        nOffY = ptStandOff[nLocalSeat].y * nStart / 2
    end

    if G_GameDefine.bReplay then
        if bNoMove then
            return cc.p(self.ptReplyStandCard[nLocalSeat].x + self.ptReplyStandOff[nLocalSeat].x * nNum + nOffX, self.ptReplyStandCard[nLocalSeat].y + self.ptReplyStandOff[nLocalSeat].y * nNum + nOffY)
        else
            return cc.p(self.ptReplyStandCard[nLocalSeat].x + self.ptReplyStandOff[nLocalSeat].x * nNum + nOffX, self.ptReplyStandCard[nLocalSeat].y + self.ptReplyStandOff[nLocalSeat].y * nNum + nOffY)
        end
    else
        if bNoMove then
            return cc.p(self.ptStandCard[nLocalSeat].x + self.ptStandOff[nLocalSeat].x * nNum + nOffX, self.ptStandCard[nLocalSeat].y + self.ptStandOff[nLocalSeat].y * nNum + nOffY)
        else
            return cc.p(self.ptStandCard[nLocalSeat].x + self.ptStandOff[nLocalSeat].x * nNum + nOffX, self.ptStandCard[nLocalSeat].y + self.ptStandOff[nLocalSeat].y * nNum + nOffY)
        end
    end
    
    return cc.p(0,0)
end

-- ��ȡָ��������
function GameCardManager:getCardArray(nLocalSeat, nCardType)

    local tCardData = {}
    for i=1, G_GameDefine.nCardCount do
        tCardData[i] = 0
    end
    
    local nCardCount = 0
	for i=1, self.nCardCount[nLocalSeat] do
        local pGameCard = self.tCardsArrayStand[nLocalSeat][i]
        if pGameCard ~= nil then
            -- ȡ����ֵ
            local nCardData = pGameCard:getCardData(nCardType)
            if nCardData > 0 then
                nCardCount = nCardCount + 1
                tCardData[nCardCount] = nCardData
            end
        end
    end

    return tCardData, nCardCount
end

-- ��ȡ����
function GameCardManager:getCardStandArray(nLocalSeat)

	return self.tCardsArrayStand[nLocalSeat]
end

-- ��ȡ����
function GameCardManager:getCardOutArray(nLocalSeat)
    return self.tCardsArrayOut[nLocalSeat]
end

-- ��ʾ
function GameCardManager:prompt(tOutCardData, nOutCardCount)

    local nAllChooseCount = 0
    local nCardCount = 0
    local tCardData = {}
    for i=1, self.nCardCount[1] do
        local pGameCard = self.tCardsArrayStand[1][i]
        if pGameCard ~= nil then

            local nChooseCardData = pGameCard:getCardData(GameCard.Card_Selected)
            if nChooseCardData > 0 then
                nAllChooseCount = nAllChooseCount + 1
            end

            -- ������
            local nCardData = pGameCard:getCardData(GameCard.Card_All)
            if nCardData > 0 then
                nCardCount = nCardCount + 1
                tCardData[nCardCount] = nCardData
            end
        end
    end

    -- ��û��ѡ��,��ʾ�ӵ�һ����ʼ
    if nAllChooseCount == 0 then
        self.nPromptCount = 1
    end
    
    local tSearchCardResult = {}
    local nResultCount = G_DeskScene.GameLogic:searchOutCard(tCardData, nCardCount, tOutCardData, nOutCardCount, tSearchCardResult)
    
    if nResultCount > 0 then
        self.nPromptCount = math.fmod(self.nPromptCount, nResultCount+1)
        if self.nPromptCount <= 0 then
            self.nPromptCount = 1
        end

        -- ������
        local nAdd = (G_GameDefine.nCardCount - self.nCardCount[1]) / 2
        for nIndex, pGameCard in pairs(self.tCardsArrayStand[1]) do
            local curPoint = self:caluteCardPoint(0, nIndex+nAdd, 1, true)
            pGameCard:onTouchOut()
            pGameCard:setVisible(true)
        end

        for i=1, tSearchCardResult.byCardCount[self.nPromptCount] do
            for j=1, self.nCardCount[1] do
                local pGameCard = self.tCardsArrayStand[1][j]
                if pGameCard ~= nil then
                    -- ȡû��ѡ�����
                    local nCardData = pGameCard:getCardData(GameCard.Card_None)
                    if nCardData > 0 and nCardData == tSearchCardResult.byResultCard[self.nPromptCount][i] then
                        -- ѡ����
                        pGameCard:onTouchIn()
                        break
                    end
                end
            end
        end

        self.nPromptCount = self.nPromptCount + 1

        return true
    end

    return false
end

-- ѹ��
function GameCardManager:pressCard(tOutCardData, nOutCardCount)

    local nCardCount = 0
    local tCardData = {}
    for i=1, self.nCardCount[1] do
        local pGameCard = self.tCardsArrayStand[1][i]
        if pGameCard ~= nil then
            -- ������
            local nCardData = pGameCard:getCardData(GameCard.Card_All)
            if nCardData > 0 then
                nCardCount = nCardCount + 1
                tCardData[nCardCount] = nCardData
            end
        end
    end
    
    local tSearchCardResult = {}
    local byResultCount = G_DeskScene.GameLogic:searchOutCard(tCardData, nCardCount, tOutCardData, nOutCardCount, tSearchCardResult)

    if byResultCount > 0 then

        local tChooseCard = {}
        for i=1, byResultCount do
            for j=1, tSearchCardResult.byCardCount[i] do
                local nCardData = tSearchCardResult.byResultCard[i][j]
                tChooseCard[G_DeskScene.GameLogic:getCardValue(nCardData)] = true
            end
        end

        for i=1, self.nCardCount[1] do
            local pGameCard = self.tCardsArrayStand[1][i]
            if pGameCard ~= nil then
                -- ������
                local nCardData = pGameCard:getCardData(GameCard.Card_All)
                if nCardData > 0 then

                    local bChooseTouch = tChooseCard[G_DeskScene.GameLogic:getCardValue(nCardData)]
                    -- ����ѡ��״̬
                    pGameCard:setTouchState(bChooseTouch)
                end
            end
        end

        return true
    end
    return false
end

-- �Զ�����
function GameCardManager:autoOutCard(bFirstOutCard, tOutCardData, nOutCardCount)

    local tCardData, nCardCount = self:getCardArray(1, GameCard.Card_All)

    if not bFirstOutCard then
        -- ���ɳ�����
        if not G_DeskScene.GameLogic:compareCard(tOutCardData, nOutCardCount, tCardData, nCardCount) then
            return
        end
    else
        -- ȡ������
        local nCardType = G_DeskScene.GameLogic:getCardType(tCardData, nCardCount)
        if nCardType == CT_ERROR then
	        -- �Ƿ��������
	        local bError = true
            while bError do
                -- �����˿�
		        local tAnalyseResult = {}
		        G_DeskScene.GameLogic:analysebCardData(tCardData, nCardCount, tAnalyseResult)
		        -- ��������
		        if tAnalyseResult.byBlockCount[3] == nil or tAnalyseResult.byBlockCount[3] <= 1 then
			        break
		        end

                -- ��������
		        local cbCardData = tAnalyseResult.tCardData[3][1]
		        local cbFirstLogicValue = G_DeskScene.GameLogic:getCardLogicValue(cbCardData)
		        local nLianPaiCount = 0
                local nLianPaiMaxCount = 0
		        -- �����ж�
		        for i=1, tAnalyseResult.byBlockCount[3] do
			        local cbCardData = tAnalyseResult.tCardData[3][i * 3]
			        if (cbFirstLogicValue ~= (G_DeskScene.GameLogic:getCardLogicValue(cbCardData) + nLianPaiCount)) then
                
                        if nLianPaiCount > nLianPaiMaxCount then
                            nLianPaiMaxCount = nLianPaiCount
                        end

                        local cbCardData = tAnalyseResult.tCardData[3][i * 3]
                        cbFirstLogicValue = G_DeskScene.GameLogic:getCardLogicValue(cbCardData)
                        nLianPaiCount = 1
			        else
                        nLianPaiCount = nLianPaiCount + 1

                        -- �������
		                if cbFirstLogicValue >= 15 then
                            if nLianPaiCount > nLianPaiMaxCount then
                                nLianPaiMaxCount = nLianPaiCount
                            end
                            local cbCardData = tAnalyseResult.tCardData[3][i * 3]
                            cbFirstLogicValue = G_DeskScene.GameLogic:getCardLogicValue(cbCardData)
                            nLianPaiCount = 1
                        end
			        end
		        end
                if nLianPaiCount > nLianPaiMaxCount then
                    nLianPaiMaxCount = nLianPaiCount
                end
		        if nLianPaiMaxCount == 0 then
			        break
		        end

		        -- �����Ʊ����ƶ���
		        if (nCardCount <= nLianPaiMaxCount * 3) then
			        break
		        end

		        -- ����555��666 ��1,2,3�Ŷ����Գ�
		        if (nCardCount - nLianPaiMaxCount * 3 > nLianPaiMaxCount * 2) then
			        break
		        end

		        -- ����δ��������
		        bError = false

		        -- ��������
		        if bError then
			        return
                end
            end
        end
    end

    if self.schedule_outcard then
    	scheduler:unscheduleScriptEntry(self.schedule_outcard)
    	self.schedule_outcard = nil
    end
    self.schedule_outcard = scheduler:scheduleScriptFunc(handler(self, self.sendOutCard), 2, false)
end

-- ���ͳ���
function GameCardManager:sendOutCard()

    if self.schedule_outcard then
    	scheduler:unscheduleScriptEntry(self.schedule_outcard)
    	self.schedule_outcard = nil
    end

    -- ��ȡѡ����
    local tCardData,nCardCount = G_DeskScene.GameCardManager:getCardArray(1, GameCard.Card_All)
    G_Data.GAME_OutCardReq = {}
    G_Data.GAME_OutCardReq.cbCardData = tCardData
    G_Data.GAME_OutCardReq.cbCardCount = nCardCount
    G_GameDeskManager:sendGameProtoclMsg(NETTYPE_GAME, "GAME_OutCardReq")
end

-- ����ѡ��״̬
function GameCardManager:recoverTouchState(bTouchState)

    for i=1, self.nCardCount[1] do
        local pGameCard = self.tCardsArrayStand[1][i]
        if pGameCard ~= nil then
            -- ����ѡ��״̬
            pGameCard:setTouchState(bTouchState)
        end
    end
end

return GameCardManager
