----------------------------------------------------------------------
-- A customizable toolbar that can be useful in touch-like devices
-- (e.g. on a Microsoft Surface).
--
-- Feel free to add new commands and modify it as you want.
----------------------------------------------------------------------

local dlg = Dialog("Layer Touch Toolbar")
dlg
  :button{text="Layer+",onclick=function() app.command.DuplicateLayer() end}
  :button{text="Layer[+]",onclick=function() app.command.NewLayer() end}
  :button{text="Layer-",onclick=function() app.command.RemoveLayer() end}
  :button{text="\\Layer/",onclick=function() app.command.MergeDownLayer() end}
  :button{text="[Show]",onclick=function() app.command.ShowLayerEdges() end}
  :newrow()
  :button{text="Frame+",onclick=function() app.command.NewFrame() end}
  :button{text="Frame[+]",onclick=function() app.command.NewFrame{content="empty"} end}
  :button{text="Frame-",onclick=function() app.command.RemoveFrame() end}
  :button{text="<",onclick=function() app.command.GotoPreviousFrame() end}
  :button{text=">",onclick=function() app.command.GotoNextFrame() end}
  :show{wait=false}