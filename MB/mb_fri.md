# MB05 FRI
# PV 2020-09-13

To do:
  * Test the translation tables with SQL workflow script
    - CAS attributes - passed
    - Other attributes fail because of "layer" issue
  * Add note to issue #424 about productivity:
    - PRODUCTIVE FOREST = "H","M","N","S"
    - NON_PRODUCTIVE_FOREST = "NonPro"
    - Perl: if (!cover_type %in% "H", "M","N","S") {
                if (!is.na(cover_type) & !is.na(productivity) & !is.na(covertype)) {
  * Add note to issue #423 about productivity_type:
    - 701-704=TM (treed muskeg) - added to productivity_type
    - 711-713=TR (treed rock) - added to productivity_type
    - 721-734 classified as NFL attributes (Cosco specs); revised specs suggest productivity_type
  * Add note to issue #423 about DST attributes
    - According to Cosco specs, there are no source fields for DST attributes
