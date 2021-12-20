#!/bin/bash

#
# poplddecay_plot.sh
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

#https://www.r-bloggers.com/estimate-decay-of-linkage-disequilibrium-with-distance/


#Each population separately (all chromosomes)
for i in LRLAC-DAF LRLAC-AHL LRLAC-ALL LRLAC-HAF LRLAC-SAV LRLAC-AMZ LRLAC-MAM LRLAC WILD-CWR; do
	perl \
		/home/agkanogiannis/software/PopLDdecay/bin/Plot_OnePop.pl \
		-inList <(ls stats/${i}.chr_*.stat.gz) \
		-output plots_pop/${i} \
		-method MeanBin;
	n=$(grep -c "${i}" LRLAC_WILD.snps.filt_info_dp3_mac5_den90_imis50.K9.groups_names.txt);
	gunzip --force plots_pop/${i}.bin.gz;
	
	echo -e "data<-read.table('plots_pop/${i}.bin')" > ${i}.R
	echo -e "colnames(data)<-c('dist','r2')" >> ${i}.R
	echo -e "LD.data <- data\$r2" >> ${i}.R
	echo -e "distance <- data\$dist" >> ${i}.R
	echo -e "n <- ${n}" >> ${i}.R
	echo -e "HW.st<-c(C=0.1)" >> ${i}.R
	echo -e "HW.nonlinear<-nls(LD.data~((10+C*distance)/((2+C*distance)*(11+C*distance)))*(1+((3+C*distance)*(12+12*C*distance+(C*distance)^2))/(n*(2+C*distance)*(11+C*distance))),start=HW.st,control=nls.control(maxiter=1000))" >> ${i}.R
	echo -e "tt<-summary(HW.nonlinear)" >> ${i}.R
	echo -e "new.rho<-tt\$parameters[1]" >> ${i}.R
	echo -e "fpoints<-((10+new.rho*distance)/((2+new.rho*distance)*(11+new.rho*distance)))*(1+((3+new.rho*distance)*(12+12*new.rho*distance+(new.rho*distance)^2))/(n*(2+new.rho*distance)*(11+new.rho*distance)))" >> ${i}.R
	echo -e "pdf('plots_pop/${i}.pdf',paper='usr',width=11, height=8.5)" >> ${i}.R
	echo -e "plot(data[,1]/1000,fpoints,type='l',col='blue',xlab='Distance(Kbp)',xlim=c(0,20),ylim=c(0,0.5),ylab=expression(r^{2}),bty='n')" >> ${i}.R
	echo -e "dev.off()" >> ${i}.R
	unset R_HOME
	Rscript ${i}.R
done


#All population together (all chromosomes)
perl \
	/home/agkanogiannis/software/PopLDdecay/bin/Plot_MultiPop.pl \
	-inList <(for i in LRLAC-DAF LRLAC-AHL LRLAC-ALL LRLAC-HAF LRLAC-SAV LRLAC-AMZ LRLAC-MAM LRLAC WILD-CWR;do ii=$(echo $i | sed 's/-/_/g');echo -e "plots_pop/${i}.bin\t${ii}";done) \
	-output plots_final/PopLDdecay \
	-method MeanBin

