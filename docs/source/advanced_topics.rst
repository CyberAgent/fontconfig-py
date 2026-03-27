Advanced Topics
===============

For more control over font matching and configuration, use the low-level API
with :py:class:`Config`, :py:class:`Pattern`, and :py:class:`ObjectSet`.

Font Matching
-------------

Find the best matching font for a given pattern::

   import fontconfig

   # Get current fontconfig configuration
   config = fontconfig.Config.get_current()

   # Create a pattern for the desired font
   pattern = fontconfig.Pattern.create()
   pattern.add("family", "Arial")
   pattern.add("weight", 200)  # Bold weight
   pattern.add("slant", 0)     # Roman (not italic)

   # Apply default substitutions
   pattern.default_substitute()
   config.substitute(pattern)

   # Find the best match
   matched = config.font_match(pattern)
   if matched:
       print(f"Matched font: {matched.get('file')}")
       print(f"Family: {matched.get('family')}")
       print(f"Style: {matched.get('style')}")

Font Sorting
------------

Get a sorted list of fonts matching a pattern::

   import fontconfig

   config = fontconfig.Config.get_current()
   pattern = fontconfig.Pattern.parse(":family=Arial")
   pattern.default_substitute()

   # Get sorted list of matching fonts
   font_set = config.font_sort(pattern, trim=True)
   if font_set:
       for i in range(len(font_set)):
           font = font_set[i]
           print(f"{i+1}. {font.get('family')} - {font.get('file')}")

List Fonts with Specific Properties
------------------------------------

Use :py:class:`ObjectSet` to specify which properties to retrieve::

   import fontconfig

   config = fontconfig.Config.get_current()

   # Create a pattern
   pattern = fontconfig.Pattern.parse(":lang=en")

   # Specify which properties to retrieve
   object_set = fontconfig.ObjectSet.create()
   object_set.add("family")
   object_set.add("style")
   object_set.add("file")
   object_set.add("slant")
   object_set.add("weight")

   # List all matching fonts
   fonts = config.font_list(pattern, object_set)
   for i in range(len(fonts)):
       font = fonts[i]
       print(f"Family: {font.get('family')}")
       print(f"Style: {font.get('style')}")
       print(f"Weight: {font.get('weight')}")
       print("---")

Working with Patterns
---------------------

:py:class:`Pattern` objects can be created, modified, and parsed.

Understanding Pattern Syntax
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Patterns use a colon-separated format to specify font properties. The general
syntax is::

   :property1=value1:property2=value2:property3=value3

**Key rules**:

- Start with a colon ``:``
- Separate properties with colons
- Use ``=`` between property name and value
- Separate multiple values for the same property with commas
- No spaces (spaces are treated as part of values)

Pattern Examples
~~~~~~~~~~~~~~~~

Common pattern formats::

   import fontconfig

   # Simple pattern
   font = fontconfig.match(":family=Arial")

   # Multiple properties
   font = fontconfig.match(":family=Arial:weight=200:slant=100")

   # Multiple values (fallback list for family)
   font = fontconfig.match(":family=Helvetica,Arial,sans-serif")

   # Boolean values
   font = fontconfig.match(":family=Arial:antialias=True")

   # Numeric values
   font = fontconfig.match(":family=Arial:size=12.0:pixelsize=16")

   # String values with spaces (avoid if possible)
   font = fontconfig.match(":family=Noto Sans")  # Works but be careful

Property Value Types
~~~~~~~~~~~~~~~~~~~~

Different properties accept different value types:

**String properties** (family, style, file, etc.)::

   ":family=Arial"
   ":style=Bold"

**Integer properties** (weight, slant, spacing, etc.)::

   ":weight=200"  # Bold
   ":slant=100"   # Italic

**Double properties** (size, pixelsize, aspect, etc.)::

   ":size=12.0"
   ":pixelsize=16.5"

**Boolean properties** (antialias, hinting, outline, etc.)::

   ":antialias=True"
   ":hinting=False"

Pattern Strings vs Properties Dict
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You can specify font properties in two ways:

**1. Pattern strings** (fontconfig native format)::

   font = fontconfig.match(":family=Arial:weight=200")

**Advantages**:

- Compact and readable for simple queries
- Native fontconfig syntax
- Can copy/paste from ``fc-match`` command line

