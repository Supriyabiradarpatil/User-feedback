library(shiny)
library(vroom)
library(janitor)
library(stringi)
# Define UI components
ui_upload <- sidebarLayout(
  sidebarPanel(
    fileInput("file", "Data", buttonLabel = "Upload..."),
    textInput("delim", "Delimiter (leave blank to guess)", ""),
    numericInput("skip", "Rows to skip", 0, min = 0),
    numericInput("rows", "Rows to preview", 10, min = 1)
  ),
  mainPanel(
    h3("Raw Data"),
    tableOutput("preview1")
  )
)

ui_clean <- sidebarLayout(
  sidebarPanel(
    checkboxInput("snake", "Rename columns to snake case?"),
    checkboxInput("constant", "Remove constant columns?"),
    checkboxInput("empty", "Remove empty cols?")
  ),
  mainPanel(
    h3("Cleaner Data"),
    tableOutput("preview2")
  )
)

ui_download <- fluidRow(
  column(width = 12, downloadButton("download", "Download Cleaned Data", class = "btn-block"))
)

# Main UI
ui <- fluidPage(
  ui_upload,
  ui_clean,
  ui_download
)

server <- function(input, output, session) {
  # Upload and read data
  raw <- reactive({
    req(input$file)
    delim <- if (input$delim == "") NULL else input$delim
    vroom::vroom(input$file$datapath, delim = delim, skip = input$skip)
  })
  
  output$preview1 <- renderTable({
    head(raw(), input$rows)
  })
  
  # Clean data
  tidied <- reactive({
    out <- raw()
    if (input$snake) {
      names(out) <- janitor::make_clean_names(names(out))
    }
    if (input$empty) {
      out <- janitor::remove_empty(out, "cols")
    }
    if (input$constant) {
      out <- janitor::remove_constant(out)
    }
    out
  })
  
  output$preview2 <- renderTable({
    head(tidied(), input$rows)
  })
  
  # Download cleaned data
  output$download <- downloadHandler(
    filename = function() {
      paste0(tools::file_path_sans_ext(input$file$name), "_cleaned.tsv")
    },
    content = function(file) {
      vroom::vroom_write(tidied(), file)
    }
  )
}

shinyApp(ui, server)
