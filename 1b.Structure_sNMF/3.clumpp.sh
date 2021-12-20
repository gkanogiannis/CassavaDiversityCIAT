#!/bin/bash

#
# 3.clumpp.sh
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

CLUMPP=/home/agkanogiannis/bin/CLUMPP

mkdir -p $output

cd $output

for K in `find ${input} -name 'K*popfile' -exec basename {} '.popfile' \;|sed 's/K//g'`
do
	K=$((10#$K+0))
	if (( $K > 1 ))
	then
		inds=`grep '^.*:' $input/K${K}.popfile |sort -nr|head -1|awk -F':' '{print $1}'`
		runs=`grep -c "^${inds}:" $input/K${K}.popfile`

		echo -e "CLUMPP\tK=$K\tinds=${inds}\truns=${runs}"

		rm -f K${K}*
		ln -sfn $input/K${K}.popfile K${K}.popfile

		echo -e \
"DATATYPE 1\n\
POPFILE K${K}.popfile\n\
OUTFILE K${K}.popq.merged\n\
MISCFILE K${K}.miscfile\n\
K ${K}\nC ${inds}\nR ${runs}\nM 3\nW 0\nS 2\n\
GREEDY_OPTION 2\nREPEATS 1000\nPRINT_PERMUTED_DATA 1\n\
PERMUTED_DATAFILE K${K}.popq.aligned\nPRINT_EVERY_PERM 0\nPRINT_RANDOM_INPUTORDER 0\n\
OVERRIDE_WARNINGS 0\nORDER_BY_RUN 0" > K$K.paramfile ;
		
		${CLUMPP} K$K.paramfile > K$K.log ;
	fi
done
