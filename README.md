# 🎬Chinook-Database-Analysis

This project is a comprehensive SQL-based analysis of the **Chinook Sample Database**, covering key insights and behaviors of customers, Artists, Tracks, and Invoices.

All logic is implemented in a single SQL script file:
**Chinook_analysis.sql**
Running this file will create all the necessary **views**, **stored procedures**, and **functions** in your SQL SERVER Chinook database.


---


## 📦 Project Structure

```plaintext
Chinook-analysis/
│
├── views/                 # Reusable reports and insights
├── procedures/            # Stored procedures for business logic
├── functions/             # User-defined utility functions
├── Chinook_analysis.sql    #All logic
├── README.md
```

---

## 📊 Views

### 1️⃣ V_CustomerInvoices1️
This view displays each customer's invoice information along with the customer's full name.
It is very useful for generating sales reports by customer.

### 2️⃣ V_InvoiceDetails
It provides you with all the details about each invoice, including the name of the tracks purchased,
the quantity, the price, and the total for each order line.
Very useful for accurate billing and sales reporting.

### 3️⃣ V_MonthlyRevenue
This view displays total sales revenue by month and year;
a great tool for analyzing sales growth over time and preparing management reports.

### 4️⃣ V_TopSellingTracks
This view shows a list of the best-selling tracks based on sales.
It's incredibly useful for identifying the most popular songs and analyzing the market.

### 5️⃣ V_ArtistAlbumCount
This view displays the number of albums for each artist.
It helps you quickly see how many albums each artist has in the system.

### 6️⃣ V_CustomerCountryCount
Provides a list of the number of customers by country.
It is very useful for analyzing the global market and examining the concentration of customers in different countries.

### 7️⃣ V_EmployeeCustomers
This view displays the relationship between employees and customers; it identifies which employee supports each customer.
Suitable for CRM reports and reviewing sales team performance.

### 8️⃣ V_GenreTrackCount
This view displays the number of tracks in each music genre;
it is very useful for analyzing and reporting on the distribution of genres.

### 9️⃣ V_AlbumTrackList
Displays all tracks from each album, along with artist name and track duration.
Used to create album lists and browse content.

### 🔟 V_CustomerLastInvoice
This view shows the last invoice posted for each customer.
It is great for tracking new customer purchases and checking for inactive customers.

### 1️⃣1️⃣ V_TopCountriesByRevenue
This view lists total revenue by country;
it is invaluable for analyzing the international market and identifying top-selling regions.

---

## ⚙️ Stored Procedures




---

## 🔧 Functions




---

## 🧪 Usage





---

## 👨‍💻 Author




















