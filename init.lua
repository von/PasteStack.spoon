-- PasteStack spoon
-- Spoon names should use TitleCase
local s = {}

-- Metadata {{{ --
s.name="PasteStack"
s.version="0.2"
s.author="Von Welch"
s.license="Creative Commons Zero v1.0 Universal"
s.homepage="https://github.com/von/PasteStack.spoon"
-- }}} Metadata --

-- Constants {{{ --
s.path = hs.spoons.scriptPath()
-- }}} Constants --

-- Set up logger {{{ --
local log = hs.logger.new("PasteStack")
s.log = log
-- }}} Set up logger --

-- PasteStack:init() {{{ --
--- PasteStack:init(self)
--- Method
--- Initializes a PasteStack
---
--- Parameters:
---  * None
---
--- Returns:
---  * PasteStack object
s.init = function(self)
  self.stack = {}
  return self
end
-- }}} PasteStack:init() --

-- PasteStack:debug() {{{ --
--- PasteStack:debug()
--- Method
--- Enable or disable debugging
---
--- Parameters:
---  * enable - Boolean indicating whether debugging should be on
---
--- Returns:
---  * Nothing
s.debug = function(self, enable)
  if enable then
    self.log.setLogLevel('debug')
    self.log.d("Debugging enabled")
  else
    self.log.d("Disabling debugging")
    self.log.setLogLevel('info')
  end
end
-- }}} PasteStack:debug() --

-- PasteStack:push() {{{ --
--- PasteStack:push()
--- Method
--- Pop last item pushed onto stack into pastebuffer.
--- Does nothing if stack is empty.
---
--- Parameters:
--- * Nothin
---
--- Returns:
--- * Nothing
s.push = function(self)
  self.log.d("Push()")
  table.insert(self.stack, hs.pasteboard.getContents())
end
-- }}} PasteStack:push() --

-- PasteStack:pop() {{{ --
--- PasteStack:pop()
--- Method
--- Push a copy of the current pastebuffer onto the stack.
--- Leaves paste buffer intact.
---
--- Parameters:
--- * Nothin
---
--- Returns:
--- * Nothing
s.pop = function(self)
  if #self.stack == 0 then
    self.log.i("Empty stack")
  else
    self.log.d("Pop()")
    hs.pasteboard.setContents(table.remove(self.stack))
  end
end
-- }}} PasteStack:push() --

-- PasteStack:bindHotKey() {{{ --
--- PasteStack:bindHotKey(self, table)
--- Method
--- The method should accept a single parameter, which is a table.
--- The keys of the table should be strings that describe the
--- action performed by the hotkeys, and the values of the table should be tables
--- containing modifiers and keynames/keycodes. E.g.
---   {
---     push = {{"cmd", "alt"}, "p"},
---     pop = {{"cmd", "alt"}, "P"}
--    }
---
---
--- Parameters:
---  * table - Table of action to key mappings
---
--- Returns:
---  * PasteStack object

s.bindHotKeys = function(self, table)
  for feature,mapping in pairs(table) do
    if feature == "push" then
       self.hotkey = hs.hotkey.bind(mapping[1], mapping[2], s.push)
    elseif feature == "pop" then
       self.hotkey = hs.hotkey.bind(mapping[1], mapping[2], s.pop)
     else
       self.log.wf("Unrecognized key binding feature '%s'", feature)
     end
   end
  return self
end
-- }}} PasteStack:bindHotKey() --

return s
-- vim: foldmethod=marker:
