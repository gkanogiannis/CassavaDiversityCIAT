#!/home/agkanogiannis/bin/Rscript

#
# 5.mapplots.R
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

library(maps)
library(mapplots)

args = commandArgs(trailingOnly=TRUE)

input <- args[1]
output <- args[2]
K <- as.integer(args[3])
title <- args[4]

shiny=c("#0C5BB0FF",
        "#EE0011FF",
        "#15983DFF",
        "#EC579AFF",
        "#FA6B09FF",
        "#149BEDFF",
        "#A1C720FF",
        "#FEC10BFF",
        "#16A08CFF",
        "#9A703EFF",
        "black",
        "#DF0101",
        "#77CE61",
        "#FF9326",
        "#A945FF",
        "#0089B2",
        "#FDF060",
        "#FFA6B2",
        "#BFF217",
        "#60D5FD")

coord_qmatrix<-read.csv(input,header=TRUE,dec=".")
coord_qmatrix$GROUP <- factor(coord_qmatrix$GROUP, levels=unique(coord_qmatrix$GROUP))
xyz<-make.xyz(coord_qmatrix$LON, coord_qmatrix$LAT, coord_qmatrix$Q, coord_qmatrix$GROUP)

pdf(output,width=11, height=8.5, paper="usr",family="sans",pointsize=10)
plot(main=title, coord_qmatrix$LON, coord_qmatrix$LAT, xlab="Longitude", ylab="Latitude", type ="n", asp=1, xlim = c(-110,-30), ylim = c(-25,20))
map(add = T, col = "grey92", fill = TRUE)
draw.pie(xyz$x, xyz$y, xyz$z, radius = 0.5, scale=F, col=shiny[1:K], clockwise=T)
legend.pie("topright",inset=0.05,labels=levels(coord_qmatrix$GROUP), radius=2.5, bty="n", col=shiny[1:K], cex=0.6, label.dist=1.2)
dev.off()
