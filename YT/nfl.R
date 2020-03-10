if($TypeLND eq "NW" || $TypeLND eq "NS" || $TypeLND eq "NE"  ||  (isempty($TypeLND) &&  (!isempty($auxCLASS) || !isempty($CLMOD))))  {
     $NatNonVeg = NaturallyNonVeg($auxCLASS, $CLMOD, 0);
     if($NatNonVeg  eq ERRCODE)               { 
        $NonForVeg = NonForestedVeg($auxCLASS, $CLMOD);
     }
     if($row->{TYPE_FOR} eq "A" || $TypeLND eq "NS")             {
        $NatNonVeg="AP"; # changeb by BK on 04042013; $UnprodFor="AP";
     }
}

if($TypeLND eq "NU" ||  (isempty($TypeLND) &&  (!isempty($auxCLASS))))         { 
    $NonForAnth = NonForestedAnth($auxCLASS);
    if($NonForAnth   =~ /-9999/)             { 
        $NatNonVeg = NaturallyNonVeg($auxCLASS, $auxCLASS, 0);
        $NonForVeg = NonForestedVeg($auxCLASS, $auxCLASS);
        if($NatNonVeg eq ERRCODE && $NonForVeg eq ERRCODE)                 {
            $keys="AnthVeg"."#".$auxCLASS."-clmod"."#".$CLMOD."-type_lnd"."#".$TypeLND."init=$NonForAnth";
        }
    }
}    

if($TypeLND eq "VN" ||  (isempty($TypeLND) &&  (!isempty($auxCLASS) || !isempty($CLMOD))))         { 
    $NonForVeg = NonForestedVeg($auxCLASS, $CLMOD);
    if($auxCLASS eq "RR") # added to avoid errcode in NFL
        $NatNonVeg = NaturallyNonVeg($auxCLASS, $CLMOD, 0);
    }
}    

if( isempty($auxCLASS) && isempty($CLMOD) && !isempty($row->{TYPE_FOR}))         {
    if($row->{TYPE_FOR} eq "NP" || $row->{TYPE_FOR} eq "KNP")            {
        $UnprodFor="NP";
    } elsif( $row->{TYPE_FOR} eq "U")             {
        $NonForAnth="SE";
    } elsif($row->{TYPE_FOR} eq "NSR")             {
        $Dist1="UK";
    } elsif($row->{TYPE_FOR} eq "A" && isempty($row->{SP1})==0)             {
        $UnprodFor="AL";$SiteClass="U";
    } elsif($row->{TYPE_FOR} eq "A" && isempty($row->{SP1}))            {
        $NatNonVeg ="AP"; # $keys="found AP#".$TypeLND;
    } else             {
        $NatNonVeg = NaturallyNonVeg($auxCLASS, $row->{TYPE_FOR}, 1);
    }      
}

sub NaturallyNonVeg {
    # Determine Naturally non-vegetated stands from CLASS and CL_MOD
    # VN=Vegetated, non forested; NW=Non vegetated water; NU=Non Vegetated, Urban/industrial; NE=Non vegetated, Exposed land; NS=Non Vegetated, Snow/Ice
    # Naturally non vegetated: Identified as a cover type (TYPE); NE (exposed land), NS (snow and Ice), NW (water). 
    # These are further identified as a cover type class (CLASS), 
    # RS – river sediments, E – exposed soil, S – sand, B – burned area, RR – bedrock or fragmented rock, O – other, R – River, L – Lake. 
    # Rock can be further identified with a cover type class modifier Ro – rock, Ru – rubble.
    # NatNonveg list AP LA RI OC RK SA SI SL EX BE WS FL IS TF
    my %NatNonVegList = ("", 1, "L", 1, "RS", 1, "E", 1, "S", 1, "B", 1, "RR", 1, "R", 1, "l", 1, "rs", 1, "e", 1, "s", 1, "b", 1, "rr", 1, "r", 1 );#"O", 1,, "o", 1
    #my %TypelndList = ("", 1, "NE", 1, "NS", 1, "NW", 1, "ne", 1, "ns", 1, "nw", 1);
    my %ClModList = ("", 1, "RO", 1, "RU", 1, "RIV", 1,"W", 1, "L", 1,"R", 1, "ro", 1, "ru", 1);
    if (defined $ClassMod ){$_ = $ClassMod; tr/a-z/A-Z/; $ClassMod = $_;}
    else {$ClassMod ="";} 
    if ($ClModList {$ClassMod} ) { } else { $ClassModRes = ERRCODE; }
    #if (isempty($ClassMod)) { $ClassModRes = MISSCODE; }
   
    if ($NatNonVegList {$NatNonVeg} ) { } else { $NatNonVegRes = ERRCODE; }
    
    if  (isempty($NatNonVeg)){ $NatNonVegRes = MISSCODE; }
    elsif (($NatNonVeg eq "l") || ($NatNonVeg eq "L"))    { $NatNonVegRes = "LA"; }
    elsif (($NatNonVeg eq "rs") || ($NatNonVeg eq "RS"))    { $NatNonVegRes = "WS"; }    
    elsif (($NatNonVeg eq "e") || ($NatNonVeg eq "E"))    { $NatNonVegRes = "EX"; }
    elsif (($NatNonVeg eq "s") || ($NatNonVeg eq "S"))    { $NatNonVegRes = "SA"; }
    elsif (($NatNonVeg eq "b") || ($NatNonVeg eq "B"))    { $NatNonVegRes = "EX"; }
    elsif (($NatNonVeg eq "rr") || ($NatNonVeg eq "RR"))    { $NatNonVegRes = "RK"; }
    #elsif (($NatNonVeg eq "h") || ($NatNonVeg eq "H"))    { $NatNonVegRes = "HE"; }
    #elsif (($NatNonVeg eq "m") || ($NatNonVeg eq "M"))    { $NatNonVegRes = "HE"; }
    elsif (($NatNonVeg eq "r") || ($NatNonVeg eq "R"))    { $NatNonVegRes = "RI"; }
    else     { $NatNonVegRes = ERRCODE; }
    
    if (isempty($ClassMod)) { $ClassModRes = MISSCODE;}    
    elsif (($ClassMod eq "ro") || ($ClassMod eq "RO"))    { $ClassModRes = "RK"; }
    elsif (($ClassMod eq "ru") || ($ClassMod eq "RU"))    { $ClassModRes = "RK"; }
    elsif (($ClassMod eq "R") && ($Typefor==1))    { $ClassModRes = "RK"; }
    elsif (($ClassMod eq "RIV") && ($Typefor==1))    { $ClassModRes = "RI"; }
    elsif (($ClassMod eq "L" || $ClassMod eq "W") && ($Typefor==1))    { $ClassModRes = "LA"; }
    else { $ClassModRes = ERRCODE; }
}

