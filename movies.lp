<?lua
  assert(loadfile("movies.lua"))()

  if cgilua.QUERY.v ~= nil and is_valid_file(cgilua.QUERY.v) then
	cgilua.put(get_media_info(cgilua.QUERY.v))
	return
  end
?><html>
  <head>
    <title>Listing of videos in <%= ROOT_DIR %></title>
    <script type="text/javascript" src="js/jquery-1.7.2.min.js"></script>
    <script type="text/javascript" src="js/spin.min.js"></script>
    <script type="text/javascript">
      $(function() {
        $('ul > li:has(> ul) > .entry')
          .click(function() {
            $(this).next().toggle();
            return false;
          })
          .addClass('has_entries')
          .next().hide();

        $('.entry.is_video')
          .click(function() {
            var info = $(this).next();
            if (!info.exists())
            {
              info = $('<div class="media_info">');

              // Add spinner to show we're loading...
              var spin = new Spinner({
                lines: 8,
                length: 4,
                width: 3,
                radius: 5,
                top: 5,
                left: 5
              });
              spin.spin(info[0]);
              info.append($('<span class="loading">Loading media info...</span>'));

              info.appendTo($(this).parent());
              info.load('?v=' + encodeURI($(this).attr('title')));
            }
            else
              info.toggle();
          });
      });
    </script>
    <style type="text/css">
      body { font-family: monospace; }
      ul {
        list-style-type: square;
        margin-bottom: 5px;
      }
      ul > li:nth-child(even) > .entry { background-color: #ddd; }
      ul > li:nth-child(odd) > ul > li:nth-child(odd) > .entry { background-color: #ddd; }
      ul > li:nth-child(odd) > ul > li:nth-child(even) > .entry { background-color: white; }
      .entry {
        border-radius: 3px;
        display: block;
        padding: 2px;
        width: 100%;
      }
      .entry:hover { background-color: turquoise !important; }
      .entry.has_entries {
        color: blue;
        cursor: pointer;
      }
      .entry.has_entries > .num_entries { color: black; }
      .entry.is_video, .num_videos { color: green; }
      .entry.is_video { cursor: pointer; }
      .mimetype { color: purple; }

      .media_info {
        border: 1px solid black;
        border-radius: 0 0 15px 15px;
        border-top: 0 none;
        margin-bottom: 5px;
        margin-left: 10px;
        min-height: 30px;
        padding-bottom: 10px;
        padding-left: 10px;
      }
      .media_info > .title {
        border-bottom: 1px solid;
        display: block;
        font-size: 1.2em;
        font-weight: bold;
        margin: 4px 0;
        width: 100%;
      }
      .media_info > .title:first-child { margin-top: 0; }
      .media_info > .title + br { display: none; }
      .media_info > .attr {
        font-weight: bold;
        margin-left: 10px;
      }
      .media_info > .value { font-style: italic; }
      .media_info > .loading {
        display: block;
        font-style: italic;
        font-weight: bold;
        padding: 10px 0 0 40px;
      }
    </style>
  </head>
  <body>
    <h1>Listing all files and directories under "<%= ROOT_DIR %>"</h1>
    <p>
      <span style="color: green;">green</span> means video file<br />
      <span style="color: blue;">blue</span> means directory<br />
      <span style="color: purple;">purple</span> means <a href="http://en.wikipedia.org/wiki/Internet_media_type">mimetype</a><br />
    </p>
<?lua local _,_,out = read_dir_recursive(ROOT_DIR) ?><%= out %>
  </body>
</html>
