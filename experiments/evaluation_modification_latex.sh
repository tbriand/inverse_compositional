#!/bin/bash

export LC_NUMERIC=C

# change directory
if [ -z "$1" ]; then
    dir=evaluation_modification
else
    dir=$1
fi

if [ ! -d "$dir" ]; then
    echo "No directory found";
    exit;
fi

cd $dir

# sift files
rmse_sift=rmse_sift.txt
max_sift=max_sift.txt
time_sift=time_sift.txt

# ICA fixed parameters
SAVE=1          #saving with good precision is necessary

# ICA DBP
    echo ""
    FIRST_SCALE=0
    ROBUST_GRADIENT=0
    GRAYMETHOD=0
    echo "\\begin{table}"
    echo "\\begin{center}"
    echo "\\begin{tabular}{l|l|l|l|l|l|l|l}"
    echo "\\multicolumn{2}{l}{} &\\multicolumn{3}{|c|}{L2} & \\multicolumn{3}{c}{Lorentzian} \\\\"
    echo "\\hline"
    echo "\\multicolumn{2}{l|}{} & & DBP $ \delta=0 $ IC & DBP $ \delta=5 $ & IC & DBP $ \delta=0 $ & DBP $ \delta=5 $\\\\"
    for noise in 0 3 5 10 20 30 50; do
            dir=noise$noise
            cd $dir
            echo "\\hline"

            #RMSE
            line2echo="\\multirow{2}{0.1\\linewidth}{$\sigma = $noise$} & EPE"
            for ROBUST in 0 3; do
                    NANIFOUTSIDE=0
                    EDGEPADDING=0
                        basefile=graymethod${GRAYMETHOD}_save${SAVE}_scale${FIRST_SCALE}_edge${EDGEPADDING}_nan${NANIFOUTSIDE}_gradient${ROBUST_GRADIENT}_robust${ROBUST}
                        # field comparison
                        rmse_ica=rmse_ica_${basefile}.txt
                        line2echo="$line2echo & `mean_and_std $rmse_ica 0`"
                    NANIFOUTSIDE=1
                        for EDGEPADDING in 0 5; do
                            basefile=graymethod${GRAYMETHOD}_save${SAVE}_scale${FIRST_SCALE}_edge${EDGEPADDING}_nan${NANIFOUTSIDE}_gradient${ROBUST_GRADIENT}_robust${ROBUST}
                            # field comparison
                            rmse_ica=rmse_ica_${basefile}.txt
                            line2echo="$line2echo & `mean_and_std $rmse_ica 0`"
                        done
            done
            line2echo="$line2echo \\\\"
            echo "$line2echo"

            #TIME
            line2echo=" & Time"
            for ROBUST in 0 3; do
                    NANIFOUTSIDE=0
                    EDGEPADDING=0
                        basefile=graymethod${GRAYMETHOD}_save${SAVE}_scale${FIRST_SCALE}_edge${EDGEPADDING}_nan${NANIFOUTSIDE}_gradient${ROBUST_GRADIENT}_robust${ROBUST}
                        # field comparison
                        time_ica=time_ica_${basefile}.txt
                        vartime=`cat $time_ica`
                        line2echo="$line2echo & `printf "%5.0f" $vartime`"

                    NANIFOUTSIDE=1
                    for EDGEPADDING in 0 5; do
                        basefile=graymethod${GRAYMETHOD}_save${SAVE}_scale${FIRST_SCALE}_edge${EDGEPADDING}_nan${NANIFOUTSIDE}_gradient${ROBUST_GRADIENT}_robust${ROBUST}
                        # field comparison
                        time_ica=time_ica_${basefile}.txt
                        vartime=`cat $time_ica`
                        line2echo="$line2echo & `printf "%5.0f" $vartime`"
                    done
            done
            if [ ! "$noise" -eq "50" ]; then
                line2echo="$line2echo \\\\"
            fi
            echo "$line2echo"

            cd ..
    done
    echo "\\end{tabular}"
    echo "\\caption{Influence of discarding boundary pixels (using the central differences gradient estimator)}"
    echo "\\label{fig::ic_dbp_central_differences}"
    echo "\\end{center}"
    echo "\\end{table}"

