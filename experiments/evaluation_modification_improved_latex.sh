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
            if [ ! "$noise" -eq "50" ]; do 
                line2echo="$line2echo \\\\"
            done
            echo "$line2echo"
            done
            cd ..
    done
    echo "\\end{tabular}"
    echo "\\caption{Influence of the color handling}"
    echo "\\end{center}"
    echo "\\end{table}"
    
# ICA DBP
    echo ""
    FIRST_SCALE=0
    ROBUST_GRADIENT=0
    GRAYMETHOD=1
    echo "\\begin{table}"
    echo "\\begin{center}"
    echo "\\begin{tabular}{l|l|l|l|l|l|l|l|l|l|l|l}"
    echo "\\multicolumn{2}{l}{} &\\multicolumn{2}{|c|}{L2} & \\multicolumn{2}{c|}{Truncated L2} & \\multicolumn{2}{c|}{German} & \\multicolumn{2}{c|}{Lorentzian} & \\multicolumn{2}{c}{Charbonnier} \\\\"
    echo "\\hline"
    echo "\\multicolumn{2}{l|}{} & &  DBP & & DBP & & DBP & & DBP & & DBP\\\\"
    for noise in 0 3 5 10 20 30 50; do
            dir=noise$noise
            cd $dir
            echo "\\hline"
            
            #RMSE
            line2echo="\\multirow{2}{0.1\\linewidth}{$\sigma = $noise$} & RMSE"
            for ROBUST in 0 1 2 3 4; do
                    for EDGEPADDING in 0 5; do
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
                    for EDGEPADDING in 0 5; do
                        basefile=graymethod${GRAYMETHOD}_save${SAVE}_scale${FIRST_SCALE}_edge${EDGEPADDING}_gradient${ROBUST_GRADIENT}_robust${ROBUST}
                        # field comparison
                        time_ica=time_ica_${basefile}.txt
                        line2echo="$line2echo & `cat $time_ica`"
                    done
            done
            if [ ! "$noise" -eq "50" ]; do 
                line2echo="$line2echo \\\\"
            done
            echo "$line2echo"
            done

            cd ..
    done
    echo "\\end{tabular}"
    echo "\\caption{Influence of discarding boundary pixels (using the gray method)}"
    echo "\\end{center}"
    echo "\\end{table}"

# ICA GRADIENT
    echo ""
    FIRST_SCALE=0
    ROBUST=4
    GRAYMETHOD=1
    EDGEPADDING=5
    echo "\\begin{table}"
    echo "\\begin{center}"
    echo "\\begin{tabular}{l|l|l|l|l|l|l|l}"
    echo "\\multicolumn{2}{l}{} & Central Differences & Hypomode & Farid 3x3 & Farid 5x5 & Gaussian 3 & Gaussian 6 \\\\"
    for noise in 0 3 5 10 20 30 50; do
            dir=noise$noise
            cd $dir
            echo "\\hline"
            
            #RMSE
            line2echo="\\multirow{2}{0.1\\linewidth}{$ \sigma = $noise $} & RMSE"
            for ROBUST_GRADIENT in 0 1 2 3 4 5; do
                basefile=graymethod${GRAYMETHOD}_save${SAVE}_scale${FIRST_SCALE}_edge${EDGEPADDING}_gradient${ROBUST_GRADIENT}_robust${ROBUST}
                # field comparison
                rmse_ica=rmse_ica_${basefile}.txt
                line2echo="$line2echo & `mean_and_std $rmse_ica 0`"
            done
            line2echo="$line2echo \\\\"
            echo "$line2echo"

            #TIME
            line2echo=" & Time"
            for ROBUST_GRADIENT in 0 1 2 3 4 5; do
                basefile=graymethod${GRAYMETHOD}_save${SAVE}_scale${FIRST_SCALE}_edge${EDGEPADDING}_gradient${ROBUST_GRADIENT}_robust${ROBUST}
                # field comparison
                time_ica=time_ica_${basefile}.txt
                line2echo="$line2echo & `cat $time_ica`"
            done
            if [ ! "$noise" -eq "50" ]; do 
                line2echo="$line2echo \\\\"
            done
            echo "$line2echo"
            done
            
            cd ..
    done
    echo "\\end{tabular}"
    echo "\\caption{Influence of the gradient estimator (using the Charbonnier robust function, the gray method and discarding boundary pixels)}"
    echo "\\end{center}"
    echo "\\end{table}"

    
