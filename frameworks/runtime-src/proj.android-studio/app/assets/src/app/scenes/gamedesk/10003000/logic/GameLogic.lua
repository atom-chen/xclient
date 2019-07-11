
local GameLogic = class("GameLogic")

local bit = require("bit")

--[[
//�˿�����
const BYTE	CGameLogic::m_cbCardData[FULL_COUNT] =
{
    0x01,     0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,		//���� A - K
    0x11,	  0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1A,0x1B,0x1C,0x1D,		//÷�� A - K
    0x21,	  0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2A,0x2B,0x2C,0x2D,		//���� A - K
		 0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3A,0x3B,0x3C,0x3D,		//���� A - K
};
--]]

-- ��ֵ����
local MASK_COLOR =              0xF0							    -- ��ɫ����
local MASK_VALUE =				0x0F							    -- ��ֵ����

-- �߼�����
CT_ERROR =				0									-- ��������
CT_SINGLE =				1									-- ��������
CT_DOUBLE =				2									-- ��������
CT_THREE =				3									-- ��������
CT_SINGLE_LINE =		4									-- ��������
CT_DOUBLE_LINE =		5									-- ��������
CT_THREE_LINE =			6									-- ��������
CT_THREE_TAKE_ONE =		7									-- ����һ��
CT_THREE_TAKE_TWO =		8									-- ����һ��,����2
CT_BOMB_CARD =			9									-- ը������

local byIndexCount =            5                                   -- ������������

-- ���캯��
function GameLogic:ctor()

end

-- ��ȡ��ֵ
function GameLogic:getCardValue(byCardData)
    return bit.band(byCardData, MASK_VALUE)
end

-- ��ȡ��ɫ
function GameLogic:getCardColor(byCardData)
    return bit.band(byCardData, MASK_COLOR)
end

-- �߼���ֵ
function GameLogic:getCardLogicValue(byCardData)

    -- �˿�����
    local byCardColor = self:getCardColor(byCardData)
    local byCardValue = self:getCardValue(byCardData)
    
    if byCardValue <= 0 then
        return 0
    end
    
    -- ת����ֵ
    if byCardColor == 0x40 then
        return byCardValue+2
    end

    if byCardValue <= 2 then
        return byCardValue+13
    end

    return byCardValue
end

-- �����˿�
function GameLogic:sortCardList(tCardData, byCardCount)

    -- ��Ŀ����
    if byCardCount == 0 then
        return
    end
    
    -- ת����ֵ
    local tSortValue = {}
    for i=1, byCardCount do
		tSortValue[i] = self:getCardLogicValue(tCardData[i])
    end
    
    -- �������
    local bSorted = true
    local bySwitchData = 0
    local byLast = byCardCount-1
    while (bSorted)
    do
        bSorted = false
        for i=1, byLast do
            if ((tSortValue[i]<tSortValue[i+1]) or ((tSortValue[i]==tSortValue[i+1]) and (tCardData[i]<tCardData[i+1]))) then
                -- ���ñ�־
                bSorted = true
                
                -- �˿�����
                bySwitchData = tCardData[i]
                tCardData[i] = tCardData[i+1]
                tCardData[i+1] = bySwitchData
                
                -- ����Ȩλ
                bySwitchData = tSortValue[i]
                tSortValue[i] = tSortValue[i+1]
                tSortValue[i+1] = bySwitchData
            end
        end
        byLast = byLast - 1
    end
end

-- ɾ���˿�
function GameLogic:removeCard(tCardData, byCardCount, tRemoveCard, byRemoveCount)

    -- ��������
    if byCardCount < byRemoveCount then
        return false, nil
    end
    
    -- �������
    local byDeleteCount = 0
    local tTempCardData = tCardData     -- ǳ����
    
    -- �����˿�
    for i=1, byRemoveCount do
        for j=1, byCardCount do
            if tRemoveCard[i] == tTempCardData[j] then
                byDeleteCount = byDeleteCount + 1
                tTempCardData[j] = 0
                break
            end
        end
    end
    if byDeleteCount ~= byRemoveCount then
        return false, nil
    end
    
    -- �����˿�
    local tEndCardData = {}
    local byEndCardIndex = 1
    for i=1, byCardCount do
        if tTempCardData[i] ~= 0 then
            tEndCardData[byEndCardIndex] = tTempCardData[i]
            byEndCardIndex = byEndCardIndex + 1
        end
    end
    
    return true, tEndCardData
end

