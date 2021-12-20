#!/home/agkanogiannis/bin/Rscript

#
# 4.pophelper.R
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

install.packages(c("devtools","ggplot2","gridExtra","gtable","tidyr"),dependencies=T)
devtools::install_github('royfrancis/pophelper')

args = commandArgs(trailingOnly=TRUE)

library(pophelper)

sNMF_dir <- args[1]
clumpp_dir <- args[2]
output_dir <- args[3]
samples_names <- args[4]
maxK <- as.integer(args[5])
runs <- as.integer(args[6])

#dir.create(file.path(getwd(), output_dir), showWarnings = FALSE)

sNMFfiles <- list.files(path=sNMF_dir,full.names=T,pattern="*.Q",recursive=T)
qlist <- readQ(files=sNMFfiles, filetype="basic")
tr1 <- tabulateQ(qlist=qlist, writetable=T,exportpath=output_dir)
sr1 <- summariseQ(tr1, writetable=T, exportpath=output_dir)
#em <- evannoMethodStructure(data=sr1,exportplot=T,writetable=T,na.rm=T)
names <- readLines(samples_names)

shiny=c("#0C5BB0",
	"#EE0011",
	"#15983D",
	"#EC579A",
	"#FA6B09",
	"#149BED",
	"#A1C720",
	"#FEC10B",
	"#16A08C", 
	"#9A703E",
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


for (K in 2:maxK) {
  print(K)
  
  KXX.pre.q <- qlist[sapply(qlist, function(x) attr(x,"k")==K)]
  KXX.aligned.q <-readQ(paste0(paste0(paste0(clumpp_dir,"/K",K),".popq.aligned")))
  KXX.merged.q  <-readQ(paste0(paste0(paste0(clumpp_dir,"/K",K),".popq.merged")))

  for (i in 1:runs){
    row.names(KXX.pre.q[[i]]) <- names
    colnames(KXX.pre.q[[i]]) <- sprintf("Cluster%02d",seq(1:K))
    row.names(KXX.aligned.q[[i]]) <- names
    colnames(KXX.aligned.q[[i]]) <- sprintf("Cluster%02d",seq(1:K))
  }
  row.names(KXX.merged.q[[1]]) <- names  
  colnames(KXX.merged.q[[1]]) <- sprintf("Cluster%02d",seq(1:K))
  
  #plotQ(qlist=KXX.pre.q, useindlab=T, showindlab=T, clustercol=shiny[1:K],
  #      indlabangle=90, indlabsize=0.5, imgtype="png", dpi=2000, indlabcol="black", 
  #      imgoutput="join", outputfilename=paste0(paste0("barplots/K",K),".pre.q"))
  #plotQ(qlist=KXX.aligned.q, useindlab=T, showindlab=T, clustercol=shiny[1:K],
  #      indlabangle=90, indlabsize=0.5, imgtype="png", dpi=2000, indlabcol="black", 
  #      imgoutput="join", outputfilename=paste0(paste0("barplots/K",K),".aligned.q"))
  data_plot_sorted <- plotQ(qlist=KXX.merged.q, returndata=T, returnplot=F, splab=paste0("k=",K), sortind="all", useindlab=T, showindlab=T, clustercol=shiny[1:K],
                indlabangle=90, indlabsize=0.5, imgtype="png", dpi=2000, indlabcol="black", 
                showlegend=T, legendlab=sprintf("Group%s",seq(1:K)),
                imgoutput="sep", outputfilename=paste0(paste0(paste0(output_dir,"/K",K),".merged.q")))
  write.table(data_plot_sorted$data$qlist, paste0(paste0(paste0(output_dir,"/K",K),".qmatrix.txt")), append=F, sep="\t", dec=".", row.names=T, col.names=F, quote=F)
  write.table(apply(data_plot_sorted$data$qlist$`K`,1,which.max), paste0(paste0(paste0(output_dir,"/K",K),".groups.txt")), append=F, sep="\t", dec=".", row.names=T, col.names=F, quote=F)
  
  #itol piechart
  header <- "DATASET_PIECHART\nSEPARATOR COMMA\nDATASET_LABEL,Pie\nCOLOR,#ff0000\nFIELD_COLORS"
  for (i in 1:K) header <- paste0(header,",",shiny[i]) 
  header <- paste0(header,"\nFIELD_LABELS")
  for (i in 1:K) header <- paste0(header,",G",i) 
  header <- paste0(header,"\nMARGIN,-25.0\nHEIGHT_FACTOR,1.8\nBORDER_WIDTH,1.0\nLEGEND_TITLE,Groups\nLEGEND_SHAPES")
  for (i in 1:K) header <- paste0(header,",2")
  header <- paste0(header,"\nLEGEND_COLORS")
  for (i in 1:K) header <- paste0(header,",",shiny[i])
  header <- paste0(header,"\nLEGEND_LABELS")
  for (i in 1:K) header <- paste0(header,",G",i)
  header <- paste0(header,"\nDATA\n")
  writeChar(header,paste0(paste0(paste0(output_dir,"/K",K),".itol_piechart.txt")),eos=NULL)
  mat1 <- matrix(-1,nrow=length(names))
  mat2 <- matrix(50,nrow=length(names))
  write.table(cbind(mat1,mat2,data_plot_sorted$data$qlist$`K`),paste0(paste0(paste0(output_dir,"/K",K),".itol_piechart.txt")),col.names=F, quote=F,sep=",",append=T)
  
  #itol strip
  header <- "DATASET_COLORSTRIP\nSEPARATOR TAB\nDATASET_LABEL\tstrip\n#COLOR\t#ff0000\nCOLOR_BRANCHES\t0\nSTRIP_WIDTH\t10\nMARGIN\t25\nBORDER_WIDTH\t1.0\nDATA\n"
  writeChar(header,paste0(paste0(paste0(output_dir,"/K",K)),".itol_strip.txt"),eos=NULL)
  write.table(paste(rownames(data_plot_sorted$data$qlist$`K`),shiny[apply(data_plot_sorted$data$qlist$`K`,1,which.max)], sep="\t"),paste0(paste0(paste0(output_dir,"/K",K),".itol_strip.txt")),row.names=F, col.names=F, quote=F,sep="\t",append=T)
  
}

