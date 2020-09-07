# MB06 FLI
# PV 2020-09-07

To do:
  * Test the translation tables with SQL workflow script
    - CAS attributes - passed
    - LYR attributes - failed because PRODUCTIVITY and PRODUCTIVITY_TYPE have not been done

####################################################################################################
## STAND_STRUCTURE

"notEmpty({species_1, species_2, species_3, species_4 ,species_5}, TRUE|NOT_APPLICABLE)",copyText('S'),"Only one LYR layer possible. If species info present, stand structure is S.",VRAI

See issue #265

Note 1: Perl code indicates that there are 5 possible stand_structure layers, using CANLAY, US2CANLAY-US5CANLAY. Seems to apply to crown_closure and height.
Note 2: Why are we not using CANLAY instead of sp1, sp2 etc.?

CANLAY describes the canopy layers that occur within the polygon.

Value	Definition
S	Single layer
V	Veteran layer
C	Complex layer
M	Multi-layer
U	Understorey

####################################################################################################
## STRUCTURE_RANGE

  - Has stand structure in Canopy Layer attribute and height range in Height Range attribute
  - Based on height range when CANLAY=="C"
  - Validate only when CANLAY=="C"
  - COMHT x 2

####################################################################################################
## CROWN_CLOSURE

Use with SC0 … SC9 (see NFL attributes below)
See Cosco table

crown_closure - done except for the special case of veterans which may need a helper function:
    if canlay=='V' and crowncl==0 then crown_closure_lower = 1 and crown_closure_upper = 5
    else crown_closure_lower = 6 and crown_closure_upper = 10
    the above is not fully clear and needs to be explored further

Value	Definition
0	0 to 10% crown closure (1 to 5% in a Veteran layer)
1	11 to 20 % crown closure

Note1: 0 = 1-5 (withCanlay V) else 0 = 6-10
Note2: See Cosco note re shrub crown closure

fri = {'0','1','2','3','4','5','6','7','8','9'}
cas_u = {'10','20','30','40','50','60','70','80','90','100'}
cas_l = {'6','11','21','31','41','51','61','71','81','91'}

fri = {'0','0','1','2','3','4','5','6','7','8','9'}
cas_u = {'5','10','20','30','40','50','60','70','80','90','100'}
cas_l = {'1','6','11','21','31','41','51','61','71','81','91'}

####################################################################################################
## NAT_NON_VEG, NON_FOR_ANTH, NON_FOR_VEG

To translate NFL attributes, use LookupText() as used with species codes. Parameters:
  - species_code = NNF_ANTH
  - schema =
  - lookup_table = mb_nfl_mappings.csv
  - column = ab_species_code

NNF_ANTH - Consider using a lookup table similar to species or QC tables
NOTE: shrub crown closure is included with the shrub code, e.g. SC6 (closed shrub with 61% - 70% crown closure)
closed shrub (along with height to nearest metre and 0 to 9 crown closure) - See Cosco note re shrub crown closure

Value Definition
SO open shrub (along with 0 to 9 crown closure and height to nearest metre (in HT field) (Note - shrub layers can be distinguished from treed layers even if height difference is less than 3 m)
SC closed shrub (along with height to nearest metre and 0 to 9 crown closure)
HG grassland, prairie savannah

####################################################################################################
# DST Attributes

what about treatmod, treatext, trorig?