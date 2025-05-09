Attract-Mode Plus Frontend
==========================

Layout and Plug-in Programming Reference
----------------------------------------
Functions and parameters unique to Plus are marked with 🔶 sign.

Contents
--------
   * [Overview](#overview)
   * [Squirrel Language](#squirrel)
   * [Language Extensions](#squirrel_ext)
   * [Frontend Binding](#binding)
   * [Magic Tokens](#magic)
   * [User Config](#userconfig)
   * [Functions](#functions)
      * [`fe.add_image()`](#add_image)
      * [`fe.add_artwork()`](#add_artwork)
      * [`fe.add_surface()`](#add_surface)
      * [`fe.add_clone()`](#add_clone)
      * [`fe.add_text()`](#add_text)
      * [`fe.add_listbox()`](#add_listbox)
      * [`fe.add_rectangle()`](#add_rectangle) 🔶
      * [`fe.add_shader()`](#add_shader)
      * [`fe.add_sound()`](#add_sound)
      * [`fe.add_music()`](#add_music) 🔶
      * [`fe.add_ticks_callback()`](#add_ticks_callback)
      * [`fe.add_transition_callback()`](#add_transition_callback)
      * [`fe.game_info()`](#game_info)
      * [`fe.get_art()`](#get_art)
      * [`fe.get_input_state()`](#get_input_state)
      * [`fe.get_input_pos()`](#get_input_pos)
      * [`fe.signal()`](#signal)
      * [`fe.set_display()`](#set_display)
      * [`fe.add_signal_handler()`](#add_signal_handler)
      * [`fe.remove_signal_handler()`](#remove_signal_handler)
      * [`fe.do_nut()`](#do_nut)
      * [`fe.load_module()`](#load_module)
      * [`fe.plugin_command()`](#plugin_command)
      * [`fe.plugin_command_bg()`](#plugin_command_bg)
      * [`fe.path_expand()`](#path_expand)
      * [`fe.path_test()`](#path_test)
      * [`fe.get_file_mtime()`](#get_file_mtime) 🔶
      * [`fe.get_config()`](#get_config)
      * [`fe.get_text()`](#get_text)
      * [`fe.get_url()`](#get_url) 🔶
      * [`fe.log()`](#log) 🔶
   * [Objects and Variables](#objects)
      * [`fe.ambient_sound`](#ambient_sound)
      * [`fe.layout`](#layout)
      * [`fe.list`](#list)
      * [`fe.image_cache`](#image_cache)
      * [`fe.overlay`](#overlay)
      * [`fe.obj`](#obj)
      * [`fe.displays`](#displays)
      * [`fe.filters`](#filters)
      * [`fe.monitors`](#monitors)
      * [`fe.script_dir`](#script_dir)
      * [`fe.script_file`](#script_file)
      * [`fe.module_dir`](#module_dir)
      * [`fe.nv`](#nv)
   * [Classes](#classes)
      * [`fe.LayoutGlobals`](#LayoutGlobals)
      * [`fe.CurrentList`](#CurrentList)
      * [`fe.ImageCache`](#ImageCache)
      * [`fe.Overlay`](#Overlay)
      * [`fe.Display`](#Display)
      * [`fe.Filter`](#Filter)
      * [`fe.Monitor`](#Monitor)
      * [`fe.Image`](#Image)
      * [`fe.Text`](#Text)
      * [`fe.ListBox`](#ListBox)
      * [`fe.Rectangle`](#Rectangle) 🔶
      * [`fe.Sound`](#Sound)
      * [`fe.Music`](#Music) 🔶
      * [`fe.Shader`](#Shader)
   * [Constants](#constants)

&nbsp;
<a name="overview"></a>

Overview
--------

The Attract-mode layout sets out what gets displayed to the user. Layouts
consist of a `layout.nut` script file and a collection of related resources
(images, other scripts, etc.) used by the script.

Layouts are stored under the "layouts" subdirectory of the Attract-Mode
config directory.  Each layout is stored in its own separate subdirectory or
archive file (Attract-Mode can read layouts and plugins directly from .zip,
.7z, .rar, .tar.gz, .tar.bz2 and .tar files).

Each layout can have one or more `layout*.nut` script files.  The "Toggle
Layout" command in Attract-Mode allows users to cycle between each of the
`layout*.nut` script files located in the layout's directory.  Attract-Mode
remembers the last layout file toggled to for each layout and will go back
to that same file the next time the layout is loaded.  This allows for
variations of a particular layout to be implemented and easily selected by
the user (for example, a layout could provide a `layout.nut` for horizontal
monitor orientations and a `layout-vert.nut` for vertical).

The Attract-Mode screen saver and intro modes are really just special case
layouts.  The screensaver gets loaded after a user-configured period of
inactivity, while the intro mode gets run when the frontend first starts and
exits as soon as any action is triggered (for example if the user hits the
select button).  The screen saver script is located in the `screensaver.nut`
file stored in the "screensaver" subdirectory.  The intro script is located
in the `intro.nut` file stored in the "intro" subdirectory.

Plug-ins are similar to layouts in that they consist of at least one squirrel
script file and a collection of related resources.  Plug-ins are stored in the
"plugins" subdirectory of the Attract-Mode config directory.  Plug-ins can be a
single ".nut" file stored in this subdirectory.  They can also have their own
separate subdirectory or archive file (in which case the script itself needs to
be in a file called `plugin.nut`).

&nbsp;
<a name="squirrel"></a>

Squirrel Language
-----------------

Attract-Mode's layouts are scripts written in the Squirrel programming
language.  Squirrel's standard "Blob", "IO", "Math", "String" and "System"
library functions are available for use in a script. For more information on
programming in Squirrel and using its standard libraries, consult the Squirrel
manuals:

   * [Squirrel 3.0 Reference Manual][SQREFMAN]
   * [Squirrel 3.0 Standard Library Manual][SQLIBMAN]

[SQREFMAN]: http://www.squirrel-lang.org/doc/squirrel3.html
[SQLIBMAN]: http://www.squirrel-lang.org/doc/sqstdlib3.html

Also check out the Introduction to Squirrel on the Attract-Mode wiki:
https://github.com/mickelson/attract/wiki/Introduction-to-Squirrel-Programming

&nbsp;
<a name="squirrel_ext"></a>

Language Extensions
-------------------

Attract-Mode includes the following home-brewed extensions to the squirrel
language and standard libraries:

   * A `zip_extract_archive( zipfile, filename )` function that will open a
     specified `zipfile` archive file and extract `filename` from it, returning
     the contents as a squirrel blob.
   * A `zip_get_dir( zipfile )` function that will return an array of the
     filenames contained in the `zipfile` archive file.

Supported archive formats are: .zip, .7z, .rar, .tar.gz, .tar.bz2 and .tar

&nbsp;
<a name="binding"></a>

Frontend Binding
----------------

All of the functions, objects and classes that Attract-Mode exposes to
Squirrel are arranged under the `fe` table, which is bound to Squirrel's
root table.

Example:
```` squirrel
fe.add_image( "bg.png", 0, 0 );
local marquee = fe.add_artwork( "marquee", 256, 20, 512, 256 );
marquee.set_rgb( 100, 100, 100 );
````

The remainder of this document describes the functions, objects, classes
and constants that are exposed to layout and plug-in scripts.

&nbsp;
<a name="magic"></a>

Magic Tokens
----------------

Image names, as well as the messages displayed by Text and Listbox objects, can
all contain one or more "Magic Tokens".  Magic tokens are enclosed in square
brackets, and the frontend automatically updates them accordingly as the user
navigates the frontend.  So for example, a Text message set to
"[Manufacturer]" will be automatically updated with the appropriate
Manufacturer's name.  There are more examples below.

   * The following magic tokens are currently supported:
      - `[DisplayName]` - the name of the current display
      - `[ListSize]` - the number of items in the game list
      - `[ListEntry]` - the number of the current selection in the game list
      - `[FilterName]` - the name of the filter
      - `[Search]` - the search rule currently applied to the game list
      - `[SortName]` - the attribute that the list was sorted by
      - `[Name]` - the short name of the selected game
      - `[Title]` - the full name of the selected game
      - `[Emulator]` - the emulator to use for the selected game
      - `[CloneOf]` - the short name of the game that the selection is a
        clone of
      - `[Year]` - the year for the selected game
      - `[Manufacturer]` - the manufacturer for the selected game
      - `[Category]` - the category for the selected game
      - `[Players]` - the number of players for the selected game
      - `[Rotation]` - the rotation for the selected game
      - `[Control]` - the primary control for the selected game
      - `[Status]` - the emulation status for the selected game
      - `[DisplayCount]` - the number of displays for the selected game
      - `[DisplayType]` - the display type for the selected game
      - `[AltRomname]` - the alternative Romname for the selected game
      - `[AltTitle]` - the alternative title for the selected game
      - `[PlayedTime]` - the amount of time the selected game has been
        played
      - `[PlayedCount]` - the number of times the selected game has been
        played
      - `[SortValue]` - the value used to order the selected game in the
        list
      - `[System]` - the first "System" name configured for the selected
        game's emulator
      - `[SystemN]` - the last "System" name configured for the selected
        game's emulator
      - `[Overview]` - the overview description for the selected game
   * Magic tokens can also be used to run a function defined in your layout
     or plugin's squirrel script to obtain the desired text.  These tokens are
     in the form `[!<function_name>]`.  When used, Attract-Mode will run the
     corresponding function (defined in the squirrel "root table").  This
     function should then return the string value that you wish to have
     replace the magic token.  The function defined in squirrel can optionally
     have up to two parameters passed to it.  If it is defined with a first
     parameter, Attract-Mode will supply the appropriate index_offset in that
     parameter  when it calls the function.  If a second parameter is present
     as well, the appropriate filter_offset is supplied.

Examples:
```` squirrel
// Add a text that displays the filter name and list location
//
fe.add_text( "[FilterName] [[ListEntry]/[ListSize]]",
		0, 0, 400, 20 );

// Add an image that will match to the first word in the
// Manufacturer name (i.e. "Atari.png", "Nintendo.jpg")
//
function strip_man( ioffset )
{
	local m = fe.game_info(Info.Manufacturer,ioffset);
	return split( m, " " )[0];
}
fe.add_image( "[!strip_man]", 0, 0 );

// Add a text that will display a copyright message if both
// the manufacturer name and a year are present.  Otherwise,
// just show the Manufacturer name.
//
function well_formatted()
{
	local m = fe.game_info( Info.Manufacturer );
	local y = fe.game_info( Info.Year );

	if (( m.len() > 0 ) && ( y.len() > 0 ))
		return "Copyright " + y + ", " + m;

	return m;
}
fe.add_text( "[!well_formatted]", 0, 0 );
````

&nbsp;
<a name="userconfig"></a>

User Config
-----------

Configuration settings can be added to a layout/plugin/screensaver/intro to
provide users with customization options.

Configurations are defined by a `UserConfig` class at the top of your script, where
each property is an individual setting. Properties should be prefixed
with an `</ attribute />` that describes how they are displayed, and their
values can be retrieved using [`fe.get_config()`](#get_config).

```` squirrel
class UserConfig </ help="Description" /> {
    </ label="Choice", order=1, options="Yes,No" /> opt = "Yes";
    </ label="String", order=2 /> val = "Default";
}

local config = fe.get_config();
// config = { opt = "Yes", val = "Default" }
````

Attribute Properties:

   * label - [string] Text for the setting list item, if omitted the
	  property id is used.
   * help - [string] The message to display in the footer when the setting is
	  selected.
   * order - [integer] The list order of the setting.
   * per_display - [boolean] When true the setting value will be unique to
	  each display.

The attribute may use **one** of the following properties to define its type:

   * options - [string] Present the user with a choice, for example:
	  `"Yes,No"`.
   * is_input - [boolean] Prompt the user to press a key.
   * is_function - [boolean] Call the function named by the property, for
	  example: `func = "callback"`.
   * is_info - [boolean] A readonly setting used for headings or separators.
   * (None of the above) - A text input for keyboard entry.

Setting function format:

```` squirrel
// The config parameter contains the fe.get_config() table
function callback(config)
{
	// The returned string is displayed in the footer
	return "Success";
}
````

&nbsp;
<a name="functions"></a>

Functions
---------

<a name="add_image"></a>
#### `fe.add_image()` ####

    fe.add_image( name )
    fe.add_image( name, x, y )
    fe.add_image( name, x, y, w, h )

Adds an image or video to the end of Attract-Mode's draw list.

[Magic Tokens](#magic) can be used in the supplied "name", in which case
Attract-Mode will dynamically update the image in response to navigation.

The default blend mode for images is `BlendMode.Alpha`

Parameters:

   * name - the name of an image/video file to show.  If a relative path is
     provided (i.e. "bg.png") it is assumed to be relative to the current
     layout directory (or the plugin directory, if called from  a plugin
     script).  If a relative path is provided and the layout/plugin is
     contained in an archive, Attract-Mode will open the corresponding file
     stored inside of the archive.  Supported image formats are: PNG, JPEG,
     GIF, BMP and TGA.  Videos can be in any format supported by FFmpeg.  One
     or more "Magic Tokens" can be used in the name, in which case Attract-Mode
     will automatically update the image/video file appropriately in response
     to user navigation.  For example "man/[Manufacturer]" will load
     the file corresponding to the manufacturer's name from the man
     subdirectory of the layout/plugin (example: "man/Konami.png"). When
     Magic Tokens are used, the file extension specified in `name` is ignored
     (if present) and Attract-Mode will load any supported media file that
     matches the Magic Token.  See [Magic Tokens](#magic) for more info.
   * x - the x coordinate of the top left corner of the image (in layout
     coordinates).
   * y - the y coordinate of the top left corner of the image (in layout
     coordinates).
   * w - the width of the image (in layout coordinates).  Image will be
     scaled accordingly.  If set to 0 image is left unscaled.  Default value
     is 0.
   * h - the height of the image (in layout coordinates).  Image will be
     scaled accordingly.  If set to 0 image is left unscaled.  Default value
     is 0.

Return Value:

   * An instance of the class [`fe.Image`](#Image) which can be used to
     interact with the added image/video.

&nbsp;
<a name="add_artwork"></a>

#### `fe.add_artwork()` ####

    fe.add_artwork( label )
    fe.add_artwork( label, x, y )
    fe.add_artwork( label, x, y, w, h )

Add an artwork to the end of Attract-Mode's draw list.  The image/video
displayed in an artwork is updated automatically whenever the user changes
the game selection.

The default blend mode for artwork is `BlendMode.Alpha`

Parameters:

   * label - the label of the artwork to display.  This should correspond
     to an artwork configured in Attract-Mode (artworks are configured per
     emulator in the config menu) or scraped using the scraper.  Attract-
     Mode's standard artwork labels are: "snap", "marquee", "flyer", "wheel",
     and "fanart".
   * x - the x coordinate of the top left corner of the artwork (in layout
     coordinates).
   * y - the y coordinate of the top left corner of the artwork (in layout
     coordinates).
   * w - the width of the artwork (in layout coordinates).  Artworks will be
     scaled accordingly.  If set to 0 artwork is left unscaled.  Default
     value is 0.
   * h - the height of the artwork (in layout coordinates).  Artworks will be
     scaled accordingly.  If set to 0 artwork is left unscaled.  Default
     value is 0.

Return Value:

   * An instance of the class [`fe.Image`](#Image) which can be used to
     interact with the added artwork.

&nbsp;
<a name="add_surface"></a>

#### `fe.add_surface()` ####

    fe.add_surface( w, h )
    fe.add_surface( x, y, w, h ) 🔶

Add a surface to the end of Attract-Mode's draw list.  A surface is an off-
screen texture upon which you can draw other image, artwork, text, listbox
and surface objects.  The resulting texture is treated as a static image by
Attract-Mode which can in turn have image effects applied to it (scale,
position, pinch, skew, shaders, etc) when it is drawn.

The default blend mode for surfaces is `BlendMode.Premultiplied`

Parameters:

   * x - the x coordinate of the top left corner of the surface (in layout
     coordinates).
   * y - the y coordinate of the top left corner of the surface (in layout
     coordinates).
   * w - the width of the surface texture (in pixels).
   * h - the height of the surface texture (in pixels).

Return Value:

   * An instance of the class [`fe.Image`](#Image) which can be used to
     interact with the added surface.

&nbsp;
<a name="add_clone"></a>

#### `fe.add_clone()` ####

    fe.add_clone( img )

Clone an image, artwork or surface object and add the clone to the back
of Attract-Mode's draw list.  The texture pixel data of the original and
clone is shared as a result.

Parameters:

   * img - the image, artwork or surface object to clone.  This needs to
     be an instance of the class `fe.Image`.

Return Value:

   * An instance of the class [`fe.Image`](#Image) which can be used to
     interact with the added clone.

&nbsp;
<a name="add_text"></a>

#### `fe.add_text()` ####

    fe.add_text( msg, x, y, w, h )

Add a text label to the end of Attract-Mode's draw list.

[Magic Tokens](#magic) can be used in the supplied "msg", in which case
Attract-Mode will dynamically update the msg in response to navigation.

Parameters:

   * msg - the text to display.  Magic tokens can be used here, see
     [Magic Tokens](#magic) for more information.
   * x - the x coordinate of the top left corner of the text (in layout
     coordinates).
   * y - the y coordinate of the top left corner of the text (in layout
     coordinates).
   * w - the width of the text (in layout coordinates).
   * h - the height of the text (in layout coordinates).

Return Value:

   * An instance of the class [`fe.Text`](#Text) which can be used to
     interact with the added text.

&nbsp;
<a name="add_listbox"></a>

#### `fe.add_listbox()` ####

    fe.add_listbox( x, y, w, h )

Add a listbox to the end of Attract-Mode's draw list.

Parameters:

   * x - the x coordinate of the top left corner of the listbox (in layout
     coordinates).
   * y - the y coordinate of the top left corner of the listbox (in layout
     coordinates).
   * w - the width of the listbox (in layout coordinates).
   * h - the height of the listbox (in layout coordinates).

Return Value:

   * An instance of the class [`fe.ListBox`](#ListBox) which can be used to
     interact with the added text.

&nbsp;
<a name="add_rectangle"></a>

#### `fe.add_rectangle()` 🔶 ####

    fe.add_rectangle( x, y, w, h )

Add a rectangle to the end of Attract-Mode's draw list.

Parameters:

   * x - the x coordinate of the top left corner of the rectangle (in layout
     coordinates).
   * y - the y coordinate of the top left corner of the rectangle (in layout
     coordinates).
   * w - the width of the rectangle (in layout coordinates).
   * h - the height of the rectangle (in layout coordinates).

Return Value:

   * An instance of the class [`fe.Rectangle`](#Rectangle) which can be used to
     interact with the added rectangle.

&nbsp;
<a name="add_shader"></a>

#### `fe.add_shader()` ####

    fe.add_shader( type, file1, file2 )
    fe.add_shader( type, file1 )
    fe.add_shader( type )

Add a GLSL shader (vertex and/or fragment) for use in the layout.

Parameters:

   * type - the type of shader to add.  Can be one of the following values:
      - `Shader.VertexAndFragment` - add a combined vertex and fragment shader
      - `Shader.Vertex` - add a vertex shader
      - `Shader.Fragment` - add a fragment shader
      - `Shader.Empty` - add an empty shader.  An object's shader property can
        be set to an empty shader to stop using a shader on that object where
        one was set previously.

   * file1 - the name of the shader file located in the layout/plugin directory.
     For the VertexAndFragment type, this should be the vertex shader.
   * file2 - This parameter is only used with the VertexAndFragment type, and
     should be the name of the fragment shader file located in the layout/
     plugin directory.

Return Value:

   * An instance of the class [`fe.Shader`](#Shader) which can be used to
     interact with the added shader.

#### Implementation notes for GLSL shaders in Attract-Mode: ####

Shaders are implemented using the SFML API.  For more information please see:
http://www.sfml-dev.org/tutorials/2.1/graphics-shader.php

The minimal vertex shader expected is as follows:

```` glsl
void main()
{
  // transform the vertex position
  gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;

  // transform the texture coordinates
  gl_TexCoord[0] = gl_TextureMatrix[0] * gl_MultiTexCoord0;

  // forward the vertex color
  gl_FrontColor = gl_Color;
}
````

The minimal fragment shader expected is as follows:

```` glsl
uniform sampler2D texture;

void main()
{
  // lookup the pixel in the texture
  vec4 pixel = texture2D(texture, gl_TexCoord[0].xy);

  // multiply it by the color
  gl_FragColor = gl_Color * pixel;
}
````

&nbsp;
<a name="add_sound"></a>

#### `fe.add_sound()` ####

    fe.add_sound( name )

Add a sound file that can then be played by Attract-Mode.
For short sounds, stored in RAM. For playing long audio tracks use [`fe.add_music()`](#add_music)

Parameters:

   * name - the name of the sound file.  If a relative path is provided,
     it is treated as relative to the directory for the layout/plugin that
     called this function.

Return Value:

   * An instance of the class [`fe.Sound`](#Sound) which can be used to
     interact with the sound.

&nbsp;
<a name="add_music"></a>

#### `fe.add_music()` 🔶 ####

    fe.add_music( name )

Add an audio track that can then be played by Attract-Mode.
For long audio tracks, streamed from disk. For playing short sounds use [`fe.add_sound()`](#add_sound)

Parameters:

   * name - the name of the audio track file.  If a relative path is provided,
     it is treated as relative to the directory for the layout/plugin that
     called this function.

Return Value:

   * An instance of the class [`fe.Music`](#Music) which can be used to
     interact with the sound.

&nbsp;
<a name="add_ticks_callback"></a>

#### `fe.add_ticks_callback()` ####

    fe.add_ticks_callback( environment, function_name )
    fe.add_ticks_callback( function_name )

Register a function in your script to get "tick" callbacks.  Tick callbacks
occur continuously during the running of the frontend.  The function that is
registered should be in the following form:

    function tick( tick_time )
    {
       // do stuff...
    }

The single parameter passed to the tick function is the amount of time (in
milliseconds) since the layout began.

Parameters:

   * environment - the squirrel object that the function is associated with
     (default value: the root table of the squirrel vm)
   * function_name - a string naming the function to be called.

Return Value:

   * None.

&nbsp;
<a name="add_transition_callback"></a>

#### `fe.add_transition_callback()` ####

    fe.add_transition_callback( environment, function_name )
    fe.add_transition_callback( function_name )

Register a function in your script to get transition callbacks.  Transition
callbacks are triggered by certain events in the frontend.  The function
that is registered should be in the following form:

    function transition( ttype, var, transition_time )
    {
       local redraw_needed = false;

       // do stuff...

       if ( redraw_needed )
          return true;

       return false;
    }

The `ttype` parameter passed to the transition function indicates what is
happening.  It will have one of the following values:

   * `Transition.StartLayout`
   * `Transition.EndLayout`
   * `Transition.ToNewSelection`
   * `Transition.FromOldSelection`
   * `Transition.ToGame`
   * `Transition.FromGame`
   * `Transition.ToNewList`
   * `Transition.EndNavigation`
   * `Transition.ShowOverlay`
   * `Transition.HideOverlay`
   * `Transition.NewSelOverlay`
   * `Transition.ChangedTag`

The value of the `var` parameter passed to the transition function depends
upon the value of `ttype`:

   * When `ttype` is `Transition.ToNewSelection`, `var` indicates the index
     offset of the selection being transitioned to (i.e. -1 when moving back
     one position in the list, 1 when moving forward one position, 2 when
     moving forward two positions, etc.)

   * When `ttype` is `Transition.FromOldSelection`, `var` indicates the index
     offset of the selection being transitioned from (i.e. 1 after moving back
     one position in the list, -1 after moving forward one position, -2 after
     moving forward two positions, etc.)

   * When `ttype` is `Transition.StartLayout`, `var` will be one of the
     following:
      - `FromTo.Frontend` if the frontend is just starting,
      - `FromTo.ScreenSaver` if the layout is starting (or the list is being
        loaded) because the built-in screen saver has stopped, or
      - `FromTo.NoValue` otherwise.

   * When `ttype` is `Transition.EndLayout`, `var` will be:
      - `FromTo.Frontend` if the frontend is shutting down,
      - `FromTo.ScreenSaver` if the layout is stopping because the built-in
        screen saver is starting, or
      - `FromTo.NoValue` otherwise.

   * When `ttype` is `Transition.ToNewList`, `var` indicates the filter index
     offset of the filter being transitioned to (i.e. -1 when moving back one
     filter, 1 when moving forward) if known, otherwise `var` is 0.

   * When `ttype` is `Transition.ShowOverlay`, var will be:
      - `Overlay.Custom` if a script generated overlay is being shown
      - `Overlay.Exit` if the exit menu is being shown
      - `Overlay.Favourite` if the add/remove favourite menu is being shown
      - `Overlay.Displays` if the displays menu is being shown
      - `Overlay.Filters` if the filters menu is being shown
      - `Overlay.Tags` if the tags menu is being shown

   * When `ttype` is `Transition.NewSelOverlay`, var will be the index of the
     new selection in the Overlay menu.

   * When `ttype` is `Transition.ChangedTag`, var will be `Info.Favourite` if
     the favourite status of the current game was changed, and `Info.Tags` if
     a tag for the current game was changed.

   * When `ttype` is `Transition.ToGame`, `Transition.FromGame`,
     `Transition.EndNavigation`, or `Transition.HideOverlay`, `var` will be
     `FromTo.NoValue`.

The `transition_time` parameter passed to the transition function is the
amount of time (in milliseconds) since the transition began.

The transition function must return a boolean value.  It should return
`true` if a redraw is required, in which case Attract-Mode will redraw the
screen and immediately call the transition function again with an updated
`transition_time`.

**The transition function must eventually return `false` to notify
Attract-Mode that the transition effect is done, allowing the normal
operation of the frontend to proceed.**

Parameters:

   * environment - the squirrel object that the function is associated with
     (default value: the root table of the squirrel vm)
   * function_name - a string naming the function to be called.

Return Value:

   * None.

&nbsp;
<a name="game_info"></a>

#### `fe.game_info()` ####

    fe.game_info( id )
    fe.game_info( id, index_offset )
    fe.game_info( id, index_offset, filter_offset )

Get information about the selected game.

Parameters:

   * id - id of the information attribute to get.  Can be one of the
     following values:
      - `Info.Name`
      - `Info.Title`
      - `Info.Emulator`
      - `Info.CloneOf`
      - `Info.Year`
      - `Info.Manufacturer`
      - `Info.Category`
      - `Info.Players`
      - `Info.Rotation`
      - `Info.Control`
      - `Info.Status`
      - `Info.DisplayCount`
      - `Info.DisplayType`
      - `Info.AltRomname`
      - `Info.AltTitle`
      - `Info.Extra`
      - `Info.Favourite`
      - `Info.Tags`
      - `Info.PlayedCount`
      - `Info.PlayedTime`
      - `Info.FileIsAvailable`
      - `Info.System`
      - `Info.Overview`
      - `Info.IsPaused`
      - `Info.SortValue`
   * index_offset - the offset (from the current selection) of the game to
     retrieve info on.  i.e. -1=previous game, 0=current game, 1=next game...
     and so on.  Default value is 0.
   * filter_offset - the offset (from the current filter) of the filter
     containing the selection to retrieve info on.  i.e. -1=previous filter,
     0=current filter.  Default value is 0.

Return Value:

   * A string containing the requested information.

Notes:

   * The `Info.IsPaused` attribute is `1` if the game is currently paused by
     the frontend, and an empty string if it is not.

&nbsp;
<a name="get_art"></a>

#### `fe.get_art()` ####

    fe.get_art( label )
    fe.get_art( label, index_offset )
    fe.get_art( label, index_offset, filter_offset )
    fe.get_art( label, index_offset, filter_offset, flags )

Get the filename of an artwork for the selected game.

Parameters:

   * label - the label of the artwork to retrieve.  This should correspond
     to an artwork configured in Attract-Mode (artworks are configured per
     emulator in the config menu) or scraped using the scraper.  Attract-
     Mode's standard artwork labels are: "snap", "marquee", "flyer", "wheel",
     and "fanart".
   * index_offset - the offset (from the current selection) of the game to
     retrieve the filename for.  i.e. -1=previous game, 0=current game,
     1=next game...  and so on.  Default value is 0.
   * filter_offset - the offset (from the current filter) of the filter
     containing the selection to retrieve the filename for.  i.e.
     -1=previous filter, 0=current filter.  Default value is 0.
   * flags - flags to control the filename that gets returned.  Can be set
     to any combination of none or more of the following (i.e. `Art.ImagesOnly
     | Art.FullList`):
      - `Art.Default` - return single match, video or image
      - `Art.ImagesOnly` - Override Art.Default, only return an image match (no
        video)
      - `Art.FullList` - Return a full list of the matches made (if multiples
        available).  Names are returned in a single string, semicolon separated

Return Value:

   * A string containing the filename of the requested artwork.  If no file
     is found, an empty string is returned.  If the artwork is contained in
     an archive, then both the archive path and the internal path are returned,
     separated by a pipe `|` character: "<archive_path>|<content_path>"

&nbsp;
<a name="get_input_state"></a>

#### `fe.get_input_state()` ####

    fe.get_input_state( input_id )

Check if a specific keyboard key, mouse button, joystick button or joystick
direction is currently pressed, or check if any input mapped to a particular
frontend action is pressed.

Parameter:

   * input_id - [string] the input to test.  This can be a string in the same
     format as used in the attract.cfg file for input mappings.  For example,
     "LControl" will check the left control key, "Joy0 Up" will check the up
     direction on the first joystick, "Mouse MiddleButton" will check the
     middle mouse button, and "select" will check for any input mapped to the
     game select button.

Return Value:

   * `true` if input is pressed, `false` otherwise.

&nbsp;
<a name="get_input_pos"></a>

#### `fe.get_input_pos()` ####

    fe.get_input_pos( input_id )

Return the current position for the specified joystick axis.

Parameter:

   * input_id - [string] the input to test.  The format of this string
     is the same as that used in the attract.cfg file.  For example,
     "Joy0 Up" is the up direction on the first joystick, "Mouse Up" is the
	  y position of the mouse, and "Mouse WheelUp" is the delta of an upward
	  mouse wheel scroll.

Return Value:

   * Current position of the specified axis, in range [0..100].

&nbsp;
<a name="signal"></a>

#### `fe.signal()` ####

    fe.signal( signal_str )

Signal that a particular frontend action should occur.

Parameters:

   * signal_str - the action to signal for.  Can be one of the
     following strings:
      - "back"
      - "up"
      - "down"
      - "left"
      - "right"
      - "select"
      - "prev_game"
      - "next_game"
      - "prev_page"
      - "next_page"
      - "prev_display"
      - "next_display"
      - "displays_menu"
      - "prev_filter"
      - "next_filter"
      - "filters_menu"
      - "toggle_layout"
      - "toggle_movie"
      - "toggle_mute"
      - "toggle_rotate_right"
      - "toggle_flip"
      - "toggle_rotate_left"
      - "exit"
      - "exit_to_desktop"
      - "screenshot"
      - "configure"
      - "random_game"
      - "replay_last_game"
      - "add_favourite"
      - "prev_favourite"
      - "next_favourite"
      - "add_tags"
      - "screen_saver"
      - "prev_letter"
      - "next_letter"
      - "intro"
      - "custom1"
      - "custom2"
      - "custom3"
      - "custom4"
      - "custom5"
      - "custom6"
      - "custom7"
      - "custom8"
      - "custom9"
      - "custom10"
      - "reset_window"
      - "reload"


Return Value:

   * None.

&nbsp;
<a name="set_display"></a>

#### `fe.set_display()` ####

    fe.set_display( index, stack_previous, reload ) 🔶
    fe.set_display( index, stack_previous )
    fe.set_display( index )

Change to the display at the specified index.  This should align with the
index of the fe.displays array that contains the intended display.

Parameters:

   * index - The index of the display to change to.  This should correspond to
   the index in the fe.displays array of the intended new display.  The index for
   the current display is stored in `fe.list.display_index`.
   * stack_previous - [boolean] if set to `true`, the new display is stacked on
   the current one, so that when the user selects the "Back" UI button the frontend
   will navigate back to the earlier display.  Default value is `false`.
   * reload 🔶 [boolean] if set to `false` and the current display shares the same
   layout file the layout is not reloaded. Default value is `true`.


Return Value:

   * None.

&nbsp;
<a name="add_signal_handler"></a>

#### `fe.add_signal_handler()` ####


    fe.add_signal_handler( environment, function_name )
    fe.add_signal_handler( function_name )

Register a function in your script to handle signals.  Signals are sent
whenever a mapped control is used by the user or whenever a layout or
plugin script uses the [`fe.signal()`](#signal) function.  The function
that is registered should be in the following form:

    function handler( signal_str )
    {
       local no_more_processing = false;

       // do stuff...

       if ( no_more_processing )
          return true;

       return false;
    }

The `signal_str` parameter passed to the handler function is a string
that identifies the signal that has been given.  This string will
correspond to the `signal_str` parameter values of [`fe.signal()`](#signal)

The signal handler function should return a boolean value.  It should
return `true` if no more processing should be done on this signal.
It should return `false` if signal processing is to continue, in which
case this signal will be dealt with in the default manner by the
frontend.

Parameters:

   * environment - the squirrel object that the function is associated with
     (default value: the root table of the squirrel vm)
   * function_name - a string naming the signal handler function to
     be added.

Return Value:

   * None.

&nbsp;
<a name="remove_signal_handler"></a>

#### `fe.remove_signal_handler()` ####

    fe.remove_signal_handler( environment, function_name )
    fe.remove_signal_handler( function_name )

Remove a signal handler that has been added with the
[`fe.add_signal_handler()`](#add_signal_handler) function.

Parameters:

   * environment - the squirrel object that the signal handler function
     is associated with (default value: the root table of the squirrel vm)
   * function_name - a string naming the signal handler function to
     remove.

Return Value:

   * None.

&nbsp;
<a name="do_nut"></a>

#### `fe.do_nut()` ####

    fe.do_nut( name )

Execute another Squirrel script.

Parameters:

   * name - the name of the script file.  If a relative path is provided,
     it is treated as relative to the directory for the layout/plugin that
     called this function.

Return Value:

   * None.

&nbsp;
<a name="load_module"></a>

#### `fe.load_module()` ####

    fe.load_module( name )

Loads a module (a "library" Squirrel script).

Parameters:

   * name - the name of the library module to load.  This should
     correspond to a script file in the "modules" subdirectory of your
     Attract-Mode configuration (without the file extension).

Return Value:

   * `true` if the module was loaded, `false' if it was not found.

&nbsp;
<a name="plugin_command"></a>

#### `fe.plugin_command()` ####

    fe.plugin_command( executable, arg_string )
    fe.plugin_command( executable, arg_string, environment, callback_function )
    fe.plugin_command( executable, arg_string, callback_function )

Execute a plug-in command and wait until the command is done.

Parameters:

   * executable - the name of the executable to run.
   * arg_string - the arguments to pass when running the executable.
   * environment - the squirrel object that the callback function
     is associated with.
   * callback_function - a string containing the name of the function in
     Squirrel to call with any output that the executable provides on stdout.
     The function should be in the following form:
     ```
     function callback_function( op )
     {
     }
     ```
     If provided, this function will get called repeatedly with chunks of the
     command output in `op`.

Return Value:

   * None.

Notes:

   * `op` is not necessarily aligned with the start and the end of the lines of
     output from the command.  In any one call `op` may contain data from
     multiple lines and that may begin or end in the middle of a line.

&nbsp;
<a name="plugin_command_bg"></a>

#### `fe.plugin_command_bg()` ####

    fe.plugin_command_bg( executable, arg_string )

Execute a plug-in command in the background and return immediately.

Parameters:

   * executable - the name of the executable to run.
   * arg_string - the arguments to pass when running the executable.

Return Value:

   * None.

&nbsp;
<a name="path_expand"></a>

#### `fe.path_expand()` ####

    fe.path_expand( path )

Expand the given path name.  A leading `~` or `$HOME` token will be become
the user's home directory.  On Windows systems, a leading `%SYSTEMROOT%`
token will become the path to the Windows directory and a leading
`%PROGRAMFILES%` or `%PROGRAMFILESx86%` will become the path to the
applicable Windows "Program Files" directory.

Parameters:

   * path - the path string to expand.

Return Value:

   * The expansion of path.

&nbsp;
<a name="path_test"></a>

#### `fe.path_test()` ####

    fe.path_test( path, flag )

Check whether the specified path has the status indicated by `flag`.

Parameters:

   * path - the path to test.
   * flag - What to test for.  Can be one of the following values:
      - `PathTest.IsFileOrDirectory`
      - `PathTest.IsFile`
      - `PathTest.IsDirectory`
      - `PathTest.IsRelativePath`
      - `PathTest.IsSupportedArchive`
      - `PathTest.IsSupportedMedia`

Return Value:

   * (boolean) result.

&nbsp;
<a name="get_file_mtime"></a>

#### `fe.get_file_mtime()` 🔶 ####

    fe.get_file_mtime( filename )

Returns the modified time of the given file.

Parameters:

   * filename - the file to get the modified time of.

Return Value:

   * An integer containing the GMT timestamp.

&nbsp;
<a name="get_config"></a>

#### `fe.get_config()` ####

Get the user configured settings for this layout/plugin/screensaver/intro.

Parameters:

   * None.

Return Value:

   * A table containing the [User Config](#userconfig) settings.

Notes:
   * This function will *not* return valid settings when called from a
     callback function registered with fe.add_ticks_callback(),
     fe.add_transition_callback() or fe.add_signal_handler()

&nbsp;
<a name="get_text"></a>

#### `fe.get_text()` ####

    fe.get_text( text )

Translate the specified text into the user's language.  If no translation is
found, then return the contents of `text`.

Parameters:

   * text - the text string to translate.

Return Value:

   * A string containing the translated text.

&nbsp;
<a name="get_url"></a>

#### `fe.get_url()` 🔶 ####

    fe.get_url( url, file_path )

Download a file from provided url address. When `file_path` is relative the file
will be saved to the layout's folder.

Parameters:

   * url - an internet address of the file to download.
   * file_path - a destination folder set as an absolute path,
     or a relative path inside the layout's folder

&nbsp;
<a name="log"></a>

#### `fe.log()` 🔶 ####

    fe.log( text )

Print a string into the console. It's an alternative to Squirrel `print()` function, which does not always show up immediately.

Parameters:

   * string - a string of text to print in the console

&nbsp;
<a name="objects"></a>

Objects and Variables
---------------------

<a name="ambient_sound"></a>

#### `fe.ambient_sound` ####

`fe.ambient_sound` is an instance of the `fe.Music` class and can be used to
control the ambient audio track.

&nbsp;
<a name="layout"></a>

#### `fe.layout` ####

`fe.layout` is an instance of the `fe.LayoutGlobals` class and is where
global layout settings are stored.

&nbsp;
<a name="list"></a>

#### `fe.list` ####

`fe.list` is an instance of the `fe.CurrentList` class and is where current
display settings are stored.

&nbsp;
<a name="image_cache"></a>

#### `fe.image_cache` ####

`fe.image_cache` is an instance of the `fe.ImageCache` class and provides script
access to Attract-Mode's internal image cache.

&nbsp;
<a name="overlay"></a>

#### `fe.overlay` ####

`fe.overlay` is an instance of the `fe.Overlay` class and is where overlay
functionality may be accessed.

&nbsp;
<a name="obj"></a>

#### `fe.obj` ####

`fe.obj` contains the Attract-Mode draw list.  It is an array of `fe.Image`,
`fe.Text`, `fe.ListBox` and `fe.Rectangle` instances.

&nbsp;
<a name="displays"></a>

#### `fe.displays` ####

`fe.displays` contains information on the available displays.  It is an array
of `fe.Display` instances.

&nbsp;
<a name="filters"></a>

#### `fe.filters` ####

`fe.filters` contains information on the available filters.  It is an array
of `fe.Filter` instances.

&nbsp;
<a name="monitors"></a>

#### `fe.monitors` ####

`fe.monitors` is an array of `fe.Monitor` instances, and provides the
mechanism for interacting with the various monitors in a multi-monitor setup.
There will always be at least one entry in this list, and the first entry
will always be the "primary" monitor.

&nbsp;
<a name="script_dir"></a>

#### `fe.script_dir` ####

When Attract-Mode runs a layout or plug-in script, `fe.script_dir` is set to
the layout or plug-in's directory.

&nbsp;
<a name="script_file"></a>

#### `fe.script_file` ####

When Attract-Mode runs a layout or plug-in script, `fe.script_file` is set to
the name of the layout or plug-in script file.

&nbsp;
<a name="module_dir"></a>

#### `fe.module_dir` ####

When Attract-Mode runs a module script, `fe.module_dir` is set to
the module's directory.

&nbsp;
<a name="nv"></a>

#### `fe.nv` ####

The fe.nv table can be used by layouts and plugins to store persistent values.
The values in this table get saved by Attract-Mode whenever the layout changes
and are saved to disk when Attract-Mode is shut down.  Boolean, integer, float,
string, array and table values can be stored in this table.

&nbsp;
<a name="classes"></a>

Classes
-------

<a name="LayoutGlobals"></a>

#### `fe.LayoutGlobals` ####

This class is a container for global layout settings.  The instance of this
class is the `fe.layout` object.  This class cannot be otherwise instantiated
in a script.

Properties:

   * `width` - Get/set the layout width.  Default value is `ScreenWidth`.
   * `height` - Get/set the layout height.  Default value is `ScreenHeight`.
   * `font` - Get/set the filename of the font which will be used for
     text and listbox objects in this layout.
   * `base_rotation` - Get the base orientation of Attract Mode which is set
     in General Settings. This property cannot be set from the script.
     This can be one of the following values:
      - `RotateScreen.None` (default)
      - `RotateScreen.Right`
      - `RotateScreen.Flip`
      - `RotateScreen.Left`
   * `toggle_rotation` - Get/set the "toggle" orientation of the layout.
     The toggle rotation is added to the rotation set in general settings
     to determine what the actual rotation is at any given time.
     The user can change this value using the Rotation Toggle inputs.
     This can be one of the following values:
      - `RotateScreen.None` (default)
      - `RotateScreen.Right`
      - `RotateScreen.Flip`
      - `RotateScreen.Left`
   * `page_size` - Get/set the number of entries to jump each time the "Next
     Page" or "Previous Page" button is pressed.
   * `preserve_aspect_ratio` - Get/set whether the overall layout aspect ratio
     should be preserved by the frontend.  Default value is false.
   * `time` - Get the number of milliseconds that the layout has been showing.
   * `mouse_pointer` 🔶 When set to true mouse pointer will be visible.

Member Functions:

   * `redraw()` 🔶 Adds the ability to process tick() and redraw the screen
     during computationally intensive loops in transition and signal callbacks.
     DO NOT call this function inside tick() callback. It will result in
     an infinite loop and the frontend will crash.

Notes:

   * The actual rotation of the layout can be determined using the following
     equation: `( fe.layout.base_rotation + fe.layout.toggle_rotation ) % 4`

&nbsp;
<a name="CurrentList"></a>

#### `fe.CurrentList` ####

This class is a container for status information regarding the current display.
The instance of this class is the `fe.list` object.  This class cannot be
otherwise instantiated in a script.

Properties:

   * `name` - Get the name of the current display.
   * `display_index` - Get the index of the current display.  Use the
     `fe.set_display()` function if you want to change the current display.
     If this value is less than 0, then the 'Displays Menu' (with a custom
     layout) is currently showing.
   * `filter_index` - Get/set the index of the currently selected filter.
     (see `fe.filters` for the list of available filters).
   * `index` - Get/set the index of the currently selected game.
   * `search_rule` - Get/set the search rule applied to the current game list.
     If you set this and the resulting search finds no results, then the
     current game list remains displayed in its entirety.  If there are
     results, then those results are shown instead, until search_rule is
     cleared or the user navigates away from the display/filter.
   * `size` - Get the size of the current game list.  If a search rule has
     been applied, this will be the number of matches found (if > 0)
   * `clones_list` 🔶 Returns 'true' if the current list contains game clones.

&nbsp;
<a name="ImageCache"></a>

#### `fe.ImageCache` ####

This class is a container for Attract-Mode's internal image cache.  The
instance of this class is the `fe.image_cache` object.  This class cannot be
otherwise instantiated in a script.

Properties:

   * `count` - Get the number of images currently in the cache.
   * `size` - Get the current size of the image cache (in bytes).
   * `max_size` - Get the (user configured) maximum size of the image cache
      (in bytes).
   * `bg_load` - Get/set whether images are to be loaded on a background thread.
      Setting to true might make Attract-Mode animations smoother, but can cause a
      slight flicker as images get loaded.  Default value is false.

Member Functions:

   * `add_image( filename )` - Add `filename` image to the internal cache and/or
     flag it as "most recently used".  Least recently used images are cleared from
     the cache first when space is needed.  If filename is contained in an
     archive, the parameter should be formatted: "<archive_name>|<filename>"
   * `name_at( pos )` - Return the name of the image at position `pos` in the internal
     cache.  `pos` can be an integer between 0 and fe.image_cache.count-1.
   * `size_at( pos )` - Return the size (in bytes) of the image at position `pos` in
     the internal cache.  `pos` can be an integer between 0 and fe.image_cache.count-1

&nbsp;
<a name="Overlay"></a>

#### `fe.Overlay` ####

This class is a container for overlay functionality.  The instance of this
class is the `fe.overlay` object.  This class cannot be otherwise instantiated
in a script.

Properties:

   * `is_up` - Get whether the overlay is currently being displayed (i.e. config
     mode, etc).

Member Functions:

   * `set_custom_controls( caption_text, options_listbox )`
   * `set_custom_controls( caption_text )`
   * `set_custom_controls()` - tells the frontend that the layout will provide
     custom controls for displaying overlay menus such as the exit dialog,
     displays menu, etc.  The `caption_text` parameter is the FeText object
     that the frontend end should use to display the overlay caption (i.e.
     "Exit Attract-Mode?").  The `options_listbox` parameter is the FeListBox
     object that the frontend should use to display the overlay options.
   * `clear_custom_controls()` - tell the frontend that the layout will NOT
     do any custom control handling for overlay menus.  This will result in
     the frontend using its built-in default menus instead for overlays.
   * `list_dialog( options, title, default_sel, cancel_sel )`
   * `list_dialog( options, title, default_sel )`
   * `list_dialog( options, title )`
   * `list_dialog( options )` - The list_dialog function prompts the user with
     a menu containing a list of options, returning the index of the selection.
     The `options` parameter is an array of strings that are the menu options
     to display in the list.  The `title` parameter is a caption for the list.
     `default_sel` is the index of the entry to be selected initially (default
     is 0).  `cancel_sel` is the index to return if the user cancels (default
     is -1).  The return value is the index selected by the user.
   * `edit_dialog( msg, text )` - Prompt the user to input/edit text.  The
     `msg` parameter is the prompt caption.  `text` is the initial text to be
     edited.  The return value a the string of text as edited by the user.
   * `splash_message( msg, replace, footer_msg )`
   * `splash_message( msg, replace )`
   * `splash_message( msg )` - immediately provide text feedback to the user.
     This could be useful during computationally-intensive operations.
     The `msg` parameter may contain a `$1` placeholder that gets replaced by `replace`.
     The `footer_msg` text is displayed in the footer.

&nbsp;
<a name="Display"></a>

#### `fe.Display` ####

This class is a container for information about the available displays.
Instances of this class are contained in the `fe.displays` array.  This class
cannot otherwise be instantiated in a script.

Properties:

   * `name` - Get the name of the display.
   * `layout` - Get the layout used by this display.
   * `romlist` - Get the romlist used by this display.
   * `in_cycle` - Get whether the display is shown in the prev display/next
     display cycle.
   * `in_menu` - Get whether the display is shown in the "Displays Menu"

&nbsp;
<a name="Filter"></a>

#### `fe.Filter` ####

This class is a container for information about the available filters.
Instances of this class are contained in the `fe.filters` array.  This class
cannot otherwise be instantiated in a script.

Properties:

   * `name` - Get the filter name.
   * `index` - Get the index of the currently selected game in this filter.
   * `size` - Get the size of the game list in this filter.
   * `sort_by` - Get the attribute that the game list has been sorted by.
     Will be equal to one of the following values:
      - `Info.NoSort`
      - `Info.Name`
      - `Info.Title`
      - `Info.Emulator`
      - `Info.CloneOf`
      - `Info.Year`
      - `Info.Manufacturer`
      - `Info.Category`
      - `Info.Players`
      - `Info.Rotation`
      - `Info.Control`
      - `Info.Status`
      - `Info.DisplayCount`
      - `Info.DisplayType`
      - `Info.AltRomname`
      - `Info.AltTitle`
      - `Info.Extra`
      - `Info.Favourite`
      - `Info.Tags`
      - `Info.PlayedCount`
      - `Info.PlayedTime`
      - `Info.FileIsAvailable`
   * `reverse_order` - [bool] Will be equal to true if the list order has been
     reversed.
   * `list_limit` - Get the value of the list limit applied to the filter game
     list.

&nbsp;
<a name="Monitor"></a>

#### `fe.Monitor` ####

This class represents a monitor in Attract-Mode, and provides the interface
to the extra monitors in a multi-monitor setup.  Instances of this class are
contained in the `fe.monitors` array.  This class cannot otherwise be
instantiated in a script.

Properties:

   * `num` - Get the monitor number.
   * `width` - Get the monitor width in pixels.
   * `height` - Get the monitor height in pixels.

Member Functions:

   * `add_image()` - add an image to the end of this monitor's draw list (see
     [`fe.add_image()`](#add_image) for parameters and return value).
   * `add_artwork()` - add an artwork to the end of this monitor's draw list
     (see [`fe.add_artwork()`](#add_artwork) for parameters and return value).
   * `add_clone()` - add a clone to the end of this monitor's draw list (see
     [`fe.add_clone()`](#add_clone) for parameters and return value).
   * `add_text()` - add a text to the end of this monitor's draw list (see
     [`fe.add_text()`](#add_text) for parameters and return value).
   * `add_listbox()` - add a listbox to the end of this monitor's draw list
     (see [`fe.add_listbox()`](#add_listbox) for parameters and return value).
   * `add_surface()` - add a surface to the end of this monitor's draw list
     (see [`fe.add_surface()`](#add_surface) for parameters and return value).
   * `add_rectangle()` - add a rectangle to the end of this monitor's draw list
     (see [`fe.add_rectangle()`](#add_rectangle) for parameters and return value).

Notes:

   * As of this writing, multiple monitor support has not been implemented
     for the OS X version of Attract-Mode.
   * The first entry in the `fe.monitors` array is always the "primary" display
     for the system.

&nbsp;
<a name="Image"></a>

#### `fe.Image` ####

The class representing an image in Attract-Mode.  Instances of this class
are returned by the [`fe.add_image()`](#add_image), [`fe.add_artwork()`](#add_artwork), [`fe.add_surface()`](#add_surface) and
[`fe.add_clone()`](#add_clone) functions and also appear in the `fe.obj` array (the
Attract-Mode draw list).  This class cannot be otherwise instantiated in
a script.

Properties:

   * `x` - Get/set x position of image (in layout coordinates).
   * `y` - Get/set y position of image (in layout coordinates).
   * `width` - Get/set width of image (in layout coordinates), 0 if the
     image is unscaled.  Default value is 0.
   * `height` - Get/set height of image (in layout coordinates), if 0 the
     image is unscaled.  Default value is 0.
   * `visible` - Get/set whether image is visible (boolean).  Default value
     is `true`.
   * `rotation` - Get/set rotation of image around its rotation origin.
     Range is [0 ... 360].  Default value is 0.
   * `red` - Get/set red colour level for image. Range is [0 ... 255].
     Default value is 255.
   * `green` - Get/set green colour level for image. Range is [0 ... 255].
     Default value is 255.
   * `blue` - Get/set blue colour level for image. Range is [0 ... 255].
     Default value is 255.
   * `alpha` - Get/set alpha level for image. Range is [0 ... 255].  Default
     value is 255.
   * `index_offset` - Get/set offset from current selection for the artwork/
     dynamic image to display.  For example, set to -1 for the image
     corresponding to the previous list entry, or 1 for the next list entry,
     etc.  Default value is 0.
   * `filter_offset` - Get/set filter offset from current filter for the
     artwork/dynamic image to display.  For example, set to -1 for an image
     indexed in the previous filter, or 1 for the next filter, etc.  Default
     value is 0.
   * `skew_x` - Get/set the amount of x-direction image skew (in layout
     coordinates).  Default value is 0.  Use a negative value to skew the
     image to the left instead.
   * `skew_y` - Get/set the amount of y-direction image skew (in layout
     coordinates).  Default value is 0.  Use a negative value to skew the
     image up instead.
   * `pinch_x` - Get/set the amount of x-direction image pinch (in layout
     coordinates).  Default value is 0.  Use a negative value to expand
     towards the bottom instead.
   * `pinch_y` - Get/set the amount of y-direction image pinch (in layout
     coordinates).  Default value is 0.  Use a negative value to expand
     towards the right instead.
   * `texture_width` - Get the width of the image texture (in pixels).
     See [Notes](#ImageNotes).
   * `texture_height` - Get the height of the image texture (in pixels).
     See [Notes](#ImageNotes).
   * `subimg_x` - Get/set the x position of top left corner of the image
     texture sub-rectangle to display.  Default value is 0.
   * `subimg_y` - Get/set the y position of top left corner of the image
     texture sub-rectangle to display.  Default value is 0.
   * `subimg_width` - Get/set the width of the image texture sub-rectangle
     to display.  Default value is `texture_width`.
   * `subimg_height` - Get/set the height of the image texture sub-rectangle
     to display.  Default value is `texture_height`.
   * `sample_aspect_ratio` - Get the "sample aspect ratio", which is the width
     of a pixel divided by the height of the pixel.
   * `origin_x` - (deprecated) Get/set the x position of the local origin for the image.
     The origin defines the centre point for any positioning or rotation of
     the image.  Default origin in 0,0 (top-left corner).
   * `origin_y` - (deprecated) Get/set the y position of the local origin for the image.
     The origin defines the centre point for any positioning or rotation of
     the image. Default origin is 0,0 (top-left corner).
   * `anchor` 🔶 Set the midpoint for position and scale.
     Can be set to one of the following modes:
      - `Anchor.Left`
      - `Anchor.Centre`
      - `Anchor.Right`
      - `Anchor.Top`
      - `Anchor.Bottom`
      - `Anchor.TopLeft` (default)
      - `Anchor.TopRight`
      - `Anchor.BottomLeft`
      - `Anchor.BottomRight`
   * `rotation_origin` 🔶 Set the midpoint for rotation
     Can be set to one of the following modes:
      - `Origin.Left`
      - `Origin.Centre`
      - `Origin.Right`
      - `Origin.Top`
      - `Origin.Bottom`
      - `Origin.TopLeft` (default)
      - `Origin.TopRight`
      - `Origin.BottomLeft`
      - `Origin.BottomRight`
   * `anchor_x` 🔶 Get/set the x position of the midpoint for position and scale.
     Range is [0.0 ... 1.0]. Default value is 0.0, centre is 0.5
   * `anchor_y` 🔶 Get/set the y position of the midpoint for position and scale.
     Range is [0.0 ... 1.0]. Default value is 0.0, centre is 0.5
   * `rotation_origin_x` 🔶 Get/set the x position of the midpoint for rotation.
     Range is [0.0 ... 1.0]. Default value is 0.0, centre is 0.5
   * `rotation_origin_y` 🔶 Get/set the y position of the midpoint for rotation.
     Range is [0.0 ... 1.0]. Default value is 0.0, centre is 0.5
   * `video_flags` - [image & artwork only] Get/set video flags for this
     object.  These flags allow you to override Attract-Mode's default video
     playback behaviour.  Can be set to any combination of none or more of the
     following (i.e. `Vid.NoAudio | Vid.NoLoop`):
      - `Vid.Default`
      - `Vid.ImagesOnly` (disable video playback, display images instead)
      - `Vid.NoAudio` (silence the audio track)
      - `Vid.NoAutoStart` (don't automatically start video playback)
      - `Vid.NoLoop` (don't loop video playback)
   * `video_playing` - [image & artwork only] Get/set whether video is
     currently playing in this artwork (boolean).
   * `video_duration` - Get the video duration (in milliseconds).
   * `video_time` - Get the time that the video is current at (in milliseconds).
   * `preserve_aspect_ratio` - Get/set whether the aspect ratio from the source
     image is to be preserved.  Default value is `false`.
   * `file_name` - [image & artwork only] Get/set the name of the image/video
     file being shown.  If you set this on an artwork or a dynamic
     image object it will get reset the next time the user changes the game
     selection.  If file_name is contained in an archive, this string should be
     formatted: "<archive_name>|<filename>"
   * `shader` - Get/set the GLSL shader for this image. This can only be set to
     an instance of the class `fe.Shader` (see: `fe.add_shader()`).
   * `trigger` - Get/set the transition that triggers updates of this artwork/
     dynamic image.  Can be set to `Transition.ToNewSelection` or
     `Transition.EndNavigation`.  Default value is `Transition.ToNewSelection`.
   * `smooth` - Get/set whether the image is to be smoothed.  Default value can
     be configured in attract.cfg
   * `zorder` - Get/set the Image's order in the applicable draw list.  Objects
     with a lower zorder are drawn first, so that when objects overlap, the one
     with the higher zorder is drawn on top.  Default value is 0.
   * `blend_mode` - Get/set the blend mode for this image.  Can have one of the
     following values:
      - `BlendMode.Alpha` (default for images and artwork)
      - `BlendMode.Add`
      - `BlendMode.Screen`
      - `BlendMode.Multiply`
      - `BlendMode.Overlay`
      - `BlendMode.Premultiplied` (default for surfaces)
      - `BlendMode.None`
   * `mipmap` - Get/set the automatic generation of mipmap for the image/artwork/video.
     Setting this to `true` greatly improves the quality of scaled down images.
     The default value is `false`.  It's advised to force anisotropic filtering in
     the display driver settings if the Image with auto generated mipmap is scaled
     by the ratio that is not isotropic.
   * `volume` 🔶 Get/set the volume of played video. Range is [0 ... 100]
   * `repeat` 🔶 Enables texture repeat when set to true. Default value is false.
     To see the effect `subimg_width/height` must be set larger than `texture_width/height`
   * `clear` 🔶 [surface only] When set to false surface is not cleared
     before the next frame. This can be used for various accumulative effects.
   * `redraw` 🔶 [surface only] When set to false surface's content is not redrawn
     which gives optimization opportunity for hidden surfaces.
     This in conjunction with `clear = false` can be used to freeze surface's content.

Member Functions:

   * `set_rgb( r, g, b )` - Set the red, green and blue colour values for the
     image.  Range is [0 ... 255].
   * `set_pos( x, y )` - Set the image position (in layout coordinates).
   * `set_pos( x, y, width, height )` - Set the image position and size (in
     layout coordinates).
   * `set_anchor( x, y )` 🔶 Set the midpoint for position and scale
     x and y are in [0.0 ... 1.0] range, centre is ( 0.5, 0.5 )
   * `set_rotation_origin( x, y )` 🔶 Set the midpoint for rotation
     x and y are in [0.0 ... 1.0] range, centre is ( 0.5, 0.5 )
   * `swap( other_img )` - swap the texture contents of this object (and all
     of its clones) with the contents of "other_img" (and all of its clones).
     If an image or artwork is swapped, its video attributes (`video_flags`
     and `video_playing`) will be swapped as well.
   * `fix_masked_image()` - Takes the colour of the top left pixel in the image
     and makes all the pixels in the image with that colour transparent.
   * `add_image()` - [surface only] add an image to the end of this surface's
     draw list (see [`fe.add_image()`](#add_image) for parameters and return
     value).
   * `add_artwork()` - [surface only] add an artwork to the end of this
     surface's draw list (see [`fe.add_artwork()`](#add_artwork) for parameters
     and return value).
   * `add_clone()` - [surface only] add a clone to the end of this surface's
     draw list (see [`fe.add_clone()`](#add_clone) for parameters and return
     value).
   * `add_text()` - [surface only] add a text to the end of this surface's draw
     list (see [`fe.add_text()`](#add_text) for parameters and return value).
   * `add_listbox()` - [surface only] add a listbox to the end of this
     surface's draw list (see [`fe.add_listbox()`](#add_listbox) for parameters
     and return value).
   * `add_surface()` - [surface only] add a surface to the end of this
     surface's draw list (see [`fe.add_surface()`](#add_surface) for parameters
     and return value).
   * `add_rectangle()` - [surface only] add a rectangle to the end of this
	  surface's draw list (see [`fe.add_rectangle()`](#add_rectangle) for parameters
	  and return value).

&nbsp;
<a name="ImageNotes"></a>

Notes:

   * Attract-Mode defers the loading of artwork and dynamic images
     (images with Magic Tokens) until after all layout and plug-in scripts have
     completed running.  This means that the `texture_width`, `texture_height`
     and `file_name` attributes are not available when a layout or plug-in
     script first adds the artwork/dynamic image resource.  These attributes
     are available during transition callbacks, and in particular during the
     `Transition.FromOldSelection` and `Transition.ToNewList` transitions.
     Example:

```` squirrel
local my_art = fe.add_artwork( "snap", 0, 0, 100, 100 );

fe.add_transition_callback( "artwork_transition" );
function artwork_transition( ttype, var, ttime )
{
  if (( ttype == Transition.FromOldSelection )
     || ( ttype == Transition.ToNewList ))
  {
    //
    // do stuff with my_art's texture_width or texture_height here...
    //
    // for example, flip the image vertically:
    my_art.subimg_height = -1 * texture_height;
    my_art.subimg_y = texture_height;
  }

  return false;
}
````

   * To flip an image vertically, set the `subimg_height` property to
     `-1 * texture_height` and `subimg_y` to `texture_height`.
   * To flip an image horizontally, set the `subimg_width` property to
     `-1 * texture_width` and `subimg_x` to `texture_width`.

```` squirrel
// flip "img" vertically
function flip_y( img )
{
  img.subimg_height = -1 * img.texture_height;
  img.subimg_y = img.texture_height;
}
````

&nbsp;
<a name="Text"></a>

#### `fe.Text` ####

The class representing a text label in Attract-Mode.  Instances of this
class are returned by the [`fe.add_text()`](#add_text) functions and also appear in the
`fe.obj` array (the Attract-Mode draw list).  This class cannot be
otherwise instantiated in a script.

Properties:
   * `msg` - Get/set the text label's message.  Magic tokens can be used here,
     see [Magic Tokens](#magic) for more information.
   * `msg_wrapped` - Get the text label's message after word wrapping.
   * `x` - Get/set x position of top left corner (in layout coordinates).
   * `y` - Get/set y position of top left corner (in layout coordinates).
   * `width` - Get/set width of text (in layout coordinates).
   * `height` - Get/set height of text (in layout coordinates).
   * `visible` - Get/set whether text is visible (boolean).  Default value
     is `true`.
   * `rotation` - Get/set rotation of text. Range is [0 ... 360].  Default
     value is 0.
   * `red` - Get/set red colour level for text. Range is [0 ... 255].
     Default value is 255.
   * `green` - Get/set green colour level for text. Range is [0 ... 255].
     Default value is 255.
   * `blue` - Get/set blue colour level for text. Range is [0 ... 255].
     Default value is 255.
   * `alpha` - Get/set alpha level for text. Range is [0 ... 255].  Default
     value is 255.
   * `index_offset` - Get/set offset from current game selection for text
     info to display.  For example, set to -1 to show text info for the
     previous list entry, or 1 for the next list entry.  Default value is 0.
   * `filter_offset` - Get/set filter offset from current filter for the
     text info to display.  For example, set to -1 to show text info for
     a selection in the previous filter, or 1 for the next filter, etc.
     Default value is 0.
   * `bg_red` - Get/set red colour level for text background. Range is
     [0 ... 255].  Default value is 0.
   * `bg_green` - Get/set green colour level for text background. Range is
     [0 ... 255].  Default value is 0.
   * `bg_blue` - Get/set blue colour level for text background. Range is
     [0 ... 255].  Default value is 0.
   * `bg_alpha` - Get/set alpha level for text background. Range is [0 ...
     255].  Default value is 0 (transparent).
   * `char_size` - Get/set the forced character size.  If this is <= 0
     then Attract-Mode will auto-size based on `height`.  Default value is -1.
   * `glyph_size` - Get the height in pixels of the capital letter.
     Useful if you want to set the textbox height to match the letter height.
   * `char_spacing` - Get/set the spacing factor between letters.  Default value is 1.0
   * `line_spacing` - Get/set the spacing factor between lines.  Default value is 1.0
     At values 0.75 or lower letters start to overlap. For uppercase texts it's around 0.5
     It's advised to use this property with the new align modes.
   * `outline` 🔶 Get/set the thickness of the outline applied to text.
     Value is set in pixels and can be fractional. Default value is 0.0
   * `bg_outline` 🔶 Get/set the thickness of the outline applied to the background.
     Value is set in pixels and can be fractional. Default value is 0.0
   * `style` - Get/set the text style.  Can be a combination of one or more
     of the following (i.e. `Style.Bold | Style.Italic`):
      - `Style.Regular` (default)
      - `Style.Bold`
      - `Style.Italic`
      - `Style.Underlined`
   * `align` - Get/set the text alignment.  Can be one of the following
     values:
      - `Align.Centre` (default)
      - `Align.Left`
      - `Align.Right`
      - `Align.TopCentre`
      - `Align.TopLeft`
      - `Align.TopRight`
      - `Align.BottomCentre`
      - `Align.BottomLeft`
      - `Align.BottomRight`
      - `Align.MiddleCentre`
      - `Align.MiddleLeft`
      - `Align.MiddleRight`
     The last 3 alignment modes have the same function as the first 3,
     but they are more accurate. The first 3 modes are preserved for compatibility.
   * `word_wrap` - Get/set whether word wrapping is enabled in this text
     (boolean).  Default is `false`.
   * `msg_width` - Get the width of the text message, in layout coordinates.
   * `msg_height` 🔶 Get the height of the text message, in layout coordinates.
   * `lines` 🔶 Get the maximum line count that can be fitted inside the text box.
   * `lines_total` 🔶 Get the total line count of the formatted text message.
   * `line_height` 🔶 Get the distance between 2 lines of text in layout coordinates.
   * `first_line_hint` 🔶 Get/set the line in the formatted text that is shown as first line in the text object
   * `font` - Get/set the filename of the font used for this text.
     If not set default font is used.
   * `margin` - Get/set the margin spacing in pixels to sides of the text.
     Default value is `-1` which calculates the margin based on the .char_size.
   * `shader` - Get/set the GLSL shader for this text. This can only be set to
     an instance of the class `fe.Shader` (see: `fe.add_shader()`).
   * `zorder` - Get/set the Text's order in the applicable draw list.  Objects
     with a lower zorder are drawn first, so that when objects overlap, the one
     with the higher zorder is drawn on top.  Default value is 0.

Member Functions:

   * `set_rgb( r, g, b )` - Set the red, green and blue colour values for the
     text.  Range is [0 ... 255].
   * `set_bg_rgb( r, g, b )` - Set the red, green and blue colour values for
     the text background.  Range is [0 ... 255].
   * `set_outline_rgb( r, g, b )` 🔶 Set the red, green and blue colour values for
     the text outline.  Range is [0 ... 255].
   * `set_bg_outline_rgb()` 🔶 Set the red, green and blue colour values for
     the outline of the text background.  Range is [0 ... 255].
   * `set_pos( x, y )` - Set the text position (in layout coordinates).
   * `set_pos( x, y, width, height )` - Set the text position and size (in
     layout coordinates).

&nbsp;
<a name="ListBox"></a>

#### `fe.ListBox` ####

The class representing the listbox in Attract-Mode.  Instances of this
class are returned by the [`fe.add_listbox()`](#add_listbox) functions and also appear in the
`fe.obj` array (the Attract-Mode draw list).  This class cannot be
otherwise instantiated in a script.

Properties:

   * `x` - Get/set x position of top left corner (in layout coordinates).
   * `y` - Get/set y position of top left corner (in layout coordinates).
   * `width` - Get/set width of listbox (in layout coordinates).
   * `height` - Get/set height of listbox (in layout coordinates).
   * `visible` - Get/set whether listbox is visible (boolean).  Default value
     is `true`.
   * `rotation` - Get/set rotation of listbox. Range is [0 ... 360].  Default
     value is 0.
   * `red` - Get/set red colour level for text. Range is [0 ... 255].
     Default value is 255.
   * `green` - Get/set green colour level for text. Range is [0 ... 255].
     Default value is 255.
   * `blue` - Get/set blue colour level for text. Range is [0 ... 255].
     Default value is 255.
   * `alpha` - Get/set alpha level for text. Range is [0 ... 255].
     Default value is 255.
   * `index_offset` - Not used.
   * `filter_offset` - Get/set filter offset from current filter for the
     text info to display.  For example, set to -1 to show info for the
     previous filter, or 1 for the next filter, etc.  Default value is 0.
   * `bg_red` - Get/set red colour level for background. Range is
     [0 ... 255].  Default value is 0.
   * `bg_green` - Get/set green colour level for background. Range is
     [0 ... 255].  Default value is 0.
   * `bg_blue` - Get/set blue colour level for background. Range is
     [0 ... 255].  Default value is 0.
   * `bg_alpha` - Get/set alpha level for background. Range is [0 ...
     255].  Default value is 0 (transparent).
   * `sel_red` - Get/set red colour level for selection text. Range is
     [0 ... 255].  Default value is 255.
   * `sel_green` - Get/set green colour level for selection text. Range is
     [0 ... 255].  Default value is 255.
   * `sel_blue` - Get/set blue colour level for selection text. Range is
     [0 ... 255].  Default value is 0.
   * `sel_alpha` - Get/set alpha level for selection text. Range is
     [0 ... 255].  Default value is 255.
   * `selbg_red` - Get/set red colour level for selection background. Range
     is [0 ... 255].  Default value is 0.
   * `selbg_green` - Get/set green colour level for selection background.
     Range is  [0 ... 255].  Default value is 0.
   * `selbg_blue` - Get/set blue colour level for selection background.
     Range is [0 ... 255].  Default value is 255.
   * `selbg_alpha` - Get/set alpha level for selection background. Range is
     [0 ... 255].  Default value is 255.
   * `rows` - Get/set the number of listbox rows.  Default value is 11.
   * `list_size` - Get the size of the list shown by listbox.
     When listbox is assigned as an overlay custom control this property
     will return the number of options available in the overlay dialog.
     This property is updated during `Transition.ShowOverlay`
   * `char_size` - Get/set the forced character size.  If this is <= 0
     then Attract-Mode will auto-size based on the value of `height`/`rows`.
     Default value is -1.
   * `glyph_size` - Get the height in pixels of the capital letter.
   * `char_spacing` - Get/set the spacing factor between letters.  Default value is 1.0
   * `style` - Get/set the text style.  Can be a combination of one or more
     of the following (i.e. `Style.Bold | Style.Italic`):
      - `Style.Regular` (default)
      - `Style.Bold`
      - `Style.Italic`
      - `Style.Underlined`
   * `align` - Get/set the text alignment.  Can be one of the following
     values:
      - `Align.Centre` (default)
      - `Align.Left`
      - `Align.Right`
      - `Align.TopCentre`
      - `Align.TopLeft`
      - `Align.TopRight`
      - `Align.BottomCentre`
      - `Align.BottomLeft`
      - `Align.BottomRight`
      - `Align.MiddleCentre`
      - `Align.MiddleLeft`
      - `Align.MiddleRight`
     The last 3 alignment modes have the same function as the first 3,
     but they are more accurate. The first 3 modes are preserved for compatibility.
   * `sel_style` - Get/set the selection text style.  Can be a combination
     of one or more of the following (i.e. `Style.Bold | Style.Italic`):
      - `Style.Regular` (default)
      - `Style.Bold`
      - `Style.Italic`
      - `Style.Underlined`
   * `font` - Get/set the filename of the font used for this listbox.
     If not set default font is used.
   * `margin` - Get/set the margin spacing in pixels to sides of the text.
     Default value is `-1` which calculates the margin based on the .char_size.
   * `format_string` - Get/set the format for the text to display in each list
     entry. Magic tokens can be used here, see [Magic Tokens](#magic) for more
     information.  If empty, game titles will be displayed (i.e. the same
     behaviour as if set to "[Title]").  Default is an empty value.
   * `shader` - Get/set the GLSL shader for this listbox. This can only be set
     to an instance of the class `fe.Shader` (see: `fe.add_shader()`).
   * `zorder` - Get/set the Listbox's order in the applicable draw list.  Objects
     with a lower zorder are drawn first, so that when objects overlap, the one
     with the higher zorder is drawn on top.  Default value is 0.

Member Functions:

   * `set_rgb( r, g, b )` - Set the red, green and blue colour values for the
     text.  Range is [0 ... 255].
   * `set_bg_rgb( r, g, b )` - Set the red, green and blue colour values for
     the text background.  Range is [0 ... 255].
   * `set_sel_rgb( r, g, b )` - Set the red, green and blue colour values
     for the selection text.  Range is [0 ... 255].
   * `set_selbg_rgb( r, g, b )` - Set the red, green and blue colour values
     for the selection background.  Range is [0 ... 255].
   * `set_pos( x, y )` - Set the listbox position (in layout coordinates).
   * `set_pos( x, y, width, height )` - Set the listbox position and size (in
     layout coordinates).

&nbsp;
<a name="Rectangle"></a>

#### `fe.Rectangle` 🔶 ####

The class representing a rectangle in Attract-Mode.  Instances of this class
are returned by the [`fe.add_rectangle()`](#add_rectangle) function and also appear in the `fe.obj`
array (the Attract-Mode draw list).  This class cannot be otherwise instantiated in
a script.

Properties:

   * `x` - Get/set x position of the rectangle (in layout coordinates).
   * `y` - Get/set y position of the rectangle (in layout coordinates).
   * `width` - Get/set width of the rectangle (in layout coordinates), 0 if the
     image is unscaled.  Default value is 0.
   * `height` - Get/set height of the rectangle (in layout coordinates), if 0 the
     image is unscaled.  Default value is 0.
   * `visible` - Get/set whether the rectangle is visible (boolean).  Default value
     is `true`.
   * `rotation` - Get/set rotation of the rectangle around its origin. Range is [0
     ... 360].  Default value is 0.
   * `red` - Get/set red colour level for the rectangle. Range is [0 ... 255].
     Default value is 255.
   * `green` - Get/set green colour level for the rectangle. Range is [0 ... 255].
     Default value is 255.
   * `blue` - Get/set blue colour level for the rectangle. Range is [0 ... 255].
     Default value is 255.
   * `alpha` - Get/set alpha level for the rectangle. Range is [0 ... 255].  Default
     value is 255.
   * `outline` Get/set the thickness of the outline applied to the rectangle.
     Value is set in pixels and can be fractional. Default value is 0.0
   * `outline_red` - Get/set red colour level for the rectangle's outline.
     Range is [0 ... 255]. Default value is 255.
   * `outline_green` - Get/set green colour level for the rectangle's outline.
     Range is [0 ... 255]. Default value is 255.
   * `outline_blue` - Get/set blue colour level for the rectangle's outline.
     Range is [0 ... 255]. Default value is 255.
   * `outline_alpha` - Get/set alpha level for the rectangle's outline.
     Range is [0 ... 255].  Default value is 255.
   * `origin_x` - (deprecated) Get/set the x position of the local origin for the rectangle.
     The origin defines the centre point for any positioning or rotation of
     the rectangle.  Default origin in 0,0 (top-left corner).
   * `origin_y` - (deprecated) Get/set the y position of the local origin for the rectangle.
     The origin defines the centre point for any positioning or rotation of
     the rectangle. Default origin is 0,0 (top-left corner).
   * `anchor` Set the midpoint for position and scale.
     Can be set to one of the following modes:
      - `Anchor.Left`
      - `Anchor.Centre`
      - `Anchor.Right`
      - `Anchor.Top`
      - `Anchor.Bottom`
      - `Anchor.TopLeft` (default)
      - `Anchor.TopRight`
      - `Anchor.BottomLeft`
      - `Anchor.BottomRight`
   * `rotation_origin` Set the midpoint for rotation
     Can be set to one of the following modes:
      - `Origin.Left`
      - `Origin.Centre`
      - `Origin.Right`
      - `Origin.Top`
      - `Origin.Bottom`
      - `Origin.TopLeft` (default)
      - `Origin.TopRight`
      - `Origin.BottomLeft`
      - `Origin.BottomRight`
   * `anchor_x` - Get/set the x position of the midpoint for position and scale.
     Range is [0.0 ... 1.0]. Default value is 0.0, centre is 0.5
   * `anchor_y` - Get/set the y position of the midpoint for position and scale.
     Range is [0.0 ... 1.0]. Default value is 0.0, centre is 0.5
   * `rotation_origin_x` - Get/set the x position of the midpoint for rotation.
     Range is [0.0 ... 1.0]. Default value is 0.0, centre is 0.5
   * `rotation_origin_y` - Get/set the y position of the midpoint for rotation.
     Range is [0.0 ... 1.0]. Default value is 0.0, centre is 0.5
   * `corner_radius` - Get/set the corner radius (in layout coordinates).
     This property will adjust the radius to preserve corner roundness when set.
     Default value is 0.0.
   * `corner_radius_x` - Get/set the corner x radius (in layout coordinates).
     Default value is 0.0.
   * `corner_radius_y` - Get/set the corner y radius (in layout coordinates).
     Default value is 0.0.
   * `corner_ratio` - Get/set the corner radius as a fraction of the smallest side.
     This property will adjust the radius to preserve corner roundness when set.
     Range is [0.0 ... 0.5]. Default value is 0.0.
   * `corner_ratio_x` - Get/set the corner x radius as a fraction of the width.
     Range is [0.0 ... 0.5]. Default value is 0.0.
   * `corner_ratio_y` - Get/set the corner y radius as a fraction of the height.
     Range is [0.0 ... 0.5]. Default value is 0.0.
   * `corner_points` - Get/set the number of points used to draw the corner radius.
     More points produce smooth curves, while fewer points result in flat bevels.
     Range is [1 ... 32]. Default value is 12.
   * `shader` - Get/set the GLSL shader for this rectangle. This can only be set to
     an instance of the class `fe.Shader` (see: `fe.add_shader()`).
   * `zorder` - Get/set the rectangles's order in the applicable draw list.  Objects
     with a lower zorder are drawn first, so that when objects overlap, the one
     with the higher zorder is drawn on top.  Default value is 0.
   * `blend_mode` - Get/set the blend mode for this rectangle.  Can have one of the
     following values:
      - `BlendMode.Alpha`
      - `BlendMode.Add`
      - `BlendMode.Screen`
      - `BlendMode.Multiply`
      - `BlendMode.Overlay`
      - `BlendMode.Premultiplied`
      - `BlendMode.None`

Member Functions:

   * `set_rgb( r, g, b )` - Set the red, green and blue colour values for the
     rectangle.  Range is [0 ... 255].
   * `set_pos( x, y )` - Set the rectangle position (in layout coordinates).
   * `set_pos( x, y, width, height )` - Set the rectangle position and size (in
     layout coordinates).
   * `set_outline_rgb( r, g, b )` - Set the red, green and blue colour values for
     the rectangle outline.  Range is [0 ... 255].
   * `set_anchor( x, y )` - Set the midpoint for position and scale
     x and y are in [0.0 ... 1.0] range, centre is ( 0.5, 0.5 )
   * `set_rotation_origin( x, y )` - Set the midpoint for rotation
     x and y are in [0.0 ... 1.0] range, centre is ( 0.5, 0.5 )
   * `set_corner_radius( x, y )` - Set the corner x and y radius (in layout coordinates).
   * `set_corner_ratio( x, y )` - Set the corner x and y radius as a fraction of the
     width and height.  Range is [0.0 ... 0.5].

&nbsp;
<a name="Sound"></a>

#### `fe.Sound` ####

The class representing a sound object.  Instances of this class are returned
by the [`fe.add_sound()`](#add_sound) function.  This class cannot be otherwise
instantiated in a script.

Properties:

   * `file_name` - Get/set the sound filename.
   * `volume` - Get/set the volume of played sound. Range is [0 ... 100] 🔶
   * `playing` - Get/set whether the sound is currently playing (boolean).
   * `loop` - Get/set whether the sound should be looped (boolean).
   * `pitch` - Get/set the sound pitch (float). Default value is 1.
   * `x` - Get/set the x position of the sound.  Default value is 0.
   * `y` - Get/set the y position of the sound.  Default value is 0.
   * `z` - Get/set the z position of the sound.  Default value is 0.
   * `duration` - Get the sound duration (in milliseconds).
   * `time` - Get the time that the sound is current at (in
     milliseconds).

&nbsp;
<a name="Music"></a>

#### `fe.Music` 🔶 ####

The class representing an audio track.  Instances of this class are returned
by the [`fe.add_music()`](#add_music) function.  This is also the class for the
`fe.ambient_sound` object.  Object of this class cannot be otherwise
instantiated in a script.

Properties:

   * `file_name` - Get/set the audio track filename.
   * `volume` - Get/set the volume of played audio track. Range is [0 ... 100]
   * `playing` - Get/set whether the audio track is currently playing (boolean).
   * `loop` - Get/set whether the audio track should be looped (boolean).
   * `pitch` - Get/set the audio track pitch (float). Default value is 1.
   * `x` - Get/set the x position of the audio track.  Default value is 0.
   * `y` - Get/set the y position of the audio track.  Default value is 0.
   * `z` - Get/set the z position of the audio track.  Default value is 0.
   * `duration` - Get the audio track duration (in milliseconds).
   * `time` - Get the time that the audio track is current at (in
     milliseconds).

Member Functions:

   * `get_metadata( tag )` - Get the meta data (if available in the source
     file) that corresponds to the specified tag (i.e. "artist", "album", etc.)

&nbsp;
<a name="Shader"></a>

#### `fe.Shader` ####

The class representing a GLSL shader.  Instances of this class are returned
by the [`fe.add_shader()`](#add_shader) function.  This class cannot be otherwise
instantiated in a script.

Properties:

   * `type` - Get the shader type.   Can be one of the following values:
      - `Shader.VertexAndFragment`
      - `Shader.Vertex`
      - `Shader.Fragment`
      - `Shader.Empty`

Member Functions:

   * `set_param( name, f )` - Set the float variable (float GLSL type) with
     the specified name to the value of f.
   * `set_param( name, f1, f2 )` - Set the 2-component vector variable (vec2
     GLSL type) with the specified name to (f1,f2).
   * `set_param( name, f1, f2, f3 )` - Set the 3-component vector variable
     (vec3 GLSL type) with the specified name to (f1,f2,f3).
   * `set_param( name, f1, f2, f3, f4 )` - Set the 4-component vector
     variable (vec4 GLSL type) with the specified name to (f1,f2,f3,f4).
   * `set_texture_param( name )` - Set the texture variable (sampler2D GLSL
     type) with the specified name.  The texture used will be the texture
     for whatever object (fe.Image, fe.Text, fe.Listbox) the shader is
     drawing.
   * `set_texture_param( name, image )` - Set the texture variable (sampler2D
     GLSL type) with the specified name to the texture contained in "image".
     "image" must be an instance of the `fe.Image` class.

&nbsp;
<a name="constants"></a>

Constants
---------

#### `FeVersion` [string] ####
#### `FeVersionNum` [int] ####

The current Attract-Mode version.

#### `FeConfigDirectory` [string] ####

The path to Attract-Mode's config directory.

#### `IntroActive` [bool] ####

true if the intro is active, false otherwise.

#### `Language` [string] ####

The configured language.

#### `OS` [string] ####

The Operating System that Attract-Mode is running under.  Will be one of:
"Windows", "OSX", "FreeBSD", "Linux" or "Unknown".

#### `ScreenWidth` [int] ####
#### `ScreenHeight` [int] ####

The screen width and height in pixels.

#### `ScreenRefreshRate` [int] ####

The refresh rate of the main screen in Hz.

#### `ScreenSaverActive` [bool] ####

true if the screen saver is active, false otherwise.

#### `ShadersAvailable` [bool] ####

true if GLSL shaders are available on this system, false otherwise.

