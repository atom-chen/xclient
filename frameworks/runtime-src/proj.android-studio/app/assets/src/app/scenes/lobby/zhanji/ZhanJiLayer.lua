
local ZhanJiLayer = class("ZhanJiLayer",G_BaseLayer)

ZhanJiLayer.RESOURCE_FILENAME = "ZhanJiLayer.csb"

local SearchLayer           = require("app.scenes.lobby.zhanji.SearchLayer")
local ZhanJiCellLayer       = require("app.scenes.lobby.zhanji.ZhanJiCellLayer")
local ZhanJiWatchLayer      = require("app.scenes.lobby.zhanji.ZhanJiWatchLayer")

-- ����
function ZhanJiLayer:onCreate()

    self.WatchFriendBtn = self.resourceNode_.node["WatchFriendBtn"]
    self.CloseBtn = self.resourceNode_.node["CloseBtn"]
end

-- ��ʼ����ͼ
function ZhanJiLayer:initView()
	self.SearchLayer = SearchLayer.create()
	self.SearchLayer:setVisible(false)
	self:addChild(self.SearchLayer)
end

-- ��ʼ������
function ZhanJiLayer:initTouch()
	self.WatchFriendBtn:addClickEventListener(handler(self, self.Click_WatchFriend))
	self.CloseBtn:addClickEventListener(handler(self, self.Click_Close))
end

-- ���볡��
function ZhanJiLayer:onEnter()
	self.target, self.event_handlermsg = G_Event:addEventListener("receiveMsg", handler(self,self.handleMsg))
	G_Data.CL_ReplayListReq = {}
	G_NetManager:sendMsg(NETTYPE_LOGIN,"CL_ReplayListReq")
end

-- �˳�����
function ZhanJiLayer:onExit()
	G_Event:removeEventListener(self.event_handlermsg)
end

-- �鿴���ѻط�
function ZhanJiLayer:Click_WatchFriend()
	self.SearchLayer:setVisible(true)
end

-- �رհ�ť
function ZhanJiLayer:Click_Close()
	self:removeFromParent()
end

-- ��Ϣ
function ZhanJiLayer:handleMsg(event)
	if event.msgName == "CL_ReplayListAck" then
		self:showWatchItems(event.msgData)
	elseif event.msgName == "CL_ReplayDetailAck" then
		local curlayer = ZhanJiWatchLayer.create()
		self:addChild(curlayer)
	end
end

-- ��ʾ�ط��б�
function ZhanJiLayer:showWatchItems(msgData)
	self.m_pListView = ccui.ListView:create()
	self.m_pListView:setAnchorPoint(cc.p(0.5,0.5))
	self.m_pListView:setDirection(ccui.ScrollViewDir.vertical)
    self.m_pListView:setTouchEnabled(true)
    self.m_pListView:setBounceEnabled(true)
    self.m_pListView:setContentSize(cc.size(1000, 400))
    self.m_pListView:setPosition(cc.p(display.width / 2,display.height / 2 - 40))
    self.m_pListView:setBackGroundColor(cc.c3b(0,0,255))
    self.m_pListView:setItemsMargin(5)
    self:addChild(self.m_pListView)

    for i = 1,G_Data.CL_ReplayListAck.count do
    	local imageViewTemp = ccui.ImageView:create("ZhanJi/zhanji_frame01.png")
    	imageViewTemp:setName("listView")
    	imageViewTemp:setTouchEnabled(true)
    	imageViewTemp:addClickEventListener(handler(self, self.Click_WatchItem))
    	imageViewTemp:setTag(G_Data.CL_ReplayListAck.ReplaListInfo[i].roomid)
    	self.m_pListView:addChild(imageViewTemp)

    	local curCell = ZhanJiCellLayer.new(G_Data.CL_ReplayListAck.ReplaListInfo[i],i)
    	imageViewTemp:addChild(curCell)

    end
    if G_Data.CL_ReplayListAck.count > 0 then
    	self.resourceNode_.node["login_agreeText"]:setVisible(false)
    end
end

-- ����ط���
function ZhanJiLayer:Click_WatchItem(sender)
	G_Data.CL_ReplayDetailReq = {}
	G_Data.CL_ReplayDetailReq.roomid = sender:getTag()
	G_NetManager:sendMsg(NETTYPE_LOGIN,"CL_ReplayDetailReq")
end

return ZhanJiLayer
