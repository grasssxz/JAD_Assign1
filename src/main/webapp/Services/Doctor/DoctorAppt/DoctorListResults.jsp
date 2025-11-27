<jsp:include page="/auth/SessisonInit.jsp" />


<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
request.setCharacterEncoding("UTF-8");

/* ==========================================================
   Read filters from request
   ========================================================== */
String name       = request.getParameter("name");
String specialty  = request.getParameter("specialty");
String experience = request.getParameter("experience");
String rating     = request.getParameter("rating");

/* ==========================================================
   Database Connection
   ========================================================== */
Class.forName("com.mysql.cj.jdbc.Driver");
Connection conn = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/jad_assign1?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC",
    "root",
    "1G9r5a6c1E**"
);

/* ==========================================================
   Build dynamic SQL
   ========================================================== */
String sql =
    "SELECT d.*, IFNULL(AVG(r.rating),0) AS avg_rating " +
    "FROM doctor d LEFT JOIN doctor_review r ON d.id = r.doctor_id WHERE 1=1";

/* Filters */
if (name != null && !name.trim().equals("")) {
    sql += " AND d.name LIKE '%" + name + "%'";
}
if (specialty != null && !specialty.trim().equals("")) {
    sql += " AND d.specialty = '" + specialty + "'";
}
if (experience != null && !experience.trim().equals("")) {
    sql += " AND d.experience_years >= " + experience;
}

sql += " GROUP BY d.id";

if (rating != null && !rating.trim().equals("")) {
    sql += " HAVING avg_rating >= " + rating;
}

PreparedStatement ps = conn.prepareStatement(sql);
ResultSet rs = ps.executeQuery();
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />

<!-- Tailwind CSS -->
<script src="https://cdn.tailwindcss.com"></script>

<title>Doctor Results</title>
</head>

<body class="bg-white p-6">

<h2 class="text-3xl font-bold text-gray-800 mb-6">Doctor Results</h2>

<%
boolean hasResults = false;

while (rs.next()) {
    hasResults = true;

    String docName = rs.getString("name");
    String docSpec = rs.getString("specialty");
    int exp = rs.getInt("experience_years");
    double avgRating = rs.getDouble("avg_rating");

    // Star rendering
    int fullStars = (int) avgRating;
    boolean halfStar = avgRating - fullStars >= 0.5;
%>

<!-- CARD -->
<div class="bg-gray-50 p-6 mb-6 rounded-xl border shadow-sm">

    <h3 class="text-xl font-semibold mb-2"><%= docName %></h3>

    <p><span class="font-semibold">Specialty:</span> <%= docSpec %></p>
    <p><span class="font-semibold">Experience:</span> <%= exp %> years</p>

    <p class="mt-2 font-semibold">Rating:</p>
<div class="text-yellow-500 text-lg">
    <% for (int i = 0; i < fullStars; i++) { %>
        ★
    <% } %>

    <% if (halfStar) { %>
        ☆
    <% } %>

    <span class="text-gray-700 ml-2 text-base">
        <%= String.format("%.1f", avgRating) %>
    </span>
</div>


    <a href="<%= request.getContextPath() %>/Services/Doctor/DoctorAppt/DoctorDetails.jsp?id=<%= rs.getInt("id") %>"
   class="inline-block mt-4 bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg font-medium">
   View Profile
</a>

</div>

<%
}
if (!hasResults) {
%>

<p class="text-gray-700 text-lg">No doctors match your filters.</p>

<%
}
conn.close();
%>

</body>
</html>
