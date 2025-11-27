<jsp:include page="/auth/AuthCheck.jsp" />
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>

<%

String search = request.getParameter("search");
String fee    = request.getParameter("fee");
String time   = request.getParameter("time");
String loc    = request.getParameter("loc");
String sort   = request.getParameter("sort");

if (search == null) search = "";
if (fee == null) fee = "";
if (time == null) time = "";
if (loc == null) loc = "";
if (sort == null) sort = "";

Class.forName("com.mysql.cj.jdbc.Driver");
Connection conn = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/jad_assign1?user=root&password=1G9r5a6c1E**"
);

/* Load unique filter values */
PreparedStatement psFee = conn.prepareStatement(
    "SELECT DISTINCT delivery_fee FROM grocery_company ORDER BY delivery_fee ASC"
);
ResultSet feeRs = psFee.executeQuery();

PreparedStatement psTime = conn.prepareStatement(
    "SELECT DISTINCT est_delivery_time FROM grocery_company ORDER BY est_delivery_time ASC"
);
ResultSet timeRs = psTime.executeQuery();

PreparedStatement psLoc = conn.prepareStatement(
    "SELECT DISTINCT location FROM grocery_company ORDER BY location ASC"
);
ResultSet locRs = psLoc.executeQuery();

/* --- Build dynamic SQL --- */
String sql =
    "SELECT c.id, c.name, c.delivery_fee, c.est_delivery_time, c.location, " +
    "IFNULL(AVG(r.rating),0) AS rating " +
    "FROM grocery_company c " +
    "LEFT JOIN grocery_review r ON c.id = r.company_id " +
    "WHERE c.name LIKE ? ";

if (!fee.isEmpty()) {
    sql += " AND c.delivery_fee <= " + fee;
}

if (!time.isEmpty()) {
    sql += " AND c.est_delivery_time = '" + time + "'";
}

if (!loc.isEmpty()) {
    sql += " AND c.location = '" + loc + "'";
}

sql += " GROUP BY c.id";

if ("rating".equals(sort)) {
    sql += " ORDER BY rating DESC";
} else if ("fee".equals(sort)) {
    sql += " ORDER BY c.delivery_fee ASC";
} else if ("time".equals(sort)) {
    sql += " ORDER BY c.est_delivery_time ASC";
}

PreparedStatement ps = conn.prepareStatement(sql);
ps.setString(1, "%" + search + "%");
ResultSet rs = ps.executeQuery();
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Find Grocery Providers</title>

<style>
body { font-family: Arial; background:#f4f4f4; margin:0; padding:20px; }
.container { display:flex; gap:20px; }

.filter-box {
    width:30%; background:white; padding:20px; border-radius:8px;
}

input, select {
    width:100%; padding:8px; margin-bottom:12px;
}

.btn {
    width:100%; padding:10px; background:#3e7bfa; color:white;
    border:none; border-radius:5px; cursor:pointer;
}

.results-box {
    width:70%;
}

.card {
    background:white; padding:20px; border-radius:10px;
    border:1px solid #ddd; margin-bottom:20px;
}

.card h3 { margin:0 0 10px 0; }

.sort-btn {
    background:#e8e8e8; padding:8px 15px; border-radius:6px;
    border:none; cursor:pointer; margin-bottom:20px; margin-right:10px;
}
.sort-btn:hover { background:#d3d3d3; }
html, body {
    margin: 0 !important;
    padding: 0 !important;
}

.navbar {
    margin: 0 !important;
    padding-top: 0 !important;
}

</style>
</head>

<body>
<jsp:include page="/home/NavBar.jsp" />
<h1>Find Grocery Provider</h1>

<div class="container">

    <!-- LEFT FILTERS -->
    <div class="filter-box">

        <form method="GET">

            <label>Search Name</label>
            <input type="text" name="search" value="<%= search %>">

            <label>Max Delivery Fee</label>
            <select name="fee">
                <option value="">Any</option>
                <% while (feeRs.next()) { %>
                    <option value="<%= feeRs.getDouble(1) %>" <%= fee.equals(feeRs.getString(1)) ? "selected" : "" %>>
                        ≤ $<%= feeRs.getDouble(1) %>
                    </option>
                <% } %>
            </select>

            <label>Delivery Time</label>
            <select name="time">
                <option value="">Any</option>
                <% while (timeRs.next()) { %>
                    <option value="<%= timeRs.getString(1) %>" <%= time.equals(timeRs.getString(1)) ? "selected" : "" %>>
                        <%= timeRs.getString(1) %>
                    </option>
                <% } %>
            </select>

            <label>Location</label>
            <select name="loc">
                <option value="">Any</option>
                <% while (locRs.next()) { %>
                    <option value="<%= locRs.getString(1) %>" <%= loc.equals(locRs.getString(1)) ? "selected" : "" %>>
                        <%= locRs.getString(1) %>
                    </option>
                <% } %>
            </select>

            <button class="btn">Apply Filters</button>
        </form>

    </div>

    <!-- RIGHT RESULTS -->
    <div class="results-box">

        <!-- Sorting Buttons -->
        <button class="sort-btn" onclick="window.location='GroceryList.jsp?sort=rating'">Sort by Rating</button>
        <button class="sort-btn" onclick="window.location='GroceryList.jsp?sort=fee'">Sort by Fee</button>
        <button class="sort-btn" onclick="window.location='GroceryList.jsp?sort=time'">Sort by Time</button>

        <%
        while (rs.next()) {
        %>

        <div class="card">
            <h3><%= rs.getString("name") %></h3>
            <p>Rating: <%= String.format("%.1f", rs.getDouble("rating")) %> ★</p>
            <p>Delivery Fee: $<%= rs.getDouble("delivery_fee") %></p>
            <p>Delivery Time: <%= rs.getString("est_delivery_time") %></p>
            <p>Location: <%= rs.getString("location") %></p>

            <a class="btn" href="GroceryDetails.jsp?id=<%= rs.getInt("id") %>">View Provider</a>
        </div>

        <% } %>
    </div>

</div>

</body>
</html>

<%
conn.close();
%>
