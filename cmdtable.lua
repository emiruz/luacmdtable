local dec = {}

function dec.conj(...)
   local p = {...}
   return function(state)
      for _,f in pairs(p) do
	 if f(state) == false then
	    return false
	 end
      end
      return true
   end
end

function dec.disc(...)
   local p = {...}
   return function(state)
      for _,f in pairs(p) do
	 if f(state) then
	    return true
	 end
      end
      return false
   end
end

function dec.neg(f)
   return function(state)
      return not f(state)
   end
end

function dec.init(state)
   local t = {cmds = {},
	      state = (state or {})}
   setmetatable(t, {__index = dec})
   return t
end

function dec.cmd(self,f,...)
   if type(f) ~= "function" then
      error("f(state) function expected as first argument")
   end
   local cond = {...}
   table.insert(self.cmds, {f=f, conds=cond })
   return self
end

function dec.exec(self)
   local all,exec=true,{}
   for i = 1, #self.cmds do
      local cmd = self.cmds[i]
      if cmd.f ~= nil then
	 all = true
	 for j = 1, #cmd.conds do
	    cond = cmd.conds[j]
	    if not cond(self.state) then
	       all = false
	       break
	    end
	 end
	 if all then
	    table.insert(exec, cmd)
	 end
      end
   end
   for i=1,#exec do
      exec[i].f(self.state)
   end
   return #exec
end

return dec
