extends Control

func setup(coroutine: GDScriptFunctionState):
	$PopupDialog.popup_centered()
	coroutine.connect("completed", self, "coroutine_ended")
	return coroutine

func coroutine_ended():
	queue_free()