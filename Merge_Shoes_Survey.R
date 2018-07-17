library(tidyverse)
library(lubridate)

shoefiles <- list.files("/myfiles/las/research/csafe/ShoeImagingPermanent/", full.names = T)


filelist <- data_frame(files = shoefiles) %>%
  tidyr::extract(files, into = c("ShoeID", "Date", "Method", 
                                 "Mode", "Replicate", "Additional", "Extension"),
                 regex = "(\\d{6}[RL])_(\\d{8})_{1,}(\\d)_(\\d{1,})_(\\d{1,})_(.*)\\.(.*)",
                 remove = F) %>%
  filter(!str_detect(files, "Thumbs"))

shoevisits <- filelist %>% ungroup %>%
  select(ShoeID, Method, Date) %>%
  unique() %>%
  mutate(date = ymd(Date)) %>%
  arrange(ShoeID, Method, date) %>%
  group_by(ShoeID, Method) %>%
  mutate(visit_num = row_number() - 1) %>%
  mutate(`Participant ID` = str_sub(ShoeID, 1, 3) %>% as.numeric())

survey_data <- read_csv("./Period Survey (Responses) - Form Responses 1.csv")

shoe_db <- filelist %>% left_join(shoevisits) %>%
  full_join(survey_data, by = c("Participant ID" = "Participant ID", "visit_num" = "Visit Number"))