-- ��ȡ����
function GameLogic:getCardType(tCardData, byCardCount)

	-- �����˿�
	self:sortCardList(tCardData, byCardCount)

    -- ������
    if byCardCount == 0 then
        return CT_ERROR
    elseif byCardCount == 1 then
        return CT_SINGLE
    elseif byCardCount == 2 then
        if (self:getCardLogicValue(tCardData[1]) == self:getCardLogicValue(tCardData[2])) then
            return CT_DOUBLE
        end
        
        return CT_ERROR
    end
    
    -- �����˿�
    local tAnalyseResult = {}
    self:analysebCardData(tCardData, byCardCount, tAnalyseResult)
    
    -- �����ж�
    if tAnalyseResult.byBlockCount[4] ~= nil and tAnalyseResult.byBlockCount[4] > 0 then
        -- �����ж�
        if tAnalyseResult.byBlockCount[4] == 1 and byCardCount == 4 then
            return CT_BOMB_CARD
        end
        
        return CT_ERROR
    end
    
    -- �����ж�
    if tAnalyseResult.byBlockCount[3] ~= nil and tAnalyseResult.byBlockCount[3] > 0 then

        local byMaxLineCount = 1
		local byLineCount = 1
        -- �����ж�
        if tAnalyseResult.byBlockCount[3] > 1 then
            -- �����ж�
            for i=1, tAnalyseResult.byBlockCount[3] do
				-- ��������
				local byCardData = tAnalyseResult.tCardData[3][i*3]
				local byFirstLogicValue = self:getCardLogicValue(byCardData)

				-- �������
				if byFirstLogicValue >= 15 then
					local byCardData = tAnalyseResult.tCardData[3][i*3]
					byFirstLogicValue = self:getCardLogicValue(byCardData)
					byLineCount = 1
                else
                    local byNextIndex = i+1
                    if byNextIndex > tAnalyseResult.byBlockCount[3] then
                        break
                    end

                    byCardData = tAnalyseResult.tCardData[3][byNextIndex*3];
                    if byFirstLogicValue == self:getCardLogicValue(byCardData) + 1 then
                        byLineCount = byLineCount + 1
                        -- �������
                        if byLineCount >= byMaxLineCount then
                            byMaxLineCount = byLineCount
                        end
                    else
                        local byCardData = tAnalyseResult.tCardData[3][i*3]
                        byFirstLogicValue = self:getCardLogicValue(byCardData)
                        byLineCount = 1
                    end
				end
            end

			if byMaxLineCount == 1 then
				return CT_ERROR
            end

			-- �����ж�
			if byMaxLineCount * 3 == byCardCount then
				return CT_THREE_LINE
            elseif byMaxLineCount * 4 == byCardCount then
				return CT_THREE_TAKE_ONE
			elseif byMaxLineCount * 5 == byCardCount then
				return CT_THREE_TAKE_TWO
			else
				-- ����3��777��888��999�������������Ե�888��999��4�������Ͻ���Ҫ�ж�-2��-3�������Ȳ�����
				if (byMaxLineCount - 1) * 5 == byCardCount then
					return CT_THREE_TAKE_TWO
                else
                    return CT_ERROR
				end
			end
        elseif byCardCount == 3 then
			return CT_THREE
        end
        
        -- �����ж�
        if byMaxLineCount*3 == byCardCount then
            return CT_THREE_LINE
        elseif byMaxLineCount*4==byCardCount then
            return CT_THREE_TAKE_ONE
        elseif byMaxLineCount*5==byCardCount then
            return CT_THREE_TAKE_TWO
        end
        
        return CT_ERROR
    end
    
    -- ��������
    if tAnalyseResult.byBlockCount[2] ~= nil and tAnalyseResult.byBlockCount[2] >= 2 then
        -- ��������
        local byCardData = tAnalyseResult.tCardData[2][1]
        local byFirstLogicValue = self:getCardLogicValue(byCardData)
        
        -- �������
        if byFirstLogicValue >= 15 then
            return CT_ERROR
        end
        
        -- �����ж�
        for i=1, tAnalyseResult.byBlockCount[2] do
            local byCardData = tAnalyseResult.tCardData[2][(i-1)*2+1]
			if byFirstLogicValue ~= self:getCardLogicValue(byCardData) + (i-1) then
				return CT_ERROR
            end
        end
        
        -- �����ж�
        if tAnalyseResult.byBlockCount[2]*2 == byCardCount then
            return CT_DOUBLE_LINE
        end
        
        return CT_ERROR
    end
    
    -- �����ж�
    if tAnalyseResult.byBlockCount[1] ~= nil and tAnalyseResult.byBlockCount[1] >= 5 and tAnalyseResult.byBlockCount[1] == byCardCount then
        -- ��������
        local byCardData = tAnalyseResult.tCardData[1][1]
        local byFirstLogicValue = self:getCardLogicValue(byCardData)
        
        -- �������
        if byFirstLogicValue >= 15 then
            return CT_ERROR
        end
        
        -- �����ж�
        for i=1, tAnalyseResult.byBlockCount[1] do
            local byCardData=tAnalyseResult.tCardData[1][i]
			if byFirstLogicValue ~= self:getCardLogicValue(byCardData) + (i-1) then
				return CT_ERROR
            end
        end
        
        return CT_SINGLE_LINE
    end
    
    return CT_ERROR
