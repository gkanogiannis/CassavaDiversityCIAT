#!/bin/bash

#
# go_graphs_final.sh
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

#prefix="LRLAC_maf5_nonrelated-2";
prefix=$1
#samples="LRLAC_imis50_nonrelated-2.names.txt";
samples=$2
#geo="list-LRLAC_WILD.all.geo.txt";
geo=$3
K=$4

CLUMPP=/home/agkanogiannis/bin/CLUMPP
Rscript=/home/agkanogiannis/bin/Rscript

inds=$(grep -m 1 'Size of G' ${prefix}.K${K}.admixture.log |cut -d'x' -f1|cut -d' ' -f4)
runs=$(ls ${prefix}.K${K}.run_*.Q|wc -l)

echo -e "inds=$inds\truns=$runs"

rm -f ${prefix}.K${K}.popfile
for ((run=1;run<=$runs;run++))
do
	paste \
        <(for ((i=1;i<=$inds;i++));do echo "$i:";done) ${prefix}.K${K}.run_`printf %02d $run`.Q \
        <(for ((i=1;i<=$inds;i++));do echo "1";done) >> ${prefix}.K${K}.popfile
        echo "" >> ${prefix}.K${K}.popfile
done

rm -f ${prefix}.K${K}.popq.merged
rm -f ${prefix}.K${K}.popq.aligned
rm -f ${prefix}.K${K}.miscfile
echo -e \
"DATATYPE 1\n\
POPFILE ${prefix}.K${K}.popfile\n\
OUTFILE ${prefix}.K${K}.popq.merged\n\
MISCFILE ${prefix}.K${K}.miscfile\n\
K ${K}\nC ${inds}\nR ${runs}\nM 3\nW 0\nS 2\n\
GREEDY_OPTION 2\nREPEATS 1000\nPRINT_PERMUTED_DATA 1\n\
PERMUTED_DATAFILE ${prefix}.K${K}.popq.aligned\nPRINT_EVERY_PERM 0\nPRINT_RANDOM_INPUTORDER 0\n\
OVERRIDE_WARNINGS 0\nORDER_BY_RUN 0" > ${prefix}.K${K}.paramfile ;
${CLUMPP} ${prefix}.K${K}.paramfile > ${prefix}.K${K}.clumpp.log ;

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
	${runs};

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
			q=`echo $qs | awk -v x=$((j+1)) '{print $x}'`
			#echo -e "i=$i\tSample=$sample\tcoords=${coords}\tGroup=${j}\tQ=${q}"
			echo -e "${coords},${j},${q}" >> ${prefix}.K${K}.mapplots.csv
		done
	fi
done

unset R_HOME
${Rscript} 5.mapplots.R ${prefix}.K${K}.mapplots.csv ${prefix}.K${K}.mapplots.pdf $K `echo -e "${prefix}_K=${K}"`
