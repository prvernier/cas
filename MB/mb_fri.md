# MB05 FRI

####################################################################################################
## PRODUCTIVITY_TYPE

According to Cosco specs, codes 721-734 are NFL attributes whereas our revised specs suggest they belong in productivity_type

####################################################################################################
## NAT_NON_VEG, NON_FOR_ANTH, NON_FOR_VEG

if (!cover_type %in% "H", "M","N","S") {
    if (!is.na(cover_type) & !is.na(productivity) & !is.na(covertype)) {
What should these be? See specs
701-704=TM (treed muskeg)
711-713=TR (treed rock)

####################################################################################################
# DST Attributes

According to Cosco specs, there are no fields