end

-- �����˿�
function GameLogic:analysebCardData(tCardData, byCardCount, tAnalyseResult)
    
    -- �˿˷���
    local byCardCountIndex = 1
    for i=1, byCardCount do

        if byCardCountIndex > byCardCount then
            break
        end
        -- ��������
        local bySameCount = 1
        local byLogicValue = self:getCardLogicValue(tCardData[byCardCountIndex])
        
        -- ����ͬ��
        for j=byCardCountIndex+1, byCardCount do
            -- ��ȡ�˿�
            if self:getCardLogicValue(tCardData[j]) ~= byLogicValue then
                break
            end
            
            -- ���ñ���
            bySameCount = bySameCount + 1
        end
        
        -- ���ý��
        if tAnalyseResult.byBlockCount == nil then
            tAnalyseResult.byBlockCount = {}
        end
        if tAnalyseResult.tCardData == nil then
            tAnalyseResult.tCardData = {}
        end
        if tAnalyseResult.tCardData[bySameCount] == nil then
            tAnalyseResult.tCardData[bySameCount] = {}
        end
        if tAnalyseResult.byBlockCount[bySameCount] == nil then
            tAnalyseResult.byBlockCount[bySameCount] = 1
        else
            tAnalyseResult.byBlockCount[bySameCount] = tAnalyseResult.byBlockCount[bySameCount] + 1
        end
        local byIndex = tAnalyseResult.byBlockCount[bySameCount] - 1
		for j=1, bySameCount do
			tAnalyseResult.tCardData[bySameCount][byIndex*bySameCount+j] = tCardData[byCardCountIndex+j-1]
		end
        
        -- ��������
        byCardCountIndex = byCardCountIndex + bySameCount
    end
end

-- �Ա��˿�
function GameLogic:compareCard(tFirstCard, byFirstCount, tNextCard, byNextCount)

    -- ��ȡ����
    local byNextType = self:getCardType(tNextCard, byNextCount)
    local byFirstType = self:getCardType(tFirstCard, byNextCount)
    
    -- �����ж�
    if byNextType == CT_ERROR then
        return false
    end
    
    -- ը���ж�
    if byFirstType ~= CT_BOMB_CARD and byNextType == CT_BOMB_CARD then
        return true
    end
    if byFirstType == CT_BOMB_CARD and byNextType ~= CT_BOMB_CARD then
        return false
    end
    
    -- �����ж�
    if byFirstType ~= byNextType or cbFirstCount ~= cbNextCount then
        return false
    end

    local compare1 = (function(tFirstCard, tNextCard, byFirstCount, byNextCount)
        -- ��ȡ��ֵ
        local byFirstLogicValue = self:getCardLogicValue(tFirstCard[1])
        local byNextLogicValue = self:getCardLogicValue(tNextCard[1])
        
        -- �Ա��˿�
        return byFirstLogicValue < byNextLogicValue
    end)

    local compare2 = (function(tFirstCard, tNextCard, byFirstCount, byNextCount)
        -- �����˿�
        local tFirstResult = {}
        local tNextResult = {}
        self:analysebCardData(tFirstCard, byFirstCount, tFirstResult)
        self:analysebCardData(tNextCard, byNextCount, tNextResult)

        if tFirstResult.tCardData[3][1] == nil or tNextResult.tCardData[3][1] == nil then
            return false
        end

        -- ��ȡ��ֵ
        local byFirstLogicValue = self:getCardLogicValue(tFirstResult.tCardData[3][1])
        local byNextLogicValue = self:getCardLogicValue(tNextResult.tCardData[3][1])

        -- �Ա��˿�
        return byFirstLogicValue < byNextLogicValue
    end)
    
    local compareWwitch = 
    {
        [CT_SINGLE]             = compare1,
        [CT_DOUBLE]             = compare1,
        [CT_THREE]              = compare1,
        [CT_SINGLE_LINE]        = compare1,
        [CT_DOUBLE_LINE]        = compare1,
        [CT_THREE_LINE]         = compare1,
        [CT_BOMB_CARD]          = compare1,
        [CT_THREE_TAKE_ONE]     = compare2,
        [CT_THREE_TAKE_TWO]     = compare2,
    }
    local func = compareWwitch[byNextType]
    if func ~= nil then
        local nResult = func(tFirstCard, tNextCard, byFirstCount, byNextCount)
        return nResult
    end
    
    return false
