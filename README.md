# Namma Yatri – Ride Funnel Analysis

## 📌 Project Overview
This project is an end-to-end analytical study conducted on **real, industry-scale ride-hailing data**, consisting of **~6 million records** distributed across **multiple relational tables** (searches, quotes, bookings, and cancellations), with an overall data size in the **multi-gigabyte range**.

The analysis follows **production-level analytics standards**, including structured data cleaning, large-scale joins, funnel construction, cancellation diagnostics, behavioral segmentation, and stakeholder-focused storytelling.

The objective is to understand how riders progress from search initiation to ride completion, identify critical funnel drop-offs, uncover operational bottlenecks, and propose data-backed recommendations to improve conversion and ride reliability.


---

## 🔄 Rider Journey
The rider flow analyzed in this project follows the standard booking lifecycle:

**Search Request → Quote Received → Booking Created → Ride Completed**

---

## 🎯 Analysis Scope & Questions Addressed

The analysis is structured into four key sections, each addressing a specific business question:

### **Q1. Funnel Construction & Conversion Analysis**

---

### **Q2. Cancellation Driver Analysis**

---

### **Q3. Root Cause Analysis using Driver Segmentation**

---

### **Q4. Funnel Visualization & Storytelling**

---

## 📊 Key Insights

- The **largest funnel drop occurs at the Search → Quote stage**, indicating driver availability constraints rather than lack of rider intent.
- **Quote → Booking conversion is consistently high**, suggesting strong user intent once a quote is received.
- A significant drop at **Booking → Completion** is driven primarily by **driver-side cancellations**.
- Driver segmentation reveals a **low-activity, high-cancellation segment** that disproportionately impacts ride completion rates.
- Longer pickup distances are strongly associated with higher cancellation likelihood.

---

## 🛠 Methods & Techniques Used

- Funnel analysis and conversion rate computation  
- Segmentation by time of day and trip length  
- Cancellation analysis by source, distance, and behavior  
- Driver clustering for behavioral segmentation  
- Data cleaning and transformation in R  
- Visualization using **ggplot2** (top-down funnel) and **Plotly** (interactive)

---

## 📈 Visual Outputs

Key visualizations generated in this project include:
- Top-down funnel visualization showing conversion across booking stages
- Interactive funnel highlighting major drop-off points
- Driver segment distribution summaries

All visual outputs are available in the `assets/` directory.

---

## 🚀 Recommendations

Based on the analysis, the following actions are recommended:
- Improve driver availability during high-demand periods to reduce Search → Quote drop-offs
- Incentivize long-distance and high-pickup rides for drivers
- Introduce reliability-based driver prioritization to reduce post-booking cancellations
- Monitor high-cancellation driver segments and apply targeted interventions

---

## 🗂 Repository Structure

```
namma-yatri-ride-funnel-analysis/
│
├── README.md
├── src/ # Analysis code (R)
│ └── namma_yatri_main.R
├── assets/ # Funnel visualizations and main outputs
└── dataset/ # Data notes (raw data excluded)
└── insights/ # key insights
```

---

## 📁 Data Availability
The raw dataset is intentionally excluded from this repository due to size and privacy constraints.

The analysis was performed on a large, production-scale dataset spanning multiple relational tables and several million records, resulting in a multi-gigabyte data footprint.

This repository focuses on reproducible analysis logic, methodology, and data-driven insights.  
For access-related queries, please feel free to contact me.

---

## 📬 Contact
For any questions regarding the analysis or methodology, feel free to connect with me:

**MD RAIHAN**  
🔗 LinkedIn: https://www.linkedin.com/in/md-raihan-9809592aa/


---

