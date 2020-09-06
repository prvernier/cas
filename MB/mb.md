# MB05 FRI

## PRODUCTIVITY

"notNull(cover_type);matchList(cover_type,{'S','M','N','H','NonPro'}|NOT_APPLICABLE)","mapText(cover_type,{'S','M','N','H','NonPro'}, {'PRODUCTIVE_FOREST','PRODUCTIVE_FOREST','PRODUCTIVE_FOREST','PRODUCTIVE_FOREST','NON_PRODUCTIVE_FOREST'})"

## PRODUCTIVITY_TYPE

According to Cosco specs, codes 721-734 are NFL attributes whereas our revised specs suggest they belong in productivity_type

"notNull(productivity);matchList(productivity,{'701','702','703','704','711','712','713'}|NOT_APPLICABLE)","mapText(productivity,{'701','702','703','704','711','712','713'}, {'TREED_MUSKEG','TREED_MUSKEG','TREED_MUSKEG','TREED_MUSKEG','TREED_ROCK','TREED_ROCK','TREED_ROCK'})"
