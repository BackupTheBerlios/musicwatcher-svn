<?php /* Smarty version 2.6.13, created on 2007-03-02 21:24:35
         compiled from /home/groups/musicwatcher/htdocs//index.tpl */ ?>
<?php require_once(SMARTY_CORE_DIR . 'core.load_plugins.php');
smarty_core_load_plugins(array('plugins' => array(array('block', 'content', '/home/groups/musicwatcher/htdocs//index.tpl', 1, false),)), $this); ?>
<?php $this->_tag_stack[] = array('content', array('title' => 'Welcome')); $_block_repeat=true;smarty_block_content($this->_tag_stack[count($this->_tag_stack)-1][1], null, $this, $_block_repeat);while ($_block_repeat) { ob_start(); ?>

Foo

<?php $_block_content = ob_get_contents(); ob_end_clean(); $_block_repeat=false;echo smarty_block_content($this->_tag_stack[count($this->_tag_stack)-1][1], $_block_content, $this, $_block_repeat); }  array_pop($this->_tag_stack); ?>