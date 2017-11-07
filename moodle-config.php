<?php  // Moodle configuration file

unset($CFG);
global $CFG;
$CFG = new stdClass();

$CFG->dbtype    = 'mysqli';
$CFG->dblibrary = 'native';
$CFG->dbhost    = 'mysql';                // This is the name of the database service in docker-compose.yml
$CFG->dbname    = getenv("MOODLE_DB_NAME");
$CFG->dbuser    = getenv("MOODLE_DB_USER");
$CFG->dbpass    = getenv("MOODLE_DB_PASS");
$CFG->prefix    = 'mdl_';
$CFG->dboptions = array (
  'dbpersist' => 0,
  'dbport' => '',
  'dbsocket' => '',
);

$CFG->wwwroot   = 'https://moodle.example.com';
$CFG->dataroot  = '/var/moodledata';
$CFG->admin     = 'admin';

//Cluster-specific settings - see config-dist.php for descriptions
$CFG->sslproxy = true;

$CFG->directorypermissions = 0777;

require_once(dirname(__FILE__) . '/lib/setup.php');

// There is no php closing tag in this file,
// it is intentional because it prevents trailing whitespace problems!
