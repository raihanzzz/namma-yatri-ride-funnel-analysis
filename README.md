# Namma Yatri – Ride Funnel Analysis

## 📌 Project Overview
This project presents an end-to-end analytical study of a ride-hailing platform’s booking lifecycle, focusing on user conversion, cancellations, and operational bottlenecks.  
The goal is to understand how riders progress from initiating a search to completing a ride, identify where and why drop-offs occur, and derive actionable insights to improve platform reliability and efficiency.

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

