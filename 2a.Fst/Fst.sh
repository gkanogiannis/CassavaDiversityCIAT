#!/bin/bash

#
# Fst.sh
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

vcf_file=$1
pops_file=$2
output=$3

vcftools=/home/agkanogiannis/software/vcftools_zlib_1.2.11/src/cpp/vcftools

pops=(`cut -f2 ${pops_file} |uniq`)

#for pop in $pops;do echo -en "\t${pop}" >> ${output}.Fst.csv;done
echo -en "\n" > ${output}.Fst.txt

#touch ${output}.Fst.txt

for (( i=${#pops[@]}-1 ; i>=0 ; i-- ))
do
	pop1="${pops[$i]}"
	sed -i "1i ${pop1}" ${output}.Fst.txt
	#echo -en "${pop1}" >> ${output}.Fst.csv
	for j in "${!pops[@]}";
	do
		pop2="${pops[$j]}"
		sed -i "1s/$/\t/" ${output}.Fst.txt
		#echo -en "\t" >> ${output}.Fst.csv
		if [[ "$i" > "$j" ]];
		then
			grep -P "\t${pop1}" ${pops_file} > ${output}.${pop1}.txt
			grep -P "\t${pop2}" ${pops_file} > ${output}.${pop2}.txt
			${vcftools} \
					--gzvcf ${vcf_file} \
					--weir-fst-pop ${output}.${pop1}.txt \
					--weir-fst-pop ${output}.${pop2}.txt \
					--fst-window-size 250000 \
					--out ${output}.Fst.${pop1}_${pop2}
			val=$(grep "Weir and Cockerham weighted Fst estimate" ${output}.Fst.${pop1}_${pop2}.log \
				|awk '{printf "%.5f", $7}')
			sed -i "1s/$/${val}/" ${output}.Fst.txt
		fi
	done
	#sed -i "1s/$/\n/" ${output}.Fst.txt
	#echo -en "\n" >> ${output}.Fst.csv
done

sed -i '1i\
' ${output}.Fst.txt
for j in "${!pops[@]}";
do 
	pop="${pops[$j]}"
	sed -i "1s/$/\t${pop}/" ${output}.Fst.txt
done

#sed -i '1iI am a new line' file.txt
#sed -i '2s/$/ myalias/' file
