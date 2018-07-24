## Shiny file upload :https://shiny.rstudio.com/gallery/file-upload.html

library(shiny)
#keytypes(org.Mm.eg.db)

# Define UI for data upload app ----
ui <- fluidPage(
  
  # App title ----
  titlePanel("Uploading Files"),
  
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    
    # Sidebar panel for inputs ----
    sidebarPanel(
      
      # Input: Select a file ----
      fileInput("file1", "Choose CSV File",
                multiple = FALSE,
                accept = c("text/csv",
                           "text/comma-separated-values,text/plain",
                           ".csv")),
      
      # Horizontal line ----
      tags$hr(),
      
      # Input: Checkbox if file has header ----
      checkboxInput("header", "Header", TRUE),
      
      # Input: Select separator ----
      radioButtons("sep", "Separator",
                   choices = c(Comma = ",",
                               Semicolon = ";",
                               Tab = "\t"),
                   selected = "\t"),
      
      # Horizontal line ----
      tags$hr(),
      
      # Input: Select number of rows to display ----
      radioButtons("disp", "Display",
                   choices = c(Head = "head",
                               All = "all"),
                   selected = "head"),
      tags$hr(),
      radioButtons(inputId = "species",
                   label="Select Organism",
                   choices=c("mouse","human"),
                   selected="mouse"),
      tags$hr(),
      radioButtons(inputId="ip_var",
                   label="User input Gene IDs:", 
                   choices=c("ENSEMBL","GENENAME","MGI","SYMBOL","ENTREZID"),
                   selected = "SYMBOL"),
      radioButtons(inputId="op_var", 
                   label="Convert Gene IDs to:", 
                   choices=c("ENSEMBL","GENENAME","MGI","SYMBOL","ENTREZID"),
                   selected="ENSEMBL"),
      downloadButton("downloadData", "Download")
      ),
    
    # Main panel for displaying outputs ----
    mainPanel(
      # Output: Data file ----
      tableOutput("contents")
      
    )
    
  )
)

# Define server logic to read selected file ----
server <- function(input, output) {
    getMatrixWithSelectedIds <- function(df, type, keys,sp){
    require("AnnotationDbi")
     if (sp=="mouse"){
       library("org.Mm.eg.db")
       org_db <- org.Mm.eg.db
     }
     else if(sp=="human"){
       library("org.Hs.eg.db")
       org_db <- org.Hs.eg.db
     }
    geneSymbols <- mapIds(org_db, keys=df[,1], column=type, keytype=keys, multiVals = "first" )
    df2 <- df[which(df[,1] %in% names(geneSymbols)),1]
    df2 <- cbind.data.frame(df2,geneSymbols,species(org.Mm.eg.db),type)
    colnames(df2) <- c(keys,type,"species","source")
    rownames(df2) <- c(1:nrow(df2))
    return(df2)
  }
  
  readFile <- reactive({
    req(input$file1)
    tryCatch(
      {
    inFile <- input$file1
      read.csv(inFile$datapath, header= input$header, sep = input$sep, stringsAsFactors=F)
      },
    error = function(e) {
      stop(safeError(e))
    }
    )
    })
  
  output$contents <- renderTable({
    if (is.null(input$file1))
      return(NULL)
    df <- readFile()
    if(input$disp == "head") {
      df_convert <- getMatrixWithSelectedIds(head(df), type=input$op_var, keys=input$ip_var,sp=input$species)
      return(df_convert)
    }
    else {
      df_convert <-  getMatrixWithSelectedIds(df, type=input$op_var, keys=input$ip_var,sp=input$species)
      return(df_convert)
    }
  })
  
  output$downloadData <- downloadHandler(
    filename = function(){ paste("geneconverted",".txt",sep="")},
    content = function(file){
      df <- readFile()
      op_table <-  getMatrixWithSelectedIds(df, type=input$op_var, keys=input$ip_var,sp=input$species)
      write.table(op_table,file,row.names = FALSE,col.names=T, sep="\t",quote=F)
      })
}

# Create Shiny app ----
shinyApp(ui, server)

