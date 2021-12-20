#!/bin/bash

#
# 1.sNMF.sh
# Script part of CassavaDiversityCIAT project
#
# Copyright (C) 2021 Anestis Gkanogiannis <anestis@gkanogiannis.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, 
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
#

input=$1
input=$(readlink -f $input)
output=$2
minK=$3
maxK=$4
runs=$5
cpus=$6
a=$7

sNMF_bin="/home/agkanogiannis/software/sNMF_CL_v1.2/bin/"
plot_entropy=`pwd`/plot_data_xy.sh

mkdir -p $output
cd ${output}

for ((K=1;K<=$maxK;K++))
do
	echo -e "sNMF\tK=$K"
		
	mkdir K`printf %02d $K`
	cd K`printf %02d $K`

	${sNMF_bin}/createDataSet \
		-x $input \
		-r 0.05 \
		-o `basename $input '.geno'`.K_`printf %02d $K`.masked.geno \
		 > `basename $input '.geno'`.K_`printf %02d $K`.masked.log
		
	for ((run=1;run<=$runs;run++))
	do
		${sNMF_bin}/sNMF \
			-K $K \
			-x `basename $input '.geno'`.K_`printf %02d $K`.masked.geno \
			-q `basename $input '.geno'`.K_`printf %02d $K`.run_`printf %02d $run`.masked.Q \
			-g `basename $input '.geno'`.K_`printf %02d $K`.run_`printf %02d $run`.masked.G \
			-i 200 \
			-a $a \
			-e 0.001 \
			-p $cpus \
			 >> `basename $input '.geno'`.K_`printf %02d $K`.masked.snmf.log
		${sNMF_bin}/crossEntropy \
			-K $K \
			-x $input \
			-q `basename $input '.geno'`.K_`printf %02d $K`.run_`printf %02d $run`.masked.Q \
			-g `basename $input '.geno'`.K_`printf %02d $K`.run_`printf %02d $run`.masked.G \
			-i `basename $input '.geno'`.K_`printf %02d $K`.masked.geno \
			 >> `basename $input '.geno'`.K_`printf %02d $K`.entropy.log
	done
	cd .. 
done

for ((K=1;K<=$maxK;K++))
do
	grep "Cross-Entropy (masked data):" K`printf %02d $K`/*.entropy.log | awk -v K="$K" '{print K"\t"$4}' \
		>> `basename $input '.geno'`.entropy.txt
done

bash $plot_entropy `basename $input '.geno'`.entropy.txt `basename $input '.geno'`.entropy.png "Entropy K=$minK to K=$maxK"
