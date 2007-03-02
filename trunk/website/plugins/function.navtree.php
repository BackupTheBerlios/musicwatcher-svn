<?

function show_roots(&$tree) {
    for ($i = 0; $i < sizeof($tree); $i++) {
        $node =& $tree[$i];
        $node['show'] = 1;
    }
}

function set_show(&$tree, $uri) {
    for ($i = 0; $i < sizeof($tree); $i++) {
        $node =& $tree[$i];

        #print "debug: " . $node['uri'] . " $uri\n";
  
        if ($node['uri'] == $uri) {
            $node['show'] = 1;
            $node['selected'] = 1;

            show_roots($node['children']);

            return 1;
        } else if ($node['children'] != NULL) {
             $child =& $node['children'];
             if (set_show($node['children'], $uri)) {
                 $node['show'] = 1;
                 show_roots($node['children']);
                 return 1;
             }

        }

    } 

    return 0;
}

function render_navtree($tree) {
    $out = "<ul class=navlist>\n";

    if ($tree == NULL) {
        return '';
    }

    for ($i = 0; $i < sizeof($tree); $i++) {
        $node = $tree[$i];

        if ($node['show'] != NULL) {
            $text = $node['text'];
            $link = $node['uri'];

            if ($node['selected'] != NULL) {
                $out .= "<li class=selected>$text\n";
            } else {
                $out .= "<li class=unselected><a href=\"$link\">$text</a>\n";
            }

            $out .= render_navtree($node['children']);
            $out .= "</li>\n";
        }
    }

    $out .= "</ul>\n";

    return $out;
}

function smarty_function_navtree($args) {
    global $PATH;
    global $ROOT;
 
    $tree_file = "$ROOT/data/navtree.yaml";
    $tree = read_yaml($tree_file);

    $short_path = preg_replace("," . $_SERVER['PATH_INFO'] . "$,", '', $PATH);

    show_roots($tree);
    set_show($tree, $short_path);

    #header("content-type: text/plain");
    #print_r($tree);
    #exit;

    return render_navtree($tree);
}

?>
