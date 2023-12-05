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

## 03_feed_proportions_data_prep
Fish meal and various crops are used for animal feed alongside human consumption and industrial uses. Therefore, to capture the full environmental pressures of animals we needed to attribute crop and fish meal pressures to the animal systems consuming that feed. o accomplish this we needed to know the proportion of how much of a crop and fish meal is used for feed by a country. We also needed to know how much of that crop and fish meal used for feed is going to each individual animal system. To calculate the necessary proportions we used a combination of FAOSTAT food balances and animal feed consumption quantities (Schwarzmueller et al. 2022, Halpern et al. 2022). 

### [03ai_proportion_feed_per_crop_country_FAO_FB_and_CB_2013.Rmd](https://github.com/jagephart/food_trade_pressures/blob/main/03_feed_proportions_data_prep/03ai_proportion_feed_per_crop_country_FAO_FB_and_CB_2013.Rmd)
Here we use 2013 data from the FAO Food Balances and Commodity Balances data to determine the proportion of certain crops being used as feed. 2013 FAO data was used for soy, palm oil, and oil crops because that is the most recent year in which data is available from the FAO that breaks down feed usage for these crops. The FAO changed reporting methodologies in 2013, which affected how some crops’ usage was tracked in their data.

### [03aii_calc_prop_feed_pulses_grains_2017_FAO_FB.Rmd](https://github.com/jagephart/food_trade_pressures/blob/main/03_feed_proportions_data_prep/03aii_calc_prop_feed_pulses_grains_2017_FAO_FB.Rmd)
In this script we calculate the proportion of each country's domestic supply quantity that they used as feed for each grains and pulses using 2017 FAO Food Balance data. Grains is an aggregate from the FAO that captures the use of 7 SPAM categories for feed. The FAO methodologies countinued to split up uses of feed for grains and pulses in the 2017 reporting year and after the methodologies were changed in 2013.

### [03aiii_combine_gf_prop_feed_dfs.Rmd](https://github.com/jagephart/food_trade_pressures/blob/main/03_feed_proportions_data_prep/03aiii_combine_gf_prop_feed_dfs.Rmd)
We combine the crop proportions used for feed calculated in steps 03ai and 03aii in this script to have all of the crop proportions in one csv.

### [03b_fw_aquaculture_feed_crops_and_fofm.Rmd](https://github.com/jagephart/food_trade_pressures/blob/main/03_feed_proportions_data_prep/03b_fw_aquaculture_feed_crops_and_fofm.Rmd)
The total crop and fishmeal consumption by freshwater aquaculture by country and taxa group is calculated.

### [03c_calculate_crop_used_for_each_animal.Rmd](https://github.com/jagephart/food_trade_pressures/blob/main/03_feed_proportions_data_prep/03c_calculate_crop_used_for_each_animal.Rmd)
The totals of feed calculated for freshwater aquaculture in step 03b are joined with the totals used by other animal systems. These are used to calculate the proportion of each crop and fish meal used by each animal system within a country.


