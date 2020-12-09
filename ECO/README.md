NLI01 2020-12-08



PEI01 2020-12-07

  - Cosco specs do not apply to PE01 but Perl code mostly does
  - Perl code uses landtype "SW" which does not exist; is this supposed to be 'WW' water?
    * or is 'SW' from the org_hist attribute i.e., swamp
    * however, this would add a lot of polygons with species, height, and crown information
    * there is no overlap between SW from org_hist and BO, SO from landtype
    * leave as is for now but flag for future discussion
  - Perl code uses value "X" for fourth letter, which is not a valid entry
    * change to '-' but flag for confirmation
