<?
    #######################################################
    # Figure root of this project and set up some globals.
    #######################################################
    #$TMPL = substr_replace('.' . $_SERVER['SCRIPT_NAME'], 'tpl', -3, 3);
    $ROOT = realpath(dirname(__FILE__) . DIRECTORY_SEPARATOR . '..') . DIRECTORY_SEPARATOR;
    $LIB  = $ROOT . 'lib' . DIRECTORY_SEPARATOR;
    $ETC  = $ROOT . 'etc' . DIRECTORY_SEPARATOR;
    $PHPBB = $ROOT . 'forum/';
    $PATH = get_path();
    #$CFG  = parse_ini_file($ROOT . 'etc/conf.ini', 1);
    set_include_path(get_include_path() . PATH_SEPARATOR . $ROOT . PATH_SEPARATOR . $LIB);

    #######################################################
    # Common include files
    #######################################################
    include('Smarty.class.php');

    #######################################################
    # Load and connect to database, if we need it.
    #######################################################
    if ($CFG['database']['use']) {
	require 'db.php';
	db_connect();
    }

    #$TMPL = template_path($ROOT);
    $TMPL = route_request($PATH);
    simple_tpl_display($TMPL);

    #######################################################
    # Helper functions
    #######################################################

    function route_request($path) {

      #find the template to use or execute a PHP file
      $template = resolve_template($path);
      
      if ($template == NULL) {
            do_404($path);
            exit;
        }

      return $template;
    }

    function resolve_template($path) {
        global $ROOT;
 
        $path_file = '';

        #handle the case of index documents
        $lastchar = $path[strlen($path) - 1];
        if ($lastchar == '/') {
            $path .= 'index';
            $is_index = 1;
        }

        $path_array = split('/', $path);
        $path = '';

        unset($path_array[0]);

        foreach ($path_array as $one) {
            $path .= "/$one";
            $newpath = $ROOT . $path;

            if(file_exists($newpath . '.php')) {
                set_pathfino($path);
                require($newpath . '.php');
                exit;
            } else if (file_exists($newpath . '.tpl')) {
                set_pathfino($path);
                return $newpath . '.tpl';
            }
        }

        return NULL;
    }

    function set_pathfino($path) {
        global $PATH;

        $path = preg_replace(',/index$,', '/', $path);

        $_SERVER['PATH_INFO'] = str_replace($path, '', $PATH);

        return 1;
    }

    function remove_query_info($uri) {
        #remove any query info if it is present
        if (($offset = strpos($uri, '?')) !== false) {
            for($i = 0; $i < $offset; $i++) {
                $newpath[$i] = $uri[$i];
            }
 
            return implode($newpath);
         }

        return $uri;
      }

    function get_path() {
      return remove_query_info($_SERVER['REQUEST_URI']);
    }

    function do_404($uri) {
        header("HTTP/1.0 404 Not Found");  
        simple_tpl_display("404.tpl");
        exit;
    }

    /* Do a redirect, does not return! */
    function sendredirect($uri) {
	header("Location: $uri");
	print "\n\n";
	exit;
    }

    /* Construct a GET call with parameters */
    function get_call($url, $params) {
	$str = NULL;
	foreach($params as $k=>$v) {
	    $p = $k . "=" . urlencode($v);

	    if ($str) {
		$str .= '&' . $p;
	    } else {
		$str = $p;
	    }
	}
	if ($str) {
	    return htmlspecialchars($url . '?' . $str);
	}
	return htmlspecialchars($url);
    }

    /* Setup a smarty template */
    function tpl() {
	global $ROOT;
	global $abu_gharib_images;

	$smarty = new Smarty;
	$smarty->template_dir = $ROOT . 'templates';
	$smarty->plugins_dir[] = $ROOT . 'plugins';
	$smarty->compile_dir = $ROOT . 'templates/compile-dir';
	$smarty->cache_dir = $ROOT . 'templates/cache-dir';

	$smarty->debugging = false;
	$smarty->force_compile = true;
	$smarty->compile_check = true;
	$smarty->caching = false;

        $smarty->assign('path', remove_query_info($_SERVER['REQUEST_URI']));
	$smarty->assign('session', &$_SESSION);
	$smarty->assign('self', $_SERVER['PHP_SELF']);
	$smarty->assign('base', strtolower(strtok($_SERVER['SERVER_PROTOCOL'], '/')).'://'.$_SERVER['HTTP_HOST']);

	header("Content-type: text/html; charset=utf-8");

	return $smarty;
    }

    /* Most pages just do this ... display a template. */
    function simple_tpl_display($name) {
	$tpl = tpl();

	$tpl->fetch($name);

	#hold off on the output to the last minute so we can set cookies in
        #a plugin
	$html = $tpl->fetch("layout.tpl");

        print $html;
    }

    function read_yaml($file) {
        include_once('spyc.php');
        $yaml = Spyc::YAMLLoad($file);

        return $yaml;
    }

    #######################################################
    # Common setup
    #######################################################
    #session_start();
?>