n=$(grep -c "WILD-CWR" LRLAC_WILD.snps.filt_info_dp3_mac5_den90_imis50.K9.groups_names.txt);
color=$(grep -P "WILD-CWR\t" colors.txt|cut -f2)
echo -e "" > PopLDdecay.R
echo -e "pdf('plots_final/PopLDdecay.pdf',paper='usr',width=11, height=8.5)" >> PopLDdecay.R
echo -e "data<-read.table('plots_pop/WILD-CWR.bin')" >> PopLDdecay.R
echo -e "colnames(data)<-c('dist','r2')" >> PopLDdecay.R
echo -e "LD.data <- data\$r2" >> PopLDdecay.R
echo -e "distance <- data\$dist" >> PopLDdecay.R
echo -e "n <- ${n}" >> PopLDdecay.R
echo -e "HW.st<-c(C=0.1)" >> PopLDdecay.R
echo -e "HW.nonlinear<-nls(LD.data~((10+C*distance)/((2+C*distance)*(11+C*distance)))*(1+((3+C*distance)*(12+12*C*distance+(C*distance)^2))/(n*(2+C*distance)*(11+C*distance))),start=HW.st,control=nls.control(maxiter=1000))" >> PopLDdecay.R
echo -e "tt<-summary(HW.nonlinear)" >> PopLDdecay.R
echo -e "new.rho<-tt\$parameters[1]" >> PopLDdecay.R
echo -e "fpoints<-((10+new.rho*distance)/((2+new.rho*distance)*(11+new.rho*distance)))*(1+((3+new.rho*distance)*(12+12*new.rho*distance+(new.rho*distance)^2))/(n*(2+new.rho*distance)*(11+new.rho*distance)))" >> PopLDdecay.R
echo -e "plot(data[,1]/1000,fpoints,type='l',col='${color}',lwd=3,xlab='Distance(Kbp)',xlim=c(0,20),ylim=c(0,0.5),ylab=expression(r^{2}),bty='n')" >> PopLDdecay.R
echo -e "" >> PopLDdecay.R
for i in LRLAC-DAF LRLAC-AHL LRLAC-ALL LRLAC-HAF LRLAC-SAV LRLAC-AMZ LRLAC-MAM LRLAC; do
	n=$(grep -c "${i}" LRLAC_WILD.snps.filt_info_dp3_mac5_den90_imis50.K9.groups_names.txt);
	color=$(grep -P "${i}\t" colors.txt|cut -f2)
	echo -e "data<-read.table('plots_pop/${i}.bin')" >> PopLDdecay.R
	echo -e "colnames(data)<-c('dist','r2')" >> PopLDdecay.R
	echo -e "LD.data <- data\$r2" >> PopLDdecay.R
	echo -e "distance <- data\$dist" >> PopLDdecay.R
	echo -e "n <- ${n}" >> PopLDdecay.R
	echo -e "HW.st<-c(C=0.1)" >> PopLDdecay.R
	echo -e "HW.nonlinear<-nls(LD.data~((10+C*distance)/((2+C*distance)*(11+C*distance)))*(1+((3+C*distance)*(12+12*C*distance+(C*distance)^2))/(n*(2+C*distance)*(11+C*distance))),start=HW.st,control=nls.control(maxiter=1000))" >> PopLDdecay.R
	echo -e "tt<-summary(HW.nonlinear)" >> PopLDdecay.R
	echo -e "new.rho<-tt\$parameters[1]" >> PopLDdecay.R
	echo -e "fpoints<-((10+new.rho*distance)/((2+new.rho*distance)*(11+new.rho*distance)))*(1+((3+new.rho*distance)*(12+12*new.rho*distance+(new.rho*distance)^2))/(n*(2+new.rho*distance)*(11+new.rho*distance)))" >> PopLDdecay.R
	echo -e "lines(data[,1]/1000,fpoints,col='${color}',lwd=3)" >> PopLDdecay.R
	echo -e "" >> PopLDdecay.R
done
echo -e "legend('topright',c('LRLAC_DAF','LRLAC_AHL','LRLAC_ALL','LRLAC_HAF','LRLAC_SAV','LRLAC_AMZ','LRLAC_MAM','LRLAC','WILD_CWR'),col=c('#A73800','#EE00FF','#DC143C','#004787','#5A9B1A','#231F1C','#FFBE00','yellow','#FFC0CB'),cex=1,lty=c(1,1,1,1,1,1,1,1,1),bty='n');" >> PopLDdecay.R
echo -e "dev.off()" >> PopLDdecay.R
Rscript PopLDdecay.R


#LRLAC per chromosome
for i in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18; do
	perl \
		/home/agkanogiannis/software/PopLDdecay/bin/Plot_OnePop.pl \
		-inList <(ls stats/LRLAC.chr_${i}.stat.gz) \
		-output plots_chr/LRLAC_chr_${i} \
		-method MeanBin;
	rm -f plots_chr/LRLAC_chr_${i}.pdf
	rm -f plots_chr/LRLAC_chr_${i}.png
	gunzip --force plots_chr/LRLAC_chr_${i}.bin.gz
done

