# food_trade_pressures repository

insert impact statement once finalized. Esstentially, we combine data that covers the environmental pressures of food production with food trade data to provide a publicly available dataset.

The steps to generate this data output are included in this repository. The data required to generate the final output are available on Zenodo (insert link). The overarching steps are:

1. trade_data_prep
2. environmental_pressures
3. feed_proportions_data_prep
4. connect_trade_and_pressures

The details of each step and the files they contained are explained below.

## trade_data_prep
Crop and licestock trade flows from producing to consuming country are based on Schwarzmueller et al. (2022) and are combined with fish data from the Aquatic Resource Trade in Species (ARTIS) database.

### [01a-format-fao-trade.Rmd](https://github.com/jagephart/food_trade_pressures/blob/main/01_trade_data_prep/01a-format-fao-trade.Rmd)
The first step taken in this process is to clean the trade and production data from the FAO so that it matches the input used in the trade matrix operation from Schwarzmueller et al. (2022).