end

-- �����˿�
function GameLogic:makeCardData(byValueIndex, byColorIndex)
    return bit.lshift(byColorIndex, 4) + byValueIndex
end

-- �����ֲ�
function GameLogic:analysebDistributing(tCardData, byCardCount, tDistributing)
    
    -- ���ñ���
    for i=1, byCardCount do
        if tCardData[i] ~= 0 then

            -- ��ȡ����
            local byCardColor = self:getCardColor(tCardData[i])
            local byCardValue = self:getCardValue(tCardData[i])
        
            if tDistributing.byCardCount == nil then
                tDistributing.byCardCount = 0
            end
            -- �ֲ���Ϣ
            tDistributing.byCardCount = tDistributing.byCardCount + 1;

            if tDistributing.byDistributing == nil then
                tDistributing.byDistributing = {}
            end
            if tDistributing.byDistributing[byCardValue] == nil then
                tDistributing.byDistributing[byCardValue] = {}
            end
            if tDistributing.byDistributing[byCardValue][byIndexCount] == nil then
                tDistributing.byDistributing[byCardValue][byIndexCount] = 0
            end
            tDistributing.byDistributing[byCardValue][byIndexCount] = tDistributing.byDistributing[byCardValue][byIndexCount] + 1
            -- ��1��ʼ
            local byColorIndex = bit.rshift(byCardColor,4) + 1
             if tDistributing.byDistributing[byCardValue][byColorIndex] == nil then
                tDistributing.byDistributing[byCardValue][byColorIndex] = 0
            end
            tDistributing.byDistributing[byCardValue][byColorIndex] = tDistributing.byDistributing[byCardValue][byColorIndex] + 1
        end
    end
end