#     echo ""
#     FIRST_SCALE=0
#     ROBUST_GRADIENT=3
#     GRAYMETHOD=0
#     echo "\\begin{table}"
#     echo "\\begin{center}"
#     echo "\\begin{tabular}{l|l|l|l|l|l|l|l}"
#     echo "\\multicolumn{2}{l}{} &\\multicolumn{3}{|c|}{L2} & \\multicolumn{3}{c}{Lorentzian} \\\\"
#     echo "\\hline"
#     echo "\\multicolumn{2}{l|}{} & & DBP $ \delta=0 $ & DBP $ \delta=5 $ & & DBP $ \delta=0 $ & DBP $ \delta=5 $\\\\"
#     for noise in 0 3 5 10 20 30 50; do
#             dir=noise$noise
#             cd $dir
#             echo "\\hline"
# 
#             #RMSE
#             line2echo="\\multirow{2}{0.1\\linewidth}{$\sigma = $noise$} & EPE"
#             for ROBUST in 0 3; do
#                     NANIFOUTSIDE=0
#                     EDGEPADDING=0
#                         basefile=graymethod${GRAYMETHOD}_save${SAVE}_scale${FIRST_SCALE}_edge${EDGEPADDING}_nan${NANIFOUTSIDE}_gradient${ROBUST_GRADIENT}_robust${ROBUST}
#                         # field comparison
#                         rmse_ica=rmse_ica_${basefile}.txt
#                         line2echo="$line2echo & `mean_and_std $rmse_ica 0`"
#                     NANIFOUTSIDE=1
#                         for EDGEPADDING in 0 5; do
#                             basefile=graymethod${GRAYMETHOD}_save${SAVE}_scale${FIRST_SCALE}_edge${EDGEPADDING}_nan${NANIFOUTSIDE}_gradient${ROBUST_GRADIENT}_robust${ROBUST}
#                             # field comparison
#                             rmse_ica=rmse_ica_${basefile}.txt
#                             line2echo="$line2echo & `mean_and_std $rmse_ica 0`"
#                         done
#             done
#             line2echo="$line2echo \\\\"
#             echo "$line2echo"
# 
#             #TIME
#             line2echo=" & Time"
#             for ROBUST in 0 3; do
#                     NANIFOUTSIDE=0
#                     EDGEPADDING=0
#                         basefile=graymethod${GRAYMETHOD}_save${SAVE}_scale${FIRST_SCALE}_edge${EDGEPADDING}_nan${NANIFOUTSIDE}_gradient${ROBUST_GRADIENT}_robust${ROBUST}
#                         # field comparison
#                         time_ica=time_ica_${basefile}.txt
#                         vartime=`cat $time_ica`
#                         line2echo="$line2echo & `printf "%5.0f" $vartime`"
# 
#                     NANIFOUTSIDE=1
#                     for EDGEPADDING in 0 5; do
#                         basefile=graymethod${GRAYMETHOD}_save${SAVE}_scale${FIRST_SCALE}_edge${EDGEPADDING}_nan${NANIFOUTSIDE}_gradient${ROBUST_GRADIENT}_robust${ROBUST}
#                         # field comparison
#                         time_ica=time_ica_${basefile}.txt
#                         vartime=`cat $time_ica`
#                         line2echo="$line2echo & `printf "%5.0f" $vartime`"
#                     done
#             done
#             if [ ! "$noise" -eq "50" ]; then
#                 line2echo="$line2echo \\\\"
#             fi
#             echo "$line2echo"
# 
#             cd ..
#     done
#     echo "\\end{tabular}"
#     echo "\\caption{Influence of discarding boundary pixels (using the Farid 5x5 gradient estimator)}"
#     echo "\\label{fig::ic_dbp_farid}"
#     echo "\\end{center}"
#     echo "\\end{table}"

