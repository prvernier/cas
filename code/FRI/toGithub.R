inventories = c("ab_0006","ab_0016","bc_0008","nb_0001")
tables = c("cas","dst","eco","hdr","lyr","nfl","species")
gitdir = "../../casfri/translation/tables/"

for (i in inventories) {
    for (j in tables) {
        if (j=="species") {
            print(paste0(gitdir,i,"_",j,".csv"))
            #file.copy(paste0(i,"/",j), paste0(gitdir,i,"_",j,".csv"))
        } else {
            print(paste0(gitdir,i,"_rules_",j,".csv"))
            #file.copy(paste0(i,"/",j), paste0(gitdir,i,"_rules_",j,".csv"))        
        }
    }
}
