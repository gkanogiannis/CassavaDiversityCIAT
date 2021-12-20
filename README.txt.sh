#
# README.txt.sh
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

***) Mapping_genotyping LRLAC_WILD (vcf/LRLAC_WILD)
	
	lists/list-LRLAC_WILD.ok.txt
	
	1a-pipeline_mappingBAM_genotypingGVCF.groovy \
		/data1/Reference/ReferenceGenome_6.1/assembly/Mesculenta_305_v6.fa \
		reads \
		lists/list-LRLAC_WILD.ok.txt \
		10
	2a-pipeline_combiningGVCF_genotypingVCF.sh \
		/data1/Reference/ReferenceGenome_6.1/assembly/Mesculenta_305_v6.fa \
		lists/list-LRLAC_WILD.ok.txt \
		50 \
		vcf/LRLAC_WILD/ \
		LRLAC_WILD \
		20
	
	LRLAC_WILD.raw.vcf
		791 samples
		23,324,255 raw variants
	LRLAC_WILD.chr.raw.vcf
		791 samples
		21,213,651 raw variants


***) Filtering to keep multiallelic SNPS LRLAC_WILD (vcf/LRLAC_WILD)

	3a-pipeline_filtering_INFO_multiallelic.sh

	LRLAC_WILD.chr.snps_multi.vcf
		791 samples
		17,342,436 multiallelic SNP

	LRLAC_WILD.chr.snps_multi.filt_info.vcf
		791 samples
		2,332,959 info quality filtered multiallelic SNP

	#Rename ChromosomeXX to Mesc6.1_chr_XX
	zcat LRLAC_WILD.chr.snps_multi.filt_info.vcf.gz \
	| sed -E "s/Chromosome([0-90-9])/Mesc61_chr_\1/g" \
	> LRLAC_WILD.chr.snps_multi.filt_info.vcf;
	bgzip -f -@ 8 LRLAC_WILD.chr.snps_multi.filt_info.vcf;
	tabix -f -p vcf LRLAC_WILD.chr.snps_multi.filt_info.vcf.gz;

	#demultied SNPs
	LRLAC_WILD.chr.snps_demulti.filt_info.vcf
		791 samples
		2,464,370 info quality filtered demultied biallelic SNP

	#Filter to keep genotype of DP>=3, otherwise is set as missing genotype
	vcftools \
		--vcf LRLAC_WILD.chr.snps_demulti.filt_info.vcf \
		--minDP 3 --recode --recode-INFO-all \
		--out LRLAC_WILD.chr.snps_demulti.filt_info_dp3.vcf
	LRLAC_WILD.chr.snps_demulti.filt_info_dp3.vcf
		791 samples
		2,464,370 SNP

	#Filter to keep variants of mac>=5 and den=0.90
	vcftools \
		--vcf LRLAC_WILD.chr.snps_demulti.filt_info_dp3.vcf \
		--recode --recode-INFO-all \
		--mac 5 \
		--out LRLAC_WILD.chr.snps_demulti.filt_info_dp3_mac5.vcf
	LRLAC_WILD.chr.snps_demulti.filt_info_dp3_mac5.vcf
		791 samples
		975,598 SNP
	export JAVA_OPTS="$JAVA_OPTS -Xms196G -Xmx196G"; \
	groovy filterDensity.groovy \
		LRLAC_WILD.chr.snps_demulti.filt_info_dp3_mac5.vcf \
		LRLAC_WILD.chr.snps_demulti.filt_info_dp3_mac5_den90.unsorted.vcf 0.90;
	LRLAC_WILD.chr.snps_demulti.filt_info_dp3_mac5_den90.vcf
		791 samples
		218,658 SNP

	#Keep good samples (missing<=0.5 on maf5_den90 on biallelic SNPs)
	vcftools \
		--vcf LRLAC_WILD.chr.snps_demulti.filt_info_dp3_mac5_den90.vcf \
		--keep list-LRLAC_WILD.ok.maf5_imis50.txt \
		--recode --recode-INFO-all \
		-out LRLAC_WILD.chr.snps_demulti.filt_info_dp3_mac5_den90_imis50.vcf
	LRLAC_WILD.chr.snps_demulti.filt_info_dp3_mac5_den90_imis50.vcf
		779 samples
		218,658 SNP


