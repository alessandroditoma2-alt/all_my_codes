# Stata-code-for-my-master-thesis
*****vedo il contenuto del file*********
browse
****describe dataset*********************
des
***quanti sono i pw in questo dataset?*********
tab lav_platform
*** i pw sono 714, cioè lo 0.78% del campione****
*** freq per anno di riferimento *********
tab year
**** 45000 (49.30%) nel 2018, 46280 (50.70%) nel 2021******
///
***tabella 1 statistiche descrittive*****
tabstat age_18_24 age_25_29 age_30_39 age_40_49 age_50_64 age_65_74
sex figli_under13 studio log_netto_mensile comune_over250 homeown
indeterminato licenza_elementare licenza_media diploma_superiori
laurea rikert_general se_figli_futuro se_nato_in_italia
family_income1001_1500€ family_income1501_2000€
family_income2001_3000€ family_income3001_5000€
family_income_oltre_5000€ pessima_salute, by (lav_platform)stats (mean
sd) col (stat) format (%9.3f)
*********metodo 2*************
asdoc summarize age_18_24 age_25_29 age_30_39 age_40_49 age_50_64
age_65_74 meno_di_1000€ family_income1001_1500€
family_income1501_2000€ family_income2001_3000€
family_income3001_5000€ family_income_oltre_5000€ licenza_elementare
licenza_media diploma_superiori laurea comune_over250 figli_under13
homeown rikert_general se_figli_futuro se_nato_in_italia sex if
lav_platform == 1,  dec(2) stat(N mean sd) title(Platform Workers)
save(tabellal8.doc)

asdoc summarize age_18_24 age_25_29 age_30_39 age_40_49 age_50_64
age_65_74 meno_di_1000€ family_income1001_1500€
family_income1501_2000€ family_income2001_3000€
family_income3001_5000€ family_income_oltre_5000€ licenza_elementare
licenza_media diploma_superiori laurea comune_over250 figli_under13
homeown rikert_general se_figli_futuro se_nato_in_italia sex if
lav_platform == 0, append dec(2) stat(N mean sd) title(Non-Platform
Workers)

