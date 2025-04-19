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

### 1️⃣ Usp_GetCustomerInvoices
Display a list of invoices for a specific customer based on CustomerId.
Suitable for displaying customer purchase history

### 2️⃣ Usp_GetInvoicesByDateRange
Display all invoices issued within a specified time period.
Suitable for periodic financial reports

### 3️⃣ Usp_GetTopSellingTracks
Report the total number of sales per track along with the total sales amount.
Suitable for analyzing the most popular music tracks

### 4️⃣ Usp_GetCustomerPurchaseSummary
A customer's purchase summary including invoice number and total payment amount.
Suitable for generating customer activity summary reports

### 5️⃣ Usp_InsertNewInvoiceWithLines
Create a new invoice with multiple InvoiceLines in one secure transaction.
Suitable for creating complete orders and preventing incomplete data storage.

### 6️⃣ Usp_CreateInvoiceWithTracks
This Stored Procedure is responsible for creating a new invoice with the tracks that are purchased at that moment.
All operations are performed in a single transaction so that if something goes wrong, incomplete information is not recorded.

### 7️⃣ Usp_SafeDeleteCustomer
Safe customer deletion; if the customer has a registered invoice, deletion is not allowed.
Suitable for preventing accidental deletion of active customers.

### 8️⃣ Usp_CheckSalesAndNotify
Check the sales of a track and display a warning message if sales are below a specified amount.
Suitable for controlling the quality of sales and monitoring low-selling tracks.

### 9️⃣ Usp_UpdateTrackPrices
Update music track prices based on a percentage increase or decrease sent as input.
Suitable for making quick changes to pricing across an entire track archive.

---

## 🔧 Functions

### 1️⃣ Svf_GetFullCustomerName
Return the full name of a customer (FirstName + LastName) using CustomerId.

### 2️⃣ Svf_CalculateDiscountAmount
Calculate the final amount after applying a discount percentage to an input amount.

### 3️⃣ Svf_GetInvoiceTotalByCustomer
Calculate the total total payments made by a specific customer.

### 4️⃣ Svf_GetTrackDurationInMinutes
Dial the duration of the music track from milliseconds to minutes with decimal accuracy.

### 5️⃣ Svf_GetCountrySalesCount
Calculate the total number of sales made in each country dynamically.

### 6️⃣ Tvf_GetInvoicesByCountry
Display a list of all registered invoices for a specific country.

### 7️⃣ Tvf_GetCustomerInvoices
Display all invoices registered for a specific customer based on CustomerId.

### 8️⃣ Tvf_GetTracksByGenre
Return a list of music tracks based on the given GenreId.

### 9️⃣ Tvf_GetTopSellingTracks
Return a list of the best-selling tracks in the entire database.

### 🔟 Tvf_GetCustomerPurchaseHistory
Display a customer's purchase history, including invoices and the total of each purchase.

---

## 🧪 Usage

# 🎵 Chinook SQL Server Practice Project

This project is designed for practicing and improving SQL Server skills using the real-world **Chinook** database.

## ⚡️ Usage — How to Install & Use the Chinook Database

### 🎧 Download the Chinook Database

1. Download the Chinook database from the official GitHub repository:  
👉 [Chinook Database GitHub](https://github.com/lerocha/chinook-database)

2. You can either download the ZIP file directly or clone the repository using Git:

```bash
git clone https://github.com/lerocha/chinook-database.git
```

### 🗄️ Installing Chinook Database on SQL Server

1. After downloading, navigate to the following path:

```
chinook-database > ChinookDatabaseScripts > Chinook_SqlServer.sql
```

2. Open the `Chinook_SqlServer.sql` file in **SQL Server Management Studio (SSMS)**.

3. Make sure the database is created properly by running this part of the script:

```sql
USE [master];
GO
CREATE DATABASE [Chinook];
GO
USE [Chinook];
```

4. Once the database is created, select all content of the `.sql` script and execute it.  
If the script runs successfully, the `Chinook` database will be ready on your SQL Server instance.


### 🧠 Notes

- Chinook is a lightweight sample database designed for training and testing.
- The database simulates a digital music store with tables for Customers, Invoices, Tracks, Albums, Artists, and more.
- Perfect for practicing SQL concepts like `SELECT`, `JOIN`, `GROUP BY`, `Stored Procedures`, `Views`, `Functions`, `Triggers` and advanced querying.

✅ Once the database is set up, you can follow the exercises, views, stored procedures, and advanced examples provided in this repository.

---

## 🤝 Contribution

Pull requests are welcome!  
If you have ideas for new examples or better solutions, feel free to contribute.

---

## ⭐ Support

If this project helped you, please consider giving it a ⭐ on GitHub!  
If you have questions or suggestions, open an issue — I’ll be happy to help!

---

## 👨‍💻 Author
Created by mehranmohammadiii
• [GitHub](https://github.com/mehranmohammadiii)   • [LinkedIn](www.linkedin.com/in/mehran-mohammadi-ceo) 




















