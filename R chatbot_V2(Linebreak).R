library(httr)

# Directly define the API key (paste your API key here)
api_key <- ""

# Initialize the conversation history (empty at first)
conversation_history <- list(
  list(role = "system", content = "Respond like Tony Stark to the user.")
)

# Function to add line breaks every 20 words
add_line_breaks <- function(text, word_limit = 20) {
  words <- strsplit(text, " ")[[1]]
  chunks <- split(words, ceiling(seq_along(words) / word_limit))
  formatted_text <- sapply(chunks, function(chunk) paste(chunk, collapse = " "))
  return(paste(formatted_text, collapse = "\n"))
}

# Function to send message to OpenAI API and get response
get_openai_response <- function(conversation_history) {
  payload <- list(
    model = "gpt-4",  # GPT-4 model
    messages = conversation_history,
    temperature = 0.7,  # Moderately creative
    max_tokens = 150,   # Reduced tokens
    top_p = 1,
    frequency_penalty = 0,
    presence_penalty = 0
  )
  
  # API call
  response <- POST(
    url = "https://api.openai.com/v1/chat/completions",
    add_headers(Authorization = paste("Bearer", api_key)),
    content_type_json(),
    encode = "json",
    body = payload
  )
  
  if (status_code(response) == 200) {
    result <- content(response)
    return(result$choices[[1]]$message$content)
  } else {
    cat("Error: ", status_code(response), "\n")
    return(NULL)
  }
}

# Continuous conversation loop
while (TRUE) {
  # Get user input from R console
  user_message <- readline(prompt = "You: ")
  
  # If user types 'exit', break the loop
  if (tolower(user_message) == "exit") {
    cat("Ending the conversation...\n")
    break
  }
  
  # Add user message to conversation history
  conversation_history <- append(conversation_history, list(list(role = "user", content = user_message)))
  
  # Get OpenAI's response
  response <- get_openai_response(conversation_history)
  
  if (!is.null(response)) {
    # Format response with line breaks every 20 words
    formatted_response <- add_line_breaks(response)
    
    # Add OpenAI's response to conversation history
    conversation_history <- append(conversation_history, list(list(role = "assistant", content = formatted_response)))
    
    # Print the assistant's response with line breaks
    cat("Tony Stark (Assistant): \n", formatted_response, "\n")
  }
}
