#!/bin/bash

#
# 2.harvester.sh
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
output=$2

mkdir -p $output

for K in `find ${input} -name 'K*' -exec basename {} \;|sed 's/K//g'`
do
	K=$((10#$K+0))
	inds=$(head -1 ${input}/K`printf %02d $K`/*.masked.geno |awk '{print length}')
	runs=$(ls ${input}/K`printf %02d $K`/*.Q|wc -l)

	echo -e "Harvester\tK=$K\tinds=${inds}\truns=${runs}"

	rm -f $output/K${K}.popfile

	for ((run=1;run<=$runs;run++))
	do
		paste \
		<(for ((i=1;i<=$inds;i++));do echo "$i:";done) ${input}/K`printf %02d $K`/*.run_`printf %02d $run`.masked.Q \
		<(for ((i=1;i<=$inds;i++));do echo "1";done) >> $output/K${K}.popfile
		echo "" >> $output/K${K}.popfile
	done
done
