#!/bin/bash

# create directory
dir=evaluation_modification
cd $dir
#
# # global file to store the result
# global_results=latex_tables.txt

# sift parameters
rmse_sift=rmse_sift.txt
max_sift=max_sift.txt

# sift table
    echo "\\begin{table}"
    echo "\\begin{center}"
    echo "\\begin{tabular}{l|l|l|l|l}"
    echo "& $\\sigma = 0$ & $\\sigma = 3$ & $\\sigma = 5$ & $\\sigma = 10$\\\\"
    echo "\\hline"

    # RMSE
    line2echo="RMSE"
    for noise in 0 5 10 30; do
        dir=noise$noise
        cd $dir
        line2echo="$line2echo & `mean_and_std $rmse_sift 0`"
        cd ..
    done
    line2echo="$line2echo \\\\"
    echo "$line2echo"

    # RMSE std
    line2echo="Std"
    for noise in 0 3 5 10; do
        dir=noise$noise
        cd $dir
        line2echo="$line2echo & `mean_and_std $rmse_sift 1`"
        cd ..
    done
    line2echo="$line2echo \\\\"
    echo "$line2echo"
    echo "\\hline"

    # RMSE
    line2echo="Max"
    for noise in 0 3 5 10; do
        dir=noise$noise
        cd $dir
        line2echo="$line2echo & `mean_and_std $max_sift 0`"
        cd ..
    done
    line2echo="$line2echo \\\\"
    echo "$line2echo"

    # RMSE std
    line2echo="Std"
    for noise in 0 3 5 10; do
        dir=noise$noise
        cd $dir
        line2echo="$line2echo & `mean_and_std $max_sift 1`"
        cd ..
    done
    line2echo="$line2echo \\\\"
    echo "$line2echo"
    echo "\\hline"

    echo "Time & v1 & v2 & v3 & v4"
    echo "\\end{tabular}"
    echo "\\caption{SIFT + RANSAC estimation}"
    echo "\\end{center}"
    echo "\\end{table}"

# ICA
    NORMALIZATION=0
    FIRST_SCALE=0
    # loop over the noise level
    # echo "Starting the loop"
    for noise in 0 5 10 30; do
    #for noise in 0 3 5; do
        dir=noise$noise
        cd $dir
        echo ""
        echo "\\begin{table}"
        echo "\\begin{center}"
        echo "\\begin{tabular}{l|l|l|l|l|l|l|l|l|l|l|l}"
        echo "\\multicolumn{2}{l}{} &\\multicolumn{2}{|c|}{L2} & \\multicolumn{2}{c|}{Truncated L2} & \\multicolumn{2}{c|}{German} & \\multicolumn{2}{c|}{Lorentzian} & \\multicolumn{2}{c}{Charbonnier} \\\\"
        echo "\\hline"
        echo "\\multicolumn{2}{l|}{} & &  DBV & & DBV & & DBV & & DBV & & DBV\\\\"
        echo "\\hline"

        declare -a arr=("Central" "Hypomode" "Farid 3x3" "Farid 5x5" "Gaussian $\\sigma = 0.3$" "Gaussian $\\sigma = 0.6$")
        ROBUST_GRADIENT=0
        for gradient in "${arr[@]}"; do
            #RMSE
            line2echo="\\multirow{5}{0.1\\linewidth}{$gradient} & RMSE"
            for ROBUST in 0 1 2 3 4; do
                for EDGEPADDING in 0 5; do
                    basefile=scale${FIRST_SCALE}_edge${EDGEPADDING}_gradient${ROBUST_GRADIENT}_robust${ROBUST}
                    # field comparison
                    rmse_ica=rmse_ica_${basefile}.txt
                    max_ica=max_ica_${basefile}.txt
                    line2echo="$line2echo & `mean_and_std $rmse_ica 0`"
                done
            done
            line2echo="$line2echo \\\\"
            echo "$line2echo"
            
            #RMSE STD
            line2echo="& Std"
            for ROBUST in 0 1 2 3 4; do
                for EDGEPADDING in 0 5; do
                    basefile=scale${FIRST_SCALE}_edge${EDGEPADDING}_gradient${ROBUST_GRADIENT}_robust${ROBUST}
                    # field comparison
                    rmse_ica=rmse_ica_${basefile}.txt
                    max_ica=max_ica_${basefile}.txt
                    line2echo="$line2echo & `mean_and_std $rmse_ica 1`"
                done
            done
            line2echo="$line2echo \\\\"
            echo "$line2echo"
            
            #MAX
            line2echo="& Max"
            for ROBUST in 0 1 2 3 4; do
                for EDGEPADDING in 0 5; do
                    basefile=scale${FIRST_SCALE}_edge${EDGEPADDING}_gradient${ROBUST_GRADIENT}_robust${ROBUST}
                    # field comparison
                    rmse_ica=rmse_ica_${basefile}.txt
                    max_ica=max_ica_${basefile}.txt
                    line2echo="$line2echo & `mean_and_std $max_ica 0`"
                done
            done
            line2echo="$line2echo \\\\"
            echo "$line2echo"
            
            #RMSE STD
            line2echo="& Std"
            for ROBUST in 0 1 2 3 4; do
                for EDGEPADDING in 0 5; do
                    basefile=scale${FIRST_SCALE}_edge${EDGEPADDING}_gradient${ROBUST_GRADIENT}_robust${ROBUST}
                    # field comparison
                    rmse_ica=rmse_ica_${basefile}.txt
                    max_ica=max_ica_${basefile}.txt
                    line2echo="$line2echo & `mean_and_std $max_ica 1`"
                done
            done
            line2echo="$line2echo \\\\"
            echo "$line2echo"
            
            if [ "$ROBUST_GRADIENT" -eq "5" ]; then 
                echo "& Time & v1 & v2 & v3 & v4 & v5 & v6 & v7 & v8 & v9 & v10"
            else
                echo "& Time & v1 & v2 & v3 & v4 & v5 & v6 & v7 & v8 & v9 & v10\\\\"
                echo "\\hline"
            fi
            ROBUST_GRADIENT=$(($ROBUST_GRADIENT + 1))
        done
        
        echo "\\end{tabular}"
        echo "\\caption{Noise level $noise}"
        echo "\\end{center}"
        echo "\\end{table}"
        
        cd ..
    done
