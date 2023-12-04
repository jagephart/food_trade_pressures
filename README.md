# food_trade_pressures repository

insert impact statement once finalized. Esstentially, we combine data that covers the environmental pressures of food production with food trade data to provide a publicly available dataset.

The steps to generate this data output are included in this repository. The data required to generate the final output are available on Zenodo (insert link). The overarching steps are:

1. trade_data_prep
2. environmental_pressures
3. feed_proportions_data_prep
4. connect_trade_and_pressures

The details of each step and the files they contained are explained below.

## 01_trade_data_prep
Crop and licestock trade flows from producing to consuming country are based on Schwarzmueller et al. (2022) and are combined with fish data from the Aquatic Resource Trade in Species (ARTIS) database.

### [01a-format-fao-trade.Rmd](https://github.com/jagephart/food_trade_pressures/blob/main/01_trade_data_prep/01a-format-fao-trade.Rmd)
The first step taken in this process is to clean the trade and production data from the FAO so that it matches the input used in the trade matrix operation from Schwarzmueller et al. (2022).

### [01b-calc-trade-matrix-2017.Rmd](https://github.com/jagephart/food_trade_pressures/blob/main/01_trade_data_prep/01b-calc-trade-matrix-2017.Rmd)
The purpose of this script is to calculate a global trade matrix in primary product equivalents based on the country of product origin (where the primary product was grown, not where it was last processed). This [script](https://zenodo.org/record/5751294#.YrrrmXZByMo) is from [Schwarzmueller & Kastner 2022](https://link.springer.com/article/10.1007/s11625-022-01138-7#Sec2). It has been annotated so that details about the steps taken are included.

### [01c_allocate_unknown_trade_fish_consumption.Rmd](https://github.com/jagephart/food_trade_pressures/blob/main/01_trade_data_prep/01c_allocate_unknown_trade_fish_consumption.Rmd)
ARTIS is used for all trade/production data most fish products. Fish meal products have additional steps and are handled in the next processing step. 

The fish trade matrix for human consumption has a number of data points that are "unknown" in the source country, habitat, method, and nceas_group columns. Unknowns arise from the error term or cases where products move through more than 2 intermediate countries. We will proportionately bump up all marine flows with the marine-unknown volume, all inland flows with the inland-unknown, and then all aquatic food flows with the unknown-unknown. This will keep the total consumption constant without having to assume a global average for the pressure values when integrated.

### [01d_allocate_unknown_fmfo_consumption.Rmd](https://github.com/jagephart/food_trade_pressures/blob/main/01_trade_data_prep/01d_allocate_unknown_fmfo_consumption.Rmd)
Similar to the other fish trade, fish meal (FOFM) trade had unknown source countries. Following the same method as step 01c, we proportionately bumped up all known FOFM traded to a country from the unknown source trade. 

In order to distinguish aquatic food trade and consumption from fish meal trade and use, we incorporated information on production of fish meal. This was necessary because production data by species does not distinguish production for direct human consumption from industrial uses, including fish meal. To do this, we first calculated total fishmeal production by country based on the FAO processed products data (FAO Fisheries & Aquaculture). 

## 02_environmental_pressures
The environmental pressures data comes from two sources: Halpern et al. (2022) and Gephart et al. (2021). This processing step prepares the data to be joined with the trade data produced from step 01.

### [02a_efficiencies_data_prep.Rmd](https://github.com/jagephart/food_trade_pressures/blob/main/02_environmental_pressures/02a_efficiencies_data_prep.Rmd)
This Rmd prepares the data from Halpern et al. (2022) to be joined with the trade data. This source covers the pressures for livestock, crops, wild fisheries, and farmed seafood. The pressures data reports the pressure efficiency based on the product group name (ex. cows_meat, yams_produce, soyb_produce, etc.). The trade data reports products in a variety of ways. The goal of this script is to prepare the pressures data so that it can be easily joined with the trade data. 

Efficiency data was provided by Halpern et al. (2022).

### [02b_fw_aqua_pressures.Rmd](https://github.com/jagephart/food_trade_pressures/blob/main/02_environmental_pressures/02b_fw_aqua_pressures.Rmd)
Freshwater aquaculture environmental pressures data was sourced from Gephart et al. (2021). This script converts the units of the production pressures into the same units from Halpern et al. (2022). These pressures are global averages.
