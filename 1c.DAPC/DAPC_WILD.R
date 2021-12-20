#!/home/agkanogiannis/bin/Rscript

#
# DAPC_WILD.R
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

library(vcfR)
library(adegenet)

setwd("D:\\agkanogiannis\\Dropbox\\CIAT\\Agrobio\\Cassava\\RAD_2019\\3.DAPC")

vcf <- read.vcfR("WILD.snps.filt_info_dp3_maf5_den90_imis50_nonrelated-2.vcf.gz")

vcf_genobject <- vcfR2genlight(vcf)
n <- length(vcf_genobject$ind.names)

vcf_genobject
n

snmf_grp<-read.csv("WILD_nonrelated-2.maf5.K2.groups.sorted.txt",
                   sep="\t", row.names=1, 
                   colClasses=c('character', 'factor'),header=FALSE)

dapc <- dapc(vcf_genobject,snmf_grp$V2)
dapc

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
        "black")

scatter(dapc, scree.da=FALSE, bg="white", pch=20, cell=0, cstar=0, col=shiny, solid=.4,
        cex=1.5,clab=0, leg=TRUE, txt.leg=paste("Cluster",1:2))
scatter(dapc,1,1, col=shiny, bg="white", scree.da=FALSE, legend=TRUE, solid=.4)

optim.a.score(dapc)
