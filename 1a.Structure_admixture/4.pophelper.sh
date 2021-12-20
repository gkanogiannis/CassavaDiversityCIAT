#!/bin/bash

#
# 4.pophelper.sh
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

sNMF=$1
clumpp=$2
output=$3
samples=$4

Rscript=/home/agkanogiannis/bin/Rscript

inds=$(grep '^.*:' `ls ${clumpp}/K*popfile|head -1` |sort -nr|head -1|awk -F':' '{print $1}')
runs=$(grep -c "^${inds}:" `ls ${clumpp}/K*popfile|head -1`)
maxK=`find ${clumpp} -name 'K*popfile' -exec basename {} '.popfile' \;|sed 's/K//g'|sort -nr|head -1`

echo -e "pophelper\tmaxK=${maxK}\tinds=${inds}\truns=${runs}"

mkdir -p $output

unset R_HOME
${Rscript} 4.pophelper.R \
	${sNMF}/ \
	${clumpp}/ \
	${output}/ \
	${samples} \
	${maxK} \
	${runs};