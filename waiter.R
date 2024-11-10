library(shiny)
library(shinyFeedback)
library(waiter)


ui <- fluidPage(
  waiter::use_waitress(),
  numericInput("steps", "How many steps?", 10),
  actionButton("go", "go"),
  textOutput("result")
)


server <- function(input, output, session) {
  data <- eventReactive(input$go, {
    # Create a new progress bar
    waitress <- waiter::Waitress$new(max = input$steps)
    on.exit(waitress$close())
    
    # Increment the progress bar for each step
    for (i in seq_len(input$steps)) {
      Sys.sleep(0.5)# simulate a time-consuming process
      waitress$inc(1)
    }
    
    runif(1)# return a random number
  })
  
  output$result <- renderText(round(data(), 2))
}
shinyApp(ui, server)