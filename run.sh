
#!/bin/bash

debug_str="import pydevd;pydevd.settrace('localhost', port=8081, stdoutToServer=True, stderrToServer=True)"
# pydevd module path
export PYTHONPATH=/home/shhs/Desktop/user/soft/pycharm-2018.1.4/debug-eggs/pycharm-debug-py3k.egg_FILES

insert_debug_string()
{
    file=$1
    line=$2
    debug_string=$3

    value=`sed -n ${line}p "$file"`

    if [ "$value" != "$debug_string" ]
    then
    echo "++Insert $debug_string in line_${line}++"

    sed "${line}s/^/\n/" -i $file
    sed -i "${line}s:^:${debug_string}:" "$file"
    fi
}

delete_debug_string()
{
    file=$1
    line=$2
    debug_string=$3

    value=`sed -n ${line}p "$file"`
    if [ "$value" = "$debug_string" ]
    then
    echo "--Delete $debug_string in line_${line}--"
    sed "${line}d" -i "$file"
    fi
}

rebuild_cython()
{
    rm -rf build
    python setup.py build_ext --inplace
}

# python3.6 tf_1_6
source $HOME/anaconda3/bin/activate tf_1_6
export LD_LIBRARY_PATH=/usr/local/cudnn-9.0-v7.1/lib64:/usr/local/cuda-9.0/lib64:$LD_LIBRARY_PATH

if [ "$1" = build ]
then
#   ./run.sh build
    rebuild_cython

elif [ "$1" = "notebooks/plot_OT_1D.ipynb" ]
then
    # ./run.sh "notebooks/plot_OT_1D.ipynb" debug
    # ./run.sh "notebooks/plot_OT_1D.ipynb" debug-cpp

    file="plot_OT_1D.py"
    line=22
    if [ $2 = debug ]
    then
        rebuild_cython
        cd notebooks
        insert_debug_string "$file" $line "$debug_str"
        python "$file"
        delete_debug_string "$file" $line "$debug_str"
    elif [ $2 = debug-cpp ]
    then
        rebuild_cython
        cd notebooks
#        gdbserver localhost:8080 python $file

    elif [ $2 = jupyter ]
    then
        jupyter notebook --browser google-chrome

    else
        cd notebooks
        python $file
    fi

elif [ "$1" = "notebooks/plot_otda_mapping.ipynb" ]
then
    # ./run.sh "notebooks/plot_otda_mapping.ipynb" debug
    # ./run.sh "notebooks/plot_otda_mapping.ipynb" jupyter

    file="plot_otda_mapping.py"
    line=22
    if [ $2 = debug ]
    then
        # rebuild_cython
        cd notebooks
        insert_debug_string "$file" $line "$debug_str"
        python "$file"
        delete_debug_string "$file" $line "$debug_str"
    elif [ $2 = debug-cpp ]
    then
        rebuild_cython
        cd notebooks
#        gdbserver localhost:8080 python $file

    elif [ $2 = jupyter ]
    then
        jupyter notebook --browser google-chrome

    else
        cd notebooks
        python $file
    fi

else
    echo NoParameter
fi