# ICA COLOR
c=`imprintf %c burst_1.tiff`
if [ "$c" -eq "3" ]; then
    echo ""
    FIRST_SCALE=0
    ROBUST_GRADIENT=0
    EDGEPADDING=5
    NANIFOUTSIDE=1
    echo "\\begin{table}"
    echo "\\begin{center}"
    echo "\\begin{tabular}{l|l|l|l|l|l}"
    echo "\\multicolumn{2}{l}{} &\\multicolumn{2}{|c|}{L2} & \\multicolumn{2}{c}{Lorentzian} \\\\"
    echo "\\hline"
    echo "\\multicolumn{2}{l|}{} & & Gray & & Gray\\\\"
    for noise in 0 3 5 10 20 30 50; do
            dir=noise$noise
            cd $dir
            echo "\\hline"

            #RMSE
            line2echo="\\multirow{2}{0.1\\linewidth}{$\sigma = $noise$} & EPE"
            for ROBUST in 0 3; do
                    for GRAYMETHOD in 0 1; do
                        basefile=graymethod${GRAYMETHOD}_save${SAVE}_scale${FIRST_SCALE}_edge${EDGEPADDING}_nan${NANIFOUTSIDE}_gradient${ROBUST_GRADIENT}_robust${ROBUST}
                        # field comparison
                        rmse_ica=rmse_ica_${basefile}.txt
                        line2echo="$line2echo & `mean_and_std $rmse_ica 0`"
                    done
            done
            line2echo="$line2echo \\\\"
            echo "$line2echo"

            #TIME
            line2echo=" & Time"
            for ROBUST in 0 3; do
                    for GRAYMETHOD in 0 1; do
                        basefile=graymethod${GRAYMETHOD}_save${SAVE}_scale${FIRST_SCALE}_edge${EDGEPADDING}_nan${NANIFOUTSIDE}_gradient${ROBUST_GRADIENT}_robust${ROBUST}
                        # field comparison
                        time_ica=time_ica_${basefile}.txt
                        vartime=`cat $time_ica`
                        line2echo="$line2echo & `printf "%5.0f" $vartime`"
                    done
            done
            if [ ! "$noise" -eq "50" ]; then
                line2echo="$line2echo \\\\"
            fi
            echo "$line2echo"

            cd ..
    done
    echo "\\end{tabular}"
    echo "\\caption{Influence of the color handling}"
    echo "\\label{fig::ic_color_handling}"
    echo "\\end{center}"
    echo "\\end{table}"
fi