***) Filtering to keep biallelic SNPs LRLAC_WILD (vcf/LRLAC_WILD)
	
	3a-pipeline_filtering_INFO.sh
	
	LRLAC_WILD.snps.vcf
		791 samples
		18,210,693 biallelic SNP
	
	LRLAC_WILD.snps.filt_info.vcf
		791 samples
		2,290,900 info quality filtered biallelic SNP

	#Rename ChromosomeXX to Mesc6.1_chr_XX, ScaffoldXXXXX to Mesc6.1_sca_XXXXX
	cat LRLAC_WILD.snps.filt_info.vcf | \
		sed -E "s/Chromosome([0-90-9])/Mesc61_chr_\1/g" | \
		sed -E "s/Scaffold([0-90-90-90-90-9])/Mesc61_sca_\1/g" \
		> LRLAC_WILD.snps.filt_info.renamed.vcf

	#Filter to keep genotype of DP>=3, otherwise is set as missing genotype
	vcftools \
		--vcf LRLAC_WILD.snps.filt_info.vcf \
		--minDP 3 --recode --recode-INFO-all \
		--out LRLAC_WILD.snps.filt_info_dp3.vcf
	LRLAC_WILD.snps.filt_info_dp3.vcf
		791 samples
		2,290,900 SNP

	#Filter to keep variants of mac>=5 and den=0.90 (or den=0.99)
	vcftools \
		--vcf LRLAC_WILD.snps.filt_info_dp3.vcf \
		--recode --recode-INFO-all \
		--mac 5 \
		--out LRLAC_WILD.snps.filt_info_dp3_mac5.vcf
	LRLAC_WILD.snps.filt_info_dp3_mac5.vcf
		791 samples
		886,967 SNP
	export JAVA_OPTS="$JAVA_OPTS -Xms196G -Xmx196G"; \
	groovy filterDensity.groovy \
		LRLAC_WILD.snps.filt_info_dp3_mac5.vcf \
		LRLAC_WILD.snps.filt_info_dp3_mac5_den90.unsorted.vcf 0.90(0.99)
	grep '^#' LRLAC_WILD.snps.filt_info_dp3_mac5_den90.unsorted.vcf \
		> LRLAC_WILD.snps.filt_info_dp3_mac5_den90.vcf;
	grep -v '^#' LRLAC_WILD.snps.filt_info_dp3_mac5_den90.unsorted.vcf \
		| LC_ALL=C sort -T ./tmp/ -t$'\t' -k1,1 -k2,2n \
		>> LRLAC_WILD.snps.filt_info_dp3_mac5_den90.vcf;
	LRLAC_WILD.snps.filt_info_dp3_mac5_den90.vcf
		791 samples
		188,612 SNP
	LRLAC_WILD.snps.filt_info_dp3_mac5_den99.vcf
		791 samples
		4,539 SNP

	#Filter to keep variants of maf>=0.05 and den=0.90
	vcftools \
		--vcf LRLAC_WILD.snps.filt_info_dp3.vcf \
		--recode --recode-INFO-all \
		--maf 0.05 \
		--out LRLAC_WILD.snps.filt_info_dp3_maf5.vcf
	LRLAC_WILD.snps.filt_info_dp3_maf5.vcf
		791 samples
		756,833 SNP
	export JAVA_OPTS="$JAVA_OPTS -Xms196G -Xmx196G"; \
	groovy filterDensity.groovy \
		LRLAC_WILD.snps.filt_info_dp3_maf5.vcf \
		LRLAC_WILD.snps.filt_info_dp3_maf5_den90.unsorted.vcf 0.90
	grep '^#' LRLAC_WILD.snps.filt_info_dp3_maf5_den90.unsorted.vcf \
		> LRLAC_WILD.snps.filt_info_dp3_maf5_den90.vcf
	grep -v '^#' LRLAC_WILD.snps.filt_info_dp3_maf5_den90.unsorted.vcf \
		| LC_ALL=C sort -T ./tmp/ -t$'\t' -k1,1 -k2,2n \
		>> LRLAC_WILD.snps.filt_info_dp3_maf5_den90.vcf
	LRLAC_WILD.snps.filt_info_dp3_maf5_den90.vcf
		791 samples
		71,540 SNP
	
	#Keep good samples (missing<=0.5 on maf5_den90)
	calculate_istats.sh LRLAC_WILD.snps.filt_info_dp3_maf5_den90.vcf
	awk 'NR>1 && $10<=0.5 {print $1}' \
		LRLAC_WILD.snps.filt_info_dp3_maf5_den90.vcf.istats \
		> list-LRLAC_WILD.ok.maf5_imis50.txt
	vcftools \
		--vcf LRLAC_WILD.snps.filt_info_dp3_maf5_den90.vcf \
		--recode --recode-INFO-all \
		--keep list-LRLAC_WILD.ok.maf5_imis50.txt \
		--out LRLAC_WILD.snps.filt_info_dp3_maf5_den90_imis50.vcf
	LRLAC_WILD.snps.filt_info_dp3_maf5_den90_imis50.vcf
		779 samples
		71,540 SNP
	vcftools \
		--vcf LRLAC_WILD.snps.filt_info_dp3_mac5_den90.vcf \
		--recode --recode-INFO-all \
		--keep list-LRLAC_WILD.ok.maf5_imis50.txt \
		--out LRLAC_WILD.snps.filt_info_dp3_mac5_den90_imis50.vcf
	LRLAC_WILD.snps.filt_info_dp3_mac5_den90_imis50.vcf
		779 samples
		188,612 SNP


***) Detection of WILD in LRLAC_WILD (detect_wild) on mac5_den99_imis50

	#Get Sample list
	grep -n '^#CH' LRLAC_WILD.snps.filt_info_dp3_mac5_den99_imis50.vcf
	#Edit sample names to have length <=10 characters and replace the line 2078 in the vcf
	#Run SNPhylo with out group S1WPD1-1
	/home/agkanogiannis/software/SNPhylo/snphylo.sh \
		-v LRLAC_WILD.snps.filt_info_dp3_mac5_den99_imis50.vcf \
		-r -m 0.0001 -M 1 -P LRLAC_WILD -A -b -o S1WPD1-1
	Identify the WILD samples from the phylogenetic tree
		LRLAC_WILD.snps.filt_info_dp3_mac5_den99_imis50.bs.tree
	Final list of WILD samples
		list-WILD.ok.mac5_den99_imis50.txt
			58 samples


***) Detection of clones LRLAC_WILD (detect_clones) on mac5_den99_homs

	java -jar JavaUtils.jar VCF2TREE_2DIST -t 8 \
		-g \
		LRLAC_WILD.snps.filt_info_dp3_mac5_den99_imis50.vcf \
		> LRLAC_WILD.snps.filt_info_dp3_mac5_den99_imis50.homs.tree_dist

	Distance cut	= 0.004
	Tree cut height = 0.008

	java -jar Javautils.jar DIST2Clusters -t 8 \
		-c 0.008 \
		LRLAC_WILD.snps.filt_info_dp3_mac5_den99_imis50.homs.dist \
		2> LRLAC_WILD.snps.filt_info_dp3_mac5_den99_imis50.clusters.txt

	java -jar JavaUtils.jar VCFRemoveClones -t 8 \
		-g \
		-c 0.008 \
		-o LRLAC_WILD.snps.filt_info_dp3_mac5_den99_imis50_noclones.vcf \
		LRLAC_WILD.snps.filt_info_dp3_mac5_den99_imis50.vcf \
		2>LRLAC_WILD.snps.filt_info_dp3_mac5_den99_imis50_noclones.clusters.txt

	vcf-query \
		-l LRLAC_WILD.snps.filt_info_dp3_mac5_den99_imis50_noclones.vcf \
		> list-LRLAC_WILD.noclones.mac5_den99_imis50_homs.txt

	LRLAC_WILD.snps.filt_info_dp3_maf5_den90_imis50_noclones.vcf
		470 samples
		71,540 SNP


