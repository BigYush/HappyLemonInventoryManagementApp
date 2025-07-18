# Happy Lemon Inventory Management App

**Happy Lemon Inventory Management App** is a Flutter-based mobile application designed to help store owners and managers track monthly inventory and forecast future needs.

---

## How It Works

The app is centered around simple, month-by-month inventory tracking with smart predictions based on past data. Users can select a month and year using a built-in calendar picker, then view or input item quantities in a clean, spreadsheet-like format.

### 1. Add/View Inventory Data

- Use the **calendar picker** to choose a specific **month and year**.
- After selection, users can **add or view inventory data** for that time period.
- Data is displayed in a table format where each row is an item and users can input the quantity used or needed.
- Entries are stored locally and kept separate by month and year for easy historical reference.

### 2. Predict Inventory

- The app automatically calculates predictions using past data from the same month over the previous two years.
- It computes the average usage per item to recommend suggested quantities for the selected month.
- This helps plan inventory based on historical demand patterns.

---

## Tech Stack

- **Frontend**: Flutter (Dart)
- **Local Storage**: Hive (for offline data saving)
- **Date Selection**: Calendar picker for month and year
- **Interface**: Table-style layout for clear inventory management

---

## Features

- Add and view inventory for any month and year  
- Month/year selection using a visual calendar  
- Spreadsheet-style UI for easy entry and review  
- Smart predictions based on 2-year historical data  
- Local data storage with Hive (fully offline support)  
