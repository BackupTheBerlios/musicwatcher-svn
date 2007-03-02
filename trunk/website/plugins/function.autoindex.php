<?

function find_node_path($tree, $path) {
    for($i = 0; $i < sizeof($tree); $i++) {
        $node = $tree[$i];

        if ($node['uri'] == $path) {
            return array($node);
        } elseif ($node['children'] != NULL) {
            $found = find_node_path($node['children'], $path);

            if ($found != NULL) {
                return $found;
            }
        }
    }

    return NULL;
}

function build_autoindex_array($tree, &$list) {
    foreach ($tree as $node) {
        if ($node['children'] == NULL) {
           array_push($list, $node); 
        }
    }

    foreach ($tree as $node) {
        if ($node['children'] != NULL) {
            build_autoindex_array($node['children'], $list);
        }
    }

    return $list;
}

function render_autoindex($list) {
    $html = '';

    for($i = 0; $i < sizeof($list); $i++) {
        $node = $list[$i];

        $html .= "<div class=thumbnail>";

        $html .= '<a href="' . $node['uri'] . '">';

        if ($node['long-text']) {
            $html .= $node['long-text'];
        } else {
            $html .= $node['text'];
        }

        $html .= '<br><img src="' . $node['thumb'] . '">';

        $html .= "</a>";

        $html .= "</div>\n\n";
    }

    return $html;
}

function smarty_function_autoindex($args) {
    global $ROOT;
    global $PATH;

    $file = $args['file'];

    $tree = read_yaml($ROOT . "/data/$file");
    $short_path = preg_replace("," . $_SERVER['PATH_INFO'] . "$,", '', $PATH);
    $list = array();

    $node = find_node_path($tree, $short_path);

    if ($node == NULL) {
        return "ERROR: Could not find data for autoindex";
    }

    build_autoindex_array($node, $list);

    return render_autoindex($list);
}

?>