***) Detection of related in bCarotene population (vcf/bCarotene)

	list-GM905-57xGM905-60__GM905-60xGM905-52.txt__(betaCarotene).txt
	3a-pipeline_filtering_INFO.sh
	bCarotene.raw.vcf
		118 samples
		3,781,548 raw variants
	bCarotene.snps.vcf
		118 samples
		3,264,916 SNP
	bCarotene.snps.filt_info.vcf
		118 samples
		454,193 SNP

	#Rename ChromosomeXX to Mesc6.1_chr_XX, ScaffoldXXXXX to Mesc6.1_sca_XXXXX
	cat bCarotene.snps.INFO_PASS.orig.vcf | \
		sed -E "s/Chromosome([0-90-9])/Mesc61_chr_\1/g" | \
		sed -E "s/Scaffold([0-90-90-90-90-9])/Mesc61_sca_\1/g" \
		> bCarotene.snps.filt_info.vcf

	#Filter to keep genotype of DP>=3, otherwise is set as missing genotype
	vcftools \
		--vcf bCarotene.snps.filt_info.vcf \
		--minDP 3 --recode --recode-INFO-all \
		--out bCarotene.snps.filt_info_dp3.vcf
	bCarotene.snps.filt_info_dp3.vcf
		118 samples
		454,193 SNP

	#Filter for maf>=0.05
	vcftools \
		--vcf bCarotene.snps.filt_info_dp3.vcf \
		--maf 0.05 --recode --recode-INFO-all \
		--out bCarotene.snps.filt_info_dp3_maf5.vcf
	bCarotene.snps.filt_info_dp3_maf5.vcf
		118 samples
		301,795 SNP

	#Filtering on LRLAC_WILD_maf5_den90
	java -Xms64G -Xmx64G -Djava.io.tmpdir=`pwd`/tmp -jar GenomeAnalysisTK.jar \
		-T SelectVariants -selectType SNP -restrictAllelesTo BIALLELIC \
		-R Mesculenta_305_v6.named.fa \
		-L LRLAC_WILD.snps.filt_info_dp3_maf5_den90.vcf \
		-V bCarotene.snps.filt_info_dp3_maf5.vcf \
		-o bCarotene.LRLAC_WILD.snps.filt_info_dp3_maf5.vcf
	bCarotene.LRLAC_WILD.snps.filt_info_dp3_maf5.vcf
		118 samples
		32,969 SNP

	java -jar JavaUtils.jar VCF2DIST -t 8 \
		-h \
		bCarotene.LRLAC_WILD.snps.filt_info_dp3_maf5.vcf \
		> bCarotene.LRLAC_WILD.snps.filt_info_dp3_maf5.hets.dist

	java RADcaroteneFamilies \
		bCarotene.LRLAC_WILD.snps.filt_info_dp3_maf5.hets.dist \
		bCarotene.LRLAC_WILD.snps.filt_info_dp3_maf5.hets.dist

	java -jar JavaUtils.jar DIST2Hist \
		-o bCarotene.LRLAC_WILD.snps.filt_info_dp3_maf5.hets.dist.2degree.dist.png \
		bCarotene.LRLAC_WILD.snps.filt_info_dp3_maf5.hets.dist.2degree.dist

	1degree: 0.69 +/- 0.03 (x2 for cutheight !!!)
	2degree: 0.75 +/- 0.02 (x2 for cutheight !!!)


***) Detection of related in LRLAC_WILD population (vcf/LRLAC_WILD/detect_related)

	java -Xms64G -Xmx64G -Djava.io.tmpdir=`pwd`/tmp -jar GenomeAnalysisTK.jar \
		-T SelectVariants -selectType SNP -restrictAllelesTo BIALLELIC \
		-R Mesculenta_305_v6.named.fa \
		-L bCarotene.LRLAC_WILD.snps.filt_info_dp3_maf5.vcf \
		-V LRLAC_WILD.snps.filt_info_dp3_maf5_den95_imis50.vcf \
		-o LRLAC_WILD.bCarotene.snps.filt_info_dp3_maf5_den90_imis50.vcf

	#(1.54 for 2nd degree, 1.44 for 1st degree)
	java -jar JavaUtils.jar VCFNonrelated -t 8 \
		-h \
		-c 1.54 \
		-o LRLAC_WILD.bCarotene.snps.filt_info_dp3_maf5_den90_imis50_nonrelated-2.vcf \
		LRLAC_WILD.bCarotene.snps.filt_info_dp3_maf5_den90_imis50.vcf \
		2> LRLAC_WILD.bCarotene.snps.filt_info_dp3_maf5_den90_imis50_nonrelated-2.clusters.txt

	vcf-query \
		-l LRLAC_WILD.bCarotene.snps.filt_info_dp3_maf5_den90_imis50_nonrelated-2.vcf \
		| sort -n > list-LRLAC_WILD.nonrelated-2.txt

	vcftools \
		--vcf LRLAC_WILD.snps.filt_info_dp3_maf5_den90_imis50.vcf \
		--keep list-LRLAC_WILD.nonrelated-2.txt \
		--recode --recode-INFO-all \
		--out LRLAC_WILD.snps.filt_info_dp3_maf5_den90_imis50_nonrelated-2.vcf
	LRLAC_WILD.snps.filt_info_dp3_maf5_den90_imis50_nonrelated-1.vcf
		426 samples
		71,540 SNP
	LRLAC_WILD.snps.filt_info_dp3_maf5_den90_imis50_nonrelated-2.vcf
		269 samples
		71,540 SNP


***) Selecting WILD from LRLAC_WILD (vcf/WILD)

	vcftools \
		--vcf LRLAC_WILD.snps.filt_info_dp3_maf5_den90_imis50.vcf \
		--recode --recode-INFO-all \
		--keep list-WILD.ok.mac5_den99_imis50.txt \
		--out WILD.snps.filt_info_dp3_maf5_den90_imis50.vcf
	WILD.snps.filt_info_dp3_maf5_den90_imis50.vcf
		58 samples
		71,540 SNP

	vcftools \
		--vcf LRLAC_WILD.snps.filt_info_dp3_maf5_den90_imis50_nonrelated-2.vcf \
		--recode --recode-INFO-all \
		--keep list-WILD.ok.mac5_den99_imis50.txt \
		--out WILD.snps.filt_info_dp3_maf5_den90_imis50_nonrelated-2.vcf
	WILD.snps.filt_info_dp3_maf5_den90_imis50_nonrelated-2.vcf
		47 samples
		71,540 SNP

	vcf-query \
		-l WILD.snps.filt_info_dp3_maf5_den90_imis50_nonrelated-2.vcf \
		> WILD_imis50_nonrelated-2.names.txt


