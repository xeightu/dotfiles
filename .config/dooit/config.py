from dooit.api.theme import DooitThemeBase
from dooit.ui.api import DooitAPI, subscribe
from dooit.ui.api.events import Startup


class CatppuccinLavender(DooitThemeBase):
    _name = "catppuccin-lavender"

    # --- Backgrounds ---
    background1: str = "#1e1e2e"  # $base
    background2: str = "#181825"  # $mantle
    background3: str = "#11111b"  # $crust

    # --- Foregrounds ---
    foreground1: str = "#ffffff"  # $text
    foreground2: str = "#e6e9ef"  # $subtext0
    foreground3: str = "#bcc0cc"  # $overlay0

    # --- Colors ---
    red: str = "#f38ba8"  # $red
    orange: str = "#fab387"  # $orange
    yellow: str = "#f9e2af"  # $yellow
    green: str = "#a6e3a1"  # $green
    blue: str = "#89b4fa"  # $blue
    purple: str = "#cba6f7"  # $mauve
    magenta: str = "#f5c2e7"  # $pink
    cyan: str = "#94e2d5"  # $teal

    # --- Accents ---
    primary: str = "#b4befe"
    secondary: str = "#cba6f7"


@subscribe(Startup)
def setup(api: DooitAPI, _):
    api.css.set_theme(CatppuccinLavender)
