from dooit.ui.api import DooitAPI, subscribe
from dooit.ui.api.events import Startup
from dooit.api.theme import DooitThemeBase
from dooit.ui.api.widgets import TodoWidget
from rich.style import Style
from dooit_extras.formatters import *
from dooit_extras.bar_widgets import *
from dooit_extras.scripts import *
from rich.text import Text


class DooitThemeCatppuccin(DooitThemeBase):
    _name: str = "dooit-catppuccin"

    # background colors
    background1: str = "#1e1e2e"  # Darkest
    background2: str = "#313244"
    background3: str = "#45475a"  # Lightest

    # foreground colors
    foreground1: str = "#a6adc8"  # Lightest
    foreground2: str = "#bac2de"
    foreground3: str = "#cdd6f4"  # Darkest

    # other colors
    red: str = "#f38ba8"
    orange: str = "#fab387"
    yellow: str = "#f9e2af"
    green: str = "#a6e3a1"
    blue: str = "#89b4fa"
    purple: str = "#b4befe"
    magenta: str = "#f5c2e7"
    cyan: str = "#89dceb"

    # accent colors
    primary: str = purple
    secondary: str = blue


@subscribe(Startup)
def setup_colorscheme(api: DooitAPI, _):
    api.css.set_theme(DooitThemeCatppuccin)


@subscribe(Startup)
def setup_global(api: DooitAPI, _):
    api.vars.always_expand_workspaces = True
    api.vars.always_expand_todos = True


@subscribe(Startup)
def setup_formatters(api: DooitAPI, _):
    fmt = api.formatter
    theme = api.vars.theme

    # ------- WORKSPACES -------
    format = Text(" ({}) ", style=theme.primary).markup
    fmt.workspaces.description.add(description_children_count(format))

    # --------- TODOS ---------
    # status formatter
    fmt.todos.status.add(status_icons(completed="󱓻 ", pending="󱓼 ", overdue="󱓼 "))

    # urgency formatte
    u_icons = {1: "  󰎤", 2: "  󰎧", 3: "  󰎪", 4: "  󰎭"}
    fmt.todos.urgency.add(urgency_icons(icons=u_icons))

    # due formatter
    fmt.todos.due.add(due_casual_format())
    fmt.todos.due.add(due_icon(completed="󱫐 ", pending="󱫚 ", overdue="󱫦 "))

    # effort formatter
    fmt.todos.effort.add(effort_icon(icon="󱠇 "))

    # description formatter
    format = Text("  {completed_count}/{total_count}", style=theme.green).markup
    fmt.todos.description.add(todo_description_progress(fmt=format))
    fmt.todos.description.add(description_highlight_tags(fmt=" {}"))
    fmt.todos.description.add(description_strike_completed())


@subscribe(Startup)
def setup_layout(api: DooitAPI, _):
    api.layouts.todo_layout = [
        TodoWidget.status,
        TodoWidget.effort,
        TodoWidget.description,
        TodoWidget.due,
        TodoWidget.urgency,
    ]


@subscribe(Startup)
def setup_bar(api: DooitAPI, _):
    theme = api.vars.theme

    widgets = [
        TextBox(api, " 󰄛 ", bg=theme.magenta),
        Spacer(api, width=1),
        Mode(api, format_normal=" 󰷸 NORMAL ", format_insert=" 󰛿 INSERT "),
        Spacer(api, width=0),
        StatusIcons(api, bg=theme.background2),
        WorkspaceProgress(api, fmt=" 󰞯 {}% ", bg=theme.secondary),
        Date(api, fmt=" 󰃰 {} "),
    ]
    api.bar.set(widgets)


@subscribe(Startup)
def setup_dashboard(api: DooitAPI, _):
    theme = api.vars.theme

    ascii_art = r"""
                                                    ____
                                         v        _(    )
        _ ^ _                          v         (___(__)
       '_\V/ `
       ' oX`
          X
          X            Help, I can't finish!
          X          -                                      .
          X        \O/                                      |\
          X.a##a.   M                                       |_\
       .aa########a.>>                                 _____|_____
    .a################aa.                              \  DOOIT  /
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
"""

    ascii_art = Text(ascii_art, style=theme.primary)
    ascii_art.highlight_words([" Help, I can't finish! "], style="reverse")
    ascii_art.highlight_words([" DOOIT "], style=theme.secondary)

    header = Text(
        "Welcome again to your daily life, piled with unfinished tasks!",
        style=Style(color=theme.secondary, bold=True, italic=True),
    )

    items = [
        header,
        ascii_art,
        "",
        "",
        Text("Will you finish your tasks today?", style=theme.secondary),
    ]
    api.dashboard.set(items)
