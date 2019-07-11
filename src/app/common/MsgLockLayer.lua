
local scheduler = cc.Director:getInstance():getScheduler()

local MsgLockLayer = class("MsgLockLayer",function()
	return display.newLayer()
end)

local TIME_NET_SHOWARN = 1.5  --����ʱ��֮����ʾ��ʾ��
local TOUCHPRIORITY_ALL = -999   --������ȼ������һ�е��

function MsgLockLayer:ctor()
	self:enableNodeEvents()
    self:initView()
	self:initTouch()
end

-- ��ʼ��ͼ
function MsgLockLayer:initView()

end

-- ��ʼ����
function MsgLockLayer:initTouch()
    self.schedule_warn = scheduler:scheduleScriptFunc(handler(self,self.showWaiting), TIME_NET_SHOWARN, false)
end

-- ���볡��
function MsgLockLayer:onEnter()
    self.listener = cc.EventListenerTouchOneByOne:create()
	self.listener:setSwallowTouches(true)
	self.listener:registerScriptHandler(handler(self,self.onTouchBegin),cc.Handler.EVENT_TOUCH_BEGAN)
	self.listener:registerScriptHandler(handler(self,self.onTouchMove),cc.Handler.EVENT_TOUCH_MOVED)
	self.listener:registerScriptHandler(handler(self,self.onTouchEnded),cc.Handler.EVENT_TOUCH_ENDED)
	cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(self.listener,TOUCHPRIORITY_ALL)
end

-- �˳�����
function MsgLockLayer:onExit()
	if self.schedule_warn then
		scheduler:unscheduleScriptEntry(self.schedule_warn)
        self.schedule_warn = nil
	end
    if self.listener then
	    cc.Director:getInstance():getEventDispatcher():removeEventListener(self.listener)
        self.listener = nil
    end
end

-- ������ʼ
function MsgLockLayer:onTouchBegin(touch, event)
	return self:isVisible()
end

-- �����ƶ�
function MsgLockLayer:onTouchMove(touch, event)
	
end

-- ��������
function MsgLockLayer:onTouchEnded(touch, event)
	
end

-- ��ʾ�ȴ�
function MsgLockLayer:showWaiting()
	if self.schedule_warn ~= nil then
		scheduler:unscheduleScriptEntry(self.schedule_warn)
		self.schedule_warn = nil
	end
	local curColorLayer = display.newLayer(cc.c4b(0,0,0,90))
	self:addChild(curColorLayer)
end

return MsgLockLayer
