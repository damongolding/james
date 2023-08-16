
try:
    import requests
    from PIL import Image
    from pydantic import BaseModel
    from rich import print as p

    p(f"\n\n[white bold on green] SUCCESS [/] All tests passed\n\n")
except ImportError as e:
    class bcolors:
        HEADER = '\033[95m'
        OKBLUE = '\033[94m'
        OKCYAN = '\033[96m'
        OKGREEN = '\033[92m'
        WARNING = '\033[93m'
        FAIL = '\033[91m'
        ENDC = '\033[0m'
        BOLD = '\033[1m'
        UNDERLINE = '\033[4m'

    print(f"\n\n{bcolors.FAIL}ERROR: {e}{bcolors.ENDC}\n\n")



