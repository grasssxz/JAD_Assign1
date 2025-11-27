<jsp:include page="/auth/AuthCheck.jsp" />
<jsp:include page="/auth/RequireLogin.jsp" />
<jsp:include page="/home/NavBar.jsp" />

<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*, java.util.*" %>

<script src="https://cdn.tailwindcss.com"></script>

<%
Integer memberId = (Integer) session.getAttribute("member_id");
if (memberId == null) {
    response.sendRedirect(request.getContextPath() + "/login/login.html");
    return;
}

// -----------------------------
// SUCCESS MESSAGE HANDLER
// -----------------------------
String msg = request.getParameter("msg");

// -----------------------------
// FILTER HANDLING
// -----------------------------
String filter = request.getParameter("status");
String filterSql = "";

if (filter != null && !filter.equals("all")) {
    filterSql = " AND b.status = '" + filter.toUpperCase() + "' ";
}

// -----------------------------
// DB CONNECTION
// -----------------------------
Class.forName("com.mysql.cj.jdbc.Driver");
Connection conn = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/jad_assign1?user=root&password=1G9r5a6c1E**"
);

// -----------------------------
// FETCH BOOKINGS
// -----------------------------
String sql =
    "SELECT b.id, c.name AS company_name, b.total_price, b.status, " +
    "b.booking_date, b.estimated_delivery " +
    "FROM grocery_order b " +
    "JOIN grocery_company c ON b.company_id = c.id " +
    "WHERE b.member_id = ? " +
    filterSql +
    "ORDER BY b.booking_date DESC";

PreparedStatement ps = conn.prepareStatement(sql);
ps.setInt(1, memberId);
ResultSet rs = ps.executeQuery();
%>

<div class="max-w-5xl mx-auto mt-10 p-6 bg-white rounded shadow">

    <h1 class="text-3xl font-bold mb-6">My Grocery Bookings</h1>

    <!-- SUCCESS NOTIFICATION -->
    <% if (msg != null) { %>
        <div class="mb-5 p-4 rounded text-white
            <% if (msg.equals("Rescheduled")) { %> bg-blue-600 <% }
               else if (msg.equals("Cancelled")) { %> bg-red-600 <% } %>">
            Booking <strong><%= msg %></strong> successfully.
        </div>
    <% } %>

    <!-- FILTER BAR -->
    <div class="flex gap-3 mb-6">
        <a href="GroceryViewAppointments.jsp?status=all"
		   class="px-4 py-2 rounded border <%= (filter==null || filter.equals("all")) ? "bg-gray-900 text-white" : "bg-gray-100" %>">
		    All
		</a>
		>

       <a href="GroceryViewAppointments.jsp?status=pending"
			   class="px-4 py-2 rounded border <%= "pending".equals(filter) ? "bg-yellow-500 text-white" : "bg-gray-100" %>">
			    Pending
			</a>


        <a href="GroceryViewAppointments.jsp?status=completed"
		   class="px-4 py-2 rounded border <%= "completed".equals(filter) ? "bg-green-600 text-white" : "bg-gray-100" %>">
		    Completed
		</a>


        <a href="GroceryViewAppointments.jsp?status=cancelled"
		   class="px-4 py-2 rounded border <%= "cancelled".equals(filter) ? "bg-red-600 text-white" : "bg-gray-100" %>">
		    Cancelled
		</a>

    </div>

    <%
    boolean hasResults = false;

    while (rs.next()) {
        hasResults = true;

        int bookingId = rs.getInt("id");
        String companyName = rs.getString("company_name");
        String date = rs.getString("booking_date");
        String delivery = rs.getString("estimated_delivery");
        double total = rs.getDouble("total_price");
        String status = rs.getString("status");

        // Status color
        String statusColor = "bg-gray-300";
        if ("COMPLETED".equalsIgnoreCase(status)) statusColor = "bg-green-600 text-white";
        if ("PENDING".equalsIgnoreCase(status)) statusColor = "bg-yellow-500 text-white";
        if ("CANCELLED".equalsIgnoreCase(status)) statusColor = "bg-red-600 text-white";
    %>

    <!-- BOOKING CARD -->
    <div class="border rounded-lg p-5 mb-5 shadow-sm bg-gray-50">
        <div class="flex justify-between items-center">
            <h2 class="text-xl font-semibold"><%= companyName %></h2>
            <span class="px-3 py-1 rounded <%= statusColor %>"><%= status %></span>
        </div>

        <div class="mt-3 text-gray-700">
            <p><strong>Booking Date:</strong> <%= date %></p>
            <p><strong>Estimated Delivery:</strong> <%= delivery %></p>
            <p><strong>Total:</strong> $<%= String.format("%.2f", total) %></p>
        </div>

        <div class="mt-4 flex gap-4">
            <% if ("PENDING".equalsIgnoreCase(status)) { %>
                <a href="GroceryReschedule.jsp?id=<%= bookingId %>"
                   class="px-4 py-2 bg-blue-600 text-white rounded">
                    Reschedule
                </a>

                <a href="GroceryCancel.jsp?id=<%= bookingId %>"
                   onclick="return confirm('Cancel this booking?');"
                   class="px-4 py-2 bg-red-600 text-white rounded">
                    Cancel
                </a>
            <% } else { %>
                <span class="text-gray-500">No actions available</span>
            <% } %>
        </div>
    </div>

    <% } %>

    <% if (!hasResults) { %>
        <div class="text-center p-10 text-gray-500 border rounded-lg bg-gray-50">
            <p class="text-xl font-semibold">No bookings found.</p>
        </div>
    <% } %>

</div>