n=$(grep -c "LRLAC" LRLAC_WILD.snps.filt_info_dp3_mac5_den90_imis50.K9.groups_names.txt);
echo -e "library('colorspace')" > PopLDdecay_chr.R
#echo -e "colors <- qualitative_hcl(18, 'Dark 3')" >> PopLDdecay_chr.R
echo -e "colors <- rainbow(18)" >> PopLDdecay_chr.R
echo -e "pdf('plots_chr/PopLDdecay_chr.pdf',paper='usr',width=11, height=8.5)" >> PopLDdecay_chr.R
echo -e "data<-read.table('plots_chr/LRLAC_chr_01.bin')" >> PopLDdecay_chr.R
echo -e "colnames(data)<-c('dist','r2')" >> PopLDdecay_chr.R
echo -e "LD.data <- data\$r2" >> PopLDdecay_chr.R
echo -e "distance <- data\$dist" >> PopLDdecay_chr.R
echo -e "n <- ${n}" >> PopLDdecay_chr.R
echo -e "HW.st<-c(C=0.1)" >> PopLDdecay_chr.R
echo -e "HW.nonlinear<-nls(LD.data~((10+C*distance)/((2+C*distance)*(11+C*distance)))*(1+((3+C*distance)*(12+12*C*distance+(C*distance)^2))/(n*(2+C*distance)*(11+C*distance))),start=HW.st,control=nls.control(maxiter=1000))" >> PopLDdecay_chr.R
echo -e "tt<-summary(HW.nonlinear)" >> PopLDdecay_chr.R
echo -e "new.rho<-tt\$parameters[1]" >> PopLDdecay_chr.R
echo -e "fpoints<-((10+new.rho*distance)/((2+new.rho*distance)*(11+new.rho*distance)))*(1+((3+new.rho*distance)*(12+12*new.rho*distance+(new.rho*distance)^2))/(n*(2+new.rho*distance)*(11+new.rho*distance)))" >> PopLDdecay_chr.R
echo -e "plot(data[,1]/1000,fpoints,type='l',col=colors[1],lwd=3,xlab='Distance(Kbp)',xlim=c(0,20),ylim=c(0,0.5),ylab=expression(r^{2}),bty='n')" >> PopLDdecay_chr.R
echo -e "" >> PopLDdecay_chr.R
for i in 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18; do
	echo -e "data<-read.table('plots_chr/LRLAC_chr_${i}.bin')" >> PopLDdecay_chr.R
	echo -e "colnames(data)<-c('dist','r2')" >> PopLDdecay_chr.R
	echo -e "LD.data <- data\$r2" >> PopLDdecay_chr.R
	echo -e "distance <- data\$dist" >> PopLDdecay_chr.R
	echo -e "n <- ${n}" >> PopLDdecay_chr.R
	echo -e "HW.st<-c(C=0.1)" >> PopLDdecay_chr.R
	echo -e "HW.nonlinear<-nls(LD.data~((10+C*distance)/((2+C*distance)*(11+C*distance)))*(1+((3+C*distance)*(12+12*C*distance+(C*distance)^2))/(n*(2+C*distance)*(11+C*distance))),start=HW.st,control=nls.control(maxiter=1000))" >> PopLDdecay_chr.R
	echo -e "tt<-summary(HW.nonlinear)" >> PopLDdecay_chr.R
	echo -e "new.rho<-tt\$parameters[1]" >> PopLDdecay_chr.R
	echo -e "fpoints<-((10+new.rho*distance)/((2+new.rho*distance)*(11+new.rho*distance)))*(1+((3+new.rho*distance)*(12+12*new.rho*distance+(new.rho*distance)^2))/(n*(2+new.rho*distance)*(11+new.rho*distance)))" >> PopLDdecay_chr.R
	echo -e "lines(data[,1]/1000,fpoints,col=colors[${i}],lwd=3)" >> PopLDdecay_chr.R
	echo -e "" >> PopLDdecay_chr.R
done
echo -e "legend('topright',paste0('chr',c(01:18)),col=colors,cex=1,lty=c(1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1),bty='n');" >> PopLDdecay_chr.R
echo -e "dev.off()" >> PopLDdecay_chr.R
Rscript PopLDdecay_chr.R
