local M = class("GamePlayer")

M.initInfo = {userid=0, nickname="", gold=0, sex=1, seat=0, ip="", leave=false, headimgurl="", room_card=0, vote=false}

function M:ctor()
	self:clear()
end

function M:clear()
	self.players = {}
	self.main_player = {}
end

function M:getPlayerCount()
	-- body
	local size = 0 
	for _,v in pairs(self.players) do 
		size =  size + 1 
	end 
	return size
end

function M:getLocalSeat(ser_seat)
	if ser_seat <= 0 then
		return 1
	end
	
	local curValue = (ser_seat + G_GameDefine.nMaxPlayerCount - self.main_player.seat) % G_GameDefine.nMaxPlayerCount + 1
	local t = {
		ser_seat = ser_seat,
		max = G_GameDefine.nMaxPlayerCount,
		main = self.main_player.seat,
		curValue = curValue
	}
	return curValue
end

function M:getServerSeat(nLocalSeat)
    if nLocalSeat == 1 then
        return self.main_player.seat
    end

	local curValue = (nLocalSeat + self.main_player.seat - 1) % G_GameDefine.nMaxPlayerCount
	return curValue ~= 0 and curValue or G_GameDefine.nMaxPlayerCount
end

function M:getMainPlayer()
	return self.main_player
end

function M:getPlayerByUserId(userid)
	for _,p in pairs(self.players) do
		if p.userid == userid then
			return p
		end
	end
	return nil
end

function M:getPlayerBySeverSeat(ser_seat)
	for _,p in pairs(self.players) do
		if p.seat == ser_seat then
			return p
		end
	end
	return nil
end

function M:getPlayerBySeat(seat)
	local ser_seat = self:getServerSeat(seat)
	return self:getPlayerBySeverSeat(ser_seat)
end

function M:isPlayerByUserId(userid)
	return getPlayerByUserId(userid) ~= nil
end

function M:addPlayerInfo(p, main)
	for _,v in pairs(self.players) do
		if v.userid == p.userid then
			table.merge(v, p)
			return true
		end
	end

	local t = {}
	table.merge(t,M.initInfo)
	table.merge(t,p)
	if main then
		self.main_player = t
	end

	self.players[p.userid] = t
	return true
end

return M
