library("shiny")
library("shinyBS")
# pageWithSidebar
shinyUI(pageWithSidebar(
	headerPanel("VennGen"),
    	sidebarPanel(
		tags$head(
			tags$style(type="text/css",	"label.radio { display: inline-block; margin-left: 1em},width=80%")
			#tags$style(type="text/css",'#leftPanel { width:50%; float:left;}')
			),
		fileInput('file1', 'Choose CSV File',
					accept=c('text/csv', 'text/comma-separated-values,text/plain', '.csv', '.txt')),
		checkboxInput('header', 'Header', TRUE),
		tags$hr(),
		radioButtons('criti','Criteria:',c('P-Value'='p','FDR-Value'='FDR'),selected='FDR'),
		radioButtons('sep', 'Separator:',
					c(Comma=',',
					Semicolon=';',
					Tab='\t'),
					selected='\t'),
		radioButtons('quote', 'Quote:',
					c(None='',
					'Double Quote'='"',
					'Single Quote'="'"),
					selected=''),
	    	radioButtons('num', 'Number of Comparisons:',
	                 c("2","3","4"),selected="2"),
        
        	uiOutput("dDown1"),
    
		div(class="row-fluid",
			div(class="span5",uiOutput("dD1p")),
			div(class="span5 offset1",uiOutput("dD1f"))
			),
  
	        uiOutput("dDown2"),
        
		div(class="row-fluid",
			div(class="span5",uiOutput("dD2p")),
			div(class="span5 offset1",uiOutput("dD2f"))
			),
		conditionalPanel(
			condition = "input.num >= 3",
			uiOutput("dDown3"),
		  	div(class="row-fluid",
			#div(class="span8",uiOutput("dDown3")),
		      	div(class="span5",uiOutput("dD3p")),
		      	div(class="span5 offset1",uiOutput("dD3f"))
		  )
		),
		conditionalPanel(
			condition = "input.num == 4",
		  	uiOutput("dDown4"),
		  	div(class="row-fluid",
		      	div(class="span5",uiOutput("dD4p")),
		      	div(class="span5 offset1",uiOutput("dD4f"))
		  )
		),
		bsTooltip("file1", "Upload user input file",placement = "bottom", trigger = "hover"),
		bsTooltip("num", "Number of circles",placement = "bottom", trigger = "hover"),
		bsTooltip("quote", "How values in file looks like : with quotes or no quotes",placement = "bottom", trigger = "hover"),
		bsTooltip("sep", "How columns are seperated in a file",placement = "bottom", trigger = "hover"),
    		bsTooltip("criti", "Choose either p-value or FDR as cutoff",placement = "bottom", trigger = "hover"),
		bsTooltip("id", "The extensions in the column names (eg: _Pval,  .fdr,  -FC).",placement = "bottom", trigger = "hover")
		),
	mainPanel(
		p(h5("VennDiagram generation based upon the input fields from left menu")),
    		p(h5("Click on the numbers to see the Genes")),    
	  	p(h5("Filtered table to view and download the lists")),
		tabsetPanel(
      			tabPanel("Venn Diagram",
      				div(class="row-fluid",
				div(class="span9",plotOutput('venn',width="650px",height="450px",clickId="tryClick")),
				div(class="span3",style="overflow:scroll; height:460px",tableOutput("gtable"))
				)
			),
			tabPanel("Filtered Table",
               		conditionalPanel(
                 		condition = "input.num == 2",
                 		radioButtons('cond2', 'Condition:',
                              	c('++'="++",
                                '+-'="+-",
                                '-+'="-+",
                                'All'="all"),
                              	selected='all')
               		),
               		conditionalPanel(
                 		condition = "input.num == 3",
                 		radioButtons('cond3', 'Condition:',
                              	c('+++'="+++",
                                '++-'="++-",
                                '+-+'="+-+",
                                '-++'="-++",
                                '+--'="+--",
                                '-+-'="-+-",
                                '--+'="--+",
                                'All'="all"),
                              selected='all')
               		),
			conditionalPanel(
                 		condition = "input.num == 4",
                 		radioButtons('cond4', 'Condition:',
                              	c('++++'="++++",
                                '+++-'="+++-",
                                '++-+'="++-+",
                                '+-++'="+-++",
                                '-+++'="-+++",
                                '++--'="++--",
                                '+--+'="+--+",
                                '--++'="--++",
                                '-++-'="-++-",
                                '-+-+'="-+-+",
                                '+-+-'="+-+-",
                                '+---'="+---",
                                '-+--'="-+--",
                                '--+-'="--+-",
                                '---+'="---+",
                                'All'="all"),
                              	selected='all')
               		),
               		downloadButton('downloadData', 'Download'),
               		tags$hr(),
			#tableOutput("table"))))
	             	dataTableOutput("table")),
              		tabPanel("Help",
                      		p(h3("Common Issues")),
                       		p("Input file must be tab-delimited file with column headers"),
                       		p("First column must contain Gene-ID, followed by DE pairwise comparisions"),
                       		p(h5("Example for File Format")),
				p(strong("Gene-ID Samplename1_vs_Samplename2.FDR Samplename1_vs_Samplename2.p Samplename1_vs_Samplename2.FC so on")))
                        	                      
      ))
    ))