# ICA FIRST SCALE    
    echo ""
    ROBUST_GRADIENT=3
    ROBUST=4
    GRAYMETHOD=1
    EDGEPADDING=5
    echo "\\begin{table}"
    echo "\\begin{center}"
    echo "\\begin{tabular}{l|l|l|l|l|l}"
    echo "\\multicolumn{2}{l}{} & $ s_0 = 0 $ & $ s_0 = 1 $ & $ s_0 = 2 $ & $ s_0 = 3 $ \\\\"
    for noise in 0 3 5 10 20 30 50; do
            dir=noise$noise
            cd $dir
            echo "\\hline"
            
            #RMSE
            line2echo="\\multirow{2}{0.1\\linewidth}{$\sigma = $noise$} & RMSE"
            for FIRST_SCALE in 0 1 2 3; do
                basefile=graymethod${GRAYMETHOD}_save${SAVE}_scale${FIRST_SCALE}_edge${EDGEPADDING}_gradient${ROBUST_GRADIENT}_robust${ROBUST}
                # field comparison
                rmse_ica=rmse_ica_${basefile}.txt
                line2echo="$line2echo & `mean_and_std $rmse_ica 0`"
            done
            line2echo="$line2echo \\\\"
            echo "$line2echo"

            #TIME
            line2echo=" & Time"
            for FIRST_SCALE in 0 1 2 3; do
                basefile=graymethod${GRAYMETHOD}_save${SAVE}_scale${FIRST_SCALE}_edge${EDGEPADDING}_gradient${ROBUST_GRADIENT}_robust${ROBUST}
                # field comparison
                time_ica=time_ica_${basefile}.txt
                line2echo="$line2echo & `cat $time_ica`"
            done
            if [ ! "$noise" -eq "50" ]; do 
                line2echo="$line2echo \\\\"
            done
            echo "$line2echo"
            done

            cd ..
    done
    echo "\\end{tabular}"
    echo "\\caption{Influence of the first scale (using the Charbonnier robust function, the gray method, the Farid 5x5 kernel estimator and discarding boundary pixels)}"
    echo "\\end{center}"
    echo "\\end{table}"

# COMPARISON ALL METHODS    
    echo ""
    ROBUST=4
    GRAYMETHOD=0
    FIRST_SCALE=0
    EDGEPADDING=0
    ROBUST_GRADIENT=0
    echo "\\begin{table}"
    echo "\\begin{center}"
    echo "\\begin{tabular}{l|l|l|l|l|l}"
    echo "\\multicolumn{2}{l}{}  $ SIFT + RANSAC  &  IC & IC optimized $ \\\\"
    for noise in 0 3 5 10 20 30 50; do
            dir=noise$noise
            cd $dir
            echo "\\hline"
            
            basefile=graymethod${GRAYMETHOD}_save${SAVE}_scale${FIRST_SCALE}_edge${EDGEPADDING}_gradient${ROBUST_GRADIENT}_robust${ROBUST}
            
            #RMSE
            line2echo="\\multirow{2}{0.1\\linewidth}{$\sigma = $noise$} & RMSE"
            #sift
            line2echo="$line2echo & `mean_and_std $rmse_sift 0`"

            #ic
            rmse_ica=rmse_ica_${basefile}.txt
            line2echo="$line2echo & `mean_and_std $rmse_ica 0`"

            #ic optimized
            line2echo="$line2echo & ?"
            line2echo="$line2echo \\\\"
            echo "$line2echo"

            #TIME
            line2echo=" & Time"
            #sift
            line2echo="$line2echo & `cat $time_sift`"

            #ic
            time_ica=time_ica_${basefile}.txt
            line2echo="$line2echo & `cat $time_ica`"

            #ic optimized
            line2echo="$line2echo & ?"
            if [ ! "$noise" -eq "50" ]; do 
                line2echo="$line2echo \\\\"
            done
            echo "$line2echo"

            cd ..
    done
    echo "\\end{tabular}"
    echo "\\caption{Comparison of the methods. The two IC variants use the Charbonnier robust function. The optimized IC algorithm uses the gray method, the Farid 5x5 kernel estimator and discards boundary pixels. The first scale used is precised in parenthesis.}"
    echo "\\end{center}"
    echo "\\end{table}"

cd ..
