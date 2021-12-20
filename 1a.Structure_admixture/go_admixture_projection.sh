#!/bin/bash

#
# go_admixture_projection.sh
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
background_P=$2
K=$3
cpus=$4

admixture_bin="/home/agkanogiannis/software/admixture_linux-1.3.0/admixture"

rm -f `basename $input '.ped'`.K$K.admixture_projection.log

ln -sfn ${background_P} `basename $input '.ped'`.${K}.P.in

${admixture_bin} \
	-j${cpus} \
	-s time \
	-C 0.001 \
	-P \
	${input} \
	${K} \
	> `basename $input '.ped'`.K$K.admixture_projection.log
mv 	`basename $input '.ped'`.$K.P `basename $input '.ped'`.K$K.P
mv 	`basename $input '.ped'`.$K.Q `basename $input '.ped'`.K$K.Q

#unlink `basename $input '.ped'`.${K}.P.in