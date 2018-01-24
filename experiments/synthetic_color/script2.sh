#!/bin/bash

epstopdf.sh
pdfcrop epe_ic.pdf epe_ic.pdf
pdfcrop epe_mic.pdf epe_mic.pdf
pdfcrop gt_diff_ic.pdf gt_diff_ic.pdf
pdfcrop gt_diff_mic.pdf gt_diff_mic.pdf