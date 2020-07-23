for fri in ["fri", "fli"]:
    f0 = open("mb_" + fri + "01.csv", "r")
    f1 = open("tables/mb_" + fri + "01_cas.csv", "w")
    f2 = open("tables/mb_" + fri + "01_lyr.csv", "w")
    f3 = open("tables/mb_" + fri + "01_nfl.csv", "w")
    f4 = open("tables/mb_" + fri + "01_dst.csv", "w")
    f5 = open("tables/mb_" + fri + "01_eco.csv", "w")
    f6 = open("tables/mb_" + fri + "01_geo.csv", "w")
    i = 0
    for row in f0:
        if i in range(1,12):
            f1.write(row)
        elif i in range(14,50):
            f2.write(row)
        elif i in range(52,66):
            f3.write(row)
        elif i in range(68,84):
            f4.write(row)
        elif i in range(86,94):
            f5.write(row)
        elif i in range(96,99):
            f6.write(row)
        i = i + 1
    f0.close()
    f1.close()
    f2.close()
    f3.close()
    f4.close()
    f5.close()
    f6.close()
