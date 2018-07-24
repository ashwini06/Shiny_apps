library(shiny)
library(amap)
library(gplots)
# Define server logic for random distribution application
shinyServer(function(input, output) {
  
  readFile <- reactive({
    inFile <- input$file1
    read.csv(inFile$datapath, header= input$header, sep="\t", stringsAsFactors=F)
  })
  
  output$contents <- renderTable({
    if (is.null(input$file1))
      return(NULL)
    readFile()
  })
  
  hmap <- function(data){
    cn <- c(colnames(data))
    gene_dist <- Dist(data,method=input$dist.meth)
    gene_cluster <- hclust(gene_dist,method=input$clust.meth) 
    samp_dist <-Dist(t(data),method=input$dist.meth)
    hm <- heatmap.2(data[,cn], Colv=FALSE, dendrogram="row",trace="none", margin=c(8,9), Rowv=as.dendrogram(gene_cluster),
              hclust=hclust,distfun=dist,col=input$colorScheme,density.info="none",key=T,keysize=1,cexRow=0.65,key.xlab="Row Z-score")
    return(hm)
  }
  
  output$h_clust <- renderPlot({
    if (is.null(input$file1))
      return(NULL)
    data <- readFile()
    df <- as.matrix(data[,c(2:ncol(data))])
    samp_dist <-Dist(t(df),method=input$dist.meth)
    samp_cluster <- hclust(samp_dist,method=input$clust.meth)
    plot(samp_cluster,main="Sample-wise Clustering")
  },height = 800, width = 600,res=100)
  
#   output$heat.clus <- renderPlot({
#     if (is.null(input$file1)){return(NULL)}
#     data <- readFile()
#     df <- as.matrix(data[,c(2:ncol(data))])
#     cn <- colnames(df)
#     #df <- as.matrix(data[,c(3:5)])
#     rownames(df)<-data[,1]
#     gene_dist <- Dist(df,method=input$dist.meth)
#     gene_cluster <- hclust(gene_dist,method=input$clust.meth) 
#     samp_dist <-Dist(t(df),method=input$dist.meth)
#     #samp_cluster <- hclust(samp_dist,method=input$clust.meth)
#     heatmap.2(df[,cn], Colv=FALSE, dendrogram="row",trace="none", margin=c(8,9), Rowv=as.dendrogram(gene_cluster),
#     hclust=hclust,distfun=dist,col=input$colorScheme,density.info="none",key=T,keysize=1,cexRow=0.65,key.xlab="Row Z-score")
#     
#   },height = 900, width = 700,res=100)

  output$heat.clus <- renderPlot({
    if (is.null(input$file1)){return(NULL)}
    data <- readFile()
    df <- as.matrix(data[,c(2:ncol(data))])
    rownames(df) <- data[,1]
    hm <- hmap(df)
  },height = 900, width = 700,res=100)
  
  output$down <- downloadHandler(
    filename = function(){ paste("heatmap",input$plotExt,sep=".")},
    content = function(file){
     if (is.null(input$file1)){return(NULL)}
      data <- readFile()
      df <- as.matrix(data[,c(2:ncol(data))])
      rownames(df) <- data[,1]
      if(input$plotExt == "png")
      {png(file)}#, width = 700, height= 900,units="px",pointsize=12,res=250)
      else if (input$plotExt == "pdf")
      {pdf(file)}
      hm <- hmap(df)
      print(hm)
      dev.off()
    }
    )
})