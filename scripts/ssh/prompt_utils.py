"""Interactive prompt utilities."""

from colorama import Fore, Style


def confirm(prompt: str, default: bool = False) -> bool:
    """Ask user for confirmation.

    Args:
        prompt: The prompt text (without [y/N])
        default: Default value if user just presses enter

    Returns:
        True if user confirmed, False otherwise
    """
    suffix = " [Y/n] " if default else " [y/N] "
    response = input(f"{Fore.YELLOW}{prompt}{suffix}{Style.RESET_ALL}").strip().lower()
    if not response:
        return default
    return response == "y"


def select_option(prompt: str, options: list[str]) -> str:
    """Present numbered options and return user's choice.

    Args:
        prompt: The prompt text
        options: List of option descriptions

    Returns:
        Selected option number as string
    """
    print(f"{Fore.YELLOW}{prompt}{Style.RESET_ALL}")
    for i, opt in enumerate(options, 1):
        print(f"  {Fore.CYAN}{i}.{Style.RESET_ALL} {opt}")
    return input(f"{Fore.YELLOW}Select: {Style.RESET_ALL}").strip()
