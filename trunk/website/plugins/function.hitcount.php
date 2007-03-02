<?
function smarty_function_hitcount() {
    global $ROOT;
    global $PATH;

    $dir = "$ROOT/logs/hitcount";
    $file = "$dir/" . urlencode($PATH);
    $lockfile = "$file.lck";

    if (($fp = fopen($file, "a+")) == FALSE) {
        return "OPEN_ERROR";
    }

    if (($lockfp = fopen($lockfile, "a")) == FALSE) {
        return "OPEN_ERROR";
    }
    
    if (! flock($lockfp, LOCK_EX)) {
        return "LOCK_ERROR";
    }

    $size = filesize($file);
    if ($size == 0) {
        $count = 0;
    } else {
        $count = fread($fp, $size); 
    }

    $count++;

    if (! fclose($fp)) {
        return "CLOSE_ERROR";
    }

    if (($fp = fopen($file, "w")) == FALSE) {
        return "OPEN_ERROR";
    }

    if (! fwrite($fp, $count)) {
        return "WRITE_ERROR";
    } 

    if (! flock($lockfp, LOCK_UN)) {
        return "UNLOCK_ERROR";
    }

    if (! fclose($fp)) {
        return "CLOSE_ERROR";
    }

    return $count;
    
}

?>
