# ===== Output inventory info for layer 1 =====
# LAYER 1 has LAYER RANK 1 and attributes defined by the various L1 fields L1S1 L1PR1, L1HT, etc.
# LAYER 2 has LAYER RANK 2 and attributes defined by the various L2 fields L2S1 L2PR1, L2HT, etc.
$NUMBER_OF_LAYERS = 1;
$StandStructureCode = "S";
if ($Forested != 0) { 
	# Only these should be forested stands
	if ($Canopy >=1) {  #L1VS >= 1
		if ($UCanopy ==0 || isempty($UCanopy)) {  
			#  (L2VS ==0 !! is.null(L2VS)) {
 			$NUMBER_OF_LAYERS = 1;
			$StandStructureCode = "S";
		} else { 
			#L2Vs > 0
 			$NUMBER_OF_LAYERS = 2;
 			if ($Canopy >1 && $UCanopy >1) { 
				#(L1VS > 1 && L2VS > 1)
   				$StandStructureCode = "C";  
			} else {
  				$StandStructureCode = "M"; 
			}
		}
	} elsif($UCanopy == 0 || isempty($UCanopy)) { # L1VS == 0 or NULL && L2VS == 0 or NULL
		if (!isempty($Sp1)) { #(L1S1 != NULL)
			if (!isempty($USp1)) { #(L2S1 != NULL) # We have two layers anyway.
   				$NUMBER_OF_LAYERS =2;
   				$StandStructureCode = "M";
 			} else {
   				$NUMBER_OF_LAYERS =  1;
   				$StandStructureCode = "S";
 			}
		} else {
			$NUMBER_OF_LAYERS =1;
			$particular=1;
			$StandStructureCode = "S";
			#LAYER 1 has LAYER RANK 1, but origin, height, density and species composition are "Missing"
			#If there is no .DST record, create one with type and other attributes coded Missing
		}
	} else {
		$keys="l1VS==0 and L2VS !=0"."#".$Canopy."#".$UCanopy;
		$herror{$keys}++;
	}
}
