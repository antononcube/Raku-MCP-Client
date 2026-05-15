from mcp.server.fastmcp import FastMCP
from RandomDataGenerators import *

mcp = FastMCP("demo")

@mcp.tool()
def add(a: int, b: int) -> int:
    """
    Add two numbers.

    Args:
        a: First number.
        b: Second number.
    """
    return a + b

@mcp.tool()
def random_words_list(n: int, kind = None ) -> list:
    """
    Generate a list of random words.

    Args:
        n: number of random words do generate.
        kind: kind of word, one of "Any", "Common", "Known", "Stopword".
    """
    kindLocal = kind
    if not isinstance(kind, str):
        kindLocal = None 
    return ["rw:" + x for x in random_word(n, kind = kind)]

@mcp.tool()
def random_pet_names_list(n: int, species = None ) -> list:
    """
    Generate a list of random pet names.

    Args:
        n: number of random pet names do generate.
        species: species, one of "Cat", "Dog", "Goat", "Pig", or Non.
    """
    speciesLocal = species
    if not isinstance(species, str):
        speciesLocal = None 
    return ["rn:" + x for x in random_pet_name(n, species = speciesLocal)]


@mcp.tool()
def random_pretentious_job_title_list(n: int, lang = None ) -> list:
    """
    Generate a list of random pretentious job titles.

    Args:
        n: number of random pretentious job titles.
        lang: language, one of "Bulgarian", "English", or None.
    """
    langLocal = lang
    if not isinstance(lang, str):
        langLocal = None 
    return ["rt:" + x for x in random_pretentious_job_title(n, language = lang)]



mcp.run()