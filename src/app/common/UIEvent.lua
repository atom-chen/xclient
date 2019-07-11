local M = class("UIEvent")

function M:ctor()
 	self.tEvent = {}
end

function M:add(e, LayerName)
    if self.tEvent.LayerName == nil then
        self.tEvent.LayerName = {}
    end
    if self.tEvent.LayerName[e] then
        print("waring UIEvent multiple registration")
        return 
    end
    if e.addClickEventListener then 
		e:addClickEventListener(function()
			self:post(e, LayerName)
		end)
	end
    self.tEvent.LayerName[e] = 
    {
        object = e,
        --time,         -- ͬ��ť����ʱ��,Ĭ��nil,�޴���ʱ��ȴ�
        --layertime,    -- ͬ��δ���ʱ��,Ĭ��nil,�޴���ʱ��ȴ�,ͬΪ"N"���,��ťa,b,��ťa��Ӧ��,b����ȴ�layertime�ſ���Ӧb
    }
end

function M:del(LayerName)
	self.tEvent.LayerName = nil
end

function M:post(e, LayerName)
    if not self.tEvent.LayerName then
        return 
    end
    local t = self.tEvent.LayerName[e]
    if not t then
        return 
    end
    local nTime = os.time()
    if e.time then
        if t.time ~= nil then
            if t.time + e.time > nTime then
                return
            end
        end
    end
    if e.layertime then
        if t.layertime ~= nil then
            if t.layertime + e.layertime > nTime then
                return
            end
        end
    end
	if e.call then
		e.call()
	end
    t.time = nTime
    t.layertime = nTime
end

return M
