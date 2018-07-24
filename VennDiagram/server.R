library("shiny")
library("shinyBS")
library("Vennerable")
source("data_create_func.R")
source("all_coOrds.R")

options(shiny.maxRequestSize=1000*1024^2)
shinyServer(function(input, output){
	
	readFile <- reactive({
		inFile <- input$file1
		read.csv(inFile$datapath, header=input$header, sep=input$sep, quote=input$quote)
		})
	
	create_dDown <- function(nm,cmp_name){
		rdUI <- renderUI({
  				if (is.null(input$file1)){return(NULL)}
					da <- vals$fl
					ds <- gsub(".FDR","",grep(".FDR$",names(da),value=T))
					selectInput(nm, cmp_name, choices = c("select",ds))#,width="80%")
				})
		return(rdUI)
		}
  
	create_numIP <- function(nm,title,type){
		if (type == "pval"){v_default <- 0.05; v_min <- 0.01; v_max <- 1; v_step <- 0.01}
		else if (type == "fc"){v_default <- 1.5; v_min <- 0.5; v_max <- 10; v_step <- 0.5}
		rdNP <- renderUI({
			if (is.null(input$file1)){return(NULL)}
				numericInput(nm,title,v_default,min=v_min,max=v_max,step=v_step)
			})
		return(rdNP)
		}
		
	get_values <- function(){
		if (is.null(input$file1)){return(NULL)}
		if ((input$d1a == "select") || (input$d2a == "select")){ return(NULL)}
		data <- as.data.frame(vals$fl)
        	criti <- input$criti
		o_pairs <- c(input$d1a,input$d2a)
		o_thresh <- c(input$d1p,input$d2p)
		o_fc <- c(input$d1f,input$d2f)
		cond_ck <- input$cond2
		if (input$num >= 3) {
			if (input$d3a == "select"){return(NULL)}
			o_pairs <- append(o_pairs,input$d3a)
			o_thresh <- append(o_thresh,input$d3p)
			o_fc <- append(o_fc,input$d3f)
			cond_ck <- input$cond3
			}
		if (input$num >= 4) {
			if (input$d4a == "select"){return(NULL)}
			o_pairs <- append(o_pairs,input$d4a)
			o_thresh <- append(o_thresh,input$d4p)
			o_fc <- append(o_fc,input$d4f)
			cond_ck <- input$cond4
			}
		out_list <- list(da=data,pairs=o_pairs,thresh=o_thresh,fc=o_fc,cond=cond_ck,cri=criti)
		return(out_list)
		}
		
	get_genes <- function(df,x,y,cds){
		for (c in 1:length(cds)){
			if ((x > cds[[c]]$x[1] & x < cds[[c]]$x[2]) & (y < cds[[c]]$y[1] & y > cds[[c]]$y[2])){
				click_cond <- names(cds)[c]
				break
				}
			else {click_cond <- NULL}
			}
		if(is.null(click_cond)){return(NULL)}
		fPos <- which(df["Condition"] == click_cond)
		fGenes <- as.data.frame(df[fPos,1])
		names(fGenes) <- "Genes"
		return(fGenes)
		}
	
	vals <- reactiveValues()
	observe({
		if (is.null(input$file1)){vals$fl <- NULL}
		else{vals$fl <- readFile()}
	})
	
	output$dDown1 <- create_dDown("d1a","Comparison 1:")
	output$dD1p <- create_numIP("d1p","Threshold(Pval/FDR):","pval")
	output$dD1f <- create_numIP("d1f","FC:","fc")
  
	output$dDown2 <- create_dDown("d2a","Comparison 2:")
	output$dD2p <- create_numIP("d2p","Threshold(Pval/FDR):","pval")
	output$dD2f <- create_numIP("d2f","FC:","fc")
	
	output$dDown3 <- create_dDown("d3a","Comparison 3:")
	output$dD3p <- create_numIP("d3p","Threshold(Pval/FDR):","pval")
	output$dD3f <- create_numIP("d3f","FC:","fc")
	
	output$dDown4 <- create_dDown("d4a","Comparison 4:")
	output$dD4p <- create_numIP("d4p","Threshold(Pval/FDR):","pval")
	output$dD4f <- create_numIP("d4f","FC:","fc")
	
	output$venn <- renderPlot({
	 	vList <- get_values()
		if (is.null(vList)){return(NULL)}
		gList <- main_filter(vList$da,vList$pairs,vList$thresh,vList$fc,vList$cri,"all","list")
		ven <- Venn(gList)
		plot.new()
		if(input$num==4){plot(ven,doWeights = F,show=list(Sets=F),type="ellipses")}
		else {plot(ven,doWeights = F,show=list(Sets=F))}
    	})
		
	output$gtable <- renderTable({
		if (is.null(input$tryClick)){return(NULL)}
		x <- input$tryClick$x
		y <- input$tryClick$y
		nComp <- paste(input$num,"_comp",sep="")
		cur_cords <- co_ords[[which(names(co_ords) == nComp)]]
		gList <- get_values()
		gTab <- main_filter(gList$da,gList$pairs,gList$thresh,gList$fc,gList$cri,"all","table")
		get_genes(gTab,x,y,cur_cords)
	})
  
	output$table <- renderDataTable({
		tList <- get_values()
		if (is.null(tList)){return(NULL)}
		main_filter(tList$da,tList$pairs,tList$thresh,tList$fc,tList$cri,tList$cond,"table")
	},options = list(searching=TRUE,search.caseInsensitive=TRUE))
  
	output$downloadData <- downloadHandler(
		filename = function() { 
      		paste('filtered_table',Sys.Date(),'.txt', sep='')},
	  	content = function(file) {
	    	dList <- get_values()
	    	if (is.null(dList)){return(NULL)}
	    	filt_tab <- main_filter(dList$da,dList$pairs,dList$thresh,dList$fc,dList$cri,dList$cond,"table")
	    	write.table(filt_tab, file, sep="\t", quote=FALSE,row.names=F,col.names=T)
	  })
	})
