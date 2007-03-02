<?php /* Smarty version 2.6.13, created on 2007-03-02 22:08:32
         compiled from /home/groups/musicwatcher/htdocs//home.tpl */ ?>
<?php require_once(SMARTY_CORE_DIR . 'core.load_plugins.php');
smarty_core_load_plugins(array('plugins' => array(array('block', 'content', '/home/groups/musicwatcher/htdocs//home.tpl', 1, false),)), $this); ?>
<?php $this->_tag_stack[] = array('content', array('title' => 'Home')); $_block_repeat=true;smarty_block_content($this->_tag_stack[count($this->_tag_stack)-1][1], null, $this, $_block_repeat);while ($_block_repeat) { ob_start(); ?>
  <center>
    <a href="/images/MusicWatcher.jpg"><img src="/images/MusicWatcher.thumb.jpg" width=400 height=215></a>
  </center>

  <h2>News</h2>

  <h3>Proof of Concept</h3>
  <p>We are proud to offer a proof of concept as our first release. It 
     consumes way too much CPU and has some warts but all projects have to 
     start somewhere. <a href="http://prdownload.berlios.de/musicwatcher/MusicWatcher-ProofOfConcept.app.zip">Click here to download.</a>
  <p>
<?php $_block_content = ob_get_contents(); ob_end_clean(); $_block_repeat=false;echo smarty_block_content($this->_tag_stack[count($this->_tag_stack)-1][1], $_block_content, $this, $_block_repeat); }  array_pop($this->_tag_stack); ?>