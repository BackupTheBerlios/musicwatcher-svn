<?
    /* Smarty hook - take the contents of the {content} tag
       and store it away for the layout template */
    function smarty_block_content($params, $content, &$smarty, &$repeat)
    {

	$smarty->assign('title', $params['title']);
   
        if (isset($params['onLoad'])) {
            $html = 'onLoad="' . $params['onLoad'] . '"';
            $smarty->assign('onLoad', $html);
        }

	if (isset($content)) {
	    $smarty->assign('content', $content);
	}
    }
?>
