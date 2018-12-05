#!/bin/sh
options=':the:u:p:'
user=user

function help () {
  cat <<-END

${SCRIPT_TITLE}
--------------------
Usage: $0 -e ENV -p PASSWORD [-t][-u user]
------
   -e | enviornment.
   -u | user (default: user).
   -p | password.
   -t | Test connection to the DB (requires -e and -p, optionally -u).
   -h | Display this help.

END
}

function test () {
  echo "exit" | sqlplus -L ${user}/${pass}@${env} | grep Connected > /dev/null
  if [ $? -eq 0 ]
  then
    echo "Connection to ${env} is OK"
  else
    echo "Connection to ${env} is NOT OK"
  fi
}

while getopts $options option
do
  case $option in
    e  ) env=$OPTARG;;
    p  ) pass=$OPTARG;;
    u  ) user=$OPTARG;;
    t  ) test=TRUE;;
    h  ) help
         exit 0;;
    \? ) echo "Invalid Option: -$OPTARG" 1>&2
         help
         exit 1;;
    *  ) help
         exit 1;;
  esac
done

shift $(($OPTIND - 1))

if [[ -z ${env} ]] || [[ -z ${pass} ]]; then
  help
  exit 1
fi

if [[ ${test} ]]
then
  test
  exit 0
fi

sqlplus -s /nolog << EOF
connect ${user}/${pass}@${env};

whenever sqlerror exit sql.sqlcode;
set echo off
set heading off

@pre_load.sql

exit;
EOF

sqlldr userid=${user}/${pass}@${env} control=${control_file}.ctl log=logs/${control_file}.log \
  bad=logs/${control_file}.bad discard=logs/${control_file}.dsc

sqlplus -s /nolog << EOF
connect ${user}/${pass}@${env};

whenever sqlerror exit sql.sqlcode;
set echo off
set heading off

@post_load.sql

exit;
EOF
