from Katana import Callbacks


def customActionTriggered():

    from PyQt5 import QtWidgets

    info_widget = QtWidgets.QMessageBox()
    info_widget.setText('Custom Action Performance')
    info_widget.exec_()

    return


def onStartupComplete(**kwargs):

    if context.entity.type == "Shot":
        from Katana import UI4, logging, QtWidgets

        log = logging.getLogger("AstrovalidateKatana")

        scene_graph_tab = UI4.App.Tabs.FindTopTab("Scene Graph")
        if not scene_graph_tab:
            scene_graph_tab = UI4.App.Tabs.CreateTab("Scene Graph")

        if not scene_graph_tab:
            log.error("Unable to get 'Scene Graph' tab")
            return

        scene_graph_view = scene_graph_tab.getSceneGraphView()
        if not scene_graph_view:
            log.error("Unable to get sceneGraphView from 'Scene Graph' tab")
            return

        original_context_menu_event_callback = (
            scene_graph_view._SceneGraphView__bridge._BridgeImpl__viewLink._TreeWidgetViewLink__userContextMenuEventCallback
        )
        if not original_context_menu_event_callback:
            log.error(
                "Unable to get originalContextMenuEventCallback from 'Scene Graph' tab"
            )
            return

        def CustomContextMenuEventCallback(
            contextMenuEvent,
            menu,
            originalContextMenuEventCallback=original_context_menu_event_callback,
        ):

            open_scenes_menu = QtWidgets.QMenu("Custom Menu", menu)
            menu.addMenu(open_scenes_menu)

            open_scenes_menu.addAction(
                "Custom Action", customActionTriggered
            )

            originalContextMenuEventCallback(contextMenuEvent, menu)

        scene_graph_view.setContextMenuEventCallback(
            CustomContextMenuEventCallback
        )


Callbacks.addCallback(Callbacks.Type.onStartupComplete, onStartupComplete)
