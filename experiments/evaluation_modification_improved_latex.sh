#!/bin/bash

# change directory
dir=evaluation_modification
cd $dir

# sift files
rmse_sift=rmse_sift.txt
max_sift=max_sift.txt
time_sift=time_sift.txt

# ICA fixed parameters
SAVE=1          #saving with good precision is necessary

# sift table
    echo "\\begin{table}"
    echo "\\begin{center}"
    echo "\\begin{tabular}{l|l|l|l|l|l|l|l}"
    echo "& $\\sigma = 0$ & $\\sigma = 3$ & $\\sigma = 5$ & $\\sigma = 10$ & $\\sigma = 20$ & $\\sigma = 30$ & $\\sigma = 50$  \\\\"
    echo "\\hline"

    # RMSE
    line2echo="RMSE"
    for noise in 0 3 5 10 20 30 50; do
        dir=noise$noise
        cd $dir
        line2echo="$line2echo & `mean_and_std $rmse_sift 0`"
        cd ..
    done
    line2echo="$line2echo \\\\"
    echo "$line2echo"

    # TIME
    line2echo="Time"
    for noise in 0 3 5 10 20 30 50; do
        dir=noise$noise
        cd $dir
        line2echo="$line2echo & `cat $time_sift`"
        cd ..
    done
    echo "$line2echo"
    echo "\\end{tabular}"
    echo "\\caption{SIFT + RANSAC estimation}"
    echo "\\end{center}"
    echo "\\end{table}"

#                             basefile=graymethod${GRAYMETHOD}_save${SAVE}_scale${FIRST_SCALE}_edge${EDGEPADDING}_gradient${ROBUST_GRADIENT}_robust${ROBUST}
#                             time_ica=time_ica_${basefile}.txt
#                             rmse_ica=rmse_ica_${basefile}.txt
# ICA COLOR
    echo ""
    FIRST_SCALE=0
    ROBUST_GRADIENT=0
    EDGEPADDING=0
    echo "\\begin{table}"
    echo "\\begin{center}"
    echo "\\begin{tabular}{l|l|l|l|l|l|l|l|l|l|l|l}"
    echo "\\multicolumn{2}{l}{} &\\multicolumn{2}{|c|}{L2} & \\multicolumn{2}{c|}{Truncated L2} & \\multicolumn{2}{c|}{German} & \\multicolumn{2}{c|}{Lorentzian} & \\multicolumn{2}{c}{Charbonnier} \\\\"
    echo "\\hline"
    echo "\\multicolumn{2}{l|}{} & &  Gray & & Gray & & Gray & & Gray & & Gray\\\\"
    for noise in 0 3 5 10 20 30 50; do
            dir=noise$noise
            cd $dir
            echo "\\hline"
            
            #RMSE
            line2echo="\\multirow{2}{0.1\\linewidth}{$\sigma = $noise$} & RMSE"
            for ROBUST in 0 1 2 3 4; do
                    for GRAYMETHOD in 0 1; do
                        basefile=graymethod${GRAYMETHOD}_save${SAVE}_scale${FIRST_SCALE}_edge${EDGEPADDING}_gradient${ROBUST_GRADIENT}_robust${ROBUST}
                        # field comparison
                        rmse_ica=rmse_ica_${basefile}.txt
                        line2echo="$line2echo & `mean_and_std $rmse_ica 0`"
                    done
            done
            line2echo="$line2echo \\\\"
            echo "$line2echo"

            #TIME
            line2echo=" & Time"
            for ROBUST in 0 1 2 3 4; do
                    for GRAYMETHOD in 0 1; do
                        basefile=graymethod${GRAYMETHOD}_save${SAVE}_scale${FIRST_SCALE}_edge${EDGEPADDING}_gradient${ROBUST_GRADIENT}_robust${ROBUST}
                        # field comparison
                        time_ica=time_ica_${basefile}.txt
                        line2echo="$line2echo & `cat $time_ica`"
                    done
            done
            line2echo="$line2echo \\\\"
            echo "$line2echo"
            done

            echo "\\end{tabular}"
            echo "\\caption{Influence of the color handling}"
            echo "\\end{center}"
            echo "\\end{table}"

            cd ..
    done

cd ..
