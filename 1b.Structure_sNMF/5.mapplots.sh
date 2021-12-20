#!/bin/bash

#
# 5.mapplots.sh
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

clumpp=$1
output=$2
samples=$3
geo=$4
base=$5

Rscript=/home/agkanogiannis/bin/Rscript

mkdir -p $output

for K in `find ${clumpp} -name 'K*popq.merged' -exec basename {} '.popq.merged' \;|sed 's/K//g'`
do
	K=$((10#$K+0))
	inds=`wc -l $clumpp/K${K}.popq.merged|awk '{print $1}'`
	echo -e "K=$K\tinds=$inds"

	rm -f ${output}/K${K}.mapplots.csv
	rm -f ${output}/K${K}.mapplots.pdf

	echo -e "SAMPLE,LAT,LON,GROUP,Q" > ${output}/K${K}.mapplots.csv

	for ((i=1;i<=$inds;i++))
	do
		sample=`sed -n "${i}p" ${samples}`
		qs=`sed -n "${i}p" $clumpp/K${K}.popq.merged`
		coords=`grep "^${sample}," ${geo}`
		if ! [ -z ${coords} ]
		then
			for ((j=1;j<=$K;j++))
			do
				q=`echo $qs | awk -v x=$((j+1)) '{print $x}'`
				#echo -e "i=$i\tSample=$sample\tcoords=${coords}\tGroup=${j}\tQ=${q}"
				echo -e "${coords},${j},${q}" >> ${output}/K${K}.mapplots.csv
			done
		fi
	done

	unset R_HOME
	${Rscript} 5.mapplots.R ${output}/K${K}.mapplots.csv ${output}/K${K}.mapplots.pdf $K `echo -e "${base}_K=${K}"`

done