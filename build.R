# build.R
#  A Builder File for the PoliScIR Relational Database
#  ------------------------------------------------------------------------

# Init
#  Since R doesn't really do Self-executing functions 
#  or globally-accessible Closures, We'll just put these
#  here so they'll run when you reload the file.
source("prep.R")

build <- function(){
  getFiles()
  buildTables()
  return(TRUE)
}

getFiles <- function(){
  # Make a directory for the original, unmodified data
  if(!file.exists("OriginalDatasets")){
    dir.create("OriginalDatasets", showWarnings = FALSE)
  }
  setwd("OriginalDatasets")
  
  #Part 1: State Identifiers
  COWStatesDates <- downloadCSV("states2011.csv", "http://www.correlatesofwar.org/COW2%20Data/SystemMembership/2011/states2011.csv")
  #TODO: Yemen Breaking table parsing, needs fine-tuning
  #GleidtschStates <- downloadCSV("iisystem.csv", "http://privatewww.essex.ac.uk/~ksg/data/iisystem.dat")
  #GleidtschMicrostates <- downloadCSV("microstates.csv", "http://privatewww.essex.ac.uk/~ksg/data/microstatessystem.dat")
  
  #Part 2: Regime Data
  CSPPolity <- downloadCSV("p4v2011.csv", "http://www.systemicpeace.org/inscr/p4v2011.xls")
  VanhanenPolyarchy <- downloadCSV("polyarchy_v2.csv", "http://www.prio.no/Global/upload/CSCW/Data/Governance/file42531_polyarchy_v2.xls")
  MIRPS <- downloadCSV("mirps_annualized.csv", "http://www.prio.no/Global/upload/CSCW/Data/Governance/mirps_annualized.dta")
  #TODO: State Fragility Index is broken, needs to be fixed manually
  #StateFragility <- downloadCSV("SFIv2011a.csv", "http://www.systemicpeace.org/inscr/SFIv2011a.xls")
  
  Archigos  <- downloadCSV("Archigos_2.9-Public.csv", "http://www.rochester.edu/college/faculty/hgoemans/Archigos_2.9-Public.dta")
  CSPCIOData<- downloadCSV("CIOdata.csv", "http://www.systemicpeace.org/inscr/CIOdata.xls")
  
  #Part 3: War Data
  # a. Interstate Conflicts and Disputes
  COWInterstate   <- downloadCSV("Inter-StateWarData_v4.0.csv", "http://www.correlatesofwar.org/COW2%20Data/WarData_NEW/Inter-StateWarData_v4.0.csv")
  COWMIDDyads     <- downloadCSV("MIDDyadic_v3.10.csv", "http://www.correlatesofwar.org/COW2%20Data/MIDs/MIDDyadic_v3.10.csv")
  COWMIDLocations <- downloadCSV("MIDLOC_1.1.csv", "http://www.correlatesofwar.org/COW2%20Data/MIDLOC/MIDLOC_1.1.csv")
  
  # b. Intrastate Conflicts and Civil Wars
  COWIntrastate<- downloadCSV("Intra-StateWarData_v4.1.csv", "http://www.correlatesofwar.org/COW2%20Data/WarData_NEW/Intra-StateWarData_v4.1.csv")
  CSPCoups     <- downloadCSV("CSPCoupsList2011.csv", "http://www.systemicpeace.org/inscr/CSPCoupsList2011.xls")
  
  # c. Mixed/Other
  CSPViolence  <- downloadCSV("MEPV2008.csv", "http://www.systemicpeace.org/inscr/MEPV2008.xls")
  COWExtrastate<- downloadCSV("Extra-StateWarData_v4.0.csv", "http://www.correlatesofwar.org/COW2%20Data/WarData_NEW/Extra-StateWarData_v4.0.csv")
  COWNonstate  <- downloadCSV("Non-StateWarData_v4.0.csv", "http://www.correlatesofwar.org/COW2%20Data/WarData_NEW/Non-StateWarData_v4.0.csv")
  CSPTerrorism <- downloadCSV("HCTBMar2012.csv", "http://www.systemicpeace.org/inscr/HCTBMar2012.xls")
  CSPFDP       <- downloadCSV("FDP2008a.csv", "http://www.systemicpeace.org/inscr/FDP2008a.xls")
  
  #Part 4: Economic Data
  COWNMC <- downloadCSV("NMC_v4_0.csv", "http://www.correlatesofwar.org/COW2%20Data/Capabilities/NMC_v4_0.csv")

  setwd("..")

  return(TRUE)
}

buildTables <- function(){
  if(!file.exists("Tables")){
    dir.create("Tables", showWarnings = FALSE)
  }
  setwd("Tables")

  buildIDs()
  buildRegimes()
  
  setwd("..")
  return(TRUE)
}

buildIDs <- function(){
  if(exists("COWStatesDates")){
    COWStates <- unique(subset(COWStatesDates, select=c('stateabb', 'ccode', 'statenme')))
    write.csv(COWStates, "COWIDs.csv", row.names=FALSE)
    return(TRUE)
  } else {
    return(FALSE)
  }
}

buildRegimes <- function(){
  if(exists("CSPPolity") && exists("VanhanenPolyarchy") && exists("MIRPS")){
    
    CSPPolity <- unique(subset(CSPPolity, select=c("cyear", "flag", "fragment", "democ", "autoc", "polity", "polity2", "durable", "xrreg", "xrcomp", "xropen", "xconst", "parreg", "parcomp", "exrec", "exconst", "polcomp", "prior", "emonth", "eday", "eyear", "eprec", "interim", "bmonth", "bday", "byear", "bprec", "post", "change", "d4", "sf", "regtrans")))
    CSPPolity <- arrange(CSPPolity,cyear)
    
    VanhanenPolyarchy['cyear'] <- paste(VanhanenPolyarchy$SSno, VanhanenPolyarchy$Year, sep="")
    VanhanenPolyarchy <- unique(subset(VanhanenPolyarchy, select=c('cyear','Comp', 'Part', 'ID')))
    VanhanenPolyarchy <- arrange(VanhanenPolyarchy,cyear)
    
    merge <- merge(CSPPolity, VanhanenPolyarchy, all=TRUE)

    #TODO: Figure out how to make a cyear in the MIRPS data, and merge it in
    #MIRPS['cyear'] <- paste(MIRPS$c, MIRPS$year, sep="")
    #merge <- merge(merge, MIRPS, all=TRUE)
    
    write.csv(merge, "regimes.csv", row.names=FALSE)
    return(TRUE)
  } else {
    return(FALSE)
  }
}
