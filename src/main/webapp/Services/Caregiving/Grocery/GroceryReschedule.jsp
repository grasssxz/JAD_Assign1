<jsp:include page="/auth/AuthCheck.jsp" />
<jsp:include page="/auth/RequireLogin.jsp" />

<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*" %>

<script src="https://cdn.tailwindcss.com"></script>

<%
Integer memberId = (Integer) session.getAttribute("member_id");
if (memberId == null) {
    response.sendRedirect(request.getContextPath() + "/login/login.html");
    return;
}

int bookingId = Integer.parseInt(request.getParameter("id"));

Class.forName("com.mysql.cj.jdbc.Driver");
Connection conn = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/jad_assign1?user=root&password=1G9r5a6c1E**"
);

// Fetch the old booking date
PreparedStatement ps = conn.prepareStatement(
    "SELECT booking_date FROM grocery_order WHERE id=? AND member_id=?"
);
ps.setInt(1, bookingId);
ps.setInt(2, memberId);
ResultSet rs = ps.executeQuery();

String oldDate = "";
if (rs.next()) {
    oldDate = rs.getString("booking_date");
} else {
    out.println("<h2 style='color:red; text-align:center; margin-top:40px;'>Booking not found.</h2>");
    conn.close();
    return;
}

conn.close();
%>

<div class="max-w-xl mx-auto mt-12 bg-white p-6 rounded shadow">
    <h2 class="text-2xl font-bold mb-4">Reschedule Grocery Booking</h2>

    <form action="GroceryRescheduleSubmit.jsp" method="post" class="space-y-4">
        
        <!-- Hidden booking ID -->
        <input type="hidden" name="booking_id" value="<%= bookingId %>">

        <div>
            <label class="font-semibold">Current Booking Date:</label>
            <p class="p-2 bg-gray-100 border rounded"><%= oldDate %></p>
        </div>

        <div>
            <label class="font-semibold">Select New Date:</label>
            <input type="date" name="new_date" required
                   class="w-full p-2 border rounded">
        </div>

        <button type="submit"
                class="w-full bg-blue-600 text-white p-2 rounded">
            Submit Reschedule
        </button>
    </form>
</div>
