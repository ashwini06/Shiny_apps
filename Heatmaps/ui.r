shinyUI(fluidPage(
  titlePanel("Heatmaps"),
  sidebarLayout(
  sidebarPanel(
    fileInput('file1', 'Choose Input File',
              accept=c('text/csv', 'text/comma-separated-values,text/plain', '.csv')),
    tags$hr(),
    checkboxInput('header', 'Header', T),
    selectInput("dist.meth", 
                  label = "Choose a Distance Measure",
                  choices = c("euclidean", "pearson",
                              "spearman", "manhattan"),
                  selected = "euclidean"),
    selectInput("clust.meth", 
                label = "Choose a clustering-linkage method",
                choices = c("average", "complete",
                            "single","ward.D2"),
                selected = "complete"),
    selectInput("colorScheme", 
                label = "Choose color scheme for heatmap",
                choices = c("greenred","heat.colors", "topo.colors",
                            "bluered","terrain.colors"),
                selected = "greenred"),
    radioButtons("plotExt",label="Save the plot",choices=list("png","pdf"))
  ),
  mainPanel(
    tabsetPanel(
        tabPanel("contents",tableOutput("contents")),
        tabPanel("Dendogram",plotOutput("h_clust")),  
        tabPanel("Heat Map",downloadButton("down","Download the plot"),plotOutput("heat.clus"))
        )
  )
  ) 
))