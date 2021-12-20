#!/bin/bash

#
# go_graphs.sh
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

#base="LRLAC_maf5_den90_nonrelated-2";
base=$1
#samples="LRLAC_imis50_nonrelated-2.names.txt";
samples=$2
#geo="list-LRLAC_WILD.all.geo.txt";
geo=$3

bash 2.harvester.sh \
	1.admixture_${base}/ \
	2.harvester_${base}/;

bash 3.clumpp.sh \
	2.harvester_${base}/ \
	3.clumpp_${base}/;

bash 4.pophelper.sh \
	1.admixture_${base}/ \
	3.clumpp_${base}/ \
	4.pophelper_${base}/ \
	${samples};

bash 5.mapplots.sh \
	3.clumpp_${base}/ \
	5.mapplots_${base}/ \
	${samples} \
	${geo} \
	${base};
