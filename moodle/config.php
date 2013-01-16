<?php  // Moodle configuration file

$stage = 'STAGE';

unset($CFG);
global $CFG;
$CFG = new stdClass();

#@error_reporting(E_ALL | E_STRICT); // NOT FOR PRODUCTION SERVERS!
#@ini_set('display_errors', '1');    // NOT FOR PRODUCTION SERVERS!
#$CFG->debug = (E_ALL | E_STRICT);   // === DEBUG_DEVELOPER - NOT FOR PRODUCTION SERVERS!
#$CFG->debugdisplay = 1;             // NOT FOR PRODUCTION SERVERS!

$CFG->dbtype    = 'mysqli';
$CFG->dblibrary = 'native';
$CFG->dbhost    = 'db.infiniterooms.co.uk';
$CFG->dbname    = "moodle_$stage";
$CFG->dbuser    = "moodle_$stage";
$CFG->dbpass    = 't4eCWhO66fSHqLt';
$CFG->prefix    = 'mdl_';
$CFG->dboptions = array (
  'dbpersist' => 0,
  'dbsocket' => 0,
);

if ($stage == 'prod') {
	$CFG->wwwroot = 'https://www.infiniterooms.co.uk/moodle';
} else {
	$CFG->wwwroot = "https://$stage.infiniterooms.co.uk/moodle";
}

$CFG->dataroot  = "/var/moodle/$stage";
$CFG->admin     = 'admin';

$CFG->directorypermissions = 0777;

$CFG->passwordsaltmain = ')9yh;DL9B';

require_once(dirname(__FILE__) . '/lib/setup.php');

// There is no php closing tag in this file,
// it is intentional because it prevents trailing whitespace problems!