-- ��������
function GameLogic:searchOutCard(tCardData, byCardCount, tTurnCardData, byTurnCardCount, tSearchCardResult)

    -- ��������
    local byResultCount = 0
    -- ��ʱ�������
    local tTempSearchCardResult = {}
    
    -- �����˿�
    self:sortCardList(tCardData, byCardCount)
	-- �����˿�
	self:sortCardList(tTurnCardData, byTurnCardCount)
    
    -- ��ȡ����
    local byTurnOutType = self:getCardType(tTurnCardData, byTurnCardCount)
    
    -- ���Ʒ���
    -- ��������
    if byTurnOutType == CT_ERROR then
    
        -- �Ƿ�һ�ֳ���
        if self:getCardType(tCardData, byCardCount) ~= CT_ERROR then

            byResultCount = byResultCount + 1

            if tSearchCardResult.byCardCount == nil then
                tSearchCardResult.byCardCount = {}
            end
            tSearchCardResult.byCardCount[byResultCount] = byCardCount

            if tSearchCardResult.byResultCard == nil then
                tSearchCardResult.byResultCard = {}
            end
            for i=1, byCardCount do
                tSearchCardResult.byResultCard[i] = tCardData[i]
            end
        end
            
        tSearchCardResult.bySearchCount = byResultCount
        return byResultCount
    -- ��������,��������,��������
    elseif byTurnOutType == CT_SINGLE or byTurnOutType == CT_DOUBLE or byTurnOutType == CT_THREE then 

        -- ��������
        local byReferCard = tTurnCardData[1]
        local bySameCount = 1
        if byTurnOutType == CT_DOUBLE then
            bySameCount = 2
        elseif byTurnOutType == CT_THREE then
            bySameCount = 3
        end
            
        -- ������ͬ��
        byResultCount = self:searchSameCard(tCardData, byCardCount, byReferCard, bySameCount, tSearchCardResult)
    -- ��������,��������,��������
    elseif byTurnOutType == CT_SINGLE_LINE or byTurnOutType == CT_DOUBLE_LINE or byTurnOutType == CT_THREE_LINE then

        -- ��������
        local byBlockCount = 1
        if byTurnOutType == CT_DOUBLE_LINE then
            byBlockCount = 2
        elseif byTurnOutType == CT_THREE_LINE then
            byBlockCount = 3
        end
            
        local byLineCount = byTurnCardCount/byBlockCount
        -- ��������
        byResultCount = self:searchLineCardType(tCardData, byCardCount, tTurnCardData[1], byBlockCount, byLineCount, tSearchCardResult)
    -- ����һ��,����һ��
    elseif byTurnOutType == CT_THREE_TAKE_ONE or byTurnOutType == CT_THREE_TAKE_TWO then
        
        if byCardCount >= byTurnCardCount then
            -- ���������һ��������
            if byTurnCardCount == 4 or byTurnCardCount == 5 then
                local byTakeCardCount = (byTurnOutType == CT_THREE_TAKE_ONE) and 1 or 2
                
                -- ������������
                byResultCount = self:searchTakeCardType(tCardData, byCardCount, tTurnCardData[3], 3, byTakeCardCount, tSearchCardResult)
            else
                -- ��������
                local byLineCount = byTurnCardCount / ((byTurnOutType == CT_THREE_TAKE_ONE) and 4 or 5)
                local byTakeCardCount = byTurnOutType == CT_THREE_TAKE_ONE and 1 or 2
                
                -- ��������
                byResultCount = self:searchLineCardType(tCardData, byCardCount, tTurnCardData[1], 3, byLineCount, tSearchCardResult)
                
                -- ��ȡ����
                local bAllDistill = true
                for i=1, byResultCount do
                    local byResultIndex = byResultCount - i + 1
                    
                    -- ��������
                    local tTempCardData = tCardData     -- ǳ����
                    local byTempCardCount = byCardCount
                
                    local bRemove = false
                    -- ɾ������
                    bRemove,tTempCardData =  self:removeCard(tTempCardData, byTempCardCount, tSearchCardResult.byResultCard[byResultIndex], tSearchCardResult.byCardCount[byResultIndex])
                    byTempCardCount = byTempCardCount - tSearchCardResult.byCardCount[byResultIndex]
                    
                    -- ������
                    local tTempResult = {}
                    self:analysebCardData(tTempCardData, byTempCardCount, tTempResult)
                    
                    -- ��ȡ��
                    local tDistillCard = {}
                    local byDistillCount = 0
                    for j = 1, 4 do
                        if tTempResult.byBlockCount[j] ~= nil then
					        for k=1, tTempResult.byBlockCount[j] do
						        -- ��С����
						        local byIndex = (tTempResult.byBlockCount[j] - k)*j

						        -- ����j==1�ǵ���,j==2�Ƕ�,j==3��3��,j==4��4��
						        if byDistillCount + j <= byTakeCardCount*byLineCount then
                                    for n=1, tTempResult.byBlockCount[j] do
                                        byDistillCount = byDistillCount + 1
                                        tDistillCard[byDistillCount] = tTempResult.tCardData[j][byIndex + n]
                                    end
						        else
							        local byMustCount = byDistillCount + j - byTakeCardCount*byLineCount
                                    for n=1, byIndex+byMustCount do
                                        byDistillCount = byDistillCount + 1
                                        tDistillCard[byDistillCount] = tTempResult.tCardData[j][byIndex+n]
                                    end
						        end

						        -- ��ȡ���
						        if byDistillCount == byTakeCardCount*byLineCount then
							        break
                                end
					        end
                        
                            -- ��ȡ���
                            if byDistillCount == byTakeCardCount*byLineCount then
                                break
                            end
                        end
                    end
                    
                    -- ��ȡ���
                    if byDistillCount == byTakeCardCount*byLineCount then
                        -- ���ƴ���
                        local byCount = tSearchCardResult.byCardCount[byResultIndex]
                        for n=1,byDistillCount do
                            tSearchCardResult.byResultCard[byResultIndex][byCount+n] = tDistillCard[i]
                        end
                        tSearchCardResult.byCardCount[byResultIndex] = tSearchCardResult.byCardCount[byResultIndex] + byDistillCount
                    -- ����ɾ������
                    else
                        bAllDistill = false
                        tSearchCardResult.byCardCount[byResultIndex] = 0
                    end
                end
                
                -- �������
                if not bAllDistill then
                    tSearchCardResult.bySearchCount = byResultCount
                    byResultCount = 0
                    for i=1, tSearchCardResult.bySearchCount do
                        if tSearchCardResult.byCardCount[i] ~= 0 then

                            byResultCount = byResultCount + 1
                            tTempSearchCardResult.byCardCount[byResultCount] = tSearchCardResult.byCardCount[i]
                            tTempSearchCardResult.byResultCard[byResultCount] = tSearchCardResult.byResultCard[i]
                        end
                    end
                    tTempSearchCardResult.bySearchCount = byResultCount
                    tSearchCardResult = tTempSearchCardResult
                end
            end
        end
    end
    
    -- ����ը��
    if byCardCount >= 4 then
        -- ��������
        local byReferCard = 0
        if byTurnOutType == CT_BOMB_CARD then
            byReferCard = tTurnCardData[1]
        end
        
        -- ����ը��
        local byTempResultCount = self:searchSameCard(tCardData, byCardCount, byReferCard, 4, tTempSearchCardResult)
        for i=1, byTempResultCount do

            byResultCount = byResultCount + 1
            if tSearchCardResult.byCardCount == nil then
                tSearchCardResult.byCardCount = {}
            end
            if tSearchCardResult.byResultCard == nil then
                tSearchCardResult.byResultCard = {}
            end
            tSearchCardResult.byCardCount[byResultCount] = tTempSearchCardResult.byCardCount[i];
            tSearchCardResult.byResultCard[byResultCount] = tTempSearchCardResult.byResultCard[i]
        end
    end
    
    tSearchCardResult.bySearchCount = byResultCount;
    return byResultCount
