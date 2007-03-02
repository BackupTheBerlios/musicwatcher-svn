<?php /* Smarty version 2.6.13, created on 2007-03-02 22:08:33
         compiled from 404.tpl */ ?>
<?php require_once(SMARTY_CORE_DIR . 'core.load_plugins.php');
smarty_core_load_plugins(array('plugins' => array(array('block', 'content', '404.tpl', 1, false),)), $this); ?>
<?php $this->_tag_stack[] = array('content', array('title' => "404 - Not Found")); $_block_repeat=true;smarty_block_content($this->_tag_stack[count($this->_tag_stack)-1][1], null, $this, $_block_repeat);while ($_block_repeat) { ob_start(); ?>
<p>
  The path <strong><?php echo $this->_tpl_vars['path']; ?>
</strong> is not valid. Please use the navigation
  system to try another link or use the search box to find another page to
  view.
</p>

<!-- it would be a neat idea to have this page automatically gather the
referer header and have the system log broken links if they originate inside
the system -->
 
<?php $_block_content = ob_get_contents(); ob_end_clean(); $_block_repeat=false;echo smarty_block_content($this->_tag_stack[count($this->_tag_stack)-1][1], $_block_content, $this, $_block_repeat); }  array_pop($this->_tag_stack); ?>