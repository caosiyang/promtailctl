#! /bin/bash

# Promtail control script.

readonly promtail_install_dir=$(dirname $(readlink -f $0))
readonly promtail_binary=$promtail_install_dir/bin/promtail
readonly promtail_config=$promtail_install_dir/conf/promtail.yaml
readonly promtail_pidfile=$promtail_install_dir/conf/promtail.pid
readonly promtail_logfile=$promtail_install_dir/logs/promtail.log

function print_help() {
    echo "Usage:"
    echo "  $0 [start|stop|status|restart]"
}

function abort() {
    echo "Aborted: $1"
    exit 1
}

function must_exist_files() {
    for file in $@; do
        test -f $file || abort "Error: not found $file"
    done
}

function must_exist_folders() {
    for dir in $@; do
        test -d $dir || abort "Error: not found $dir"
    done
}

function start() {
    if [ -f $promtail_pidfile ]; then
        pid=$(cat $promtail_pidfile)
        if [ -d /proc/$pid ]; then
            echo "promtail (pid $pid) is already running, do nothing"
            return 0
        fi
    fi
    echo -n "Starting promtail: "
    $promtail_binary -config.file $promtail_config >> $promtail_logfile 2>&1 &
    if [ $? -eq 0 ]; then
        echo $! > $promtail_pidfile
        echo -e "\t[ \033[32mOK\033[0m ]"
        return 0
    else
        echo -e "\t[ \033[31mFAILED\033[0m ]"
        echo "check error details in $promtail_logfile"
        return 1
    fi
}

function stop() {
    if [ -f $promtail_pidfile ]; then
        pid=$(cat $promtail_pidfile)
        if [ -d /proc/$pid ]; then
            echo -n "Stopping promtail: "
            kill $pid
            retcode=1
            for i in {1..100}; do
                if [ ! -d /proc/$pid ]; then
                    rm $promtail_pidfile
                    echo -e "\t[ \033[32mOK\033[0m ]"
                    return 0
                fi
                sleep 0.2
            done
            echo -e "\t[ \033[31mFAILED\033[0m ]"
            return 1
        else
            rm $promtail_pidfile
        fi
    fi
    echo "promtail is already stopped, do nothing"
    return 0
}

function status() {
    if [ -f $promtail_pidfile ]; then
        pid=$(cat $promtail_pidfile)
        if [ -d /proc/$pid ]; then
            echo "promtail (pid $pid) is running..."
            return 0
        fi
    fi
    echo "promtail is stopped"
    return 0
}

function restart() {
    echo "Restarting promtail: "
    stop
    start
}

function main() {
    if [ $# -ne 1 ]; then
        echo "Error: missing argument"
        print_help
        exit 1
    fi
    
    must_exist_folders $promtail_install_dir
    test -d $promtail_install_dir/logs || mkdir $promtail_install_dir/logs || abort "cannot create directory $promtail_install_dir/logs"
    must_exist_files $promtail_binary $promtail_config
    
    case $1 in
        start)
            start
            ;;
        stop)
            stop
            ;;
        status)
            status
            ;;
        restart)
            restart
            ;;
        *)
            echo 'Error: invalid argument'
            print_help
            exit 1
    esac
}

main "$@"
