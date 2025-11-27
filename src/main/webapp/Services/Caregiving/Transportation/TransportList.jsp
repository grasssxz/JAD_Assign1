<jsp:include page="/auth/SessisonInit.jsp" />
<jsp:include page="/home/NavBar.jsp" />
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<script src="https://cdn.tailwindcss.com"></script>

<%
    Class.forName("com.mysql.cj.jdbc.Driver");
    String url = "jdbc:mysql://localhost:3306/jad_assign1?user=root&password=1G9r5a6c1E**";
    Connection conn = DriverManager.getConnection(url);

    String name = request.getParameter("name");
    String location = request.getParameter("location");
    String vehicle = request.getParameter("vehicle_type");
    String wc = request.getParameter("wheelchair_friendly");
    String minRating = request.getParameter("min_rating");

    String sql =
        "SELECT * FROM (" +
        "   SELECT p.*, IFNULL(AVG(r.rating), 0) AS rating " +
        "   FROM transport_provider p " +
        "   LEFT JOIN transport_review r ON p.id = r.provider_id " +
        "   WHERE 1=1 ";

    if (name != null && !name.isEmpty())
        sql += " AND p.name LIKE '%" + name + "%' ";

    if (location != null && !location.isEmpty())
        sql += " AND p.location = '" + location + "' ";

    if (vehicle != null && !vehicle.isEmpty())
        sql += " AND p.vehicle_type = '" + vehicle + "' ";

    if ("1".equals(wc))
        sql += " AND p.wheelchair_friendly = 1 ";

    sql += " GROUP BY p.id ) AS providerTable ";

    if (minRating != null && !minRating.isEmpty())
        sql += " WHERE rating >= " + minRating + " ";

    System.out.println("===== FINAL SQL =====");
    System.out.println(sql);
    System.out.println("=====================");

    PreparedStatement ps = conn.prepareStatement(sql);
    ResultSet rs = ps.executeQuery();
%>

<div class="max-w-7xl mx-auto mt-10 grid grid-cols-1 md:grid-cols-4 gap-8">

    <!-- FILTER SIDEBAR -->
    <div class="bg-white shadow p-6 rounded-lg h-fit">
        <h2 class="text-xl font-semibold mb-4">Filter Transportation</h2>

        <form method="GET">

            <!-- NAME -->
            <label class="block text-sm font-medium">Search Name</label>
            <input type="text" name="name" value="<%= name != null ? name : "" %>"
                class="mt-1 w-full border rounded px-3 py-2" />

            <!-- LOCATION -->
            <label class="block text-sm font-medium mt-4">Location</label>
            <select name="location" class="mt-1 w-full border rounded px-3 py-2">
                <option value="">Any</option>
                <option <%= "North".equals(location) ? "selected" : "" %>>North</option>
                <option <%= "South".equals(location) ? "selected" : "" %>>South</option>
                <option <%= "East".equals(location) ? "selected" : "" %>>East</option>
                <option <%= "West".equals(location) ? "selected" : "" %>>West</option>
                <option <%= "Central".equals(location) ? "selected" : "" %>>Central</option>
            </select>

            <!-- VEHICLE -->
            <label class="block text-sm font-medium mt-4">Vehicle Type</label>
            <select name="vehicle_type" class="mt-1 w-full border rounded px-3 py-2">
                <option value="">Any</option>
                <option <%= "Sedan".equals(vehicle) ? "selected" : "" %>>Sedan</option>
                <option <%= "MPV".equals(vehicle) ? "selected" : "" %>>MPV</option>
                <option <%= "Van".equals(vehicle) ? "selected" : "" %>>Van</option>
                <option <%= "Wheelchair Van".equals(vehicle) ? "selected" : "" %>>Wheelchair Van</option>
            </select>

            <!-- WHEELCHAIR FRIENDLY -->
            <div class="mt-4 flex items-center gap-2">
                <input type="checkbox" name="wheelchair_friendly" value="1"
                    <%= "1".equals(wc) ? "checked" : "" %>
                    class="h-4 w-4"/>
                <label class="text-sm">Wheelchair Friendly</label>
            </div>

            <!-- MINIMUM RATING -->
            <label class="block text-sm font-medium mt-4">Minimum Rating</label>
            <select name="min_rating" class="mt-1 w-full border rounded px-3 py-2">
                <option value="">Any</option>
                <option value="1" <%= "1".equals(minRating) ? "selected" : "" %>>1 ★</option>
                <option value="2" <%= "2".equals(minRating) ? "selected" : "" %>>2 ★</option>
                <option value="3" <%= "3".equals(minRating) ? "selected" : "" %>>3 ★</option>
                <option value="4" <%= "4".equals(minRating) ? "selected" : "" %>>4 ★</option>
                <option value="5" <%= "5".equals(minRating) ? "selected" : "" %>>5 ★</option>
            </select>

            <button class="mt-6 w-full bg-blue-600 text-white py-2 rounded hover:bg-blue-700">
                Apply Filters
            </button>
        </form>
    </div>


    <!-- PROVIDER LIST -->
    <div class="col-span-3 space-y-6">
    <%
        boolean found = false;
        while (rs.next()) {
            found = true;
    %>

        <div class="bg-white shadow p-6 rounded-lg flex justify-between items-center">
            <div class="space-y-1">
                <h3 class="text-2xl font-semibold"><%= rs.getString("name") %></h3>
                <p class="text-gray-700">⭐ <%= rs.getDouble("rating") %> / 5</p>
                <p class="text-gray-700">Base Fee: $<%= rs.getDouble("base_fee") %></p>
                <p class="text-gray-700">Estimated Time: <%= rs.getString("est_time") %></p>
                <p class="text-gray-700">Location: <%= rs.getString("location") %></p>
                <p class="text-gray-700">Vehicle: <%= rs.getString("vehicle_type") %></p>

                <% if (rs.getBoolean("wheelchair_friendly")) { %>
                    <p class="text-green-600 font-medium">Wheelchair Friendly</p>
                <% } %>
            </div>

            <a href="TransportDetails.jsp?id=<%= rs.getInt("id") %>"
                class="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700">
                View Provider
            </a>
        </div>

    <% } %>

    <% if (!found) { %>
        <p class="text-gray-500 text-center mt-10">No providers found.</p>
    <% } %>
    </div>
</div>

<%
    rs.close();
    ps.close();
    conn.close();
%>
