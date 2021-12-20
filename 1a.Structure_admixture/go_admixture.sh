#!/bin/bash

#
# go_admixture.sh
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

#base="LRLAC_maf5_den90_nonrelated-2"
base=$1
#input="LRLAC.snps.filt_info_dp3_maf5_den90_imis50_nonrelated-2.ped"
input=$2
#minK=1
minK=$3
#maxK=20
maxK=$4
#runs=5
runs=$5
#threads=20
threads=$6

bash 1.admixture.sh \
	${input} \
	1.admixture_${base}/ ${minK} ${maxK} ${runs} ${threads} ;
