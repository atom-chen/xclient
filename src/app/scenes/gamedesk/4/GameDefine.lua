local M = class("GameDefine")

-- ��ǰ����
M.nGameCount = 0

-- ������
M.nTotalGameCount = 10

-- ��Ϸ״̬
M.nGameStatus = 0

-- ����������
M.nPlayerCount = 3

-- ��Ϸ����״̬
M.GAME_FREE             = 0
-- ��Ϸ��ʼ״̬
M.GAME_PLAY             = 1

-- ��������
M.END_NORMAL            = 1
-- ��ɢ����
M.END_DISSOLVE          = 2

-- ��Ϸ����
M.GAME_PLAYER           = 3
-- ��Ч
M.INVALID_SEAT          = 0xFF

-- ��������
M.ACK_NULL              = 0x00					-- ��
M.ACK_TI                = 0x01					-- ��
M.ACK_PAO               = 0x02					-- ��
M.ACK_WEI               = 0x04					-- ��
M.ACK_CHI               = 0x08					-- ��
M.ACK_CHI_EX            = 0x10					-- ��
M.ACK_PENG              = 0x20					-- ��
M.ACK_CHIHU             = 0x40					-- ��

-- ��������
M.CK_NULL               = 0x00					-- ��Ч����
M.CK_XXD                = 0x01					-- СС���
M.CK_XDD                = 0x02					-- С����
M.CK_EQS                = 0x04					-- ����ʮ��
M.CK_LEFT               = 0x10					-- �������
M.CK_CENTER             = 0x20					-- ���ж���
M.CK_RIGHT              = 0x40					-- ���Ҷ���

-- ��Ϣ����
M.HUXI_TI_S             = 9                     -- С���Ϣ
M.HUXI_TI_B             = 12                    -- �����Ϣ
M.HUXI_PAO_S            = 6                     -- С���Ϣ
M.HUXI_PAO_B            = 9                     -- �����Ϣ
M.HUXI_WEI_S            = 3                     -- С�˺�Ϣ
M.HUXI_WEI_B            = 6                     -- ���˺�Ϣ
M.HUXI_PENG_S           = 1                     -- С����Ϣ
M.HUXI_PENG_B           = 3                     -- ������Ϣ
M.HUXI_27A_S            = 3                     -- С27A��Ϣ
M.HUXI_27A_B            = 6                     -- ��27A��Ϣ
M.HUXI_123_S            = 3                     -- С123��Ϣ
M.HUXI_123_B            = 6                     -- ��123��Ϣ

-- ��ֵ����
M.MAX_WEAVE                 = 7					-- ������
M.MAX_WEAVE_CARD_COUNT		= 4					-- ������������
M.MAX_CARD					= 20				-- �����
M.MAX_COUNT					= 21				-- �����Ŀ
M.MAX_LEFT					= 19				-- ���ʣ����
M.MIN_HU_XI					= 15				-- ������С��Ϣ

return M