#!/bin/bash

#
# go_graphs_gnames_projection.sh
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

#prefix="LRLAC_WILD.snps.filt_info_dp3_mac5_den90_imis50";
prefix=$1
#samples="LRLAC_WILD_imis50.names.txt";
samples=$2
#geo="list-LRLAC_WILD.all.geo.txt";
geo=$3
g_names=$4
K=$5
g_colors=$6

CLUMPP=/home/agkanogiannis/bin/CLUMPP
Rscript=/home/agkanogiannis/bin/Rscript

inds=$(grep -m 1 'Size of G' ${prefix}.K$K.admixture_projection.log |cut -d'x' -f1|cut -d' ' -f4)
runs=1

echo -e "inds=$inds\truns=$runs"

rm -f ${prefix}.qmatrix.txt
rm -f ${prefix}.groups.txt
rm -f ${prefix}.itol_piechart.txt
rm -f ${prefix}.itol_strip.txt
rm -f ${prefix}.merged.q.png
unset R_HOME
${Rscript} 4.pophelper.singleK.R \
	`pwd` \
	`pwd` \
	${prefix} \
	${samples} \
	${K} \
	${runs} \
	${g_names} \
	${g_colors};

rm -f ${prefix}.K${K}.mapplots.csv
rm -f ${prefix}.K${K}.mapplots.pdf

echo -e "SAMPLE,LAT,LON,GROUP,Q" > ${prefix}.K${K}.mapplots.csv
for ((i=1;i<=$inds;i++));
do
	sample=`sed -n "${i}p" ${samples}`
	qs=`sed -n "${i}p" ${prefix}.K${K}.popq.merged`
	coords=`grep "^${sample}," ${geo}`
	if ! [ -z ${coords} ]
	then
		for ((j=1;j<=$K;j++));
		do
			g=`cat ${g_names} | sed -n "${j}p"`
			q=`echo $qs | awk -v x=$((j+1)) '{print $x}'`
			#echo -e "i=$i\tSample=$sample\tcoords=${coords}\tGroup=${j}\tQ=${q}"
			echo -e "${coords},${g},${q}" >> ${prefix}.K${K}.mapplots.csv
		done
	fi
done

unset R_HOME
${Rscript} 5.mapplots.R ${prefix}.K${K}.mapplots.csv ${prefix}.K${K}.mapplots.pdf $K `echo -e "${prefix}_K=${K}"` ${g_colors}
