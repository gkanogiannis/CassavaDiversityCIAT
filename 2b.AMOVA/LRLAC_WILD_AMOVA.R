#!/home/agkanogiannis/bin/Rscript

#
# LRLAC_WILD_AMOVA.R
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

rm(list=ls())
library(vcfR)
library(adegenet)
library(poppr)
library(matrixcalc)
library(BMTME)
library(dartR)

vcfr.all <- read.vcfR(file="LRLAC_WILD.snps.filt_info_dp3_maf5_den98_imis50_chr_ld50.vcf.gz",convertNA=T)
vcfr.nonrelated <- read.vcfR(file="LRLAC_WILD.snps.filt_info_dp3_maf5_den98_imis50_nonrelated_chr_ld50.vcf.gz",convertNA=T)

genlight.all <- vcfR2genlight(vcfr.all)
genlight.nonrelated <- vcfR2genlight(vcfr.nonrelated)

pop <- read.table(file="LRLAC_WILD.snps.filt_info_dp3_mac5_den90_imis50.K9.groups_names.sorted.txt",stringsAsFactors=F,header=T)

inds.all <- as.data.frame(intersect(indNames(genlight.all), pop$line),stringsAsFactors=F)
colnames(inds.all)<-"line"
inds.nonrelated <- as.data.frame(intersect(indNames(genlight.nonrelated), pop$line),stringsAsFactors=F)
colnames(inds.nonrelated)<-"line"

genlight.all <- genlight.all[indNames(genlight.all) %in% inds.all$line]
pop.all <- pop[pop$line %in% inds.all$line,]
genlight.nonrelated <- genlight.nonrelated[indNames(genlight.nonrelated) %in% inds.nonrelated$line]
pop.nonrelated <- pop[pop$line %in% inds.nonrelated$line,]

strata(genlight.all) <- pop.all[match(indNames(genlight.all), pop.all$line), ]
setPop(genlight.all) <- ~pop
strata(genlight.nonrelated) <- pop.nonrelated[match(indNames(genlight.nonrelated), pop.nonrelated$line), ]
setPop(genlight.nonrelated) <- ~pop

table(strata(genlight.all, ~pop))
table(strata(genlight.nonrelated, ~pop))

amova.all <- poppr.amova(genlight.all, hier=~pop, within=T, quiet=F)
amova.all
amova.nonrelated <- poppr.amova(genlight.nonrelated, hier=~pop, within=T, quiet=F)
amova.nonrelated

write.table(amova.all$results, sep = ",", file = "amova.all.csv")
write.table(amova.all$componentsofcovariance, sep = ",", file = "amova.all.csv", append=T)
write.table(amova.all$statphi, sep = ",", file = "amova.all.csv", append=T)
write.table(amova.nonrelated$results, sep = ",", file = "amova.nonrelated.csv")
write.table(amova.nonrelated$componentsofcovariance, sep = ",", file = "amova.nonrelated.csv", append=T)
write.table(amova.nonrelated$statphi, sep = ",", file = "amova.nonrelated.csv", append=T)

set.seed(2019)
amova.nonrelated.test <- randtest(amova.nonrelated, nrepet=999)
amova.nonrelated.test
pdf(file="amova.nonrelated.pdf",paper="a4r")
plot(amova.nonrelated.test)
dev.off()

set.seed(2019)
amova.all.test <- randtest(amova.all, nrepet=999)
amova.amova.test
pdf(file="amova.all.pdf",paper="a4r")
plot(amova.all.test)
dev.off()

