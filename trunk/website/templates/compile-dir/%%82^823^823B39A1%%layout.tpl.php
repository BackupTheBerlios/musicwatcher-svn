<?php /* Smarty version 2.6.13, created on 2007-03-02 22:08:33
         compiled from layout.tpl */ ?>
<?php require_once(SMARTY_CORE_DIR . 'core.load_plugins.php');
smarty_core_load_plugins(array('plugins' => array(array('function', 'navtree', 'layout.tpl', 13, false),)), $this); ?>
<html>
  <head>
    <title>MusicWatcher :: <?php echo $this->_tpl_vars['title']; ?>
</title>
    <link rel="stylesheet" type="text/css" title="screen" href="/stylesheets/screen.css">
  </head>

  <body bgcolor=white text=black>
    <table border=0 width=100% height=100%>
      <tr>
        <td valign=top id=leftside>
          <div class=leftbox>
            <h2>Navigation</h2>
            <?php echo smarty_function_navtree(array('file' => "navtree.yaml"), $this);?>

          </div>

          <div class=leftbox>
            <?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "search.tpl", 'smarty_include_vars' => array()));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>
          </div>

          <div class=leftbox>
            <a href="http://developer.berlios.de"><img src="http://developer.berlios.de/bslogo.php?group_id=0" width="124" height="32" border="0" alt="BerliOS Logo" /></a>
          </div>
        </td>

        <td valign=top rowspan=2 width="100%">
          <h2><?php echo $this->_tpl_vars['title']; ?>
</h2>
          <?php echo $this->_tpl_vars['content']; ?>


        </td>
      </tr>

      <!-- just to fill space -->
      <tr><td height=100%>&nbsp;</td></tr>
    </table>
  </body>
</html>