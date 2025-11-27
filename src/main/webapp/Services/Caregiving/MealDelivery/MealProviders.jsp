<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<!-- SESSION INIT (PUBLIC PAGE) -->
<jsp:include page="/auth/SessisonInit.jsp" />





<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<title>Meal Providers</title>

<!-- Tailwind CSS -->
<script src="https://cdn.tailwindcss.com"></script>

</head>
<body class="bg-gray-100 min-h-screen p-8">

    <div class="max-w-5xl mx-auto">

        <!-- PAGE TITLE -->
        <h1 class="text-3xl font-bold mb-8">Meal Delivery Providers</h1>

        <%
            Class.forName("com.mysql.cj.jdbc.Driver");
            String url = "jdbc:mysql://localhost:3306/jad_assign1?user=root&password=1G9r5a6c1E**";
            Connection conn = DriverManager.getConnection(url);

            String sql = "SELECT id, name, is_active FROM meal_provider WHERE is_active = 1";
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
        %>

        <!-- PROVIDER LIST CONTAINER -->
        <div class="grid grid-cols-1 gap-6">

            <%
                while (rs.next()) {
                    int providerId = rs.getInt("id");
                    String providerName = rs.getString("name");

                    // Compute avg rating
                    PreparedStatement psRate = conn.prepareStatement(
                        "SELECT IFNULL(AVG(r.rating),0) AS rating " +
                        "FROM reviews r JOIN meal m ON r.meal_id = m.id " +
                        "WHERE m.provider_id = ?"
                    );
                    psRate.setInt(1, providerId);
                    ResultSet rsRate = psRate.executeQuery();
                    double rating = 0;
                    if (rsRate.next()) rating = rsRate.getDouble("rating");
            %>

            <!-- PROVIDER CARD -->
            <div class="bg-white shadow rounded-lg p-6">
                <h2 class="text-xl font-semibold"><%= providerName %></h2>

                <p class="mt-1 text-gray-700">
                    Rating: <%= String.format("%.1f", rating) %> ★
                </p>

                <!-- View Provider Button -->
                <a href="MealProviderDetails.jsp?id=<%= providerId %>"
                   class="inline-block mt-4 px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700">
                    View Provider
                </a>
            </div>

            <%
                } // end while
                conn.close();
            %>

        </div>
    </div>

</body>
</html>
