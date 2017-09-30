#!/bin/bash 


cat d-info-header > debug-info.cfg
export_started1=false
export_started2=false
while read line
do
    if [ "$line" == "Exports list by name:" ] ; then
        export_started1=true
        continue
    fi
    if [ "$line" == "Exports list by value:" ] ; then
        export_started2=true
        continue
    fi
    if [ "$line" == "Exports list:" ] ; then
        export_started2=true
        continue
    fi
    if [ -z "$line" ] ; then
        continue
    fi
    if [ "$line" == "Imports list:" ] ; then
        break
    fi

    if [ $export_started1 == true -o $export_started2 == true ] ; then
#        echo $line
        ##parse token.
        t1=""
        t2=""
        t3=""
        i=0
        for t in $line
        do
            case $((i%3)) in
                0)
                    t1=$t
                    ;;
                1)
                    t2=$t
                    ;;
                2)
                    t3=$t
                    if [ "$t3" == "RLA" ] ; then
                        #echo $t1 $t2
                        echo "LABEL { NAME \"$t1\";     ADDR  \$$t2;   };" >> debug-info.cfg.tmp
                    fi
                    ;;
            esac
            i=$((i+1))
        done
    fi

done < duper-rom.map

cat debug-info.cfg.tmp | sort | uniq >> debug-info.cfg
da65 --verbose -i debug-info.cfg
rm debug-info.cfg.tmp debug-info.cfg