***) Selecting LRLAC from LRLAC_WILD (vcf/LRLAC)

	vcftools \
		--vcf LRLAC_WILD.snps.filt_info_dp3_maf5_den90_imis50.vcf \
		--recode --recode-INFO-all \
		--remove list-WILD.ok.mac5_den99_imis50.txt \
		--out LRLAC.snps.filt_info_dp3_maf5_den90_imis50.vcf
	LRLAC.snps.filt_info_dp3_maf5_den90_imis50.vcf
		721 samples
		71,540 SNP

	vcftools \
		--vcf LRLAC.snps.filt_info_dp3_maf5_den90_imis50.vcf \
		--recode --recode-INFO-all \
		--keep list-LRLAC_WILD.noclones.mac5_den99_homs.txt \
		--out LRLAC.snps.filt_info_dp3_maf5_den90_imis50_noclones.vcf
	LRLAC.snps.filt_info_dp3_maf5_den90_imis50_noclones.vcf
		421 samples
		71,540 SNP

	vcftools \
		--vcf LRLAC.snps.filt_info_dp3_maf5_den90_imis50.vcf \
		--recode --recode-INFO-all \
		--keep list-LRLAC_WILD.nonrelated-2.txt \
		--out LRLAC.snps.filt_info_dp3_maf5_den90_imis50_nonrelated-2.vcf
	LRLAC.snps.filt_info_dp3_maf5_den90_imis50_nonrelated-2.vcf
		222 samples
		71,540 SNP

	vcf-query \
		-l LRLAC.snps.filt_info_dp3_maf5_den90_imis50_nonrelated-2.vcf \
		> LRLAC_imis50_nonrelated-2.names.txt


***) Structure with admixture WILD maf5_nonrelated-2 (Structure_admixture/WILD)

	#Convert vcf to ped/map
	plink \
		--vcf WILD.snps.filt_info_dp3_maf5_den90_imis50_nonrelated-2.vcf.gz \
		--keep-allele-order --recode 12 --allow-extra-chr \
		--out WILD.snps.filt_info_dp3_maf5_den90_imis50_nonrelated-2

	#Run admixture K=1 to K=20 , 1 run , 5-cross validation
	bash go_admixture.sh \
		WILD_maf5_nonrelated-2 \
		WILD.snps.filt_info_dp3_maf5_den90_imis50_nonrelated-2.ped \
		1 20 1 20

	#One run for FINAL
	In FINAL for maf5 and K=2
	bash go_admixture_final.sh \
		WILD.snps.filt_info_dp3_maf5_den90_imis50_nonrelated-2 \
		2 10
	bash go_graphs_final.sh \
		WILD.snps.filt_info_dp3_maf5_den90_imis50_nonrelated-2 \
		WILD_imis50_nonrelated-2.names.txt \
		list-LRLAC_WILD.all.geo.txt \
		2


***) Structure with admixture LRLAC maf5_nonrelated-2 (Structure_admixture/LRLAC)

	#Convert vcf to ped/map
	plink \
		--vcf LRLAC.snps.filt_info_dp3_maf5_den90_imis50_nonrelated-2.vcf.gz \
		--keep-allele-order --recode 12 --allow-extra-chr \
		--out LRLAC.snps.filt_info_dp3_maf5_den90_imis50_nonrelated-2
	
	#Run admixture K=1 to K=20 , 1 run , 5-cross validation
	bash go_admixture.sh \
		LRLAC_maf5_nonrelated-2 \
		LRLAC.snps.filt_info_dp3_maf5_den90_imis50_nonrelated-2.ped \
		1 20 1 20

	#One run for FINAL
	In FINAL for maf5 and K=7
	bash go_admixture_final.sh \
		LRLAC.snps.filt_info_dp3_maf5_den90_imis50_nonrelated-2 \
		7 10
	bash go_graphs_final.sh \
		LRLAC.snps.filt_info_dp3_maf5_den90_imis50_nonrelated-2 \
		LRLAC_imis50_nonrelated-2.names.txt \
		list-LRLAC_WILD.all.geo.txt \
		7

	#Identify group names from map
		#LRLAC.snps.filt_info_dp3_maf5_den90_imis50_nonrelated-2.K7.mapplots.pdf
	LRLAC.snps.filt_info_dp3_maf5_den90_imis50_nonrelated-2.K7.groups2names.txt
	#Identify colors to 
	LRLAC.snps.filt_info_dp3_maf5_den90_imis50_nonrelated-2.K7.groups_colors.txt
	bash go_graphs_gnames_final.sh \
		LRLAC.snps.filt_info_dp3_maf5_den90_imis50_nonrelated-2 \
		LRLAC_imis50_nonrelated-2.names.txt \
		list-LRLAC_WILD.all.geo.txt \
		LRLAC.snps.filt_info_dp3_maf5_den90_imis50_nonrelated-2.K7.groups2names.txt \
		7 \
		LRLAC.snps.filt_info_dp3_maf5_den90_imis50_nonrelated-2.K7.groups_colors.txt

	while read -r line; 
	do \
		i=$(echo -n "$line"|awk '{print $1}');\
		j=$(echo -n "$line"|awk '{print $2}');\
		k=$(sed -n "${j}p" LRLAC.snps.filt_info_dp3_maf5_den90_imis50_nonrelated-2.K7.groups2names.txt);\
		echo -e "$i\t$k" ;\
	done\
	<LRLAC.snps.filt_info_dp3_maf5_den90_imis50_nonrelated-2.K7.groups.txt \
	>LRLAC.snps.filt_info_dp3_maf5_den90_imis50_nonrelated-2.K7.groups_names.txt


