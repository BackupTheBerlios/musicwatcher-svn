<html>
  <head>
    <title>MusicWatcher :: {$title}</title>
    <link rel="stylesheet" type="text/css" title="screen" href="/stylesheets/screen.css">
  </head>

  <body bgcolor=white text=black>
    <table border=0 width=100% height=100%>
      <tr>
        <td valign=top id=leftside>
          <div class=leftbox>
            <h2>Navigation</h2>
            {navtree file=navtree.yaml}
          </div>

          <div class=leftbox>
            {include file="search.tpl"}
          </div>

          <div class=leftbox>
            <a href="http://developer.berlios.de"><img src="http://developer.berlios.de/bslogo.php?group_id=0" width="124" height="32" border="0" alt="BerliOS Logo" /></a>
          </div>
        </td>

        <td valign=top rowspan=2 width="100%">
          <h2>{$title}</h2>
          {$content}

        </td>
      </tr>

      <!-- just to fill space -->
      <tr><td height=100%>&nbsp;</td></tr>
    </table>
  </body>
</html>