/// fig.1
****** graph bar age lav_platform
graph hbar age_18_24 age_25_29 age_30_39 age_40_49 age_50_64 age_65_74
[pweight=peso], over (lav_platform) ///
blabel(bar, format(%9.2f))
graph export agetotpesi.png, replace
*********
/// Fig.2
***** reddito lordo medio mensile delle famiglie tra pw e non pw*****
graph hbar (mean) meno_di_1000€ family_income1001_1500€
family_income1501_2000€ family_income2001_3000€
family_income3001_5000€ family_income_oltre_5000€, over(lav_platform)
///
blabel(bar, format(%9.2f)) ///
bar(1, color(blue)) bar(2, color(red)) ///
ytitle("Percentuale")
***********
/// Fig.3
***hbar titolo di studio dei pw******
graph hbar (mean) studio, over(cat_pw, sort(1)) title("Titolo di
studio dei lavoratori delle piattaforme") note ("Authors elaboration
on Plus data")
****hbar titolo di studio pw e non******
graph hbar (percent), over(studio, label(angle(0))) over(lav_platform) ///
asyvars blabel(bar, format(%9.1f)) percentages ///
bar(1, color(blue)) bar(2, color(red)) ///
ytitle("Percent")

*****
/// fig. 4
**** mappa regioni ***
collapse(mean) lav_platform [pw=peso], by(regione)
gen stid=regione
gen platperc = lav_platform * 100
label var platperc "% di lavoratori delle piattaforme"

spmap platperc using "reg-coord.dta", id(stid) clnumber(6)
clmethod(quantile) fcolor(Reds2) ocolor(white ..) ndfcolor(gs8)
osize(thin ..) legend(position(6)) legtitle("% lavoratori delle
piattaforme") saving(mapregion, replace)

spmap platperc_nazionale using "reg-coord.dta", id(stid) clnumber(6)
clmethod(quantile) ///
fcolor(Reds2) ocolor(white) osize(medium) ///
ndfcolor(gs12) ///
legend(position(3) size(small)) ///
legtitle("% lavoratori piattaforma sul totale nazionale") ///
title("Distribuzione % dei lavoratori di piattaforma per regione") ///
saving(mapregion, replace)


****graph bar e tab regione di residenz workers******
tabulate regione lav_platform, column
*****
/// fig. 5
****hbar pw e tw se hanno posticipato trattamento medico
graph hbar (percent), over(cure_post, label(angle(0))) over(lav_platform) ///
asyvars blabel(bar, format(%9.1f)) percentages ///
graphregion(color(white))

******
/// Fig. 6
**** bar var sex
graph hbar (percent) [pweight=peso], over(sex, label(angle(0)))
over(lav_platform) ///
asyvars blabel(bar, format(%9.1f)) percentages ///
graphregion(color(white))
graph export sextot_pesi.png, replace

*****
/// fig. 7
***grafico hbar per vedere la distribuzione dei pw*****
graph hbar (percent), over(cat_pw) ///
asyvars blabel(bar, format(%9.1f)) ///
graphregion(color(white)) ///
ytitle("Tipi di lavoro")

/// Fig. 8
*** stat des che indica il reddito dei pw*********
graph hbar income, over(cat_pw, sort(1)) ///
blabel(bar, format(%9.1f))

****pandemia******

///fig. 9 e fig. 10 (age)
///2018
graph hbar (mean) age_18_24 age_25_29 age_30_39 age_40_49 age_50_64
age_65_74 if year==2018, over(lav_platform) ///
blabel(bar, format(%9.2f) position(outside) color(black)) ///
ytitle("Percentuale") ///
ylabel(, format(%9.1f)) ///
legend(size(medium))


/// 2021
graph hbar (mean) age_18_24 age_25_29 age_30_39 age_40_49 age_50_64
age_65_74 if year==2021, over(lav_platform) ///
blabel(bar, format(%9.2f) position(outside) color(black)) ///
ytitle("Percentuale") ///
ylabel(, format(%9.1f)) ///
legend(size(medium))

graph hbar (mean) age_18_24 age_25_29 age_30_39 age_40_49 age_50_64
age_65_74 [pweight=peso], over(lav_platform) over(year) ///
blabel(bar, format(%9.2f) position(outside) color(black)) ///
ytitle("Percentuale") ///
ylabel(, format(%9.1f)) ///
legend(size(medium))

*****
/// Fig. 11 e 12 (income)
///2018
graph hbar (mean) meno_di_1000€ family_income1001_1500€
family_income1501_2000€ family_income2001_3000€
family_income3001_5000€ family_income_oltre_5000€ [pweight=peso],
over(lav_platform) over (year) ///
blabel(bar, format(%9.2f)) ///
bar(1, color(blue)) bar(2, color(red)) ///
ytitle("Percentuale")
/// 2021
graph hbar (mean) meno_di_1000€ family_income1001_1500€
family_income1501_2000€ family_income2001_3000€
family_income3001_5000€ family_income_oltre_5000€ if year==2021,
over(lav_platform) ///
blabel(bar, format(%9.3f)) ///
bar(1, color(blue)) bar(2, color(red)) ///
ytitle("Percentuale")
*******
/// Fig. 13 (tit studio)
**** over year*****
graph hbar (percent) [pweight=peso], over(studio, label(angle(0)))
over(lav_platform) over (year) ///
asyvars blabel(bar, format(%9.1f)) percentages ///
bar(1, color(blue)) bar(2, color(red)) ///
ytitle("Percentuale")
*********
/// Fig. 14 (cure_post)
graph hbar (percent) [pweight=peso], over(cure_post, label(angle(0)))
over(lav_platform) over (year) ///
asyvars blabel(bar, format(%9.1f)) percentages ///
graphregion(color(white))
*******
/// Fig. 15 (sex)
graph hbar (percent) [pweight=peso], over(sex, label(angle(0)))
over(lav_platform) over (year) ///
asyvars blabel(bar, format(%9.1f)) percentages ///
graphregion(color(white))
*****
/// (cat_pw) over year
/// Fig. 16
graph hbar (percent) [pweight=peso], over(cat_pw) over(year) ///
blabel(bar, format(%9.2f))

graph hbar (percent) [pweight=peso] if year==2018 , over (cat_pw) ///
blabel(bar, format(%9.2f))

graph hbar (percent) [pweight=peso] if year==2021 , over (cat_pw) ///
blabel(bar, format(%9.2f))


******export graph to word
graph export media_età.emf, replace
graph export Mean_Monthly_Family.emf, replace
graph export studioaw.emf, replace
graph export regionr.emf, replace
graph export work_pw.emf, replace
graph export rma_pw.emf, replace
graph export med.emf, replace
graph export bar_rikert.emf, replace
graph export regions.emf, replace
graph export rpw2018.emf, replace
graph export rpw2021.emf, replace
graph export incomepwnpw2018.emf, replace
graph export incomepwnpw2021.emf, replace
graph export tratt_medico2018.emf, replace
graph export tratt_medico2021.emf, replace
graph export media_età18.emf, replace
graph export media_età21.emf, replace
graph export titstudio1821.emf, replace
graph export trattmed1821.emf, replace
graph export sex.emf, replace
graph export categoriepw.emf, replace
graph export cat_pw1821.emf, replace
graph export redmed1821.emf, replace
graph export reddito18.emf, replace
graph export reddito21.emf, replace
graph export sex1821.emf, replace
graph export mapregion.emf, replace
graph export redditolav.emf, replace
graph export age_pres.emf, replace
graph export studio1821_pesi.png, replace
graph export incomepres.png, replace
graph export ptest_results.emf, replace
graph export margini_predittivi.emf, replace
graph export sex_pesi.png, replace
graph export age_pesi.png, replace
graph export income_pesi.png, replace
graph export cure_post__pesi.png, replace
graph export categoriepw.png, replace
graph export mapregion.png, replace

******
/// Tabella 2 probabilità di essere un lavoratore delle piattaforme digitali
*** no family income***
probit lav_platform ib6.age_classi i.sex i.monoreddito i.homeown
i.pessima_salute i.se_nato_in_italia i.laureato ib3.empl_condition
[pweight=peso], robust
margins, dydx(*) post
outreg2 using tab2.doc, replace word

*** family income***
probit lav_platform ib6.age_classi i.sex i.monoreddito i.homeown
i.pessima_salute i.se_nato_in_italia i.laureato ib3.empl_condition
ib6.fasce_reddito_fam [pweight=peso], robust
margins, dydx(*) post
outreg2 using tab2b.doc, replace word
******
/// Tabella 3 OUTCOME DI INSICUREZZA ECONOMICA
/// prima colonna
*** no family income***
probit cure_post lav_platform i.Covid ib6.age_classi i.monoreddito
i.se_nato_in_italia i.pessima_salute i.homeown i.sex i.laureato
ib3.empl_condition
margins, dydx(*) post
outreg2 using taba3.doc, replace word
/// seconda colonna
*** family income***
probit cure_post lav_platform i.Covid ib6.age_classi  i.monoreddito
i.se_nato_in_italia i.pessima_salute i.homeown i.sex i.laureato
ib3.empl_condition i.fasce_reddito_fam
margins, dydx(*) post
outreg2 using tab3bb.doc, replace word
/// terza colonna
probit cure_post i.lav_platform i.lavplatformxcovid i.Covid
ib6.age_classi i.monoreddito i.se_nato_in_italia i.pessima_salute
i.homeown i.sex i.laureato ib3.empl_condition
margins, dydx(*) post
outreg2 using interazionefl.doc, replace word
/// quarta colonna
probit cure_post i.lav_platform i.lavplatformxcovid i.Covid
ib6.age_classi  i.monoreddito i.se_nato_in_italia i.pessima_salute
i.homeown i.sex i.laureato ib3.empl_condition i.fasce_reddito_fam
margins, dydx(*) post
outreg2 using interazionepop.doc, replace word

* PROPENSITY SCORE MATCHING e ATET

probit lav_platform sex empl_condition studio comune_over250 age_18_24
age_25_29 age_30_39 age_40_49 age_50_64
predict pd, pr

psmatch2 lav_platform, pscore(pd) neighbor(1) ate

tab lav_platform if _weight != .

pstest sex empl_condition studio comune_over250 age_18_24 age_25_29
age_30_39 age_40_49 age_50_64, treat(lav_platform) graph
saving(pstest_results, replace)


teffects psmatch (cure_post) (lav_platform sex empl_condition studio
comune_over250 age_18_24 age_25_29 age_30_39 age_40_49 age_50_64),
atet
