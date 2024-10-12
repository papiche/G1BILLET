<?php
$mytime = new Datetime("now");
$timestamp = $mytime->format('U').rand();

/// BROKEN PREFER DAEMON MODE
// CREATE 6 G1BILLETS in /tmp/g1billet/$timestamp
$page = shell_exec(dirname(__FILE__)."/G1BILLETS.sh '".$_REQUEST['montant']."' '".$timestamp."' '".$_REQUEST['style']."'");

if ( $_REQUEST['style'] == 'ticket' || $_REQUEST['style'] == 'xbian' || $_REQUEST['style'] == 'astro' ) {
    $file_type = "jpg";
} else {
    $file_type = "pdf";
}
$attachment_location = dirname(__FILE__)."/tmp/g1billet/".$timestamp.".".$file_type;

if (file_exists($attachment_location)) {
    header($_SERVER["SERVER_PROTOCOL"] . " 200 OK");
    header("Cache-Control: public"); // needed for internet explorer
    header("Content-Type: application/".$file_type);
    header("Content-Transfer-Encoding: Binary");
    header("Content-Length:".filesize($attachment_location));
    header("Content-Disposition: attachment; filename=".$timestamp.".".$file_type);
    readfile($attachment_location);
    unlink(dirname(__FILE__)."/tmp/g1billet/".$timestamp.".".$file_type);
    die();
} else {
    die("Error: File not found.".$attachment_location);
}
?>