***) Structure with admixture LRLAC_WILD mac5 nonrelated-2 (Structure_admixture/LRLAC_WILD)

	#Convert vcf to ped/map
	plink \
		--vcf LRLAC_WILD.snps.filt_info_dp3_mac5_den90_imis50_nonrelated-2.vcf.gz \
		--keep-allele-order --recode 12 --allow-extra-chr \
		--out LRLAC_WILD.snps.filt_info_dp3_mac5_den90_imis50_nonrelated-2

	#Run admixture K=1 to K=20 , 5 runs , 5-cross validation
	bash go_admixture.sh \
		LRLAC_WILD_mac5_nonrelated-2 \
		LRLAC_WILD.snps.filt_info_dp3_mac5_den90_imis50_nonrelated-2 \
		1 20 5 40

	#One run for FINAL
	In FINAL for mac5 and K=9
	bash go_admixture_final.sh \
		LRLAC_WILD.snps.filt_info_dp3_mac5_den90_imis50_nonrelated-2 \
		9 10
	bash go_graphs_final.sh \
		LRLAC_WILD.snps.filt_info_dp3_mac5_den90_imis50_nonrelated-2 \
		LRLAC_WILD_imis50_nonrelated-2.names.txt \
		list-LRLAC_WILD.all.geo.txt \
		9

	#Identify group names from map
		#LRLAC_WILD.snps.filt_info_dp3_mac5_den90_imis50_nonrelated-2.K9.mapplots.pdf
	LRLAC_WILD.snps.filt_info_dp3_mac5_den90_imis50_nonrelated-2.K9.groups2names.txt
	bash go_graphs_gnames_final.sh \
		LRLAC_WILD.snps.filt_info_dp3_mac5_den90_imis50_nonrelated-2 \
		LRLAC_WILD_imis50_nonrelated-2.names.txt \
		list-LRLAC_WILD.all.geo.txt \
		LRLAC_WILD.snps.filt_info_dp3_mac5_den90_imis50_nonrelated-2.K9.groups2names.txt \
		9 \
		LRLAC_WILD.snps.filt_info_dp3_mac5_den90_imis50_nonrelated-2.K9.groups_colors.txt

	while read -r line; 
	do \
		i=$(echo -n "$line"|awk '{print $1}');\
		j=$(echo -n "$line"|awk '{print $2}');\
		k=$(sed -n "${j}p" LRLAC_WILD.snps.filt_info_dp3_mac5_den90_imis50_nonrelated-2.K9.groups2names.txt);\
		echo -e "$i\t$k" ;\
	done\
	<LRLAC_WILD.snps.filt_info_dp3_mac5_den90_imis50_nonrelated-2.K9.groups.txt \
	>LRLAC_WILD.snps.filt_info_dp3_mac5_den90_imis50_nonrelated-2.K9.groups_names.txt


***) Structure Projection with admixture LRLAC maf5 (Structure_admixture/LRLAC_projection)

	#Convert vcf to ped/map
	plink \
		--vcf LRLAC.snps.filt_info_dp3_maf5_den90_imis50.vcf.gz \
		--keep-allele-order --recode 12 --allow-extra-chr \
		--out LRLAC.snps.filt_info_dp3_maf5_den90_imis50

	#Run admixture in projection mode on LRLAC.snps.filt_info_dp3_maf5_den90_imis50.ped
	#Using as background LRLAC.snps.filt_info_dp3_maf5_den90_imis50_nonrelated-2.K7.run_01.P
	bash go_admixture_projection.sh \
		LRLAC.snps.filt_info_dp3_maf5_den90_imis50.ped \
		LRLAC.snps.filt_info_dp3_maf5_den90_imis50_nonrelated-2.K7.run_01.P \
		7 20
	bash go_graphs_projection.sh \
		LRLAC.snps.filt_info_dp3_maf5_den90_imis50 \
		LRLAC_imis50.names.txt \
		list-LRLAC_WILD.all.geo.txt \
		7

	#Use group names from background
	#LRLAC.snps.filt_info_dp3_maf5_den90_imis50_nonrelated-2.K7.groups2names.txt
	bash go_graphs_gnames_projection.sh \
		LRLAC.snps.filt_info_dp3_maf5_den90_imis50 \
		LRLAC_imis50.names.txt \
		list-LRLAC_WILD.all.geo.txt \
		LRLAC.snps.filt_info_dp3_maf5_den90_imis50_nonrelated-2.K7.groups2names.txt \
		7 \
		LRLAC.snps.filt_info_dp3_maf5_den90_imis50_nonrelated-2.K7.groups_colors.txt

	while read -r line; 
	do \
		i=$(echo -n "$line"|awk '{print $1}');\
		j=$(echo -n "$line"|awk '{print $2}');\
		k=$(sed -n "${j}p" LRLAC.snps.filt_info_dp3_maf5_den90_imis50_nonrelated-2.K7.groups2names.txt);\
		echo -e "$i\t$k" ;\
	done\
	<LRLAC.snps.filt_info_dp3_maf5_den90_imis50.K7.groups.txt \
	>LRLAC.snps.filt_info_dp3_maf5_den90_imis50.K7.groups_names.txt


***) Structure Projection with admixture LRLAC_WILD mac5 (Structure_admixture/LRLAC_WILD_projection)

	#Convert vcf to ped/map
	plink \
		--vcf LRLAC_WILD.snps.filt_info_dp3_mac5_den90_imis50.vcf.gz \
		--keep-allele-order --recode 12 --allow-extra-chr \
		--out LRLAC_WILD.snps.filt_info_dp3_mac5_den90_imis50

	#Run admixture in projection mode on LRLAC_WILD.snps.filt_info_dp3_mac5_den90_imis50.ped
	#Using as background LRLAC_WILD.snps.filt_info_dp3_mac5_den90_imis50_nonrelated-2.K9.run_01.P
	bash go_admixture_projection.sh \
		LRLAC_WILD.snps.filt_info_dp3_mac5_den90_imis50.ped \
		LRLAC_WILD.snps.filt_info_dp3_mac5_den90_imis50_nonrelated-2.K9.run_01.P \
		9 8
	bash go_graphs_projection.sh \
		LRLAC_WILD.snps.filt_info_dp3_mac5_den90_imis50 \
		LRLAC_WILD_imis50.names.txt \
		list-LRLAC_WILD.all.geo.txt \
		9

	#Use group names from background
	#LRLAC_WILD.snps.filt_info_dp3_mac5_den90_imis50_nonrelated-2.K9.groups2names.txt
	bash go_graphs_gnames_projection.sh \
		LRLAC_WILD.snps.filt_info_dp3_mac5_den90_imis50 \
		LRLAC_WILD_imis50.names.txt \
		list-LRLAC_WILD.all.geo.txt \
		LRLAC_WILD.snps.filt_info_dp3_mac5_den90_imis50_nonrelated-2.K9.groups2names.txt \
		9 \
		LRLAC_WILD.snps.filt_info_dp3_mac5_den90_imis50_nonrelated-2.K9.groups_colors.txt

	while read -r line; 
	do \
		i=$(echo -n "$line"|awk '{print $1}');\
		j=$(echo -n "$line"|awk '{print $2}');\
		k=$(sed -n "${j}p" LRLAC_WILD.snps.filt_info_dp3_mac5_den90_imis50_nonrelated-2.K9.groups2names.txt);\
		echo -e "$i\t$k" ;\
	done\
	<LRLAC_WILD.snps.filt_info_dp3_mac5_den90_imis50.K9.groups.txt \
	>LRLAC_WILD.snps.filt_info_dp3_mac5_den90_imis50.K9.groups_names.txt