# ICA GRADIENT
    echo ""
    ROBUST=0
    FIRST_SCALE=0
    GRAYMETHOD=1
    NANIFOUTSIDE=1
    EDGEPADDING=5
    echo "\\begin{table}"
    echo "\\begin{center}"
    echo "\\resizebox{\\textwidth}{!}{"
    echo "\\begin{tabular}{l|l|l|l|l|l|l|l}"
    echo "\\multicolumn{2}{l|}{} & Central Differences & Hypomode & Farid 3x3 & Farid 5x5 & Gaussian 3 & Gaussian 6 \\\\"
    for noise in 0 3 5 10 20 30 50; do
            dir=noise$noise
            cd $dir
            echo "\\hline"

            #RMSE
            line2echo="\\multirow{2}{0.1\\linewidth}{$ \sigma = $noise $} & EPE"
            for ROBUST_GRADIENT in 0 1 2 3 4 5; do
                basefile=graymethod${GRAYMETHOD}_save${SAVE}_scale${FIRST_SCALE}_edge${EDGEPADDING}_nan${NANIFOUTSIDE}_gradient${ROBUST_GRADIENT}_robust${ROBUST}
                # field comparison
                rmse_ica=rmse_ica_${basefile}.txt
                line2echo="$line2echo & `mean_and_std $rmse_ica 0`"
            done
            line2echo="$line2echo \\\\"
            echo "$line2echo"

            #TIME
            line2echo=" & Time"
            for ROBUST_GRADIENT in 0 1 2 3 4 5; do
                basefile=graymethod${GRAYMETHOD}_save${SAVE}_scale${FIRST_SCALE}_edge${EDGEPADDING}_nan${NANIFOUTSIDE}_gradient${ROBUST_GRADIENT}_robust${ROBUST}
                # field comparison
                time_ica=time_ica_${basefile}.txt
                vartime=`cat $time_ica`
                line2echo="$line2echo & `printf "%5.0f" $vartime`"
            done
            if [ ! "$noise" -eq "50" ]; then
                line2echo="$line2echo \\\\"
            fi
            echo "$line2echo"

            cd ..
    done
    echo "\\end{tabular}"
    echo "}"
    echo "\\caption{Influence of the gradient estimator (using the L2 error function and discarding boundary pixels)}"
    echo "\\label{fig::ic_gradient_l2}"
    echo "\\end{center}"
    echo "\\end{table}"

    echo ""
    ROBUST=3
    FIRST_SCALE=0
    GRAYMETHOD=1
    NANIFOUTSIDE=1
    EDGEPADDING=5
    echo "\\begin{table}"
    echo "\\begin{center}"
    echo "\\resizebox{\\textwidth}{!}{"
    echo "\\begin{tabular}{l|l|l|l|l|l|l|l}"
    echo "\\multicolumn{2}{l|}{} & Central Differences & Hypomode & Farid 3x3 & Farid 5x5 & Gaussian 3 & Gaussian 6 \\\\"
    for noise in 0 3 5 10 20 30 50; do
            dir=noise$noise
            cd $dir
            echo "\\hline"

            #RMSE
            line2echo="\\multirow{2}{0.1\\linewidth}{$ \sigma = $noise $} & EPE"
            for ROBUST_GRADIENT in 0 1 2 3 4 5; do
                basefile=graymethod${GRAYMETHOD}_save${SAVE}_scale${FIRST_SCALE}_edge${EDGEPADDING}_nan${NANIFOUTSIDE}_gradient${ROBUST_GRADIENT}_robust${ROBUST}
                # field comparison
                rmse_ica=rmse_ica_${basefile}.txt
                line2echo="$line2echo & `mean_and_std $rmse_ica 0`"
            done
            line2echo="$line2echo \\\\"
            echo "$line2echo"

            #TIME
            line2echo=" & Time"
            for ROBUST_GRADIENT in 0 1 2 3 4 5; do
                basefile=graymethod${GRAYMETHOD}_save${SAVE}_scale${FIRST_SCALE}_edge${EDGEPADDING}_nan${NANIFOUTSIDE}_gradient${ROBUST_GRADIENT}_robust${ROBUST}
                # field comparison
                time_ica=time_ica_${basefile}.txt
                vartime=`cat $time_ica`
                line2echo="$line2echo & `printf "%5.0f" $vartime`"
            done
            if [ ! "$noise" -eq "50" ]; then
                line2echo="$line2echo \\\\"
            fi
            echo "$line2echo"

            cd ..
    done
    echo "\\end{tabular}"
    echo "}"
    echo "\\caption{Influence of the gradient estimator (using the Lorentzian error function and discarding boundary pixels)}"
    echo "\\label{fig::ic_gradient_lorentzian}"
    echo "\\end{center}"
    echo "\\end{table}"

