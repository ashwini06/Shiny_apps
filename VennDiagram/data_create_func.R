options(stringsAsFactors= FALSE)

ext_create <- function(nams,ext,sept){
	op <- c()
	for (i in 1:length(nams)){op[i] <- paste(nams[i],ext,sep=".")}
	return(op)
	}
header_create <- function(clCri,fcvals){
	op <- c("Genes","Condition")
	for (p in 1:length(clCri)){op <- append(op,c(clCri[p],fcvals[p]))}
	return(op)
	}

# lName_create <- function(nams){
# 	op <- c()
# 	for (l in 1:length(nams)){op <- append(op,gsub('(.*)_vs_(.*).*','\\1\\2',nams[l]))}
# 	return(op)
# 	}

main_filter <- function(ip,args,thresh_cut,fc_cut,criti,ck_cond,op_type){
	colCriti <- ext_create(args,criti)
	logFCs <- ext_create(args,"FC")
	allFail <- paste(rep('-',length(args)),collapse='')
	op_table <- data.frame();
	gene_list <- list();
	tab_name <- header_create(colCriti,logFCs)
	genes <- ip[,1]

	for (g in 1:nrow(ip)){
		cond = ""; op_row <- c(genes[g])
		for (n in 1:length(args)){
			criVal <- ip[g,colCriti[n]]
			fcVal <- ip[g,logFCs[n]]
			if(length(gene_list) < length(args)){gene_list[[n]] <- vector()}
			if ((!is.na(criVal) && criVal <= thresh_cut[n]) && (!is.na(abs(fcVal)) && abs(fcVal) >= fc_cut[n])){
        			cond <- paste(cond,"+",sep="");
				gene_list[[n]] <- append(gene_list[[n]],genes[g])
				}
			else {
				cond <- paste(cond,"-",sep="")
				}
			op_row <- append(op_row, c(criVal,fcVal)) 
			}
		op_row <- append(op_row, cond, after=1)
		if ((cond != allFail) && (length(unlist(strsplit(cond,''))) == length(args))){
			op_table <- rbind(op_table,op_row)
			}
		}
	names(op_table) <- tab_name
	# names(gene_list) <- lName_create(args)
  	names(gene_list) <- paste(rep('C',length(args)),1:length(args),sep='')
	if (op_type == "list"){
		return(gene_list)
		}
	else if(op_type == "table"){
		if (ck_cond == "all"){
			return(op_table)
			}
		else {
  			pos <- which(op_table["Condition"] == ck_cond)
			return(op_table[pos,])
			}
		}
	}
