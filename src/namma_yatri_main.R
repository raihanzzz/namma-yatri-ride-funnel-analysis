library(dplyr)
library(lubridate)
library(tidyr)
library(ggplot2)
library(data.table)


df_booking<-read.csv("D:/PROJECTS/datathon/NY Datathon 2025/booking_data.csv")
head(df_booking)
str(df_booking)

df_search<-read.csv("D:PROJECTS/datathon/NY Datathon 2025/search_data.csv")
head(df_search)
str(df_search)  

df_quotedata<-read.csv("D:/PROJECTS/datathon/NY Datathon 2025/quote_data.csv")
str(df_quotedata)


df_booking_cancellation<-read.csv("D:/PROJECTS/datathon/NY Datathon 2025/booking_cancellation_data.csv")
str(df_booking_cancellation)

df_quotedata <- df_quotedata %>%
  mutate(driver_rating = as.numeric(driver_rating))


#changing data types

df_search <- df_search %>%
  mutate(search_request_created_at = ymd_hms(search_request_created_at))

df_quotedata <- df_quotedata %>%
  mutate(quote_created_at = ymd_hms(quote_created_at))

df_booking <- df_booking %>%
  mutate(booking_created_at = ymd_hms(booking_created_at))

df_booking_cancellation <- df_booking_cancellation %>%
  mutate(cancelled_at = ymd_hms(cancelled_at))

df_quotedata <- df_quotedata %>%
  mutate(
    driver_rating = as.numeric(driver_rating)
  )


#----------x-----------------

#q1

df_search_seg <- df_search %>%
  mutate(
    
    hour = hour(search_request_created_at),
    time_of_day = case_when(
      hour >= 6  & hour < 10 ~ "Morning",
      hour >= 10 & hour < 17 ~ "Day",
      hour >= 17 & hour < 21 ~ "Evening",
      TRUE                  ~ "Night"
    ),
    
    trip_km = estimated_distance / 1000,
    
    trip_length = case_when(
      trip_km < 5               ~ "Short",
      trip_km >= 5 & trip_km <= 15 ~ "Medium",
      trip_km > 15              ~ "Long"
    )
    
  )

#head(df_search_seg)

#storing unique quote datas
search_quote_flag <- df_quotedata %>%
  distinct(search_request_id) %>%
  mutate(has_quote = 1)
#join
df_search_funnel <- df_search_seg %>%
  left_join(search_quote_flag, by = "search_request_id") %>%
  mutate(has_quote = ifelse(is.na(has_quote), 0, 1))

quote_booking_flag <- df_booking %>%
  mutate(
    booked = 1,
    completed = ifelse(status == "COMPLETED", 1, 0)
  ) %>%
  select(quote_id, booked, completed)

# map search to quote_id
search_to_quote <- df_quotedata %>%
  select(search_request_id, quote_id) %>%
  distinct()

df_funnel_q1 <- df_search_funnel %>%
  left_join(search_to_quote, by = "search_request_id") %>%
  left_join(quote_booking_flag, by = "quote_id") %>%
  mutate(
    booked = ifelse(is.na(booked), 0, booked),
    completed = ifelse(is.na(completed), 0, completed)
  )

funnel_summary_q1 <- df_funnel_q1 %>%
  group_by(time_of_day, trip_length) %>%
  summarise(
    searches = n_distinct(search_request_id),
    quotes = sum(has_quote),
    bookings = sum(booked),
    completed = sum(completed),
    .groups = "drop"
  )

funnel_summary_q1 <- funnel_summary_q1 %>%
  mutate(
    search_to_quote_rate = quotes / searches,
    quote_to_booking_rate = bookings / quotes,
    booking_to_complete_rate = completed / bookings
  )

funnel_summary_q1 <- funnel_summary_q1 %>%
  mutate(
    drop_search_quote = 1 - search_to_quote_rate,
    drop_quote_booking = 1 - quote_to_booking_rate,
    drop_booking_complete = 1 - booking_to_complete_rate,
    
    max_drop_stage = case_when(
      drop_search_quote >= drop_quote_booking &
        drop_search_quote >= drop_booking_complete
      ~ "Search → Quote",
      
      drop_quote_booking >= drop_booking_complete
      ~ "Quote → Booking",
      
      TRUE
      ~ "Booking → Completed"
    )
  )

View(funnel_summary_q1)
print(funnel_summary_q1)