# ICA FIRST SCALE
    echo ""
    ROBUST=0
    ROBUST_GRADIENT=3
    GRAYMETHOD=1
    NANIFOUTSIDE=1
    EDGEPADDING=5
    echo "\\begin{table}"
    echo "\\begin{center}"
    echo "\\begin{tabular}{l|l|l|l|l|l}"
    echo "\\multicolumn{2}{l|}{} & $ s_0 = 0 $ & $ s_0 = 1 $ & $ s_0 = 2 $ & $ s_0 = 3 $ \\\\"
    for noise in 0 3 5 10 20 30 50; do
            dir=noise$noise
            cd $dir
            echo "\\hline"

            #RMSE
            line2echo="\\multirow{2}{0.1\\linewidth}{$\sigma = $noise$} & EPE"
            for FIRST_SCALE in 0 1 2 3; do
                basefile=graymethod${GRAYMETHOD}_save${SAVE}_scale${FIRST_SCALE}_edge${EDGEPADDING}_nan${NANIFOUTSIDE}_gradient${ROBUST_GRADIENT}_robust${ROBUST}
                # field comparison
                rmse_ica=rmse_ica_${basefile}.txt
                line2echo="$line2echo & `mean_and_std $rmse_ica 0`"
            done
            line2echo="$line2echo \\\\"
            echo "$line2echo"

            #TIME
            line2echo=" & Time"
            for FIRST_SCALE in 0 1 2 3; do
                basefile=graymethod${GRAYMETHOD}_save${SAVE}_scale${FIRST_SCALE}_edge${EDGEPADDING}_nan${NANIFOUTSIDE}_gradient${ROBUST_GRADIENT}_robust${ROBUST}
                # field comparison
                time_ica=time_ica_${basefile}.txt
                vartime=`cat $time_ica`
                line2echo="$line2echo & `printf "%5.0f" $vartime`"
            done
            if [ ! "$noise" -eq "50" ]; then
                line2echo="$line2echo \\\\"
            fi
            echo "$line2echo"

            cd ..
    done
    echo "\\end{tabular}"
    echo "\\caption{Influence of the first scale (using the L2 error function and the Farid 5x5 kernel estimator and discarding boundary pixels)}"
    echo "\\label{fig::ic_first_scale_l2}"
    echo "\\end{center}"
    echo "\\end{table}"

    echo ""
    ROBUST=3
    ROBUST_GRADIENT=3
    GRAYMETHOD=1
    NANIFOUTSIDE=1
    EDGEPADDING=5
    echo "\\begin{table}"
    echo "\\begin{center}"
    echo "\\begin{tabular}{l|l|l|l|l|l}"
    echo "\\multicolumn{2}{l|}{} & $ s_0 = 0 $ & $ s_0 = 1 $ & $ s_0 = 2 $ & $ s_0 = 3 $ \\\\"
    for noise in 0 3 5 10 20 30 50; do
            dir=noise$noise
            cd $dir
            echo "\\hline"

            #RMSE
            line2echo="\\multirow{2}{0.1\\linewidth}{$\sigma = $noise$} & EPE"
            for FIRST_SCALE in 0 1 2 3; do
                basefile=graymethod${GRAYMETHOD}_save${SAVE}_scale${FIRST_SCALE}_edge${EDGEPADDING}_nan${NANIFOUTSIDE}_gradient${ROBUST_GRADIENT}_robust${ROBUST}
                # field comparison
                rmse_ica=rmse_ica_${basefile}.txt
                line2echo="$line2echo & `mean_and_std $rmse_ica 0`"
            done
            line2echo="$line2echo \\\\"
            echo "$line2echo"

            #TIME
            line2echo=" & Time"
            for FIRST_SCALE in 0 1 2 3; do
                basefile=graymethod${GRAYMETHOD}_save${SAVE}_scale${FIRST_SCALE}_edge${EDGEPADDING}_nan${NANIFOUTSIDE}_gradient${ROBUST_GRADIENT}_robust${ROBUST}
                # field comparison
                time_ica=time_ica_${basefile}.txt
                vartime=`cat $time_ica`
                line2echo="$line2echo & `printf "%5.0f" $vartime`"
            done
            if [ ! "$noise" -eq "50" ]; then
                line2echo="$line2echo \\\\"
            fi
            echo "$line2echo"

            cd ..
    done
    echo "\\end{tabular}"
    echo "\\caption{Influence of the first scale (using the Lorentzian error function and the Farid 5x5 kernel estimator and discarding boundary pixels)}"
    echo "\\label{fig::ic_first_scale_lorentzian}"
    echo "\\end{center}"
    echo "\\end{table}"