end

-- ͬ������
function GameLogic:searchSameCard(tHandCardData, byHandCardCount, byReferCard, bySameCardCount, tSearchCardResult)

    -- ���ý��
    local byResultCount = 0
    
    -- �����˿�
    local tCardData = tHandCardData
    local byCardCount = byHandCardCount
    
    -- �����˿�
    self:sortCardList(tCardData, byCardCount)
    
    -- �����˿�
    local tAnalyseResult = {}
    self:analysebCardData(tCardData, byCardCount, tAnalyseResult)
    
    local byReferLogicValue = (byReferCard == 0) and 0 or self:getCardLogicValue(byReferCard)
    for byBlockIndex=bySameCardCount, 4 do
        if tAnalyseResult.byBlockCount ~= nil and tAnalyseResult.byBlockCount[byBlockIndex] ~= nil then
            for i=1, tAnalyseResult.byBlockCount[byBlockIndex] do

                local byIndex = (tAnalyseResult.byBlockCount[byBlockIndex] - i)*byBlockIndex
                if self:getCardLogicValue(tAnalyseResult.tCardData[byBlockIndex][byIndex+1]) > byReferLogicValue then
                    -- �����˿�
                    byResultCount = byResultCount + 1;

                    if tSearchCardResult.byResultCard == nil then
                        tSearchCardResult.byResultCard = {}
                    end
                    if tSearchCardResult.byCardCount == nil then
                        tSearchCardResult.byCardCount = {}
                    end
                    if tSearchCardResult.byResultCard[byResultCount] == nil then
                        tSearchCardResult.byResultCard[byResultCount] = {}
                    end
                    for n=1, bySameCardCount do
                        tSearchCardResult.byResultCard[byResultCount][n] = tAnalyseResult.tCardData[byBlockIndex][byIndex+n]
                    end
                    tSearchCardResult.byCardCount[byResultCount] = bySameCardCount
                end
            end
        end
    end
    
    tSearchCardResult.bySearchCount = byResultCount
    return byResultCount
end