***) Fst

#Fst of nonrelated
Fst from admixture log report

#Fst of all (nonrelated + projected)
Fst from vcftools

bash Fst.sh \
	LRLAC.snps.filt_info_dp3_mac5_den90_imis50.vcf.gz \
	LRLAC.snps.filt_info_dp3_mac5_den90_imis50.K7.groups_names.txt \
	LRLAC

bash Fst.sh \
	LRLAC_WILD.snps.filt_info_dp3_mac5_den90_imis50.vcf.gz \
	LRLAC_WILD.snps.filt_info_dp3_mac5_den90_imis50.K9.groups_names.txt \
	LRLAC_WILD


***) AMOVA

#Select independent SNPs from maf5
#density 0.98 with filterDensity
#ld<0.5
#10,392 SNPs
bcftools \
	+prune -w 100 -l 0.5 -Ov \
	-o LRLAC_WILD.snps.filt_info_dp3_maf5_den98_imis50_chr_ld50.vcf \
	LRLAC_WILD.snps.filt_info_dp3_maf5_den98_imis50_chr.vcf
#Impute missing genotypes
java \
	-jar /home/agkanogiannis/software/beagle/beagle.12Jul19.0df.jar \
	gt=LRLAC_WILD.snps.filt_info_dp3_maf5_den98_imis50_chr_ld50.vcf.gz \
	out=LRLAC_WILD.snps.filt_info_dp3_maf5_den98_imis50_chr_ld50_imp

#R script
#population file
LRLAC_WILD.snps.filt_info_dp3_mac5_den90_imis50.K9.groups_names.txt
#from population file, create pop, superpop
#sort population file to match sort order of genind (by line)
#final population file
LRLAC_WILD.snps.filt_info_dp3_mac5_den90_imis50.K9.groups_names.sorted.withsuperpop.txt

#in R script synchronize genind(from vcf) inds with population file inds


***) Phylogeny SNPhylo (Phylogeny)

/home/agkanogiannis/software/SNPhylo/snphylo.sh \
	-v LRLAC_WILD.snps.filt_info_dp3_mac5_den90_imis50.vcf \
	-r -m 0.0001 -M 1 -P LRLAC_WILD -A -b
/home/agkanogiannis/software/SNPhylo/snphylo.sh \
	-v LRLAC_WILD.snps.filt_info_dp3_mac5_den90_imis50_nonrelated-2.vcf \
	-r -m 0.0001 -M 1 -P LRLAC_WILD_nonrelated -A -b
/home/agkanogiannis/software/SNPhylo/snphylo.sh \
	-v LRLAC.snps.filt_info_dp3_mac5_den90_imis50.vcf \
	-r -m 0.0001 -M 1 -P LRLAC -A -b
/home/agkanogiannis/software/SNPhylo/snphylo.sh \
	-v LRLAC.snps.filt_info_dp3_mac5_den90_imis50_nonrelated-2.vcf \
	-r -m 0.0001 -M 1 -P LRLAC_nonrelated -A -b

#non hybrids phylogeny (for graph figure)
#from LRLAC_WILD_projection >0.99 selected (non hybrids)
val=0.99;
while read line;do 
	echo -n "$line"|awk -v val="$val"  '$2>val || $3>val || $4>val || $5>val || $6>val || $7>val || $8>val || $9>val || $10>val {print $1}';
done< LRLAC_WILD.snps.filt_info_dp3_mac5_den90_imis50.K9.qmatrix.txt 
| uniq > LRLAC_WILD.snps.filt_info_dp3_mac5_den90_imis50.K9.selected_${val}.txt

vcftools \
	--vcf LRLAC_WILD/LRLAC_WILD.snps.filt_info_dp3_mac5_den90_imis50.vcf \
	--keep Structure_admixture/LRLAC_WILD_projection/LRLAC_WILD.snps.filt_info_dp3_mac5_den90_imis50.K9.selected_0.99.txt \
	--recode --recode-INFO-all \
	--out LRLAC_WILD.snps.filt_info_dp3_mac5_den90_imis50_selected_0.99.vcf

#To keep all the 58 WILD
vcftools \
	--gzvcf ../raw_and_core/LRLAC_WILD.snps.filt_info_dp3_mac5_den90_imis50.vcf.gz \
	--keep <(cat ../../../lists/list-LRLAC_WILD.imis50_selected_LRLAC.txt ../../../lists/list-WILD.imis50.txt |sort|uniq) \
	--recode --recode-INFO-all \
	--out LRLAC_WILD.snps.filt_info_dp3_mac5_den90_imis50_selected_0.99.vcf

/home/agkanogiannis/software/SNPhylo/snphylo.sh -v LRLAC_WILD.snps.filt_info_dp3_mac5_den90_imis50_selected_0.99.vcf -r -m 0.0001 -M 1 -P LRLAC_WILD_selected -A -b

ATTENTION: When sample_name>10 their name is truncated by dnaml. We need to edit the output ml.tree and phylip.txt to replace duplicates berore continuing running with the bootstrap!!
ATTENTION: Or , when there are no duplicates, we need to change the names in the final ml.tree and bs.tree to match the itol colors files
ATTENTION: On itol, reroot LRLAC_WILD trees to S1WPD1-1 sample.
ATTENTION:(FIXED) 
	Use /home/agkanogiannis/software/SNPhylo/snphylo.edited.sh with -A (muscle)
		This runs muscle to fasta alignment
		then converts fasta to phylip relaxed (fasta_to_phylip_relaxed.R)
		then runs RAXML (not DNAML!!) to determine the tree