# COMPARISON ALL METHODS
    echo ""
    echo "\\begin{table}"
    echo "\\begin{center}"
    echo "\\begin{tabular}{l|l|l|l|l|l|l|l|l}"
    echo "\\multicolumn{3}{l|}{} & \\multicolumn{3}{c|}{L2} & \\multicolumn{3}{c}{Lorentzian} \\\\"
    echo "\\hline"
    echo "\\multicolumn{2}{l|}{} & SIFT + R & IC & M-IC & F-IC & IC & M-IC & F-IC \\\\"
    for noise in 0 3 5 10 20 30 50; do
            dir=noise$noise
            cd $dir
            echo "\\hline"

            #RMSE
            line2echo="\\multirow{2}{0.1\\linewidth}{$\sigma = $noise$} & EPE"
            #sift
            line2echo="$line2echo & `mean_and_std $rmse_sift 0`"

            for ROBUST in 0 3; do
		#ic
		GRAYMETHOD=0
		EDGEPADDING=0
                NANIFOUTSIDE=0
                ROBUST_GRADIENT=0
                FIRST_SCALE=0
                basefile=graymethod${GRAYMETHOD}_save${SAVE}_scale${FIRST_SCALE}_edge${EDGEPADDING}_nan${NANIFOUTSIDE}_gradient${ROBUST_GRADIENT}_robust${ROBUST}
                rmse_ica=rmse_ica_${basefile}.txt
                line2echo="$line2echo & `mean_and_std $rmse_ica 0`"
                #ic optimized
		GRAYMETHOD=1
                EDGEPADDING=5
                NANIFOUTSIDE=1
                ROBUST_GRADIENT=3
                FIRST_SCALE=0
                basefile=graymethod${GRAYMETHOD}_save${SAVE}_scale${FIRST_SCALE}_edge${EDGEPADDING}_nan${NANIFOUTSIDE}_gradient${ROBUST_GRADIENT}_robust${ROBUST}
                rmse_ica=rmse_ica_${basefile}.txt
                line2echo="$line2echo & `mean_and_std $rmse_ica 0`"
		#ic fast
		GRAYMETHOD=1
		EDGEPADDING=5
                NANIFOUTSIDE=1
                ROBUST_GRADIENT=3
                FIRST_SCALE=1
                basefile=graymethod${GRAYMETHOD}_save${SAVE}_scale${FIRST_SCALE}_edge${EDGEPADDING}_nan${NANIFOUTSIDE}_gradient${ROBUST_GRADIENT}_robust${ROBUST}
                rmse_ica=rmse_ica_${basefile}.txt
                line2echo="$line2echo & `mean_and_std $rmse_ica 0`"
            done

            line2echo="$line2echo \\\\"
            echo "$line2echo"

            #TIME
            line2echo=" & Time"
            #sift
            vartime=`cat $time_sift`
            line2echo="$line2echo & `printf "%5.0f" $vartime`"

            for ROBUST in 0 3; do
                #ic
		GRAYMETHOD=0
		EDGEPADDING=0
                NANIFOUTSIDE=0
                ROBUST_GRADIENT=0
                FIRST_SCALE=0
                basefile=graymethod${GRAYMETHOD}_save${SAVE}_scale${FIRST_SCALE}_edge${EDGEPADDING}_nan${NANIFOUTSIDE}_gradient${ROBUST_GRADIENT}_robust${ROBUST}
                time_ica=time_ica_${basefile}.txt
                vartime=`cat $time_ica`
                line2echo="$line2echo & `printf "%5.0f" $vartime`"
                #ic optimized
		GRAYMETHOD=1
                EDGEPADDING=5
                NANIFOUTSIDE=1
                ROBUST_GRADIENT=3
                FIRST_SCALE=0
                basefile=graymethod${GRAYMETHOD}_save${SAVE}_scale${FIRST_SCALE}_edge${EDGEPADDING}_nan${NANIFOUTSIDE}_gradient${ROBUST_GRADIENT}_robust${ROBUST}
                time_ica=time_ica_${basefile}.txt
                vartime=`cat $time_ica`
                line2echo="$line2echo & `printf "%5.0f" $vartime`"
		#ic fast
		GRAYMETHOD=1
                EDGEPADDING=5
                NANIFOUTSIDE=1
                ROBUST_GRADIENT=3
                FIRST_SCALE=1
                basefile=graymethod${GRAYMETHOD}_save${SAVE}_scale${FIRST_SCALE}_edge${EDGEPADDING}_nan${NANIFOUTSIDE}_gradient${ROBUST_GRADIENT}_robust${ROBUST}
                time_ica=time_ica_${basefile}.txt
                vartime=`cat $time_ica`
                line2echo="$line2echo & `printf "%5.0f" $vartime`"
            done

            if [ ! "$noise" -eq "50" ]; then
                line2echo="$line2echo \\\\"
            fi
            echo "$line2echo"

            cd ..
    done
    echo "\\end{tabular}"
    echo "\\caption{Comparison of motion estimation methods: SIFT+RANSAC (SIFT+R), IC algorithm (IC) described in Algorithm~\\ref{algo::ic_sanchez_multiscale}, Modified IC algorithm (M-IC) and Fast IC algorithm (F-IC). The IC algorithm uses the Farid 5x5 kernel estimator and discards boundary pixels with $ \delta = 5 $.}"
    echo "\\label{fig::ic_all_comparisons}"
    echo "\\end{center}"
    echo "\\end{table}"

cd ..