-- ������������(����һ���Ĵ�һ��)
function GameLogic:searchTakeCardType(tHandCardData, byHandCardCount, byReferCard, bySameCardCount, byTakeCardCount, tSearchCardResult)

    -- ���ý��
    local byResultCount = 0
    
    -- Ч��
    if bySameCardCount ~= 3 and bySameCardCount ~= 4 then
        return byResultCount
    end
    if byTakeCardCount ~= 1 and byTakeCardCount ~= 2 then
        return byResultCount
    end
    
    -- �����ж�
    if (bySameCardCount == 4 and byHandCardCount < bySameCardCount + byTakeCardCount*2) or byHandCardCount < bySameCardCount + byTakeCardCount then
        return byResultCount
    end
    
    -- �����˿�
    local tCardData = tHandCardData
    local byCardCount = byHandCardCount
    
    -- �����˿�
    self:sortCardList(tCardData, byCardCount)
    
    -- ����ͬ��
    local tSameCardResult = {};
    local bySameCardResultCount = self:searchSameCard(tCardData, byCardCount, byReferCard, bySameCardCount, tSameCardResult)
    
    if bySameCardResultCount > 0 then

        -- �����˿�
        local tAnalyseResult = {}
        self:analysebCardData(tCardData, byCardCount, tAnalyseResult)
        
        -- ��Ҫ����
        local byNeedCount = bySameCardCount + byTakeCardCount;
        if bySameCardCount == 4 then
            byNeedCount = byNeedCount + byTakeCardCount
        end
        
        -- ��ȡ����
        for i=1, bySameCardResultCount do

            local bMerge = false
            
            for j=1, 4 do
                if tAnalyseResult.byBlockCount[j] ~= nil then
                    for k=1, tAnalyseResult.byBlockCount[j] do
                        -- ��С����
                        local byIndex = (tAnalyseResult.byBlockCount[j] - k)*j
                    
                        -- ������ͬ��
                        if self:getCardValue(tSameCardResult.byResultCard[i][1]) ~= self:getCardValue(tAnalyseResult.tCardData[j][byIndex+1]) then

                            -- ���ƴ���
                            local byCount = tSameCardResult.byCardCount[i]
					        --  ����j==1�ǵ���,j==2�Ƕ�,j==3��3��,j==4��4��
					        if byCount + j <= byNeedCount then
                                for n=1,j  do
                                    tSameCardResult.byResultCard[i][byCount+n] = tAnalyseResult.tCardData[j][byIndex+n]
                                end
                                tSameCardResult.byCardCount[i] = tSameCardResult.byCardCount[i] + j;
					        else
						        local byMustCount = byCount + j - byNeedCount;
                                for n=1,byMustCount  do
                                    tSameCardResult.byResultCard[i][byCount+n] = tAnalyseResult.tCardData[j][byIndex+n]
                                end
                                tSameCardResult.byCardCount[i] = tSameCardResult.byCardCount[i] + byMustCount
					        end
                    
                            if tSameCardResult.byCardCount[i] >= byNeedCount then

                                byResultCount = byResultCount + 1

                                if tSearchCardResult.byResultCard == nil then
                                    tSearchCardResult.byResultCard = {}
                                end
                                if tSearchCardResult.byCardCount == nil then
                                    tSearchCardResult.byCardCount = {}
                                end
                                tSearchCardResult.byResultCard[byResultCount] = tSameCardResult.byResultCard[i]
                                tSearchCardResult.byCardCount[byResultCount] = tSameCardResult.byCardCount[i]
                    
                                bMerge = true
                                break;
                            end
                        end
                    end
                
                    if bMerge then
                        break
                    end
                end
            end
        end
    end
    
    tSearchCardResult.bySearchCount = byResultCount
    return byResultCount
end