***) DAPC

	plink
	plink --vcf LRLAC.snps.INFO_PASS.MAF_05.den_95.noclones.vcf.gz --keep-allele-order --recode A --allow-extra-chr --out LRLAC.snps.INFO_PASS.MAF_05.den_95.noclones
	plink --vcf LRLAC.snps.INFO_PASS.MAF_05.den_95.noclones.nonrelated-3.vcf.gz --keep-allele-order --recode A --allow-extra-chr --out LRLAC.snps.INFO_PASS.MAF_05.den_95.noclones.nonrelated-3


	vcf replace ./.:etc with ./.
	vim %s/\.\/\.[0-9:,.]*\n/\.\/\.\r/g LRLAC.snps.INFO_PASS.MAF_05.den_95.noclones.vcf
	vim %s/\.\/\.[0-9:,.]*\t/\.\/\.\t/g LRLAC.snps.INFO_PASS.MAF_05.den_95.noclones.vcf


***) Treemix on LRLAC_WILD_nonrelated

#Use population allele frequencies from admixture for LRLAC_WILD_nonrelated K9 (these frequencies are computed without projection, directly from admixture)
LRLAC_WILD_nonrelated-2.K9.P

#Convert the population frequencies to counts, using population sizes
bash admixture_freq_2_treemix_counts.sh | gzip -c > LRLAC_WILD_nonrelated-2.K9.treemix.in.gz

# Create stem tree
/home/agkanogiannis/software/treemix-1.13/src/treemix -i LRLAC_WILD_nonrelated-2.K9.treemix.in.gz -root WILD-OG -o LRLAC_WILD_TreeMix_stem
#Run treemix rooted at WILD-OG with LD and 0-10 migration events and 5 replicates
for i in {0..10}; do 
	for j in {1..5}; do 
		/home/agkanogiannis/software/treemix-1.13/src/treemix \
			-i LRLAC_WILD_nonrelated-2.K9.treemix.in.gz \
			-m $i \
			-g LRLAC_WILD_TreeMix_stem.vertices.gz LRLAC_WILD_TreeMix_stem.edges.gz \
			-o LRLAC_WILD_TreeMix_m${i}_${j}; 
	done;
done;
#plot
for i in {0..10}; do
	/home/agkanogiannis/bin/Rscript --vanilla plot_results.R LRLAC_WILD_TreeMix_m${i}_1;
done

# Repeat the same TReeMix process, but this time with 8 groups (7 LRLAC + WILD-CWR)
# Remove column 2 (for WILD-OG) from allele frequencies .P matrix
# Create LRLAC_WILD_nonrelated-2.K8.treemix.in
# Create stem tree
/home/agkanogiannis/software/treemix-1.13/src/treemix -i LRLAC_WILD_nonrelated-2.K8.treemix.in.gz -root WILD-CWR -o LRLAC_WILD_TreeMix_stem
# Run treemix rooted at WILD-CWR with LD and 0-10 migration events and 5 replicates
for i in {0..10}; do 
	for j in {1..5}; do 
		/home/agkanogiannis/software/treemix-1.13/src/treemix \
			-i LRLAC_WILD_nonrelated-2.K8.treemix.in.gz \
			-m $i \
			-g LRLAC_WILD_TreeMix_stem.vertices.gz LRLAC_WILD_TreeMix_stem.edges.gz \
			-o LRLAC_WILD_TreeMix_m${i}_${j}; 
	done;
done;
#plot
for i in {0..10}; do
	/home/agkanogiannis/bin/Rscript --vanilla plot_results.R LRLAC_WILD_TreeMix_m${i}_1;
done
# Get log-likelihoods
for i in {1..10};do for j in {1..5}; do llik=$(grep 'Exiting' LRLAC_WILD_TreeMix_m${i}_${j}.llik|cut -d' ' -f7);echo -e "$i\t$j\t$llik"; done;done

# Run again for 6 migrations and enable standard errors (-se)
/home/agkanogiannis/software/treemix-1.13/src/treemix -i LRLAC_WILD_nonrelated-2.K8.treemix.in.gz -se -m 6 -g LRLAC_WILD_TreeMix_stem.vertices.gz LRLAC_WILD_TreeMix_stem.edges.gz -o LRLAC_WILD_TreeMix_m6_se



***) ABBA-BABA

#Using Manuel scripts
######
#populations file (samplename\tpopname\n)
# 3 WILD-CWR accessions removed because was not clear which ssp were member of (ALTXXX-3, IRWXXX-6, ALTXXX-4)

#separate LRLAC-'population name'
pops/LRLAC_WILD.K9.pops.abba_baba.LRLAC.txt
#all LRLAC as one population
pops/LRLAC_WILD.K9.pops.abba_baba.LRLAC-XXX.txt

#genotype tab file created using VCF2TABLE from JavaUtils (mode1)
#Keep only SNPs on chromosomes
java -jar JavaUtils-0.0.1-SNAPSHOT-jar-with-dependencies.jar \
	VCF2TABLE \
	LRLAC_WILD.snps.filt_info_dp3_mac5_den90_imis50.vcf \
	| grep -v "^Mesc61_sca" > LRLAC_WILD.snps.filt_info_dp3_mac5_den90_imis50.geno.tab

#creation of population scheme files (popname\t[1-4]\n)
#CWR_CWR_LRLAC-***_WILD-OG.scheme.txt
#CWR_CWR_LRLAC_WILD-OG.scheme.txt
bash create_scheme.sh

#run ABBA analyses, windows 10Mb
perl 1_batch_abba_baba.pl

#get result D and stdD
bash results.sh > results.txt

#Using Admixtools software
######
#Convert vcf to eigenstrat
python vcf2eigenstrat.py \
	-v <(grep -vi "^Mesc61_sca" LRLAC_WILD.snps.filt_info_dp3_mac5_den90_imis50.vcf) \
	-o LRLAC_WILD.snps.filt_info_dp3_mac5_den90_imis50.eigenstrat

#replace chrom names with numbers in .snp
sed -i 's/Mesc61_chr_//g' LRLAC_WILD.snps.filt_info_dp3_mac5_den90_imis50.eigenstrat.snp