funnel_summary_q1 %>%
  select(
    time_of_day,
    trip_length,
    searches,
    quotes,
    bookings,
    completed
  ) %>%
  print(n = Inf)


#--------------

#q2.

overall_cancellation_rate <- df_booking %>%
  summarise(
    total_bookings = n(),
    cancelled = sum(status == "CANCELLED"),
    cancellation_rate = cancelled / total_bookings
  )

overall_cancellation_rate

#STEP 2: Driver vs Rider cancellations
driver_vs_rider <- df_booking_cancellation %>%
  group_by(source) %>%
  summarise(
    cancellations = n(),
    .groups = "drop"
  ) %>%
  mutate(percentage = cancellations / sum(cancellations))

driver_vs_rider

#STEP 3: Pickup distance bucket analysis

pickup_cancellation <- df_booking_cancellation %>%
  left_join(
    df_booking %>% select(booking_id, quote_id),
    by = "booking_id",
    relationship = "many-to-many"
    
  ) %>%
  left_join(
    df_quotedata %>% select(quote_id, distance_to_pickup),
    by = "quote_id"
  ) %>%
  mutate(
    pickup_bucket = case_when(
      distance_to_pickup < 500 ~ "Near (<500m)",
      distance_to_pickup < 1500 ~ "Medium (500m–1.5km)",
      TRUE ~ "Far (>1.5km)"
    )
  ) %>%
  group_by(pickup_bucket) %>%
  summarise(cancellations = n(), .groups = "drop")

pickup_cancellation

#🔹 STEP 4: Trip distance bucket analysis
trip_cancellation <- df_booking_cancellation %>%
  left_join(
    df_booking %>% select(booking_id, quote_id),
    by = "booking_id",
    relationship = "many-to-many"
  ) %>%
  left_join(
    df_quotedata %>% select(quote_id, search_request_id),
    by = "quote_id"
  ) %>%
  left_join(
    df_search_seg %>% select(search_request_id, trip_length),
    by = "search_request_id"
  ) %>%
  group_by(trip_length) %>%
  summarise(cancellations = n(), .groups = "drop")

trip_cancellation

#🔹 STEP 5: Top 3 driver cancellation reasons
top_driver_reasons <- df_booking_cancellation %>%
  filter(source == "ByDriver") %>%
  group_by(reason_code) %>%
  summarise(cancellations = n(), .groups = "drop") %>%
  arrange(desc(cancellations)) %>%
  slice_head(n = 3)

top_driver_reasons

#🔹 STEP 6: Driver cancellation trends by time-of-day
driver_cancel_time <- df_booking_cancellation %>%
  filter(source == "ByDriver") %>%
  left_join(
    df_booking %>% select(booking_id, quote_id),
    by = "booking_id",
    relationship = "many-to-many"
  ) %>%
  left_join(
    df_quotedata %>% select(quote_id, search_request_id),
    by = "quote_id"
  ) %>%
  left_join(
    df_search_seg %>% select(search_request_id, time_of_day),
    by = "search_request_id"
  ) %>%
  group_by(time_of_day, reason_code) %>%
  summarise(cancellations = n(), .groups = "drop")

driver_cancel_time

#🔹 STEP 6: Driver cancellation trends by time-of-day
driver_cancel_time <- df_booking_cancellation %>%
  filter(source == "ByDriver") %>%
  left_join(
    df_booking %>% select(booking_id, quote_id),
    by = "booking_id",
    relationship = "many-to-many"
  ) %>%
  left_join(
    df_quotedata %>% select(quote_id, search_request_id),
    by = "quote_id"
  ) %>%
  left_join(
    df_search_seg %>% select(search_request_id, time_of_day),
    by = "search_request_id"
  ) %>%
  group_by(time_of_day, reason_code) %>%
  summarise(cancellations = n(), .groups = "drop")

driver_cancel_time

#🔹 STEP 7: Driver cancellation vs trip length
driver_cancel_trip <- df_booking_cancellation %>%
  filter(source == "ByDriver") %>%
  left_join(
    df_booking %>% select(booking_id, quote_id),
    by = "booking_id",
    relationship = "many-to-many"
  ) %>%
  left_join(
    df_quotedata %>% select(quote_id, search_request_id),
    by = "quote_id"
  ) %>%
  left_join(
    df_search_seg %>% select(search_request_id, trip_length),
    by = "search_request_id"
  ) %>%
  group_by(trip_length, reason_code) %>%
  summarise(cancellations = n(), .groups = "drop")