-- ��������
function GameLogic:searchLineCardType(tHandCardData, byHandCardCount, byReferCard, byBlockCount, byLineCount, tSearchCardResult)

    -- ���ý��
    local byResultCount = 0
    
    -- �������
    local byLessLineCount = 0
    if byLineCount == 0 then
        if byBlockCount == 1 then
            byLessLineCount = 5
        else
            byLessLineCount = 2
        end
    else
        byLessLineCount = byLineCount
    end
    
    local byReferIndex = 2
    if byReferCard ~= 0 then
        byReferIndex = self:getCardLogicValue(byReferCard) - byLessLineCount + 2
    end
    -- ����A
    if byReferIndex + byLessLineCount > 14 then
        return byResultCount
    end
    
    -- �����ж�
    if byHandCardCount < byLessLineCount*byBlockCount then
        return byResultCount
    end
    
    -- �����˿�
    local tCardData = tHandCardData
    local byCardCount = byHandCardCount
    
    -- �����˿�
    self:sortCardList(tCardData, byCardCount)
    
    -- �����˿�
    local tDistributing = {}
    self:analysebDistributing(tCardData, byCardCount, tDistributing)
    
    -- ����˳��
    local byTempLinkCount = 0
    -- �����и���byValueIndex������for����ı���,����byLastValueIndexҪ���¸�ֵ
    local byLastValueIndex = byReferIndex
    for byValueIndex=byReferIndex,13 do

        byLastValueIndex = byValueIndex

        local bContinue = true
        if tDistributing.byDistributing[byValueIndex] == nil then
            byTempLinkCount = 0
        elseif tDistributing.byDistributing[byValueIndex][byIndexCount] ~= nil then
            -- �����ж�
            if tDistributing.byDistributing[byValueIndex][byIndexCount] < byBlockCount then
                if byTempLinkCount < byLessLineCount then
                    byTempLinkCount = 0
                    bContinue = false
                else
                    byValueIndex = byValueIndex - 1 
                end
            else
                byTempLinkCount = byTempLinkCount + 1
                -- Ѱ�����
                if byLineCount == 0 then
                    bContinue = false
                end
            end
        
            if bContinue then
                if byTempLinkCount >= byLessLineCount then
            
                    byResultCount = byResultCount + 1

                    -- �����˿�
                    local byCount = 0
                    local byTmpCount = 0
                    for byIndex = byValueIndex+1-byTempLinkCount, byValueIndex do
                        byTmpCount = 0
                        for byColorIndex=1, 4 do
                            if tDistributing.byDistributing[byValueIndex] == nil then
                                byTempLinkCount = 0
                            elseif tDistributing.byDistributing[byIndex][byColorIndex] ~= nil then
                                for byColorCount=1, tDistributing.byDistributing[byIndex][byColorIndex] do

                                    byCount = byCount + 1

                                    if tSearchCardResult.byResultCard == nil then
                                        tSearchCardResult.byResultCard = {}
                                    end
                                    if tSearchCardResult.byResultCard[byResultCount] == nil then
                                        tSearchCardResult.byResultCard[byResultCount] = {}
                                    end
                                    tSearchCardResult.byResultCard[byResultCount][byCount] = self:makeCardData(byIndex, byColorIndex-1)
                        
                                    byTmpCount = byTmpCount + 1
                                    if byTmpCount == byBlockCount then
                                        break
                                    end
                                end
                                if byTmpCount == byBlockCount then
                                    break
                                end
                            end
                        end
                    end
            
                    if tSearchCardResult.byCardCount == nil then
                        tSearchCardResult.byCardCount = {}
                    end
                    -- ���ñ���
                    tSearchCardResult.byCardCount[byResultCount] = byCount
            
                    if byLineCount ~= 0 then
                        byTempLinkCount = byTempLinkCount - 1
                    else
                        byTempLinkCount = 0
                    end
                end
            end
        end
    end
    
    -- ����˳��
    if byTempLinkCount >= byLessLineCount-1 and byLastValueIndex == 13 then
        if (tDistributing.byDistributing[1] ~= nil and tDistributing.byDistributing[1][byIndexCount] >= byBlockCount) or byTempLinkCount >= byLessLineCount then
            byResultCount = byResultCount + 1
            if tSearchCardResult.byResultCard == nil then
                tSearchCardResult.byResultCard = {}
            end
            if tSearchCardResult.byResultCard[byResultCount] == nil then
                tSearchCardResult.byResultCard[byResultCount] = {}
            end

            -- �����˿�
            local byCount = 0
            local byTmpCount = 0
            for byIndex=byLastValueIndex-byTempLinkCount+1, 13 do
                byTmpCount = 0
                for byColorIndex=1, 4 do
                    if tDistributing.byDistributing[byIndex] == nil then
                        byTempLinkCount = 0
                    elseif tDistributing.byDistributing[byIndex][byColorIndex] ~= nil then
                        for byColorCount=1, tDistributing.byDistributing[byIndex][byColorIndex] do
                            byCount = byCount + 1
                            tSearchCardResult.byResultCard[byResultCount][byCount] = self:makeCardData(byIndex, byColorIndex-1)
                        
                            byTmpCount = byTmpCount + 1
                            if byTmpCount == byBlockCount then
                                break
                            end
                        end
                        if byTmpCount == byBlockCount then
                            break
                        end
                    end
                end
            end
            -- ����A
            if tDistributing.byDistributing[1][byIndexCount] >= byBlockCount then
                byTmpCount = 0
                for byColorIndex=1, 4 do
                    if tDistributing.byDistributing[1] == nil then
                        byTempLinkCount = 0
                    elseif tDistributing.byDistributing[1][byColorIndex] ~= nil then
                        for byColorCount=1, tDistributing.byDistributing[1][byColorIndex] do
                            byCount = byCount + 1
                            tSearchCardResult.byResultCard[byResultCount][byCount] = self:makeCardData(1, byColorIndex-1)
                        
                            byTmpCount = byTmpCount + 1
                            if byTmpCount == byBlockCount then
                                break
                            end
                        end
                        if byTmpCount == byBlockCount then
                            break
                        end
                    end
                end
            end
            
            if tSearchCardResult.byCardCount == nil then
                tSearchCardResult.byCardCount = {}
            end
            tSearchCardResult.byCardCount[byResultCount] = byCount
        end
    end
    
    tSearchCardResult.bySearchCount = byResultCount
    return byResultCount;
end

return GameLogic
