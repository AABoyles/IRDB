# prep.R
#  An R Script containing Helper functions, but no actual Data Manipulation

COWStatesDates <- data.frame()
CSPPolity <- data.frame()
VanhanenPolyarchy <- data.frame()
MIRPS <- data.frame()
Archigos <- data.frame()
CSPCIOData <- data.frame()
COWInterstate <- data.frame()
COWMIDDyads <- data.frame()
COWMIDLocations <- data.frame()
COWIntrastate <- data.frame()
CSPCoups <- data.frame()
CSPViolence <- data.frame()
COWExtrastate <- data.frame()
COWNonstate <- data.frame()
CSPTerrorism <- data.frame()
CSPFDP <- data.frame()
COWNMC <- data.frame()
ICB    <- data.frame()

downloadCSV <- function(filename, url){
  incoming <- data.frame()
  if(file.exists(filename)){
    incoming <- read.csv(filename)
  } else {
    extension <- last(url, 3)
    if(extension == "csv"){
      incoming <- read.csv(url)
    } else if (extension == "xls"){
      getPackage("gdata")
      incoming <- read.xls(url)
    } else if (extension == "dta"){
      getPackage("foreign")
      incoming <- read.dta(url)
    } else {
      print("Unknown File Extension")
      return(FALSE)
    }
    write.csv(incoming, filename, row.names=FALSE)
  }
  return(incoming)
}

last <- function(x, n){
  return(substr(x, nchar(x)-n+1, nchar(x)))
}

getPackage <- function(pkg){
  if(!require(pkg, character.only=TRUE)){
    install.packages(pkg)
    library(pkg, character.only=TRUE)
  }
  return(TRUE)
}
