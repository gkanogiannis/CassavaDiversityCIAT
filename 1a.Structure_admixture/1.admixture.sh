#!/bin/bash

#
# 1.admixture.sh
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

admixture_bin="/home/agkanogiannis/software/admixture_linux-1.3.0/admixture"
plot_entropy=`pwd`/plot_data_xy.sh

mkdir -p $output
cd ${output}

for ((K=1;K<=$maxK;K++))
do
	echo -e "admixture\tK=$K"
		
	mkdir K`printf %02d $K`
	cd K`printf %02d $K`

	for ((run=1;run<=$runs;run++))
	do
		${admixture_bin} \
			-j${cpus} \
			-s time \
			-C 0.01 \
			--cv \
			${input} \
			${K} \
			>> `basename $input '.ped'`.K_`printf %02d $K`.admixture.log
		mv 	`basename $input '.ped'`.$K.P `basename $input '.ped'`.K_`printf %02d $K`.run_`printf %02d $run`.P
		mv 	`basename $input '.ped'`.$K.Q `basename $input '.ped'`.K_`printf %02d $K`.run_`printf %02d $run`.Q
	done
	cd .. 
done

for ((K=1;K<=$maxK;K++))
do
	grep "CV error" K`printf %02d $K`/*.admixture.log | awk -v K="$K" '{print K"\t"$4}' \
		>> `basename $input '.ped'`.entropy.txt
done

bash $plot_entropy `basename $input '.ped'`.entropy.txt `basename $input '.ped'`.entropy.png "Entropy K=$minK to K=$maxK"
