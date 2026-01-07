from kitty.boss import Boss

def main(args: list[str]) -> str:
    pass

from kittens.tui.handler import result_handler

@result_handler(no_ui=True)
def handle_result(args: list[str], answer: str, target_window_id: int, boss: Boss) -> None:
    tab = boss.active_tab
    if tab is None:
        return

    # 查找是否有 overlay 窗口（通过标记识别）
    for window in tab.windows:
        if window.user_vars.get('is_overlay') == 'true':
            boss.close_window(window)
            return

    # 没有 overlay，创建一个新的
    boss.call_remote_control(None, ('launch', '--type=overlay', '--var', 'is_overlay=true', '--cwd=current'))
