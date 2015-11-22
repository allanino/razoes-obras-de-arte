# Function to download database
download_data <- function(){
  URL <- "http://www.wga.hu/database/download/data_xls.zip"
  download.file(URL, "data.zip")
  unzip('data.zip')
}

# Functions to extract dimenstions from 'TECHNIQUES' column,
# which may be like "Oil on copper, 56 x 47 cm"
get_width <- function(s) {
  split <- unlist(strsplit(s, " "))
  x_index <- match("x", split)
  number <- sub(",", ".", split[x_index-1])
  return(as.numeric(number))
}

get_height<- function(s) {
  split <- unlist(strsplit(s, " "))
  x_index <- match("x", split)
  number <- sub(",", ".", split[x_index+1])
  return(as.numeric(number))
}

# Function to get the paiting dimensions scale
# We don't care too much because we are interested
# in the dimensions ration, but here it is anyway
get_scale <- function(s) {
  split <- unlist(strsplit(s, " "))
  x_index <- match("x", split)
  return(split[x_index+2])
}

# Function to compute data summmary with relevant columns
compute_summary <- function(artist) {
  library(gdata)
  # Read .xls file
  df = read.xls ("catalog.xls", sheet = 1, header = TRUE, stringsAsFactors=FALSE)

  # Take a look at the data columns
  print(names(df))
  
  # We're interested in the TECHNIQUE column, but we need some 
  # way to extract the dimensions info from that
  df[1, 'TECHNIQUE']
  
  # Filter Rembrandt only data
  if(artist == "all"){
    d <- df
  } else {
    d <- df[df[,1] == artist,]
  }
  
  # Let's extract the info we want
  d['WIDTH'] <- apply(d['TECHNIQUE'], MARGIN=1, FUN=get_width)
  d['HEIGHT'] <- apply(d['TECHNIQUE'], MARGIN=1, FUN=get_height)
  d['SCALE'] <- apply(d['TECHNIQUE'], MARGIN=1, FUN=get_scale)
  
  # Let's purge NA's, as some paintings doesn't has dimensions info
  d <- d[!(is.na(d[,'WIDTH'])|is.na(d[,'HEIGHT'])|is.na(d[,'SCALE'])), ]
  
  # We assumed that the first dimension is WIDHT, but that doesn't
  # always is the case. Let's consider the ratio between the greater
  # dimension and the lowest one
  greater_w <- d['WIDTH'] > d['HEIGHT']
  
  # Let's call these DIM1 and DIM2 to avoid confusion
  d[!greater_w, 'ORIENTATION'] <- "Paisagem"
  d[greater_w, 'ORIENTATION'] <- "Retrato"
  d[greater_w, 'DIM_1'] <- d[greater_w,'WIDTH']
  d[greater_w, 'DIM_2'] <- d[greater_w,'HEIGHT']
  d[!greater_w, 'DIM_2'] <- d[!greater_w,'WIDTH']
  d[!greater_w, 'DIM_1'] <- d[!greater_w,'HEIGHT']
  
  d['RATIO'] <- d[,'DIM_1']/d[,'DIM_2']
  
  mean_ratio <- mean(d$RATIO)
  
  sprintf('Width/Height ratio: %f', mean_ratio)
  
  # Summarize important data to display in table
  
  if(artist == "all"){
    # Get only relevant columns
    summary <- subset(d, TRUE, select=c(AUTHOR, TITLE, DATE, URL, ORIENTATION, DIM_1, DIM_2, SCALE, RATIO))
    # Rename columns
    colnames(summary) <- c("Artista", "Obra", "Data", "URL", "Orientação", "Dim 1", "Dim 2", "Escala", "Razão")
    # Fix encondings
    summary$Artista <- enc2utf8(summary$Artista)
  } else {
    # Get only relevant columns
    summary <- subset(d, TRUE, select=c(TITLE, DATE, URL, ORIENTATION, DIM_1, DIM_2, SCALE, RATIO))
    # Rename columns
    colnames(summary) <- c("Obra", "Data", "URL", "Orientação", "Dim 1", "Dim 2", "Escala", "Razão") 
  }

  # Fix encondings
  summary$Obra <- enc2utf8(summary$Obra)
  
  # Keep only ratios <= 4.0. Some bad formatted rows mess with this, leaving
  # ratios of up to 100 because of issues like extra espaces: 130, 5 X 150 -> (5, 150)
  return(summary[summary$Razão <= 4.0, ])
}

create_histogram <- function(summary, save = FALSE){
  # install.packages(c("ggplot2","RColorBrewer","scales"))
  library(ggplot2)
  library(RColorBrewer)
  library(scales)
  library("grid")
  
  source("fte_theme.R")
  
  mean_ratio <- mean(summary$Razão)
  
  plastic_line <- data.frame(Legenda="Número plástico = 1.3247...", vals=c(1.3247))
  gold_line <- data.frame(Legenda="Razão áurea = 1.6180...", vals=c(1.6180))
  mean_line <- data.frame(Legenda=sprintf("Média = %f", mean_ratio), vals=c(mean_ratio))
  vlines<- rbind(mean_line, plastic_line, gold_line)
  
  f <- ggplot(summary, aes(Razão)) +
    geom_histogram(binwidth=0.05) +
    xlim(1.0, 2.5) + 
    xlab("Razão") +
    ylab("Frequência") + 
    #ggtitle("Histrograma da razão entre a maior dimensão e a menor") +
    fte_theme() +
    geom_vline(data=vlines, 
               aes(xintercept=vals, 
                   linetype=Legenda,
                   colour = Legenda),
               show_guide = TRUE)
  if(save){
    ggsave("histogram.png", dpi=300, width=8, height=6)    
  }
  
  return(f)
}