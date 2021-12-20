#!/bin/bash

#
# admixture_freq_2_treemix_counts.sh
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

echo -e "LRLAC-DAF	WILD-OG	LRLAC-AHL	LRLAC-ALL	LRLAC-HAF	WILD-CWR	LRLAC-SAV	LRLAC-AMZ	LRLAC-MAM"

Ns=( 23 23 33 33 33 23 27 23 51 )
K=`head -1 LRLAC_WILD_nonrelated-2.K9.P | awk '{print NF}'`

while read line;
do
	qs=( $line )
	for ((j=0;j<$K;j++))
	do
		q=${qs[j]}
		N=${Ns[j]}
		Nq=$(echo "(2 * $N * $q)/1" | bc)
		p=$(echo "1.0 - $q" | bc)
		Np=$(echo "(2 * $N * $p)/1" | bc)
		sum=$(( Nq+Np ))
		if(( sum != 2*N )); then
			Nq=$(( Nq + 1 ))
		fi
		echo -en "$Nq,$Np\t"
	done
	echo -e ""
done<LRLAC_WILD_nonrelated-2.K9.P