# 
# NORMALIZATION=1
#     # loop over the noise level
#     # echo "Starting the loop"
#     for noise in 0 3 5 10; do
#     #for noise in 0 3 5; do
#         dir=noise$noise
#         cd $dir
#         echo ""
#         echo "\\begin{table}"
#         echo "\\begin{center}"
#         echo "\\begin{tabular}{l|l|l|l|l|l|l|l|l|l|l|l}"
#         echo "\\multicolumn{2}{l}{} &\\multicolumn{2}{|c|}{L2} & \\multicolumn{2}{c|}{Truncated L2} & \\multicolumn{2}{c|}{German} & \\multicolumn{2}{c|}{Lorentzian} & \\multicolumn{2}{c}{Charbonnier} \\\\"
#         echo "\\hline"
#         echo "\\multicolumn{2}{l|}{} & &  DBV & & DBV & & DBV & & DBV & & DBV\\\\"
#         echo "\\hline"
# 
#         declare -a arr=("Central" "Hypomode" "Farid 3x3" "Farid 5x5" "Gaussian $\\sigma = 0.3$" "Gaussian $\\sigma = 0.6$")
#         ROBUST_GRADIENT=0
#         for gradient in "${arr[@]}"; do
#             #RMSE
#             line2echo="\\multirow{5}{0.1\\linewidth}{$gradient} & RMSE"
#             for ROBUST in 0 1 2 3 4; do
#                 for EDGEPADDING in 0 5; do
#                     basefile=norm${NORMALIZATION}_edge${EDGEPADDING}_gradient${ROBUST_GRADIENT}_robust${ROBUST}
#                     # field comparison
#                     rmse_ica=rmse_ica_${basefile}.txt
#                     max_ica=max_ica_${basefile}.txt
#                     line2echo="$line2echo & `mean_and_std $rmse_ica 0`"
#                 done
#             done
#             line2echo="$line2echo \\\\"
#             echo "$line2echo"
#             
#             #RMSE STD
#             line2echo="& Std"
#             for ROBUST in 0 1 2 3 4; do
#                 for EDGEPADDING in 0 5; do
#                     basefile=norm${NORMALIZATION}_edge${EDGEPADDING}_gradient${ROBUST_GRADIENT}_robust${ROBUST}
#                     # field comparison
#                     rmse_ica=rmse_ica_${basefile}.txt
#                     max_ica=max_ica_${basefile}.txt
#                     line2echo="$line2echo & `mean_and_std $rmse_ica 1`"
#                 done
#             done
#             line2echo="$line2echo \\\\"
#             echo "$line2echo"
#             
#             #MAX
#             line2echo="& Max"
#             for ROBUST in 0 1 2 3 4; do
#                 for EDGEPADDING in 0 5; do
#                     basefile=norm${NORMALIZATION}_edge${EDGEPADDING}_gradient${ROBUST_GRADIENT}_robust${ROBUST}
#                     # field comparison
#                     rmse_ica=rmse_ica_${basefile}.txt
#                     max_ica=max_ica_${basefile}.txt
#                     line2echo="$line2echo & `mean_and_std $max_ica 0`"
#                 done
#             done
#             line2echo="$line2echo \\\\"
#             echo "$line2echo"
#             
#             #RMSE STD
#             line2echo="& Std"
#             for ROBUST in 0 1 2 3 4; do
#                 for EDGEPADDING in 0 5; do
#                     basefile=norm${NORMALIZATION}_edge${EDGEPADDING}_gradient${ROBUST_GRADIENT}_robust${ROBUST}
#                     # field comparison
#                     rmse_ica=rmse_ica_${basefile}.txt
#                     max_ica=max_ica_${basefile}.txt
#                     line2echo="$line2echo & `mean_and_std $max_ica 1`"
#                 done
#             done
#             line2echo="$line2echo \\\\"
#             echo "$line2echo"
#             
#             if [ "$ROBUST_GRADIENT" -eq "5" ]; then 
#                 echo "& Time & v1 & v2 & v3 & v4 & v5 & v6 & v7 & v8 & v9 & v10"
#             else
#                 echo "& Time & v1 & v2 & v3 & v4 & v5 & v6 & v7 & v8 & v9 & v10\\\\"
#                 echo "\\hline"
#             fi
#             ROBUST_GRADIENT=$(($ROBUST_GRADIENT + 1))
#         done
#         
#         echo "\\end{tabular}"
#         echo "\\caption{Noise level $noise}"
#         echo "\\end{center}"
#         echo "\\end{table}"
#         
#         cd ..
#     done
    FIRST_SCALE=1
    # loop over the noise level
    # echo "Starting the loop"
    for noise in 0 5 10 30; do
    #for noise in 0 3 5; do
        dir=noise$noise
        cd $dir
        echo ""
        echo "\\begin{table}"
        echo "\\begin{center}"
        echo "\\begin{tabular}{l|l|l|l|l|l|l|l|l|l|l|l}"
        echo "\\multicolumn{2}{l}{} &\\multicolumn{2}{|c|}{L2} & \\multicolumn{2}{c|}{Truncated L2} & \\multicolumn{2}{c|}{German} & \\multicolumn{2}{c|}{Lorentzian} & \\multicolumn{2}{c}{Charbonnier} \\\\"
        echo "\\hline"
        echo "\\multicolumn{2}{l|}{} & &  DBV & & DBV & & DBV & & DBV & & DBV\\\\"
        echo "\\hline"

        declare -a arr=("Central" "Hypomode" "Farid 3x3" "Farid 5x5" "Gaussian $\\sigma = 0.3$" "Gaussian $\\sigma = 0.6$")
        ROBUST_GRADIENT=0
        for gradient in "${arr[@]}"; do
            #RMSE
            line2echo="\\multirow{5}{0.1\\linewidth}{$gradient} & RMSE"
            for ROBUST in 0 1 2 3 4; do
                for EDGEPADDING in 0 5; do
                    basefile=scale${FIRST_SCALE}_edge${EDGEPADDING}_gradient${ROBUST_GRADIENT}_robust${ROBUST}
                    # field comparison
                    rmse_ica=rmse_ica_${basefile}.txt
                    max_ica=max_ica_${basefile}.txt
                    line2echo="$line2echo & `mean_and_std $rmse_ica 0`"
                done
            done
            line2echo="$line2echo \\\\"
            echo "$line2echo"
            
            #RMSE STD
            line2echo="& Std"
            for ROBUST in 0 1 2 3 4; do
                for EDGEPADDING in 0 5; do
                    basefile=scale${FIRST_SCALE}_edge${EDGEPADDING}_gradient${ROBUST_GRADIENT}_robust${ROBUST}
                    # field comparison
                    rmse_ica=rmse_ica_${basefile}.txt
                    max_ica=max_ica_${basefile}.txt
                    line2echo="$line2echo & `mean_and_std $rmse_ica 1`"
                done
            done
            line2echo="$line2echo \\\\"
            echo "$line2echo"
            
            #MAX
            line2echo="& Max"
            for ROBUST in 0 1 2 3 4; do
                for EDGEPADDING in 0 5; do
                    basefile=scale${FIRST_SCALE}_edge${EDGEPADDING}_gradient${ROBUST_GRADIENT}_robust${ROBUST}
                    # field comparison
                    rmse_ica=rmse_ica_${basefile}.txt
                    max_ica=max_ica_${basefile}.txt
                    line2echo="$line2echo & `mean_and_std $max_ica 0`"
                done
            done
            line2echo="$line2echo \\\\"
            echo "$line2echo"
            
            #RMSE STD
            line2echo="& Std"
            for ROBUST in 0 1 2 3 4; do
                for EDGEPADDING in 0 5; do
                    basefile=scale${FIRST_SCALE}_edge${EDGEPADDING}_gradient${ROBUST_GRADIENT}_robust${ROBUST}
                    # field comparison
                    rmse_ica=rmse_ica_${basefile}.txt
                    max_ica=max_ica_${basefile}.txt
                    line2echo="$line2echo & `mean_and_std $max_ica 1`"
                done
            done
            line2echo="$line2echo \\\\"
            echo "$line2echo"
            
            if [ "$ROBUST_GRADIENT" -eq "5" ]; then 
                echo "& Time & v1 & v2 & v3 & v4 & v5 & v6 & v7 & v8 & v9 & v10"
            else
                echo "& Time & v1 & v2 & v3 & v4 & v5 & v6 & v7 & v8 & v9 & v10\\\\"
                echo "\\hline"
            fi
            ROBUST_GRADIENT=$(($ROBUST_GRADIENT + 1))
        done
        
        echo "\\end{tabular}"
        echo "\\caption{Noise level $noise}"
        echo "\\end{center}"
        echo "\\end{table}"
        
        cd ..
    done
    
cd ..
