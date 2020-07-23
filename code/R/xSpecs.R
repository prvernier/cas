# Create cas_inventories.md
#rmarkdown::render("cas_inventories.rmd")
#file.remove("cas_inventories.html")

file.copy("../docs/specifications/cas_specifications.Rmd", "../docs/specifications/archive/cas_specifications.Rmd", overwrite=TRUE)
lines = readLines("../docs/specifications/cas_specifications.Rmd")

# Create cas_specifications.md
fo = file("../docs/specifications/cas_specifications.Rmd", "w")
cat('---
title: "CASFRI Specifications"
output: github_document
---\n', file=fo)
i = 1
for (line in lines) {
    if (i > 8) {
        cat(line, "\n", file=fo)
    }
    i = i + 1
}
close(fo)
rmarkdown::render("../docs/specifications/cas_specifications.rmd")

# Restore original cas_specifications.Rmd
fo = file("../docs/specifications/cas_specifications.Rmd", "w")
for (line in lines) {
    cat(line, "\n", file=fo)
}
close(fo)

# Create cas_specifications.html
rmarkdown::render("../docs/specifications/cas_specifications.rmd")
