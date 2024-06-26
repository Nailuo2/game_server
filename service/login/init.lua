--登录服务，用于处理登录逻辑的服务，比如账号校验。
local skynet = require "skynet"
local s = require "service"
local mysql = require "skynet.db.mysql"
local redis = require "skynet.db.redis"

s.client = {}
s.resp.client = function(source, fd, cmd, msg)--client是用来封装处理服务器功能的，这样可以便于之后拓展处理客户端信息的功能
    if s.client[cmd] then
        local ret_msg = s.client[cmd]( fd, msg, source)
        skynet.send(source, "lua", "send_by_fd", fd, ret_msg)
    else
        skynet.error("s.resp.client fail", cmd)
    end
end

--可以再封装一个注册功能
s.client.register = function(fd, msg, source)
	local playerid = msg[2]
	local pw = msg[3]
	local gate = source
    --校验用户名密码--这里调用mysql数据库，根据playerid获取密码

	local resp_db = db:query("select * from player where name = '"..playerid.."'");
	--打印存储结果
	--if resp_db.err then print("打印存储结果") end	
	if resp_db[1] ~= nil then
		return {"register", 1, "账号已存在"}
	end
	local insert = db:query("INSERT INTO player (name, password, coin) VALUES ('"..playerid.."', '".. pw.."', 0);")
	return {"register",1,"注册成功"}
end



s.client.login = function(fd, msg, source)--处理登录请求
	local playerid = msg[2]
	local pw = msg[3]
	local gate = source
	node = skynet.getenv("node")--获取当前节点信息
    --校验用户名密码--这里调用mysql数据库，根据playerid获取密码

	local check_pwd = rds:get(playerid.."_password") --查询redis缓存
	if not check_pwd then
		local resp_db = db:query("select * from player where name = '"..playerid.."'") --没有则查询mysql
		if resp_db[1] == nil then
			return {"login", 1, "账号不存在"}
		end
		if pw ~= resp_db[1].password then
			rds:set(playerid.."_password",resp_db[1].password) --有账号那就把密码存入缓存
			return {"login", 1, "密码错误"}
		end
	else --如果缓存存在，那么查看密码是否匹配
		if pw ~= check_pwd then
			return {"login", 1, "密码错误"}
		end
	end

	--发给agentmgr
	local isok, agent = skynet.call("agentmgr", "lua", "reqlogin", playerid, node, gate)--call为阻塞调用
	if not isok then
		return {"login", 1, "请求mgr失败"}
	end
	--回应gate
	local isok = skynet.call(gate, "lua", "sure_agent", fd, playerid, agent)--call为阻塞调用
	if not isok then
		return {"login", 1, "gate注册失败"}
	end
    skynet.error("login succ "..playerid)
    return {"login", 0, "登陆成功"}
end

function s.init()
    db = mysql.connect({
        host="127.0.0.1",
        port=3306,
        database="game_server",
        user="root",
        password="123456",
        max_packet_size = 1024 * 1024,
        on_connect = nil
    })
    rds = redis.connect({ auth = "123456", db = 1, host = "127.0.0.1", port = 6379})

end

s.start(...)