sub NonForestedAnth {
    my $NonForAnth;   my $NonForAnthRes;
    my %NonForAnthList = ("", 1, "G", 1, "T", 1, "RD", 1, "O", 1, "g", 1, "t", 1, "rd", 1, "o", 1);
    ($NonForAnth) = shift(@_);
    if ($NonForAnthList {$NonForAnth} ) { } else { $NonForAnthRes = ERRCODE; }
    if  (isempty($NonForAnth))    { $NonForAnthRes = MISSCODE; }
    elsif (($NonForAnth  eq "g") || ($NonForAnth  eq "G"))    { $NonForAnthRes = "IN"; }
    elsif (($NonForAnth  eq "t") || ($NonForAnth  eq "T"))    { $NonForAnthRes  = "IN"; }
    elsif (($NonForAnth  eq "rd") || ($NonForAnth  eq "RD"))    { $NonForAnthRes  = "FA"; }
    elsif (($NonForAnth  eq "o") || ($NonForAnth  eq "O"))    { $NonForAnthRes = "OT"; }
    else { $NonForAnthRes = ERRCODE; }
    #return $Type_lnd.",".$NonForAnth;
    return $NonForAnthRes;
}

sub NonForestedVeg {
    # Non forest vegetated: cover type = VN, cover type class = S – shrub, H – herb, C – cryptogam, M- mixed. 
    # Cover type class modifier = TS – tall shrub, TSo – tall shrub open, TSc –   tall shrub closed, LS – low shrub.
    my $NonForVeg;  my $ClassMod;my $NonForVegRes;  my $ClassModRes;
    my %NonForVegList = ("", 1, "S", 1,  "H", 1, "M", 1, "C", 1, "s", 1,  "h", 1, "m", 1, "c", 1);
    my %ClModList = ("", 1, "TS", 1, "TSO", 1, "TSC", 1, "LS", 1, "ts", 1, "tso", 1, "tsc", 1, "ls", 1);
    if (defined $ClassMod ) {$_ = $ClassMod; tr/a-z/A-Z/; $ClassMod = $_;}
    else {$ClassMod ="";} 
    if ($ClModList {$ClassMod} ) { } else { $ClassModRes = ERRCODE; }
    if ($NonForVegList {$NonForVeg} ) { } else { $NonForVegRes = ERRCODE; }
    if  (isempty($NonForVeg)) { $NonForVegRes =MISSCODE; }
    elsif (($NonForVeg eq "s") || ($NonForVeg eq "S"))    { $NonForVegRes = "ST"; }
    elsif (($NonForVeg eq "h") || ($NonForVeg eq "H"))    { $NonForVegRes = "HE"; }
    elsif (($NonForVeg eq "m") || ($NonForVeg eq "M"))    { $NonForVegRes = "HE"; }
    elsif (($NonForVeg eq "c") || ($NonForVeg eq "C"))    { $NonForVegRes = "BR"; }
    #elsif (($NonForVeg eq "r") || ($NonForVeg eq "R"))    { $NonForVeg = "RI"; }
    else { $NonForVegRes = ERRCODE; }
    if (isempty($ClassMod)) { $ClassModRes =MISSCODE;}
    elsif (($ClassMod eq "ts") || ($ClassMod eq "TS"))    { $ClassModRes = "ST"; }
    elsif (($ClassMod eq "tsc") || ($ClassMod eq "TSC"))    { $ClassModRes = "ST"; }
    elsif (($ClassMod eq "tso") || ($ClassMod eq "TSO"))    { $ClassModRes = "ST"; }
    elsif (($ClassMod eq "ls") || ($ClassMod eq "LS"))    { $ClassModRes = "SL"; }
    else { $ClassModRes = ERRCODE; }
}