**Disadvantages**:

- Easy to make syntax errors
- Harder to build dynamically
- Requires string formatting for variables

**2. Properties dictionary** (Python dict)::

   font = fontconfig.match(properties={
       "family": "Arial",
       "weight": 200
   })

**Advantages**:

- Type-safe and IDE-friendly
- Easy to build programmatically
- Clear and Pythonic
- Less error-prone

**Disadvantages**:

- Slightly more verbose

**Best Practice**: Use properties dict for programmatic queries, pattern strings
for simple hardcoded queries.

Example: Building patterns dynamically::

   import fontconfig

   # Dynamic pattern building
   def find_font(family, bold=False, italic=False):
       properties = {"family": family}

       if bold:
           properties["weight"] = 200
       if italic:
           properties["slant"] = 100

       return fontconfig.match(properties=properties)

   # Easy to use
   regular = find_font("Arial")
   bold = find_font("Arial", bold=True)
   bold_italic = find_font("Arial", bold=True, italic=True)

Common Pattern Mistakes
~~~~~~~~~~~~~~~~~~~~~~~~

Avoid these common errors::

   # ❌ WRONG: Missing initial colon
   fontconfig.match("family=Arial")

   # ✅ CORRECT
   fontconfig.match(":family=Arial")

   # ❌ WRONG: Using comma between different properties
   fontconfig.match(":family=Arial,weight=200")

   # ✅ CORRECT: Comma only for multiple values of SAME property
   fontconfig.match(":family=Arial,Helvetica:weight=200")

   # ❌ WRONG: Spaces around separators
   fontconfig.match(": family = Arial : weight = 200")

   # ✅ CORRECT: No spaces
   fontconfig.match(":family=Arial:weight=200")

   # ❌ WRONG: Invalid property name (typo)
   fontconfig.match(":famly=Arial")  # Will be ignored silently

   # ✅ CORRECT: Use dict to catch typos
   fontconfig.match(properties={"family": "Arial"})

Creating and Modifying Patterns
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Pattern objects support creation, modification, and parsing::

   import fontconfig

   # Create from scratch
   pattern = fontconfig.Pattern.create()
   pattern.add("family", "Arial")
   pattern.add("size", 12.0)
   pattern.add("antialias", True)

   # Parse from string
   pattern = fontconfig.Pattern.parse(":family=Arial:size=12:antialias=True")

   # Get properties
   family = pattern.get("family")
   size = pattern.get("size")

   # Remove properties
   pattern.remove("size")

   # Convert back to string
   pattern_str = pattern.unparse()
   print(pattern_str)

   # Format pattern with custom template
   formatted = pattern.format("%{family} %{style}")
   print(formatted)

Configuration Management
------------------------

Access fontconfig configuration directories and files::

   import fontconfig

   config = fontconfig.Config.get_current()

   # Get configuration directories
   print("Config directories:", config.get_config_dirs())
   print("Font directories:", config.get_font_dirs())
   print("Config files:", config.get_config_files())
   print("Cache directories:", config.get_cache_dirs())

   # Get available fonts
   system_fonts = config.get_fonts("system")
   app_fonts = config.get_fonts("application")

   print(f"System fonts: {len(system_fonts)}")
   print(f"Application fonts: {len(app_fonts)}")

Configuring fontconfig
----------------------

If fontconfig does not return a font you expect, it may not be in any of the
configured font search paths. fontconfig is configured via XML files, typically
located in:

- ``~/.config/fontconfig/fonts.conf`` (user-level, Linux/macOS)
- ``/etc/fonts/local.conf`` or ``/etc/fonts/conf.d/`` (system-level)

To add a custom font directory, create or edit ``~/.config/fontconfig/fonts.conf``::

   <?xml version="1.0"?>
   <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
   <fontconfig>
     <dir>/path/to/your/fonts</dir>
   </fontconfig>

After editing the configuration, rebuild the font cache::

   fc-cache -f

You can verify the new directory is scanned by checking ``get_font_dirs()``::

   import fontconfig
   config = fontconfig.Config.get_current()
   print(config.get_font_dirs())

For the full reference on fontconfig configuration — including aliases, rules,
substitutions, and per-application settings — see the
`fontconfig user documentation <https://www.freedesktop.org/software/fontconfig/fontconfig-user.html>`_.

