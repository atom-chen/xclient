local M = class("GameDefine")

-- ��Ϸ����״̬
M.game_free = 0
-- ��Ϸ��ʼ״̬
M.game_play = 1

-- ����������
M.nMaxPlayerCount = 3

-- �������
M.nPlayerCount = 3

-- ��ǰ����
M.nGameCount = 0

-- ������
M.nTotalGameCount = 10

-- ��Ϸ״̬
M.nGameStatus = 0

-- �������
M.nCardCount = 16

-- ��Ч
M.invalid_seat = 0xFF

return M