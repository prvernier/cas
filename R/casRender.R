# This file needs to be run once prior to rendering the markdown files
# 2019-06-14

library(rmarkdown)

casRender = function(inv) {
    if (inv=="ab06") {
        # Select attributes from ab06 and save as a tibble
        render("ab06_hdr.Rmd", output_dir="docs")
        render("ab06_cas.Rmd", output_dir="docs")
        render("ab06_lyr.Rmd", output_dir="docs")
        render("ab06_nfl.Rmd", output_dir="docs")
        render("ab06_dst.Rmd", output_dir="docs")
        render("ab06_eco.Rmd", output_dir="docs")
    } else if (inv=="ab16") {
        # Select attributes from ab16 and save as a tibble
        render("ab16_hdr.Rmd", output_dir="docs")
        render("ab16_cas.Rmd", output_dir="docs")
        render("ab16_lyr.Rmd", output_dir="docs")
        render("ab16_nfl.Rmd", output_dir="docs")
        render("ab16_dst.Rmd", output_dir="docs")
        render("ab16_eco.Rmd", output_dir="docs")
    } else if (inv=="bc08") {
        #render("bc08.Rmd")
        render("bc08_hdr.Rmd", output_dir="docs")
        render("bc08_cas.Rmd", output_dir="docs")
        render("bc08_lyr.Rmd", output_dir="docs")
        render("bc08_nfl.Rmd", output_dir="docs")
        render("bc08_dst.Rmd", output_dir="docs")
        render("bc08_eco.Rmd", output_dir="docs")
    } else if (inv=="nb01") {
        render("nb01_hdr.Rmd", output_dir="docs")
        render("nb01_cas.Rmd", output_dir="docs")
        render("nb01_lyr.Rmd", output_dir="docs")
        render("nb01_nfl.Rmd", output_dir="docs")
        render("nb01_dst.Rmd", output_dir="docs")
        render("nb01_eco.Rmd", output_dir="docs")
    } else {
        stop('There is no inventory with that name')
    }
}

renderAll = function() {
    render("index.Rmd")
    render("cas_specifications.Rmd")
    x = friConnect("ab06")
    casRender("ab06")
    x = friConnect("ab16")
    casRender("ab16")
    x = friConnect("bc08")
    casRender("bc08")
    x = friConnect("nb01")
    casRender("nb01")
}

