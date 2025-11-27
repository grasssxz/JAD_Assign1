<jsp:include page="/auth/RequireLogin.jsp" />
<jsp:include page="/auth/SessisonInit.jsp" />
<jsp:include page="/home/NavBar.jsp" />

<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>

<script src="https://cdn.tailwindcss.com"></script>

<%
Integer memberId = (Integer) session.getAttribute("member_id");
if (memberId == null) {
    response.sendRedirect("/login/login.html");
    return;
}

// Notifications
String msg = request.getParameter("msg");

// Filters
String filter = request.getParameter("status");
String filterSQL = "";
if (filter != null && !"all".equals(filter)) {
    filterSQL = " AND t.status = '" + filter.toUpperCase() + "' ";
}

// DB
Class.forName("com.mysql.cj.jdbc.Driver");
Connection conn = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/jad_assign1?user=root&password=1G9r5a6c1E**"
);

String sql =
    "SELECT t.id, p.name AS provider_name, t.booking_date, t.total_fee, t.status " +
    "FROM transport_booking t " +
    "JOIN transport_provider p ON t.provider_id = p.id " +
    "WHERE t.member_id = ? " + filterSQL +
    "ORDER BY t.booking_date DESC";

PreparedStatement ps = conn.prepareStatement(sql);
ps.setInt(1, memberId);
ResultSet rs = ps.executeQuery();

boolean hasResults = false;
%>

<div class="max-w-5xl mx-auto mt-10 p-6 bg-white rounded shadow">

    <h1 class="text-3xl font-bold mb-6">My Transport Bookings</h1>

    <% if (msg != null) { %>
        <div class="p-4 rounded mb-6 text-white
            <%= msg.equals("Rescheduled") ? "bg-blue-600" : "" %>
            <%= msg.equals("Cancelled") ? "bg-red-600" : "" %>">
            Booking <b><%= msg %></b> successfully.
        </div>
    <% } %>

    <!-- FILTER BAR -->
    <div class="flex gap-3 mb-6">
        <a href="ViewTransportBookings.jsp?status=all"
            class="px-4 py-2 rounded border <%= (filter==null || filter.equals("all")) ? "bg-gray-900 text-white" : "bg-gray-100" %>">
            All
        </a>

        <a href="ViewTransportBookings.jsp?status=pending"
            class="px-4 py-2 rounded border <%= "pending".equals(filter) ? "bg-yellow-500 text-white" : "bg-gray-100" %>">
            Pending
        </a>

        <a href="ViewTransportBookings.jsp?status=completed"
            class="px-4 py-2 rounded border <%= "completed".equals(filter) ? "bg-green-600 text-white" : "bg-gray-100" %>">
            Completed
        </a>

        <a href="ViewTransportBookings.jsp?status=cancelled"
            class="px-4 py-2 rounded border <%= "cancelled".equals(filter) ? "bg-red-600 text-white" : "bg-gray-100" %>">
            Cancelled
        </a>
    </div>

<%
while (rs.next()) {
    hasResults = true;

    int bookingId = rs.getInt("id");
    String provider = rs.getString("provider_name");
    String bookingDate = rs.getString("booking_date");
    double totalFee = rs.getDouble("total_fee");
    String status = rs.getString("status");

    String badge = "bg-gray-300";
    if ("PENDING".equalsIgnoreCase(status)) badge = "bg-yellow-500 text-white";
    if ("COMPLETED".equalsIgnoreCase(status)) badge = "bg-green-600 text-white";
    if ("CANCELLED".equalsIgnoreCase(status)) badge = "bg-red-600 text-white";
%>

    <!-- CARD -->
    <div class="bg-gray-50 border rounded p-5 mb-4">
        <div class="flex justify-between items-center">
            <h2 class="text-xl font-bold"><%= provider %></h2>
            <span class="px-3 py-1 rounded <%= badge %>"><%= status %></span>
        </div>

        <p class="mt-3"><b>Date:</b> <%= bookingDate %></p>
        <p><b>Total Fee:</b> $<%= totalFee %></p>

        <div class="mt-4 flex gap-4">
            <% if ("PENDING".equalsIgnoreCase(status)) { %>

                <a href="TransportReschedule.jsp?id=<%= bookingId %>"
                   class="px-4 py-2 bg-blue-600 text-white rounded">
                    Reschedule
                </a>

                <a href="TransportCancel.jsp?id=<%= bookingId %>"
                   onclick="return confirm('Cancel this booking?');"
                   class="px-4 py-2 bg-red-600 text-white rounded">
                    Cancel
                </a>

            <% } else { %>
                <span class="text-gray-500">No actions available</span>
            <% } %>
        </div>
    </div>

<%
} // END while
conn.close();
%>

<% if (!hasResults) { %>
    <p class="text-center text-gray-500 mt-10">No bookings found.</p>
<% } %>

</div>