Working with Character Sets
----------------------------

:py:class:`CharSet` represents the set of Unicode characters supported by a font.
This is useful for checking whether a font can display specific text or for
filtering fonts by character coverage.

What is CharSet?
~~~~~~~~~~~~~~~~

A CharSet is a boolean array indicating which Unicode codepoints are present in
a font. When you need to:

- Check if a font supports specific characters
- Find fonts that can render a given string
- Filter fonts by Unicode range (e.g., only fonts with Cyrillic)

You'll work with CharSet objects.

Creating CharSets
~~~~~~~~~~~~~~~~~

Create CharSets from strings or codepoint lists::

   import fontconfig

   # Create from string
   charset = fontconfig.CharSet.from_string("Hello, World!")
   print(f"Character count: {len(charset)}")

   # Create from Unicode codepoints
   charset = fontconfig.CharSet.from_codepoints([0x41, 0x42, 0x43])  # A, B, C

   # Create empty and add characters
   charset = fontconfig.CharSet.create()
   charset.add('A')
   charset.add(0x42)  # Add by codepoint
   charset.add('C')

   print(f"Contains: {len(charset)} characters")

Checking Character Membership
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Check if specific characters are in a CharSet::

   import fontconfig

   charset = fontconfig.CharSet.from_string("Hello")

   # Check with 'in' operator
   if 'H' in charset:
       print("Has H")

   if 'Z' not in charset:
       print("Does not have Z")

   # Check by codepoint
   if 0x48 in charset:  # 0x48 = 'H'
       print("Has H (by codepoint)")

   # Iterate over all codepoints
   print("Characters in charset:")
   for codepoint in charset:
       char = chr(codepoint)
       print(f"  U+{codepoint:04X} = '{char}'")

Finding Fonts for Specific Text
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Find fonts that can render a given string by checking character support::

   import fontconfig

   def find_fonts_for_text(text, max_results=10):
       """Find fonts that support all characters in the text."""
       # Create charset from text
       required_chars = fontconfig.CharSet.from_string(text)

       # Get all system fonts
       all_fonts = fontconfig.list(select=("family", "file", "charset"))

       # Filter fonts that support all required characters
       compatible_fonts = []
       for font in all_fonts:
           if 'charset' not in font:
               continue

           font_charset = font['charset']

           # Check if font supports all characters
           all_supported = all(char in font_charset for char in text)
           if all_supported:
               compatible_fonts.append(font)
               if len(compatible_fonts) >= max_results:
                   break

       return compatible_fonts

   # Example: Find fonts for Chinese text
   chinese_text = "你好世界"
   fonts = find_fonts_for_text(chinese_text)

   print(f"Fonts that support '{chinese_text}':")
   for font in fonts:
       print(f"  {font['family']}")

   # Example: Find fonts for mathematical symbols
   math_text = "∑∫∂∇"
   fonts = find_fonts_for_text(math_text, max_results=5)

   print(f"\nFonts that support math symbols:")
   for font in fonts:
       print(f"  {font['family']}")

**Performance Note**: Checking character support for every font in the system
can be slow. For better performance, filter by language first::

   # More efficient: Filter by language first
   japanese_fonts = fontconfig.list(
       properties={"lang": ["ja"]},
       select=("family", "file", "charset")
   )

   # Then check character support within filtered results
   text = "こんにちは"
   for font in japanese_fonts:
       if 'charset' in font:
           charset = font['charset']
           if all(char in charset for char in text):
               print(f"Compatible: {font['family']}")

Getting Font CharSets
~~~~~~~~~~~~~~~~~~~~~~

Access the charset property from font patterns::

   import fontconfig

   # Get charset from matched font
   font = fontconfig.match(":family=Arial")
   if 'charset' in font:
       charset = font['charset']
       print(f"Font supports {len(charset)} characters")

       # Check specific character support
       if 'é' in charset:
           print("Supports accented characters")

       if '中' in charset:
           print("Supports Chinese characters")

   # List fonts with their character counts
   fonts = fontconfig.list(select=("family", "charset"))

   for font in fonts[:20]:  # First 20
       if 'charset' in font:
           count = len(font['charset'])
           print(f"{font['family']}: {count} characters")
