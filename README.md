# Movie Directory Listing

A port of my [php-movie-listing](https://github.com/theY4Kman/php-movie-listing) to Lua, in order to test out Xavante and refamiliarize myself with Lua.

## Using it yourself

1. **Install** [Lua](http://www.lua.org/download.html)
2. **Install** [Xavante](http://keplerproject.github.com/xavante/) and [WSAPI](http://keplerproject.github.com/wsapi/) (to run Xavante as a standalone server), and their dependencies. In order to run lua-movie-listing, you'll also need [LuaFileSystem](http://keplerproject.github.com/luafilesystem/), as required by Xavante's file handler.
3. **Download** the correct distribution of **MediaInfo** ([download page](http://mediainfo.sourceforge.net/Download)) for your platform and place the executables in the `MediaInfo` directory.
4. **Configure** the `movies.lua` file:
   
   ```lua
   ROOT_DIR = '/hopefully/an/absolute/path/to/your/movies'
   PATH_SEPARATOR = '\\'
   ```

   **Note**: `ROOT_DIR` can be a relative path, but due to the lack of good protection and security, an absolute path is recommended. *When executing MediaInfo (in the shell!) the script checks only that `ROOT_PATH` is at the beginning of the user-supplied path, and that the path exists as a file. It's potentially possible to access unintended files, depending on your file tree.*
5. **Run** `lua web.lua <port>`
6. **Open** `localhost:<port>` in your browser, *et voilá!*