driver_cancel_trip

#STEP 8: Driver rating vs cancellation
rating_cancellation <- df_booking_cancellation %>%
  filter(source == "ByDriver") %>%
  left_join(
    df_booking %>% select(booking_id, quote_id),
    by = "booking_id",
    relationship = "many-to-many"
  ) %>%
  left_join(
    df_quotedata %>% select(quote_id, driver_rating),
    by = "quote_id"
  ) %>%
  mutate(
    rating_bucket = case_when(
      driver_rating < 4 ~ "<4",
      driver_rating < 4.5 ~ "4–4.5",
      TRUE ~ ">4.5"
    )
  ) %>%
  group_by(rating_bucket) %>%
  summarise(cancellations = n(), .groups = "drop")

rating_cancellation


#--------------------x-------------------
#q3
#Step 1: Create driver-level features
driver_features <- df_quotedata %>%
  left_join(
    df_booking %>% select(quote_id, status),
    by = "quote_id"
  ) %>%
  group_by(driver_id) %>%
  summarise(
    total_quotes = n(),
    total_bookings = sum(!is.na(status)),
    completed_rides = sum(status == "COMPLETED", na.rm = TRUE),
    avg_pickup_distance = mean(distance_to_pickup, na.rm = TRUE),
    avg_rating = mean(driver_rating, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    booking_rate = total_bookings / total_quotes,
    completion_rate = completed_rides / total_bookings
  )

driver_features_cluster <- driver_features %>%
  select(
    driver_id,
    total_quotes,
    booking_rate,
    completion_rate,
    avg_pickup_distance
  ) %>%
  drop_na()


driver_cluster_matrix <- driver_features_cluster %>%
  select(-driver_id) %>%
  scale()


set.seed(42)
driver_clusters <- kmeans(driver_cluster_matrix, centers = 3)

driver_features_cluster$cluster <- driver_clusters$cluster

driver_features <- driver_features %>%
  left_join(
    driver_features_cluster %>% select(driver_id, cluster),
    by = "driver_id"
  )

table(driver_features$cluster, useNA = "ifany")

#for easy to understand clusters
cluster_summary <- driver_features %>%
  count(cluster) %>%
  mutate(
    percentage = round(n / sum(n) * 100, 1),
    cluster = ifelse(is.na(cluster), "Unassigned", paste("Cluster", cluster))
  )

cluster_summary


#q4 funnel Visualization with Storytelling

overall_funnel <- funnel_summary_q1 %>%
  summarise(
    searches = sum(searches),
    quotes = sum(quotes),
    bookings = sum(bookings),
    completed = sum(completed)
  )

library(plotly)

fig_overall <- plot_ly(
  type = "funnel",
  y = c("Searches", "Quotes", "Bookings", "Completed"),
  x = c(
    overall_funnel$searches,
    overall_funnel$quotes,
    overall_funnel$bookings,
    overall_funnel$completed
  ),
  textinfo = "value+percent initial",
  marker = list(
    color = c("#4C78A8", "#72B7B2", "#F58518", "#E45756")
  )
) %>%
  layout(
    title = "Overall Ride Funnel – Namma Yatri"
  )

fig_overall

#--------ggplot(top-down funnel)-------------------
#step 1
library(ggplot2)

funnel_df <- data.frame(
  stage = factor(
    c("Searches", "Quotes", "Bookings", "Completed"),
    levels = c("Searches", "Quotes", "Bookings", "Completed")
  ),
  count = c(
    overall_funnel$searches,
    overall_funnel$quotes,
    overall_funnel$bookings,
    overall_funnel$completed
  )
) %>%
  mutate(
    percent = round(count / count[1] * 100, 1)
  )

#step 2
ggplot(funnel_df, aes(x = stage, y = count, fill = stage)) +
  geom_col(width = 0.6) +
  geom_text(
    aes(label = paste0(
      scales::comma(round(count)), "\n",
      percent, "%"
    )),
    vjust = -0.3,
    size = 4,
    fontface = "bold"
  ) +
  scale_fill_manual(
    values = c(
      "Searches" = "#4C78A8",
      "Quotes" = "#72B7B2",
      "Bookings" = "#F58518",
      "Completed" = "#E45756"
    )
  ) +
  labs(
    title = "Overall Ride Funnel",
    x = NULL,
    y = "Number of Users"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    legend.position = "none",
    plot.title = element_text(face = "bold", hjust = 0.5)
  )


