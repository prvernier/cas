library(tidyverse)
hdr = read_csv("C:/Users/PIVER37/Documents/casfri/CAS_04/TranslatedCASFiles/Version.00.04/TranslatedFiles/BC/BC_082E/BC_082E.hdr")
cas = read_csv("C:/Users/PIVER37/Documents/casfri/CAS_04/TranslatedCASFiles/Version.00.04/TranslatedFiles/BC/BC_082E/BC_082E.cas")
lyr = read_csv("C:/Users/PIVER37/Documents/casfri/CAS_04/TranslatedCASFiles/Version.00.04/TranslatedFiles/BC/BC_082E/BC_082E_sub.lyr")
nfl = read_csv("C:/Users/PIVER37/Documents/casfri/CAS_04/TranslatedCASFiles/Version.00.04/TranslatedFiles/BC/BC_082E/BC_082E.nfl")
dst = read_csv("C:/Users/PIVER37/Documents/casfri/CAS_04/TranslatedCASFiles/Version.00.04/TranslatedFiles/BC/BC_082E/BC_082E.dst")
eco = read_csv("C:/Users/PIVER37/Documents/casfri/CAS_04/TranslatedCASFiles/Version.00.04/TranslatedFiles/BC/BC_082E/BC_082E.eco")

x = read_delim("C:/Users/PIVER37/Documents/casfri/CAS_04/ExportedSourceFiles/Version.00.04/ExportedFiles/BC/GOV/csv/BC_082E.csv", delim=";")