#add pop info on the 3rd column of .ind
paste \
	<(cat LRLAC_WILD.snps.filt_info_dp3_mac5_den90_imis50.eigenstrat.ind|sort|awk '{print $1"\t"$2}') \
	<(cat ../../00.Structure_admixture/LRLAC_WILD_projection/LRLAC_WILD.snps.filt_info_dp3_mac5_den90_imis50.K9.groups_names.abba-baba-qpDstat.LRLAC-XXX.txt|sort|awk '{print $2}')\
	>LRLAC_WILD.snps.filt_info_dp3_mac5_den90_imis50.eigenstrat.LRLAC-XXX.ind
paste \
	<(cat LRLAC_WILD.snps.filt_info_dp3_mac5_den90_imis50.eigenstrat.ind|sort|awk '{print $1"\t"$2}') \
	<(cat ../../00.Structure_admixture/LRLAC_WILD_projection/LRLAC_WILD.snps.filt_info_dp3_mac5_den90_imis50.K9.groups_names.abba-baba-qpDstat.LRLAC.txt|sort|awk '{print $2}')\
	>LRLAC_WILD.snps.filt_info_dp3_mac5_den90_imis50.eigenstrat.LRLAC.ind

#Create population combination files
qpDstat.poplist.LRLAC-XXX.txt
qpDstat.poplist.LRLAC.txt

#Run qpDstat for WILD-CWR-XXX WILD-CWR-XXX LRLAC-XXX
/home/agkanogiannis/software/AdmixTools/bin/qpDstat -p qpDstat.params.LRLAC-XXX.txt > LRLAC-XXX.log
#Run qpDstat for WILD-CWR-XXX WILD-CWR-XXX LRLAC
/home/agkanogiannis/software/AdmixTools/bin/qpDstat -p qpDstat.params.LRLAC.txt > LRLAC.log

#Total results
abba-baba-qpDstat.xlsx


***) RangeExpansion

#Filter LRLAC_WILD maf5 vcf 98% density, only chromosome loci, ld 50%
cat LRLAC_WILD.snps.filt_info_dp3_maf5_den90_imis50.vcf |grep -vi "##contig=<ID=Mesc61_sca" | grep -vi "^Mesc61_sca" > tmp.vcf;
groovy filterDensity.groovy \
	tmp.vcf \
	LRLAC_WILD.snps.filt_info_dp3_maf5_den98_imis50_chr.unsorted.vcf 0.98;
bash sort_vcf.sh \
	LRLAC_WILD.snps.filt_info_dp3_maf5_den98_imis50_chr.unsorted.vcf \
	LRLAC_WILD.snps.filt_info_dp3_maf5_den98_imis50_chr.vcf tmp;
bcftools +prune -w 50 -l 0.50 -Ov \
	-o LRLAC_WILD.snps.filt_info_dp3_maf5_den98_imis50_chr_ld50.vcf \
	LRLAC_WILD.snps.filt_info_dp3_maf5_den98_imis50_chr.vcf;
rm tmp.vcf;

#Keep in vcf only samples with geo information
vcftools \
	--vcf LRLAC_WILD.snps.filt_info_dp3_maf5_den98_imis50_chr_ld50.vcf \
	--keep <(cat list-LRLAC_WILD.all.geo.txt | cut -d',' -f1 | grep -v "^#") \
	--recode --recode-INFO-all \
	--out LRLAC_WILD.snps.filt_info_dp3_maf5_den98_imis50_chr_ld50_geoinfo.vcf

#Convert filtered vcf to bed
plink \
	--vcf LRLAC_WILD.snps.filt_info_dp3_maf5_den98_imis50_chr_ld50_geoinfo.vcf \
	--keep-allele-order --allow-extra-chr --set-missing-var-ids "@_#" --make-bed \
	--out LRLAC_WILD.snps.filt_info_dp3_maf5_den98_imis50_chr_ld50_geoinfo

#Create geo tab file
bash create_geo.sh

#Adjust various RangeExpansion_geo_LRLAC_XXX.csv files for outgroup info etc.

#Run RangExpansion R scripts
Rscript RangeExpansion_LRLAC.R
Rscript RangeExpansion_LRLAC_FLA.R
Rscript RangeExpansion_LRLAC_PER.R
Rscript RangeExpansion_LRLAC_TST.R
Rscript RangeExpansion_LRLAC_WILD-OG.R
Rscript RangeExpansion_LRLAC_WILD.R


***) PopLDdecay

#Keep only Chromosomes
cat \
	LRLAC_WILD.snps.filt_info_dp3_maf5_den90_imis50.vcf \
	| grep -vi "##contig=<ID=Mesc61_sca" | grep -vi "^Mesc61_sca" \
	> LRLAC_WILD.snps.filt_info_dp3_maf5_den90_imis50_chr.vcf
#Split into 18 Chromosomes
for i in {01..18};do \
	cat LRLAC_WILD.snps.filt_info_dp3_maf5_den90_imis50_chr.vcf \
	| grep -i "^#\|^Mesc61_chr_${i}" \
	> LRLAC_WILD.snps.filt_info_dp3_maf5_den90_imis50_chr_${i}.vcf ;\
done

#Run PopLDdecay
bash poplddecay.sh
#Run plot
bash poplddecay_plot.sh


***) Karyoploter (SNP_stats_Karyoploter)

#Create a list of SNP chromosome, position, ID for maf5_den90 and mac5_den90, only in chromosomes
zgrep -v "^##" \
	LRLAC_WILD.snps.filt_info_dp3_maf5(mac5)_den90_imis50_chr.vcf.gz \
	| cut -f1-3 \
	| sed 's/Mesc61_chr_//g' \
	| awk '{print $1"\t"$2"\t"$1"_"$2}' \
	> LRLAC_WILD.snps.filt_info_dp3_maf5(mac5)_den90_imis50_chr.snps.txt

#Get the lengths of chromosomes
zgrep "^##contig=" \
	LRLAC_WILD.snps.filt_info_dp3_maf5_den90_imis50_chr.vcf.gz \
	| awk -F '[=,>]' '{print $3"\t"$5}' \
	| sed 's/Mesc61_chr_//g' \
	> chr.lengths.txt

#Run karyoploter script
Rscript karyoploter_maf5(mac5).R
