#!/bin/bash

#
# plot_data_xy.sh
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

/home/agkanogiannis/bin/gnuplot -e "\
inputF='$1' ;
outputF = '$2' ;
titleS = '$3' ;
set term png ;
set output outputF ;
set xlabel 'My x axis [a.u.]' ;
set ylabel 'My y axis [a.u.]' ;
set style line 1 linecolor rgb '#0060ad' linetype 1 linewidth 2 pointtype 7 pointsize 1.5; 
set style fill solid border -1; set boxwidth 0.01; binwidth=0.01 ;
set style fill transparent solid 0.4 ;
`awk '{ Q[$1]++;                   \
  if (Q[$1]==1){ Min[$1]=$2;Max[$1]=$2; } \
  else                                    \
  {  if (Min[$1]>$2) {Min[$1]=$2;}        \
     else {if (Max[$1]<$2) Max[$1]=$2;} } \
  }                                       \
  END {for (i in Min){ Avg[i]=Min[i]+(Max[i]-Min[i])/2.0;print i,Min[i],Max[i],Avg[i]}}' $1 | sort -n > data.dat`;
plot 'data.dat' using 1:4 with linespoints linestyle 1 title 'average',\
	 "inputF" with points;
"